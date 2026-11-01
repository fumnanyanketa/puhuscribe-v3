"""The road's reading overrides: a reading chosen for one word in one line, and manual readings.

Job 20-a1-road, round 2 (the manager's list of readings that do not fit the line,
factory/jobs/20-a1-road/reading-flags.tsv). Spec statement 10: a draft has Voikko's reading for each
written word, chosen by fixed rules and no AI. Labels [a1-road 10] name that statement. Tests that need
Finnish morphology use the real Voikko and are skipped where it is not installed (the GitHub Python
check installs it and fails on any skip). No test calls the network or an AI service.
"""

from __future__ import annotations

import pytest

import road_import as ri
from analysis import candidates
from grammar import form_name
from road_checks import ManualReadingGate, manual_readings
from road_data import (
    ListAlias,
    ReadingOverride,
    RoadDataError,
    aliased_ranks,
    load_list_aliases,
    load_overrides,
    load_position_overrides,
    manual_analysis,
)
from road_parse import REPO

ROAD = REPO / "content" / "road"
GENITIVE = "CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular"
NEGATIVE_PRESENT = "CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true"
# The flags of reading-flags.tsv that were not accepted, wholly or in part (build.md lists each with
# the reason): voi (two lines where it is the verb), tule (three lines where it is the command), lisää
# (three lines where it is the noun) and tulossa (the noun tulo, not the MA-infinitive of tulla).
FLAGGED_FORMS_STILL_IN_THE_DRAFTS = {"fc6219", "a2a7fb", "aa8e1d", "7eae52"}


@pytest.fixture(scope="module")
def ctx(voikko, ranks, thresholds):
    return ri.Context(gate=voikko, ranks=ranks, thresholds=thresholds)


@pytest.fixture(scope="module")
def offline_ctx(ranks, thresholds):
    """The road's files and no Voikko: enough for what only reads the override files."""
    return ri.Context(gate=None, ranks=ranks, thresholds=thresholds)


def draft_of(ctx, slug: str) -> dict:
    dialogue = next(d for d in ctx.road.dialogues() if d.slug == slug)
    return ri.build_draft(dialogue, ctx)


def word_at(draft: dict, line: int, position: int) -> tuple[dict, dict]:
    """The written word at a place and the form it is linked to."""
    token = draft["lines"][line - 1]["kirja_tokens"][position - 1]
    form = next(f for f in draft["forms"] if f["id"] == token["form"])
    return token, form


def committed() -> dict[str, dict]:
    return ri.committed_road_drafts(None)


# Real Voikko: the four readings the manager named ------------------------------------------------


def test_a1_road_10_ajan_in_varata_ajan_is_aika_not_ajaa(ctx):
    """[a1-road 10] 'varata ajan' is booking an appointment: the genitive of aika, not 'I drive'."""
    draft = draft_of(ctx, "booking-a-haircut")
    token, form = word_at(draft, 2, 5)
    assert token["surface"] == "ajan"
    assert (token["lemma"], token["form_tag"]) == ("aika", GENITIVE)
    assert (form["lemma"], form["form_name_en"]) == ("aika", "genitive singular")


def test_a1_road_10_voi_is_oh_in_its_own_line_and_the_verb_in_another(ctx):
    """[a1-road 10] The same spelling needs a different reading in a different line: 'Voi harmi' is the
    cry, 'Lääkäri voi nähdä sinut' is the verb voida."""
    cry, cry_form = word_at(draft_of(ctx, "a-cold"), 2, 1)
    assert cry["surface"] == "Voi"
    assert (cry["lemma"], cry["form_tag"], cry_form["form_name_en"]) == (
        "voi",
        "CLASS=huudahdussana",
        "interjection",
    )
    verb, verb_form = word_at(draft_of(ctx, "booking-a-visit"), 7, 3)
    assert verb["surface"] == "voi"
    assert (verb["lemma"], verb_form["form_name_en"]) == ("voida", "present tense, 3rd person singular")


def test_a1_road_10_ei_kesta_is_a_negative_form_not_an_order(ctx):
    """[a1-road 10] Voikko offers only the imperative for 'kestä'; after 'ei' it is the negative form."""
    draft = draft_of(ctx, "where-are-the-eggs")
    token, form = word_at(draft, 8, 2)
    assert token["surface"] == "kestä"
    assert (token["lemma"], token["form_tag"]) == ("kestää", NEGATIVE_PRESENT)
    assert form["form_name_en"] == "present tense, negative form"
    assert "imperative" not in form["form_name_en"]


def test_a1_road_10_sataako_is_sataa_to_rain_not_sata_a_hundred(ctx):
    """[a1-road 10] 'sataako huomenna?' asks if it will rain: the verb sataa with the question ending."""
    draft = draft_of(ctx, "will-it-rain-tomorrow")
    token, form = word_at(draft, 1, 5)
    assert token["surface"] == "sataako"
    assert token["lemma"] == "sataa"
    assert form["form_name_en"] == "present tense, 3rd person singular, with the question ending -ko/-kö"


# No stale keys ----------------------------------------------------------------------------------


def test_a1_road_10_every_override_key_matches_a_real_token_in_the_drafts(offline_ctx):
    """[a1-road 10] Each position row names a dialogue, a line and a word position that exist, and the
    word written there; each spelling row is a word some dialogue uses. A stale key is a failure."""
    drafts = committed()
    assert ri.override_problems(drafts, offline_ctx) == []
    assert len(offline_ctx.data.position_overrides) > 50
    assert len(offline_ctx.data.overrides) > 20


def test_a1_road_10_a_stale_key_is_found(offline_ctx):
    """[a1-road 10] Proof the stale check can fail: a wrong word, a missing line and an unused spelling."""
    drafts = committed()
    slug = "booking-a-haircut"
    wrong_word = ReadingOverride("aika", GENITIVE, "manual", "x", word="ei", file_line=1)
    no_line = ReadingOverride("aika", GENITIVE, "manual", "x", word="ajan", file_line=2)
    unused = ReadingOverride("aika", GENITIVE, "manual", "x", file_line=3)
    offline_ctx_copy = ri.Context(gate=None, ranks=offline_ctx.ranks, thresholds=offline_ctx.thresholds)
    offline_ctx_copy.data.position_overrides = {(slug, 2, 5): wrong_word, (slug, 99, 1): no_line}
    offline_ctx_copy.data.overrides = {"xyzzyx": unused}
    problems = ri.override_problems(drafts, offline_ctx_copy)
    assert len(problems) == 3
    assert "the word at" in problems[0] and "'ajan'" in problems[0]
    assert "not a word of any dialogue" in problems[1]
    assert "'xyzzyx' is in no dialogue" in problems[2]


# The two kinds of row ---------------------------------------------------------------------------


def test_a1_road_10_a_voikko_row_needs_a_reading_voikko_has_and_a_manual_row_needs_one_it_lacks():
    """[a1-road 10] A voikko row that names a reading Voikko lacks is refused, and so is a manual row
    that names one Voikko offers, so the manual list stays the list of what Voikko lacks."""
    options = [{"lemma": "kestää", "form_tag": "CLASS=teonsana", "name": False, "reading": {}}]
    offered = ReadingOverride("kestää", "CLASS=teonsana", "voikko", "x", file_line=4)
    assert ri.apply_override(offered, "kestä", options) is options[0]
    lacking = ReadingOverride("kestää", NEGATIVE_PRESENT, "voikko", "x", file_line=5)
    with pytest.raises(RoadDataError, match="Voikko has no reading"):
        ri.apply_override(lacking, "kestä", options)
    wrongly_manual = ReadingOverride("kestää", "CLASS=teonsana", "manual", "x", file_line=6)
    with pytest.raises(RoadDataError, match="so the reading is voikko, not manual"):
        ri.apply_override(wrongly_manual, "kestä", options)
    manual = ReadingOverride("kestää", NEGATIVE_PRESENT, "manual", "x", file_line=7)
    chosen = ri.apply_override(manual, "kestä", options)
    assert (chosen["lemma"], chosen["form_tag"], chosen["name"]) == ("kestää", NEGATIVE_PRESENT, False)
    assert chosen["reading"]["MANUAL"] == "true"
    assert chosen["reading"] == manual_analysis("kestää", NEGATIVE_PRESENT)


def test_a1_road_10_the_override_files_refuse_a_wrong_row(tmp_path):
    """[a1-road 10] An unknown tag, a missing reason, a wrong source, a repeated key and a manual name
    are each refused with the file and the line."""
    tab = chr(9)
    nl = chr(10)

    def spelling(*rows: str):
        path = tmp_path / "reading-overrides.tsv"
        path.write_text(nl.join(rows) + nl, encoding="utf-8")
        return load_overrides(path)

    def position(*rows: str):
        path = tmp_path / "reading-overrides-by-position.tsv"
        path.write_text(nl.join(rows) + nl, encoding="utf-8")
        return load_position_overrides(path)

    good = tab.join(["kestä", "kestää", NEGATIVE_PRESENT, "manual", "after ei"])
    assert list(spelling(good)) == ["kestä"]
    cases = [
        (tab.join(["kestä", "kestää", "CLASS=teonsana;COLOUR=red", "manual", "r"]), "COLOUR"),
        (tab.join(["kestä", "kestää", NEGATIVE_PRESENT, "manual", ""]), "reason"),
        (tab.join(["kestä", "kestää", NEGATIVE_PRESENT, "guess", "r"]), "voikko or manual"),
        (tab.join(["Kirsi", "Kirsi", "CLASS=etunimi", "manual", "r"]), "cannot be a name"),
    ]
    for row, message in cases:
        with pytest.raises(RoadDataError, match=message) as err:
            spelling(row)
        assert "reading-overrides.tsv, line 1" in str(err.value)
    with pytest.raises(RoadDataError, match="appears twice"):
        spelling(good, good)
    row = tab.join(["booking-a-haircut", "2", "5", "ajan", "aika", GENITIVE, "voikko", "r"])
    assert list(position(row)) == [("booking-a-haircut", 2, 5)]
    with pytest.raises(RoadDataError, match="appears twice"):
        position(row, row)
    with pytest.raises(RoadDataError, match="must be numbers"):
        position(row.replace(tab + "2" + tab, tab + "two" + tab))


def test_a1_road_10_a_manual_reading_passes_the_checks_only_for_its_own_spelling():
    """[a1-road 10] The checks accept a form only if it is one of the gate's readings. A manual reading
    is added for the spelling it was written for and for no other word."""

    class EmptyGate:
        def _analyze_best(self, token):
            return []

    row = ReadingOverride("kestää", NEGATIVE_PRESENT, "manual", "x", word="kestä")
    voikko_row = ReadingOverride("sataa", "CLASS=teonsana", "voikko", "x", word="sataa")
    gate = ManualReadingGate(EmptyGate(), manual_readings([row, voikko_row]))
    assert [(c["lemma"], c["form_tag"]) for c in candidates(gate, "Kestä")] == [("kestää", NEGATIVE_PRESENT)]
    assert candidates(gate, "kestämme") == []
    assert candidates(gate, "sataa") == []


# The files the importer writes --------------------------------------------------------------------


def test_a1_road_10_the_manual_readings_file_is_what_the_importer_lists(offline_ctx):
    """[a1-road 10] content/road/manual-readings.tsv lists each word read by hand, with its place and
    its reason, and equals what the importer makes from the committed drafts."""
    drafts = committed()
    made = ri.manual_readings_table(drafts, offline_ctx)
    assert (ROAD / "manual-readings.tsv").read_text(encoding="utf-8") == made
    rows = [r.split(chr(9)) for r in made.splitlines() if not r.startswith("#")]
    assert len(rows) > 100
    assert all(len(r) == 8 and r[7] and form_name(r[5]) == r[6] for r in rows)


def test_a1_road_10_only_the_rejected_flags_are_still_in_the_drafts():
    """[a1-road 10] Every form of reading-flags.tsv is gone from the drafts, except the four whose flag
    was not accepted (wholly or for some lines): the flags are applied, not forgotten."""
    flagged = {
        line.split(chr(9))[0].removeprefix("form-")[:6]
        for line in (REPO / "factory" / "jobs" / "20-a1-road" / "reading-flags.tsv")
        .read_text(encoding="utf-8")
        .splitlines()
        if line.startswith("form-")
    }
    assert len(flagged) == 121
    present = {
        form["id"].removeprefix("form-")[:6]
        for draft in committed().values()
        for form in draft["forms"]
        if form["id"].removeprefix("form-")[:6] in flagged
    }
    assert present == FLAGGED_FORMS_STILL_IN_THE_DRAFTS


# Round 3: the list aliases and the pronoun minä --------------------------------------------------------


def test_a1_road_10_every_alias_key_is_a_lemma_in_the_drafts_and_every_value_is_on_the_list(ranks):
    """[a1-road 10] An alias maps a dictionary form some draft uses, which the frequency list lacks,
    to a base form the list has; each row has a reason."""
    aliases = load_list_aliases()
    assert len(aliases) >= 8
    lemmas = {f["lemma"].lower() for draft in committed().values() for f in draft["forms"]}
    for key, alias in aliases.items():
        assert key in lemmas, f"{key} is not a dictionary form of any draft"
        assert key not in ranks, f"{key} is on the list itself, so it needs no alias"
        assert alias.listed_as in ranks, f"{alias.listed_as} is not on the list"
        assert alias.reason.strip()


def test_a1_road_10_an_alias_takes_its_list_forms_rank_and_never_replaces_a_listed_word(ranks):
    """[a1-road 10] paljon counts as paljo for the level checks. A word the list has keeps its rank."""
    aliases = load_list_aliases()
    result = aliased_ranks(ranks, aliases)
    assert result["paljon"] == ranks["paljo"] and "paljon" not in ranks
    assert result["tuo"] == ranks["tuo"]
    own = {"tuo": ListAlias("tuo", "paljo", "r")}
    assert aliased_ranks({"tuo": 5, "paljo": 9}, own)["tuo"] == 5
    missing = {"abc": ListAlias("abc", "nowhere", "r")}
    assert "abc" not in aliased_ranks(ranks, missing)


def test_a1_road_10_the_alias_file_refuses_a_wrong_row(tmp_path):
    """[a1-road 10] The same word twice, a missing reason and a word listed as itself are refused."""
    tab = chr(9)
    nl = chr(10)
    path = tmp_path / "list-aliases.tsv"

    def load(*rows: str):
        path.write_text(nl.join(rows) + nl, encoding="utf-8")
        return load_list_aliases(path)

    good = tab.join(["paljon", "paljo", "a lot"])
    assert list(load(good)) == ["paljon"]
    with pytest.raises(RoadDataError, match="appears twice"):
        load(good, good)
    with pytest.raises(RoadDataError, match="reason"):
        load(tab.join(["paljon", "paljo", ""]))
    with pytest.raises(RoadDataError, match="two different base forms"):
        load(tab.join(["paljon", "paljon", "same"]))


def test_a1_road_10_minae_is_the_pronoun_in_every_line_of_the_drafts():
    """[a1-road 10] All 179 words minä (and Minä) are the personal pronoun, none the noun minä and none
    a form of mikä, and one spelling row says so."""
    assert load_overrides()["minä"].form_tag == "CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular"
    found = 0
    for draft in committed().values():
        if draft["brief"].get("source") != "written":
            continue
        for line in draft["lines"]:
            for token in line["kirja_tokens"]:
                if token["surface"].lower() == "minä":
                    found += 1
                    assert (token["lemma"], token["form_tag"]) == (
                        "minä",
                        "CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular",
                    )
    assert found == 179


def test_a1_road_10_minae_is_the_pronoun_even_where_voikko_prefers_the_noun(ctx):
    """[a1-road 10] In these dialogues the automatic choice used to be the noun minä for some words."""
    for slug in ("im-lost", "buying-a-ticket", "at-the-market"):
        draft = draft_of(ctx, slug)
        tags = {
            token["form_tag"]
            for line in draft["lines"]
            for token in line["kirja_tokens"]
            if token["surface"].lower() == "minä"
        }
        assert tags == {"CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular"}, slug


# Round 5: hitaammin, en voi and the third person voi ---------------------------------------------------


def test_a1_road_10_hitaammin_is_the_adverb_more_slowly_from_hidas(ctx):
    """[a1-road 10] Voikko offers only the instructive plural; the card says hidas, comparative, adverb."""
    token, form = word_at(draft_of(ctx, "sorry-i-didnt-understand"), 4, 5)
    assert token["surface"] == "hitaammin"
    assert (token["lemma"], token["form_tag"]) == ("hidas", "CLASS=seikkasana;COMPARISON=comparative")
    assert form["form_name_en"] == "comparative, adverb"


def test_a1_road_10_en_voi_is_the_negative_form_of_voida(ctx):
    """[a1-road 10] In Minä en voi syödä, voi is voida, present tense, negative form."""
    token, form = word_at(draft_of(ctx, "is-there-milk-in-it"), 3, 3)
    assert token["surface"] == "voi"
    assert (token["lemma"], token["form_tag"]) == ("voida", NEGATIVE_PRESENT)
    assert form["form_name_en"] == "present tense, negative form"


def test_a1_road_10_the_third_person_voi_row_is_used_only_by_the_verb_line():
    """[a1-road 10] No "Voi ei!" or other cry uses the verb row form-fc6219c3121b: its only line is
    "Lääkäri voi nähdä sinut" (booking-a-visit 7). Every cry has the interjection row."""
    places = []
    cries = 0
    for slug, draft in committed().items():
        if draft["brief"].get("source") != "written":
            continue
        for line in draft["lines"]:
            for position, token in enumerate(line["kirja_tokens"], start=1):
                if token["surface"].lower() != "voi":
                    continue
                if token.get("form") == "form-fc6219c3121b":
                    places.append((slug, line["n"], position))
                elif token["form_tag"] == "CLASS=huudahdussana":
                    cries += 1
    assert places == [("booking-a-visit", 7, 3)]
    assert cries == 12
