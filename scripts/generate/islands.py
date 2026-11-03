"""Language islands: one personal line per stop (fast route "islands", 3 November 2026).

The owner approved the lines and the fill-in lists in content/islands/islands.md ("Yes, approved",
3 November 2026). content/approvals/islands.json holds that file's SHA-256. Every command here first
reads islands.md and refuses, writing nothing, when its SHA-256 is not the approved one: a change to
the file voids the approval. Nothing here ever writes islands.md.

The English shown on the "Meaning" line of each choice is in content/islands/meanings.tsv (English
only; the Finnish is islands.md's).

python scripts/generate/islands.py build
    Writes src/lib/islands-data.json, the data the app and the Worker read: per stop, the spoken and
    written pattern, the English, the fill-in list it uses and the audio key of every line it can make.
python scripts/generate/islands.py unmet [--out <file>]
    Lists every word of every line a stop can make that the learner has not met in the road's dialogues
    of that stop or an earlier one (content/drafts/*/draft.json). Reports only; changes nothing.
python scripts/generate/islands.py check-islands [--out <folder>]
    The road importer's checks on every line: Voikko on every written word (needs Linux with Voikko, so
    it runs in the A1 road workflow), the spoken to written word mapping, and the unmet word report.
python scripts/generate/islands.py count-islands
    The dry count: the clips and the exact characters Azure would bill, before any call.
python scripts/generate/islands.py voice-islands [--limit 600]
    Selma reads every line once per choice in its list, spoken and written, into
    content/island-audio/<key>.mp3. A clip that exists is kept. Needs the Azure key (workflow only).
python scripts/generate/islands.py publish-islands
    Copies the clips into public/audio/islands/, where the app plays them. Refuses a fake clip.

Which texts are voiced. Each line a stop can make, once per choice in its list, in spoken and in
written Finnish, by one voice (ISLAND_VOICE, Selma). The stop 1 name sentence ("Mä oon {name}." and
"Minä olen {name}.") is never voiced: no learner's name is ever sent to a voice service. Its other
sentence (the country) is voiced per country. The island's closing question ("Entä sä?" and
"Entä sinä?") is voiced once. The same text is voiced once, whatever stop it comes from.

The key. A clip's key is voice.py's request_hash(text, voice): the SHA-256 of the voice name, a new
line and the text, as 64 hex characters, the same key the word clips use.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path

from providers.voice import request_hash

REPO = Path(__file__).resolve().parents[2]
SOURCE = REPO / "content" / "islands" / "islands.md"
APPROVAL = REPO / "content" / "approvals" / "islands.json"
MEANINGS = REPO / "content" / "islands" / "meanings.tsv"
DATA = REPO / "src" / "lib" / "islands-data.json"
AUDIO = REPO / "content" / "island-audio"
PUBLIC_AUDIO = REPO / "public" / "audio" / "islands"
DATA_FORMAT = "puhuscribe-islands-1"
APPROVAL_FORMAT = "puhuscribe-owner-approval-islands-1"
ISLAND_VOICE = "fi-FI-SelmaNeural"
NAME_GAP = "name"
NAME_MAX = 30
# The island ends with a question back (islands.md, top).
CLOSING = {"spoken": "Entä sä?", "written": "Entä sinä?", "english": "And you?"}
# Azure's free tier allows 20 requests a minute, so 600 clips take 30 minutes (as road_words.py).
MAX_CLIPS_PER_RUN = 600
# voice.py's fake provider writes this marker into every clip it makes. A fake clip is never published.
FAKE_MARKER = b"puhuscribe-fake-voice\x00"
GAP = re.compile(r"\{([^{}]+)\}")
SENTENCE_END = re.compile(r"(?<=[.!?])\s+")
_EDGE_PUNCT = ".,!?;:\"'“”‘’«»()[]{}…-–—/\\|*_~`"


class IslandsError(RuntimeError):
    """An islands command refused. Nothing was written."""


@dataclass
class Choice:
    spoken: str
    written: str
    english: str = ""


@dataclass
class Stop:
    number: int
    title: str
    spoken: str
    written: str
    english: str
    list: str | None
    name: bool
    optional: bool = False
    lines: list[dict] = field(default_factory=list)


# Reading islands.md -----------------------------------------------------------------------------


def approved_text(source: Path = SOURCE, approval: Path = APPROVAL) -> str:
    """islands.md as text, only when its SHA-256 is the one the owner approved."""
    if not approval.is_file():
        raise IslandsError(f"{approval.name} does not exist: the island lines are not approved")
    record = json.loads(approval.read_text(encoding="utf-8"))
    if record.get("format") != APPROVAL_FORMAT:
        raise IslandsError(f"{approval.name} is not in the format {APPROVAL_FORMAT}")
    if not str(record.get("approved_line", "")).strip():
        raise IslandsError(f"{approval.name} has no approval line from the owner")
    raw = source.read_bytes()
    found = hashlib.sha256(raw).hexdigest()
    if found != record.get("sha256"):
        raise IslandsError(
            f"{source.name} is not the approved file (SHA-256 {found[:12]}, approved "
            f"{str(record.get('sha256'))[:12]}): a change voids the owner's approval"
        )
    return raw.decode("utf-8")


def _gap_key(name: str) -> str:
    """The list a gap fills from: {weekend_past_w} is the written side of the weekend_past list."""
    return name[:-2] if name.endswith("_w") else name


def parse_stops(text: str) -> list[Stop]:
    stops = []
    for raw in text.splitlines():
        if not raw.startswith("| "):
            continue
        cells = [cell.strip() for cell in raw.strip().strip("|").split("|")]
        if len(cells) != 4:
            continue
        head = re.match(r"^(\d+) (.+)$", cells[0])
        if not head:
            continue
        number, title = int(head.group(1)), head.group(2)
        spoken, written, english = cells[1], cells[2], cells[3]
        if spoken.startswith("(no personal line)"):
            continue
        spoken_gaps = [_gap_key(g) for g in GAP.findall(spoken)]
        written_gaps = [_gap_key(g) for g in GAP.findall(written)]
        if sorted(spoken_gaps) != sorted(written_gaps):
            raise IslandsError(f"stop {number}: the spoken and written lines fill different gaps")
        lists = [g for g in spoken_gaps if g != NAME_GAP]
        if len(lists) > 1:
            raise IslandsError(f"stop {number}: a line may fill one list gap, it has {len(lists)}")
        english_gaps = GAP.findall(english)
        name = NAME_GAP in spoken_gaps
        if name != (NAME_GAP in english_gaps) or len([g for g in english_gaps if g != NAME_GAP]) != len(
            lists
        ):
            raise IslandsError(f"stop {number}: the English line's gaps do not match the Finnish line's")
        stops.append(Stop(number, title, spoken, written, english, lists[0] if lists else None, name))
    numbers = [s.number for s in stops]
    if numbers != sorted(set(numbers)):
        raise IslandsError("the stops are not in order, or a stop has two lines")
    return stops


def _strip_end(body: str) -> str:
    return body[:-1] if body.endswith(".") else body


def _pair(item: str) -> Choice:
    if " / " in item:
        spoken, written = item.split(" / ", 1)
        return Choice(spoken.strip(), written.strip())
    return Choice(item.strip(), item.strip())


def parse_lists(text: str) -> tuple[dict[str, list[Choice]], set[str]]:
    """The fill-in lists by name, and the names of the lists the learner may skip."""
    lists: dict[str, list[Choice]] = {}
    optional: set[str] = set()
    in_lists = False
    for raw in text.splitlines():
        if raw.startswith("## "):
            in_lists = raw.strip() == "## Fill-in lists"
            continue
        if not in_lists or not raw.startswith("- **"):
            continue
        match = re.match(r"^- \*\*([a-z_]+):?\*\*(?: \(([^)]*)\))?:?\s*(.*)$", raw)
        if not match:
            raise IslandsError(f"a fill-in list line cannot be read: {raw[:40]}")
        key, note, body = match.group(1), match.group(2) or "", match.group(3).strip()
        if key == NAME_GAP:
            continue
        if "may skip" in note:
            optional.add(key)
        body = re.sub(r"^the same countries:\s*", "", body)
        if ". / " in body:
            # Whole sentences: "Mulla on mies. / Minulla on mies. Mulla on vaimo. / ..."
            pairs = re.findall(r"\s*(.+?[.!?])\s/\s(.+?[.!?])(?=\s|$)", body)
            items = [Choice(s.strip(), w.strip()) for s, w in pairs]
        elif ";" in body:
            items = [_pair(item) for item in _strip_end(body).split(";")]
        else:
            items = [_pair(item) for item in _strip_end(body).split(",")]
        if not items or any(not c.spoken or not c.written for c in items):
            raise IslandsError(f"the list {key} has an empty choice")
        lists[key] = items
    return lists, optional


def read_meanings(path: Path = MEANINGS) -> dict[tuple[str, str], str]:
    found: dict[tuple[str, str], str] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not raw.strip() or raw.startswith("#"):
            continue
        cells = raw.split("\t")
        if len(cells) != 3 or not all(c.strip() for c in cells):
            raise IslandsError(f"{path.name}, line {number}: needs a list, a written choice and the English")
        found[(cells[0].strip(), cells[1].strip())] = cells[2].strip()
    return found


# Filling a line -----------------------------------------------------------------------------------


def fill(template: str, register: str, choice: Choice | None, name: str | None = None) -> str:
    def value(match: re.Match[str]) -> str:
        key = match.group(1)
        if key == NAME_GAP:
            return name if name is not None else "{name}"
        if choice is None:
            raise IslandsError(f"the gap {{{key}}} needs a choice")
        return choice.spoken if register == "spoken" else choice.written

    return GAP.sub(value, template)


def voiced_part(template: str) -> str:
    """The part of a line that is voiced: every sentence except the one with the learner's name."""
    return " ".join(s for s in SENTENCE_END.split(template.strip()) if "{" + NAME_GAP + "}" not in s)


def english_line(template: str, choice: Choice | None) -> str:
    def value(match: re.Match[str]) -> str:
        if match.group(1) == NAME_GAP:
            return "{name}"
        assert choice is not None
        word = choice.english
        # "{Time of day} suits me best.": a gap written with a capital starts the sentence.
        return word[:1].upper() + word[1:] if match.group(1)[:1].isupper() else word

    return GAP.sub(value, template)


def load(source: Path = SOURCE, approval: Path = APPROVAL, meanings: Path = MEANINGS):
    """Every stop with a line, the lists (with their English) and the optional lists."""
    text = approved_text(source, approval)
    stops = parse_stops(text)
    lists, optional = parse_lists(text)
    english = read_meanings(meanings)
    for key, items in lists.items():
        for choice in items:
            if (key, choice.written) not in english:
                raise IslandsError(f"{MEANINGS.name} has no English for {key} {choice.written!r}")
            choice.english = english[(key, choice.written)]
    known = {(key, c.written) for key, items in lists.items() for c in items}
    stray = sorted(set(english) - known)
    if stray:
        raise IslandsError(f"{MEANINGS.name} names choices no list has: {stray[:3]}")
    for stop in stops:
        if stop.list is not None and stop.list not in lists:
            raise IslandsError(f"stop {stop.number} fills from {stop.list}, which islands.md does not list")
        stop.optional = stop.list in optional
        choices: list[Choice | None] = list(lists[stop.list]) if stop.list else [None]
        for index, choice in enumerate(choices):
            spoken = fill(voiced_part(stop.spoken), "spoken", choice)
            written = fill(voiced_part(stop.written), "written", choice)
            stop.lines.append(
                {"choice": None if choice is None else index, "spoken": spoken, "written": written}
            )
    return stops, lists


def clip_texts(stops: list[Stop]) -> list[tuple[str, int | None]]:
    """Every distinct text to voice, in road order, with the stop it first comes from (None: closing)."""
    seen: dict[str, int | None] = {}
    for stop in stops:
        for line in stop.lines:
            for register in ("spoken", "written"):
                text = line[register]
                if text and text not in seen:
                    seen[text] = stop.number
    for register in ("spoken", "written"):
        seen.setdefault(CLOSING[register], None)
    return list(seen.items())


def key(text: str) -> str:
    return request_hash(text, ISLAND_VOICE)


# build ------------------------------------------------------------------------------------------


def data(stops: list[Stop], lists: dict[str, list[Choice]]) -> dict:
    return {
        "format": DATA_FORMAT,
        "source": "content/islands/islands.md",
        "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "voice": ISLAND_VOICE,
        "name_max": NAME_MAX,
        "stops": [
            {
                "stop": s.number,
                "title": s.title,
                "spoken": s.spoken,
                "written": s.written,
                "english": s.english,
                "list": s.list,
                "name": s.name,
                "optional": s.optional,
                # One entry per choice of the list (one for a line with no list): the clip keys of the
                # voiced part of the line, spoken and written.
                "audio": [
                    {"spoken": key(line["spoken"]), "written": key(line["written"])} for line in s.lines
                ],
            }
            for s in stops
        ],
        "lists": {
            name: [{"spoken": c.spoken, "written": c.written, "english": c.english} for c in items]
            for name, items in lists.items()
        },
        "closing": {**CLOSING, "audio": {r: key(CLOSING[r]) for r in ("spoken", "written")}},
    }


def cmd_build(args) -> int:
    stops, lists = load()
    out = Path(args.out) if getattr(args, "out", None) else DATA
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        json.dumps(data(stops, lists), ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n"
    )
    print(
        f"Wrote {out.relative_to(REPO) if out.is_relative_to(REPO) else out}: {len(stops)} stops with a line"
    )
    return 0


# unmet: words the learner has not met by that stop -----------------------------------------------


def words(text: str) -> list[str]:
    out = []
    for raw in text.replace("{" + NAME_GAP + "}", " ").split():
        core = raw.strip(_EDGE_PUNCT)
        if core and any(ch.isalpha() for ch in core):
            out.append(core.lower())
    return out


def met_by_stop(repo: Path = REPO) -> dict[int, set[str]]:
    """Every word (as it appears, lower case) of the road's dialogue lines, spoken and written, of each
    stop and every stop before it. The road's dialogues are the committed drafts whose brief names a
    stop (content/drafts/<slug>/draft.json)."""
    by_stop: dict[int, set[str]] = {n: set() for n in range(1, 37)}
    for path in sorted((repo / "content" / "drafts").glob("*/draft.json")):
        draft = json.loads(path.read_text(encoding="utf-8"))
        stop = int(draft.get("brief", {}).get("unit", {}).get("position", 0))
        if stop not in by_stop:
            continue
        for line in draft.get("lines", []):
            for register in ("text_puhe", "text_kirja"):
                by_stop[stop].update(words(line.get(register) or ""))
    running: set[str] = set()
    met = {}
    for n in range(1, 37):
        running |= by_stop[n]
        met[n] = set(running)
    return met


def unmet_report(stops: list[Stop], lists: dict[str, list[Choice]], met: dict[int, set[str]]) -> list[dict]:
    """Per stop and register, the words of its lines (every choice) the learner has not met there."""
    rows = []
    for stop in stops:
        choices: list[Choice | None] = list(lists[stop.list]) if stop.list else [None]
        for register in ("spoken", "written"):
            template = stop.spoken if register == "spoken" else stop.written
            seen: dict[str, list[str]] = {}
            for choice in choices:
                choice_text = fill(template, register, choice)
                for word in words(choice_text):
                    if word not in met[stop.number]:
                        seen.setdefault(word, []).append(choice_text)
            for word, lines in seen.items():
                rows.append({"stop": stop.number, "register": register, "word": word, "lines": len(lines)})
    return rows


def unmet_text(stops: list[Stop], rows: list[dict]) -> str:
    out = [
        "# Island words not met in the road by that stop",
        "",
        "Made by `python scripts/generate/islands.py unmet` from content/islands/islands.md (the approved",
        "file, unchanged) and the road's dialogue drafts. A word counts as met when the same word, in the",
        "same form, is in a spoken or written line of a dialogue of that stop or an earlier one. The",
        "learner's name is left out. This is a report for the owner and the native reviewer; nothing was",
        "changed. A choice word (a country, a drink) is listed once per stop.",
        "",
    ]
    if not rows:
        out.append("Every word of every island line was met by its stop.")
        return "\n".join(out) + "\n"
    out += ["| Stop | Spoken words not met | Written words not met |", "|---|---|---|"]
    for stop in stops:
        mine = [r for r in rows if r["stop"] == stop.number]
        if not mine:
            continue
        spoken = ", ".join(r["word"] for r in mine if r["register"] == "spoken") or "none"
        written = ", ".join(r["word"] for r in mine if r["register"] == "written") or "none"
        out.append(f"| {stop.number} {stop.title} | {spoken} | {written} |")
    clean = [s.number for s in stops if not any(r["stop"] == s.number for r in rows)]
    out += ["", f"Stops whose every word was met: {', '.join(map(str, clean)) or 'none'}."]
    return "\n".join(out) + "\n"


def cmd_unmet(args) -> int:
    stops, lists = load()
    text = unmet_text(stops, unmet_report(stops, lists, met_by_stop()))
    if getattr(args, "out", None):
        Path(args.out).write_text(text, encoding="utf-8", newline="\n")
        print(f"Wrote {args.out}")
    else:
        sys.stdout.write(text)
    return 0


# check-islands: Voikko and the word mapping (Linux with Voikko) --------------------------------


def check_lines(stops: list[Stop], lists: dict[str, list[Choice]], gate=None, forms=None) -> dict:
    """Voikko on every written word of every line a stop can make (the name left out), and the road's
    spoken to written mapping on every pair. Returns the findings; writes nothing."""
    from road_mapping import SpokenForms, map_line

    forms = forms or SpokenForms.load()
    voikko_rows: list[dict] = []
    mapping_rows: list[dict] = []
    seen: set[tuple[str, str]] = set()
    for stop in stops:
        choices: list[Choice | None] = list(lists[stop.list]) if stop.list else [None]
        for choice in choices:
            spoken = fill(stop.spoken, "spoken", choice, name="")
            written = fill(stop.written, "written", choice, name="")
            if (spoken, written) in seen:
                continue
            seen.add((spoken, written))
            if gate is not None:
                result = gate.validate(written)
                if result.invalid_tokens:
                    voikko_rows.append({"stop": stop.number, "text": written, "words": result.invalid_tokens})
            _, mapping = map_line(spoken, written, forms)
            if mapping.refusals:
                mapping_rows.append(
                    {"stop": stop.number, "spoken": spoken, "written": written, "problems": mapping.failures}
                )
    return {"voikko": voikko_rows, "mapping": mapping_rows}


def cmd_check(args) -> int:
    from voikko_gate import VoikkoGate

    stops, lists = load()
    found = check_lines(stops, lists, gate=VoikkoGate())
    rows = unmet_report(stops, lists, met_by_stop())
    out = ["# Island lines: the road's checks", ""]
    out.append(
        f"Voikko on every written word: {len(found['voikko'])} lines with a word Voikko does not know."
    )
    for row in found["voikko"]:
        out.append(f"- Stop {row['stop']}: {row['text']} ({', '.join(row['words'])})")
    out += ["", f"The spoken to written word mapping: {len(found['mapping'])} lines it does not accept."]
    for row in found["mapping"]:
        out.append(f"- Stop {row['stop']}: {row['spoken']} / {row['written']}: {'; '.join(row['problems'])}")
    out += ["", unmet_text(stops, rows)]
    text = "\n".join(out) + "\n"
    if getattr(args, "out", None):
        folder = Path(args.out)
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "islands-check.md").write_text(text, encoding="utf-8", newline="\n")
        (folder / "islands-check.json").write_text(
            json.dumps({**found, "unmet": rows}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    sys.stdout.write(text)
    return 1 if found["voikko"] else 0


# count-islands, voice-islands and publish-islands -------------------------------------------------


def clip_path(clip_key: str, folder: Path = AUDIO) -> Path:
    return folder / f"{clip_key}.mp3"


def has_clip(clip_key: str, folder: Path = AUDIO) -> bool:
    path = clip_path(clip_key, folder)
    return path.is_file() and path.stat().st_size > 0


def cmd_count(args) -> int:
    stops, _ = load()
    texts = clip_texts(stops)
    missing = [t for t, _ in texts if not has_clip(key(t))]
    print(f"Island clips in one voice ({ISLAND_VOICE}). Characters are what Azure bills: the text only.")
    print(f"{len(texts)} clips, {sum(len(t) for t, _ in texts)} characters in all.")
    print(f"Still to make: {len(missing)} clips, {sum(len(t) for t in missing)} characters.")
    print("The stop 1 name sentence is not voiced: no learner's name is ever sent to the voice service.")
    return 0


def cmd_voice(args, voice=None) -> int:
    from providers import voice as voice_module

    stops, _ = load()
    voice = voice or voice_module.get_provider()
    missing = [t for t, _ in clip_texts(stops) if not has_clip(key(t))]
    limit = max(1, int(getattr(args, "limit", None) or MAX_CLIPS_PER_RUN))
    batch = missing[:limit]
    need = sum(len(t) for t in batch)
    # Both checks are voice.py's own, unchanged: an uncommitted log, and the monthly guard.
    voice_module.refuse_uncommitted_log(voice.log_path)
    voice_module.refuse_over_allowance(voice.log_path, need)
    print(f"Voicing {len(batch)} island clips, {need} characters ({ISLAND_VOICE})")
    AUDIO.mkdir(parents=True, exist_ok=True)
    for text in batch:
        audio = voice.synthesize(text=text, voice=ISLAND_VOICE, dialogue="islands")
        part = AUDIO / f"{key(text)}.mp3.part"
        part.write_bytes(audio)
        part.replace(clip_path(key(text)))
    remaining = len(missing) - len(batch)
    print(f"Made {len(batch)} island clips. Still to make: {remaining}")
    if remaining:
        print("Run voice-islands again after the log is committed, to carry on.")
    return 0


def cmd_publish(args) -> int:
    stops, _ = load()
    keys = [key(t) for t, _ in clip_texts(stops)]
    fake = [k for k in keys if has_clip(k) and FAKE_MARKER in clip_path(k).read_bytes()[:512]]
    if fake:
        raise IslandsError(f"{len(fake)} clips were made by the fake voice provider; nothing was published")
    PUBLIC_AUDIO.mkdir(parents=True, exist_ok=True)
    copied = 0
    for k in keys:
        if has_clip(k):
            shutil.copyfile(clip_path(k), clip_path(k, PUBLIC_AUDIO))
            copied += 1
    print(f"Published {copied} of {len(keys)} island clips to public/audio/islands/.")
    if copied < len(keys):
        print(f"{len(keys) - copied} clips are not made yet; their play buttons say the clip could not play.")
    return 0


# The command line -----------------------------------------------------------------------------------

COMMANDS = {
    "build": cmd_build,
    "unmet": cmd_unmet,
    "check-islands": cmd_check,
    "count-islands": cmd_count,
    "voice-islands": cmd_voice,
    "publish-islands": cmd_publish,
}


def main(argv: list[str]) -> int:
    from providers.voice import VoiceError

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description="Language islands")
    sub = parser.add_subparsers(dest="command", required=True)
    build = sub.add_parser("build")
    build.add_argument("--out")
    unmet = sub.add_parser("unmet")
    unmet.add_argument("--out")
    check = sub.add_parser("check-islands")
    check.add_argument("--out")
    sub.add_parser("count-islands")
    voice = sub.add_parser("voice-islands")
    voice.add_argument("--limit", type=int, default=MAX_CLIPS_PER_RUN)
    sub.add_parser("publish-islands")
    args = parser.parse_args(argv)
    try:
        return COMMANDS[args.command](args)
    except (IslandsError, VoiceError) as err:
        print(f"Stopped: {err}")
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
