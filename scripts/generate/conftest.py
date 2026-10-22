"""Shared test fixtures for the content pipeline tests (job 7-content-pipeline).

Tests that need Finnish morphology use the real Voikko through v2's VoikkoGate.
Where Voikko is not installed (a Windows laptop) they are skipped; the GitHub
Python check installs Voikko and fails if any test was skipped.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
FIXTURES = HERE / "fixtures"
UNIT_1_BRIEF = REPO / "content" / "briefs" / "meeting-people-new-colleague.json"


@pytest.fixture(scope="session")
def voikko():
    try:
        from voikko_gate import VoikkoGate

        return VoikkoGate()
    except Exception as err:  # libvoikko or the Finnish dictionary is missing here
        pytest.skip(
            f"Voikko is not installed here ({type(err).__name__}); the GitHub Python check runs this test"
        )


@pytest.fixture(scope="session")
def ranks():
    from analysis import frequency_ranks

    return frequency_ranks()


@pytest.fixture(scope="session")
def thresholds():
    from content_checks import load_thresholds

    return load_thresholds()


@pytest.fixture
def brief():
    from brief import load_brief

    return load_brief(UNIT_1_BRIEF)


def recording(name: str) -> dict:
    return json.loads((FIXTURES / "ai" / name).read_text(encoding="utf-8"))


@pytest.fixture
def fake_ai(tmp_path):
    """A fake AI provider that logs to a temporary file, from a named recording."""
    from providers.ai import FakeProvider

    def make(name_or_data, log_path=None):
        data = recording(name_or_data) if isinstance(name_or_data, str) else name_or_data
        return FakeProvider(data, log_path or tmp_path / "ai-calls.jsonl")

    return make


@pytest.fixture
def fake_voice(tmp_path):
    from providers.voice import FakeProvider

    return FakeProvider(tmp_path / "ai-calls.jsonl")


@pytest.fixture
def unit_1_draft(voikko, ranks, thresholds, brief, fake_ai):
    """The unit 1 fixture dialogue, drafted through the real loop with the fake AI."""
    from drafting import draft_dialogue

    draft, report = draft_dialogue(
        brief,
        "content/briefs/meeting-people-new-colleague.json",
        fake_ai("unit-1-run.json"),
        voikko,
        ranks,
        thresholds,
        log=lambda _m: None,
    )
    assert report["ok"], report["failures"]
    return draft
