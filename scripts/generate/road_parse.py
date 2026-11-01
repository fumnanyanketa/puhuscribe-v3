"""Reading the A1 road's markdown (job 20-a1-road, "Done when" 8).

Claude's hand written dialogues live in content/written/part-1.md to part-6.md and the road's
stops in docs/curriculum-a1.md. parse_road() reads them, checks their shape and returns plain data.
It refuses, naming the file, the stop and the line, a row with an empty cell, a stray pipe, a line
number out of order, a stop without its "**I can:**" line, or a dialogue count that is not 3 once
the six earlier drafts are counted. No Voikko, no network and no AI is used here.

All text read here is plain text. Nothing is run or rendered by this module, and every place that
shows it escapes it.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CURRICULUM = REPO / "docs" / "curriculum-a1.md"
WRITTEN = REPO / "content" / "written"
PARTS = 6
STOPS_PER_PART = 6
DIALOGUES_PER_STOP = 3
LINES_PER_DIALOGUE = 8

TABLE_HEADER = ["#", "Speaker", "Spoken Finnish", "Written Finnish", "English"]
CURRICULUM_HEADER = ["Stop", "Situation", "I can...", "Grammar that comes up", "Spoken / written"]
_CONTROL = re.compile(r"[\x00-\x08\x0b-\x1f\x7f]")


class RoadParseError(ValueError):
    """The markdown cannot be used. The message names the file, the stop and the line."""


@dataclass
class RoadLine:
    n: int
    speaker: str
    puhe: str
    kirja: str
    en: str


@dataclass
class RoadDialogue:
    stop: int
    position: int
    title: str
    situation: str
    lines: list[RoadLine]
    file: str
    slug: str = ""

    @property
    def label(self) -> str:
        return f"{self.stop}.{self.position}"


@dataclass
class RoadStop:
    number: int
    part: int
    name: str
    can_do: str
    curriculum_can_do: str
    grammar_text: str
    dialogues: list[RoadDialogue] = field(default_factory=list)


@dataclass
class Road:
    parts: dict[int, str]
    stops: dict[int, RoadStop]

    def dialogues(self) -> list[RoadDialogue]:
        return [d for stop in self.stops.values() for d in stop.dialogues]


def _cells(row: str) -> list[str]:
    inner = row.strip()
    if inner.startswith("|"):
        inner = inner[1:]
    if inner.endswith("|"):
        inner = inner[:-1]
    return [cell.strip() for cell in inner.split("|")]


def _is_separator(row: str) -> bool:
    return bool(re.fullmatch(r"\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?", row.strip()))


def kebab(text: str) -> str:
    """The English title as a slug: lower case ASCII letters and digits with single hyphens."""
    plain = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii").lower()
    plain = plain.replace("'", "").replace("’", "")
    return re.sub(r"[^a-z0-9]+", "-", plain).strip("-")


def parse_curriculum(path: Path = CURRICULUM) -> tuple[dict[int, str], dict[int, RoadStop]]:
    """The six parts and 36 stops from the curriculum's tables (the sample below them is skipped)."""
    where = path.name
    parts: dict[int, str] = {}
    stops: dict[int, RoadStop] = {}
    part = 0
    in_table = False
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw.rstrip()
        if line.startswith("## Sample"):
            break
        heading = re.match(r"^## Part (\d+)\. (.+)$", line)
        if heading:
            part = int(heading.group(1))
            parts[part] = heading.group(2).strip()
            in_table = False
            continue
        if not line.startswith("|") or part == 0:
            in_table = False
            continue
        if _is_separator(line):
            continue
        cells = _cells(line)
        if cells == CURRICULUM_HEADER:
            in_table = True
            continue
        if not in_table:
            continue
        if len(cells) != 5 or not all(cells):
            raise RoadParseError(
                f"{where}, line {lineno}: a stop row needs 5 filled cells, found {len(cells)}"
            )
        if not cells[0].isdigit():
            raise RoadParseError(f"{where}, line {lineno}: the stop number '{cells[0]}' is not a number")
        number = int(cells[0])
        if number in stops:
            raise RoadParseError(f"{where}, line {lineno}: stop {number} appears twice")
        stops[number] = RoadStop(
            number=number,
            part=part,
            name=cells[1],
            can_do="",
            curriculum_can_do=cells[2],
            grammar_text=cells[3],
        )
    if sorted(parts) != list(range(1, PARTS + 1)):
        raise RoadParseError(f"{where}: expected parts 1 to {PARTS}, found {sorted(parts)}")
    if sorted(stops) != list(range(1, PARTS * STOPS_PER_PART + 1)):
        raise RoadParseError(f"{where}: expected stops 1 to {PARTS * STOPS_PER_PART}, found {len(stops)}")
    for number, stop in stops.items():
        if stop.part != (number - 1) // STOPS_PER_PART + 1:
            raise RoadParseError(f"{where}: stop {number} is in part {stop.part}")
    return parts, stops


def parse_part_file(path: Path, part: int, stops: dict[int, RoadStop]) -> None:
    """Fill each stop of the part with its "I can" sentence and its new dialogues."""
    where = f"content/written/{path.name}"
    current: RoadStop | None = None
    lines = path.read_text(encoding="utf-8").splitlines()
    i = 0
    seen_part = False
    while i < len(lines):
        raw = lines[i].rstrip()
        lineno = i + 1
        i += 1
        if _CONTROL.search(raw):
            raise RoadParseError(f"{where}, line {lineno}: a control character is not allowed")
        top = re.match(r"^# Part (\d+)\. (.+)$", raw)
        if top:
            if int(top.group(1)) != part:
                raise RoadParseError(
                    f"{where}, line {lineno}: this file holds part {part}, not {top.group(1)}"
                )
            seen_part = True
            continue
        stop_heading = re.match(r"^## Stop (\d+)\. (.+)$", raw)
        if stop_heading:
            number = int(stop_heading.group(1))
            if number not in stops or stops[number].part != part:
                raise RoadParseError(f"{where}, line {lineno}: stop {number} is not in part {part}")
            current = stops[number]
            if current.name != stop_heading.group(2).strip():
                raise RoadParseError(
                    f"{where}, stop {number}: its name '{stop_heading.group(2).strip()}' differs from "
                    f"the curriculum's '{current.name}'"
                )
            continue
        can = re.match(r"^\*\*I can:\*\* (.+)$", raw)
        if can:
            if current is None:
                raise RoadParseError(f"{where}, line {lineno}: an I can line before any stop")
            if current.can_do:
                raise RoadParseError(f"{where}, stop {current.number}: two I can lines")
            current.can_do = can.group(1).strip()
            continue
        dialogue_heading = re.match(r"^### (\d+)\.(\d+) (.+)$", raw)
        if dialogue_heading:
            if current is None:
                raise RoadParseError(f"{where}, line {lineno}: a dialogue before any stop")
            stop_number, position = int(dialogue_heading.group(1)), int(dialogue_heading.group(2))
            title = dialogue_heading.group(3).strip()
            here = f"{where}, stop {current.number}, dialogue {stop_number}.{position}"
            if stop_number != current.number:
                raise RoadParseError(f"{here}: the dialogue number does not match its stop")
            # The scene sentence: the first non empty line after the heading, before the table.
            while i < len(lines) and not lines[i].strip():
                i += 1
            situation = lines[i].strip() if i < len(lines) else ""
            if not situation or situation.startswith("|"):
                raise RoadParseError(f"{here}: the scene sentence is missing")
            i += 1
            while i < len(lines) and not lines[i].strip():
                i += 1
            rows: list[tuple[int, str]] = []
            while i < len(lines) and lines[i].lstrip().startswith("|"):
                rows.append((i + 1, lines[i].rstrip()))
                i += 1
            current.dialogues.append(
                RoadDialogue(
                    stop=current.number,
                    position=position,
                    title=title,
                    situation=situation,
                    lines=_parse_table(rows, here),
                    file=where,
                    slug=kebab(title),
                )
            )
    if not seen_part:
        raise RoadParseError(f"{where}: the file has no '# Part {part}.' heading")


def _parse_table(rows: list[tuple[int, str]], here: str) -> list[RoadLine]:
    if len(rows) < 3:
        raise RoadParseError(f"{here}: the dialogue table is missing")
    header = _cells(rows[0][1])
    if header != TABLE_HEADER:
        raise RoadParseError(
            f"{here}, line {rows[0][0]}: the table header must be {' | '.join(TABLE_HEADER)}"
        )
    if not _is_separator(rows[1][1]):
        raise RoadParseError(f"{here}, line {rows[1][0]}: the header row needs its separator row")
    result: list[RoadLine] = []
    for lineno, raw in rows[2:]:
        cells = _cells(raw)
        position = len(result) + 1
        if len(cells) != 5:
            raise RoadParseError(
                f"{here}, line {position} (file line {lineno}): {len(cells)} cells instead of 5, "
                "probably a stray pipe"
            )
        names = ["number", "speaker", "spoken text", "written text", "English text"]
        for name, cell in zip(names, cells, strict=True):
            if not cell:
                raise RoadParseError(f"{here}, line {position} (file line {lineno}): the {name} is empty")
        if not cells[0].isdigit() or int(cells[0]) != position:
            raise RoadParseError(
                f"{here}, line {position} (file line {lineno}): the line number is '{cells[0]}', "
                f"expected {position}"
            )
        result.append(RoadLine(position, cells[1], cells[2], cells[3], cells[4]))
    if len(result) != LINES_PER_DIALOGUE:
        raise RoadParseError(f"{here}: {len(result)} lines instead of {LINES_PER_DIALOGUE}")
    return result


def parse_road(
    curriculum: Path = CURRICULUM,
    written: Path = WRITTEN,
    earlier: dict[int, list[tuple[int, str]]] | None = None,
) -> Road:
    """The whole road. `earlier` maps a stop number to the (position, slug) of the dialogues the
    pipeline drafted before. With them, each stop must have exactly 3 dialogues in positions 1 to 3."""
    parts, stops = parse_curriculum(curriculum)
    for part in range(1, PARTS + 1):
        parse_part_file(written / f"part-{part}.md", part, stops)
    earlier = earlier or {}
    for number, stop in stops.items():
        if not stop.can_do:
            raise RoadParseError(
                f"content/written/part-{stop.part}.md, stop {number}: the **I can:** line is missing"
            )
        positions = sorted([d.position for d in stop.dialogues] + [p for p, _ in earlier.get(number, [])])
        if positions != list(range(1, DIALOGUES_PER_STOP + 1)):
            raise RoadParseError(
                f"stop {number}: dialogue positions are {positions}, expected 1 to {DIALOGUES_PER_STOP} "
                f"once the {sum(len(v) for v in earlier.values())} earlier drafts are counted"
            )
        stop.dialogues.sort(key=lambda d: d.position)
    slugs: dict[str, str] = {}
    for stop in stops.values():
        for d in stop.dialogues:
            if d.slug in slugs:
                raise RoadParseError(
                    f"dialogue {d.label} and dialogue {slugs[d.slug]} have the same slug '{d.slug}'"
                )
            slugs[d.slug] = d.label
    return Road(parts=parts, stops=stops)
