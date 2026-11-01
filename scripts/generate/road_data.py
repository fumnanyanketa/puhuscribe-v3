"""The road's settings and word card texts, read from content/road/ (job 20-a1-road, statements 9, 13 and 16).

content/road/stops.json         each stop's unit slug, rank cap, grammar entries and extra base forms
content/road/speakers.json      each named speaker's Azure voice
content/road/glossary.tsv       each dictionary form's English meaning (lemma_meaning_en)
content/road/word-notes.tsv     each other form's own meaning and its one line "why"
content/road/allowed-extras.json  base forms and forms allowed outside a stop's level, with a reason
content/road/reading-overrides.tsv  a chosen reading for a spelling, the same in every line
content/road/reading-overrides-by-position.tsv  a chosen reading for one word in one line
content/road/list-aliases.tsv   a dictionary form the frequency list holds under another base form

Nothing here calls Voikko, the network or an AI service.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

from grammar import GRAMMAR_CATALOGUE, NAME_CLASSES, UnknownTagValue, form_name, parse_tag, why_problems
from road_parse import REPO

ROAD_DIR = REPO / "content" / "road"
FIXED_WHY = {"dictionary-same": "This is the dictionary form. People say it the same way."}
MEANING_MAX = 60
MNEMONIC = re.compile(r"\b(remember|mnemonic|memori[sz]e|think of|sounds like|imagine)\b", re.IGNORECASE)
_CONTROL = re.compile(r"[\x00-\x1f\x7f]")


class RoadDataError(ValueError):
    """A road file is wrong. The message names the file and the line."""


def read_tsv(path: Path, columns: int, name: str) -> list[tuple[int, list[str]]]:
    """The rows of a tab separated file, with their line numbers. Blank lines and # lines are skipped.
    Every row is padded to `columns` cells; a longer row is refused."""
    rows = []
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not raw.strip() or raw.startswith("#"):
            continue
        cells = raw.split("\t")
        if len(cells) > columns:
            raise RoadDataError(f"{name}, line {number}: {len(cells)} cells, at most {columns} are allowed")
        rows.append((number, [c.strip() for c in cells] + [""] * (columns - len(cells))))
    return rows


def meaning_problems(text: str) -> list[str]:
    """Plain reasons a meaning text breaks the database's rule, or []."""
    if not text.strip():
        return ["the text is empty"]
    problems = []
    if len(text) > MEANING_MAX:
        problems.append(f"the text is {len(text)} characters, over the limit of {MEANING_MAX}")
    if _CONTROL.search(text):
        problems.append("the text has a line break or another control character")
    return problems


@dataclass
class StopSettings:
    number: int
    unit_slug: str
    rank_cap: int
    grammar: list[str]
    extra_base_forms: list[str]
    earlier_dialogues: list[str]


READING_SOURCES = ("voikko", "manual")


@dataclass(frozen=True)
class ReadingOverride:
    """A reading chosen by hand for a spelling, or for one word in one line (word and the file line
    are set for a position row). "voikko": the reading is one of Voikko's own, chosen among them.
    "manual": Voikko offers no fitting reading, so the lemma and form tag are written here."""

    lemma: str
    form_tag: str
    source: str
    reason: str
    word: str = ""
    file_line: int = 0


@dataclass(frozen=True)
class ListAlias:
    """A dictionary form the frequency list does not have under that spelling, and the base form the list
    does have for the same word (paljon is listed as paljo). The word takes the rank of its list form."""

    lemma: str
    listed_as: str
    reason: str
    file_line: int = 0


def manual_analysis(lemma: str, form_tag: str) -> dict:
    """The analysis stored for a manual reading: the same keys as Voikko's, plus a marker."""
    return dict(sorted({"BASEFORM": lemma, **parse_tag(form_tag), "MANUAL": "true"}.items()))


@dataclass
class RoadData:
    stops: dict[int, StopSettings]
    speakers: dict[str, str]
    glossary: dict[str, str] = field(default_factory=dict)
    notes: dict[str, dict] = field(default_factory=dict)
    extras: dict[int, dict] = field(default_factory=dict)
    overrides: dict[str, ReadingOverride] = field(default_factory=dict)
    position_overrides: dict[tuple[str, int, int], ReadingOverride] = field(default_factory=dict)
    list_aliases: dict[str, ListAlias] = field(default_factory=dict)

    def cumulative_grammar(self, stop: int) -> list[str]:
        """A stop's list is its own entries plus every earlier stop's."""
        out: list[str] = []
        for number in range(1, stop + 1):
            for entry in self.stops[number].grammar:
                if entry not in out:
                    out.append(entry)
        out += [f"extras-stop-{n}" for n in sorted(self.extras) if n <= stop and self.extras[n].get("forms")]
        return out

    def stop_extra_base_forms(self, stop: int) -> list[str]:
        """The extra base forms of a stop: its own settings plus the ones recorded for it."""
        found = list(self.stops[stop].extra_base_forms)
        for item in self.extras.get(stop, {}).get("base_forms", []):
            found.append(item["lemma"])
        return sorted({w.lower() for w in found})


def load_stops(path: Path = ROAD_DIR / "stops.json") -> dict[int, StopSettings]:
    doc = json.loads(path.read_text(encoding="utf-8"))
    if doc.get("format") != "puhuscribe-road-stops-1":
        raise RoadDataError("stops.json: the format must be puhuscribe-road-stops-1")
    stops = {}
    for key, raw in doc["stops"].items():
        unknown = [g for g in raw["grammar"] if g not in GRAMMAR_CATALOGUE]
        if unknown:
            raise RoadDataError(f"stops.json, stop {key}: unknown grammar id {', '.join(unknown)}")
        stops[int(key)] = StopSettings(
            number=int(key),
            unit_slug=raw["unit_slug"],
            rank_cap=int(raw["rank_cap"]),
            grammar=list(raw["grammar"]),
            extra_base_forms=[w.lower() for w in raw["extra_base_forms"]],
            earlier_dialogues=list(raw["earlier_dialogues"]),
        )
    if sorted(stops) != list(range(1, 37)):
        raise RoadDataError("stops.json: it must have stops 1 to 36")
    return stops


def load_speakers(path: Path = ROAD_DIR / "speakers.json") -> dict[str, str]:
    doc = json.loads(path.read_text(encoding="utf-8"))
    if doc.get("format") != "puhuscribe-road-speakers-1":
        raise RoadDataError("speakers.json: the format must be puhuscribe-road-speakers-1")
    return dict(doc["speakers"])


def load_glossary(path: Path = ROAD_DIR / "glossary.tsv") -> dict[str, str]:
    """Dictionary form to its English meaning. A row with an empty meaning is an empty entry."""
    if not path.is_file():
        return {}
    glossary: dict[str, str] = {}
    for number, cells in read_tsv(path, 3, "glossary.tsv"):
        lemma, meaning = cells[0], cells[1]
        if lemma in glossary:
            raise RoadDataError(f"glossary.tsv, line {number}: '{lemma}' appears twice")
        glossary[lemma] = meaning
    return glossary


def load_notes(path: Path = ROAD_DIR / "word-notes.tsv") -> dict[str, dict]:
    """Form id to its own notes: kirja, puhe, lemma, name, meaning_en and why_en (empty when not written)."""
    if not path.is_file():
        return {}
    notes: dict[str, dict] = {}
    for number, cells in read_tsv(path, 7, "word-notes.tsv"):
        form_id = cells[0]
        if form_id in notes:
            raise RoadDataError(f"word-notes.tsv, line {number}: form '{form_id}' appears twice")
        notes[form_id] = {
            "line": number,
            "surface_kirja": cells[1],
            "surface_puhe": cells[2],
            "lemma": cells[3],
            "form_name_en": cells[4],
            "meaning_en": cells[5],
            "why_en": cells[6],
        }
    return notes


def load_extras(path: Path = ROAD_DIR / "allowed-extras.json") -> dict[int, dict]:
    """Per stop: base forms and forms allowed outside the level, each with its reason."""
    if not path.is_file():
        return {}
    doc = json.loads(path.read_text(encoding="utf-8"))
    if doc.get("format") != "puhuscribe-road-extras-1":
        raise RoadDataError("allowed-extras.json: the format must be puhuscribe-road-extras-1")
    extras: dict[int, dict] = {}
    for key, raw in doc["stops"].items():
        for kind in ("base_forms", "forms"):
            for item in raw.get(kind, []):
                if not str(item.get("reason", "")).strip():
                    raise RoadDataError(f"allowed-extras.json, stop {key}: an extra has no reason")
        extras[int(key)] = {"base_forms": raw.get("base_forms", []), "forms": raw.get("forms", [])}
    return extras


def _override(name: str, number: int, lemma: str, tag: str, source: str, reason: str, word: str = ""):
    """One validated override row. The tag must be one the form name table knows, and a manual
    reading can never be a name (names have no word card)."""
    where = f"{name}, line {number}"
    if not lemma or not tag:
        raise RoadDataError(f"{where}: the lemma and the form tag must not be empty")
    if source not in READING_SOURCES:
        raise RoadDataError(f"{where}: the reading must be voikko or manual, not '{source}'")
    if not reason:
        raise RoadDataError(f"{where}: the reason must not be empty")
    try:
        form_name(tag)
        is_name = parse_tag(tag).get("CLASS") in NAME_CLASSES
    except UnknownTagValue as err:
        raise RoadDataError(f"{where}: {err}") from err
    if is_name and source == "manual":
        raise RoadDataError(f"{where}: a manual reading cannot be a name")
    return ReadingOverride(lemma, tag, source, reason, word, number)


def load_overrides(path: Path = ROAD_DIR / "reading-overrides.tsv") -> dict[str, ReadingOverride]:
    """Spelling (lower case) to its reading. Columns: word, lemma, form tag, voikko or manual, reason."""
    if not path.is_file():
        return {}
    found: dict[str, ReadingOverride] = {}
    for number, cells in read_tsv(path, 5, "reading-overrides.tsv"):
        word = cells[0].lower()
        if word in found:
            raise RoadDataError(f"reading-overrides.tsv, line {number}: '{word}' appears twice")
        found[word] = _override("reading-overrides.tsv", number, *cells[1:5])
    return found


def load_position_overrides(
    path: Path = ROAD_DIR / "reading-overrides-by-position.tsv",
) -> dict[tuple[str, int, int], ReadingOverride]:
    """(dialogue slug, line number, word position) to its reading. Columns: dialogue slug, line number,
    word position (counted over the line's written words from 1), the written word, lemma, form tag,
    voikko or manual, reason."""
    if not path.is_file():
        return {}
    name = "reading-overrides-by-position.tsv"
    found: dict[tuple[str, int, int], ReadingOverride] = {}
    for number, cells in read_tsv(path, 8, name):
        try:
            key = (cells[0], int(cells[1]), int(cells[2]))
        except ValueError as err:
            raise RoadDataError(f"{name}, line {number}: the line and the position must be numbers") from err
        if key in found:
            raise RoadDataError(f"{name}, line {number}: {key} appears twice")
        if not cells[3]:
            raise RoadDataError(f"{name}, line {number}: the written word must not be empty")
        found[key] = _override(name, number, cells[4], cells[5], cells[6], cells[7], cells[3])
    return found


def load_list_aliases(path: Path = ROAD_DIR / "list-aliases.tsv") -> dict[str, ListAlias]:
    """Dictionary form (lower case) to the list form that stands for it. Columns: dictionary form, the
    base form the frequency list has for the same word, reason."""
    if not path.is_file():
        return {}
    found: dict[str, ListAlias] = {}
    for number, cells in read_tsv(path, 3, "list-aliases.tsv"):
        lemma, listed_as, reason = cells[0].lower(), cells[1].lower(), cells[2]
        where = f"list-aliases.tsv, line {number}"
        if not lemma or not listed_as or lemma == listed_as:
            raise RoadDataError(f"{where}: two different base forms are needed")
        if not reason:
            raise RoadDataError(f"{where}: the reason must not be empty")
        if lemma in found:
            raise RoadDataError(f"{where}: '{lemma}' appears twice")
        found[lemma] = ListAlias(lemma, listed_as, reason, number)
    return found


def aliased_ranks(ranks: dict[str, int], aliases: dict[str, ListAlias]) -> dict[str, int]:
    """The frequency ranks with each alias given the rank of its list form. A word the list already has
    keeps its own rank, and an alias whose list form is missing adds nothing."""
    result = dict(ranks)
    for lemma, alias in aliases.items():
        if lemma not in result and alias.listed_as in result:
            result[lemma] = result[alias.listed_as]
    return result


def load_road_data(road_dir: Path = ROAD_DIR) -> RoadData:
    return RoadData(
        stops=load_stops(road_dir / "stops.json"),
        speakers=load_speakers(road_dir / "speakers.json"),
        glossary=load_glossary(road_dir / "glossary.tsv"),
        notes=load_notes(road_dir / "word-notes.tsv"),
        extras=load_extras(road_dir / "allowed-extras.json"),
        overrides=load_overrides(road_dir / "reading-overrides.tsv"),
        position_overrides=load_position_overrides(road_dir / "reading-overrides-by-position.tsv"),
        list_aliases=load_list_aliases(road_dir / "list-aliases.tsv"),
    )


def note_problems(note: dict, form_name: str) -> list[str]:
    """Plain reasons a word note breaks the rules (meaning limit, the why rules, no mnemonics)."""
    problems = []
    if note.get("meaning_en"):
        problems += [f"meaning: {p}" for p in meaning_problems(note["meaning_en"])]
    why = note.get("why_en", "")
    if why:
        problems += [f"why: {p}" for p in why_problems(why, form_name)]
        if MNEMONIC.search(why):
            problems.append("why: a mnemonic or memory trick is not allowed")
    return problems
