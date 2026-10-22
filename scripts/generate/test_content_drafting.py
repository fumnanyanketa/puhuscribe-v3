"""Brief to review pack, with the fake providers (job 7-content-pipeline, [content N]).

Needs Voikko (Linux); the GitHub Python check runs it with the network off.
"""

from __future__ import annotations

import argparse
import json

import pytest

import pipeline
from audio import make_audio
from drafting import MAX_ROUNDS, DraftFailed, draft_dialogue


def run_args(tmp_path):
    return argparse.Namespace(
        brief="content/briefs/meeting-people-new-colleague.json", out=str(tmp_path / "pack")
    )


def test_the_loop_drafts_checks_and_judges_in_one_round(voikko, ranks, thresholds, brief, fake_ai):
    """[content 2] draft, Voikko check, forms and why lines, judge, automatic checks."""
    provider = fake_ai("unit-1-run.json")
    draft, report = draft_dialogue(
        brief, "content/briefs/x.json", provider, voikko, ranks, thresholds, log=lambda _m: None
    )
    assert report["ok"]
    assert draft["rounds"] == 1
    assert [p["purpose"] for p in provider.prompts] == ["draft", "why", "judge"]
    assert provider.remaining() == 0
    assert all(line["judge"]["faithful"] for line in draft["lines"])
    assert {f["surface_kirja"] for f in draft["forms"]} >= {"minä", "olen", "mistä", "oletko"}


def test_a_rejected_word_is_named_in_the_next_draft(voikko, ranks, thresholds, brief, fake_ai):
    """[content 2] redraft with the rejected words named."""
    provider = fake_ai("unit-1-redraft.json")
    draft, report = draft_dialogue(
        brief, "content/briefs/x.json", provider, voikko, ranks, thresholds, log=lambda _m: None
    )
    assert report["ok"]
    assert draft["rounds"] == 2
    second_draft_prompt = provider.prompts[1]["prompt"]
    assert provider.prompts[1]["purpose"] == "draft"
    assert "'blarghti' is not a real Finnish word" in second_draft_prompt


def test_after_the_last_round_the_run_fails_with_each_failing_word(voikko, ranks, thresholds, brief, fake_ai):
    """[content 2] at most 3 rounds; then a plain list of each failing word or line."""
    assert MAX_ROUNDS == 3
    provider = fake_ai("unit-1-fails.json")
    with pytest.raises(DraftFailed) as failed:
        draft_dialogue(
            brief, "content/briefs/x.json", provider, voikko, ranks, thresholds, log=lambda _m: None
        )
    assert [p["purpose"] for p in provider.prompts] == ["draft", "draft", "draft"]
    assert "line 4: 'blarghti' is not a real Finnish word (Voikko does not know it)" in failed.value.failures
    assert "kollega" in provider.prompts[2]["prompt"], "round 2's out of level word is named in round 3"


def test_run_writes_the_review_pack(voikko, fake_ai, fake_voice, tmp_path, monkeypatch):
    """[content 2] the result holds the draft, the check report, the audio, the review page and the log."""
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    provider = fake_ai("unit-1-run.json", tmp_path / "ai-calls.jsonl")
    code = pipeline.cmd_run(
        run_args(tmp_path), gate=voikko, ai=provider, voice=fake_voice, recordings=tmp_path / "none"
    )
    pack = tmp_path / "pack"
    assert code == 0
    assert sorted(p.relative_to(pack).as_posix() for p in pack.rglob("*") if p.is_file()) == sorted(
        [
            "draft.json",
            "check-report.json",
            "run.log",
            "ai-calls.jsonl",
            "review/round-1.html",
            "review/round-1.json",
        ]
        + [f"audio/{n}-{r}.mp3" for n in range(1, 7) for r in ("puhe", "kirja")]
    )
    report = json.loads((pack / "check-report.json").read_text(encoding="utf-8"))
    assert report["ok"]
    calls = [json.loads(line) for line in (pack / "ai-calls.jsonl").read_text(encoding="utf-8").splitlines()]
    assert [c["purpose"] for c in calls] == ["draft", "why", "judge"] + ["voice"] * 12
    draft = json.loads((pack / "draft.json").read_text(encoding="utf-8"))
    assert draft["providers"] == {"ai": "fake", "voice": "fake"}


def test_a_failing_run_makes_no_review_pack(voikko, fake_ai, fake_voice, tmp_path, monkeypatch):
    """[content 2] if a check still fails after the last round, the run fails and makes no review pack."""
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    provider = fake_ai("unit-1-fails.json", tmp_path / "ai-calls.jsonl")
    code = pipeline.cmd_run(
        run_args(tmp_path), gate=voikko, ai=provider, voice=fake_voice, recordings=tmp_path / "none"
    )
    pack = tmp_path / "pack"
    assert code == 1
    assert not (pack / "review").exists()
    assert not (pack / "audio").exists()
    log = (pack / "run.log").read_text(encoding="utf-8")
    assert "No review pack was made" in log
    assert "line 4: 'blarghti' is not a real Finnish word" in log


def test_a_native_recording_replaces_the_synthetic_clip(unit_1_draft, fake_voice, tmp_path):
    """[content 6] an mp3 at content/recordings/<slug>/<line>-<register>.mp3 replaces that clip."""
    recordings = tmp_path / "recordings"
    native = recordings / "meeting-people-new-colleague" / "2-puhe.mp3"
    native.parent.mkdir(parents=True)
    native.write_bytes(b"ID3 native recording of line 2")
    make_audio(unit_1_draft, tmp_path / "pack", fake_voice, recordings, log=lambda _m: None)
    clip = unit_1_draft["lines"][1]["audio"]["puhe"]
    assert clip["source"] == "native recording"
    assert (tmp_path / "pack" / clip["file"]).read_bytes() == b"ID3 native recording of line 2"
    assert unit_1_draft["lines"][1]["audio"]["kirja"]["source"] == "synthetic"
    calls = [json.loads(c) for c in (tmp_path / "ai-calls.jsonl").read_text(encoding="utf-8").splitlines()]
    assert len([c for c in calls if c["purpose"] == "voice"]) == 11, "the replaced clip is not synthesised"
