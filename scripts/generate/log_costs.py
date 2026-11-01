"""Sum the logged AI and voice cost per dialogue and per unit (job 12-units-1-3, "Done when" 6).

Reads content/logs/ai-calls.jsonl (one line per call, with its cost in US
dollars) and the briefs in content/briefs/ (to know each dialogue's unit), and
prints one line per dialogue, one per unit and the total. Writes nothing.

Job 20-a1-road adds the A1 road by part: for every logged call of a road dialogue it sums the voice
characters and the cost per part of the road (a part is six stops). Dialogues are found from the drafts.

Run: python scripts/generate/log_costs.py
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
LOG = REPO / "content" / "logs" / "ai-calls.jsonl"
BRIEFS = REPO / "content" / "briefs"
DRAFTS = REPO / "content" / "drafts"


def costs(log: Path = LOG, briefs: Path = BRIEFS) -> dict:
    """{"dialogues": {slug: usd}, "units": {position: usd}, "total": usd}, rounded to the cent."""
    unit_of = {}
    for path in briefs.glob("*.json"):
        brief = json.loads(path.read_text(encoding="utf-8"))
        unit_of[brief["dialogue"]["slug"]] = brief["unit"]["position"]
    dialogues: dict[str, float] = defaultdict(float)
    units: dict[int, float] = defaultdict(float)
    total = 0.0
    for line in log.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        call = json.loads(line)
        cost = float(call["cost_usd"])
        dialogues[call["dialogue"]] += cost
        if call["dialogue"] in unit_of:
            units[unit_of[call["dialogue"]]] += cost
        total += cost
    return {
        "dialogues": {k: round(v, 2) for k, v in sorted(dialogues.items())},
        "units": {k: round(v, 2) for k, v in sorted(units.items())},
        "total": round(total, 2),
    }


def road_costs(log: Path = LOG, drafts: Path = DRAFTS) -> dict[int, dict]:
    """{part: {"characters": n, "calls": n, "usd": cost}} for the logged calls of the A1 road's dialogues."""
    part_of = {}
    for path in drafts.glob("*/draft.json"):
        brief = json.loads(path.read_text(encoding="utf-8"))["brief"]
        stop = brief["unit"]["position"]
        if 1 <= stop <= 36:
            part_of[brief["dialogue"]["slug"]] = (stop - 1) // 6 + 1
    parts: dict[int, dict] = defaultdict(lambda: {"characters": 0, "calls": 0, "usd": 0.0})
    for line in log.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        call = json.loads(line)
        part = part_of.get(call["dialogue"])
        if part is None:
            continue
        parts[part]["characters"] += int(call.get("characters", 0))
        parts[part]["calls"] += 1
        parts[part]["usd"] += float(call["cost_usd"])
    return {p: {**v, "usd": round(v["usd"], 2)} for p, v in sorted(parts.items())}


def main() -> int:
    result = costs()
    for slug, usd in result["dialogues"].items():
        print(f"dialogue {slug}: {usd:.2f} USD")
    for unit, usd in result["units"].items():
        print(f"unit {unit}: {usd:.2f} USD")
    print(f"total: {result['total']:.2f} USD")
    for part, row in road_costs().items():
        print(f"road part {part}: {row['characters']} characters, {row['calls']} calls, {row['usd']:.2f} USD")
    return 0


if __name__ == "__main__":
    sys.exit(main())
