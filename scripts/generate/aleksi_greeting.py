"""Aleksi's greeting on the intro screen (fast route aleksi-intro, owner approved 4 November 2026).

The app's Finnish voice, Selma, is female. Aleksi is a man, so his one greeting is read by Azure's male
Finnish voice, Harri. It is one short clip, made once, the way the road's clips are made: through
providers/voice.py, from the A1 road workflow (task voice-aleksi), where the Azure key lives.

python scripts/generate/aleksi_greeting.py voice-aleksi [--out <folder>]
    Harri reads GREETING into <folder>/<clip name> (default public/audio/aleksi/). A clip that exists is
    kept. The voice log's two guards (an uncommitted log, the monthly allowance) are voice.py's own.

python scripts/generate/aleksi_greeting.py samples --out <folder>
    Voice samples of GREETING for the owner to choose from (owner, 4 November 2026: "Change the
    voice"): Harri as he is, Harri slower and warmer, Harri brighter, and Azure's male multilingual
    voices reading Finnish. The voice list (free) says which multilingual voices speak fi-FI; any that do
    not are skipped. The clips go to <folder> with samples.txt, which names each voice, its settings and
    its characters. Samples never go to public/.

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
# His second line, when the road opens in the new intro (owner, 5 November 2026). A draft for the native
# reviewer; the clip is made so the owner can hear the intro prototype.
JOURNEY = "Ja mä vien sut tälle matkalle."
GREETING_VOICE = "fi-FI-HarriNeural"
# Each line Aleksi says, with the start of its clip name. He says the spoken form only (owner, 5 November
# 2026, fast route intro-logo): "Moi! Minä olen Aleksi." is shown in the intro as the written form, never
# said, so its clip was removed.
LINES = [(GREETING, "greeting"), (JOURNEY, "journey")]
# voice.py's fake provider writes this marker into every clip it makes. A fake clip never reaches public/.
FAKE_MARKER = b"puhuscribe-fake-voice\x00"


def clip_name(text: str = GREETING, voice: str = GREETING_VOICE, prefix: str = "greeting") -> str:
    return f"{prefix}-{request_hash(text, voice)[:12]}.mp3"


def cmd_voice(args, voice=None) -> int:
    from providers import voice as voice_module

    folder = Path(args.out) if getattr(args, "out", None) else PUBLIC_AUDIO
    missing = [
        (text, folder / clip_name(text, prefix=prefix))
        for text, prefix in LINES
        if not (
            (folder / clip_name(text, prefix=prefix)).is_file()
            and (folder / clip_name(text, prefix=prefix)).stat().st_size > 0
        )
    ]
    if not missing:
        print("Every Aleksi clip exists already. Nothing was voiced.")
        return 0
    voice = voice or voice_module.get_provider()
    voice_module.refuse_uncommitted_log(voice.log_path)
    voice_module.refuse_over_allowance(voice.log_path, sum(len(text) for text, _ in missing))
    for text, target in missing:
        audio = voice.synthesize(text=text, voice=GREETING_VOICE, dialogue="aleksi-greeting")
        if folder == PUBLIC_AUDIO and FAKE_MARKER in audio[:512]:
            print("The fake voice provider made this clip, so it was not written to public/audio/.")
            return 1
        folder.mkdir(parents=True, exist_ok=True)
        part = folder / f"{target.name}.part"
        part.write_bytes(audio)
        part.replace(target)
        print(f"Made {target.name}: {len(text)} characters ({GREETING_VOICE}).")
    return 0


# The owner's samples: (file name, voice, rate, pitch). Harri's settings are the manager's brief.
HARRI_SAMPLES = [
    ("1-harri", GREETING_VOICE, None, None),
    ("2-harri-warmer", GREETING_VOICE, "-8%", "-4%"),
    ("3-harri-brighter", GREETING_VOICE, "-3%", "+6%"),
]
NAMED_MULTILINGUAL = [
    ("4-andrew", "en-US-AndrewMultilingualNeural"),
    ("5-brian", "en-US-BrianMultilingualNeural"),
    ("6-florian", "de-DE-FlorianMultilingualNeural"),
]


def speaks_finnish(entry: dict) -> bool:
    locales = entry.get("SecondaryLocaleList") or []
    return entry.get("Locale") == "fi-FI" or "fi-FI" in locales


def plan_samples(voices: list[dict]) -> tuple[list[tuple[str, str, str | None, str | None]], list[str]]:
    """The samples to make, and a line for each multilingual voice that was skipped or found."""
    by_name = {str(v.get("ShortName", "")): v for v in voices}
    plan: list[tuple[str, str, str | None, str | None]] = list(HARRI_SAMPLES)
    notes: list[str] = []
    for name, voice in NAMED_MULTILINGUAL:
        entry = by_name.get(voice)
        if entry is None:
            notes.append(f"skipped {voice}: not in the region's voice list")
        elif not speaks_finnish(entry):
            notes.append(f"skipped {voice}: its locales do not include fi-FI")
        else:
            plan.append((name, voice, None, None))
    named = {voice for _, voice in NAMED_MULTILINGUAL}
    others = sorted(
        name
        for name, entry in by_name.items()
        if "Multilingual" in name
        and entry.get("Gender") == "Male"
        and speaks_finnish(entry)
        and name not in named
    )
    notes.append(f"other male multilingual voices that list fi-FI: {', '.join(others) or 'none'}")
    if others:
        extra = others[0]
        short = extra.split("-")[2].replace("MultilingualNeural", "").lower()
        plan.append((f"{len(plan) + 1}-{short}", extra, None, None))
    return plan, notes


def cmd_samples(args, voice=None) -> int:
    from providers import voice as voice_module

    folder = Path(args.out)
    voice = voice or voice_module.get_provider()
    plan, notes = plan_samples(voice.list_voices())
    need = len(GREETING) * len(plan)
    voice_module.refuse_uncommitted_log(voice.log_path)
    voice_module.refuse_over_allowance(voice.log_path, need)
    folder.mkdir(parents=True, exist_ok=True)
    lines = [f'Voice samples of "{GREETING}", {len(GREETING)} characters each, {need} in all.']
    for name, speaker, rate, pitch in plan:
        audio = voice.synthesize(
            text=GREETING, voice=speaker, dialogue="aleksi-voice-sample", rate=rate, pitch=pitch
        )
        (folder / f"{name}.mp3").write_bytes(audio)
        settings = ", ".join(f"{k} {v}" for k, v in (("rate", rate), ("pitch", pitch)) if v) or "as is"
        multilingual = voice_module.MULTILINGUAL_VOICE.match(speaker)
        lingual = " (Finnish through <lang xml:lang='fi-FI'>)" if multilingual else ""
        lines.append(f"{name}.mp3: {speaker}, {settings}{lingual}, {len(GREETING)} characters")
    lines.extend(notes)
    report = "\n".join(lines) + "\n"
    (folder / "samples.txt").write_text(report, encoding="utf-8")
    print(report, end="")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command", required=True)
    voice_cmd = sub.add_parser("voice-aleksi", help="Harri reads Aleksi's greeting")
    voice_cmd.add_argument("--out", help="the folder for the clip (default public/audio/aleksi/)")
    samples_cmd = sub.add_parser("samples", help="voice samples of the greeting for the owner")
    samples_cmd.add_argument("--out", required=True, help="the folder for the samples (never public/)")
    args = parser.parse_args(argv)
    if args.command == "samples":
        if Path(args.out).resolve().is_relative_to((REPO / "public").resolve()):
            parser.error("samples never go to public/")
        return cmd_samples(args)
    return cmd_voice(args)


if __name__ == "__main__":
    sys.exit(main())
