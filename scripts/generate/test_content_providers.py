"""The AI and voice provider modules and the cost log (job 7-content-pipeline, [content N]).

Every test here runs offline: the network is switched off in the GitHub check.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest

from providers import ai, voice

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
# Imported unchanged from v2 (docs/v2-imports.md). generate.py imports anthropic
# itself; it is never called by the v3 pipeline.
V2_FILES = {"generate.py", "voikko_gate.py", "allowed_vocab.py", "test_voikko_gate.py"}
PLANTED = "planted-value-for-the-log-test"


def pipeline_python_files() -> list[Path]:
    files = [p for p in (REPO / "scripts").rglob("*.py") if p.name not in V2_FILES or p.parent != HERE]
    assert len(files) > 10
    return files


def test_only_ai_py_imports_anthropic_or_calls_an_ai_address():
    """[content 3] providers/ai.py is the only new file that uses the anthropic package or an AI address."""
    pattern = re.compile(
        r"^\s*(import anthropic|from anthropic)|api\.anthropic\.com|anthropic\.Anthropic", re.M
    )
    users = sorted(
        p.relative_to(REPO).as_posix()
        for p in pipeline_python_files()
        if pattern.search(p.read_text("utf-8"))
    )
    assert users == ["scripts/generate/providers/ai.py"]


def test_only_voice_py_calls_a_voice_service_or_opens_a_network_connection():
    """[content 5] providers/voice.py is the only new file that calls a voice service."""
    pattern = re.compile(
        r"speech\.microsoft\.com|cognitiveservices|urllib\.request|http\.client|import requests|httpx|socket"
    )
    users = sorted(
        p.relative_to(REPO).as_posix()
        for p in pipeline_python_files()
        if pattern.search(p.read_text("utf-8")) and p.name != Path(__file__).name
    )
    assert users == ["scripts/generate/providers/voice.py"]


def test_ai_provider_is_picked_by_one_variable(monkeypatch, tmp_path):
    """[content 3] AI_PROVIDER picks anthropic or fake, nothing else."""
    recording = tmp_path / "r.json"
    recording.write_text('{"calls": []}', encoding="utf-8")
    monkeypatch.setenv("AI_PROVIDER", "fake")
    monkeypatch.setenv("AI_FAKE_RECORDING", str(recording))
    assert ai.get_provider(tmp_path / "log.jsonl").name == "fake"
    monkeypatch.setenv("AI_PROVIDER", "openai")
    with pytest.raises(ai.AiError, match="'anthropic' or 'fake'"):
        ai.get_provider()
    monkeypatch.delenv("AI_PROVIDER")
    with pytest.raises(ai.AiError):
        ai.get_provider()
    monkeypatch.setenv("AI_PROVIDER", "anthropic")
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
    with pytest.raises(ai.AiError, match="ANTHROPIC_API_KEY is not set"):
        ai.get_provider()


def test_fake_provider_replays_in_order_and_refuses_the_wrong_purpose(fake_ai):
    """[content 3] the fake provider replays recorded responses."""
    provider = fake_ai("unit-1-run.json")
    answer = provider.complete_json(purpose="draft", dialogue="d", system="s", prompt="p", schema={})
    assert len(answer["lines"]) == 6
    with pytest.raises(ai.AiError, match="expected a why call, got a judge call"):
        provider.complete_json(purpose="judge", dialogue="d", system="s", prompt="p", schema={})


def test_one_call_writes_exactly_one_log_line_with_the_tables_cost_and_no_key_or_prompt(
    fake_ai, tmp_path, monkeypatch
):
    """[content 4] every AI call is logged with its cost, and the line holds no key and no prompt text."""
    monkeypatch.setenv("ANTHROPIC_API_KEY", PLANTED)
    log = tmp_path / "calls.jsonl"
    provider = fake_ai("unit-1-run.json", log)
    prompt = "PROMPT TEXT Mistä sinä olet kotoisin"
    provider.complete_json(
        purpose="draft",
        dialogue="meeting-people-new-colleague",
        system="SYSTEM TEXT",
        prompt=prompt,
        schema={},
    )
    lines = log.read_text(encoding="utf-8").splitlines()
    assert len(lines) == 1
    entry = json.loads(lines[0])
    assert set(entry) == {
        "time",
        "provider",
        "purpose",
        "model",
        "input_tokens",
        "output_tokens",
        "cost_usd",
        "prices_date",
        "dialogue",
    }
    assert entry["purpose"] == "draft"
    assert entry["model"] == "claude-opus-5-5"
    assert entry["dialogue"] == "meeting-people-new-colleague"
    assert (entry["input_tokens"], entry["output_tokens"]) == (9000, 700)
    price = ai.PRICES_PER_MILLION["claude-opus-5-5"]
    assert entry["cost_usd"] == pytest.approx((9000 * price["input"] + 700 * price["output"]) / 1_000_000)
    assert entry["cost_usd"] == pytest.approx(0.05)
    text = lines[0]
    assert PLANTED not in text and "PROMPT TEXT" not in text and "SYSTEM TEXT" not in text
    assert "Mistä" not in text


def test_judge_calls_use_the_judge_model_and_its_price(fake_ai, tmp_path):
    """[content 4] the cost matches the dated price table per model."""
    log = tmp_path / "calls.jsonl"
    provider = fake_ai(
        {
            "calls": [
                {"purpose": "judge", "output": {"verdicts": []}, "input_tokens": 1000, "output_tokens": 100}
            ]
        },
        log,
    )
    provider.complete_json(purpose="judge", dialogue="d", system="s", prompt="p", schema={})
    entry = json.loads(log.read_text(encoding="utf-8"))
    assert entry["model"] == "claude-sonnet-5-5"
    assert entry["cost_usd"] == pytest.approx((1000 * 2.0 + 100 * 10.0) / 1_000_000)


def test_a_call_whose_answer_cannot_be_used_is_still_logged(fake_ai, tmp_path):
    """[content 4] the log write is inside the module, before the answer is used, so no call skips it."""
    log = tmp_path / "calls.jsonl"
    provider = fake_ai(
        {
            "calls": [
                {"purpose": "why", "output": ["not", "an", "object"], "input_tokens": 10, "output_tokens": 5}
            ]
        },
        log,
    )
    with pytest.raises(ai.AiError, match="not a JSON object"):
        provider.complete_json(purpose="why", dialogue="d", system="s", prompt="p", schema={})
    assert len(log.read_text(encoding="utf-8").splitlines()) == 1


def test_price_table_is_dated_and_cites_the_pricing_page():
    """[content 4] the cost comes from a dated price table that cites Anthropic's pricing page."""
    source = (HERE / "providers" / "ai.py").read_text(encoding="utf-8")
    assert "https://platform.claude.com/docs/en/about-claude/pricing" in source
    assert re.fullmatch(r"\d{4}-\d{2}-\d{2}", ai.PRICES_DATE)
    assert set(ai.MODELS.values()) <= set(ai.PRICES_PER_MILLION)
    with pytest.raises(ai.AiError, match="no price"):
        ai.cost_usd("claude-unknown", 1, 1)


def test_ssml_escapes_markup_ampersands_and_quotes():
    """[content 5] text is XML escaped before it goes into the request."""
    body = voice.ssml("""<b>Tom & "Jerry" 'x'</b>""", "fi-FI-NooraNeural")
    assert "&lt;b&gt;Tom &amp; &quot;Jerry&quot; &apos;x&apos;&lt;/b&gt;" in body
    assert "<b>" not in body
    assert body.startswith("<speak version='1.0' xml:lang='fi-FI'><voice name='fi-FI-NooraNeural'>")


def test_azure_request_uses_the_eu_region_endpoint_the_voice_and_v2s_format(monkeypatch, tmp_path):
    """[content 5] Azure REST in the resource's EU region, with the brief's voice and mp3 24 kHz 48 kbit."""
    monkeypatch.setenv("AZURE_SPEECH_KEY", PLANTED)
    monkeypatch.setenv("AZURE_SPEECH_REGION", "northeurope")
    monkeypatch.setenv("AZURE_SPEECH_TIER", "F0")
    provider = voice.AzureProvider(tmp_path / "log.jsonl")
    request = provider.request("Mä oon Aino.", "fi-FI-SelmaNeural")
    assert request.full_url == "https://northeurope.tts.speech.microsoft.com/cognitiveservices/v1"
    assert request.get_method() == "POST"
    assert request.get_header("X-microsoft-outputformat") == "audio-24khz-48kbitrate-mono-mp3"
    assert request.get_header("Content-type") == "application/ssml+xml"
    assert request.get_header("Ocp-apim-subscription-key") == PLANTED
    assert b"<voice name='fi-FI-SelmaNeural'>M\xc3\xa4 oon Aino.</voice>" in request.data


@pytest.mark.parametrize(
    ("variable", "value", "message"),
    [
        ("AZURE_SPEECH_REGION", "eastus", "EU region"),
        ("AZURE_SPEECH_REGION", "", "EU region"),
        ("AZURE_SPEECH_TIER", "S0", "known price"),
        ("AZURE_SPEECH_KEY", "", "AZURE_SPEECH_KEY is not set"),
    ],
)
def test_azure_refuses_a_region_outside_the_eu_an_unpriced_tier_or_no_key(
    monkeypatch, variable, value, message
):
    """[content 5] only EU regions, and no synthesis at a guessed price."""
    monkeypatch.setenv("AZURE_SPEECH_KEY", PLANTED)
    monkeypatch.setenv("AZURE_SPEECH_REGION", "northeurope")
    monkeypatch.setenv("AZURE_SPEECH_TIER", "F0")
    monkeypatch.setenv(variable, value)
    with pytest.raises(voice.VoiceError, match=message):
        voice.AzureProvider()


def test_voice_provider_is_picked_by_one_variable(monkeypatch):
    """[content 5] VOICE_PROVIDER picks azure or fake."""
    monkeypatch.setenv("VOICE_PROVIDER", "fake")
    assert voice.get_provider().name == "fake"
    monkeypatch.setenv("VOICE_PROVIDER", "google")
    with pytest.raises(voice.VoiceError):
        voice.get_provider()


def test_each_synthesis_is_logged_with_characters_and_cost(fake_voice, tmp_path):
    """[content 5] each synthesis is logged in the same log with its character count and cost."""
    audio = fake_voice.synthesize(
        text="Mä oon Aino.", voice="fi-FI-NooraNeural", dialogue="meeting-people-new-colleague"
    )
    assert audio.startswith(b"ID3")
    entry = json.loads((tmp_path / "ai-calls.jsonl").read_text(encoding="utf-8"))
    assert entry["purpose"] == "voice"
    assert entry["characters"] == len("Mä oon Aino.")
    assert entry["cost_usd"] == 0.0
    assert entry["dialogue"] == "meeting-people-new-colleague"
    with pytest.raises(voice.VoiceError, match="not one of"):
        fake_voice.synthesize(text="Hei", voice="en-US-JennyNeural", dialogue="d")
