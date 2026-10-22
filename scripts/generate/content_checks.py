"""The automatic checks on a dialogue draft (job 7-content-pipeline, "Done when" 7 to 12 and 21).

run_checks() runs every check offline (no AI call, no network) and returns a
report. Each failure is one plain sentence naming the line and the word. The
thresholds come from content/checks/thresholds.json (PRD section 8).

Checks:
- shape: the line count and speakers match the brief.
- word_validity (7): every written word analyses in Voikko through v2's VoikkoGate.
- token_order (21): each word's text appears in order in its line's text, and the
  words cover the whole line.
- spoken_links (8): every spoken word renders exactly one written word or is
  marked spoken only; every written word is rendered exactly once.
- level_fit (9): every written base form apart from names is inside the rank cap
  or on the brief's extra list, and every form is on the unit's grammar list.
- grammar_cards (10): each word's form is one of Voikko's own readings, its name
  comes from the tag table, and its "why" follows the rules.
- register_faithfulness (11): the judge said every line keeps its meaning, and no
  line changed after it was judged.
"""

from __future__ import annotations

import json
from pathlib import Path

from analysis import candidates, is_word, tokens, within_level
from fingerprints import form_id, line_fingerprint
from grammar import UnknownTagValue, form_name, is_name_tag, on_grammar_list, why_problems
from voikko_gate import VoikkoGate

REPO = Path(__file__).resolve().parents[2]
THRESHOLDS_PATH = REPO / "content" / "checks" / "thresholds.json"
CHECK_NAMES = (
    "shape",
    "word_validity",
    "token_order",
    "spoken_links",
    "level_fit",
    "grammar_cards",
    "register_faithfulness",
)


def load_thresholds(path: Path = THRESHOLDS_PATH) -> dict:
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


class _Check:
    def __init__(self) -> None:
        self.passed = 0
        self.total = 0
        self.failures: list[str] = []
        self.hard = 0

    def ok(self) -> None:
        self.passed += 1
        self.total += 1

    def fail(self, message: str) -> None:
        self.total += 1
        self.failures.append(message)

    def note(self, message: str) -> None:
        """A failure that fails the check whatever the rate (for example a stale verdict)."""
        self.hard += 1
        self.failures.append(message)

    def rate(self) -> float:
        return 1.0 if self.total == 0 else self.passed / self.total


def _in_order(surfaces: list[str], text: str) -> str | None:
    """None when every surface appears in text in order; else the first one that does not."""
    at = 0
    for surface in surfaces:
        found = text.find(surface, at)
        if found < 0:
            return surface
        at = found + len(surface)
    return None


def run_checks(draft: dict, gate: VoikkoGate, ranks: dict[str, int], thresholds: dict) -> dict:
    brief = draft["brief"]
    lines = draft["lines"]
    forms = {f["id"]: f for f in draft.get("forms", [])}
    checks = {name: _Check() for name in CHECK_NAMES}
    spoken_only: list[str] = []

    # shape
    shape = checks["shape"]
    if len(lines) != brief["line_count"]:
        shape.fail(f"the dialogue has {len(lines)} lines; the brief asks for {brief['line_count']}")
    else:
        shape.ok()
    speakers = {s["name"] for s in brief["speakers"]}
    for i, line in enumerate(lines, start=1):
        where = f"line {i}"
        if line.get("n") != i:
            shape.fail(f"{where}: its number is {line.get('n')}, expected {i}")
        elif line.get("speaker") not in speakers:
            shape.fail(f"{where}: speaker '{line.get('speaker')}' is not in the brief")
        elif not all(str(line.get(k, "")).strip() for k in ("text_puhe", "text_kirja", "gloss_en")):
            shape.fail(f"{where}: the spoken text, the written text and the English meaning are all needed")
        else:
            shape.ok()

    used_forms: set[str] = set()
    for i, line in enumerate(lines, start=1):
        where = f"line {i}"
        kirja = line.get("kirja_tokens", [])
        puhe = line.get("puhe_tokens", [])

        # token_order (21): in order, and covering the whole line
        order = checks["token_order"]
        for register, toks, text in (
            ("written", kirja, line["text_kirja"]),
            ("spoken", puhe, line["text_puhe"]),
        ):
            surfaces = [t.get("surface", "") for t in toks]
            missing = _in_order(surfaces, text)
            if missing is not None:
                order.fail(f"{where}: the {register} word '{missing}' does not appear in order in the line")
            elif surfaces != tokens(gate, text):
                order.fail(
                    f"{where}: the {register} words do not cover the line exactly ({' '.join(surfaces)})"
                )
            else:
                order.ok()

        # word_validity (7)
        validity = checks["word_validity"]
        for tok in kirja:
            surface = tok.get("surface", "")
            if not is_word(gate, surface):
                continue
            result = gate.check_token(surface)
            if result is not None and result.valid:
                validity.ok()
            else:
                validity.fail(f"{where}: '{surface}' is not a Finnish word Voikko knows")

        # spoken_links (8)
        links = checks["spoken_links"]
        rendered = [0] * len(kirja)
        for tok in puhe:
            surface = tok.get("surface", "")
            if tok.get("spoken_only") is True and "kirja" not in tok:
                spoken_only.append(f"{where}: {surface}")
                links.ok()
                continue
            target = tok.get("kirja")
            if not isinstance(target, int) or isinstance(target, bool) or not 1 <= target <= len(kirja):
                links.fail(
                    f"{where}: the spoken word '{surface}' links to written word {target}, which is missing"
                )
                continue
            rendered[target - 1] += 1
            links.ok()
        for index, count in enumerate(rendered):
            surface = kirja[index].get("surface", "") if index < len(kirja) else ""
            if count == 0:
                links.fail(f"{where}: no spoken word renders the written word '{surface}'")
            elif count > 1:
                links.fail(f"{where}: the written word '{surface}' is rendered by {count} spoken words")

        # grammar_cards (10) and level_fit (9), word by word
        cards = checks["grammar_cards"]
        level = checks["level_fit"]
        for index, tok in enumerate(kirja):
            surface = tok.get("surface", "")
            if not is_word(gate, surface):
                if tok.get("form") is not None:
                    cards.fail(f"{where}: '{surface}' is not a word and cannot have a form")
                continue
            readings = {(c["lemma"], c["form_tag"]) for c in candidates(gate, surface)}
            lemma, tag = tok.get("lemma"), tok.get("form_tag")
            if (lemma, tag) not in readings:
                cards.fail(
                    f"{where}: the form of '{surface}' ({lemma}, {tag}) is not one of Voikko's readings"
                )
                continue
            try:
                name = is_name_tag(tag)
            except UnknownTagValue as err:
                cards.fail(f"{where}: '{surface}': {err}")
                continue
            if bool(tok.get("name")) != name:
                cards.fail(
                    f"{where}: '{surface}' is marked {'a name' if tok.get('name') else 'not a name'}, "
                    "which its chosen reading does not support"
                )
                continue
            if name:
                if tok.get("form") is not None:
                    cards.fail(f"{where}: the name '{surface}' must not have a form")
                else:
                    cards.ok()
                continue
            form = forms.get(tok.get("form") or "")
            if form is None:
                cards.fail(f"{where}: '{surface}' has no form")
                continue
            used_forms.add(form["id"])
            puhe_surface = next(
                (p.get("surface", "") for p in puhe if p.get("kirja") == index + 1), ""
            ).lower()
            expected = {
                "lemma": lemma,
                "form_tag": tag,
                "surface_kirja": surface.lower(),
                "surface_puhe": puhe_surface,
            }
            if {k: form.get(k) for k in expected} != expected or form["id"] != form_id(form):
                cards.fail(f"{where}: the form linked to '{surface}' does not match the word")
                continue
            cards.ok()
            # level fit
            if not within_level(lemma, brief["rank_cap"], brief["extra_base_forms"], ranks):
                level.fail(
                    f"{where}: '{surface}' (base form {lemma}) is outside the frequency rank cap "
                    f"of {brief['rank_cap']} and not on the brief's extra list"
                )
            elif not on_grammar_list(lemma, tag, brief["grammar"]):
                level.fail(
                    f"{where}: '{surface}' is a form ({form.get('form_name_en') or tag}) "
                    "that is not on the unit's grammar list"
                )
            else:
                level.ok()

    # grammar_cards (10): each form's own name and "why"
    cards = checks["grammar_cards"]
    for fid, form in forms.items():
        label = f"form '{form.get('surface_kirja')}' ({form.get('lemma')})"
        if fid not in used_forms:
            cards.fail(f"{label} is not used by any word")
            continue
        try:
            name = form_name(form["form_tag"])
        except UnknownTagValue as err:
            cards.fail(f"{label}: {err}")
            continue
        if form.get("form_name_en") != name:
            cards.fail(f"{label}: its name '{form.get('form_name_en')}' is not the table's name '{name}'")
            continue
        problems = why_problems(form.get("why_en", ""), name)
        if problems:
            for problem in problems:
                cards.fail(f"{label}: {problem}")
            continue
        cards.ok()

    # register_faithfulness (11)
    faithful = checks["register_faithfulness"]
    for i, line in enumerate(lines, start=1):
        verdict = line.get("judge")
        if not verdict:
            faithful.note(f"line {i}: the judge has not checked this line")
        elif verdict.get("fingerprint") != line_fingerprint(line):
            faithful.note(f"line {i}: the line changed after the judge checked it")
        elif verdict.get("faithful") is not True:
            reason = verdict.get("reason") or "no reason given"
            faithful.fail(
                f"line {i}: the judge says the spoken and written versions differ in meaning ({reason})"
            )
        else:
            faithful.ok()

    minimum = {
        "shape": 1.0,
        "word_validity": thresholds["word_validity"],
        "token_order": 1.0,
        "spoken_links": 1.0,
        "level_fit": thresholds["level_fit"],
        "grammar_cards": thresholds["grammar_card_tag_match"],
        "register_faithfulness": thresholds["register_faithfulness_judge"],
    }
    results = {}
    failures: list[str] = []
    for name, check in checks.items():
        passed = check.hard == 0 and check.rate() >= minimum[name]
        results[name] = {
            "passed": passed,
            "rate": round(check.rate(), 4),
            "threshold": minimum[name],
            "checked": check.total,
            "failures": check.failures,
        }
        if not passed:
            failures.extend(check.failures)
    return {
        "ok": all(r["passed"] for r in results.values()),
        "checks": results,
        "failures": failures,
        "spoken_only_words": spoken_only,
    }
