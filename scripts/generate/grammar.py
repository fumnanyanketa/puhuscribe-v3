"""Form tags, form names, the grammar lists and the "why" rules (job 7-content-pipeline).

"Done when" 9 and 10. Everything here is fixed code; nothing is guessed.

- A form tag is built only from one Voikko reading: the attributes in TAG_ORDER,
  in that order, as KEY=value joined by ";". For example "olen" gives
  CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false
- A form's English name comes from its tag through the tables below. A Voikko
  value the tables do not know raises UnknownTagValue, which fails the check.
- A unit's grammar list is a list of ids from GRAMMAR_CATALOGUE. A form is on
  the list when it is a dictionary form (BASE) or one entry licenses its
  inflection, and one entry licenses every extra ending (question -ko/-kö,
  -kin, possessive endings, comparison).
- A "why" is one line of at most 140 characters that names no grammar term other
  than the ones in the form's own name.
"""

from __future__ import annotations

import re

# Voikko attributes that make up a form tag, in the fixed order of the tag
# (docs/content-pipeline.md). Attributes such as STRUCTURE, FSTOUTPUT and
# WORDBASES differ between Voikko versions and are left out.
TAG_ORDER = (
    "CLASS",
    "SIJAMUOTO",
    "NUMBER",
    "PERSON",
    "MOOD",
    "TENSE",
    "NEGATIVE",
    "POSSESSIVE",
    "COMPARISON",
    "PARTICIPLE",
    "KYSYMYSLIITE",
    "FOCUS",
)

# Word classes whose words are names: valid Finnish, no form, no card, and not
# held to the frequency rank cap (the same set as v2's VoikkoGate).
NAME_CLASSES = frozenset({"etunimi", "sukunimi", "paikannimi", "nimi", "erisnimi", "lyhenne"})

CLASS_NAMES = {
    "nimisana": "noun",
    "laatusana": "adjective",
    "nimisana_laatusana": "adjective",
    "asemosana": "pronoun",
    "teonsana": "verb",
    "kieltosana": "negative verb",
    "seikkasana": "adverb",
    "huudahdussana": "interjection",
    "sidesana": "conjunction",
    "suhdesana": "adposition",
    "lukusana": "numeral",
    "etuliite": "prefix",
    "lyhenne": "abbreviation",
    "etunimi": "first name",
    "sukunimi": "surname",
    "paikannimi": "place name",
    "nimi": "name",
    "erisnimi": "name",
}

CASE_NAMES = {
    "nimento": "nominative",
    "omanto": "genitive",
    "osanto": "partitive",
    "olento": "essive",
    "tulento": "translative",
    "kohdanto": "accusative",
    "sisaolento": "inessive",
    "sisaeronto": "elative",
    "sisatulento": "illative",
    "ulkoolento": "adessive",
    "ulkoeronto": "ablative",
    "ulkotulento": "allative",
    "vajanto": "abessive",
    "seuranto": "comitative",
    "keinonto": "instructive",
    "kerrontosti": "adverb form (-sti)",
}

NUMBER_NAMES = {"singular": "singular", "plural": "plural"}
PERSON_NAMES = {"1": "1st person", "2": "2nd person", "3": "3rd person", "4": "passive"}
FINITE_MOODS = {
    "indicative": None,  # named by its tense instead
    "conditional": "conditional",
    "imperative": "imperative",
    "potential": "potential",
}
INFINITIVE_MOODS = {
    "A-infinitive": "basic form (A-infinitive)",
    "E-infinitive": "E-infinitive",
    "MA-infinitive": "MA-infinitive",
    "MINEN-infinitive": "MINEN-infinitive",
    "MAINEN-infinitive": "MAINEN-infinitive",
}
TENSE_NAMES = {"present_simple": "present tense", "past_imperfective": "past tense"}
NEGATIVE_NAMES = {"false": None, "both": None, "true": "negative form"}
POSSESSIVE_NAMES = {
    "1s": "with the possessive ending for my",
    "2s": "with the possessive ending for your",
    "1p": "with the possessive ending for our",
    "2p": "with the possessive ending for your (plural)",
    "3": "with the possessive ending for his, her or their",
}
COMPARISON_NAMES = {"positive": None, "comparative": "comparative", "superlative": "superlative"}
PARTICIPLE_NAMES = {
    "present_active": "present active participle",
    "present_passive": "present passive participle",
    "past_active": "past active participle",
    "past_passive": "past passive participle",
    "agent": "agent participle",
    "negation": "negative participle",
}
QUESTION_NAMES = {"true": "with the question ending -ko/-kö"}
FOCUS_NAMES = {"kin": "with -kin (also)", "kaan": "with -kaan/-kään"}

TABLES = {
    "CLASS": CLASS_NAMES,
    "SIJAMUOTO": CASE_NAMES,
    "NUMBER": NUMBER_NAMES,
    "PERSON": PERSON_NAMES,
    "MOOD": {**FINITE_MOODS, **INFINITIVE_MOODS},
    "TENSE": TENSE_NAMES,
    "NEGATIVE": NEGATIVE_NAMES,
    "POSSESSIVE": POSSESSIVE_NAMES,
    "COMPARISON": COMPARISON_NAMES,
    "PARTICIPLE": PARTICIPLE_NAMES,
    "KYSYMYSLIITE": QUESTION_NAMES,
    "FOCUS": FOCUS_NAMES,
}


class UnknownTagValue(ValueError):
    """A Voikko value the name tables do not know. The check fails instead of guessing."""


def form_tag(reading: dict) -> str:
    """The canonical tag of one Voikko reading."""
    return ";".join(f"{key}={reading[key]}" for key in TAG_ORDER if key in reading)


def parse_tag(tag: str) -> dict:
    """The tag's attributes as a dict. Refuses keys outside TAG_ORDER or out of order."""
    if not tag:
        raise UnknownTagValue("empty form tag")
    attrs: dict[str, str] = {}
    for part in tag.split(";"):
        key, sep, value = part.partition("=")
        if not sep or key not in TAG_ORDER or not value:
            raise UnknownTagValue(f"'{part}' is not a known tag attribute")
        attrs[key] = value
    if form_tag(attrs) != tag:
        raise UnknownTagValue(f"tag '{tag}' is not in the fixed attribute order")
    return attrs


def _lookup(key: str, value: str) -> str | None:
    table = TABLES[key]
    if value not in table:
        raise UnknownTagValue(f"Voikko value {key}={value} has no English name in the table")
    return table[value]


def is_name_tag(tag: str) -> bool:
    return parse_tag(tag).get("CLASS") in NAME_CLASSES


def form_name(tag: str) -> str:
    """The English name of a form, built only from its tag."""
    attrs = parse_tag(tag)
    # Every value must be known, even ones the name does not mention.
    named = {key: _lookup(key, value) for key, value in attrs.items()}
    if "CLASS" not in attrs:
        raise UnknownTagValue(f"tag '{tag}' has no word class")
    parts: list[str] = []
    mood = attrs.get("MOOD")
    if attrs.get("PARTICIPLE"):
        parts.append(named["PARTICIPLE"] or "")
        if "SIJAMUOTO" in attrs:
            parts.append(" ".join(n for n in (named["SIJAMUOTO"], named.get("NUMBER")) if n))
    elif mood in INFINITIVE_MOODS:
        parts.append(named["MOOD"] or "")
        if "SIJAMUOTO" in attrs:
            parts.append(named["SIJAMUOTO"] or "")
    elif mood in FINITE_MOODS:
        if attrs["CLASS"] == "kieltosana":
            parts.append(named["CLASS"])
        elif mood == "indicative":
            if "TENSE" not in attrs:
                raise UnknownTagValue(f"tag '{tag}' has an indicative mood but no tense")
            parts.append(named["TENSE"] or "")
        else:
            parts.append(" ".join(n for n in (named["MOOD"], named.get("TENSE")) if n))
        person = attrs.get("PERSON")
        if person == "4":
            parts.append("passive")
        elif person:
            parts.append(" ".join(n for n in (named["PERSON"], named.get("NUMBER")) if n))
    elif "SIJAMUOTO" in attrs:
        parts.append(" ".join(n for n in (named["SIJAMUOTO"], named.get("NUMBER")) if n))
    else:
        parts.append(named["CLASS"])
    if named.get("COMPARISON"):
        parts.insert(0, named["COMPARISON"] or "")
    if named.get("NEGATIVE"):
        parts.append(named["NEGATIVE"] or "")
    for key in ("POSSESSIVE", "KYSYMYSLIITE", "FOCUS"):
        if named.get(key):
            parts.append(named[key] or "")
    return ", ".join(p for p in parts if p)


# Grammar lists ------------------------------------------------------------------

PERSONAL_PRONOUNS = frozenset({"minä", "sinä", "hän", "me", "te", "he"})
NUMBERS_1_TO_20 = frozenset(
    {
        "yksi",
        "kaksi",
        "kolme",
        "neljä",
        "viisi",
        "kuusi",
        "seitsemän",
        "kahdeksan",
        "yhdeksän",
        "kymmenen",
        "yksitoista",
        "kaksitoista",
        "kolmetoista",
        "neljätoista",
        "viisitoista",
        "kuusitoista",
        "seitsemäntoista",
        "kahdeksantoista",
        "yhdeksäntoista",
        "kaksikymmentä",
    }
)
ADD_ON_KEYS = ("KYSYMYSLIITE", "FOCUS", "POSSESSIVE")


def is_base_form(attrs: dict) -> bool:
    """A dictionary form: nominative singular, the A-infinitive, or an uninflected word."""
    if any(key in attrs for key in ADD_ON_KEYS):
        return False
    if attrs.get("COMPARISON") in ("comparative", "superlative"):
        return False
    if "PARTICIPLE" in attrs:
        return False
    if "MOOD" in attrs:
        return attrs["MOOD"] == "A-infinitive" and "SIJAMUOTO" not in attrs and "PERSON" not in attrs
    if "SIJAMUOTO" in attrs:
        return attrs["SIJAMUOTO"] == "nimento" and attrs.get("NUMBER", "singular") == "singular"
    return True


# Each entry: a description for the drafting prompt and the reviewer, a test of
# the inflection it licenses (or None), and the extra endings it licenses.
GRAMMAR_CATALOGUE: dict[str, dict] = {
    "olla-present": {
        "en": "olla (to be) in the present tense, every person (olen, olet, on, olemme, olette, ovat)",
        "core": lambda lemma, a: (
            lemma == "olla"
            and a.get("CLASS") == "teonsana"
            and a.get("MOOD") == "indicative"
            and a.get("TENSE") == "present_simple"
            and a.get("NEGATIVE") == "false"
        ),
        "add_ons": {},
    },
    "personal-pronouns": {
        "en": "the personal pronouns in their basic form (minä, sinä, hän, me, te, he)",
        "core": lambda lemma, a: (
            a.get("CLASS") == "asemosana" and lemma in PERSONAL_PRONOUNS and a.get("SIJAMUOTO") == "nimento"
        ),
        "add_ons": {},
    },
    "inessive-elative": {
        "en": "the endings -ssa/-ssä (in) and -sta/-stä (from), singular or plural",
        "core": lambda lemma, a: a.get("SIJAMUOTO") in ("sisaolento", "sisaeronto"),
        "add_ons": {},
    },
    "question-clitic": {
        "en": "yes or no questions with the ending -ko/-kö (oletko, onko)",
        "core": None,
        "add_ons": {"KYSYMYSLIITE": {"true"}},
    },
    # Unit 2 (PRD section 6), added in job 12-units-1-3.
    "partitive-singular": {
        "en": "the partitive singular for an amount of something (kahvia, pullaa, euroa)",
        "core": lambda lemma, a: a.get("SIJAMUOTO") == "osanto" and a.get("NUMBER") == "singular",
        "add_ons": {},
    },
    "numbers-1-20": {
        "en": (
            "the numbers 1 to 20 (yksi, kaksi, kolme ... kaksikymmentä), in their basic form or the partitive"
        ),
        "core": lambda lemma, a: (
            a.get("CLASS") == "lukusana"
            and lemma in NUMBERS_1_TO_20
            and a.get("SIJAMUOTO") in ("nimento", "osanto")
            and a.get("NUMBER", "singular") == "singular"
        ),
        "add_ons": {},
    },
    "saisinko": {
        "en": "saisinko (could I have), saada in the conditional, 1st person singular, as a polite request",
        "core": lambda lemma, a: (
            lemma == "saada"
            and a.get("CLASS") == "teonsana"
            and a.get("MOOD") == "conditional"
            and a.get("PERSON") == "1"
            and a.get("NUMBER") == "singular"
            and a.get("NEGATIVE") == "false"
        ),
        "add_ons": {"KYSYMYSLIITE": {"true"}},
    },
    # Unit 3 (PRD section 6), added in job 12-units-1-3.
    "missa-on": {
        "en": "missä on ...? (where is ...?): missä, the -ssa form of mikä, with on",
        "core": lambda lemma, a: lemma == "mikä" and a.get("SIJAMUOTO") == "sisaolento",
        "add_ons": {},
    },
    "adessive-allative": {
        "en": (
            "the endings -lla/-llä (on, at, has) and -lle (onto, to), singular or plural "
            "(hyllyllä, kassalle, teillä)"
        ),
        "core": lambda lemma, a: a.get("SIJAMUOTO") in ("ulkoolento", "ulkotulento"),
        "add_ons": {},
    },
    "tuolla-tassa": {
        "en": "tuolla (over there) and tässä (here, right here)",
        "core": lambda lemma, a: (
            (lemma == "tuo" and a.get("SIJAMUOTO") == "ulkoolento")
            or (lemma == "tämä" and a.get("SIJAMUOTO") == "sisaolento")
        ),
        "add_ons": {},
    },
}


def on_grammar_list(lemma: str, tag: str, grammar: list[str]) -> bool:
    attrs = parse_tag(tag)
    entries = [GRAMMAR_CATALOGUE[g] for g in grammar]
    core_attrs = {k: v for k, v in attrs.items() if k not in ADD_ON_KEYS}
    core_ok = is_base_form(core_attrs) or any(
        e["core"] and e["core"](lemma.lower(), core_attrs) for e in entries
    )
    if not core_ok:
        return False
    for key in ADD_ON_KEYS:
        if key in attrs and not any(attrs[key] in e["add_ons"].get(key, set()) for e in entries):
            return False
    return True


# "Why" lines ----------------------------------------------------------------------

WHY_MAX = 140  # the database's own limit (forms.why_en)

GRAMMAR_TERMS = sorted(
    {
        *CASE_NAMES.values(),
        "singular",
        "plural",
        "1st person",
        "2nd person",
        "3rd person",
        "first person",
        "second person",
        "third person",
        "present tense",
        "past tense",
        "imperfect",
        "perfect",
        "pluperfect",
        "indicative",
        "conditional",
        "imperative",
        "potential",
        "infinitive",
        "participle",
        "passive",
        "possessive",
        "comparative",
        "superlative",
        "clitic",
        "connegative",
        "consonant gradation",
        "vowel harmony",
        "declension",
        "conjugation",
    }
    - {"adverb form (-sti)"}
)

# Spelled-out words for a term the name writes another way.
SAME_TERM = {"first person": "1st person", "second person": "2nd person", "third person": "3rd person"}


def _mentions(text: str, term: str) -> bool:
    return re.search(r"\b" + re.escape(term) + r"\b", text, re.IGNORECASE) is not None


_CONTROL = re.compile(r"[\x00-\x1f\x7f]")


def why_problems(why: str, name: str) -> list[str]:
    """Plain reasons a "why" line breaks the rules, or [] when it is fine."""
    problems = []
    if not why or not why.strip():
        return ["the why line is empty"]
    if _CONTROL.search(why):
        problems.append("the why line has a line break or another control character")
    if len(why) > WHY_MAX:
        problems.append(f"the why line is {len(why)} characters, over the limit of {WHY_MAX}")
    for term in GRAMMAR_TERMS:
        if _mentions(why, term) and not _mentions(name, SAME_TERM.get(term, term)):
            problems.append(f"the why line names the grammar term '{term}', which is not this form's own")
    return problems
