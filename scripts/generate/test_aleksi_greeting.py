"""Aleksi's greeting clip (fast route aleksi-intro, item 3). Labels [aleksi-intro 3]. No network: the fake
voice provider stands in for Azure."""

from __future__ import annotations

import json
import types

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
    """[aleksi-intro 3] one clip, one log line with the voice name, and a second run voices nothing."""
    log = tmp_path / "ai-calls.jsonl"
    out = tmp_path / "audio"
    args = types.SimpleNamespace(out=str(out))
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(log)) == 0
    clip = out / aleksi_greeting.clip_name()
    assert clip.is_file() and clip.stat().st_size > 0
    lines = [json.loads(line) for line in log.read_text(encoding="utf-8").splitlines()]
    assert [(line["model"], line["characters"]) for line in lines] == [("fi-FI-HarriNeural", 19)]
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(log)) == 0
    assert len(log.read_text(encoding="utf-8").splitlines()) == 1


def test_fake_clip_never_reaches_public_audio(tmp_path, monkeypatch):
    """[aleksi-intro 3] a clip from the fake provider is refused for public/audio/."""
    public = tmp_path / "public"
    monkeypatch.setattr(aleksi_greeting, "PUBLIC_AUDIO", public)
    args = types.SimpleNamespace(out=None)
    assert aleksi_greeting.cmd_voice(args, voice=FakeProvider(tmp_path / "log.jsonl")) == 1
    assert not public.exists()
