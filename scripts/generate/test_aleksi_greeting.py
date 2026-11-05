"""Aleksi's greeting clip (fast route aleksi-intro, item 3). Labels [aleksi-intro 3]. No network: the fake
voice provider stands in for Azure."""

from __future__ import annotations

import json
import types

import pytest

import aleksi_greeting
from providers.voice import FakeProvider, request_hash


def test_greeting_is_harri_reading_the_approved_line(tmp_path):
    """[aleksi-intro 3] the male voice reads exactly the greeting, and the clip name follows the text."""
    assert aleksi_greeting.GREETING == "Moi! Mä oon Aleksi."
    assert aleksi_greeting.GREETING_VOICE == "fi-FI-HarriNeural"
    assert (
        aleksi_greeting.clip_name()
        == f"greeting-{request_hash('Moi! Mä oon Aleksi.', 'fi-FI-HarriNeural')[:12]}.mp3"
    )


def test_voice_writes_one_clip_and_logs_it(tmp_path):
    """[aleksi-intro 3] [aleksi-journey 1] one clip per line (greeting, written greeting and journey),
    one log line each with the voice name, and a second run voices nothing. Changed requirement: Aleksi
    has three lines now."""
    log = tmp_path / "ai-calls.jsonl"
    out = tmp_path / "audio"
    args = types.SimpleNamespace(out=str(out))
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(log)) == 0
    for text, prefix in aleksi_greeting.LINES:
        clip = out / aleksi_greeting.clip_name(text, prefix=prefix)
        assert clip.is_file() and clip.stat().st_size > 0
    assert aleksi_greeting.clip_name() == aleksi_greeting.clip_name(
        aleksi_greeting.GREETING, prefix="greeting"
    )
    lines = [json.loads(line) for line in log.read_text(encoding="utf-8").splitlines()]
    assert [(line["model"], line["characters"]) for line in lines] == [
        ("fi-FI-HarriNeural", 19),
        ("fi-FI-HarriNeural", 22),
        ("fi-FI-HarriNeural", 30),
    ]
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(log)) == 0
    assert len(log.read_text(encoding="utf-8").splitlines()) == 3


def test_fake_clip_never_reaches_public_audio(tmp_path, monkeypatch):
    """[aleksi-intro 3] a clip from the fake provider is refused for public/audio/."""
    public = tmp_path / "public"
    monkeypatch.setattr(aleksi_greeting, "PUBLIC_AUDIO", public)
    args = types.SimpleNamespace(out=None)
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(tmp_path / "log.jsonl")) == 1
    assert not public.exists()


def test_samples_make_each_voice_with_its_settings_and_skip_voices_without_finnish(tmp_path):
    """[aleksi-intro 3] the owner's voice samples: Harri three ways, the multilingual voices that list
    fi-FI, one more found in the list, and a skip line for a voice without Finnish."""

    class Listing(FakeProvider):
        def list_voices(self):
            voices = super().list_voices()
            voices[2] = {
                "ShortName": "de-DE-FlorianMultilingualNeural",
                "Gender": "Male",
                "SecondaryLocaleList": [],
            }
            return voices

    log = tmp_path / "ai-calls.jsonl"
    out = tmp_path / "samples"
    assert aleksi_greeting.cmd_samples(types.SimpleNamespace(out=str(out)), voice=Listing(log)) == 0
    names = sorted(p.name for p in out.glob("*.mp3"))
    assert names == [
        "1-harri.mp3",
        "2-harri-warmer.mp3",
        "3-harri-brighter.mp3",
        "4-andrew.mp3",
        "5-brian.mp3",
        "6-remy.mp3",
    ]
    report = (out / "samples.txt").read_text(encoding="utf-8")
    assert "2-harri-warmer.mp3: fi-FI-HarriNeural, rate -8%, pitch -4%, 19 characters" in report
    assert "3-harri-brighter.mp3: fi-FI-HarriNeural, rate -3%, pitch +6%, 19 characters" in report
    assert "skipped de-DE-FlorianMultilingualNeural: its locales do not include fi-FI" in report
    lines = [json.loads(line) for line in log.read_text(encoding="utf-8").splitlines()]
    assert len(lines) == 6 and all(line["characters"] == 19 for line in lines)


def test_ssml_for_prosody_and_a_multilingual_voice():
    """[aleksi-intro 3] prosody wraps the text, a multilingual voice reads fi-FI, plain Harri is unchanged."""
    from providers import voice as voice_module

    plain = voice_module.ssml("Moi!", "fi-FI-HarriNeural")
    assert (
        plain == "<speak version='1.0' xml:lang='fi-FI'><voice name='fi-FI-HarriNeural'>Moi!</voice></speak>"
    )
    warm = voice_module.ssml("Moi!", "fi-FI-HarriNeural", "-8%", "-4%")
    assert "<prosody rate='-8%' pitch='-4%'>Moi!</prosody>" in warm
    andrew = voice_module.ssml("Moi!", "en-US-AndrewMultilingualNeural")
    assert "<lang xml:lang='fi-FI'>Moi!</lang>" in andrew
    with pytest.raises(voice_module.VoiceError, match="signed whole percent"):
        voice_module.ssml("Moi!", "fi-FI-HarriNeural", "slow'><x", None)
