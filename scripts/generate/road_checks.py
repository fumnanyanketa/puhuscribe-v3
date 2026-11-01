"""The automatic checks on a road draft (job 20-a1-road, statements 10, 12 and 15).

check_draft() runs job 7's checks, unchanged, on the road's written drafts. Three things differ from
an AI draft, and each is a rule of the spec, not a softer check:

- A spoken word glued to sä (Ootsä) is shown as written but analysed as two words (Oot sä), so the
  checks see the analysis text. Verdicts of the judge are bound to that text too.
- The spoken to written mapping is checked again from the texts (content/road/spoken-forms.tsv and the
  ending rules), as a check of its own: spoken_pairs.
- The register judge is off unless the owner turned it on. With it off the report says "not run",
  never "passed".

While the word notes of a form are not written yet, the draft says so ("notes": pending), the
form's missing "why" is reported as waiting, and nothing can be approved or published.
"""

from __future__ import annotations

import copy

from content_checks import run_checks
from fingerprints import line_fingerprint
from grammar import form_name
from road_data import FIXED_WHY, meaning_problems
from road_extras import register_road_extras
from road_mapping import SpokenForms, analysis_text, map_line, tokenize

PENDING_WHY = FIXED_WHY["dictionary-same"]


def is_written(draft: dict) -> bool:
    return draft.get("brief", {}).get("source") == "written"


def judge_state(draft: dict) -> str:
    """ "off" or "on". A written draft names its state; an AI draft always had the judge."""
    return draft.get("providers", {}).get("judge", "off" if is_written(draft) else "on")


def view_line_text(line: dict) -> str:
    return analysis_text(line["text_puhe"], tokenize(line["text_kirja"]))


def judged_line(line: dict) -> dict:
    """The line as the checks and the judge see it: glued words split."""
    return {**line, "text_puhe": view_line_text(line)}


def line_judge_fingerprint(line: dict) -> str:
    return line_fingerprint(judged_line(line))


def analysis_view(draft: dict) -> dict:
    """A copy of the draft for the checks. Pending word notes get a placeholder why, so the rules
    that need a why can run on everything else."""
    view = copy.deepcopy(draft)
    for line in view["lines"]:
        line["text_puhe"] = view_line_text(line)
    if view.get("notes", {}).get("status") == "pending":
        for form in view["forms"]:
            if not form.get("why_en"):
                form["why_en"] = PENDING_WHY
    return view


def pending_forms(draft: dict) -> list[str]:
    """Ids of forms that still lack a meaning, a dictionary form meaning or a why."""
    return [
        f["id"]
        for f in draft["forms"]
        if not (f.get("meaning_en") and f.get("lemma_meaning_en") and f.get("why_en"))
    ]


def check_draft(
    draft: dict, gate, ranks: dict[str, int], thresholds: dict, forms: SpokenForms | None = None
) -> dict:
    """The report of job 7's checks for any draft, with the road's differences for a written one."""
    if not is_written(draft):
        return run_checks(draft, gate, ranks, thresholds)
    register_road_extras()
    forms = forms or SpokenForms.load()
    report = run_checks(analysis_view(draft), gate, ranks, thresholds)
    checks = report["checks"]

    # The mapping, again from the texts.
    pairs = {"passed": True, "rate": 1.0, "threshold": 1.0, "checked": 0, "failures": []}
    for line in draft["lines"]:
        spoken, mapping = map_line(line["text_puhe"], line["text_kirja"], forms)
        for problem in mapping.failures:
            pairs["failures"].append(f"line {line['n']}: {problem}")
        stored = [
            (t["surface"], None if t.get("spoken_only") else t.get("kirja")) for t in line["puhe_tokens"]
        ]
        wanted = list(zip(spoken, mapping.links, strict=True))
        if not mapping.failures and stored != wanted:
            pairs["failures"].append(f"line {line['n']}: the stored word links differ from its texts")
        pairs["checked"] += len(spoken)
    if pairs["failures"]:
        pairs["passed"] = False
        pairs["rate"] = round(1 - len(pairs["failures"]) / max(pairs["checked"], 1), 4)
        report["failures"].extend(pairs["failures"])
    checks["spoken_pairs"] = pairs

    # Word note rules that run_checks does not know: both meanings, once the notes are complete.
    if draft.get("notes", {}).get("status") != "pending":
        for form in draft["forms"]:
            label = f"form '{form['surface_kirja']}' ({form['lemma']})"
            for key in ("meaning_en", "lemma_meaning_en"):
                for problem in meaning_problems(form.get(key, "")):
                    report["failures"].append(f"{label}: {key}: {problem}")
                    checks["grammar_cards"]["passed"] = False
            if form.get("form_name_en") != form_name(form["form_tag"]):
                report["failures"].append(f"{label}: its name is not the table's name")

    # The register judge.
    state = judge_state(draft)
    register = checks["register_faithfulness"]
    if state == "off":
        report["failures"] = [f for f in report["failures"] if f not in register["failures"]]
        checks["register_faithfulness"] = {
            "passed": None,
            "status": "not run",
            "rate": None,
            "threshold": register["threshold"],
            "checked": 0,
            "failures": [],
        }
    report["register_judge"] = "not run" if state == "off" else ("passed" if register["passed"] else "FAILED")
    report["notes_pending"] = pending_forms(draft)
    report["ok"] = all(c["passed"] is not False for c in checks.values())
    return report
