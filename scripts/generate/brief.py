"""Briefs: what one dialogue must be about (job 7-content-pipeline, "Done when" 1).

A brief is a JSON file in content/briefs/. It names the unit and the dialogue,
the situation, the unit's grammar list, the word frequency rank cap, any extra
allowed base forms, the speakers (each with an English role and a voice) and
the number of lines. load_brief() refuses a brief with a missing or wrong field
and says which one.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

from grammar import GRAMMAR_CATALOGUE

SLUG = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
# Azure's Finnish neural voices (Azure language support page, read 21 October 2026).
FINNISH_VOICES = frozenset({"fi-FI-NooraNeural", "fi-FI-HarriNeural", "fi-FI-SelmaNeural"})
MIN_LINES = 4
MAX_LINES = 8


class BriefError(ValueError):
    """The brief cannot be used. The message says which field and why."""


def _text(obj: dict, key: str, where: str) -> str:
    if key not in obj:
        raise BriefError(f"{where}: the field '{key}' is missing")
    value = obj[key]
    if not isinstance(value, str) or not value.strip():
        raise BriefError(f"{where}: '{key}' must be a non-empty text")
    return value


def _int(obj: dict, key: str, where: str, low: int, high: int | None = None) -> int:
    if key not in obj:
        raise BriefError(f"{where}: the field '{key}' is missing")
    value = obj[key]
    if (
        isinstance(value, bool)
        or not isinstance(value, int)
        or value < low
        or (high is not None and value > high)
    ):
        limit = f"from {low} to {high}" if high is not None else f"{low} or more"
        raise BriefError(f"{where}: '{key}' must be a whole number {limit}")
    return value


def _slug(obj: dict, key: str, where: str) -> str:
    value = _text(obj, key, where)
    if not SLUG.match(value):
        raise BriefError(f"{where}: '{key}' must be lower case letters, digits and single hyphens")
    return value


def _object(obj: dict, key: str, where: str) -> dict:
    if key not in obj:
        raise BriefError(f"{where}: the field '{key}' is missing")
    if not isinstance(obj[key], dict):
        raise BriefError(f"{where}: '{key}' must be an object")
    return obj[key]


def validate_brief(data: object) -> dict:
    """Return the brief in its checked shape, or raise BriefError."""
    if not isinstance(data, dict):
        raise BriefError("brief: the file must hold one JSON object")
    unit = _object(data, "unit", "brief")
    dialogue = _object(data, "dialogue", "brief")
    checked_unit = {
        "slug": _slug(unit, "slug", "unit"),
        "position": _int(unit, "position", "unit", 1),
        "title_en": _text(unit, "title_en", "unit"),
        "can_do_en": _text(unit, "can_do_en", "unit"),
    }
    checked_dialogue = {
        "slug": _slug(dialogue, "slug", "dialogue"),
        "position": _int(dialogue, "position", "dialogue", 1),
        "title_en": _text(dialogue, "title_en", "dialogue"),
    }
    situation = _text(data, "situation_en", "brief")

    if "grammar" not in data:
        raise BriefError("brief: the field 'grammar' is missing")
    grammar = data["grammar"]
    if not isinstance(grammar, list) or not grammar or not all(isinstance(g, str) for g in grammar):
        raise BriefError("brief: 'grammar' must be a non-empty list of grammar ids")
    unknown = [g for g in grammar if g not in GRAMMAR_CATALOGUE]
    if unknown:
        known = ", ".join(sorted(GRAMMAR_CATALOGUE))
        raise BriefError(f"brief: unknown grammar id {', '.join(unknown)} (known: {known})")

    rank_cap = _int(data, "rank_cap", "brief", 1)

    if "extra_base_forms" not in data:
        raise BriefError("brief: the field 'extra_base_forms' is missing (use [] for none)")
    extra = data["extra_base_forms"]
    if not isinstance(extra, list) or not all(isinstance(w, str) and w.strip() for w in extra):
        raise BriefError("brief: 'extra_base_forms' must be a list of base forms")

    if "speakers" not in data:
        raise BriefError("brief: the field 'speakers' is missing")
    speakers = data["speakers"]
    if not isinstance(speakers, list) or not speakers:
        raise BriefError("brief: 'speakers' must be a non-empty list")
    checked_speakers = []
    for i, speaker in enumerate(speakers, start=1):
        where = f"speaker {i}"
        if not isinstance(speaker, dict):
            raise BriefError(f"{where}: must be an object")
        voice = _text(speaker, "voice", where)
        if voice not in FINNISH_VOICES:
            raise BriefError(f"{where}: voice '{voice}' is not one of {', '.join(sorted(FINNISH_VOICES))}")
        checked_speakers.append(
            {
                "name": _text(speaker, "name", where),
                "role_en": _text(speaker, "role_en", where),
                "voice": voice,
            }
        )
    names = [s["name"] for s in checked_speakers]
    if len(set(names)) != len(names):
        raise BriefError("brief: two speakers have the same name")

    line_count = _int(data, "line_count", "brief", MIN_LINES, MAX_LINES)

    return {
        "unit": checked_unit,
        "dialogue": checked_dialogue,
        "situation_en": situation,
        "grammar": list(grammar),
        "rank_cap": rank_cap,
        "extra_base_forms": [w.strip().lower() for w in extra],
        "speakers": checked_speakers,
        "line_count": line_count,
    }


def load_brief(path: Path | str) -> dict:
    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except json.JSONDecodeError as err:
        raise BriefError(f"brief: {path} is not valid JSON ({err.msg}, line {err.lineno})") from err
    return validate_brief(data)
