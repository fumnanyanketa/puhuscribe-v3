"""The importer's one automatic repair: add the written pronoun a spoken line has (job 20-a1-road).

A spoken pronoun (mä, sä, me, te, mun, sun) must pair with a written pronoun, so a line whose
written version drops it gets the pronoun added. This module finds those lines through the
mapping's own refusals, inserts the pronoun in the written cell and logs each change in
content/road/fixes.md. It changes only the markdown tables, never a check.
"""

from __future__ import annotations

import re

from road_mapping import SpokenForms, map_line, tokenize
from road_markdown import insert_word_after, insert_word_before, log_fix, read_cell, replace_cell
from road_parse import Road

WRITTEN_FOR = {
    "mä": "minä",
    "sä": "sinä",
    "me": "me",
    "te": "te",
    "mun": "minun",
    "sun": "sinun",
}
POSSESSIVE_END = re.compile(r"(ni|si|mme|nne|nsa|nsä|ani|äni|asi|äsi|amme|ämme|anne|änne)$", re.IGNORECASE)
MAX_STEPS = 6


def pronoun_fix(spoken: str, written: str, forms: SpokenForms) -> tuple[int, str, bool] | None:
    """(position, pronoun, after the previous word) of the first pronoun to add, or None."""
    _, mapping = map_line(spoken, written, forms)
    words = tokenize(written)
    for refusal in mapping.refusals:
        low = refusal.spoken.lower()
        in_range = 1 <= refusal.written_index <= len(words) or (
            refusal.kind == "spoken_extra"
            and refusal.after_previous
            and refusal.written_index == len(words) + 1
        )
        if low not in WRITTEN_FOR or not in_range:
            continue
        if refusal.kind == "missing_pronoun":
            return refusal.written_index, WRITTEN_FOR[low], refusal.after_previous
        if refusal.kind == "spoken_extra" and refusal.after_previous:
            return refusal.written_index, WRITTEN_FOR[low], True
        if low in ("mun", "sun") and refusal.kind in ("pair", "spoken_extra", "missing_pronoun"):
            # Spoken "mun äiti" renders written "äitini": the written line gets "minun" before
            # the possessed noun, which is the next written word with a possessive ending.
            for offset in range(3):
                at = refusal.written_index + offset
                if at <= len(words) and POSSESSIVE_END.search(words[at - 1]):
                    return refusal.written_index, WRITTEN_FOR[low], False
    return None


def repair_pronouns(road: Road, forms: SpokenForms, round_name: str, write: bool = True) -> list[dict]:
    """Add the missing written pronouns. Returns one record per change (also logged when `write`)."""
    changes = []
    for dialogue in road.dialogues():
        for line in dialogue.lines:
            written = line.kirja
            for _ in range(MAX_STEPS):
                fix = pronoun_fix(line.puhe, written, forms)
                if fix is None:
                    break
                position, pronoun, after_previous = fix
                new = (
                    insert_word_after(written, position - 1, pronoun)
                    if after_previous and position > 1
                    else insert_word_before(written, position, pronoun)
                )
                changes.append(
                    {
                        "label": dialogue.label,
                        "line": line.n,
                        "before": written,
                        "after": new,
                        "pronoun": pronoun,
                    }
                )
                written = new
            if written != line.kirja and write:
                label, n = dialogue.label, line.n
                before = read_cell(label, n, "kirja")
                replace_cell(label, n, "kirja", written)
                log_fix(
                    label,
                    n,
                    "kirja",
                    before,
                    written,
                    "The spoken line has a pronoun. Every spoken word renders one written word, "
                    "so the written line needs its pronoun too.",
                    round_name,
                )
    return changes
