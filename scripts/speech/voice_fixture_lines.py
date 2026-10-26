"""Voices the speech fixture lines with Azure text to speech (job 10-speaking-feedback, "Done when" 23).

Run only by the manual workflow "Speech fixtures" (.github/workflows/speech-fixtures.yml):

    python scripts/speech/voice_fixture_lines.py <out folder>

For every recorded fixture in worker/providers/fixtures/speech/recorded-*.json it
reads the line the fixture is for ("reference") and writes <name>.mp3 into the
out folder. The voice comes from the content pipeline's one voice module
(scripts/generate/providers/voice.py), so this file calls no service itself and
every synthesis is logged with its cost in content/logs/ai-calls.jsonl. The
clips are computer voices, never a human voice.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "scripts" / "generate"))

from providers.voice import VoiceError, get_provider  # noqa: E402

FIXTURES = REPO / "worker" / "providers" / "fixtures" / "speech"
VOICE = "fi-FI-NooraNeural"


def main(out: Path) -> int:
    out.mkdir(parents=True, exist_ok=True)
    provider = get_provider()
    names = sorted(FIXTURES.glob("recorded-*.json"))
    if not names:
        print("No recorded fixtures are listed.")
        return 1
    for path in names:
        line = json.loads(path.read_text(encoding="utf-8")).get("reference", "")
        if not isinstance(line, str) or not line.strip():
            print(f"{path.name} names no line to voice.")
            return 1
        audio = provider.synthesize(text=line, voice=VOICE, dialogue="speech-fixtures")
        (out / f"{path.stem}.mp3").write_bytes(audio)
        print(f"Voiced {path.stem}.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python scripts/speech/voice_fixture_lines.py <out folder>")
        sys.exit(1)
    try:
        sys.exit(main(Path(sys.argv[1])))
    except VoiceError as err:
        print(f"Voicing failed: {err}")
        sys.exit(1)
