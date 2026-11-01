"""The spoken to written word mapping of the A1 road (job 20-a1-road, "Done when" 11).

Each spoken (puhe) word is paired with the written (kirja) word it renders, in order. A pair is
accepted when

1. the two words are equal, ignoring case, or
2. the pair is in content/road/spoken-forms.tsv (a plain list of spoken and written words that a
   reader can check one by one), or
3. one of the documented ending rules applies:
   - dropped final letter: spoken is the written word without its last letter
     (mist for mistä, kaks for kaksi);
   - dropped final vowel with a shortened double consonant: Helsingis for Helsingissä, tääl for täällä;
   - vowel stretched: the written ending -ia, -oa, -ea, -ua, -iä, -yä is -ii, -oo, -ee, -uu, -ii, -yy
     in speech (kahvii for kahvia, euroo for euroa);
   - -ks for -ko or -kö (onks for onko, paljonks for paljonko);
   - after mun, sun, meidän, teidän or sen, a noun may leave out the written noun's possessive ending
     (mun äiti, written minun äitini).

Any other pair fails the line with both words named. A written word no spoken word renders fails the
line. A spoken only word is accepted only when it is a filler in the table (written side "-"). A spoken
pronoun (mä, sä, me, te) must pair with a written pronoun.

A spoken word glued to sä after a verb (Ootsä, Puhutsä) is split in two (Oot sä) for the analysis, by
one rule that logs each change. The learner sees the line as written; only the checks and the word
cards see two words, because every word links to one form.

Nothing here needs Voikko, the network or an AI service.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SPOKEN_FORMS = REPO / "content" / "road" / "spoken-forms.tsv"

# The same edge punctuation as v2's VoikkoGate.tokenize (checked against it in the Python tests).
_EDGE_PUNCT = ".,!?;:\"'“”‘’«»()[]{}…-–—/\\|*_~`"
VOWELS = "aeiouyäö"
SPOKEN_PRONOUNS = frozenset({"mä", "sä", "me", "te"})
WRITTEN_PRONOUNS = frozenset({"minä", "sinä", "me", "te"})
# Real words that end in -sä but are not a verb with a glued sä.
NOT_GLUED = frozenset({"kesä", "metsä", "yleensä", "sisä", "käsä", "vesä"})


def tokenize(text: str) -> list[str]:
    """The words of a text as VoikkoGate.tokenize splits them."""
    out = []
    for raw in text.split():
        core = raw.strip(_EDGE_PUNCT)
        if core:
            out.append(core)
    return out


class SpokenForms:
    """The table of accepted pairs and fillers, read from content/road/spoken-forms.tsv."""

    def __init__(self, pairs: dict[tuple[str, str], str], fillers: dict[str, str]):
        self.pairs = pairs
        self.fillers = fillers

    @classmethod
    def load(cls, path: Path = SPOKEN_FORMS) -> SpokenForms:
        pairs: dict[tuple[str, str], str] = {}
        fillers: dict[str, str] = {}
        for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if not raw.strip() or raw.startswith("#"):
                continue
            cells = raw.split("\t")
            if len(cells) < 2 or not cells[0].strip() or not cells[1].strip():
                raise ValueError(f"{path.name}, line {number}: needs a spoken word and a written word (or -)")
            spoken, written = cells[0].strip().lower(), cells[1].strip().lower()
            note = cells[2].strip() if len(cells) > 2 else ""
            if written == "-":
                fillers[spoken] = note
            else:
                pairs[(spoken, written)] = note
        return cls(pairs, fillers)


def _shorten_double(word: str) -> str:
    if len(word) >= 2 and word[-1] == word[-2] and word[-1] not in VOWELS:
        return word[:-1]
    return word


def ending_rule(spoken: str, written: str) -> str | None:
    """The name of the documented ending rule that turns `written` into `spoken`, or None."""
    s, w = spoken.lower(), written.lower()
    if len(w) >= 3 and s == w[:-1]:
        return "dropped final letter"
    if len(w) >= 3 and w[-1] in VOWELS and s == _shorten_double(w[:-1]) and s != w[:-1]:
        return "dropped final vowel, shortened double consonant"
    if len(w) >= 3 and w[-1] in "aä" and w[-2] in VOWELS and s == w[:-1] + w[-2]:
        return "vowel stretched at the end"
    if len(w) >= 3 and w[-2:] in ("ko", "kö") and s == w[:-2] + "ks":
        return "-ks for -ko or -kö"
    return None


POSSESSORS = frozenset({"mun", "sun", "meidän", "teidän", "sen", "niitten"})
POSSESSIVE_SUFFIXES = ("ni", "si", "mme", "nne", "nsa", "nsä")


def possessive_rule(spoken: str, written: str) -> str | None:
    """A spoken noun after mun, sun, meidän, teidän or sen leaves out the possessive ending the
    written noun has (mun äiti, written minun äitini)."""
    s, w = spoken.lower(), written.lower()
    for suffix in POSSESSIVE_SUFFIXES:
        if w in (s + suffix, s + "e" + suffix):
            return "possessive ending left out in speech"
        if s.endswith("i") and w == s[:-1] + "e" + suffix:
            return "possessive ending left out in speech"
    if s.endswith("n") and w == s + "i":
        return "possessive ending left out in speech"
    return None


def pair_rule(spoken: str, written: str, forms: SpokenForms) -> str | None:
    """How a pair is accepted: "equal", "table", an ending rule's name, or None when it is refused."""
    s, w = spoken.lower(), written.lower()
    if s == w:
        return "equal"
    if (s, w) in forms.pairs:
        return "table"
    return ending_rule(s, w)


@dataclass
class Glue:
    """One glued word split in two."""

    original: str
    first: str
    second: str


def has_question_word(written_words: list[str]) -> bool:
    """True when the written line has a verb with the question ending -ko or -kö."""
    return any(len(w) >= 4 and w.lower()[-2:] in ("ko", "kö") for w in written_words)


def split_glued_words(spoken_words: list[str], written_words: list[str]) -> tuple[list[str], list[Glue]]:
    """Split every spoken word glued to sä after a verb. Returns the new word list and the changes."""
    if not has_question_word(written_words):
        return list(spoken_words), []
    out: list[str] = []
    changes: list[Glue] = []
    for word in spoken_words:
        low = word.lower()
        if len(word) >= 4 and low.endswith("sä") and not low.endswith("ssä") and low not in NOT_GLUED:
            changes.append(Glue(word, word[:-2], word[-2:]))
            out += [word[:-2], word[-2:]]
        else:
            out.append(word)
    return out, changes


def analysis_text(spoken_text: str, written_words: list[str]) -> str:
    """The spoken text with each glued word written as two (the text the checks see)."""
    if not has_question_word(written_words):
        return spoken_text
    pieces = []
    for raw in spoken_text.split():
        core = raw.strip(_EDGE_PUNCT)
        low = core.lower()
        if len(core) >= 4 and low.endswith("sä") and not low.endswith("ssä") and low not in NOT_GLUED:
            start = raw.index(core)
            raw = raw[:start] + core[:-2] + " " + core[-2:] + raw[start + len(core) :]
        pieces.append(raw)
    return " ".join(pieces)


@dataclass
class Refusal:
    """One refused word or pair, with what the repair step needs to know."""

    kind: str  # "pair", "spoken_extra", "written_extra", "missing_pronoun"
    spoken: str
    written: str
    message: str
    written_index: int  # 1 based position of the written word the problem is at
    spoken_index: int
    after_previous: bool = False  # a glued sä: the pronoun belongs right after the verb before it


@dataclass
class LineMapping:
    """The result of mapping one line: a link per spoken word, plus what was accepted and refused."""

    links: list[int | None] = field(default_factory=list)  # 1 based written position, None for spoken only
    rules: list[str] = field(default_factory=list)  # the rule that accepted each spoken word
    refusals: list[Refusal] = field(default_factory=list)
    glued: list[Glue] = field(default_factory=list)

    @property
    def failures(self) -> list[str]:
        return [r.message for r in self.refusals]


def map_line(spoken_text: str, written_text: str, forms: SpokenForms) -> tuple[list[str], LineMapping]:
    """Map one line. Returns the spoken words (glued ones split) and the mapping.

    On a mismatch the mapping looks one word ahead on each side so that one missing or extra
    word is reported once, not as a run of wrong pairs."""
    written = tokenize(written_text)
    spoken, glued = split_glued_words(tokenize(spoken_text), written)
    mapping = LineMapping(glued=glued)
    glued_first = {g.first for g in glued}

    def accepted(s: str, w: str, first_of_glue: bool, at: int) -> str | None:
        rule = pair_rule(s, w, forms)
        if rule is None and any(word.lower() in POSSESSORS for word in spoken[:at]):
            rule = possessive_rule(s, w)
        if rule is None and first_of_glue:
            # The verb half of a glued word lost its -ko: ootko sä became oot + sä.
            for suffix in ("ko", "kö"):
                rule = pair_rule(s + suffix, w, forms)
                if rule:
                    rule = f"{rule}, with -{suffix} dropped before a glued sä"
                    break
        if rule is not None and s.lower() in SPOKEN_PRONOUNS and w.lower() not in WRITTEN_PRONOUNS:
            return None
        return rule

    i = j = 0
    while i < len(spoken) or j < len(written):
        s = spoken[i] if i < len(spoken) else None
        w = written[j] if j < len(written) else None
        if s is not None and w is not None:
            rule = accepted(s, w, s in glued_first, i)
            if rule is not None:
                mapping.links.append(j + 1)
                mapping.rules.append(rule)
                i += 1
                j += 1
                continue
        if s is not None and s.lower() in forms.fillers:
            mapping.links.append(None)
            mapping.rules.append("spoken only filler")
            i += 1
            continue
        if s is not None and w is not None:
            next_s = spoken[i + 1] if i + 1 < len(spoken) else None
            next_w = written[j + 1] if j + 1 < len(written) else None
            if next_s is not None and accepted(next_s, w, next_s in glued_first, i + 1):
                if s.lower() in SPOKEN_PRONOUNS:
                    msg = (
                        f"the spoken pronoun '{s}' has no written pronoun: add one before '{w}' "
                        "(a spoken pronoun must pair with a written pronoun)"
                    )
                    kind = "missing_pronoun"
                else:
                    msg = f"the spoken word '{s}' has no written word to render and is not a filler"
                    kind = "spoken_extra"
                mapping.refusals.append(
                    Refusal(
                        kind,
                        s,
                        w,
                        msg,
                        j + 1,
                        i + 1,
                        after_previous=bool(glued)
                        and i > 0
                        and spoken[i - 1] in glued_first
                        and s.lower() == "sä",
                    )
                )
                mapping.links.append(None)
                mapping.rules.append("refused")
                i += 1
                continue
            if next_w is not None and accepted(s, next_w, s in glued_first, i):
                mapping.refusals.append(
                    Refusal(
                        "written_extra", s, w, f"no spoken word renders the written word '{w}'", j + 1, i + 1
                    )
                )
                j += 1
                continue
            mapping.refusals.append(
                Refusal(
                    "pair",
                    s,
                    w,
                    f"the spoken word '{s}' does not match the written word '{w}'",
                    j + 1,
                    i + 1,
                )
            )
            mapping.links.append(j + 1)
            mapping.rules.append("refused")
            i += 1
            j += 1
        elif s is not None:
            mapping.refusals.append(
                Refusal(
                    "spoken_extra",
                    s,
                    "",
                    f"the spoken word '{s}' has no written word to render and is not a filler",
                    len(written) + 1,
                    i + 1,
                    after_previous=i > 0 and spoken[i - 1] in glued_first and s.lower() == "sä",
                )
            )
            mapping.links.append(None)
            mapping.rules.append("refused")
            i += 1
        else:
            assert w is not None
            mapping.refusals.append(
                Refusal(
                    "written_extra",
                    "",
                    w,
                    f"no spoken word renders the written word '{w}'",
                    j + 1,
                    len(spoken) + 1,
                )
            )
            j += 1
    return spoken, mapping
