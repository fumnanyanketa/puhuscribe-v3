"""Sum the logged AI and voice cost per dialogue and per unit (job 12-units-1-3, "Done when" 6).

Reads content/logs/ai-calls.jsonl (one line per call, with its cost in US
dollars) and the briefs in content/briefs/ (to know each dialogue's unit), and
prints one line per dialogue, one per unit and the total. Writes nothing.

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


def main() -> int:
    result = costs()
    for slug, usd in result["dialogues"].items():
        print(f"dialogue {slug}: {usd:.2f} USD")
    for unit, usd in result["units"].items():
        print(f"unit {unit}: {usd:.2f} USD")
    print(f"total: {result['total']:.2f} USD")
    return 0


if __name__ == "__main__":
    sys.exit(main())
