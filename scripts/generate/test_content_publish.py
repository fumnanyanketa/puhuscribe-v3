"""Publishing (job 7-content-pipeline, [content N]).

publish() runs in a temporary copy of the repository layout, so nothing here
touches supabase/migrations/ or public/ in the real repository.
"""

from __future__ import annotations

import copy
import hashlib
import json

import pytest

import fixture_outputs
from publish import PublishRefused, publish, sql_text
from review_page import write_round
from test_content_review import SLUG, answer, make_pack

STAMP = "20261021120000"


@pytest.fixture
def published_setup(unit_1_draft, fake_voice, tmp_path):
    """A temporary repository with the unit 1 fixture draft, its audio and a full approval."""
    repo = tmp_path / "repo"
    (repo / "supabase" / "migrations").mkdir(parents=True)
    draft_dir = repo / "content" / "drafts" / SLUG
    _, manifest = make_pack(unit_1_draft, draft_dir, fake_voice)
    reviews = repo / "content" / "reviews" / SLUG
    reviews.mkdir(parents=True)
    (reviews / "round-1.json").write_text(json.dumps(answer(manifest)), encoding="utf-8")
    return repo, draft_dir, reviews, unit_1_draft


def run_publish(setup, voikko, ranks, thresholds, draft=None, allow_fake=True):
    repo, draft_dir, reviews, original = setup
    return publish(
        draft or original,
        draft_dir,
        reviews,
        voikko,
        ranks,
        thresholds,
        repo=repo,
        timestamp=STAMP,
        allow_fake=allow_fake,
    )


def written(repo):
    """Every file under supabase/ and public/ in the temporary repository."""
    return sorted(
        p.relative_to(repo).as_posix()
        for folder in ("supabase", "public")
        for p in (repo / folder).rglob("*")
        if p.is_file()
    )


def test_publish_writes_the_migration_and_copies_the_reviewed_audio(
    published_setup, voikko, ranks, thresholds
):
    """[content 15] the migration, the audio keys, and approval refs that are the review file path
    plus the item id."""
    repo, draft_dir, _, draft = published_setup
    migration, audio = run_publish(published_setup, voikko, ranks, thresholds)
    assert migration == repo / "supabase" / "migrations" / f"{STAMP}_publish_meeting_people_new_colleague.sql"
    assert len(audio) == 12
    for path in audio:
        name = path.relative_to(repo / "public" / "audio").as_posix()
        line, register, digest = path.stem.split("-")
        assert name == f"{SLUG}/{line}-{register}-{digest}.mp3"
        assert hashlib.sha256(path.read_bytes()).hexdigest().startswith(digest) and len(digest) == 12
        assert (draft_dir / "audio" / f"{line}-{register}.mp3").read_bytes() == path.read_bytes()
    sql = migration.read_text(encoding="utf-8")
    ref = f"content/reviews/{SLUG}/round-1.json"
    assert f"'{ref}#line-1'" in sql and f"'{ref}#dialogue'" in sql
    for form in draft["forms"]:
        assert f"'{ref}#{form['id']}'" in sql
    order = [
        sql.index(s)
        for s in (
            "insert into public.forms",
            "insert into public.dialogue_lines",
            "update public.dialogue_lines set status = 'approved'",
            "update public.dialogues set status = 'approved'",
            "update public.units set status = 'approved'",
        )
    ]
    assert order == sorted(order), "forms, then lines with their words, then the dialogue, then the unit"
    assert "status = 'approved') then" in sql and "return;" in sql, "a second run does nothing"


def _drop_one_approval(setup):
    path = setup[2] / "round-1.json"
    review = json.loads(path.read_text(encoding="utf-8"))
    review["items"] = [i for i in review["items"] if i["id"] != "line-3"]
    path.write_text(json.dumps(review), encoding="utf-8")


def _open_fix(setup):
    path = setup[2] / "round-1.json"
    review = json.loads(path.read_text(encoding="utf-8"))
    review["items"][0].update(decision="fix", fix={"text_puhe": "a", "text_kirja": "b", "gloss_en": "c"})
    path.write_text(json.dumps(review), encoding="utf-8")


def _no_review(setup):
    (setup[2] / "round-1.json").unlink()


def _changed_after_approval(setup):
    form = next(f for f in setup[3]["forms"] if f["surface_kirja"] == "olen")
    form["why_en"] = "Olen is olla with minä."


def _failing_check(setup):
    setup[3]["lines"][1]["judge"]["faithful"] = False


def _audio_changed(setup):
    (setup[1] / "audio" / "4-kirja.mp3").write_bytes(b"ID3 swapped")


def _already_published(setup):
    (
        setup[0] / "supabase" / "migrations" / "20261001000000_publish_meeting_people_new_colleague.sql"
    ).write_text("-- earlier", encoding="utf-8")


@pytest.mark.parametrize(
    ("change", "reason"),
    [
        (_no_review, "there is no review file"),
        (_drop_one_approval, "item line-3 is not approved by the reviewer"),
        (_open_fix, "the latest review still has open fixes (line-1)"),
        (_changed_after_approval, "changed after the reviewer approved it"),
        (_failing_check, "check failed: line 2: the judge says"),
        (_audio_changed, "the audio file audio/4-kirja.mp3 changed after it was made"),
        (_already_published, "already publishes this dialogue"),
    ],
)
def test_each_missing_precondition_writes_nothing(published_setup, voikko, ranks, thresholds, change, reason):
    """[content 15] only when every check passes and the review covers every item; otherwise
    nothing is written."""
    repo = published_setup[0]
    change(published_setup)
    before = written(repo)
    with pytest.raises(PublishRefused) as refused:
        run_publish(published_setup, voikko, ranks, thresholds)
    assert any(reason in r for r in refused.value.reasons), refused.value.reasons
    assert written(repo) == before
    assert not (repo / "public").exists()


def _dollar_tag_in_gloss(setup):
    setup[3]["lines"][1]["gloss_en"] = "Hello $publish$; drop table units; --"


def _clip_path_elsewhere(setup):
    setup[3]["lines"][0]["audio"]["kirja"]["file"] = "../../../.env.local"


def _brief_not_valid(setup):
    setup[3]["brief"]["dialogue"]["slug"] = "../../src/x"


@pytest.mark.parametrize(
    ("change", "reason"),
    [
        (_dollar_tag_in_gloss, "draft.lines[2].gloss_en holds $publish$"),
        (_clip_path_elsewhere, "line 1 kirja audio must be audio/1-kirja.mp3"),
        (_brief_not_valid, "the draft's brief is not valid"),
    ],
)
def test_unsafe_drafts_are_refused_and_write_nothing(
    published_setup, voikko, ranks, thresholds, change, reason
):
    """[content 15] a value holding the migration's dollar quote tag, a clip path outside the draft folder
    or a broken brief is refused before anything is written (security review, round 2)."""
    repo = published_setup[0]
    change(published_setup)
    with pytest.raises(PublishRefused) as refused:
        run_publish(published_setup, voikko, ranks, thresholds)
    assert any(reason in r for r in refused.value.reasons), refused.value.reasons
    assert written(repo) == []


def test_error_messages_pass_words_as_parameters(published_setup, voikko, ranks, thresholds):
    """[content 15] words go into the migration's messages as quoted parameters, so a word with an
    apostrophe such as vaa'an cannot break the SQL."""
    migration, _ = run_publish(published_setup, voikko, ranks, thresholds)
    sql = migration.read_text(encoding="utf-8")
    assert "raise exception 'form % (%) exists but is not approved'," in sql
    assert (
        "raise notice 'dialogue % is already published; nothing to do', 'meeting-people-new-colleague';"
        in sql
    )
    for line in sql.splitlines():
        if "raise " in line:
            assert "{" not in line and line.count("%") >= 1, line
    assert sql_text("vaa'an") == "'vaa''an'"


def test_fake_provider_content_is_never_published_for_real(published_setup, voikko, ranks, thresholds):
    """[content 15] drafts and audio from the fake providers are refused outside the tests."""
    with pytest.raises(PublishRefused) as refused:
        run_publish(published_setup, voikko, ranks, thresholds, allow_fake=False)
    assert (
        "the draft was not made by the real AI provider (fake drafts are for tests only)"
        in refused.value.reasons
    )
    assert any("comes from the fake voice provider" in r for r in refused.value.reasons)


def test_a_fix_approved_in_a_later_round_publishes_with_that_rounds_reference(
    published_setup, voikko, ranks, thresholds
):
    """[content 14] [content 15] changed lines are approved again in the next round only."""
    repo, draft_dir, reviews, draft = published_setup
    draft = copy.deepcopy(draft)
    form = next(f for f in draft["forms"] if f["surface_kirja"] == "olen")
    form["why_en"] = "Olen is olla with minä: minä olen means I am."
    approved = {}
    for entry in json.loads((reviews / "round-1.json").read_text(encoding="utf-8"))["items"]:
        approved[entry["id"]] = entry["fingerprint"]
    _, manifest_path = write_round(draft, draft_dir, approved, 2)
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert set(manifest["items"]) == {form["id"], "dialogue"}
    (reviews / "round-2.json").write_text(json.dumps(answer(manifest)), encoding="utf-8")
    migration, _ = run_publish(published_setup, voikko, ranks, thresholds, draft=draft)
    sql = migration.read_text(encoding="utf-8")
    assert f"'content/reviews/{SLUG}/round-2.json#{form['id']}'" in sql
    assert f"'content/reviews/{SLUG}/round-1.json#line-1'" in sql
    assert f"'content/reviews/{SLUG}/round-2.json#dialogue'" in sql


def test_sql_text_escapes_quotes():
    """[content 15] text goes into the migration as a SQL string literal."""
    assert sql_text("it's") == "'it''s'"
    assert sql_text("'; drop table units; --") == "'''; drop table units; --'"
    with pytest.raises(ValueError):
        sql_text("a\x00b")
    with pytest.raises(ValueError, match="publish"):
        sql_text("ends $publish$ early")


def test_the_committed_pgtap_publish_test_is_current():
    """[content 16] the pgTAP test runs the SQL the publish step writes today."""
    made = fixture_outputs.outputs()[fixture_outputs.PGTAP_FILE]
    assert fixture_outputs.PGTAP_FILE.read_text(encoding="utf-8") == made, (
        "run python scripts/generate/fixture_outputs.py"
    )
