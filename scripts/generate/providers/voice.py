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
import subprocess
import time
import urllib.error
import urllib.request
from collections import deque
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

# Job 20-a1-road, statements 18 and 19. Azure's free tier allows 20 requests in any 60 seconds
# (Azure Speech quotas page, read 1 November 2026) and 500,000 characters a month. A run refuses to
# start when this month's logged characters plus its own would pass 90 percent of the allowance.
MAX_REQUESTS = 20
WINDOW_SECONDS = 60.0
MAX_ATTEMPTS = 6
# A wait asked for by Azure (Retry-After) is never longer than this, so a huge value cannot stall a run.
MAX_RETRY_WAIT_SECONDS = 60.0
FREE_ALLOWANCE_CHARACTERS = 500_000
GUARD_CHARACTERS = 450_000


class VoiceError(RuntimeError):
    """A synthesis failed. The message never holds the key."""


def request_hash(text: str, voice: str) -> str:
    """A hash of what a clip was made from, so a clip that already exists is not made again."""
    return hashlib.sha256(f"{voice}\n{text}".encode()).hexdigest()


class Throttle:
    """At most `limit` requests in any `window` seconds. The clock and the sleep can be replaced in tests."""

    def __init__(self, limit: int = MAX_REQUESTS, window: float = WINDOW_SECONDS, clock=None, sleep=None):
        self.limit = limit
        self.window = window
        self.clock = clock or time.monotonic
        self.sleep = sleep or time.sleep
        self._stamps: deque[float] = deque()

    def wait(self) -> None:
        """Returns when one more request may be sent, and counts it."""
        while True:
            now = self.clock()
            while self._stamps and now - self._stamps[0] >= self.window:
                self._stamps.popleft()
            if len(self._stamps) < self.limit:
                self._stamps.append(now)
                return
            self.sleep(self._stamps[0] + self.window - now)


def month_characters(log_path: Path | str, now: datetime | None = None) -> int:
    """The characters of every voice call logged this month (UTC), from the shared log."""
    now = now or datetime.now(UTC)
    prefix = now.strftime("%Y-%m")
    path = Path(log_path)
    if not path.is_file():
        return 0
    total = 0
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw.strip():
            continue
        entry = json.loads(raw)
        if entry.get("purpose") == "voice" and str(entry.get("time", "")).startswith(prefix):
            total += int(entry.get("characters", 0))
    return total


def refuse_uncommitted_log(log_path: Path | str, run=subprocess.run) -> None:
    """Refuse to voice when the voice log in the working tree has changes git does not hold.

    The month's characters are read from the log, and a run on a fresh checkout only sees the committed
    log. Characters from a run whose log was not committed yet would be forgotten, and the guard could
    be passed by repeated runs. The manager commits the log after every voice run and before the next.
    Outside a git working tree (a temporary folder in a test) there is nothing to compare, so the
    check does nothing there."""
    path = Path(log_path)
    try:
        result = run(
            ["git", "status", "--porcelain", "--", path.name],
            cwd=path.parent,
            capture_output=True,
            text=True,
            check=False,
        )
    except (FileNotFoundError, NotADirectoryError):
        return
    if result.returncode != 0:
        return
    if result.stdout.strip():
        raise VoiceError(
            f"the voice log {path.name} has changes that are not committed ({result.stdout.strip()[:2]}): "
            "commit the log after every voice run and before the next one, so this month's characters are "
            "counted. Nothing was voiced"
        )


def refuse_over_allowance(
    log_path: Path | str, new_characters: int, limit: int = GUARD_CHARACTERS, now: datetime | None = None
) -> None:
    """Refuse a run whose characters, with this month's logged ones, would pass the guard."""
    used = month_characters(log_path, now)
    if used + new_characters > limit:
        raise VoiceError(
            f"this month's voice calls used {used} characters and this run needs {new_characters}: "
            f"together that is over {limit} (90 percent of the free allowance of "
            f"{FREE_ALLOWANCE_CHARACTERS}), "
            "so nothing was voiced"
        )


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

    @staticmethod
    def request_hash(text: str, voice: str) -> str:
        return request_hash(text, voice)

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

    def __init__(self, log_path: Path | str | None = None, *, opener=None, clock=None, sleep=None) -> None:
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
        self._open = opener or urllib.request.urlopen
        self._sleep = sleep or time.sleep
        self.throttle = Throttle(clock=clock, sleep=self._sleep)

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
        """At most 20 requests a minute. A busy answer (HTTP 429) or a server error waits and tries again."""
        wait = 2.0
        for attempt in range(1, MAX_ATTEMPTS + 1):
            self.throttle.wait()
            try:
                with self._open(self.request(text, voice), timeout=TIMEOUT_SECONDS) as response:
                    audio = response.read()
            except urllib.error.HTTPError as err:
                busy = err.code == 429 or err.code >= 500
                if not busy or attempt == MAX_ATTEMPTS:
                    raise VoiceError(f"Azure refused the synthesis (HTTP {err.code})") from None
                header = err.headers.get("Retry-After") if err.headers else None
                asked = float(header) if header and header.isdigit() else wait
                self._sleep(min(asked, MAX_RETRY_WAIT_SECONDS))
                wait = min(wait * 2, MAX_RETRY_WAIT_SECONDS)
                continue
            except urllib.error.URLError as err:
                raise VoiceError(f"could not reach Azure ({err.reason})") from None
            if not audio:
                raise VoiceError("Azure returned no audio")
            return audio
        raise VoiceError("Azure did not answer")


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
