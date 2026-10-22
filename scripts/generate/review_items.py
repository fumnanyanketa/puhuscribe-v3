"""The items a native reviewer approves (job 7-content-pipeline, "Done when" 13 to 15).

Every line, every form, every audio clip and the dialogue as a whole is one
item with an id and a content fingerprint. A review file approves an item only
for the fingerprint the reviewer saw.
"""

from __future__ import annotations

from fingerprints import audio_fingerprint, fingerprint, form_fingerprint, line_fingerprint

REGISTERS = ("puhe", "kirja")


def line_item_id(n: int) -> str:
    return f"line-{n}"


def audio_item_id(n: int, register: str) -> str:
    return f"audio-{n}-{register}"


DIALOGUE_ITEM = "dialogue"


def clip_path(n: int, register: str) -> str:
    """The only place a clip may live inside a draft folder. Paths in draft.json are
    never trusted beyond this, so no edited path can read or write another file."""
    return f"audio/{n}-{register}.mp3"


def all_items(draft: dict) -> dict[str, dict]:
    """Every item of the current draft: id to {kind, fingerprint, ...}. Ordered for display."""
    items: dict[str, dict] = {}
    for line in draft["lines"]:
        items[line_item_id(line["n"])] = {
            "kind": "line",
            "line": line["n"],
            "fingerprint": line_fingerprint(line),
        }
    for line in draft["lines"]:
        for register in REGISTERS:
            audio = line.get("audio", {}).get(register)
            if audio is None:
                continue
            items[audio_item_id(line["n"], register)] = {
                "kind": "audio",
                "line": line["n"],
                "register": register,
                "fingerprint": audio_fingerprint(audio["text"], audio["sha256"]),
            }
    for form in draft["forms"]:
        items[form["id"]] = {"kind": "form", "fingerprint": form_fingerprint(form)}
    items[DIALOGUE_ITEM] = {"kind": "dialogue", "fingerprint": dialogue_fingerprint(draft, items)}
    return items


def dialogue_fingerprint(draft: dict, items: dict[str, dict]) -> str:
    brief = draft["brief"]
    return fingerprint(
        {
            "unit": brief["unit"],
            "dialogue": brief["dialogue"],
            "items": {k: v["fingerprint"] for k, v in items.items() if k != DIALOGUE_ITEM},
        }
    )
