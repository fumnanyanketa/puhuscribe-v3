"""The A1 road's markdown, the spoken to written mapping and the road migration (job 20-a1-road).

Spec: factory/jobs/20-a1-road/spec.md. Labels [a1-road N] are its "Done when" statements. Nothing here
needs Voikko, the network or an AI service.
"""

from __future__ import annotations

import re
import shutil
from pathlib import Path

import pytest

from road_mapping import (
    SpokenForms,
    analysis_text,
    ending_rule,
    map_line,
    pair_rule,
    possessive_rule,
    split_glued_words,
    tokenize,
)
from road_markdown import insert_word_after, insert_word_before
from road_parse import (
    CURRICULUM,
    REPO,
    WRITTEN,
    RoadParseError,
    kebab,
    parse_curriculum,
    parse_part_file,
    parse_road,
)
from road_repair import pronoun_fix
from road_sql import MIGRATION, road_sql

EARLIER = {
    1: [(1, "meeting-people-new-colleague"), (2, "meeting-people-language-cafe")],
    2: [(1, "ordering-coffee-at-the-counter"), (2, "ordering-coffee-paying")],
    3: [(1, "grocery-store-asking-staff"), (2, "grocery-store-directions")],
}


@pytest.fixture(scope="module")
def road():
    return parse_road(earlier=EARLIER)


@pytest.fixture(scope="module")
def forms():
    return SpokenForms.load()


@pytest.fixture
def written_copy(tmp_path):
    """A copy of the curriculum and the six part files that a test may break."""
    docs = tmp_path / "docs"
    docs.mkdir()
    shutil.copy(CURRICULUM, docs / "curriculum-a1.md")
    written = tmp_path / "written"
    shutil.copytree(WRITTEN, written)
    return docs / "curriculum-a1.md", written


# [a1-road 8] Reading the markdown ------------------------------------------------------------


def test_a1_road_8_finds_36_stops_102_dialogues_of_8_lines(road):
    """[a1-road 8] 36 stops, 102 new dialogues, each with exactly 8 lines of four filled cells."""
    assert len(road.stops) == 36
    dialogues = road.dialogues()
    assert len(dialogues) == 102
    for d in dialogues:
        assert len(d.lines) == 8, d.label
        for line in d.lines:
            assert line.speaker and line.puhe and line.kirja and line.en, (d.label, line.n)
    assert [len(s.dialogues) for s in road.stops.values()][:4] == [1, 1, 1, 3]


def test_a1_road_8_names_and_sentences(road):
    """[a1-road 8] stop 4 and its I can sentence, as the owner approved them."""
    stop = road.stops[4]
    assert stop.name == "Numbers, prices and paying"
    assert stop.can_do == "ask what something costs and pay by card or cash."
    assert road.parts[1] == "First words"


def _replace_in(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    assert old in text
    path.write_text(text.replace(old, new, 1), encoding="utf-8", newline="\n")


def _row_of(path: Path, label: str, line: int) -> str:
    text = path.read_text(encoding="utf-8").split(f"### {label} ", 1)[1]
    return next(r for r in text.splitlines() if r.startswith(f"| {line} |"))


def test_a1_road_8_refuses_an_empty_cell_naming_file_stop_and_line(written_copy):
    """[a1-road 8] an empty cell is refused, with the file, the stop, the dialogue and the line."""
    curriculum, written = written_copy
    part = written / "part-2.md"
    row = _row_of(part, "7.1", 3)
    cells = row.split("|")
    cells[3] = "  "
    _replace_in(part, row, "|".join(cells))
    with pytest.raises(RoadParseError) as err:
        parse_road(curriculum, written, EARLIER)
    message = str(err.value)
    assert "part-2.md" in message and "stop 7" in message and "7.1" in message and "line 3" in message
    assert "empty" in message


def test_a1_road_8_refuses_a_stray_pipe(written_copy):
    """[a1-road 8] a pipe inside a cell makes 6 cells, which is refused."""
    curriculum, written = written_copy
    part = written / "part-3.md"
    row = _row_of(part, "13.1", 2)
    _replace_in(part, row, row.replace("Hei!", "Hei | hei!", 1))
    with pytest.raises(RoadParseError) as err:
        parse_road(curriculum, written, EARLIER)
    assert "stray pipe" in str(err.value) and "13.1" in str(err.value)


def test_a1_road_8_refuses_a_line_number_out_of_order(written_copy):
    """[a1-road 8] line 4 numbered 5 is refused."""
    curriculum, written = written_copy
    part = written / "part-4.md"
    row = _row_of(part, "19.1", 4)
    _replace_in(part, row, row.replace("| 4 |", "| 5 |", 1))
    with pytest.raises(RoadParseError) as err:
        parse_road(curriculum, written, EARLIER)
    assert "line number" in str(err.value) and "19.1" in str(err.value)


def test_a1_road_8_refuses_a_stop_without_its_i_can_line(written_copy):
    """[a1-road 8] a stop with no **I can:** line is refused, naming the stop."""
    curriculum, written = written_copy
    part = written / "part-5.md"
    text = part.read_text(encoding="utf-8")
    start = text.index("**I can:**", text.index("## Stop 26."))
    end = text.index("\n", start)
    part.write_text(text[:start] + text[end + 1 :], encoding="utf-8", newline="\n")
    with pytest.raises(RoadParseError) as err:
        parse_road(curriculum, written, EARLIER)
    assert "stop 26" in str(err.value) and "I can" in str(err.value)


def test_a1_road_8_refuses_a_dialogue_count_that_is_not_3():
    """[a1-road 8] once the earlier drafts are counted, every stop has exactly 3 dialogues."""
    with pytest.raises(RoadParseError) as err:
        parse_road(earlier={1: [(1, "a")], 2: EARLIER[2], 3: EARLIER[3]})
    assert "stop 1" in str(err.value) and "3" in str(err.value)
    with pytest.raises(RoadParseError) as err:
        parse_road(earlier={**EARLIER, 4: [(1, "extra")]})
    assert "stop 4" in str(err.value)


def test_a1_road_8_a_dialogue_of_7_lines_is_refused(written_copy):
    """[a1-road 8] a dialogue needs exactly 8 lines."""
    curriculum, written = written_copy
    part = written / "part-1.md"
    row = _row_of(part, "5.1", 8)
    _replace_in(part, row + "\n", "")
    with pytest.raises(RoadParseError) as err:
        parse_road(curriculum, written, EARLIER)
    assert "7 lines" in str(err.value) and "5.1" in str(err.value)


def test_a1_road_8_slugs_are_the_english_title_in_kebab_case(road):
    """[a1-road 8] [a1-road 10] a slug is the English title in kebab case, unique across the road."""
    assert kebab("What time is it?") == "what-time-is-it"
    assert kebab("Sorry, I didn't understand") == "sorry-i-didnt-understand"
    assert kebab("A language café at Oodi") == "a-language-cafe-at-oodi"
    slugs = [d.slug for d in road.dialogues()] + [slug for pairs in EARLIER.values() for _, slug in pairs]
    assert len(slugs) == 108 and len(set(slugs)) == 108
    assert all(re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", slug) for slug in slugs)


def test_a1_road_8_the_part_files_alone_parse(written_copy):
    """[a1-road 8] parse_part_file fills the stops of one part."""
    curriculum, written = written_copy
    _, stops = parse_curriculum(curriculum)
    parse_part_file(written / "part-6.md", 6, stops)
    assert stops[36].can_do and len(stops[36].dialogues) == 3


# [a1-road 11] The spoken to written mapping --------------------------------------------------


def test_a1_road_11_tokenize_matches_the_gate_rules():
    """[a1-road 11] the word split is VoikkoGate's: spaces, then edge punctuation off."""
    assert tokenize("Moi, mä oon Maria!") == ["Moi", "mä", "oon", "Maria"]
    assert tokenize("HSL-sovelluksesta — 23.40?") == ["HSL-sovelluksesta", "23.40"]


@pytest.mark.parametrize(
    ("spoken", "written", "rule"),
    [
        ("Kahvi", "kahvi", "equal"),
        ("mä", "minä", "table"),
        ("noi", "nuo", "table"),
        ("mist", "mistä", "dropped final letter"),
        ("kaks", "kaksi", "dropped final letter"),
        ("Helsingis", "Helsingissä", "dropped final vowel, shortened double consonant"),
        ("euroo", "euroa", "vowel stretched at the end"),
        ("kahvii", "kahvia", "vowel stretched at the end"),
        ("paljonks", "paljonko", "-ks for -ko or -kö"),
        ("eiks", "eikö", "-ks for -ko or -kö"),
    ],
)
def test_a1_road_11_every_accepted_pair_has_a_named_rule(forms, spoken, written, rule):
    """[a1-road 11] a pair is accepted by equality, the table or one documented ending rule."""
    assert pair_rule(spoken, written, forms) == rule


def test_a1_road_11_a_pair_nothing_accepts_is_refused_with_both_words(forms):
    """[a1-road 11] planted failure: an unlisted pair fails the line and names both words."""
    _, mapping = map_line("Mä otan kolmee", "Minä otan kahvia", forms)
    assert any("'kolmee'" in f and "'kahvia'" in f for f in mapping.failures)
    assert ending_rule("kolmee", "kahvia") is None


def test_a1_road_11_a_written_word_no_spoken_word_renders_fails(forms):
    """[a1-road 11] planted failure: a written word with no spoken partner fails the line."""
    _, mapping = map_line("Mä oon täällä", "Minä olen täällä kotona", forms)
    assert any("no spoken word renders the written word 'kotona'" in f for f in mapping.failures)


def test_a1_road_11_a_spoken_only_word_must_be_a_filler(forms):
    """[a1-road 11] planted failure: a spoken only word that is not a filler fails; a filler passes."""
    _, bad = map_line("Mä oon sitten täällä", "Minä olen täällä", forms)
    assert bad.failures
    _, good = map_line("No, mä oon täällä", "Minä olen täällä", forms)
    assert good.failures == []
    assert good.links[0] is None and good.rules[0] == "spoken only filler"


def test_a1_road_11_a_spoken_pronoun_needs_a_written_pronoun(forms):
    """[a1-road 11] planted failure: spoken mä against a written line that drops minä."""
    _, mapping = map_line("Mä oon täällä", "Olen täällä", forms)
    assert any("pronoun" in f for f in mapping.failures)
    assert pronoun_fix("Mä oon täällä", "Olen täällä", forms) == (1, "minä", False)
    # The pair mä and minä is accepted, but mä against any other written word is not.
    assert pair_rule("mä", "minä", forms) == "table"
    _, other = map_line("Mä oon", "Olen oma", forms)
    assert other.failures


def test_a1_road_11_the_pronoun_repair_adds_the_pronoun_and_the_capital():
    """[a1-road 11] the added pronoun takes the sentence's capital letter, and a verb gives it up."""
    assert insert_word_before("Hei! Olen täällä.", 2, "minä") == "Hei! Minä olen täällä."
    assert insert_word_before("Voin auttaa.", 1, "minä") == "Minä voin auttaa."
    assert insert_word_before("Hei, voin auttaa.", 2, "minä") == "Hei, minä voin auttaa."
    assert insert_word_after("Tiedätkö, sataako?", 1, "sinä") == "Tiedätkö sinä, sataako?"


def test_a1_road_11_glued_sa_is_split_by_one_rule_that_logs_each_change(forms):
    """[a1-road 11] Ootsä is two words for the checks, and the line is shown as written."""
    written = tokenize("Oletko sinä uusi täällä?")
    words, changes = split_glued_words(tokenize("Ootsä uus täällä?"), written)
    assert words == ["Oot", "sä", "uus", "täällä"]
    assert [(c.original, c.first, c.second) for c in changes] == [("Ootsä", "Oot", "sä")]
    assert analysis_text("Ootsä uus täällä?", written) == "Oot sä uus täällä?"
    _, mapping = map_line("Ootsä uus täällä?", "Oletko sinä uusi täällä?", forms)
    assert mapping.failures == [], mapping.failures
    # Words that only end in sä are left alone, with or without a question in the line.
    assert split_glued_words(tokenize("Missä on kesä?"), tokenize("Missä on kesä?"))[1] == []
    assert split_glued_words(tokenize("Onks täs metsä?"), tokenize("Onko tässä metsä?"))[1] == []


def test_a1_road_11_possessive_endings_after_mun_and_sun(forms):
    """[a1-road 11] mun äiti renders minun äitini: the ending the spoken noun leaves out."""
    assert possessive_rule("äiti", "äitini") is not None
    assert possessive_rule("nimi", "nimesi") is not None
    assert possessive_rule("sateenvarjon", "sateenvarjoni") is not None
    _, mapping = map_line("Mun äiti on täällä", "Minun äitini on täällä", forms)
    assert mapping.failures == []
    # Without mun, sun, meidän, teidän or sen before it, the rule does not apply.
    _, alone = map_line("Äiti on täällä", "Äitini on täällä", forms)
    assert alone.failures


def test_a1_road_11_every_line_of_the_road_maps(road, forms):
    """[a1-road 11] after the repairs in content/road/fixes.md, all 816 lines map word for word."""
    bad = []
    glued = 0
    for d in road.dialogues():
        for line in d.lines:
            _, mapping = map_line(line.puhe, line.kirja, forms)
            glued += len(mapping.glued)
            bad += [f"{d.label}.{line.n}: {f}" for f in mapping.failures]
    assert bad == []
    assert 30 <= glued <= 45  # about 37 spoken words are glued to sä


def test_a1_road_11_the_table_lists_only_plain_pairs():
    """[a1-road 11] every table row has two lower case words and a note a reader can follow."""
    seen = set()
    path = REPO / "content" / "road" / "spoken-forms.tsv"
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not raw.strip() or raw.startswith("#"):
            continue
        cells = raw.split("\t")
        assert len(cells) == 3, f"line {number}"
        assert cells[0] == cells[0].lower() and cells[1] == cells[1].lower(), f"line {number}"
        assert (cells[0], cells[1]) not in seen, f"line {number} repeats a pair"
        seen.add((cells[0], cells[1]))


# [a1-road 1] The road migration --------------------------------------------------------------


def test_a1_road_1_the_committed_migration_is_what_the_script_makes():
    """[a1-road 1] the load migration equals road_sql.py's output, so the names cannot drift."""
    assert MIGRATION.read_text(encoding="utf-8") == road_sql()


def test_a1_road_1_the_migration_has_6_parts_and_36_stops_from_the_markdown(road):
    """[a1-road 1] 6 parts, 36 stops, the owner's names and sentences, each text quoted safely."""
    sql = road_sql()
    assert sql.count("\n  (") == 6 + 36
    assert "'Numbers, prices and paying'" in sql
    assert "'ask what something costs and pay by card or cash.'" in sql
    assert "'say who I am and where I''m from, and ask the same.'" in sql
    for stop in road.stops.values():
        assert f"({stop.number}, " in sql


def test_a1_road_1_a_changed_sentence_changes_the_migration(tmp_path):
    """[a1-road 1] planted drift: a changed I can sentence makes the generated file differ."""
    repo = tmp_path / "repo"
    (repo / "docs").mkdir(parents=True)
    shutil.copy(CURRICULUM, repo / "docs" / "curriculum-a1.md")
    shutil.copytree(WRITTEN, repo / "content" / "written")
    shutil.copytree(REPO / "content" / "road", repo / "content" / "road")
    part = repo / "content" / "written" / "part-1.md"
    _replace_in(part, "ask what something costs and pay by card or cash.", "ask what something costs.")
    assert road_sql(repo) != MIGRATION.read_text(encoding="utf-8")
