"""Editing one cell of the road's markdown tables, and the repair log (job 20-a1-road, "Done when" 14 and 24).

The markdown is the source of the road's Finnish. A repair, whether made by the importer's pronoun
step, by a working session or by a reviewer's fix, changes one cell of one row here and is written
to content/road/fixes.md with the text before, the text after and the reason. No threshold, check or
test is ever edited to make a draft pass.
"""

from __future__ import annotations

import re
from pathlib import Path

from road_mapping import _EDGE_PUNCT
from road_parse import REPO, WRITTEN, _cells

FIXES = REPO / "content" / "road" / "fixes.md"
COLUMNS = {"speaker": 1, "puhe": 2, "kirja": 3, "en": 4}


class CellNotFound(LookupError):
    """The row or the cell to change is not in the file."""


def part_file_for(label: str, written: Path = WRITTEN) -> Path:
    stop = int(label.split(".")[0])
    return written / f"part-{(stop - 1) // 6 + 1}.md"


def read_cell(label: str, line: int, column: str, written: Path = WRITTEN) -> str:
    """The text of one cell, for example read_cell("4.1", 2, "kirja")."""
    path = part_file_for(label, written)
    lines = path.read_text(encoding="utf-8").splitlines()
    row = _find_row(lines, label, line)
    return _cells(lines[row])[COLUMNS[column]]


def _find_row(lines: list[str], label: str, line: int) -> int:
    in_dialogue = False
    for index, raw in enumerate(lines):
        heading = re.match(r"^### (\d+\.\d+) ", raw)
        if heading:
            in_dialogue = heading.group(1) == label
            continue
        if in_dialogue and raw.lstrip().startswith("|"):
            cells = _cells(raw)
            if cells and cells[0] == str(line):
                return index
    raise CellNotFound(f"dialogue {label}, line {line}: the row is not in {part_file_for(label).name}")


def replace_cell(label: str, line: int, column: str, new_text: str, written: Path = WRITTEN) -> str:
    """Write new_text into the cell and return the text it replaced. Keeps the file's other bytes."""
    if "|" in new_text or "\n" in new_text or not new_text.strip():
        raise ValueError("a table cell cannot be empty or hold a pipe or a line break")
    path = part_file_for(label, written)
    raw = path.read_bytes().decode("utf-8")
    newline = "\r\n" if "\r\n" in raw else "\n"
    lines = raw.split(newline)
    row = _find_row(lines, label, line)
    cells = _cells(lines[row])
    old = cells[COLUMNS[column]]
    cells[COLUMNS[column]] = new_text.strip()
    lines[row] = "| " + " | ".join(cells) + " |"
    path.write_bytes(newline.join(lines).encode("utf-8"))
    return old


def log_fix(
    label: str,
    line: int,
    column: str,
    before: str,
    after: str,
    reason: str,
    round_name: str,
    fixes: Path = FIXES,
) -> None:
    """Append one fix to content/road/fixes.md under its round's heading."""
    names = {
        "speaker": "speaker",
        "puhe": "spoken text",
        "kirja": "written text",
        "en": "English text",
        "situation": "scene sentence",
    }
    text = fixes.read_text(encoding="utf-8") if fixes.is_file() else _HEADER
    heading = f"## {round_name}"
    if heading not in text:
        text = text.rstrip("\n") + f"\n\n{heading}\n"
    entry = (
        f"\n- Dialogue {label}, {f'line {line}, ' if line else ''}{names[column]}.\n"
        f"  Before: {before}\n"
        f"  After: {after}\n"
        f"  Reason: {reason}\n"
    )
    head, _, rest = text.partition(heading)
    after_heading, sep, tail = rest.partition("\n## ")
    rest = after_heading.rstrip("\n") + "\n" + entry + (("\n## " + tail) if sep else "")
    fixes.parent.mkdir(parents=True, exist_ok=True)
    fixes.write_text(head + heading + rest, encoding="utf-8", newline="\n")


_HEADER = """# Fixes made to Claude's road content

Every change made to `content/written/part-1.md` to `part-6.md` after a failing check run, with the
text before, the text after and the reason. No threshold, check or test was changed to make a draft
pass (job 20-a1-road, statement 14).
"""


def token_spans(text: str) -> list[tuple[int, int]]:
    """For each word as the tokenizer splits it, the (start, end) of its letters in the text."""
    spans = []
    for match in re.finditer(r"\S+", text):
        raw = match.group(0)
        core = raw.strip(_EDGE_PUNCT)
        if core:
            start = match.start() + raw.index(core)
            spans.append((start, start + len(core)))
    return spans


def insert_word_before(text: str, word_index: int, word: str) -> str:
    """Insert `word` before the word_index'th word (1 based). At the start of a sentence the new
    word takes the capital letter and the old word gives it up."""
    spans = token_spans(text)
    if not 1 <= word_index <= len(spans):
        raise IndexError("the word position is not in the text")
    start, end = spans[word_index - 1]
    old = text[start:end]
    before = text[:start].rstrip()
    sentence_start = before == "" or before[-1] in ".!?"
    if sentence_start and old[:1].isupper():
        # Names stay capital. The caller passes only pronouns and verbs here.
        new_word = word[:1].upper() + word[1:]
        old = old[:1].lower() + old[1:]
    else:
        new_word = word
    return text[:start] + new_word + " " + old + text[end:]


def insert_word_after(text: str, word_index: int, word: str) -> str:
    """Insert `word` right after the word_index'th word (1 based), before any punctuation that follows it."""
    spans = token_spans(text)
    if not 1 <= word_index <= len(spans):
        raise IndexError("the word position is not in the text")
    end = spans[word_index - 1][1]
    return text[:end] + " " + word + text[end:]
