"""Audio for both registers of every line (job 7-content-pipeline, "Done when" 5 and 6).

Each line gets two clips: the spoken text read aloud (puhe) and the written text
(kirja), in the speaker's voice from the brief, through providers/voice.py.

A native recording replaces the synthetic clip for one line and register when
an mp3 exists at content/recordings/<dialogue-slug>/<line>-<register>.mp3. The
review page then marks that clip "native recording".
"""

from __future__ import annotations

from pathlib import Path

from fingerprints import sha256_bytes

REPO = Path(__file__).resolve().parents[2]
RECORDINGS = REPO / "content" / "recordings"
REGISTERS = ("puhe", "kirja")


def recording_path(recordings: Path, slug: str, line: int, register: str) -> Path:
    return recordings / slug / f"{line}-{register}.mp3"


def make_audio(
    draft: dict,
    draft_dir: Path,
    voice,
    recordings: Path = RECORDINGS,
    only: set[tuple[int, str]] | None = None,
    log=print,
) -> None:
    """Write audio/<line>-<register>.mp3 under draft_dir and record it on each line.
    `only` limits it to some (line, register) clips; the others are left as they are."""
    slug = draft["brief"]["dialogue"]["slug"]
    voices = {s["name"]: s["voice"] for s in draft["brief"]["speakers"]}
    audio_dir = draft_dir / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)
    for line in draft["lines"]:
        audio = line.setdefault("audio", {})
        for register in REGISTERS:
            if only is not None and (line["n"], register) not in only:
                continue
            text = line[f"text_{register}"]
            native = recording_path(recordings, slug, line["n"], register)
            if native.is_file():
                data = native.read_bytes()
                entry = {"source": "native recording", "provider": None, "voice": None}
                log(f"Line {line['n']} {register}: native recording")
            else:
                voice_name = voices[line["speaker"]]
                data = voice.synthesize(text=text, voice=voice_name, dialogue=slug)
                entry = {"source": "synthetic", "provider": voice.name, "voice": voice_name}
            target = audio_dir / f"{line['n']}-{register}.mp3"
            target.write_bytes(data)
            audio[register] = {
                "file": f"audio/{target.name}",
                "sha256": sha256_bytes(data),
                "text": text,
                **entry,
            }
