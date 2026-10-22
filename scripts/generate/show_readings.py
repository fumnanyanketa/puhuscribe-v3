"""Print Voikko's readings for Finnish words, as JSON (job 7-content-pipeline).

A helper for whoever writes briefs or checks a failing draft: it shows every
reading Voikko gives a word, the form tag the pipeline builds from each one,
and whether v2's VoikkoGate accepts the word. Needs Linux with Voikko.

Run: python scripts/generate/show_readings.py olen Helsingistä Oletko
"""

from __future__ import annotations

import json
import sys

from voikko_gate import VoikkoGate


def readings(gate: VoikkoGate, word: str) -> dict:
    result = gate.check_token(word)
    return {
        "word": word,
        "valid": bool(result and result.valid),
        "is_proper": bool(result and result.is_proper),
        "readings": [dict(sorted(dict(r).items())) for r in gate._analyze_best(word)],
    }


def main(argv: list[str]) -> int:
    gate = VoikkoGate()
    words = [w for arg in argv for w in gate.tokenize(arg)]
    json.dump([readings(gate, w) for w in words], sys.stdout, ensure_ascii=False, indent=1)
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
