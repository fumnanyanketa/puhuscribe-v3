"""Briefs (job 7-content-pipeline, factory/jobs/7-content-pipeline/spec.md, label [content N])."""

from __future__ import annotations

import copy
import json

import pytest

from brief import BriefError, load_brief, validate_brief
from conftest import UNIT_1_BRIEF

REQUIRED = [
    ("unit",),
    ("unit", "slug"),
    ("unit", "position"),
    ("unit", "title_en"),
    ("unit", "can_do_en"),
    ("dialogue",),
    ("dialogue", "slug"),
    ("dialogue", "position"),
    ("dialogue", "title_en"),
    ("situation_en",),
    ("grammar",),
    ("rank_cap",),
    ("extra_base_forms",),
    ("speakers",),
    ("line_count",),
]


def raw_brief() -> dict:
    return json.loads(UNIT_1_BRIEF.read_text(encoding="utf-8"))


def test_unit_1_brief_has_every_field_from_prd_section_6():
    """[content 1] the unit 1 brief, written from PRD section 6 unit 1."""
    brief = load_brief(UNIT_1_BRIEF)
    assert brief["unit"]["slug"] == "meeting-people"
    assert brief["unit"]["position"] == 1
    assert "introduce yourself" in brief["unit"]["can_do_en"]
    assert "where you are from" in brief["unit"]["can_do_en"]
    assert brief["dialogue"]["position"] == 1
    assert brief["grammar"] == ["olla-present", "personal-pronouns", "inessive-elative", "question-clitic"]
    assert brief["rank_cap"] > 0
    assert 4 <= brief["line_count"] <= 8
    assert len(brief["speakers"]) == 2
    for speaker in brief["speakers"]:
        assert speaker["name"] and speaker["role_en"] and speaker["voice"].startswith("fi-FI-")


@pytest.mark.parametrize("path", REQUIRED, ids=lambda p: ".".join(p))
def test_a_brief_with_a_missing_field_is_refused(path):
    """[content 1] the pipeline refuses a brief with a missing field, and names it."""
    data = raw_brief()
    target = data
    for key in path[:-1]:
        target = target[key]
    del target[path[-1]]
    with pytest.raises(BriefError) as err:
        validate_brief(data)
    assert f"'{path[-1]}'" in str(err.value)


@pytest.mark.parametrize("count", [3, 9, "6", True])
def test_line_count_must_be_4_to_8(count):
    """[content 1] a line count from 4 to 8."""
    data = raw_brief()
    data["line_count"] = count
    with pytest.raises(BriefError, match="line_count"):
        validate_brief(data)


def test_each_speaker_needs_a_role_and_a_finnish_voice():
    """[content 1] the speakers with an English role label and a voice each."""
    data = raw_brief()
    bad = copy.deepcopy(data)
    del bad["speakers"][0]["role_en"]
    with pytest.raises(BriefError, match="role_en"):
        validate_brief(bad)
    bad = copy.deepcopy(data)
    bad["speakers"][1]["voice"] = "en-US-JennyNeural"
    with pytest.raises(BriefError, match="voice"):
        validate_brief(bad)


def test_unknown_grammar_ids_are_refused():
    """[content 1] the grammar list must use ids the checks know."""
    data = raw_brief()
    data["grammar"] = ["olla-present", "past-tense"]
    with pytest.raises(BriefError, match="past-tense"):
        validate_brief(data)
