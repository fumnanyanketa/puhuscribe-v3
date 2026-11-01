"""Forms the road records as allowed outside a stop's grammar list (job 20-a1-road, statement 13).

content/road/allowed-extras.json lists, for a stop, the forms (a dictionary form and its form tag) that
the stop's lines use before the curriculum teaches them, each with a reason in plain English.
register_road_extras() adds one grammar entry, "extras-stop-<n>", for each stop that has some, so the
existing level check licenses exactly those forms. The entry also licenses the add-on endings (question,
-kin, possessive) that appear on the stop's recorded forms, and no other. Nothing is skipped: the report
prints how many extras each part allowed.
"""

from __future__ import annotations

import json
from pathlib import Path

from grammar import ADD_ON_KEYS, GRAMMAR_CATALOGUE, form_tag, parse_tag
from road_parse import REPO

EXTRAS_PATH = REPO / "content" / "road" / "allowed-extras.json"


def core_tag(tag: str) -> str:
    """A form tag without its add-on endings (question, -kin, possessive)."""
    attrs = {k: v for k, v in parse_tag(tag).items() if k not in ADD_ON_KEYS}
    return form_tag(attrs)


def register_road_extras(path: Path = EXTRAS_PATH) -> list[str]:
    """Add the stops' extras to GRAMMAR_CATALOGUE. Safe to call again: it replaces its own entries."""
    for key in [k for k in GRAMMAR_CATALOGUE if k.startswith("extras-stop-")]:
        del GRAMMAR_CATALOGUE[key]
    if not path.is_file():
        return []
    doc = json.loads(path.read_text(encoding="utf-8"))
    added = []
    for stop, raw in sorted(doc.get("stops", {}).items(), key=lambda item: int(item[0])):
        recorded = raw.get("forms", [])
        if not recorded:
            continue
        cores = {(item["lemma"].lower(), core_tag(item["tag"])) for item in recorded}
        add_ons: dict[str, set[str]] = {}
        for item in recorded:
            for key, value in parse_tag(item["tag"]).items():
                if key in ADD_ON_KEYS:
                    add_ons.setdefault(key, set()).add(value)
        entry = f"extras-stop-{int(stop)}"
        GRAMMAR_CATALOGUE[entry] = {
            "en": f"forms recorded as allowed in stop {int(stop)} (content/road/allowed-extras.json)",
            "core": lambda lemma, a, cores=cores: (lemma.lower(), form_tag(a)) in cores,
            "add_ons": add_ons,
        }
        added.append(entry)
    return added
