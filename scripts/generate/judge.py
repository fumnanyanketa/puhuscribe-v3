"""Proving the register judge on its golden set (job 7-content-pipeline, "Done when" 11).

content/checks/judge-golden-set.json holds 20 pairs of spoken and written
Finnish: 10 that mean the same and 10 with a planted change of meaning (a
number, a negation, a swapped pronoun, a place, a time or a thing). The judge
is the same prompt the pipeline uses (drafting.JUDGE_SYSTEM). It passes when it
catches every changed pair and accepts at least 9 of the 10 faithful ones
(content/checks/thresholds.json).
"""

from __future__ import annotations

from pathlib import Path

from drafting import JUDGE_SCHEMA, JUDGE_SYSTEM
from providers.ai import MODELS

REPO = Path(__file__).resolve().parents[2]
GOLDEN_PATH = REPO / "content" / "checks" / "judge-golden-set.json"


def evaluate_golden(ai, golden: dict, thresholds: dict) -> dict:
    pairs = golden["pairs"]
    prompt = "\n".join(
        f'Line {i}: spoken "{p["puhe"]}" | written "{p["kirja"]}"' for i, p in enumerate(pairs, 1)
    )
    answer = ai.complete_json(
        purpose="judge", dialogue="judge-golden-set", system=JUDGE_SYSTEM, prompt=prompt, schema=JUDGE_SCHEMA
    )
    verdicts = {v.get("n"): v for v in answer.get("verdicts", [])}
    rows = []
    for i, pair in enumerate(pairs, start=1):
        verdict = verdicts.get(i, {})
        said_same = verdict.get("same_meaning")
        rows.append(
            {
                "n": i,
                "puhe": pair["puhe"],
                "kirja": pair["kirja"],
                "label": pair["label"],
                "planted_change": pair.get("change"),
                "judge_same_meaning": said_same,
                "judge_reason": verdict.get("reason"),
                "correct": (said_same is True) == (pair["label"] == "faithful") and said_same is not None,
            }
        )
    changed = [r for r in rows if r["label"] == "changed"]
    faithful = [r for r in rows if r["label"] == "faithful"]
    caught = sum(1 for r in changed if r["judge_same_meaning"] is False)
    accepted = sum(1 for r in faithful if r["judge_same_meaning"] is True)
    need = thresholds["judge_golden_set"]
    return {
        "model": MODELS["judge"],
        "provider": ai.name,
        "changed_total": len(changed),
        "changed_caught": caught,
        "faithful_total": len(faithful),
        "faithful_accepted": accepted,
        "passed": caught >= need["changed_caught_min"] and accepted >= need["faithful_accepted_min"],
        "rows": rows,
    }
