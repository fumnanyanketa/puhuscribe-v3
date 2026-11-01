"""The A1 road importer (job 20-a1-road, statements 8 to 17). Needs Linux with Voikko.

python scripts/generate/road_import.py import [--out <folder>] [--part N]
    Reads docs/curriculum-a1.md and content/written/part-1.md to part-6.md, maps each spoken word to its
    written word, asks Voikko about every written word, runs the free checks and writes a draft for every
    dialogue (content/drafts/<slug>/draft.json, in the puhuscribe-draft-1 format) into the folder. It also
    writes the check report, the list of word notes still missing and the files the notes are written in.
    No AI call is made and no network is needed.

python scripts/generate/road_import.py analyse [--out <folder>]
    Counts, for every stop, the words above each candidate frequency rank cap and the forms outside the
    grammar list, to choose the part's rank cap and to record the extras.

python scripts/generate/road_import.py count-characters [--part N]
    Prints the exact number of characters the voices must read for a part or for the road.

python scripts/generate/road_import.py voice --part N
    Reads both versions of every line of the part with the Azure voice, inside the free allowance.

python scripts/generate/road_import.py judge [--part N]
    Runs the register judge on the lines, after the golden set. Needs the Anthropic key.
"""

from __future__ import annotations

import argparse
import copy
import json
import sys
from collections import defaultdict
from pathlib import Path

from analysis import candidates, frequency_ranks, is_word, within_level
from brief import validate_brief
from content_checks import load_thresholds
from fingerprints import form_id
from grammar import UnknownTagValue, form_name, is_base_form, on_grammar_list, parse_tag
from road_checks import check_draft, judged_line, line_judge_fingerprint, pending_forms
from road_data import FIXED_WHY, RoadData, RoadDataError, load_road_data, note_problems
from road_extras import register_road_extras
from road_mapping import SpokenForms, map_line, tokenize
from road_markdown import token_spans
from road_parse import REPO, Road, RoadDialogue, RoadStop, parse_road

DRAFTS = REPO / "content" / "drafts"
BRIEFS = REPO / "content" / "briefs"
DRAFT_FORMAT = "puhuscribe-draft-1"
RANK_LADDER = (1500, 2000, 2500, 3000, 4000, 5000, 6000, 8000, 10000, 15000, 20000, 50000)
MAX_EXTRA_WORDS_PER_STOP = 15


class Context:
    """Everything the importer reads once: the road, its settings, the notes and the checkers."""

    def __init__(self, gate=None, ranks=None, thresholds=None, repo: Path = REPO):
        self.repo = repo
        register_road_extras(repo / "content" / "road" / "allowed-extras.json")
        self.data: RoadData = load_road_data(repo / "content" / "road")
        self.spoken_forms = SpokenForms.load(repo / "content" / "road" / "spoken-forms.tsv")
        self.gate = gate
        self.ranks = ranks if ranks is not None else frequency_ranks()
        self.thresholds = thresholds if thresholds is not None else load_thresholds()
        self.earlier = self._earlier_drafts()
        self.road: Road = parse_road(
            repo / "docs" / "curriculum-a1.md",
            repo / "content" / "written",
            {stop: self._earlier_positions(stop) for stop in range(1, 37)},
        )
        # The "why" and name of forms the six earlier drafts already carry stay as they are.
        self.existing_forms: dict[str, dict] = {}
        for draft in self.earlier.values():
            for form in draft["forms"]:
                self.existing_forms.setdefault(form["id"], form)

    def _earlier_drafts(self) -> dict[str, dict]:
        found = {}
        for stop in self.data.stops.values():
            for slug in stop.earlier_dialogues:
                path = self.repo / "content" / "drafts" / slug / "draft.json"
                found[slug] = json.loads(path.read_text(encoding="utf-8"))
        return found

    def _earlier_positions(self, stop: int) -> list[tuple[int, str]]:
        return [
            (self.earlier[slug]["brief"]["dialogue"]["position"], slug)
            for slug in self.data.stops[stop].earlier_dialogues
        ]

    def stop_of(self, number: int) -> RoadStop:
        return self.road.stops[number]


# The brief ------------------------------------------------------------------------------


def road_brief(dialogue: RoadDialogue, ctx: Context) -> dict:
    stop = ctx.stop_of(dialogue.stop)
    settings = ctx.data.stops[stop.number]
    names: list[str] = []
    for line in dialogue.lines:
        if line.speaker not in names:
            names.append(line.speaker)
    missing = [n for n in names if n not in ctx.data.speakers]
    if missing:
        raise RoadDataError(f"dialogue {dialogue.label}: no voice in speakers.json for {', '.join(missing)}")
    voices = [ctx.data.speakers[n] for n in names]
    if len(set(voices)) != len(voices):
        raise RoadDataError(f"dialogue {dialogue.label}: two speakers share one voice")
    return validate_brief(
        {
            "unit": {
                "slug": settings.unit_slug,
                "position": stop.number,
                "title_en": stop.name,
                "can_do_en": stop.can_do,
            },
            "dialogue": {"slug": dialogue.slug, "position": dialogue.position, "title_en": dialogue.title},
            "situation_en": dialogue.situation,
            "grammar": ctx.data.cumulative_grammar(stop.number),
            "rank_cap": settings.rank_cap,
            "extra_base_forms": ctx.data.stop_extra_base_forms(stop.number),
            "speakers": [{"name": n, "voice": ctx.data.speakers[n]} for n in names],
            "line_count": len(dialogue.lines),
            "source": "written",
        }
    )


# The lines -----------------------------------------------------------------------------


def make_lines(dialogue: RoadDialogue, ctx: Context) -> list[dict]:
    lines = []
    for road_line in dialogue.lines:
        spoken, mapping = map_line(road_line.puhe, road_line.kirja, ctx.spoken_forms)
        glued = {g.first: g.original for g in mapping.glued} | {g.second: g.original for g in mapping.glued}
        puhe_tokens = []
        for surface, link in zip(spoken, mapping.links, strict=True):
            token: dict = {"surface": surface}
            if link is None:
                token["spoken_only"] = True
            else:
                token["kirja"] = link
            if surface in glued and mapping.glued:
                token["glued"] = glued[surface]
            puhe_tokens.append(token)
        lines.append(
            {
                "n": road_line.n,
                "speaker": road_line.speaker,
                "text_puhe": road_line.puhe,
                "text_kirja": road_line.kirja,
                "gloss_en": road_line.en,
                "kirja_tokens": [{"surface": s} for s in tokenize(road_line.kirja)],
                "puhe_tokens": puhe_tokens,
            }
        )
    return lines


def _capital_mid_sentence(text: str, index: int) -> bool:
    """True when the index'th word starts with a capital letter in the middle of a sentence."""
    spans = token_spans(text)
    if index >= len(spans):
        return False
    start, end = spans[index]
    if not text[start:end][:1].isupper():
        return False
    before = text[:start].rstrip()
    return before != "" and before[-1] not in ".!?"


def choose_reading(
    surface: str, options: list[dict], brief: dict, ctx: Context, mid_sentence_capital: bool
) -> dict | None:
    """One of Voikko's own readings, by fixed rules (no AI): an override, then names for a capital in
    the middle of a sentence, then a reading that fits the stop's level, then a dictionary form."""
    if not options:
        return None
    override = ctx.data.overrides.get(surface.lower())
    if override:
        for option in options:
            if (option["lemma"], option["form_tag"]) == override:
                return option
        raise RoadDataError(f"reading-overrides.tsv: '{surface}' has no Voikko reading {override}")
    names = [o for o in options if o["name"]]
    others = [o for o in options if not o["name"]]
    pool = names if (mid_sentence_capital and names) or not others else others

    def rank(option: dict) -> tuple:
        if option["name"]:
            fits = True
        else:
            try:
                fits = within_level(
                    option["lemma"], brief["rank_cap"], brief["extra_base_forms"], ctx.ranks
                ) and on_grammar_list(option["lemma"], option["form_tag"], brief["grammar"])
            except UnknownTagValue:
                fits = False
        base = is_base_form(parse_tag(option["form_tag"]))
        return (
            0 if fits else 1,
            0 if base else 1,
            len(option["form_tag"]),
            option["form_tag"],
            option["lemma"],
        )

    return min(pool, key=rank)


def add_readings(lines: list[dict], brief: dict, ctx: Context) -> None:
    for line in lines:
        for index, token in enumerate(line["kirja_tokens"]):
            surface = token["surface"]
            if not is_word(ctx.gate, surface):
                continue
            chosen = choose_reading(
                surface,
                candidates(ctx.gate, surface),
                brief,
                ctx,
                _capital_mid_sentence(line["text_kirja"], index),
            )
            if chosen is None:
                continue
            token.update(
                {
                    "lemma": chosen["lemma"],
                    "form_tag": chosen["form_tag"],
                    "name": chosen["name"],
                    "analysis": chosen["reading"],
                }
            )


# The forms and their texts --------------------------------------------------------------


def is_plain_dictionary_form(form: dict) -> bool:
    """A dictionary form that sounds the same in speech: it needs no note of its own."""
    return (
        form["surface_kirja"] == form["lemma"].lower()
        and form["surface_puhe"] == form["surface_kirja"]
        and is_base_form(parse_tag(form["form_tag"]))
    )


def form_texts(form: dict, ctx: Context) -> dict:
    """The meaning, the dictionary form meaning and the why of a form, from the road files."""
    lemma_meaning = ctx.data.glossary.get(form["lemma"], "")
    note = ctx.data.notes.get(form["id"], {})
    existing = ctx.existing_forms.get(form["id"], {})
    plain = is_plain_dictionary_form(form)
    meaning = existing.get("meaning_en") or note.get("meaning_en") or (lemma_meaning if plain else "")
    why = existing.get("why_en") or note.get("why_en") or (FIXED_WHY["dictionary-same"] if plain else "")
    return {"meaning_en": meaning, "lemma_meaning_en": lemma_meaning, "why_en": why}


def build_forms(lines: list[dict], ctx: Context) -> list[dict]:
    """Link every non-name written word to its form. The lemma is Voikko's base form of the written
    word the spoken word is paired with: Voikko cannot analyse spoken Finnish."""
    forms: dict[str, dict] = {}
    for line in lines:
        for i, token in enumerate(line["kirja_tokens"], start=1):
            if not is_word(ctx.gate, token["surface"]) or "form_tag" not in token or token.get("name"):
                token["form"] = None
                continue
            spoken = next((p["surface"] for p in line["puhe_tokens"] if p.get("kirja") == i), "")
            identity = {
                "lemma": token["lemma"],
                "form_tag": token["form_tag"],
                "surface_kirja": token["surface"].lower(),
                "surface_puhe": spoken.lower(),
            }
            fid = form_id(identity)
            token["form"] = fid
            if fid in forms:
                continue
            try:
                name = form_name(token["form_tag"])
            except UnknownTagValue:
                name = ""
            form = {"id": fid, **identity, "analysis": token.get("analysis", {}), "form_name_en": name}
            existing = ctx.existing_forms.get(fid)
            if existing:
                form["form_name_en"] = existing.get("form_name_en", name)
            form.update(form_texts({**identity, "id": fid}, ctx))
            forms[fid] = form
    return list(forms.values())


def keep_audio_and_verdicts(draft: dict, previous: dict | None) -> None:
    """A re-import keeps the clips and the judge's verdicts of lines whose texts did not change."""
    if not previous:
        return
    draft["providers"]["voice"] = previous.get("providers", {}).get("voice")
    if draft["providers"]["voice"] is None:
        del draft["providers"]["voice"]
    before = {line["n"]: line for line in previous["lines"]}
    kept_verdicts = 0
    for line in draft["lines"]:
        old = before.get(line["n"])
        if not old:
            continue
        for register in ("puhe", "kirja"):
            clip = old.get("audio", {}).get(register)
            if clip and clip.get("text") == line[f"text_{register}"]:
                line.setdefault("audio", {})[register] = clip
        verdict = old.get("judge")
        if verdict and verdict.get("fingerprint") == line_judge_fingerprint(line):
            line["judge"] = verdict
            kept_verdicts += 1
    if previous.get("providers", {}).get("judge") == "on":
        draft["providers"]["judge"] = "on"


def build_draft(dialogue: RoadDialogue, ctx: Context, previous: dict | None = None) -> dict:
    brief = road_brief(dialogue, ctx)
    lines = make_lines(dialogue, ctx)
    add_readings(lines, brief, ctx)
    forms = build_forms(lines, ctx)
    missing = [f["id"] for f in forms if not (f["meaning_en"] and f["lemma_meaning_en"] and f["why_en"])]
    draft = {
        "format": DRAFT_FORMAT,
        "brief_path": dialogue.file,
        "brief": brief,
        "providers": {"ai": "written", "judge": "off"},
        "notes": {"status": "pending" if missing else "complete"},
        "lines": lines,
        "forms": forms,
    }
    keep_audio_and_verdicts(draft, previous)
    return draft


# The earlier six drafts ---------------------------------------------------------------------


def update_earlier_draft(draft: dict, ctx: Context) -> dict:
    """Statement 17: the lines, tokens, why lines and audio stay as committed. The forms gain their two
    meanings and the unit block takes the road's name and I can sentence."""
    updated = copy.deepcopy(draft)
    number = updated["brief"]["unit"]["position"]
    stop = ctx.stop_of(number)
    updated["brief"]["unit"] = {
        "slug": ctx.data.stops[number].unit_slug,
        "position": number,
        "title_en": stop.name,
        "can_do_en": stop.can_do,
    }
    for form in updated["forms"]:
        texts = form_texts(form, ctx)
        form["meaning_en"] = texts["meaning_en"]
        form["lemma_meaning_en"] = texts["lemma_meaning_en"]
    missing = pending_forms(updated)
    updated["notes"] = {"status": "pending" if missing else "complete"}
    return updated


# Everything --------------------------------------------------------------------------------


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def build_all(ctx: Context, part: int | None = None) -> dict[str, dict]:
    """A draft for each of the 102 new dialogues and the updated six earlier ones, by slug."""
    drafts: dict[str, dict] = {}
    for stop in ctx.road.stops.values():
        if part is not None and stop.part != part:
            continue
        for dialogue in stop.dialogues:
            path = ctx.repo / "content" / "drafts" / dialogue.slug / "draft.json"
            previous = json.loads(path.read_text(encoding="utf-8")) if path.is_file() else None
            drafts[dialogue.slug] = build_draft(dialogue, ctx, previous)
        for slug in ctx.data.stops[stop.number].earlier_dialogues:
            drafts[slug] = update_earlier_draft(ctx.earlier[slug], ctx)
    return drafts


def stop_order(drafts: dict[str, dict]) -> list[str]:
    return sorted(
        drafts,
        key=lambda s: (drafts[s]["brief"]["unit"]["position"], drafts[s]["brief"]["dialogue"]["position"]),
    )


def run_all_checks(drafts: dict[str, dict], ctx: Context) -> dict[str, dict]:
    return {
        slug: check_draft(draft, ctx.gate, ctx.ranks, ctx.thresholds, ctx.spoken_forms)
        for slug, draft in drafts.items()
    }


def notes_tables(drafts: dict[str, dict], ctx: Context) -> tuple[str, str, str]:
    """The files the notes are written in (glossary, word notes) with an empty entry for every word that
    still needs a text, and needed-notes.tsv, the list of what is missing with each form's first line."""
    order = stop_order(drafts)
    lemmas: dict[str, list[str]] = {}
    needed: list[list[str]] = []
    note_rows: list[list[str]] = []
    seen_forms: set[str] = set()
    for slug in order:
        draft = drafts[slug]
        by_id = {f["id"]: f for f in draft["forms"]}
        for line in draft["lines"]:
            for token in line["kirja_tokens"]:
                form = by_id.get(token.get("form") or "")
                if form is None:
                    continue
                lemmas.setdefault(form["lemma"], [])
                if form["surface_kirja"] not in lemmas[form["lemma"]] and len(lemmas[form["lemma"]]) < 4:
                    lemmas[form["lemma"]].append(form["surface_kirja"])
                if form["id"] in seen_forms:
                    continue
                seen_forms.add(form["id"])
                lacks = [
                    k
                    for k, v in (
                        ("meaning_en", form.get("meaning_en")),
                        ("lemma_meaning_en", form.get("lemma_meaning_en")),
                        ("why_en", form.get("why_en")),
                    )
                    if not v
                ]
                note = ctx.data.notes.get(form["id"], {})
                if not is_plain_dictionary_form(form) or note:
                    note_rows.append(
                        [
                            form["id"],
                            form["surface_kirja"],
                            form["surface_puhe"],
                            form["lemma"],
                            form["form_name_en"],
                            note.get("meaning_en", ""),
                            note.get("why_en", ""),
                        ]
                    )
                if lacks:
                    needed.append(
                        [
                            form["id"],
                            form["surface_kirja"],
                            form["surface_puhe"],
                            form["lemma"],
                            form["form_name_en"],
                            ",".join(lacks),
                            line["text_puhe"],
                            line["text_kirja"],
                            line["gloss_en"],
                        ]
                    )
    glossary_head = (
        "# The English meaning of each dictionary form of the A1 road (job 20-a1-road, statement 16).\n"
        "# One row per dictionary form (lemma), in the order the road first uses it: lemma, meaning,\n"
        "# and the forms seen (for context only). The meaning says what the dictionary form means in\n"
        "# plain English, at most 60 characters, for example tuo: that. An empty meaning is an empty\n"
        "# entry still to write.\n"
    )
    glossary = glossary_head + "".join(
        f"{lemma}\t{ctx.data.glossary.get(lemma, '')}\t{', '.join(seen)}\n" for lemma, seen in lemmas.items()
    )
    notes_head = (
        "# The own meaning and the why line of each form of the A1 road that is not an unchanged\n"
        "# dictionary form (job 20-a1-road, statement 16). Columns: form id, written form, spoken form,\n"
        "# dictionary form, form name (the first five only find the row), meaning, why. The meaning\n"
        "# says what this form means in the dialogue, for example noi: those (at most 60 characters).\n"
        "# The why is one line of at most 140 characters that says why the form looks like this, names\n"
        "# no grammar term other than the ones in the form name and holds no memory trick. An empty\n"
        "# cell is an empty entry still to write.\n"
    )
    notes = notes_head + "".join("\t".join(row) + "\n" for row in note_rows)
    needed_head = (
        "# Forms that still miss a text (job 20-a1-road). Columns: form id, written form, spoken form,\n"
        "# dictionary form, form name, what is missing, then the first line the form is in (spoken,\n"
        "# written, English). Made by scripts/generate/road_import.py; do not edit by hand.\n"
    )
    needed_text = needed_head + "".join("\t".join(row) + "\n" for row in needed)
    return glossary, notes, needed_text


def lemma_consistency(drafts: dict[str, dict]) -> list[str]:
    """One dictionary form has one meaning, and one form id carries the same texts in every draft that
    has it. The six earlier drafts keep the why lines they were committed with (statement 17), and they
    were written one by one, so a shared form may carry a different why there: only the road's written
    drafts must agree on the why."""
    problems = []
    meanings: dict[str, set[str]] = defaultdict(set)
    texts: dict[str, dict[str, str]] = {}
    for slug, draft in drafts.items():
        written = draft["brief"].get("source") == "written"
        for form in draft["forms"]:
            if form.get("lemma_meaning_en"):
                meanings[form["lemma"]].add(form["lemma_meaning_en"])
            texts.setdefault(form["id"], {})
            for key in ("meaning_en", "lemma_meaning_en", "why_en", "form_name_en"):
                if key == "why_en" and not written:
                    continue
                have = texts[form["id"]].setdefault(key, form.get(key, ""))
                if have != form.get(key, ""):
                    problems.append(f"form {form['id']} has two different {key} texts (draft {slug})")
    for lemma, found in meanings.items():
        if len(found) > 1:
            problems.append(f"dictionary form '{lemma}' has {len(found)} different meanings: {sorted(found)}")
    return problems


def note_file_problems(ctx: Context, drafts: dict[str, dict]) -> list[str]:
    """Stale or broken rows in word-notes.tsv and glossary.tsv."""
    problems = []
    by_id = {f["id"]: f for d in drafts.values() for f in d["forms"]}
    lemmas = {f["lemma"] for f in by_id.values()}
    for lemma, meaning in ctx.data.glossary.items():
        if lemma not in lemmas:
            problems.append(f"glossary.tsv: '{lemma}' is not a dictionary form of any draft")
        elif meaning:
            from road_data import meaning_problems

            problems += [f"glossary.tsv: '{lemma}': {p}" for p in meaning_problems(meaning)]
    for fid, note in ctx.data.notes.items():
        form = by_id.get(fid)
        if form is None:
            problems.append(f"word-notes.tsv, line {note['line']}: form {fid} is in no draft")
            continue
        echoed = (note["surface_kirja"], note["surface_puhe"], note["lemma"])
        if echoed != (form["surface_kirja"], form["surface_puhe"], form["lemma"]):
            problems.append(f"word-notes.tsv, line {note['line']}: the row does not match form {fid}")
        problems += [
            f"word-notes.tsv, line {note['line']}: {p}" for p in note_problems(note, form["form_name_en"])
        ]
    return problems


def report_text(drafts: dict[str, dict], reports: dict[str, dict], ctx: Context) -> str:
    """content/road/road-report.md: per stop, each check's rate, the spoken only words, the pairs accepted
    by table, the extras and the number of forms; per part, the extras allowed."""
    names = ("word_validity", "token_order", "spoken_links", "spoken_pairs", "level_fit", "grammar_cards")
    out = [
        "# The A1 road: automatic check report",
        "",
        "Made by `python scripts/generate/road_import.py import` (job 20-a1-road, statement 12).",
        "Do not edit by hand.",
        "A rate is the share of checked items that passed. Voikko, the word frequency list and the spoken to",
        "written word mapping run on every written dialogue. The register judge is reported as `not run`",
        "unless it ran.",
        "",
    ]
    totals: dict[str, list[int]] = {n: [0, 0] for n in names}
    pending = 0
    judge_state = defaultdict(int)
    for slug in drafts:
        for name in names:
            checked = reports[slug]["checks"][name]["checked"] if name in reports[slug]["checks"] else 0
            failed = len(reports[slug]["checks"].get(name, {}).get("failures", []))
            totals[name][0] += checked
            totals[name][1] += min(failed, checked)
        pending += len(reports[slug]["notes_pending"]) if "notes_pending" in reports[slug] else 0
        judge_state[reports[slug].get("register_judge", "n/a")] += 1
    out += ["## The road", ""]
    out += ["| Check | Items | Rate |", "|---|---|---|"]
    for name in names:
        checked, failed = totals[name]
        rate = 1.0 if checked == 0 else (checked - failed) / checked
        out.append(f"| {name} | {checked} | {rate:.4f} |")
    out += [
        "",
        f"Register judge: {', '.join(f'{state} in {n} drafts' for state, n in sorted(judge_state.items()))}.",
        f"Forms waiting for word notes: {pending} (see needed-notes.tsv).",
        "",
    ]
    by_stop: dict[int, list[str]] = defaultdict(list)
    for slug in stop_order(drafts):
        by_stop[drafts[slug]["brief"]["unit"]["position"]].append(slug)
    extras_by_part: dict[int, int] = defaultdict(int)
    for stop_number, slugs in by_stop.items():
        stop = ctx.stop_of(stop_number)
        extras = ctx.data.extras.get(stop_number, {"base_forms": [], "forms": []})
        extras_by_part[stop.part] += len(extras["base_forms"]) + len(extras["forms"])
        forms = {f["id"] for s in slugs for f in drafts[s]["forms"]}
        spoken_only = [w for s in slugs for w in reports[s].get("spoken_only_words", [])]
        table_pairs: dict[tuple[str, str], int] = defaultdict(int)
        for s in slugs:
            for line in drafts[s]["lines"]:
                _, mapping = map_line(line["text_puhe"], line["text_kirja"], ctx.spoken_forms)
                written = tokenize(line["text_kirja"])
                spoken_words = _spoken_words(line, ctx)
                for index, rule in enumerate(mapping.rules):
                    link = mapping.links[index]
                    if rule == "table" and link:
                        table_pairs[(spoken_words[index].lower(), written[link - 1].lower())] += 1
        out += [f"## Stop {stop_number}. {stop.name}", ""]
        out += ["| Check | Items | Rate |", "|---|---|---|"]
        for name in names:
            checked = sum(reports[s]["checks"].get(name, {}).get("checked", 0) for s in slugs)
            failed = sum(len(reports[s]["checks"].get(name, {}).get("failures", [])) for s in slugs)
            rate = 1.0 if checked == 0 else (checked - min(failed, checked)) / checked
            out.append(f"| {name} | {checked} | {rate:.4f} |")
        out += [""]
        out.append(f"Forms in the stop: {len(forms)}.")
        out.append(
            "Spoken only words: " + (", ".join(sorted(set(spoken_only))) if spoken_only else "none") + "."
        )
        out.append(
            "Pairs accepted by the table: "
            + (", ".join(f"{s} for {w}" for (s, w) in sorted(table_pairs)) if table_pairs else "none")
            + "."
        )
        out.append(
            f"Extras recorded: {len(extras['base_forms'])} base forms"
            + (
                ": " + ", ".join(sorted(i["lemma"] for i in extras["base_forms"]))
                if extras["base_forms"]
                else ""
            )
            + f", {len(extras['forms'])} forms."
        )
        out.append("")
    out += ["## Extras allowed per part", "", "| Part | Extras recorded |", "|---|---|"]
    for part in sorted(ctx.road.parts):
        out.append(f"| {part}. {ctx.road.parts[part]} | {extras_by_part.get(part, 0)} |")
    out.append("")
    return "\n".join(out)


def _spoken_words(line: dict, ctx: Context) -> list[str]:
    spoken, _ = map_line(line["text_puhe"], line["text_kirja"], ctx.spoken_forms)
    return spoken


def failures_text(reports: dict[str, dict], drafts: dict[str, dict]) -> list[str]:
    out = []
    for slug in stop_order(drafts):
        for problem in reports[slug]["failures"]:
            out.append(f"{slug} (stop {drafts[slug]['brief']['unit']['position']}): {problem}")
    return out


def cmd_import(args, ctx: Context | None = None, out_dir: Path | None = None) -> int:
    from voikko_gate import VoikkoGate

    ctx = ctx or Context(gate=VoikkoGate())
    out = out_dir or Path(args.out)
    drafts = build_all(ctx, getattr(args, "part", None))
    reports = run_all_checks(drafts, ctx)
    for slug, draft in drafts.items():
        write_json(out / "drafts" / slug / "draft.json", draft)
        write_json(out / "drafts" / slug / "check-report.json", reports[slug])
    glossary, notes, needed = notes_tables(drafts, ctx)
    (out / "road").mkdir(parents=True, exist_ok=True)
    (out / "road" / "glossary.tsv").write_text(glossary, encoding="utf-8", newline="\n")
    (out / "road" / "word-notes.tsv").write_text(notes, encoding="utf-8", newline="\n")
    (out / "road" / "needed-notes.tsv").write_text(needed, encoding="utf-8", newline="\n")
    if getattr(args, "part", None) is None:
        (out / "road" / "road-report.md").write_text(
            report_text(drafts, reports, ctx), encoding="utf-8", newline="\n"
        )
    problems = failures_text(reports, drafts) + lemma_consistency(drafts) + note_file_problems(ctx, drafts)
    lines = [f"Drafts: {len(drafts)}", f"Failures: {len(problems)}"] + problems
    (out / "import.log").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("\n".join(lines[:2]))
    for problem in problems[:400]:
        print(f"  {problem}")
    if len(problems) > 400:
        print(f"  ... and {len(problems) - 400} more in import.log")
    return 1 if problems else 0


def cmd_analyse(args, ctx: Context | None = None) -> int:
    """Per stop: the base forms above each candidate rank cap, and the forms outside the grammar list."""
    from voikko_gate import VoikkoGate

    ctx = ctx or Context(gate=VoikkoGate())
    for stop in ctx.data.stops.values():
        stop.rank_cap = 1_000_000
    drafts = build_all(ctx)
    result: dict = {"stops": {}, "parts": {}}
    part_words: dict[int, dict[int, set[str]]] = defaultdict(lambda: defaultdict(set))
    for slug in stop_order(drafts):
        draft = drafts[slug]
        number = draft["brief"]["unit"]["position"]
        stop = result["stops"].setdefault(number, {"words": {}, "outside_grammar": {}})
        for form in draft["forms"]:
            rank = ctx.ranks.get(form["lemma"].lower())
            stop["words"][form["lemma"]] = rank
            grammar = draft["brief"]["grammar"]
            try:
                fits = on_grammar_list(form["lemma"], form["form_tag"], grammar)
            except UnknownTagValue:
                fits = False
            if not fits:
                key = f"{form['lemma']}|{form['form_tag']}"
                stop["outside_grammar"][key] = {
                    "surface": form["surface_kirja"],
                    "name": form["form_name_en"],
                    "first_line": slug,
                }
    for number, stop in result["stops"].items():
        part = ctx.stop_of(number).part
        for lemma, rank in stop["words"].items():
            part_words[part][number].add((lemma, rank))
    for part, stops in sorted(part_words.items()):
        ladder = {}
        for cap in RANK_LADDER:
            worst = 0
            for words in stops.values():
                above = {w for w, r in words if r is None or r > cap}
                worst = max(worst, len(above))
            ladder[cap] = worst
        result["parts"][part] = {"max_words_above_cap_per_stop": ladder}
    for stop in result["stops"].values():
        stop["absent_from_list"] = sorted(w for w, r in stop["words"].items() if r is None)
        stop["ranks_above_1500"] = {w: r for w, r in stop["words"].items() if r is not None and r > 1500}
        del stop["words"]
    out = Path(args.out)
    write_json(out / "analysis.json", result)
    print(json.dumps(result["parts"], indent=1))
    return 0


# Characters, voices and the judge -------------------------------------------------------------


def clip_needs_voice(line: dict, register: str, draft_dir: Path, speakers: dict[str, str]) -> bool:
    """False when the clip exists and was made from this text and this voice."""
    from providers.voice import request_hash

    clip = line.get("audio", {}).get(register)
    if not clip or clip.get("source") != "synthetic":
        return True
    path = draft_dir / clip["file"]
    return not (
        path.is_file()
        and clip.get("request_sha256") == request_hash(line[f"text_{register}"], speakers[line["speaker"]])
    )


def characters_to_voice(drafts: dict[str, dict], repo: Path = REPO) -> int:
    total = 0
    for slug, draft in drafts.items():
        voices = {s["name"]: s["voice"] for s in draft["brief"]["speakers"]}
        for line in draft["lines"]:
            for register in ("puhe", "kirja"):
                if clip_needs_voice(line, register, repo / "content" / "drafts" / slug, voices):
                    total += len(line[f"text_{register}"])
    return total


def committed_road_drafts(part: int | None, repo: Path = REPO) -> dict[str, dict]:
    """The committed drafts of the road's stops (the written ones, and the six earlier ones)."""
    data = load_road_data(repo / "content" / "road")
    found = {}
    for path in sorted((repo / "content" / "drafts").glob("*/draft.json")):
        draft = json.loads(path.read_text(encoding="utf-8"))
        stop = draft["brief"]["unit"]["position"]
        if stop in data.stops and (
            draft["brief"].get("source") == "written"
            or path.parent.name in {s for st in data.stops.values() for s in st.earlier_dialogues}
        ):
            if part is None or (stop - 1) // 6 + 1 == part:
                found[path.parent.name] = draft
    return found


def cmd_count(args) -> int:
    drafts = committed_road_drafts(args.part)
    total = characters_to_voice(drafts)
    scope = f"part {args.part}" if args.part else "the road"
    print(f"Characters to voice for {scope}: {total}")
    return 0


def cmd_voice(args, voice=None) -> int:
    from audio import make_audio
    from providers import voice as voice_module

    drafts = committed_road_drafts(args.part)
    voice = voice or voice_module.get_provider()
    need = characters_to_voice(drafts)
    voice_module.refuse_over_allowance(voice.log_path, need)
    print(f"Voicing {need} characters for part {args.part}")
    for slug in stop_order(drafts):
        draft = drafts[slug]
        folder = REPO / "content" / "drafts" / slug
        voices = {s["name"]: s["voice"] for s in draft["brief"]["speakers"]}
        only = {
            (line["n"], register)
            for line in draft["lines"]
            for register in ("puhe", "kirja")
            if clip_needs_voice(line, register, folder, voices)
        }
        if not only:
            continue
        make_audio(draft, folder, voice, only=only, log=print)
        draft["providers"]["voice"] = voice.name
        write_json(folder / "draft.json", draft)
    return 0


def cmd_judge(args, ai=None) -> int:
    from drafting import JUDGE_SCHEMA, JUDGE_SYSTEM
    from judge import GOLDEN_PATH, evaluate_golden
    from providers import ai as ai_module
    from providers.ai import MODELS

    ai = ai or ai_module.get_provider()
    thresholds = load_thresholds()
    golden = evaluate_golden(ai, json.loads(GOLDEN_PATH.read_text(encoding="utf-8")), thresholds)
    print(f"Golden set: {'passed' if golden['passed'] else 'FAILED'}")
    if not golden["passed"]:
        return 1
    drafts = committed_road_drafts(args.part)
    for slug in stop_order(drafts):
        draft = drafts[slug]
        asked = [ln for ln in draft["lines"] if not _has_current_verdict(ln)]
        if not asked:
            continue
        ai.guard_run_cost(JUDGE_RUN_LIMIT_USD)
        prompt = "\n".join(
            f'Line {ln["n"]}: spoken "{judged_line(ln)["text_puhe"]}" | written "{ln["text_kirja"]}"'
            for ln in asked
        )
        answer = ai.complete_json(
            purpose="judge", dialogue=slug, system=JUDGE_SYSTEM, prompt=prompt, schema=JUDGE_SCHEMA
        )
        verdicts = {v.get("n"): v for v in answer.get("verdicts", [])}
        for ln in asked:
            verdict = verdicts.get(ln["n"])
            if verdict is None:
                continue
            ln["judge"] = {
                "faithful": verdict.get("same_meaning") is True,
                "reason": str(verdict.get("reason", "")),
                "fingerprint": line_judge_fingerprint(ln),
                "model": MODELS["judge"],
            }
        draft["providers"]["judge"] = "on"
        write_json(REPO / "content" / "drafts" / slug / "draft.json", draft)
    return 0


JUDGE_RUN_LIMIT_USD = 2.0


def _has_current_verdict(line: dict) -> bool:
    verdict = line.get("judge")
    return bool(verdict) and verdict.get("fingerprint") == line_judge_fingerprint(line)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="The A1 road importer")
    sub = parser.add_subparsers(dest="command", required=True)
    imp = sub.add_parser("import")
    imp.add_argument("--out", required=True)
    imp.add_argument("--part", type=int)
    ana = sub.add_parser("analyse")
    ana.add_argument("--out", required=True)
    cnt = sub.add_parser("count-characters")
    cnt.add_argument("--part", type=int)
    vo = sub.add_parser("voice")
    vo.add_argument("--part", type=int, required=True)
    ju = sub.add_parser("judge")
    ju.add_argument("--part", type=int)
    args = parser.parse_args(argv)
    commands = {
        "import": cmd_import,
        "analyse": cmd_analyse,
        "count-characters": cmd_count,
        "voice": cmd_voice,
        "judge": cmd_judge,
    }
    try:
        return commands[args.command](args)
    except RoadDataError as err:
        print(f"Stopped: {err}")
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
