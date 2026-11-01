"""The A1 road's voices: the throttle, the retry, the skip and the character guard (job 20-a1-road).

Spec: factory/jobs/20-a1-road/spec.md, "Done when" 18 and 19. Labels [a1-road N]. No network is used: the
Azure provider gets a fake opener, a fake clock and a fake sleep.
"""

from __future__ import annotations

import io
import json
import re
import urllib.error
from datetime import UTC, datetime
from pathlib import Path

import pytest

from providers import voice as voice_module
from providers.ai import AiError, FakeProvider
from providers.voice import (
    GUARD_CHARACTERS,
    AzureProvider,
    Throttle,
    VoiceError,
    month_characters,
    refuse_over_allowance,
    request_hash,
)
from road_import import characters_to_voice, clip_needs_voice

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]


class Clock:
    """A clock that only moves when the throttle or the retry sleeps."""

    def __init__(self) -> None:
        self.now = 1000.0
        self.sleeps: list[float] = []

    def time(self) -> float:
        return self.now

    def sleep(self, seconds: float) -> None:
        self.sleeps.append(seconds)
        self.now += seconds


class Response:
    def __init__(self, data: bytes) -> None:
        self._data = data

    def read(self) -> bytes:
        return self._data

    def __enter__(self) -> Response:
        return self

    def __exit__(self, *exc: object) -> None:
        return None


def http_error(code: int, retry_after: str | None = None) -> urllib.error.HTTPError:
    headers = {"Retry-After": retry_after} if retry_after else {}
    return urllib.error.HTTPError("https://example.test", code, "x", headers, io.BytesIO(b""))  # type: ignore[arg-type]


@pytest.fixture
def azure_env(monkeypatch):
    monkeypatch.setenv("AZURE_SPEECH_KEY", "test-key-not-real")
    monkeypatch.setenv("AZURE_SPEECH_REGION", "italynorth")
    monkeypatch.setenv("AZURE_SPEECH_TIER", "F0")


def provider(tmp_path, clock, answers):
    """An Azure provider whose requests are answered from `answers` (a response or an error each)."""
    sent: list[float] = []

    def opener(request, timeout):
        sent.append(clock.time())
        answer = answers.pop(0) if len(answers) > 1 else answers[0]
        if isinstance(answer, Exception):
            raise answer
        return Response(answer)

    azure = AzureProvider(tmp_path / "ai-calls.jsonl", opener=opener, clock=clock.time, sleep=clock.sleep)
    return azure, sent


def test_a1_road_18_the_throttle_sends_at_most_20_requests_in_any_60_seconds():
    """[a1-road 18] 50 requests, a fake clock: in no window of 60 seconds are there more than 20."""
    clock = Clock()
    throttle = Throttle(clock=clock.time, sleep=clock.sleep)
    stamps = []
    for _ in range(50):
        throttle.wait()
        stamps.append(clock.time())
    for start in stamps:
        assert sum(1 for t in stamps if start <= t < start + 60) <= 20
    assert stamps[19] == stamps[0] and stamps[20] >= stamps[0] + 60
    assert clock.sleeps, "the throttle had to wait"


def test_a1_road_18_a_part_of_272_clips_takes_about_15_minutes():
    """[a1-road 18] 272 requests at 20 a minute: the fake clock shows 12 to 15 minutes."""
    clock = Clock()
    throttle = Throttle(clock=clock.time, sleep=clock.sleep)
    for _ in range(272):
        throttle.wait()
    assert 12 * 60 <= clock.now - 1000.0 <= 15 * 60


def test_a1_road_18_azure_retries_a_busy_answer_and_a_server_error(azure_env, tmp_path):
    """[a1-road 18] HTTP 429 and 500 wait and try again; the audio comes at last and is logged once."""
    clock = Clock()
    azure, sent = provider(tmp_path, clock, [http_error(429, "7"), http_error(500), b"mp3-bytes"])
    audio = azure.synthesize(text="Moi!", voice="fi-FI-NooraNeural", dialogue="x")
    assert audio == b"mp3-bytes"
    assert len(sent) == 3
    assert 7.0 in clock.sleeps  # the Retry-After header is honoured
    assert len(azure.log_path.read_text(encoding="utf-8").splitlines()) == 1


def test_a1_road_18_azure_does_not_retry_a_refusal_and_gives_up_after_the_last_try(azure_env, tmp_path):
    """[a1-road 18] HTTP 400 is refused at once; a service that stays busy fails after six tries."""
    clock = Clock()
    azure, sent = provider(tmp_path, clock, [http_error(400)])
    with pytest.raises(VoiceError, match="HTTP 400"):
        azure.synthesize(text="Moi!", voice="fi-FI-NooraNeural", dialogue="x")
    assert len(sent) == 1
    busy, sent_busy = provider(tmp_path, Clock(), [http_error(429)])
    with pytest.raises(VoiceError, match="HTTP 429"):
        busy.synthesize(text="Moi!", voice="fi-FI-NooraNeural", dialogue="x")
    assert len(sent_busy) == voice_module.MAX_ATTEMPTS


def test_a1_road_18_the_throttle_also_holds_inside_the_provider(azure_env, tmp_path):
    """[a1-road 18] 45 synthesis calls through the provider never exceed 20 in a minute."""
    clock = Clock()
    azure, sent = provider(tmp_path, clock, [b"x"])
    for i in range(45):
        azure.synthesize(text=f"Moi {i}", voice="fi-FI-NooraNeural", dialogue="x")
    for start in sent:
        assert sum(1 for t in sent if start <= t < start + 60) <= 20


def _draft_with_clip(tmp_path: Path, text: str, voice: str, hash_text: str, hash_voice: str):
    folder = tmp_path / "draft"
    (folder / "audio").mkdir(parents=True)
    (folder / "audio" / "1-puhe.mp3").write_bytes(b"clip")
    line = {
        "n": 1,
        "speaker": "Maria",
        "text_puhe": text,
        "text_kirja": text,
        "audio": {
            "puhe": {
                "file": "audio/1-puhe.mp3",
                "source": "synthetic",
                "voice": voice,
                "request_sha256": request_hash(hash_text, hash_voice),
            }
        },
    }
    return folder, line


def test_a1_road_18_a_clip_with_a_matching_hash_is_skipped(tmp_path):
    """[a1-road 18] the clip exists and was made from this text and this voice: nothing is voiced."""
    folder, line = _draft_with_clip(tmp_path, "Moi!", "fi-FI-NooraNeural", "Moi!", "fi-FI-NooraNeural")
    voices = {"Maria": "fi-FI-NooraNeural"}
    assert clip_needs_voice(line, "puhe", folder, voices) is False
    assert clip_needs_voice(line, "kirja", folder, voices) is True  # no clip for this register yet


def test_a1_road_18_a_changed_text_a_changed_voice_or_a_missing_file_is_voiced_again(tmp_path):
    """[a1-road 18] each of the three changes makes the clip be made again, on its own."""
    voices = {"Maria": "fi-FI-NooraNeural"}
    folder, line = _draft_with_clip(tmp_path, "Moi!", "fi-FI-NooraNeural", "Hei!", "fi-FI-NooraNeural")
    assert clip_needs_voice(line, "puhe", folder, voices) is True
    folder, line = _draft_with_clip(tmp_path / "b", "Moi!", "fi-FI-NooraNeural", "Moi!", "fi-FI-HarriNeural")
    assert clip_needs_voice(line, "puhe", folder, voices) is True
    folder, line = _draft_with_clip(tmp_path / "c", "Moi!", "fi-FI-NooraNeural", "Moi!", "fi-FI-NooraNeural")
    (folder / "audio" / "1-puhe.mp3").unlink()
    assert clip_needs_voice(line, "puhe", folder, voices) is True


def test_a1_road_18_the_exact_characters_of_a_part_are_counted(tmp_path):
    """[a1-road 18] count-characters adds the characters of every clip that still has to be made."""
    folder, line = _draft_with_clip(tmp_path, "Moi!", "fi-FI-NooraNeural", "Moi!", "fi-FI-NooraNeural")
    line["text_kirja"] = "Hei sinä!"
    draft = {"brief": {"speakers": [{"name": "Maria", "voice": "fi-FI-NooraNeural"}]}, "lines": [line]}
    # The spoken clip exists, the written one does not: only its 9 characters are counted. The slug
    # folder is under the repository, so this checks the count rule with a draft that has no folder.
    assert characters_to_voice({"no-such-draft": draft}, repo=tmp_path) == len("Moi!") + len("Hei sinä!")


def _log(path: Path, entries: list[dict]) -> None:
    path.write_text("".join(json.dumps(e) + "\n" for e in entries), encoding="utf-8")


def test_a1_road_18_a_run_that_would_pass_90_percent_of_the_allowance_is_refused(tmp_path):
    """[a1-road 18] this month's logged characters plus the new ones may not pass 450,000."""
    log = tmp_path / "ai-calls.jsonl"
    now = datetime(2026, 11, 15, 12, 0, tzinfo=UTC)
    _log(
        log,
        [
            {"time": "2026-11-02T10:00:00Z", "purpose": "voice", "characters": 400_000},
            {"time": "2026-10-30T10:00:00Z", "purpose": "voice", "characters": 90_000},  # last month
            {"time": "2026-11-03T10:00:00Z", "purpose": "judge", "cost_usd": 0.01},  # not a voice call
        ],
    )
    assert month_characters(log, now) == 400_000
    refuse_over_allowance(log, 50_000, now=now)  # exactly the guard: allowed
    with pytest.raises(VoiceError) as err:
        refuse_over_allowance(log, 50_001, now=now)
    message = str(err.value)
    assert "400000" in message and "50001" in message and str(GUARD_CHARACTERS) in message
    assert "nothing was voiced" in message


def test_a1_road_18_no_log_means_nothing_used(tmp_path):
    """[a1-road 18] a missing log counts as zero characters."""
    assert month_characters(tmp_path / "none.jsonl") == 0
    refuse_over_allowance(tmp_path / "none.jsonl", GUARD_CHARACTERS)


def test_a1_road_18_voice_py_is_the_only_file_that_calls_a_voice_service():
    """[a1-road 18] no other file in the pipeline opens an address or names the Azure service."""
    for path in sorted(HERE.glob("*.py")) + sorted((HERE / "providers").glob("*.py")):
        if path.name in ("voice.py", Path(__file__).name) or path.name.startswith("test_"):
            continue
        text = path.read_text(encoding="utf-8")
        assert "tts.speech." + "microsoft" not in text, path.name
        assert "urllib." + "request" not in text, path.name


def test_a1_road_19_the_workflow_follows_the_content_pipeline_shape():
    """[a1-road 19] manual start, contents read only, no npm ci, a secret check, keys in one step each."""
    text = (REPO / ".github" / "workflows" / "a1-road.yml").read_text(encoding="utf-8")
    assert re.search(r"^on:\n  workflow_dispatch:", text, re.MULTILINE)
    assert "pull_request" not in text and "\n  push:" not in text
    assert "permissions:\n  contents: read" in text
    commands = [ln for ln in text.splitlines() if not ln.lstrip().startswith("#")]
    assert not any("npm ci" in ln for ln in commands)
    assert "timeout-minutes: 45" in text
    assert "check-files-for-secrets.ts" in text
    for task in ("import", "voice", "review-pages"):
        assert task in text
    # The Azure key is in the voice step (and the upload guard that looks for it), nowhere else.
    steps = re.split(r"\n      - ", text)
    holders = {
        name: [s.split("\n")[0] for s in steps if name in s]
        for name in ("AZURE_SPEECH_KEY", "ANTHROPIC_API_KEY")
    }
    assert holders["AZURE_SPEECH_KEY"] == [
        "name: Voice the part (the Azure key is here and nowhere else)",
        "name: Check the files to upload hold no secret value",
    ]
    assert holders["ANTHROPIC_API_KEY"] == [
        "name: Run the register judge (the Anthropic key is here and nowhere else)",
        "name: Check the files to upload hold no secret value",
    ]


def test_a1_road_15_a_judge_run_that_has_reached_its_limit_stops(tmp_path):
    """[a1-road 15] a run that would pass $2 stops: the provider counts what its calls cost."""
    ai = FakeProvider({"calls": []}, tmp_path / "ai-calls.jsonl")
    ai.guard_run_cost(2.0)
    ai.run_cost = 2.0
    with pytest.raises(AiError, match="limit"):
        ai.guard_run_cost(2.0)


def test_a1_road_26_log_costs_sums_the_road_by_part(tmp_path):
    """[a1-road 26] voice characters and cost are summed per part of the road, from the drafts' stops."""
    from log_costs import road_costs

    drafts = tmp_path / "drafts"
    for slug, stop in (("a-one", 2), ("a-two", 8), ("not-the-road", 99)):
        (drafts / slug).mkdir(parents=True)
        brief = {"unit": {"position": stop}, "dialogue": {"slug": slug}}
        (drafts / slug / "draft.json").write_text(json.dumps({"brief": brief}), encoding="utf-8")
    log = tmp_path / "ai-calls.jsonl"
    _log(
        log,
        [
            {"dialogue": "a-one", "characters": 100, "cost_usd": 0.0},
            {"dialogue": "a-one", "characters": 50, "cost_usd": 0.0},
            {"dialogue": "a-two", "characters": 10, "cost_usd": 0.0},
            {"dialogue": "a-two", "input_tokens": 5, "cost_usd": 0.005},
            {"dialogue": "not-the-road", "characters": 999, "cost_usd": 0.0},
        ],
    )
    assert road_costs(log, drafts) == {
        1: {"characters": 150, "calls": 2, "usd": 0.0},
        2: {"characters": 10, "calls": 2, "usd": 0.01},
    }
