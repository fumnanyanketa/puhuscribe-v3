"""Voikko readings for the words of a line (job 7-content-pipeline, "Done when" 7 and 10).

Every written (kirja) word is split and checked with v2's VoikkoGate, unchanged.
Each word's readings become candidates: one per distinct (base form, form tag),
sorted, so the AI can only choose among Voikko's own readings by number.
"""

from __future__ import annotations

from functools import lru_cache

import allowed_vocab
from grammar import NAME_CLASSES, form_tag
from voikko_gate import VoikkoGate


def tokens(gate: VoikkoGate, text: str) -> list[str]:
    """The words of a text, as v2's gate splits them (spaces, edge punctuation off)."""
    return gate.tokenize(text)


def is_word(gate: VoikkoGate, token: str) -> bool:
    """False for tokens with no letter (numbers), which the gate does not check."""
    return gate.check_token(token) is not None


def candidates(gate: VoikkoGate, token: str) -> list[dict]:
    """Voikko's readings of one word as {lemma, form_tag, name, reading}, one per distinct pair."""
    seen: dict[tuple[str, str], dict] = {}
    # The gate's own capitalisation handling (sentence-initial words, names).
    for reading in gate._analyze_best(token):
        reading = dict(reading)
        lemma = reading.get("BASEFORM", "")
        tag = form_tag(reading)
        if not lemma or not tag:
            continue
        seen.setdefault(
            (lemma, tag),
            {
                "lemma": lemma,
                "form_tag": tag,
                "name": reading.get("CLASS") in NAME_CLASSES,
                "reading": dict(sorted(reading.items())),
            },
        )
    return sorted(seen.values(), key=lambda c: (c["form_tag"], c["lemma"]))


@lru_cache(maxsize=2)
def frequency_ranks(path: str | None = None) -> dict[str, int]:
    """Base form (lower case) to frequency rank, from data/finnish_frequency_lemmas.json."""
    entries = allowed_vocab.load_entries(path) if path else allowed_vocab.load_entries()
    ranks: dict[str, int] = {}
    for entry in entries:
        ranks.setdefault(entry["lemma"].lower(), entry["rank"])
    return ranks


def within_level(lemma: str, rank_cap: int, extra: list[str], ranks: dict[str, int]) -> bool:
    key = lemma.lower()
    if key in extra:
        return True
    rank = ranks.get(key)
    return rank is not None and rank <= rank_cap
