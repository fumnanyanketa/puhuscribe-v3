"""The A1 road importer, its checks and its word cards (job 20-a1-road).

Spec: factory/jobs/20-a1-road/spec.md. Labels [a1-road N] are its "Done when" statements. Tests that
need Finnish morphology use the real Voikko and are skipped where it is not installed (the GitHub
Python check installs it and fails on any skip). No test calls the network or an AI service.
"""

from __future__ import annotations

import copy
import hashlib
import json
import re
import shutil
from pathlib import Path

import pytest

import road_import as ri
from brief import BriefError, validate_brief
from fingerprints import form_id
from grammar import GRAMMAR_CATALOGUE, why_problems
from pipeline import cmd_check_committed
from providers import ai as ai_module
from review_items import all_items
from road_checks import check_draft, line_judge_fingerprint
from road_data import FIXED_WHY, load_extras, load_road_data, meaning_problems
from road_extras import core_tag
from road_markdown import FIXES
from road_parse import REPO, RoadDialogue, RoadLine
from test_units_1_3 import THRESHOLDS_SHA256_ON_MAIN

DRAFTS = REPO / "content" / "drafts"
ROAD = REPO / "content" / "road"
FINNISH_VOICES = {"fi-FI-NooraNeural", "fi-FI-HarriNeural", "fi-FI-SelmaNeural"}
# The six earlier drafts: a hash of the lines, the providers, the why and name of every form the road does not
# also have, and the name of every form it does (the road's texts win for those, statement 17 as amended).
EARLIER = {
    "meeting-people-new-colleague": "ee9b2e4add4389646f87deb2d5491c4f3b9287abe7278a18b536b583e4630b6b",
    "meeting-people-language-cafe": "186b22d375744d87dfc83a26ce49d5145463e67bb9d8e6b7f06421b6d628cfc6",
    "ordering-coffee-at-the-counter": "fc182996371b680ee7d28836f9fffab5e17c6a5bb6ad51a2885ba8190e3f8694",
    "ordering-coffee-paying": "6cd6175e304e2adfc6fe26481934637d4546b9d3f897c3864d3e61f75ffa3e52",
    "grocery-store-asking-staff": "97a03304597a2762c7e8f84639843b0621e523272608f1993847181354f0914a",
    "grocery-store-directions": "8b8a62fb2c7b97c178c605724b10c4d31b1777f0f058f1a934a3a1bc1ead7684",
}
# The six earlier briefs, byte for byte as on main (their tests in test_units_1_3.py need that).
EARLIER_BRIEF_SHA256 = {
    "grocery-store-asking-staff": "26f0e4d9e1ea69458d329cee7c059664dbc47300c14136cb6714bab31b6e6fc8",
    "grocery-store-directions": "cdfc3c87bbc085c54e864d657a27226e0592583406514885a218cc6ecb2232cf",
    "meeting-people-language-cafe": "80766fc335e012be04e18879739fbc069ff4149c0a0940f75849c33281b977c6",
    "meeting-people-new-colleague": "8294174c1ffa8e38f3b0cb0533ad37a86836d9ea07ed147c504846fbd23aa801",
    "ordering-coffee-at-the-counter": "f0df772966677112bd73de7dada6a07a62775cb9f75e1bdba8537c491957b70d",
    "ordering-coffee-paying": "2e7bbe0056ba687c665b9f5c4c3690ea146ef670404bbd30919ea326ba0e1f89",
}


def committed_road_drafts() -> dict[str, dict]:
    return ri.committed_road_drafts(None)


@pytest.fixture(scope="module")
def ctx(voikko, ranks, thresholds):
    return ri.Context(gate=voikko, ranks=ranks, thresholds=thresholds)


@pytest.fixture(scope="module")
def made(ctx):
    """What the importer makes from the markdown right now."""
    return ri.build_all(ctx)


@pytest.fixture(scope="module")
def committed():
    return committed_road_drafts()


def _plain(draft: dict) -> dict:
    """A draft without what a voice or the judge adds later (audio, verdicts)."""
    plain = copy.deepcopy(draft)
    for line in plain["lines"]:
        line.pop("audio", None)
        line.pop("judge", None)
    plain["providers"].pop("voice", None)
    plain["providers"].pop("judge", None)
    return plain


# [a1-road 9] Stop settings, speakers and the brief --------------------------------------------


def test_a1_road_9_stops_json_has_36_stops_with_known_grammar_and_one_cap_per_part():
    """[a1-road 9] each stop has its unit slug, a rank cap and grammar ids the catalogue knows."""
    data = load_road_data()
    assert sorted(data.stops) == list(range(1, 37))
    assert [data.stops[n].unit_slug for n in (1, 2, 3)] == [
        "meeting-people",
        "ordering-coffee",
        "grocery-store",
    ]
    assert len({s.unit_slug for s in data.stops.values()}) == 36
    for part in range(1, 7):
        caps = {data.stops[n].rank_cap for n in range((part - 1) * 6 + 1, part * 6 + 1)}
        assert len(caps) == 1, f"part {part} has more than one rank cap"
    for stop in data.stops.values():
        assert all(g in GRAMMAR_CATALOGUE for g in stop.grammar)
    assert {n for n, s in data.stops.items() if s.earlier_dialogues} == {1, 2, 3}


def test_a1_road_9_every_speaker_has_one_voice_and_no_dialogue_shares_one(ctx):
    """[a1-road 9] speakers.json: a voice for each name, the same every time, none shared in a dialogue."""
    speakers = ctx.data.speakers
    assert set(speakers.values()) <= FINNISH_VOICES
    for dialogue in ctx.road.dialogues():
        names = list(dict.fromkeys(line.speaker for line in dialogue.lines))
        assert all(n in speakers for n in names), dialogue.label
        voices = [speakers[n] for n in names]
        assert len(set(voices)) == len(voices), f"dialogue {dialogue.label} has two speakers with one voice"
    assert speakers["Maria"] == "fi-FI-SelmaNeural"


def test_a1_road_9_the_brief_gains_one_optional_field_source():
    """[a1-road 9] source is 'ai' by default; for 'written' role_en may be left out; the rest still holds."""
    brief = json.loads(
        (REPO / "content" / "briefs" / "meeting-people-new-colleague.json").read_text(encoding="utf-8")
    )
    assert "source" not in validate_brief(brief)
    written = copy.deepcopy(brief)
    written["source"] = "written"
    for speaker in written["speakers"]:
        del speaker["role_en"]
    assert validate_brief(written)["source"] == "written"
    with pytest.raises(BriefError, match="role_en"):
        validate_brief({**brief, "speakers": written["speakers"]})
    with pytest.raises(BriefError, match="source"):
        validate_brief({**brief, "source": "magic"})


def test_a1_road_9_the_six_earlier_briefs_are_unchanged():
    """[a1-road 9] the earlier briefs stay byte for byte: the road's name and sentence go into the drafts."""
    for slug, sha in EARLIER_BRIEF_SHA256.items():
        data = (REPO / "content" / "briefs" / f"{slug}.json").read_bytes()
        assert hashlib.sha256(data).hexdigest() == sha, slug


# [a1-road 10] A draft for every dialogue, with no AI ------------------------------------------


def test_a1_road_10_the_importer_needs_no_network_and_no_ai(ctx, monkeypatch):
    """[a1-road 10] with AI_PROVIDER unset and any AI call a failure, the import still succeeds."""
    monkeypatch.delenv("AI_PROVIDER", raising=False)
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)

    def boom(*_args, **_kwargs):
        raise AssertionError("the importer called an AI provider")

    monkeypatch.setattr(ai_module, "get_provider", boom)
    monkeypatch.setattr(ai_module, "AnthropicProvider", boom)
    drafts = ri.build_all(ctx, part=1)
    assert len(drafts) == 18  # 12 new dialogues and the 6 earlier drafts of part 1


def test_a1_road_10_no_file_imports_anthropic_outside_providers_ai():
    """[a1-road 10] only scripts/generate/providers/ai.py imports the anthropic package (v2's unused
    generate.py apart, which no road module imports)."""
    for path in sorted((REPO / "scripts" / "generate").glob("road_*.py")):
        assert "import generate" not in path.read_text(encoding="utf-8"), path.name
    for path in sorted((REPO / "scripts").rglob("*.py")):
        if path.name == "ai.py" and path.parent.name == "providers":
            continue
        if path.name.startswith("test_") or path.name == "generate.py":
            # generate.py is v2's own generator, kept unchanged and unused (docs/v2-imports.md).
            continue
        text = path.read_text(encoding="utf-8")
        assert not re.search(r"^\s*(import|from)\s+anthropic\b", text, re.MULTILINE), path.as_posix()


def test_a1_road_10_every_dialogue_has_a_draft_in_the_draft_format(committed):
    """[a1-road 10] 108 drafts, each with 8 lines, tokens and forms, providers written and judge off."""
    assert len(committed) == 108
    assert len({d["brief"]["dialogue"]["slug"] for d in committed.values()}) == 108
    written = [d for d in committed.values() if d["brief"].get("source") == "written"]
    assert len(written) == 102
    for slug, draft in committed.items():
        assert draft["format"] == "puhuscribe-draft-1"
        assert draft["brief"]["dialogue"]["slug"] == slug
        assert len(draft["lines"]) == 8 or slug in EARLIER
    for draft in written:
        assert draft["providers"]["ai"] == "written"
        assert draft["providers"]["judge"] in ("off", "on")
        for line in draft["lines"]:
            assert line["kirja_tokens"] and line["puhe_tokens"]
            assert all("surface" in t for t in line["kirja_tokens"] + line["puhe_tokens"])


# [a1-road 11] [a1-road 16] The mapping and the lemma rule, with real Voikko ----------------------


def test_a1_road_16_the_lemma_is_voikkos_base_form_of_the_paired_written_word(ctx):
    """[a1-road 16] noi pairs with nuo, so its lemma is Voikko's base form of nuo. (The spec says tuo;
    Voikko gives nuo its own base form nuo, and the rule is Voikko's base form.) toi pairs with tuo."""
    market = next(d for d in ctx.road.dialogues() if d.slug == "at-the-market")
    draft = ri.build_draft(market, ctx)
    line2 = draft["lines"][1]
    assert line2["text_puhe"] == "Moi! Paljonks noi mansikat maksaa?"
    forms = {f["id"]: f for f in draft["forms"]}
    noi = next(forms[t["form"]] for t in line2["kirja_tokens"] if t.get("form") and t["surface"] == "nuo")
    assert (noi["surface_kirja"], noi["surface_puhe"], noi["lemma"]) == ("nuo", "noi", "nuo")
    line4 = draft["lines"][3]
    toi = next(forms[t["form"]] for t in line4["kirja_tokens"] if t.get("form") and t["surface"] == "tuo")
    assert (toi["surface_puhe"], toi["lemma"]) == ("toi", "tuo")


def test_a1_road_11_a_glued_sa_stays_one_word_in_the_text_and_is_two_words_in_the_tokens(ctx):
    """[a1-road 11] Ootsä is shown as written; its two halves are two spoken words with two forms."""
    dialogue = next(d for d in ctx.road.dialogues() if d.slug == "a-new-neighbour")
    draft = ri.build_draft(dialogue, ctx)
    line = next(ln for ln in draft["lines"] if "Puhutsä" in ln["text_puhe"])
    assert "Puhutsä" in line["text_puhe"]
    surfaces = [t["surface"] for t in line["puhe_tokens"]]
    assert "Puhut" in surfaces and "sä" in surfaces and "Puhutsä" not in surfaces
    assert any(t.get("glued") == "Puhutsä" for t in line["puhe_tokens"])


# [a1-road 12] The free checks on all 108 --------------------------------------------------------


def test_a1_road_12_all_108_committed_drafts_pass_every_check(committed, voikko, ranks, thresholds):
    """[a1-road 12] Voikko, the word list, the mapping and the grammar cards pass on every draft."""
    failing = {}
    for slug, draft in committed.items():
        report = check_draft(draft, voikko, ranks, thresholds)
        if not report["ok"]:
            failing[slug] = report["failures"][:3]
    assert failing == {}


def test_a1_road_12_a_committed_road_draft_equals_what_the_importer_makes(committed, made):
    """[a1-road 12] audio and verdicts apart, the committed drafts are the importer's output."""
    assert set(committed) == set(made)
    different = [slug for slug in committed if _plain(committed[slug]) != _plain(made[slug])]
    assert different == [], "run the import again and commit its drafts: " + ", ".join(different[:5])


def test_a1_road_12_the_report_is_current_and_lists_every_stop_and_every_part(committed, made, ctx):
    """[a1-road 12] content/road/road-report.md: per stop its checks, the spoken only words and the extras."""
    reports = ri.run_all_checks(made, ctx)
    text = ri.report_text(made, reports, ctx)
    assert (ROAD / "road-report.md").read_text(encoding="utf-8") == text
    for number, stop in ctx.road.stops.items():
        assert f"## Stop {number}. {stop.name}" in text
    assert "## Extras allowed per part" in text
    assert "Register judge:" in text and "not run" in text


# [a1-road 13] Level fit for written content ----------------------------------------------------


def _planted(ctx, lines: list[tuple[str, str]], stop: int = 1) -> dict:
    dialogue = RoadDialogue(
        stop=stop,
        position=9,
        title="Planted test dialogue",
        situation="Maria tests the checks.",
        lines=[
            RoadLine(n, "Maria" if n % 2 else "Aino", puhe, kirja, "test")
            for n, (puhe, kirja) in enumerate(lines, start=1)
        ],
        file="content/written/part-1.md",
        slug="planted-test-dialogue",
    )
    return ri.build_draft(dialogue, ctx)


_FOUR = [("Moi!", "Hei!"), ("Moi!", "Hei!"), ("Moi!", "Hei!"), ("Moi!", "Hei!")]


def test_a1_road_13_a_planted_form_outside_the_stops_list_fails(ctx, voikko, ranks, thresholds):
    """[a1-road 13] taloon (illative) is on no list at stop 1, so the level check refuses the line."""
    lines = [("Mä meen taloon.", "Minä menen taloon.")] + _FOUR[1:]
    draft = _planted(ctx, lines)
    report = check_draft(draft, voikko, ranks, thresholds)
    assert not report["ok"]
    assert any("taloon" in f and "grammar list" in f for f in report["failures"])
    # The same line at stop 5, where the illative is taught, passes the grammar part of the check.
    later = check_draft(_planted(ctx, lines, stop=5), voikko, ranks, thresholds)
    assert not any("taloon" in f and "grammar list" in f for f in later["failures"])


def test_a1_road_13_a_planted_word_outside_the_level_fails(ctx, voikko, ranks, thresholds):
    """[a1-road 13] a rare word at stop 1, where the cap is 2000, fails and says the rank cap."""
    lines = [("Mä oon kemisti.", "Minä olen kemisti.")] + _FOUR[1:]
    report = check_draft(_planted(ctx, lines), voikko, ranks, thresholds)
    assert not report["ok"]
    assert any("kemisti" in f and "frequency rank cap" in f for f in report["failures"])


def test_a1_road_13_the_catalogue_has_an_entry_for_each_curriculum_item():
    """[a1-road 13] every grammar id of stops.json is in the catalogue, and the new entries are there."""
    for entry in (
        "present-tense",
        "numbers-to-100",
        "illative",
        "genitive",
        "plural-nominative",
        "past-and-perfect",
        "conditional",
        "imperative",
        "comparison",
        "possessive-endings",
        "ordinal-numbers",
    ):
        assert entry in GRAMMAR_CATALOGUE, entry
    assert sum(1 for g in GRAMMAR_CATALOGUE if not g.startswith("extras-stop-")) >= 27, (
        "the ten earlier entries and the new ones"
    )


def test_a1_road_13_each_part_has_the_lowest_cap_that_leaves_at_most_15_extra_words_per_stop(committed, ctx):
    """[a1-road 13] the rank cap per part is the lowest one with at most 15 words on any stop's list."""
    words = ri.stop_lemma_ranks(committed, ctx.ranks)
    for part in range(1, 7):
        stops = list(range((part - 1) * 6 + 1, part * 6 + 1))
        assert ri.lowest_cap(words, stops) == ctx.data.stops[stops[0]].rank_cap, f"part {part}"
    for number in range(1, 37):
        assert len(ctx.data.extras[number]["base_forms"]) <= 15, f"stop {number}"


def test_a1_road_13_every_recorded_extra_has_a_reason_and_is_used(committed):
    """[a1-road 13] no stale extra: each recorded base form and form is in a draft of its stop."""
    extras = load_extras()
    for number, entry in extras.items():
        drafts = [d for d in committed.values() if d["brief"]["unit"]["position"] == number]
        lemmas = {f["lemma"] for d in drafts for f in d["forms"]}
        tags = {(f["lemma"].lower(), f["form_tag"]) for d in drafts for f in d["forms"]}
        for item in entry["base_forms"]:
            assert item["reason"].strip()
            assert item["lemma"] in lemmas, f"stop {number}: {item['lemma']} is not used any more"
        for item in entry["forms"]:
            assert item["reason"].strip()
            assert (item["lemma"].lower(), item["tag"]) in tags, (
                f"stop {number}: {item['lemma']} {item['tag']}"
            )
            assert core_tag(item["tag"])


# [a1-road 14] Only Claude's content is repaired ---------------------------------------------------


def _fixes() -> list[dict]:
    text = FIXES.read_text(encoding="utf-8")
    entries = re.findall(
        r"- Dialogue (\d+\.\d+), (?:line (\d+), )?([a-z ]+)\.\s+Before: (.*)\s+After: (.*)\s+Reason: (.*)",
        text,
    )
    columns = {
        "spoken text": "puhe",
        "written text": "kirja",
        "English text": "en",
        "scene sentence": "situation",
    }
    return [
        {
            "label": e[0],
            "line": int(e[1] or 0),
            "column": columns[e[2]],
            "before": e[3],
            "after": e[4],
            "reason": e[5],
        }
        for e in entries
    ]


def test_a1_road_14_every_repair_is_listed_with_before_after_and_the_reason():
    """[a1-road 14] fixes.md: the last After of each cell is what the markdown says now."""
    from road_markdown import read_cell

    fixes = _fixes()
    assert len(fixes) > 100
    last: dict[tuple, str] = {}
    for fix in fixes:
        assert fix["before"].strip() and fix["after"].strip() and fix["reason"].strip()
        last[(fix["label"], fix["line"], fix["column"])] = fix["after"]
    for (label, line, column), after in last.items():
        if column == "situation":
            assert after in (
                REPO / "content" / "written" / f"part-{(int(label.split('.')[0]) - 1) // 6 + 1}.md"
            ).read_text(encoding="utf-8")
        else:
            assert read_cell(label, line, column) == after, f"{label} line {line} {column}"


def test_a1_road_14_no_threshold_or_check_was_changed():
    """[a1-road 14] the thresholds are the ones on main, byte for byte."""
    data = (REPO / "content" / "checks" / "thresholds.json").read_bytes()
    assert hashlib.sha256(data).hexdigest() == THRESHOLDS_SHA256_ON_MAIN


# [a1-road 15] The register judge is off unless the owner turns it on ----------------------------


def _written(committed) -> dict:
    return copy.deepcopy(committed["at-the-market"])


def test_a1_road_15_with_the_judge_off_the_report_says_not_run(committed, voikko, ranks, thresholds):
    """[a1-road 15] off: every draft records it, and the register check is 'not run', never 'passed'."""
    for slug, draft in committed.items():
        if draft["brief"].get("source") == "written":
            assert draft["providers"]["judge"] in ("off", "on"), slug
    draft = _written(committed)
    draft["providers"]["judge"] = "off"
    for line in draft["lines"]:
        line.pop("judge", None)
    report = check_draft(draft, voikko, ranks, thresholds)
    assert report["ok"] and report["register_judge"] == "not run"
    assert report["checks"]["register_faithfulness"]["status"] == "not run"
    assert report["checks"]["register_faithfulness"]["passed"] is None


def test_a1_road_15_on_with_every_verdict_passes_and_on_with_a_missing_verdict_fails(
    committed, voikko, ranks, thresholds
):
    """[a1-road 15] on: verdicts count; a missing verdict, a stale one or a 'differs' one fails."""
    draft = _written(committed)
    draft["providers"]["judge"] = "on"
    for line in draft["lines"]:
        line["judge"] = {
            "faithful": True,
            "reason": "same",
            "fingerprint": line_judge_fingerprint(line),
            "model": "x",
        }
    assert check_draft(draft, voikko, ranks, thresholds)["register_judge"] == "passed"

    missing = copy.deepcopy(draft)
    del missing["lines"][2]["judge"]
    report = check_draft(missing, voikko, ranks, thresholds)
    assert not report["ok"] and any("judge has not checked" in f for f in report["failures"])

    stale = copy.deepcopy(draft)
    stale["lines"][1]["gloss_en"] = stale["lines"][1]["gloss_en"] + " (changed)"
    assert any(
        "changed after the judge" in f for f in check_draft(stale, voikko, ranks, thresholds)["failures"]
    )

    differs = copy.deepcopy(draft)
    differs["lines"][0]["judge"]["faithful"] = False
    report = check_draft(differs, voikko, ranks, thresholds)
    assert not report["ok"] and report["register_judge"] == "FAILED"


def test_a1_road_15_check_committed_prints_register_judge_not_run(capsys, voikko, tmp_path):
    """[a1-road 15] check-committed says 'register judge: not run' for a written draft with the judge off,
    and the committed road passes it."""
    folder = tmp_path / "content" / "drafts" / "at-the-market"
    folder.mkdir(parents=True)
    draft = copy.deepcopy(committed_road_drafts()["at-the-market"])
    draft["providers"]["judge"] = "off"
    for line in draft["lines"]:
        line.pop("judge", None)
    (folder / "draft.json").write_text(json.dumps(draft, ensure_ascii=False), encoding="utf-8")
    (tmp_path / "supabase" / "migrations").mkdir(parents=True)
    (tmp_path / "content" / "road").mkdir(parents=True)
    shutil.copyfile(ROAD / "allowed-extras.json", tmp_path / "content" / "road" / "allowed-extras.json")
    assert cmd_check_committed(None, gate=voikko, repo=tmp_path) == 0
    out = capsys.readouterr().out
    assert "at-the-market: passes every check" in out
    assert "register judge: not run" in out
    assert cmd_check_committed(None, gate=voikko) == 0
    assert "at-the-market: passes every check" in capsys.readouterr().out


# [a1-road 16] [a1-road 17] Word cards and the six earlier drafts --------------------------------


def test_a1_road_16_the_fixed_line_follows_the_why_rules():
    """[a1-road 16] 'This is the dictionary form. People say it the same way.' is a legal why line."""
    assert FIXED_WHY["dictionary-same"] == "This is the dictionary form. People say it the same way."
    assert why_problems(FIXED_WHY["dictionary-same"], "interjection") == []


def test_a1_road_16_texts_come_from_the_glossary_the_notes_or_the_fixed_table(ctx):
    """[a1-road 16] a plain dictionary form gets its meaning and the fixed line; another form needs a note."""
    plain = {
        "id": "form-x",
        "lemma": "kahvi",
        "form_tag": "CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular",
        "surface_kirja": "kahvi",
        "surface_puhe": "kahvi",
    }
    changed = {
        **plain,
        "id": "form-y",
        "surface_puhe": "kahvii",
        "surface_kirja": "kahvia",
        "form_tag": "CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular",
    }
    ctx.data.glossary["kahvi"] = "coffee"
    ctx.data.notes["form-y"] = {
        "line": 1,
        "meaning_en": "some coffee",
        "why_en": "The partitive says an amount.",
    }
    try:
        assert ri.is_plain_dictionary_form(plain) and not ri.is_plain_dictionary_form(changed)
        assert ri.form_texts(plain, ctx) == {
            "meaning_en": "coffee",
            "lemma_meaning_en": "coffee",
            "why_en": FIXED_WHY["dictionary-same"],
        }
        assert ri.form_texts(changed, ctx) == {
            "meaning_en": "some coffee",
            "lemma_meaning_en": "coffee",
            "why_en": "The partitive says an amount.",
        }
        del ctx.data.notes["form-y"]
        assert ri.form_texts(changed, ctx)["meaning_en"] == ""
    finally:
        ctx.data.glossary.pop("kahvi", None)
        ctx.data.notes.pop("form-y", None)


def test_a1_road_16_notes_are_consistent_and_what_is_missing_is_listed(made, ctx):
    """[a1-road 16] one dictionary form has one meaning, one form id one set of texts, and every missing
    text is in needed-notes.tsv with its draft marked pending; a complete draft says complete."""
    assert ri.lemma_consistency(made) == []
    assert ri.note_file_problems(ctx, made) == []
    _, _, needed = ri.notes_tables(made, ctx)
    assert (ROAD / "needed-notes.tsv").read_text(encoding="utf-8") == needed
    missing_ids = {line.split("\t")[0] for line in needed.splitlines() if line and not line.startswith("#")}
    for slug, draft in made.items():
        incomplete = {
            f["id"] for f in draft["forms"] if not (f["meaning_en"] and f["lemma_meaning_en"] and f["why_en"])
        }
        assert incomplete <= missing_ids
        assert draft["notes"]["status"] == ("pending" if incomplete else "complete"), slug
        for form in draft["forms"]:
            for key in ("meaning_en", "lemma_meaning_en"):
                if form[key]:
                    assert meaning_problems(form[key]) == [], (slug, form["id"])
            if form["why_en"]:
                assert why_problems(form["why_en"], form["form_name_en"]) == [], (slug, form["id"])


def test_a1_road_16_a_form_id_is_the_same_form_in_every_draft(committed):
    """[a1-road 16] the id is a hash of the form's identity, and a form keeps it across drafts."""
    for draft in committed.values():
        for form in draft["forms"]:
            assert form["id"] == form_id(form)


def _road_form_ids(committed: dict[str, dict]) -> set[str]:
    """The form ids whose texts the road files decide in the earlier drafts: the road's own and the ones
    that two earlier drafts have."""
    ids = {f["id"] for d in committed.values() if d["brief"].get("source") == "written" for f in d["forms"]}
    count: dict[str, int] = {}
    for slug in EARLIER:
        for fid in {f["id"] for f in committed[slug]["forms"]}:
            count[fid] = count.get(fid, 0) + 1
    return ids | {fid for fid, n in count.items() if n > 1}


def test_a1_road_17_the_six_earlier_drafts_keep_their_lines_clips_and_other_why_lines(committed):
    """[a1-road 17] lines, tokens, providers and clips are the ones committed on main, and so are the why
    lines of the forms the road does not also have. (The forms the road shares take the road's texts.)"""
    shared = _road_form_ids(committed)
    for slug, sha in EARLIER.items():
        draft = committed[slug]
        payload = {
            "lines": draft["lines"],
            "why": [
                [f["id"], f["why_en"], f["form_name_en"]] for f in draft["forms"] if f["id"] not in shared
            ],
            "names": [[f["id"], f["form_name_en"]] for f in draft["forms"] if f["id"] in shared],
            "providers": draft["providers"],
        }
        digest = hashlib.sha256(
            json.dumps(payload, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode()
        ).hexdigest()
        assert digest == sha, slug
        for line in draft["lines"]:
            for register in ("puhe", "kirja"):
                clip = DRAFTS / slug / line["audio"][register]["file"]
                assert hashlib.sha256(clip.read_bytes()).hexdigest() == line["audio"][register]["sha256"]


def test_a1_road_17_a_form_the_road_and_an_earlier_draft_share_has_the_same_texts_in_every_draft(committed):
    """[a1-road 17] for every form id in more than one draft (the 22 forms of the six earlier drafts and the
    road included), the meaning, the dictionary form meaning, the why and the name are identical."""
    seen: dict[str, dict[str, set]] = {}
    for draft in committed.values():
        for form in draft["forms"]:
            for key in ("meaning_en", "lemma_meaning_en", "why_en", "form_name_en"):
                seen.setdefault(form["id"], {}).setdefault(key, set()).add(form.get(key, ""))
    earlier_ids = {f["id"] for slug in EARLIER for f in committed[slug]["forms"]}
    shared = {
        f["id"] for d in committed.values() if d["brief"].get("source") == "written" for f in d["forms"]
    } & earlier_ids
    assert len(shared) >= 22
    for fid, keys in seen.items():
        for key, values in keys.items():
            assert len(values) == 1, (fid, key, values)
    # an earlier draft's shared form carries the road files' why, not an AI text of its own
    notes = load_road_data().notes
    for slug in EARLIER:
        for form in committed[slug]["forms"]:
            if form["id"] in shared and form["id"] in notes:
                assert form["why_en"] == notes[form["id"]]["why_en"], (slug, form["id"])


def test_a1_road_17_they_gain_both_meaning_fields_and_keep_their_unit_block(committed):
    """[a1-road 17] every form has both meaning fields; the unit block is as committed, because the six
    briefs and their job 12 tests hold it. The road's name and sentence reach the database through
    road_stops, which the publish migration reads."""
    for slug in EARLIER:
        draft = committed[slug]
        brief = json.loads((REPO / "content" / "briefs" / f"{slug}.json").read_text(encoding="utf-8"))
        assert draft["brief"] == validate_brief(brief)
        assert all("meaning_en" in f and "lemma_meaning_en" in f for f in draft["forms"])


def test_a1_road_17_their_review_manifests_match_the_new_form_fingerprints(committed):
    """[a1-road 17] each round 1 manifest lists the current fingerprints, which now hold the meanings."""
    reviews = sorted(p.name for p in (REPO / "content" / "reviews").iterdir())
    assert reviews == ["README.md"], "no reviewer file may exist for them when the manifests are made again"
    for slug in EARLIER:
        manifest = json.loads((DRAFTS / slug / "review" / "round-1.json").read_text(encoding="utf-8"))
        items = all_items(committed[slug])
        assert manifest["items"] == {item_id: item["fingerprint"] for item_id, item in items.items()}, slug


def test_a1_road_26_the_importer_module_does_not_import_the_ai_module_at_start():
    """[a1-road 26] with the judge off the road adds no Anthropic call: only the judge command loads it."""
    source = (Path(ri.__file__)).read_text(encoding="utf-8")
    top = source.split("def cmd_judge")[0]
    assert "from providers import ai" not in top and "import providers.ai" not in top
