"""Publishing the A1 road under the owner's approval (job 20-a1-road, statements 20 and 21).

The owner approves the road part by part, in writing. The manager adds one file for each part,
content/approvals/part-<n>.json (format puhuscribe-owner-approval-1), on the owner's written line. It
holds that line word for word with its date, the part, the judge's state and, for every dialogue of the
part, a fingerprint: a SHA-256 of every line's three texts and every form's texts.

publish_road() writes one migration for a dialogue and copies its clips to public/audio/. It refuses,
naming every reason, and writes nothing, when

- the approval file is missing or not the owner's format,
- the dialogue is not listed in it, or its fingerprint differs from the current draft (a changed line
  voids its dialogue's approval),
- a check fails, or word notes are missing,
- the judge's state differs from the one the owner approved,
- a clip is missing or comes from the fake voice,
- any dialogue of the part fails its checks.

Each approval_ref is the approval file's path plus "#<dialogue-slug>/<item id>", so every reference is
new. There is no override. A migration does nothing when its dialogue is already published.
"""

from __future__ import annotations

import json
import re
import shutil
from datetime import UTC, datetime, timedelta
from pathlib import Path

from fingerprints import fingerprint, sha256_bytes
from publish import PublishRefused, audio_key, build_sql, unsafe_texts
from review_items import DIALOGUE_ITEM, all_items, audio_item_id, clip_path
from road_checks import check_draft, judge_state, pending_forms

REPO = Path(__file__).resolve().parents[2]
APPROVAL_FORMAT = "puhuscribe-owner-approval-1"
STOPS_PER_PART = 6
DIALOGUES_PER_STOP = 3
# Publish migrations are made with explicit timestamps, one minute apart, in stop and dialogue order,
# later than every migration on main when the job was built (the latest was 20261101120100).
FIRST_PUBLISH_TIMESTAMP = datetime(2026, 11, 2, 0, 0, 0, tzinfo=UTC)
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def part_of(draft: dict) -> int:
    return (draft["brief"]["unit"]["position"] - 1) // STOPS_PER_PART + 1


def road_fingerprint(draft: dict) -> str:
    """A SHA-256 of every line's three texts and every form's texts, in order."""
    return fingerprint(
        {
            "lines": [[ln["text_puhe"], ln["text_kirja"], ln["gloss_en"]] for ln in draft["lines"]],
            "forms": [
                [
                    f["lemma"],
                    f["form_tag"],
                    f["surface_kirja"],
                    f["surface_puhe"],
                    f["form_name_en"],
                    f["why_en"],
                    f.get("meaning_en", ""),
                    f.get("lemma_meaning_en", ""),
                ]
                for f in draft["forms"]
            ],
        }
    )


def approval_path(part: int, repo: Path = REPO) -> Path:
    return repo / "content" / "approvals" / f"part-{part}.json"


def read_approval(part: int, repo: Path = REPO) -> tuple[dict | None, list[str]]:
    """The owner's approval file for a part and every reason it cannot be used."""
    path = approval_path(part, repo)
    name = f"content/approvals/part-{part}.json"
    if not path.is_file():
        return None, [f"there is no owner approval file {name}"]
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None, [f"{name} is not valid JSON"]
    reasons = []
    if not isinstance(data, dict) or data.get("format") != APPROVAL_FORMAT:
        return None, [f"{name} is not an owner approval file ({APPROVAL_FORMAT})"]
    if data.get("part") != part:
        reasons.append(f"{name} is for part {data.get('part')}, not part {part}")
    if not str(data.get("approved_line", "")).strip():
        reasons.append(f"{name} does not hold the owner's own approval line")
    if not _DATE.match(str(data.get("approved_on", ""))):
        reasons.append(f"{name} has no approval date (YYYY-MM-DD)")
    if data.get("judge") not in ("off", "on"):
        reasons.append(f"{name} does not say whether the register judge was off or on")
    dialogues = data.get("dialogues")
    if not isinstance(dialogues, dict) or not all(
        isinstance(v, str) and _SHA256.match(v) for v in (dialogues or {}).values()
    ):
        reasons.append(f"{name} must list each dialogue with its SHA-256 fingerprint")
    return (None if reasons else data), reasons


def make_approval(part: int, drafts: dict[str, dict], approved_line: str, approved_on: str) -> dict:
    """The approval file's content for a part. Used by the manager, and by tests."""
    in_part = {slug: d for slug, d in drafts.items() if part_of(d) == part}
    judges = {judge_state(d) for d in in_part.values()}
    return {
        "format": APPROVAL_FORMAT,
        "part": part,
        "approved_line": approved_line,
        "approved_on": approved_on,
        "judge": judges.pop() if len(judges) == 1 else "off",
        "dialogues": {slug: road_fingerprint(d) for slug, d in sorted(in_part.items())},
    }


def publish_timestamp(stop: int, position: int) -> str:
    index = (stop - 1) * DIALOGUES_PER_STOP + (position - 1)
    return (FIRST_PUBLISH_TIMESTAMP + timedelta(minutes=index)).strftime("%Y%m%d%H%M%S")


def migration_name(draft: dict) -> str:
    brief = draft["brief"]
    stamp = publish_timestamp(brief["unit"]["position"], brief["dialogue"]["position"])
    return f"{stamp}_publish_{brief['dialogue']['slug'].replace('-', '_')}.sql"


def road_refs(draft: dict, part: int, last: bool) -> dict[str, str]:
    slug = draft["brief"]["dialogue"]["slug"]
    base = f"content/approvals/part-{part}.json#{slug}/"
    refs = {item_id: base + item_id for item_id in all_items(draft)}
    if last:
        refs["unit"] = refs[DIALOGUE_ITEM]
    return refs


def road_preconditions(
    draft: dict,
    draft_dir: Path,
    repo: Path,
    gate,
    ranks,
    thresholds,
    part_drafts: dict[str, dict],
    last: bool,
    allow_fake: bool = False,
) -> tuple[dict[str, str], dict[tuple[int, str], str], list[str]]:
    """The approval references, the audio keys and every reason this dialogue cannot be published."""
    slug = draft["brief"]["dialogue"]["slug"]
    part = part_of(draft)
    approval, reasons = read_approval(part, repo)
    if approval is not None:
        listed = approval["dialogues"]
        if slug not in listed:
            reasons.append(f"dialogue {slug} is not listed in the owner's approval of part {part}")
        elif listed[slug] != road_fingerprint(draft):
            reasons.append(f"dialogue {slug} changed after the owner approved it: its fingerprint differs")
        if approval["judge"] != judge_state(draft):
            reasons.append(
                f"the owner approved part {part} with the register judge {approval['judge']}, "
                f"but this draft says {judge_state(draft)}"
            )
    reasons += unsafe_texts(draft)
    report = check_draft(draft, gate, ranks, thresholds)
    reasons += [f"check failed: {f}" for f in report["failures"]]
    if pending_forms(draft):
        reasons.append(f"{len(pending_forms(draft))} word cards still miss a meaning or a why line")
    for other_slug, other in part_drafts.items():
        if other_slug == slug:
            continue
        if not check_draft(other, gate, ranks, thresholds)["ok"]:
            reasons.append(f"part {part} has a failing dialogue: {other_slug}")
    keys: dict[tuple[int, str], str] = {}
    refs = road_refs(draft, part, last)
    for line in draft["lines"]:
        for register in ("puhe", "kirja"):
            audio = line.get("audio", {}).get(register)
            if audio is None:
                reasons.append(f"line {line['n']} has no {register} audio")
                continue
            if not allow_fake and audio.get("provider") == "fake":
                reasons.append(f"line {line['n']} {register} audio comes from the fake voice provider")
            if audio.get("file") != clip_path(line["n"], register):
                reasons.append(f"line {line['n']} {register} audio must be {clip_path(line['n'], register)}")
                continue
            path = draft_dir / audio["file"]
            if not path.is_file():
                reasons.append(f"the audio file {audio['file']} is missing")
                continue
            digest = sha256_bytes(path.read_bytes())
            if digest != audio["sha256"]:
                reasons.append(f"the audio file {audio['file']} changed after it was made")
                continue
            if audio_item_id(line["n"], register) in refs:
                keys[(line["n"], register)] = audio_key(slug, line["n"], register, digest)
    return refs, keys, reasons


def publish_road(
    draft: dict,
    draft_dir: Path,
    gate,
    ranks,
    thresholds,
    part_drafts: dict[str, dict],
    last: bool,
    repo: Path = REPO,
    allow_fake: bool = False,
) -> tuple[Path, list[Path]]:
    """Write the dialogue's migration and copy its clips, or raise PublishRefused and write nothing."""
    refs, keys, reasons = road_preconditions(
        draft, draft_dir, repo, gate, ranks, thresholds, part_drafts, last, allow_fake
    )
    if reasons:
        raise PublishRefused(reasons)
    slug = draft["brief"]["dialogue"]["slug"]
    migrations = repo / "supabase" / "migrations"
    existing = sorted(migrations.glob(f"*_publish_{slug.replace('-', '_')}.sql"))
    if existing:
        raise PublishRefused([f"{existing[0].name} already publishes this dialogue"])
    source = (
        draft_dir.resolve().relative_to(repo.resolve()).as_posix()
        if draft_dir.resolve().is_relative_to(repo.resolve())
        else draft_dir.name
    )
    sql = build_sql(
        draft, refs, keys, source, road={"stop": draft["brief"]["unit"]["position"], "last": last}
    )
    migration = migrations / migration_name(draft)
    migration.parent.mkdir(parents=True, exist_ok=True)
    migration.write_text(sql, encoding="utf-8", newline="\n")
    written = []
    for line in draft["lines"]:
        for register in ("puhe", "kirja"):
            target = repo / "public" / "audio" / keys[(line["n"], register)]
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(draft_dir / line["audio"][register]["file"], target)
            written.append(target)
    return migration, written


def is_last_dialogue(draft: dict, part_drafts: dict[str, dict]) -> bool:
    """True when no dialogue of the same stop comes after this one."""
    stop = draft["brief"]["unit"]["position"]
    position = draft["brief"]["dialogue"]["position"]
    return all(
        d["brief"]["dialogue"]["position"] <= position
        for d in part_drafts.values()
        if d["brief"]["unit"]["position"] == stop
    )


def publish_part(
    part: int, gate, ranks, thresholds, repo: Path = REPO, allow_fake: bool = False
) -> list[tuple[str, Path]]:
    """Publish every dialogue of a part, in stop and dialogue order. Writes nothing when any is refused."""
    drafts: dict[str, dict] = {}
    for path in sorted((repo / "content" / "drafts").glob("*/draft.json")):
        draft = json.loads(path.read_text(encoding="utf-8"))
        if part_of(draft) == part and 1 <= draft["brief"]["unit"]["position"] <= 36:
            drafts[path.parent.name] = draft
    order = sorted(
        drafts,
        key=lambda s: (drafts[s]["brief"]["unit"]["position"], drafts[s]["brief"]["dialogue"]["position"]),
    )
    problems: list[str] = []
    for slug in order:
        _, _, reasons = road_preconditions(
            drafts[slug],
            repo / "content" / "drafts" / slug,
            repo,
            gate,
            ranks,
            thresholds,
            drafts,
            is_last_dialogue(drafts[slug], drafts),
            allow_fake,
        )
        problems += [f"{slug}: {r}" for r in reasons]
    if problems:
        raise PublishRefused(problems)
    made = []
    for slug in order:
        migration, _ = publish_road(
            drafts[slug],
            repo / "content" / "drafts" / slug,
            gate,
            ranks,
            thresholds,
            drafts,
            is_last_dialogue(drafts[slug], drafts),
            repo,
            allow_fake,
        )
        made.append((slug, migration))
    return made
