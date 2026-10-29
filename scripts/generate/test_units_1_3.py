"""Units 1 to 3: the six briefs and their grammar (job 12-units-1-3, label [units N]).

Spec: factory/jobs/12-units-1-3/spec.md. Runs without Voikko: it reads the briefs
and the committed drafts, whose word readings Voikko made in the pipeline run.

ITEM_FORMS below is the one table that maps each PRD section 6 grammar item to
the form tags that show it, written from the documented tag format
(docs/content-pipeline.md, "The form tag"): KEY=value pairs joined by ";".
An item lists one or more parts; each part is a list of alternatives, and every
part must appear in at least one written (kirja) word of the unit's drafts.
An alternative is (base forms or None for any, required tag values, and
optionally the base form and tag values the next written word must have).
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

import pytest

from brief import load_brief

REPO = Path(__file__).resolve().parents[2]
BRIEFS = REPO / "content" / "briefs"
DRAFTS = REPO / "content" / "drafts"

# PRD section 6, "Grammar that surfaces", as ids of GRAMMAR_CATALOGUE.
UNIT_GRAMMAR = {
    1: ["olla-present", "personal-pronouns", "inessive-elative", "question-clitic"],
    2: ["partitive-singular", "numbers-1-20", "saisinko"],
    3: ["missa-on", "adessive-allative", "tuolla-tassa"],
}

# The six dialogues of statement 1: (unit position, dialogue position) to slug.
DIALOGUES = {
    (1, 1): "meeting-people-new-colleague",
    (1, 2): "meeting-people-language-cafe",
    (2, 1): "ordering-coffee-at-the-counter",
    (2, 2): "ordering-coffee-paying",
    (3, 1): "grocery-store-asking-staff",
    (3, 2): "grocery-store-directions",
}

# Job 7's merged unit 1 brief, byte for byte (SHA-256 of the file on main when job 12 started).
JOB_7_BRIEF_SHA256 = "8294174c1ffa8e38f3b0cb0533ad37a86836d9ea07ed147c504846fbd23aa801"

PRONOUNS = {"minä", "sinä", "hän", "me", "te", "he"}
NUMBERS = {
    "yksi",
    "kaksi",
    "kolme",
    "neljä",
    "viisi",
    "kuusi",
    "seitsemän",
    "kahdeksan",
    "yhdeksän",
    "kymmenen",
    "yksitoista",
    "kaksitoista",
    "kolmetoista",
    "neljätoista",
    "viisitoista",
    "kuusitoista",
    "seitsemäntoista",
    "kahdeksantoista",
    "yhdeksäntoista",
    "kaksikymmentä",
}

ITEM_FORMS: dict[str, list[list[tuple]]] = {
    "olla-present": [[({"olla"}, {"CLASS": "teonsana", "MOOD": "indicative", "TENSE": "present_simple"})]],
    "personal-pronouns": [[(PRONOUNS, {"CLASS": "asemosana", "SIJAMUOTO": "nimento"})]],
    "inessive-elative": [
        [(None, {"SIJAMUOTO": "sisaolento"})],
        [(None, {"SIJAMUOTO": "sisaeronto"})],
    ],
    "question-clitic": [[(None, {"KYSYMYSLIITE": "true"})]],
    "partitive-singular": [[(None, {"SIJAMUOTO": "osanto", "NUMBER": "singular"})]],
    "numbers-1-20": [[(NUMBERS, {"CLASS": "lukusana"})]],
    "saisinko": [
        [
            (
                {"saada"},
                {"MOOD": "conditional", "PERSON": "1", "NUMBER": "singular", "KYSYMYSLIITE": "true"},
            )
        ]
    ],
    "missa-on": [
        [
            (
                {"mikä"},
                {"SIJAMUOTO": "sisaolento"},
                ({"olla"}, {"MOOD": "indicative", "TENSE": "present_simple", "PERSON": "3"}),
            )
        ]
    ],
    "adessive-allative": [
        [(None, {"SIJAMUOTO": "ulkoolento"})],
        [(None, {"SIJAMUOTO": "ulkotulento"})],
    ],
    "tuolla-tassa": [
        [({"tuo"}, {"SIJAMUOTO": "ulkoolento"}), ({"tuolla"}, {})],
        [({"tämä"}, {"SIJAMUOTO": "sisaolento"}), ({"tässä"}, {})],
    ],
}


def cumulative(unit: int) -> list[str]:
    return [item for u in sorted(UNIT_GRAMMAR) if u <= unit for item in UNIT_GRAMMAR[u]]


def tag_values(tag: str) -> dict[str, str]:
    return dict(part.split("=", 1) for part in tag.split(";") if "=" in part)


def matches(token: dict, lemmas: set[str] | None, values: dict[str, str]) -> bool:
    # Names count: "Helsingissä" shows the ending -ssa as well as any word does.
    if "form_tag" not in token:
        return False
    if lemmas is not None and token.get("lemma", "").lower() not in lemmas:
        return False
    attrs = tag_values(token["form_tag"])
    return all(attrs.get(key) == value for key, value in values.items())


def part_shown(drafts: list[dict], alternatives: list[tuple]) -> bool:
    for draft in drafts:
        for line in draft["lines"]:
            words = [t for t in line["kirja_tokens"] if "form_tag" in t]
            for i, token in enumerate(words):
                for alternative in alternatives:
                    lemmas, values = alternative[0], alternative[1]
                    if not matches(token, lemmas, values):
                        continue
                    if len(alternative) == 2:
                        return True
                    nxt_lemmas, nxt_values = alternative[2]
                    if i + 1 < len(words) and matches(words[i + 1], nxt_lemmas, nxt_values):
                        return True
    return False


def briefs() -> dict[str, dict]:
    return {p.stem: load_brief(p) for p in sorted(BRIEFS.glob("*.json"))}


def unit_drafts(unit: int) -> list[dict]:
    found = []
    for path in sorted(DRAFTS.glob("*/draft.json")):
        draft = json.loads(path.read_text(encoding="utf-8"))
        if draft["brief"]["unit"]["position"] == unit:
            found.append(draft)
    return found


def test_there_is_one_brief_for_each_of_the_six_dialogues():
    """[units 1] content/briefs/ holds the six briefs, one per dialogue, every field filled."""
    found = briefs()
    assert set(found) == set(DIALOGUES.values())
    for (unit, position), slug in DIALOGUES.items():
        brief = found[slug]
        assert brief["unit"]["position"] == unit
        assert brief["dialogue"]["position"] == position
        assert brief["dialogue"]["slug"] == slug
        assert 6 <= brief["line_count"] <= 8
        assert len(brief["speakers"]) == 2
        voices = [s["voice"] for s in brief["speakers"]]
        assert len(set(voices)) == 2, f"{slug}: the two speakers need different voices"
        for speaker in brief["speakers"]:
            assert speaker["role_en"].strip()


def test_job_7_unit_1_brief_is_unchanged():
    """[units 1] the first unit 1 dialogue is job 7's merged brief, unchanged."""
    data = (BRIEFS / "meeting-people-new-colleague.json").read_bytes()
    assert hashlib.sha256(data).hexdigest() == JOB_7_BRIEF_SHA256


def test_a_units_briefs_share_one_unit_title_and_can_do_line():
    """[units 1] both dialogues of a unit carry the same unit slug, title and "can do" line."""
    by_unit: dict[int, list[dict]] = {}
    for brief in briefs().values():
        by_unit.setdefault(brief["unit"]["position"], []).append(brief["unit"])
    assert sorted(by_unit) == [1, 2, 3]
    for units in by_unit.values():
        assert len(units) == 2
        assert units[0] == units[1]
        assert units[0]["can_do_en"].startswith("Can ")


def test_each_briefs_grammar_list_holds_its_unit_and_every_earlier_unit():
    """[units 2] grammar lists are cumulative: the unit's PRD grammar plus every earlier unit's list."""
    for slug, brief in briefs().items():
        unit = brief["unit"]["position"]
        for item in cumulative(unit):
            assert item in brief["grammar"], f"{slug}: grammar list is missing {item}"
        later = {i for u, items in UNIT_GRAMMAR.items() if u > unit for i in items}
        assert not later & set(brief["grammar"]), f"{slug}: grammar list has a later unit's item"


def test_the_item_table_covers_every_prd_item():
    """[units 2] every PRD section 6 item for units 1 to 3 has a row in the item to form tag table."""
    assert set(ITEM_FORMS) == {item for items in UNIT_GRAMMAR.values() for item in items}


@pytest.mark.parametrize("unit", [1, 2, 3])
def test_each_units_grammar_shows_up_in_its_two_drafts(unit):
    """[units 2] across a unit's two committed drafts every grammar item of the unit is in a kirja word."""
    drafts = unit_drafts(unit)
    assert len(drafts) == 2, f"unit {unit} has {len(drafts)} committed drafts; it needs two"
    missing = []
    for item in UNIT_GRAMMAR[unit]:
        for number, alternatives in enumerate(ITEM_FORMS[item], start=1):
            if not part_shown(drafts, alternatives):
                missing.append(f"{item} (part {number})")
    assert not missing, f"unit {unit}: these grammar items are in no written word: {', '.join(missing)}"


def test_the_item_table_finds_forms_and_misses_others():
    """[units 2] the table matches the forms it names and nothing else (no false pass)."""
    verb = "CLASS=teonsana;NUMBER=singular;PERSON={};MOOD=indicative;TENSE=present_simple;NEGATIVE=false"
    olen = {"lemma": "olla", "form_tag": verb.format(1)}
    on = {"lemma": "olla", "form_tag": verb.format(3)}
    missa = {"lemma": "mikä", "form_tag": "CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular"}
    kahvia = {"lemma": "kahvi", "form_tag": "CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular"}
    helsinki = {"lemma": "Helsinki", "form_tag": "CLASS=paikannimi;SIJAMUOTO=sisaolento", "name": True}

    def one(*tokens):
        return [{"lines": [{"kirja_tokens": list(tokens)}]}]

    assert part_shown(one(olen), ITEM_FORMS["olla-present"][0])
    assert part_shown(one(kahvia), ITEM_FORMS["partitive-singular"][0])
    assert not part_shown(one(olen), ITEM_FORMS["partitive-singular"][0])
    assert part_shown(one(missa, on), ITEM_FORMS["missa-on"][0])
    assert not part_shown(one(missa, olen), ITEM_FORMS["missa-on"][0])
    assert not part_shown(one(on, missa), ITEM_FORMS["missa-on"][0])
    # A place name with a case ending shows that ending; a word without the tag shows nothing.
    assert part_shown(one(helsinki), ITEM_FORMS["inessive-elative"][0])
    assert not part_shown(one(helsinki), ITEM_FORMS["inessive-elative"][1])
    assert not part_shown(one({"surface": "Moi"}), ITEM_FORMS["question-clitic"][0])


def _tag(**values: str) -> str:
    from grammar import form_tag

    return form_tag(values)


@pytest.mark.parametrize(
    ("lemma", "tag", "unit", "allowed"),
    [
        ("kahvi", _tag(CLASS="nimisana", SIJAMUOTO="osanto", NUMBER="singular"), 1, False),
        ("kahvi", _tag(CLASS="nimisana", SIJAMUOTO="osanto", NUMBER="singular"), 2, True),
        ("kahvi", _tag(CLASS="nimisana", SIJAMUOTO="osanto", NUMBER="plural"), 2, False),
        ("neljä", _tag(CLASS="lukusana", SIJAMUOTO="osanto", NUMBER="singular"), 2, True),
        ("sata", _tag(CLASS="lukusana", SIJAMUOTO="ulkoolento", NUMBER="singular"), 2, False),
        (
            "saada",
            _tag(
                CLASS="teonsana",
                NUMBER="singular",
                PERSON="1",
                MOOD="conditional",
                TENSE="present_simple",
                NEGATIVE="false",
                KYSYMYSLIITE="true",
            ),
            2,
            True,
        ),
        (
            "ottaa",
            _tag(
                CLASS="teonsana",
                NUMBER="singular",
                PERSON="1",
                MOOD="conditional",
                TENSE="present_simple",
                NEGATIVE="false",
            ),
            2,
            False,
        ),
        ("hylly", _tag(CLASS="nimisana", SIJAMUOTO="ulkoolento", NUMBER="singular"), 2, False),
        ("hylly", _tag(CLASS="nimisana", SIJAMUOTO="ulkoolento", NUMBER="singular"), 3, True),
        ("kassa", _tag(CLASS="nimisana", SIJAMUOTO="ulkotulento", NUMBER="singular"), 3, True),
        ("te", _tag(CLASS="asemosana", SIJAMUOTO="ulkoolento", NUMBER="plural"), 3, True),
        ("tuo", _tag(CLASS="asemosana", SIJAMUOTO="ulkoolento", NUMBER="singular"), 3, True),
        ("kauppa", _tag(CLASS="nimisana", SIJAMUOTO="sisatulento", NUMBER="singular"), 3, False),
    ],
)
def test_the_new_grammar_ids_license_their_forms_only(lemma, tag, unit, allowed):
    """[units 2] each unit's grammar ids allow that unit's forms, and nothing a later unit brings."""
    from grammar import on_grammar_list

    assert on_grammar_list(lemma, tag, cumulative(unit)) is allowed


# Statements 3 to 6: the six drafts as the real workflow made them ---------------

THRESHOLDS_SHA256_ON_MAIN = "4a08bb2d066e96917d3958336806251042af281f2d40cbbe35a834a067092ba8"
PACK_FILES = ("draft.json", "check-report.json", "run.log", "review/round-1.html", "review/round-1.json")


def committed(slug: str) -> dict:
    return json.loads((DRAFTS / slug / "draft.json").read_text(encoding="utf-8"))


@pytest.mark.parametrize("slug", sorted(DIALOGUES.values()))
def test_each_dialogue_is_a_committed_review_pack_from_the_real_providers(slug):
    """[units 3] the draft, check report, review page, audio and run log, made with Anthropic and Azure."""
    folder = DRAFTS / slug
    for name in PACK_FILES:
        assert (folder / name).is_file(), f"{slug}: {name} is missing"
    draft = committed(slug)
    assert draft["providers"] == {"ai": "anthropic", "voice": "azure"}
    assert draft["brief_path"] == f"content/briefs/{slug}.json"
    assert draft["brief"] == load_brief(BRIEFS / f"{slug}.json")
    assert "Review page: review/round-1.html" in (folder / "run.log").read_text(encoding="utf-8")
    assert not (REPO / "public" / "audio" / slug).exists()


@pytest.mark.parametrize("slug", sorted(DIALOGUES.values()))
def test_each_draft_passed_every_automatic_check(slug):
    """[units 4] the pipeline's check report says every check passed (the Python check reruns them)."""
    report = json.loads((DRAFTS / slug / "check-report.json").read_text(encoding="utf-8"))
    assert report["ok"] is True
    assert all(check["passed"] for check in report["checks"].values())


def test_thresholds_are_byte_for_byte_those_on_main():
    """[units 4] content/checks/thresholds.json is unchanged."""
    data = (REPO / "content" / "checks" / "thresholds.json").read_bytes()
    assert hashlib.sha256(data).hexdigest() == THRESHOLDS_SHA256_ON_MAIN


@pytest.mark.parametrize("slug", sorted(DIALOGUES.values()))
def test_every_line_has_both_clips_in_its_speakers_voice(slug):
    """[units 5] a spoken and a written clip for every line, in the voice the brief gives the speaker."""
    draft = committed(slug)
    voices = {s["name"]: s["voice"] for s in draft["brief"]["speakers"]}
    assert len(draft["lines"]) == draft["brief"]["line_count"]
    for line in draft["lines"]:
        for register in ("puhe", "kirja"):
            clip = line["audio"][register]
            path = DRAFTS / slug / clip["file"]
            assert path.is_file(), f"{slug} line {line['n']} {register}: no clip"
            assert hashlib.sha256(path.read_bytes()).hexdigest() == clip["sha256"]
            assert clip["provider"] == "azure" and clip["source"] == "synthetic"
            assert clip["voice"] == voices[line["speaker"]]
            assert clip["text"] == line[f"text_{register}"]


@pytest.mark.parametrize("slug", sorted(DIALOGUES.values()))
def test_every_ai_and_voice_call_of_each_run_is_logged(slug):
    """[units 6] the log holds the drafting, why and judge calls and one voice call per clip."""
    calls = [
        json.loads(line)
        for line in (REPO / "content" / "logs" / "ai-calls.jsonl").read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    mine = [c for c in calls if c["dialogue"] == slug]
    purposes = {c["purpose"] for c in mine if c["provider"] == "anthropic"}
    assert {"draft", "why", "judge"} <= purposes
    rounds = committed(slug)["rounds"]
    assert len([c for c in mine if c["purpose"] == "draft"]) == rounds
    assert len([c for c in mine if c["provider"] == "azure"]) == 2 * len(committed(slug)["lines"])
    assert all(isinstance(c["cost_usd"], int | float) and c["cost_usd"] >= 0 for c in mine)


def test_the_cost_command_sums_the_log_per_dialogue_and_per_unit(tmp_path):
    """[units 6] scripts/generate/log_costs.py adds up the logged cost per dialogue, per unit and in all."""
    from log_costs import costs

    briefs = tmp_path / "briefs"
    briefs.mkdir()
    for slug, unit in (("a-one", 1), ("b-two", 1), ("c-three", 2)):
        (briefs / f"{slug}.json").write_text(
            json.dumps({"unit": {"position": unit}, "dialogue": {"slug": slug}}), encoding="utf-8"
        )
    log = tmp_path / "log.jsonl"
    log.write_text(
        "\n".join(
            json.dumps({"dialogue": d, "cost_usd": c})
            for d, c in (("a-one", 0.10), ("a-one", 0.05), ("b-two", 0.2), ("c-three", 0.3), ("other", 1.0))
        ),
        encoding="utf-8",
    )
    result = costs(log, briefs)
    assert result["dialogues"] == {"a-one": 0.15, "b-two": 0.2, "c-three": 0.3, "other": 1.0}
    assert result["units"] == {1: 0.35, 2: 0.3}
    assert result["total"] == 1.65


def test_the_batch_cover_note_lists_the_six_pages_in_order():
    """[units 7] the batch cover note: the six pages in order, titles, what to do, time and return."""
    note = (REPO / "content" / "review-batches" / "mvp-batch-1.md").read_text(encoding="utf-8")
    positions = [note.index(f"content/drafts/{slug}/review/round-1.html") for slug in DIALOGUES.values()]
    assert positions == sorted(positions)
    for brief in briefs().values():
        assert brief["dialogue"]["title_en"] in note
        assert brief["unit"]["title_en"] in note
    for words in ("Download my review", "R1", "2 to 3 hours", "Sending your files back"):
        assert words in note
    assert "@" not in note


@pytest.mark.parametrize("slug", sorted(DIALOGUES.values()))
def test_review_files_ask_for_a_reviewer_code_never_a_name_or_email(slug):
    """[units 7] the review page asks for a code such as R1 and holds no email address."""
    page = (DRAFTS / slug / "review" / "round-1.html").read_text(encoding="utf-8")
    assert "Your reviewer code (for example R1, not your name)" in page
    assert not re.search(r"[\w.+-]+@[\w-]+\.[\w.]+", page)
