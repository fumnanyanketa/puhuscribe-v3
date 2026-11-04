"""Aleksi's greeting on the intro screen (fast route aleksi-intro, owner approved 4 November 2026).

The app's Finnish voice, Selma, is female. Aleksi is a man, so his one greeting is read by Azure's male
Finnish voice, Harri. It is one short clip, made once, the way the road's clips are made: through
providers/voice.py, from the A1 road workflow (task voice-aleksi), where the Azure key lives.

python scripts/generate/aleksi_greeting.py voice-aleksi [--out <folder>]
    Harri reads GREETING into <folder>/<clip name> (default public/audio/aleksi/). A clip that exists is
    kept. The voice log's two guards (an uncommitted log, the monthly allowance) are voice.py's own.

The clip's name holds the first 12 characters of voice.py's request_hash(text, voice), so a changed text
gets a new name and no phone plays an old copy. src/lib/aleksi-greeting.ts names the same file.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from providers.voice import request_hash

REPO = Path(__file__).resolve().parents[2]
PUBLIC_AUDIO = REPO / "public" / "audio" / "aleksi"
GREETING = "Moi! Mä oon Aleksi."
GREETING_VOICE = "fi-FI-HarriNeural"
# voice.py's fake provider writes this marker into every clip it makes. A fake clip never reaches public/.
FAKE_MARKER = b"puhuscribe-fake-voice\x00"


def clip_name(text: str = GREETING, voice: str = GREETING_VOICE) -> str:
    return f"greeting-{request_hash(text, voice)[:12]}.mp3"


def cmd_voice(args, voice=None) -> int:
    from providers import voice as voice_module

    folder = Path(args.out) if getattr(args, "out", None) else PUBLIC_AUDIO
    target = folder / clip_name()
    if target.is_file() and target.stat().st_size > 0:
        print(f"The greeting clip exists already: {target.name}. Nothing was voiced.")
        return 0
    voice = voice or voice_module.get_provider()
    voice_module.refuse_uncommitted_log(voice.log_path)
    voice_module.refuse_over_allowance(voice.log_path, len(GREETING))
    audio = voice.synthesize(text=GREETING, voice=GREETING_VOICE, dialogue="aleksi-greeting")
    if folder == PUBLIC_AUDIO and FAKE_MARKER in audio[:512]:
        print("The fake voice provider made this clip, so it was not written to public/audio/.")
        return 1
    folder.mkdir(parents=True, exist_ok=True)
    part = folder / f"{target.name}.part"
    part.write_bytes(audio)
    part.replace(target)
    print(f"Made {target.name}: {len(GREETING)} characters ({GREETING_VOICE}).")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command", required=True)
    voice_cmd = sub.add_parser("voice-aleksi", help="Harri reads Aleksi's greeting")
    voice_cmd.add_argument("--out", help="the folder for the clip (default public/audio/aleksi/)")
    args = parser.parse_args(argv)
    return cmd_voice(args)


if __name__ == "__main__":
    sys.exit(main())
