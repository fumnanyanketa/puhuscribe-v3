"""The automatic checks with real Voikko (job 7-content-pipeline, [content N]).

Each protection is shown passing on the unit 1 fixture dialogue and failing on
a planted fault. Needs Voikko (Linux); the GitHub Python check runs it.
"""

from __future__ import annotations

import copy

import pytest

import grammar
from content_checks import run_checks
from drafting import apply_readings
from fingerprints import line_fingerprint


def check(draft, voikko, ranks, thresholds):
    return run_checks(draft, voikko, ranks, thresholds)


def failing(report, name):
    return report["checks"][name]["failures"]


def replace_kirja_word(draft, line_no, index, new):
    """Swap one written word in a line's text and its word list."""
    line = draft["lines"][line_no - 1]
    old = line["kirja_tokens"][index]["surface"]
    line["text_kirja"] = line["text_kirja"].replace(old, new, 1)
    line["kirja_tokens"][index]["surface"] = new


def test_the_fixture_dialogue_passes_every_check(unit_1_draft, voikko, ranks, thresholds):
    """[content 7] [content 8] [content 9] [content 10] [content 11] [content 21] the passing baseline."""
    report = check(unit_1_draft, voikko, ranks, thresholds)
    assert report["ok"], report["failures"]
    for name in ("word_validity", "level_fit", "grammar_cards", "register_faithfulness"):
        assert report["checks"][name]["rate"] == 1.0
        assert report["checks"][name]["checked"] > 0


def test_a_planted_invented_word_fails_word_validity(unit_1_draft, voikko, ranks, thresholds):
    """[content 7] every written word analyses in Voikko through v2's VoikkoGate; an invented word fails."""
    draft = copy.deepcopy(unit_1_draft)
    replace_kirja_word(draft, 4, 2, "Blarghtista")
    report = check(draft, voikko, ranks, thresholds)
    assert not report["ok"]
    assert failing(report, "word_validity") == ["line 4: 'Blarghtista' is not a Finnish word Voikko knows"]
    assert report["checks"]["word_validity"]["rate"] < 1.0


def test_words_must_appear_in_order_in_their_line(unit_1_draft, voikko, ranks, thresholds):
    """[content 21] each token's text appears in order in its line's text."""
    draft = copy.deepcopy(unit_1_draft)
    tokens = draft["lines"][2]["kirja_tokens"]
    tokens[0], tokens[1] = tokens[1], tokens[0]
    report = check(draft, voikko, ranks, thresholds)
    assert any("does not appear in order" in f for f in failing(report, "token_order"))
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][0]["puhe_tokens"][1]["surface"] = "Minä"
    report = check(draft, voikko, ranks, thresholds)
    assert failing(report, "token_order") == [
        "line 1: the spoken word 'Minä' does not appear in order in the line"
    ]


def test_a_dropped_word_is_caught(unit_1_draft, voikko, ranks, thresholds):
    """[content 21] the words cover the whole line, so a word missing from the list fails."""
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][0]["kirja_tokens"].pop()
    report = check(draft, voikko, ranks, thresholds)
    assert any("do not cover the line exactly" in f for f in failing(report, "token_order"))


def test_spoken_words_link_to_existing_written_words(unit_1_draft, voikko, ranks, thresholds):
    """[content 8] a link to a missing written word fails."""
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][2]["puhe_tokens"][3]["kirja"] = 9
    report = check(draft, voikko, ranks, thresholds)
    assert "line 3: the spoken word 'kotoisin' links to written word 9, which is missing" in failing(
        report, "spoken_links"
    )
    assert "line 3: no spoken word renders the written word 'kotoisin'" in failing(report, "spoken_links")


def test_a_doubled_written_word_fails(unit_1_draft, voikko, ranks, thresholds):
    """[content 8] two spoken words rendering one written word fails."""
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][0]["puhe_tokens"][2]["kirja"] = 2
    report = check(draft, voikko, ranks, thresholds)
    links = failing(report, "spoken_links")
    assert "line 1: the written word 'Minä' is rendered by 2 spoken words" in links
    assert "line 1: no spoken word renders the written word 'olen'" in links


def test_spoken_only_words_get_no_form_and_are_listed(unit_1_draft, voikko, ranks, thresholds):
    """[content 8] spoken only words get no form and are listed for the reviewer."""
    draft = copy.deepcopy(unit_1_draft)
    line = draft["lines"][5]
    line["text_puhe"] = "No oon. Mä oon Helsingist."
    line["puhe_tokens"].insert(0, {"surface": "No", "spoken_only": True})
    line["puhe_tokens"][1]["surface"] = "oon"
    line["judge"]["fingerprint"] = line_fingerprint(line)
    report = check(draft, voikko, ranks, thresholds)
    assert report["ok"], report["failures"]
    assert report["spoken_only_words"] == ["line 6: No"]
    draft["lines"][5]["puhe_tokens"][0]["kirja"] = 1  # a spoken only word cannot also link
    assert not check(draft, voikko, ranks, thresholds)["ok"]


def test_a_planted_out_of_level_word_fails(unit_1_draft, voikko, ranks, thresholds):
    """[content 9] every written base form apart from names is inside the rank cap or on the extra list."""
    draft = copy.deepcopy(unit_1_draft)
    draft["brief"]["rank_cap"] = 100  # hei is rank 499, entä 941
    report = check(draft, voikko, ranks, thresholds)
    level = failing(report, "level_fit")
    assert any("'Hei' (base form hei) is outside the frequency rank cap of 100" in f for f in level)
    assert not any("Aino" in f or "Helsingistä" in f or "Brasiliasta" in f for f in level), "names are exempt"
    draft["brief"]["extra_base_forms"] += ["hei", "entä", "sinä"]
    level = failing(check(draft, voikko, ranks, thresholds), "level_fit")
    assert not any("'Hei'" in f or "'Entä'" in f for f in level)


def test_a_planted_out_of_list_form_fails(unit_1_draft, voikko, ranks, thresholds):
    """[content 9] every form is on the unit's grammar list."""
    draft = copy.deepcopy(unit_1_draft)
    draft["brief"]["grammar"] = ["olla-present", "personal-pronouns", "question-clitic"]
    report = check(draft, voikko, ranks, thresholds)
    assert failing(report, "level_fit") == [
        "line 3: 'Mistä' is a form (elative singular) that is not on the unit's grammar list"
    ]


def test_a_form_must_be_one_of_voikkos_readings(unit_1_draft, voikko, ranks, thresholds):
    """[content 10] a form's tag is built only from one of Voikko's own readings of that word."""
    draft = copy.deepcopy(unit_1_draft)
    token = draft["lines"][0]["kirja_tokens"][2]  # olen
    token["form_tag"] = token["form_tag"].replace("PERSON=1", "PERSON=3")
    report = check(draft, voikko, ranks, thresholds)
    assert any(
        "the form of 'olen'" in f and "is not one of Voikko's readings" in f
        for f in failing(report, "grammar_cards")
    )


def test_the_ai_may_choose_among_voikkos_readings_but_never_add_one(unit_1_draft, voikko):
    """[content 10] a reading number outside Voikko's readings is refused."""
    from analysis import candidates

    lines = copy.deepcopy(unit_1_draft["lines"][:1])
    options = {"L1.W2": candidates(voikko, "Minä")}
    whys, failures = apply_readings(lines, {"words": [{"id": "L1.W2", "reading": 9, "why_en": "x"}]}, options)
    assert failures == [
        f"line 1: the reading chosen for 'Minä' (9) is not one of Voikko's {len(options['L1.W2'])} readings"
    ]
    whys, failures = apply_readings(lines, {"words": [{"id": "L1.W2", "reading": 0, "why_en": "x"}]}, options)
    assert failures


def test_a_name_must_be_a_name_reading(unit_1_draft, voikko, ranks, thresholds):
    """[content 9] [content 10] a common word cannot be marked a name to skip the level check."""
    draft = copy.deepcopy(unit_1_draft)
    token = draft["lines"][0]["kirja_tokens"][0]  # Hei
    token["name"] = True
    report = check(draft, voikko, ranks, thresholds)
    assert any("'Hei' is marked a name" in f for f in failing(report, "grammar_cards"))


def test_the_form_name_must_be_the_tables_name(unit_1_draft, voikko, ranks, thresholds):
    """[content 10] the form's English name comes from the tag through the fixed table."""
    draft = copy.deepcopy(unit_1_draft)
    form = next(f for f in draft["forms"] if f["surface_kirja"] == "olen")
    form["form_name_en"] = "first person present"
    report = check(draft, voikko, ranks, thresholds)
    assert any(
        "is not the table's name 'present tense, 1st person singular'" in f
        for f in failing(report, "grammar_cards")
    )


def test_an_unknown_voikko_value_fails_the_check(unit_1_draft, voikko, ranks, thresholds, monkeypatch):
    """[content 10] a Voikko value the table does not know fails the check instead of guessing."""
    monkeypatch.delitem(grammar.CASE_NAMES, "sisaeronto")
    report = check(unit_1_draft, voikko, ranks, thresholds)
    assert any("SIJAMUOTO=sisaeronto has no English name" in f for f in failing(report, "grammar_cards"))


@pytest.mark.parametrize(
    ("why", "expected"),
    [
        ("y" * 141, "over the limit of 140"),
        ("Olen means I am.\nIn speech: oon.", "line break"),
        ("Olen is followed by the partitive.", "grammar term 'partitive'"),
        ("", "empty"),
    ],
)
def test_planted_why_failures_are_refused(unit_1_draft, voikko, ranks, thresholds, why, expected):
    """[content 10] each "why" is one line of at most 140 characters and names no other grammar term."""
    draft = copy.deepcopy(unit_1_draft)
    form = next(f for f in draft["forms"] if f["surface_kirja"] == "olen")
    form["why_en"] = why
    report = check(draft, voikko, ranks, thresholds)
    assert any(expected in f for f in failing(report, "grammar_cards"))


def test_the_judge_must_accept_every_line(unit_1_draft, voikko, ranks, thresholds):
    """[content 11] with 4 to 8 lines, 98 percent means every line."""
    assert thresholds["register_faithfulness_judge"] == 0.98
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][3]["judge"]["faithful"] = False
    draft["lines"][3]["judge"]["reason"] = "the written line says Finland"
    report = check(draft, voikko, ranks, thresholds)
    assert not report["checks"]["register_faithfulness"]["passed"]
    assert report["checks"]["register_faithfulness"]["rate"] == pytest.approx(5 / 6, abs=1e-4)


def test_a_line_changed_after_it_was_judged_fails(unit_1_draft, voikko, ranks, thresholds):
    """[content 11] each verdict is stored with the line's fingerprint; a later change fails."""
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][1]["gloss_en"] = "Hello, I am Maria."
    report = check(draft, voikko, ranks, thresholds)
    assert failing(report, "register_faithfulness") == ["line 2: the line changed after the judge checked it"]
    del draft["lines"][1]["judge"]
    report = check(draft, voikko, ranks, thresholds)
    assert failing(report, "register_faithfulness") == ["line 2: the judge has not checked this line"]
