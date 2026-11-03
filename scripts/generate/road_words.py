"""Word clips: one spoken clip for every distinct word text of the A1 road (job word-audio).

The word card plays the word's own clip when the owner has approved it, and the whole line otherwise.
This module makes, counts, lists, publishes and presents those clips. It needs no Voikko, so every
command except voice-words runs on any computer.

Which texts get a clip. Every form of the committed road drafts (content/drafts/<slug>/draft.json, the
written dialogues and the six earlier ones) and every row of content/road/word-notes.tsv gives its
written text, and its spoken text when that is different. Nothing else gets a clip. The same text gets
one clip, whatever form or register it comes from. A text belongs to the part where it first appears,
in road order (stop, then dialogue). The test fixture units (901 and 902) are not road drafts and get
none.

One voice. Every clip is read by WORD_VOICE (Selma, the voice of Maria, who is in every dialogue).

The key. A clip's key is voice.py's request_hash(text, voice): the SHA-256 of the voice name, a new
line and the text, as 64 hex characters. The text is the form's text exactly as stored, with nothing
added. The app computes the same key from the form text it shows (src/lib/word-audio.ts) and asks for
/audio/words/<key>.mp3. A clip is made once: when content/word-audio/<key>.mp3 exists it is kept. A
changed text has a new key, so it gets a new clip. Nothing is ever deleted by this module.

Serving. A clip reaches public/audio/words/ only through publish-words, which copies the keys listed
in the owner's approval file content/approvals/part-<n>-words.json. Until that file exists for a part,
none of its clips is served and every word card of that part plays the line, as before.

python scripts/generate/road_words.py list-words --part N|all
python scripts/generate/road_words.py count-words --part N|all
python scripts/generate/road_words.py voice-words --part N [--limit 600]
python scripts/generate/road_words.py review-words --part N --out <folder>
python scripts/generate/road_words.py publish-words --part N

road_import.py offers the same commands, so the A1 road workflow runs them the same way.
"""

from __future__ import annotations

import argparse
import base64
import html
import json
import re
import shutil
import sys
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path

from providers.voice import request_hash
from road_data import load_notes, load_road_data
from road_parse import REPO

WORD_VOICE = "fi-FI-SelmaNeural"
PARTS = range(1, 7)
# Azure's free tier allows 20 requests a minute, so 600 clips take 30 minutes. A run stops there and
# says how many remain, so the workflow's 45 minute timeout never cancels a run before its upload.
MAX_CLIPS_PER_RUN = 600
APPROVAL_FORMAT = "puhuscribe-owner-word-approval-1"
KEY_PATTERN = re.compile(r"^[0-9a-f]{64}$")
# voice.py's fake provider writes this marker into every clip it makes. A fake clip is never published.
FAKE_MARKER = b"puhuscribe-fake-voice\x00"


class WordsError(RuntimeError):
    """A word clip command refused. Nothing was written."""


def word_key(text: str, voice: str = WORD_VOICE) -> str:
    return request_hash(text, voice)


@dataclass
class Use:
    form_id: str
    register: str  # "puhe", "kirja" or "both"
    written: str
    spoken: str
    meaning: str


@dataclass
class Word:
    key: str
    text: str
    part: int
    stop: int
    slug: str
    stop_title: str
    uses: list[Use] = field(default_factory=list)


def part_of(stop: int) -> int:
    return (stop - 1) // 6 + 1


def road_drafts(repo: Path = REPO) -> list[tuple[int, int, str, dict]]:
    """The committed road drafts in road order, as (stop, dialogue position, slug, draft): the written
    dialogues and the six earlier ones, the same set road_import.committed_road_drafts reads."""
    data = load_road_data(repo / "content" / "road")
    earlier = {slug for stop in data.stops.values() for slug in stop.earlier_dialogues}
    found = []
    for path in sorted((repo / "content" / "drafts").glob("*/draft.json")):
        draft = json.loads(path.read_text(encoding="utf-8"))
        slug = path.parent.name
        if draft["brief"].get("source") != "written" and slug not in earlier:
            continue
        stop = int(draft["brief"]["unit"]["position"])
        found.append((stop, int(draft["brief"]["dialogue"]["position"]), slug, draft))
    found.sort(key=lambda item: (item[0], item[1], item[2]))
    return found


def _texts(written: str, spoken: str) -> list[tuple[str, str]]:
    """The clips one form needs, as (text, register)."""
    written, spoken = written.strip(), spoken.strip()
    if written and written == spoken:
        return [(written, "both")]
    out = []
    if spoken:
        out.append((spoken, "puhe"))
    if written:
        out.append((written, "kirja"))
    return out


def road_words(repo: Path = REPO, voice: str = WORD_VOICE) -> tuple[dict[str, Word], list[str]]:
    """Every word clip of the road, by key, in road order, and the word-notes.tsv form ids that no road
    draft holds (their texts get clips in the part of no dialogue, so they are reported, not voiced)."""
    words: dict[str, Word] = {}
    seen_forms: set[str] = set()
    for stop, _position, slug, draft in road_drafts(repo):
        title = f"Stop {stop}, {draft['brief']['unit'].get('title_en', '')}".rstrip(", ")
        for form in draft["forms"]:
            seen_forms.add(form["id"])
            for text, register in _texts(form["surface_kirja"], form["surface_puhe"]):
                key = word_key(text, voice)
                word = words.get(key)
                if word is None:
                    word = Word(key, text, part_of(stop), stop, slug, title)
                    words[key] = word
                if not any(u.form_id == form["id"] and u.register == register for u in word.uses):
                    word.uses.append(
                        Use(
                            form["id"],
                            register,
                            form["surface_kirja"],
                            form["surface_puhe"],
                            form.get("meaning_en") or form.get("lemma_meaning_en") or "",
                        )
                    )
    notes = load_notes(repo / "content" / "road" / "word-notes.tsv")
    unplaced = sorted(fid for fid in notes if fid not in seen_forms)
    return words, unplaced


def part_words(part: int | None, repo: Path = REPO) -> list[Word]:
    words, _ = road_words(repo)
    return [w for w in words.values() if part is None or w.part == part]


def clip_path(key: str, repo: Path = REPO) -> Path:
    return repo / "content" / "word-audio" / f"{key}.mp3"


def has_clip(word: Word, repo: Path = REPO) -> bool:
    path = clip_path(word.key, repo)
    return path.is_file() and path.stat().st_size > 0


def to_make(words: list[Word], repo: Path = REPO) -> list[Word]:
    return [w for w in words if not has_clip(w, repo)]


def _parse_part(value: str) -> int | None:
    if value == "all":
        return None
    number = int(value)
    if number not in PARTS:
        raise argparse.ArgumentTypeError("the part must be 1 to 6 or all")
    return number


def _one_part(value: str) -> int:
    number = _parse_part(value)
    if number is None:
        raise argparse.ArgumentTypeError("this command needs one part, 1 to 6")
    return number


# list-words and count-words (no key, no call) ---------------------------------------------------


def cmd_list(args, repo: Path = REPO) -> int:
    for word in part_words(args.part, repo):
        registers = ", ".join(
            f"{u.form_id} {'spoken and written' if u.register == 'both' else u.register}" for u in word.uses
        )
        state = "clip" if has_clip(word, repo) else "no clip"
        print(f"{word.key[:12]}\tpart {word.part}\tstop {word.stop}\t{word.text}\t{state}\t{registers}")
    return 0


def count_rows(repo: Path = REPO) -> list[dict]:
    words, _ = road_words(repo)
    rows = []
    for part in PARTS:
        mine = [w for w in words.values() if w.part == part]
        missing = to_make(mine, repo)
        rows.append(
            {
                "part": part,
                "clips": len(mine),
                "characters": sum(len(w.text) for w in mine),
                "to_make": len(missing),
                "characters_to_make": sum(len(w.text) for w in missing),
            }
        )
    return rows


def cmd_count(args, repo: Path = REPO) -> int:
    """The dry count: the exact characters Azure would bill, per part, before any call."""
    rows = count_rows(repo)
    _, unplaced = road_words(repo)
    shown = [r for r in rows if args.part is None or r["part"] == args.part]
    print(f"Word clips in one voice ({WORD_VOICE}). Characters are what Azure bills: the text only.")
    for r in shown:
        print(
            f"Part {r['part']}: {r['clips']} clips, {r['characters']} characters; still to make "
            f"{r['to_make']} clips, {r['characters_to_make']} characters"
        )
    if args.part is None:
        print(
            f"The road: {sum(r['clips'] for r in rows)} clips, "
            f"{sum(r['characters'] for r in rows)} characters; "
            f"still to make {sum(r['to_make'] for r in rows)} clips, "
            f"{sum(r['characters_to_make'] for r in rows)} characters"
        )
    if unplaced:
        print(f"word-notes.tsv rows that no road draft holds (not voiced): {len(unplaced)}")
    return 0


# voice-words (the Azure key, in the workflow only) ----------------------------------------------


def cmd_voice(args, voice=None, repo: Path = REPO) -> int:
    from providers import voice as voice_module

    voice = voice or voice_module.get_provider()
    missing = to_make(part_words(args.part, repo), repo)
    limit = max(1, int(getattr(args, "limit", None) or MAX_CLIPS_PER_RUN))
    batch = missing[:limit]
    need = sum(len(w.text) for w in batch)
    # Both checks are voice.py's own, unchanged: an uncommitted log, and the monthly guard.
    voice_module.refuse_uncommitted_log(voice.log_path)
    voice_module.refuse_over_allowance(voice.log_path, need)
    print(f"Voicing {len(batch)} word clips, {need} characters, for part {args.part} ({WORD_VOICE})")
    folder = repo / "content" / "word-audio"
    folder.mkdir(parents=True, exist_ok=True)
    made = 0
    for word in batch:
        audio = voice.synthesize(text=word.text, voice=WORD_VOICE, dialogue=f"words-part-{args.part}")
        part_file = folder / f"{word.key}.mp3.part"
        part_file.write_bytes(audio)
        part_file.replace(folder / f"{word.key}.mp3")
        made += 1
    remaining = len(missing) - made
    print(f"Made {made} word clips. Still to make for part {args.part}: {remaining}")
    if remaining:
        print("Run voice-words again for this part after the log is committed, to carry on.")
    return 0


# review-words: the owner's listening page ------------------------------------------------------

PAGE_STYLE = """
/* The app's own token values (src/styles/tokens.css), light only like the app. */
:root { color-scheme: light; --bg: #f7f8f6; --ink: #1b2a26; --quiet: #556863;
  --spoken: #d6efe7; --written: #edf2f8; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--ink);
  font: 16px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; }
main { max-width: 760px; margin: 0 auto; padding: 32px 16px 96px; }
h1 { font-size: 26px; line-height: 1.2; margin: 0 0 8px; font-weight: 650; }
h2 { font-size: 19px; margin: 36px 0 12px; font-weight: 650; }
p { margin: 0 0 10px; }
h1, h2, p, li, .text { overflow-wrap: anywhere; }
.intro { color: var(--quiet); }
ol { list-style: none; margin: 0; padding: 0; }
li { margin: 0 0 12px; padding: 14px 16px; border-radius: 14px; background: var(--written); }
li.puhe, li.both { background: var(--spoken); }
.text { font-size: 22px; font-weight: 650; margin: 0 0 2px; }
.about { color: var(--quiet); font-size: 14px; margin: 0 0 8px; }
.id { font-family: ui-monospace, "SFMono-Regular", Menlo, Consolas, monospace; font-size: 13px; }
audio { width: 100%; max-width: 360px; display: block; }
.missing { color: var(--quiet); font-style: italic; }
"""


def _about(word: Word) -> str:
    parts = []
    for use in word.uses:
        if use.register == "both":
            what = f"spoken and written ({use.written})"
        elif use.register == "puhe":
            what = f"spoken form of {use.written}"
        else:
            what = f"written form, spoken {use.spoken}" if use.spoken else "written form"
        if use.meaning:
            what += f": {use.meaning}"
        parts.append(what)
    return "; ".join(dict.fromkeys(parts))


def listening_page(part: int, repo: Path = REPO) -> str:
    """One self contained page: every clip of the part with its text, what it is and a native player.
    The audio is inside the file; the Content Security Policy allows nothing from the network and no
    script. Every text is HTML escaped, so a text such as <script> is printed, never run."""
    words = part_words(part, repo)
    made = [w for w in words if has_clip(w, repo)]
    out = [
        "<!doctype html>",
        '<html lang="en"><head><meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
        '<meta http-equiv="Content-Security-Policy" content="default-src \'none\'; '
        "style-src 'unsafe-inline'; media-src data:\">",
        f"<title>Word clips, part {part}</title>",
        f"<style>{PAGE_STYLE}</style></head><body><main>",
        f"<h1>Word clips, part {part}</h1>",
        f'<p class="intro">{len(words)} words are new in part {part}. {len(made)} have a clip, read by '
        f"Selma ({html.escape(WORD_VOICE)}). Each word is read alone, exactly as the app shows it. "
        "Words that first appear in an earlier part are on that part's page.</p>",
        '<p class="intro">To approve, tell the manager in your own words, for example "I approve the word '
        f'clips of part {part}". To leave some out, name their clip ids (the short code under each word). '
        "A clip you leave out keeps playing the whole line in the app.</p>",
    ]
    if len(made) < len(words):
        out.append(
            f'<p class="intro">{len(words) - len(made)} words have no clip yet. They are listed, marked '
            '"No clip yet", and cannot be approved until they are voiced.</p>'
        )
    current = None
    for word in words:
        if word.stop != current:
            if current is not None:
                out.append("</ol>")
            out.append(f"<h2>{html.escape(word.stop_title)}</h2><ol>")
            current = word.stop
        register = word.uses[0].register if word.uses else "kirja"
        out.append(f'<li class="{register}">')
        out.append(f'<p class="text" lang="fi">{html.escape(word.text)}</p>')
        out.append(f'<p class="about">{html.escape(_about(word))}</p>')
        out.append(f'<p class="about">Clip id <span class="id">{word.key[:12]}</span></p>')
        if has_clip(word, repo):
            data = base64.b64encode(clip_path(word.key, repo).read_bytes()).decode("ascii")
            label = html.escape(f"Play {word.text}", quote=True)
            out.append(
                f'<audio controls preload="none" aria-label="{label}" '
                f'src="data:audio/mpeg;base64,{data}"></audio>'
            )
        else:
            out.append('<p class="missing">No clip yet</p>')
        out.append("</li>")
    if current is not None:
        out.append("</ol>")
    out.append("</main></body></html>")
    return "\n".join(out) + "\n"


def cmd_review(args, repo: Path = REPO) -> int:
    folder = Path(args.out)
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / f"words-part-{args.part}.html"
    path.write_text(listening_page(args.part, repo), encoding="utf-8", newline="\n")
    print(f"Wrote {path}")
    return 0


# publish-words: only clips the owner approved reach public/audio/words/ ---------------------------


def approval_path(part: int, repo: Path = REPO) -> Path:
    return repo / "content" / "approvals" / f"part-{part}-words.json"


def read_approval(part: int, repo: Path = REPO) -> list[str]:
    """The approved keys of a part, after every check on the owner's approval file."""
    path = approval_path(part, repo)
    if not path.is_file():
        raise WordsError(f"{path.name} does not exist: the owner has not approved part {part}'s word clips")
    approval = json.loads(path.read_text(encoding="utf-8"))
    if approval.get("format") != APPROVAL_FORMAT:
        raise WordsError(f"{path.name} is not in the format {APPROVAL_FORMAT}")
    if approval.get("part") != part:
        raise WordsError(f"{path.name} names part {approval.get('part')}, not part {part}")
    if not str(approval.get("approval", "")).strip():
        raise WordsError(f"{path.name} has no approval line from the owner")
    try:
        date.fromisoformat(str(approval.get("date", "")))
    except ValueError:
        raise WordsError(f"{path.name} has no valid date (YYYY-MM-DD)") from None
    keys = approval.get("keys")
    if not isinstance(keys, list) or not keys:
        raise WordsError(f"{path.name} lists no clip keys")
    bad = [k for k in keys if not isinstance(k, str) or not KEY_PATTERN.match(k)]
    if bad:
        raise WordsError(f"{path.name} holds keys that are not 64 hex characters: {bad[:3]}")
    return list(dict.fromkeys(keys))


def publish_words(part: int, repo: Path = REPO) -> list[str]:
    """Copies the approved clips of a part to public/audio/words/<key>.mp3 and returns the keys copied.
    Refuses, writing nothing, when the approval file fails a check, when a key is not one of this part's
    words in the current drafts, or when a clip is missing or came from the fake provider."""
    keys = read_approval(part, repo)
    mine = {w.key: w for w in part_words(part, repo)}
    problems = []
    for key in keys:
        if key not in mine:
            problems.append(f"{key[:12]} is not a word of part {part} in the current drafts")
            continue
        path = clip_path(key, repo)
        if not path.is_file() or path.stat().st_size == 0:
            problems.append(f"{key[:12]} ({mine[key].text}) has no clip in content/word-audio/")
        elif FAKE_MARKER in path.read_bytes()[:512]:
            problems.append(f"{key[:12]} ({mine[key].text}) was made by the fake voice provider")
    if problems:
        raise WordsError("nothing was published:\n  " + "\n  ".join(problems))
    target = repo / "public" / "audio" / "words"
    target.mkdir(parents=True, exist_ok=True)
    for key in keys:
        shutil.copyfile(clip_path(key, repo), target / f"{key}.mp3")
    return keys


def cmd_publish(args, repo: Path = REPO) -> int:
    keys = publish_words(args.part, repo)
    left_out = len(part_words(args.part, repo)) - len(keys)
    print(f"Published {len(keys)} word clips of part {args.part} to public/audio/words/.")
    if left_out:
        print(f"{left_out} words of part {args.part} are not approved and keep playing the whole line.")
    return 0


# The command line -------------------------------------------------------------------------------

COMMANDS = {
    "list-words": cmd_list,
    "count-words": cmd_count,
    "voice-words": cmd_voice,
    "review-words": cmd_review,
    "publish-words": cmd_publish,
}


def add_commands(sub) -> None:
    """The word clip commands, for this file's command line and for road_import.py's."""
    lst = sub.add_parser("list-words")
    lst.add_argument("--part", type=_parse_part, required=True)
    cnt = sub.add_parser("count-words")
    cnt.add_argument("--part", type=_parse_part, default=None)
    vo = sub.add_parser("voice-words")
    vo.add_argument("--part", type=_one_part, required=True)
    vo.add_argument("--limit", type=int, default=MAX_CLIPS_PER_RUN, help="at most this many clips this run")
    rv = sub.add_parser("review-words")
    rv.add_argument("--part", type=_one_part, required=True)
    rv.add_argument("--out", required=True)
    pub = sub.add_parser("publish-words")
    pub.add_argument("--part", type=_one_part, required=True)


def run(args) -> int:
    from providers.voice import VoiceError

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    try:
        return COMMANDS[args.command](args)
    except (WordsError, VoiceError) as err:
        print(f"Stopped: {err}")
        return 1


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Word clips of the A1 road")
    sub = parser.add_subparsers(dest="command", required=True)
    add_commands(sub)
    return run(parser.parse_args(argv))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
