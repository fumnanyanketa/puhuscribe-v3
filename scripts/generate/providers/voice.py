"""The one voice module of the content pipeline (job 7-content-pipeline, "Done when" 5).

This is the only file in the pipeline that calls a voice service. VOICE_PROVIDER
picks the provider:

- `azure`: Azure neural text to speech through its REST endpoint in the
  resource's EU region (AZURE_SPEECH_REGION), with the key in AZURE_SPEECH_KEY
  and the price tier in AZURE_SPEECH_TIER. Output format
  audio-24khz-48kbitrate-mono-mp3, v2's working setting. The text is XML escaped
  before it goes into the request.
- `fake`: returns a short silent MP3 that names the text it stands for, so tests
  run offline. The publish step refuses fake audio.

Each synthesis appends one line to the same log as the AI calls
(content/logs/ai-calls.jsonl) with its character count and cost. The log never
holds the key.
"""

from __future__ import annotations

import hashlib
import json
import os
import urllib.error
import urllib.request
from datetime import UTC, datetime
from pathlib import Path
from xml.sax.saxutils import escape

REPO = Path(__file__).resolve().parents[3]
DEFAULT_LOG = REPO / "content" / "logs" / "ai-calls.jsonl"

OUTPUT_FORMAT = "audio-24khz-48kbitrate-mono-mp3"
VOICES = frozenset({"fi-FI-NooraNeural", "fi-FI-HarriNeural", "fi-FI-SelmaNeural"})

# Azure regions inside the EU that offer neural voices. Learner data and voice
# work stay in the EU (AGENTS.md).
EU_REGIONS = frozenset(
    {
        "northeurope",
        "westeurope",
        "swedencentral",
        "francecentral",
        "germanywestcentral",
        "italynorth",
        "polandcentral",
    }
)

# US dollars per character, per Azure Speech price tier. Source: Azure Speech
# pricing page, https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/,
# read 21 October 2026. F0 is the free tier (0.5 million characters a month).
# The paid tier's price could not be read from the page, so it is not in the
# table: a tier without a price is refused instead of logged at a guessed cost.
PRICES_DATE = "2026-10-21"
PRICE_PER_CHARACTER = {"F0": 0.0}

TIMEOUT_SECONDS = 60


class VoiceError(RuntimeError):
    """A synthesis failed. The message never holds the key."""


def ssml(text: str, voice: str) -> str:
    """The request body. Text and voice name are XML escaped, quotes included."""
    quotes = {'"': "&quot;", "'": "&apos;"}
    return (
        "<speak version='1.0' xml:lang='fi-FI'>"
        f"<voice name='{escape(voice, quotes)}'>{escape(text, quotes)}</voice>"
        "</speak>"
    )


class _Provider:
    name = ""
    tier = ""

    def __init__(self, log_path: Path | str | None = None) -> None:
        self.log_path = Path(log_path) if log_path else DEFAULT_LOG

    def synthesize(self, *, text: str, voice: str, dialogue: str) -> bytes:
        if voice not in VOICES:
            raise VoiceError(f"voice '{voice}' is not one of {', '.join(sorted(VOICES))}")
        if not text.strip():
            raise VoiceError("there is no text to read")
        audio = self._synthesize(text, voice)
        self._log(len(text), voice, dialogue)
        return audio

    def _log(self, characters: int, voice: str, dialogue: str) -> None:
        line = {
            "time": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "provider": self.name,
            "purpose": "voice",
            "model": voice,
            "characters": characters,
            "cost_usd": round(characters * PRICE_PER_CHARACTER.get(self.tier, 0.0), 6),
            "price_tier": self.tier,
            "prices_date": PRICES_DATE,
            "dialogue": dialogue,
        }
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.log_path, "a", encoding="utf-8", newline="\n") as fh:
            fh.write(json.dumps(line, ensure_ascii=False) + "\n")

    def _synthesize(self, text: str, voice: str) -> bytes:
        raise NotImplementedError


class AzureProvider(_Provider):
    name = "azure"

    def __init__(self, log_path: Path | str | None = None) -> None:
        super().__init__(log_path)
        self._key = os.environ.get("AZURE_SPEECH_KEY", "").strip()
        region = os.environ.get("AZURE_SPEECH_REGION", "").strip()
        tier = os.environ.get("AZURE_SPEECH_TIER", "").strip()
        if not self._key:
            raise VoiceError("AZURE_SPEECH_KEY is not set, so the azure provider cannot run")
        if region not in EU_REGIONS:
            raise VoiceError(
                f"AZURE_SPEECH_REGION must be an EU region: one of {', '.join(sorted(EU_REGIONS))}"
            )
        if tier not in PRICE_PER_CHARACTER:
            raise VoiceError(
                f"AZURE_SPEECH_TIER must be a tier with a known price ({', '.join(PRICE_PER_CHARACTER)}); "
                "add the tier's price to voice.py first"
            )
        self.tier = tier
        self.url = f"https://{region}.tts.speech.microsoft.com/cognitiveservices/v1"

    def request(self, text: str, voice: str) -> urllib.request.Request:
        return urllib.request.Request(
            self.url,
            data=ssml(text, voice).encode("utf-8"),
            method="POST",
            headers={
                "Ocp-Apim-Subscription-Key": self._key,
                "Content-Type": "application/ssml+xml",
                "X-Microsoft-OutputFormat": OUTPUT_FORMAT,
                "User-Agent": "puhuscribe-content-pipeline",
            },
        )

    def _synthesize(self, text: str, voice: str) -> bytes:
        try:
            with urllib.request.urlopen(self.request(text, voice), timeout=TIMEOUT_SECONDS) as response:
                audio = response.read()
        except urllib.error.HTTPError as err:
            raise VoiceError(f"Azure refused the synthesis (HTTP {err.code})") from None
        except urllib.error.URLError as err:
            raise VoiceError(f"could not reach Azure ({err.reason})") from None
        if not audio:
            raise VoiceError("Azure returned no audio")
        return audio


# One silent MPEG-2 Layer III frame at 24 kHz, 48 kbit/s, mono: the same format
# as Azure's output. 72 * 48000 / 24000 = 144 bytes, header included.
_SILENT_FRAME = bytes([0xFF, 0xF3, 0x64, 0xC0]) + bytes(140)


def fake_mp3(text: str, voice: str) -> bytes:
    """Half a second of silence, with an ID3 tag that names the text it stands for."""
    owner = b"puhuscribe-fake-voice\x00"
    payload = owner + hashlib.sha256(f"{voice}\n{text}".encode()).digest()
    frame = b"PRIV" + len(payload).to_bytes(4, "big") + b"\x00\x00" + payload
    size = len(frame)
    syncsafe = bytes([(size >> 21) & 0x7F, (size >> 14) & 0x7F, (size >> 7) & 0x7F, size & 0x7F])
    return b"ID3\x03\x00\x00" + syncsafe + frame + _SILENT_FRAME * 20


class FakeProvider(_Provider):
    name = "fake"
    tier = "F0"

    def _synthesize(self, text: str, voice: str) -> bytes:
        return fake_mp3(text, voice)


def get_provider(log_path: Path | str | None = None) -> _Provider:
    choice = os.environ.get("VOICE_PROVIDER", "")
    if choice == "azure":
        return AzureProvider(log_path)
    if choice == "fake":
        return FakeProvider(log_path)
    raise VoiceError("VOICE_PROVIDER must be 'azure' or 'fake'")
