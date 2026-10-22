"""Brief to checked dialogue draft (job 7-content-pipeline, "Done when" 2, 8, 10 and 11).

The loop, modelled on v2's generate.py (which stays unchanged and unused):

1. The AI drafts the dialogue: written and spoken Finnish, the English meaning,
   and which written word each spoken word renders.
2. Voikko checks every written word; the links and the level are checked.
3. If anything failed, the AI drafts again with each failure named. At most
   MAX_ROUNDS rounds in all.
4. The AI picks, for each word, one of Voikko's own readings by number and
   writes the one line "why". It cannot add a reading.
5. The AI judge says whether each line's spoken and written versions mean the
   same. The verdict is stored with the line's fingerprint.
6. Every automatic check runs. A failure goes back to step 1 while rounds remain.

All AI calls go through providers/ai.py, which logs each one with its cost.
"""

from __future__ import annotations

from analysis import candidates, is_word, tokens, within_level
from content_checks import run_checks
from fingerprints import form_id, line_fingerprint
from grammar import GRAMMAR_CATALOGUE, UnknownTagValue, form_name, on_grammar_list
from providers.ai import MODELS

MAX_ROUNDS = 3
DRAFT_FORMAT = "puhuscribe-draft-1"


class DraftFailed(RuntimeError):
    """The draft still fails a check after the last round. Holds the plain failure list."""

    def __init__(self, failures: list[str], draft: dict | None = None):
        super().__init__("the draft still fails after the last round")
        self.failures = failures
        self.draft = draft


DRAFT_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["lines"],
    "properties": {
        "lines": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["speaker", "text_kirja", "text_puhe", "gloss_en", "puhe_links"],
                "properties": {
                    "speaker": {"type": "string"},
                    "text_kirja": {"type": "string"},
                    "text_puhe": {"type": "string"},
                    "gloss_en": {"type": "string"},
                    "puhe_links": {"type": "array", "items": {"type": "integer"}},
                },
            },
        }
    },
}

LINKS_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["lines"],
    "properties": {
        "lines": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["n", "puhe_links"],
                "properties": {
                    "n": {"type": "integer"},
                    "puhe_links": {"type": "array", "items": {"type": "integer"}},
                },
            },
        }
    },
}

WHY_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["words"],
    "properties": {
        "words": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["id", "reading", "why_en"],
                "properties": {
                    "id": {"type": "string"},
                    "reading": {"type": "integer"},
                    "why_en": {"type": "string"},
                },
            },
        }
    },
}

JUDGE_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["verdicts"],
    "properties": {
        "verdicts": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["n", "same_meaning", "reason"],
                "properties": {
                    "n": {"type": "integer"},
                    "same_meaning": {"type": "boolean"},
                    "reason": {"type": "string"},
                },
            },
        }
    },
}

DRAFT_SYSTEM = """You write short Finnish dialogues for adults who have just moved to Finland \
and are learning Finnish from zero (CEFR A1). Each line has three parts:
- text_puhe: spoken Finnish (puhekieli), standard spoken Finnish as an adult in Helsinki speaks it \
in 2026 (yleispuhekieli). No dialect, no dated or rare slang.
- text_kirja: written standard Finnish (kirjakieli) with exactly the same meaning.
- gloss_en: a short, natural English meaning.

Rules:
1. Write exactly the number of lines asked for. Use only the speakers given.
2. Written Finnish uses only base forms from the allowed vocabulary, the speakers' names and \
well known Finnish or world place names. Every word must be a real, correctly inflected standard \
Finnish word. Never invent a word or a form.
3. Use only these forms: dictionary forms (nominative singular, the basic form of a verb, \
words that do not inflect) and the grammar listed in the request. No other inflection.
4. The spoken line renders the written line word by word. Each written word is rendered by \
exactly one spoken word, in its spoken shape (minä: mä, olen: oon, mistä: mist). Keep words \
apart (write "ootko sä", never "ootsä"). A spoken only word such as "no" is allowed, rarely.
5. puhe_links: one number for each spoken word, in order. Words are separated by spaces and \
punctuation does not count. The number is the position of the written word it renders \
(1 is the first written word), or 0 for a spoken only word.
6. Natural, everyday, kind. A real situation, never a word list."""

WHY_SYSTEM = """You help build word cards for adult beginners learning Finnish. For each written \
Finnish word you get the line it is in and Voikko's readings of it, numbered. Choose the number of \
the reading that is meant in this line. You can only choose one of the numbers given.
Then write why_en: one line of plain English, at most 140 characters, saying what this form does \
in this line, for a beginner. Use no grammar term except words from the chosen reading's own \
name. No mnemonics, no jokes, never shaming. For a name (first name, surname, place name) write \
an empty why_en."""

JUDGE_SYSTEM = """You check Finnish dialogue lines for a language course. Each line has a spoken \
version (puhekieli) and a written version (kirjakieli). Say for each line whether the two versions \
mean the same thing. Differences of register are expected and fine: mä and minä, oon and olen, \
mist and mistä, dropped endings, spoken only words like "no". They differ in meaning when a \
number, a negation, a person or pronoun, a place, a time, a thing or a fact differs, or when \
information is added or missing. Give a short reason in English."""


def grammar_text(grammar: list[str]) -> str:
    return "\n".join(f"- {GRAMMAR_CATALOGUE[g]['en']}" for g in grammar)


def vocabulary(brief: dict, ranks: dict[str, int]) -> list[str]:
    words = sorted((rank, lemma) for lemma, rank in ranks.items() if rank <= brief["rank_cap"])
    return [lemma for _, lemma in words] + [w for w in brief["extra_base_forms"] if w not in ranks]


def draft_prompt(brief: dict, ranks: dict[str, int], feedback: list[str]) -> str:
    speakers = "\n".join(f"- {s['name']}: {s['role_en']}" for s in brief["speakers"])
    text = (
        f"Unit: {brief['unit']['title_en']}. Can do: {brief['unit']['can_do_en']}\n"
        f"Dialogue: {brief['dialogue']['title_en']}\n"
        f"Situation: {brief['situation_en']}\n"
        f"Speakers:\n{speakers}\n"
        f"Number of lines: {brief['line_count']}\n\n"
        f"Grammar allowed besides dictionary forms:\n{grammar_text(brief['grammar'])}\n\n"
        "Allowed vocabulary (base forms, use them in any allowed form):\n"
        f"{', '.join(vocabulary(brief, ranks))}"
    )
    if feedback:
        problems = "\n".join(f"- {f}" for f in feedback)
        text += (
            f"\n\nThe previous draft failed these checks. Write a new draft that fixes every one:\n{problems}"
        )
    return text


def lines_from_answer(answer: dict, gate) -> list[dict]:
    lines = []
    for n, raw in enumerate(answer.get("lines", []), start=1):
        line = {
            "n": n,
            "speaker": str(raw.get("speaker", "")),
            "text_puhe": str(raw.get("text_puhe", "")).strip(),
            "text_kirja": str(raw.get("text_kirja", "")).strip(),
            "gloss_en": str(raw.get("gloss_en", "")).strip(),
        }
        set_links(line, raw.get("puhe_links", []), gate)
        lines.append(line)
    return lines


def set_links(line: dict, links: list, gate) -> None:
    """Fill the line's word lists from its texts and the AI's links (kept as given;
    the checks refuse a wrong count or a broken link)."""
    line["kirja_tokens"] = [{"surface": s} for s in tokens(gate, line["text_kirja"])]
    puhe_words = tokens(gate, line["text_puhe"])
    line["puhe_tokens"] = []
    line["link_count_ok"] = len(links) == len(puhe_words)
    for i, surface in enumerate(puhe_words):
        link = links[i] if i < len(links) else None
        if link == 0:
            line["puhe_tokens"].append({"surface": surface, "spoken_only": True})
        else:
            line["puhe_tokens"].append({"surface": surface, "kirja": link})


def pre_check(lines: list[dict], brief: dict, gate, ranks: dict[str, int]) -> list[str]:
    """The checks that need no reading choice: run before paying for the "why" and judge calls."""
    failures = []
    if len(lines) != brief["line_count"]:
        failures.append(f"the dialogue has {len(lines)} lines; it must have {brief['line_count']}")
    speakers = {s["name"] for s in brief["speakers"]}
    for line in lines:
        where = f"line {line['n']}"
        if line["speaker"] not in speakers:
            failures.append(
                f"{where}: speaker '{line['speaker']}' is not one of {', '.join(sorted(speakers))}"
            )
        if not (line["text_puhe"] and line["text_kirja"] and line["gloss_en"]):
            failures.append(
                f"{where}: the spoken text, the written text and the English meaning are all needed"
            )
        if not line.pop("link_count_ok", True):
            failures.append(f"{where}: puhe_links must have one number for each spoken word")
        kirja = line["kirja_tokens"]
        rendered = [0] * len(kirja)
        for tok in line["puhe_tokens"]:
            target = tok.get("kirja")
            if tok.get("spoken_only"):
                continue
            if not isinstance(target, int) or not 1 <= target <= len(kirja):
                failures.append(
                    f"{where}: the spoken word '{tok['surface']}' links to a written word that is missing"
                )
            else:
                rendered[target - 1] += 1
        for tok, count in zip(kirja, rendered, strict=True):
            if count != 1:
                failures.append(
                    f"{where}: the written word '{tok['surface']}' must be rendered by exactly one "
                    "spoken word "
                    f"(now {count})"
                )
        for tok in kirja:
            surface = tok["surface"]
            if not is_word(gate, surface):
                continue
            result = gate.check_token(surface)
            if not result or not result.valid:
                failures.append(f"{where}: '{surface}' is not a real Finnish word (Voikko does not know it)")
                continue
            options = candidates(gate, surface)
            fits = [
                c
                for c in options
                if c["name"]
                or (
                    within_level(c["lemma"], brief["rank_cap"], brief["extra_base_forms"], ranks)
                    and on_grammar_list(c["lemma"], c["form_tag"], brief["grammar"])
                )
            ]
            if not fits:
                failures.append(
                    f"{where}: '{surface}' is outside the unit's level (its base form is too rare, "
                    "or its form is not on the grammar list)"
                )
    return failures


def _reading_label(candidate: dict) -> str:
    try:
        name = form_name(candidate["form_tag"])
    except UnknownTagValue:
        name = candidate["form_tag"]
    return f"{candidate['lemma']}: {name}"


def why_prompt(lines: list[dict], gate, only: set[int] | None = None) -> tuple[str, dict]:
    """The prompt for the reading choice and "why" lines, and the candidates per word id."""
    options: dict[str, list[dict]] = {}
    parts = []
    for line in lines:
        if only is not None and line["n"] not in only:
            continue
        parts.append(f'Line {line["n"]}: written "{line["text_kirja"]}", spoken "{line["text_puhe"]}"')
        for i, tok in enumerate(line["kirja_tokens"], start=1):
            if not is_word(gate, tok["surface"]):
                continue
            word_id = f"L{line['n']}.W{i}"
            found = candidates(gate, tok["surface"])
            options[word_id] = found
            spoken = next((p["surface"] for p in line["puhe_tokens"] if p.get("kirja") == i), "")
            readings = "; ".join(f"{k}. {_reading_label(c)}" for k, c in enumerate(found, start=1))
            parts.append(f'  {word_id} "{tok["surface"]}" (spoken "{spoken}"): {readings}')
    return "\n".join(parts), options


def apply_readings(lines: list[dict], answer: dict, options: dict[str, list[dict]]) -> tuple[dict, list[str]]:
    """Set each word's reading from the AI's choice. Returns the "why" per word id and the failures."""
    failures = []
    whys: dict[str, str] = {}
    chosen = {str(w.get("id")): w for w in answer.get("words", [])}
    for line in lines:
        for i, tok in enumerate(line["kirja_tokens"], start=1):
            word_id = f"L{line['n']}.W{i}"
            if word_id not in options:
                continue
            choice = chosen.get(word_id)
            found = options[word_id]
            if choice is None:
                failures.append(f"line {line['n']}: no reading was chosen for '{tok['surface']}'")
                continue
            number = choice.get("reading")
            if not isinstance(number, int) or isinstance(number, bool) or not 1 <= number <= len(found):
                failures.append(
                    f"line {line['n']}: the reading chosen for '{tok['surface']}' ({number}) is not one of "
                    f"Voikko's {len(found)} readings"
                )
                continue
            reading = found[number - 1]
            tok.update(
                {
                    "lemma": reading["lemma"],
                    "form_tag": reading["form_tag"],
                    "name": reading["name"],
                    "analysis": reading["reading"],
                }
            )
            whys[word_id] = str(choice.get("why_en", "")).strip()
    return whys, failures


def build_forms(lines: list[dict], previous: list[dict], whys: dict[str, str], gate) -> list[dict]:
    """Link every non-name written word to its form. Forms that already exist keep their
    "why" (it may carry the reviewer's fix); new forms take the AI's "why"."""
    old = {f["id"]: f for f in previous}
    forms: dict[str, dict] = {}
    for line in lines:
        for i, tok in enumerate(line["kirja_tokens"], start=1):
            if not is_word(gate, tok["surface"]) or "form_tag" not in tok or tok.get("name"):
                tok["form"] = None
                continue
            spoken = next((p["surface"] for p in line["puhe_tokens"] if p.get("kirja") == i), "")
            form = {
                "lemma": tok["lemma"],
                "form_tag": tok["form_tag"],
                "surface_kirja": tok["surface"].lower(),
                "surface_puhe": spoken.lower(),
            }
            fid = form_id(form)
            tok["form"] = fid
            if fid in forms:
                continue
            if fid in old:
                forms[fid] = old[fid]
                continue
            try:
                name = form_name(tok["form_tag"])
            except UnknownTagValue:
                name = ""
            forms[fid] = {
                "id": fid,
                **form,
                "analysis": tok.get("analysis", {}),
                "form_name_en": name,
                "why_en": whys.get(f"L{line['n']}.W{i}", ""),
            }
    return list(forms.values())


def judge_lines(ai, dialogue: str, lines: list[dict], only: set[int] | None = None) -> list[str]:
    """Ask the judge about each line and store the verdict with the line's fingerprint."""
    asked = [line for line in lines if only is None or line["n"] in only]
    prompt = "\n".join(
        f'Line {line["n"]}: spoken "{line["text_puhe"]}" | written "{line["text_kirja"]}"' for line in asked
    )
    answer = ai.complete_json(
        purpose="judge", dialogue=dialogue, system=JUDGE_SYSTEM, prompt=prompt, schema=JUDGE_SCHEMA
    )
    verdicts = {v.get("n"): v for v in answer.get("verdicts", [])}
    failures = []
    for line in asked:
        verdict = verdicts.get(line["n"])
        if verdict is None:
            line.pop("judge", None)
            failures.append(f"line {line['n']}: the judge gave no verdict")
            continue
        line["judge"] = {
            "faithful": verdict.get("same_meaning") is True,
            "reason": str(verdict.get("reason", "")),
            "fingerprint": line_fingerprint(line),
            "model": MODELS["judge"],
        }
    return failures


def enrich(draft: dict, ai, gate, only: set[int] | None = None) -> list[str]:
    """Reading choice, "why" lines, forms and the judge, for every line or only some."""
    dialogue = draft["brief"]["dialogue"]["slug"]
    prompt, options = why_prompt(draft["lines"], gate, only)
    failures: list[str] = []
    whys: dict[str, str] = {}
    if options:
        answer = ai.complete_json(
            purpose="why", dialogue=dialogue, system=WHY_SYSTEM, prompt=prompt, schema=WHY_SCHEMA
        )
        whys, failures = apply_readings(draft["lines"], answer, options)
    draft["forms"] = build_forms(draft["lines"], draft.get("forms", []), whys, gate)
    failures += judge_lines(ai, dialogue, draft["lines"], only)
    return failures


def new_draft(brief: dict, brief_path: str, providers: dict) -> dict:
    return {
        "format": DRAFT_FORMAT,
        "brief_path": brief_path,
        "brief": brief,
        "providers": providers,
        "lines": [],
        "forms": [],
    }


def draft_dialogue(
    brief: dict, brief_path: str, ai, gate, ranks: dict[str, int], thresholds: dict, log=print
) -> tuple[dict, dict]:
    """Run the loop. Returns (draft, check report), or raises DraftFailed with the failures."""
    dialogue = brief["dialogue"]["slug"]
    feedback: list[str] = []
    draft = None
    for round_number in range(1, MAX_ROUNDS + 1):
        log(f"Round {round_number}: drafting")
        answer = ai.complete_json(
            purpose="draft",
            dialogue=dialogue,
            system=DRAFT_SYSTEM,
            prompt=draft_prompt(brief, ranks, feedback),
            schema=DRAFT_SCHEMA,
        )
        draft = new_draft(brief, brief_path, {"ai": ai.name})
        draft["lines"] = lines_from_answer(answer, gate)
        feedback = pre_check(draft["lines"], brief, gate, ranks)
        if feedback:
            log(f"Round {round_number}: {len(feedback)} problems before the word cards")
            for problem in feedback:
                log(f"  {problem}")
            continue
        log(f"Round {round_number}: choosing readings, writing the why lines, judging")
        feedback = enrich(draft, ai, gate)
        report = run_checks(draft, gate, ranks, thresholds)
        feedback += report["failures"]
        if not feedback:
            draft["rounds"] = round_number
            return draft, report
        log(f"Round {round_number}: {len(feedback)} checks failed")
        for problem in feedback:
            log(f"  {problem}")
    raise DraftFailed(feedback, draft)
