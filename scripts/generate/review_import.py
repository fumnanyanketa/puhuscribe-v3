"""Reading the reviewer's file back (job 7-content-pipeline, "Done when" 14).

The reviewer's files live in content/reviews/<dialogue-slug>/, added only by
the manager on the owner's instruction. read_round() refuses a file, with a
plain reason, when an item is missing, a fingerprint does not match the page
the reviewer saw, a decision is missing, an audio clip is marked "sounds wrong"
without a native recording to replace it, or the reviewer code is empty.

approvals() collects every approval across all rounds. An approval counts only
for the fingerprint the reviewer saw, so any later change makes it stale.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

from review_items import DIALOGUE_ITEM
from review_page import REVIEW_FORMAT, ROUND_FORMAT

REVIEWER_CODE = re.compile(r"^[A-Za-z0-9]{1,12}$")
LINE_FIX_FIELDS = ("text_puhe", "text_kirja", "gloss_en")
FORM_FIX_FIELDS = ("why_en",)


class ReviewRefused(ValueError):
    """The review file cannot be used. .reasons lists every plain reason."""

    def __init__(self, reasons: list[str]):
        super().__init__("; ".join(reasons))
        self.reasons = reasons


def _load_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as err:
        raise ReviewRefused([f"{path.name} cannot be read as JSON ({err})"]) from err


def review_files(reviews_dir: Path) -> list[tuple[int, Path, dict]]:
    """Every review file for one dialogue, in round order. Refuses two files for one round."""
    if not reviews_dir.is_dir():
        return []
    found: dict[int, tuple[Path, dict]] = {}
    for path in sorted(reviews_dir.glob("*.json")):
        data = _load_json(path)
        if not isinstance(data, dict) or data.get("format") != REVIEW_FORMAT:
            raise ReviewRefused([f"{path.name} is not a PuhuScribe review file"])
        number = data.get("round")
        if not isinstance(number, int) or isinstance(number, bool) or number < 1:
            raise ReviewRefused([f"{path.name} has no round number"])
        if number in found:
            raise ReviewRefused([f"{path.name} and {found[number][0].name} are both for round {number}"])
        found[number] = (path, data)
    return [(n, p, d) for n, (p, d) in sorted(found.items())]


def read_round(review: dict, manifest: dict, slug: str, recording_exists) -> dict:
    """Check one returned file against the page it answers. Returns {item id: entry}.

    recording_exists(line, register) says whether a native recording now exists, which
    is what lets a clip marked "sounds wrong" move on to the next round."""
    reasons = []
    if review.get("dialogue_slug") != slug:
        reasons.append(f"the file is for dialogue '{review.get('dialogue_slug')}', not '{slug}'")
    if review.get("round") != manifest.get("round"):
        reasons.append(
            f"the file is for round {review.get('round')}, the page was round {manifest.get('round')}"
        )
    code = review.get("reviewer_code")
    if not isinstance(code, str) or not code.strip():
        reasons.append("the reviewer code is empty")
    elif not REVIEWER_CODE.match(code):
        reasons.append(
            "the reviewer code must be letters and digits only (such as R1), never a name or email"
        )
    entries = {}
    for entry in review.get("items", []) if isinstance(review.get("items"), list) else []:
        if isinstance(entry, dict) and isinstance(entry.get("id"), str):
            entries[entry["id"]] = entry
    expected: dict[str, str] = manifest.get("items", {})
    for item_id, fingerprint in expected.items():
        entry = entries.get(item_id)
        if entry is None:
            reasons.append(f"item {item_id} is missing from the review file")
            continue
        if entry.get("fingerprint") != fingerprint:
            reasons.append(
                f"item {item_id} does not match the page the reviewer saw (its fingerprint differs)"
            )
            continue
        if item_id.startswith("audio-"):
            verdict = entry.get("verdict")
            if verdict == "wrong":
                _, line, register = item_id.split("-")
                if not recording_exists(int(line), register):
                    reasons.append(
                        f"item {item_id} is marked sounds wrong: add a native recording at "
                        f"content/recordings/{slug}/{line}-{register}.mp3, then run the next round"
                    )
            elif verdict != "right":
                reasons.append(f"item {item_id} has no sounds right or sounds wrong")
            continue
        decision = entry.get("decision")
        if item_id == DIALOGUE_ITEM:
            asks_for_changes = any(
                e.get("decision") == "fix" or e.get("verdict") == "wrong"
                for other, e in entries.items()
                if other in expected and other != DIALOGUE_ITEM
            )
            if decision == "not-yet" and not asks_for_changes:
                reasons.append(
                    "the dialogue as a whole is marked not yet, but no item is marked fix or sounds wrong"
                )
            elif decision not in ("approve", "not-yet"):
                reasons.append("the dialogue as a whole has no decision (approve or not yet)")
            continue
        if decision == "approve":
            continue
        if decision != "fix":
            reasons.append(f"item {item_id} has no decision (approve or fix)")
            continue
        fields = LINE_FIX_FIELDS if item_id.startswith("line-") else FORM_FIX_FIELDS
        fix = entry.get("fix")
        if not isinstance(fix, dict) or any(
            not isinstance(fix.get(f), str) or not fix[f].strip() for f in fields
        ):
            reasons.append(f"item {item_id} is marked fix but the corrected text is missing")
    extra = sorted(set(entries) - set(expected))
    if extra:
        reasons.append(f"the review file has items the page did not show: {', '.join(extra)}")
    if reasons:
        raise ReviewRefused(reasons)
    return {item_id: entries[item_id] for item_id in expected}


def approvals(files: list[tuple[int, Path, dict]], repo: Path) -> dict[str, dict]:
    """Item id to {fingerprint, ref, round} for every approval, later rounds winning."""
    found: dict[str, dict] = {}
    for number, path, data in files:
        relative = path.resolve().relative_to(repo.resolve()).as_posix()
        for entry in data.get("items", []):
            if not isinstance(entry, dict):
                continue
            approved = entry.get("decision") == "approve" or entry.get("verdict") == "right"
            if approved:
                found[entry["id"]] = {
                    "fingerprint": entry.get("fingerprint"),
                    "ref": f"{relative}#{entry['id']}",
                    "round": number,
                }
            else:
                found.pop(entry.get("id"), None)
    return found


def open_fixes(files: list[tuple[int, Path, dict]]) -> list[str]:
    """Items the latest file marks fix or sounds wrong (still to be applied)."""
    if not files:
        return []
    _, _, latest = files[-1]
    return [
        e["id"]
        for e in latest.get("items", [])
        if isinstance(e, dict) and (e.get("decision") == "fix" or e.get("verdict") == "wrong")
    ]


def load_manifest(draft_dir: Path, round_number: int) -> dict:
    path = draft_dir / "review" / f"round-{round_number}.json"
    if not path.is_file():
        raise ReviewRefused([f"there is no page for round {round_number} ({path.name} is missing)"])
    data = _load_json(path)
    if not isinstance(data, dict) or data.get("format") != ROUND_FORMAT:
        raise ReviewRefused([f"{path.name} is not a review round manifest"])
    return data
