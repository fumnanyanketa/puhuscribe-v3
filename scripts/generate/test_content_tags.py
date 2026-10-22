"""Form tags, names, grammar lists and "why" rules, without Voikko (job 7-content-pipeline, [content N]).

The readings below are copied from real Voikko output (libvoikko 4.3.2, voikko-fi 2.5,
Ubuntu, 21 October 2026). Tests with live Voikko are in test_content_checks.py.
"""

from __future__ import annotations

import pytest

import grammar
from grammar import (
    UnknownTagValue,
    form_name,
    form_tag,
    is_base_form,
    on_grammar_list,
    parse_tag,
    why_problems,
)

OLEN = {
    "BASEFORM": "olla",
    "CLASS": "teonsana",
    "MOOD": "indicative",
    "NEGATIVE": "false",
    "NUMBER": "singular",
    "PERSON": "1",
    "TENSE": "present_simple",
    "STRUCTURE": "=pppp",
    "FSTOUTPUT": "[Lt][Xp]olla[X]ole[Tt][Ap][P1][Ny][Ef]n",
}
OLETKO = {**OLEN, "PERSON": "2", "KYSYMYSLIITE": "true"}
MISTA = {"BASEFORM": "mikä", "CLASS": "asemosana", "NUMBER": "singular", "SIJAMUOTO": "sisaeronto"}
KAHVIA = {"BASEFORM": "kahvi", "CLASS": "nimisana", "NUMBER": "singular", "SIJAMUOTO": "osanto"}
NIMENI = {
    "BASEFORM": "nimi",
    "CLASS": "nimisana",
    "NUMBER": "singular",
    "POSSESSIVE": "1s",
    "SIJAMUOTO": "nimento",
}
HE = {"BASEFORM": "he", "CLASS": "asemosana", "NUMBER": "plural", "SIJAMUOTO": "nimento"}
TUTUSTUA = {"BASEFORM": "tutustua", "CLASS": "teonsana", "MOOD": "A-infinitive", "NEGATIVE": "both"}
HEI = {"BASEFORM": "hei", "CLASS": "huudahdussana"}
ISOMPI = {
    "BASEFORM": "iso",
    "CLASS": "laatusana",
    "COMPARISON": "comparative",
    "NUMBER": "singular",
    "SIJAMUOTO": "nimento",
}
EN = {"BASEFORM": "ei", "CLASS": "kieltosana", "MOOD": "indicative", "NUMBER": "singular", "PERSON": "1"}

UNIT_1 = ["olla-present", "personal-pronouns", "inessive-elative", "question-clitic"]


def test_tag_uses_the_fixed_attribute_order_and_leaves_out_version_fields():
    """[content 10] the canonical tag, built only from Voikko's own attributes."""
    assert (
        form_tag(OLEN)
        == "CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false"
    )
    assert "STRUCTURE" not in form_tag(OLEN) and "FSTOUTPUT" not in form_tag(OLEN)
    assert form_tag(OLETKO).endswith(";KYSYMYSLIITE=true")
    assert parse_tag(form_tag(OLETKO))["PERSON"] == "2"


def test_tag_attributes_out_of_order_or_unknown_are_refused():
    """[content 10] a tag that is not a canonical Voikko tag is refused."""
    with pytest.raises(UnknownTagValue):
        parse_tag("NUMBER=singular;CLASS=nimisana")
    with pytest.raises(UnknownTagValue):
        parse_tag("CLASS=nimisana;WEIGHT=3")


@pytest.mark.parametrize(
    ("reading", "name"),
    [
        (OLEN, "present tense, 1st person singular"),
        (OLETKO, "present tense, 2nd person singular, with the question ending -ko/-kö"),
        (MISTA, "elative singular"),
        (KAHVIA, "partitive singular"),
        (NIMENI, "nominative singular, with the possessive ending for my"),
        (TUTUSTUA, "basic form (A-infinitive)"),
        (HEI, "interjection"),
        (ISOMPI, "comparative, nominative singular"),
        (EN, "negative verb, 1st person singular"),
    ],
)
def test_form_names_come_from_the_tag_table(reading, name):
    """[content 10] the form's English name comes from the tag through a fixed table."""
    assert form_name(form_tag(reading)) == name


def test_a_voikko_value_the_table_does_not_know_fails_instead_of_guessing(monkeypatch):
    """[content 10] an unknown Voikko value fails the check."""
    with pytest.raises(UnknownTagValue, match="SIJAMUOTO=uusisija"):
        form_name("CLASS=nimisana;SIJAMUOTO=uusisija;NUMBER=singular")
    monkeypatch.delitem(grammar.CASE_NAMES, "osanto")
    with pytest.raises(UnknownTagValue, match="osanto"):
        form_name(form_tag(KAHVIA))


def test_base_forms_are_dictionary_forms_only():
    """[content 9] dictionary forms count as on every grammar list; inflected forms do not."""
    assert is_base_form(parse_tag(form_tag(HEI)))
    assert is_base_form(parse_tag(form_tag(TUTUSTUA)))
    assert not is_base_form(parse_tag(form_tag(KAHVIA)))
    assert not is_base_form(parse_tag(form_tag(ISOMPI)))
    assert not is_base_form(parse_tag(form_tag(NIMENI)))


@pytest.mark.parametrize(
    ("reading", "allowed"),
    [
        (OLEN, True),
        (OLETKO, True),
        (MISTA, True),
        (HE, True),
        (HEI, True),
        (KAHVIA, False),  # partitive: unit 2
        (NIMENI, False),  # possessive ending
        (EN, False),  # negation
        (ISOMPI, False),  # comparative
    ],
)
def test_unit_1_grammar_list(reading, allowed):
    """[content 9] every form must be on the unit's grammar list."""
    assert on_grammar_list(reading["BASEFORM"], form_tag(reading), UNIT_1) is allowed


def test_the_question_ending_needs_its_own_list_entry():
    """[content 9] -ko/-kö is allowed only when the list names it."""
    without = [g for g in UNIT_1 if g != "question-clitic"]
    assert not on_grammar_list("olla", form_tag(OLETKO), without)


def test_why_rules():
    """[content 10] one line, at most 140 characters, no grammar term but the form's own."""
    name = form_name(form_tag(OLEN))
    assert why_problems("Olen is olla (to be) with minä: minä olen means I am.", name) == []
    assert why_problems("Olen is the 1st person singular of olla, present tense.", name) == []
    assert why_problems("x" * 141, name) == ["the why line is 141 characters, over the limit of 140"]
    assert why_problems("x" * 140, name) == []
    assert "line break" in why_problems("Olen means I am.\nSpoken: oon.", name)[0]
    assert why_problems("", name) == ["the why line is empty"]
    problems = why_problems("Olen takes the partitive after it.", name)
    assert problems == ["the why line names the grammar term 'partitive', which is not this form's own"]
    assert why_problems("Mistä is the elative of mikä.", form_name(form_tag(MISTA))) == []
    assert why_problems("Mistä is like a plural.", form_name(form_tag(MISTA)))
