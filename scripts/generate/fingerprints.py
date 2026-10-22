"""Content fingerprints for the content pipeline (job 7-content-pipeline).

A fingerprint is the SHA-256 of an item's content written as canonical JSON
(sorted keys, no spaces). The judge's verdicts and the reviewer's approvals
carry the fingerprint of what they saw, so any later change to a line, a form
or an audio clip makes them stale and the checks or the publish step refuse.
"""

from __future__ import annotations

import hashlib
import json
from typing import Any


def canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def fingerprint(value: Any) -> str:
    return hashlib.sha256(canonical_json(value).encode("utf-8")).hexdigest()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def line_content(line: dict) -> dict:
    """The part of a line the judge and the reviewer look at."""
    return {
        "speaker": line["speaker"],
        "text_puhe": line["text_puhe"],
        "text_kirja": line["text_kirja"],
        "gloss_en": line["gloss_en"],
    }


def line_fingerprint(line: dict) -> str:
    return fingerprint(line_content(line))


def form_identity(form: dict) -> dict:
    """What makes a form the same form (the database's unique key)."""
    return {
        "lemma": form["lemma"],
        "form_tag": form["form_tag"],
        "surface_kirja": form["surface_kirja"],
        "surface_puhe": form["surface_puhe"],
    }


def form_id(form: dict) -> str:
    """A stable item id for a form, the same in every review round."""
    return "form-" + fingerprint(form_identity(form))[:12]


def form_fingerprint(form: dict) -> str:
    return fingerprint(
        {**form_identity(form), "form_name_en": form["form_name_en"], "why_en": form["why_en"]}
    )


def audio_fingerprint(text: str, audio_sha256: str) -> str:
    return fingerprint({"text": text, "audio_sha256": audio_sha256})
