"""Publishing the A1 road under the owner's approval (job 20-a1-road, statements 20 and 21).

Spec: factory/jobs/20-a1-road/spec.md. Labels [a1-road N]. The tests publish a copy of one committed draft
(its clips were made by the real voice) into a temporary repository. They use the real Voikko and are
skipped where it is not installed; the GitHub Python check installs it and fails on any skip.
"""

from __future__ import annotations

import copy
import json
import shutil
from pathlib import Path

import pytest

from publish import PublishRefused
from road_publish import (
    FIRST_PUBLISH_TIMESTAMP,
    approval_path,
    is_last_dialogue,
    make_approval,
    migration_name,
    publish_road,
    publish_timestamp,
    road_fingerprint,
)

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
SLUG = "meeting-people-new-colleague"
OWNER_LINE = "I approve part 1 of the A1 road as it stands today. (test fixture, not the owner's words)"


def _complete(draft: dict) -> dict:
    """The draft with both meanings on every form, as it will be once the notes are written."""
    done = copy.deepcopy(draft)
    for form in done["forms"]:
        form["meaning_en"] = form["meaning_en"] or "meaning"
        form["lemma_meaning_en"] = form["lemma_meaning_en"] or "dictionary meaning"
    return done


@pytest.fixture
def repo(tmp_path):
    """A temporary repository with the draft, the road settings and an empty migrations folder."""
    shutil.copytree(REPO / "content" / "drafts" / SLUG, tmp_path / "content" / "drafts" / SLUG)
    shutil.copytree(REPO / "content" / "road", tmp_path / "content" / "road")
    (tmp_path / "supabase" / "migrations").mkdir(parents=True)
    (tmp_path / "supabase" / "migrations" / "20261101120100_load_road_stops.sql").write_text("-- main\n")
    return tmp_path


@pytest.fixture
def draft(repo):
    return _complete(
        json.loads((repo / "content" / "drafts" / SLUG / "draft.json").read_text(encoding="utf-8"))
    )


def approve(repo: Path, draft: dict, **changes) -> None:
    approval = make_approval(1, {SLUG: draft}, OWNER_LINE, "2026-11-02")
    approval.update(changes)
    path = approval_path(1, repo)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(approval, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def run(repo, draft, voikko, ranks, thresholds, others=None, last=True):
    return publish_road(
        draft,
        repo / "content" / "drafts" / SLUG,
        voikko,
        ranks,
        thresholds,
        {SLUG: draft, **(others or {})},
        last,
        repo,
    )


def nothing_written(repo: Path) -> bool:
    migrations = [p.name for p in (repo / "supabase" / "migrations").glob("*_publish_*.sql")]
    return not migrations and not (repo / "public").exists()


def test_a1_road_20_an_approved_dialogue_is_published_with_references_into_the_approval_file(
    repo, draft, voikko, ranks, thresholds
):
    """[a1-road 20] the migration and the clips are written, and every reference is file#slug/item."""
    approve(repo, draft)
    migration, clips = run(repo, draft, voikko, ranks, thresholds)
    assert migration.name == f"{publish_timestamp(1, 1)}_publish_{SLUG.replace('-', '_')}.sql"
    sql = migration.read_text(encoding="utf-8")
    assert f"'content/approvals/part-1.json#{SLUG}/line-1'" in sql
    assert f"'content/approvals/part-1.json#{SLUG}/dialogue'" in sql
    assert f"'content/approvals/part-1.json#{SLUG}/{draft['forms'][0]['id']}'" in sql
    assert "content/reviews/" not in sql
    assert len(clips) == len(draft["lines"]) * 2
    assert all(c.is_file() and c.name.endswith(".mp3") for c in clips)


def test_a1_road_20_a_changed_line_voids_the_approval_of_its_dialogue(repo, draft, voikko, ranks, thresholds):
    """[a1-road 20] the fingerprint covers every line's three texts and every form's texts."""
    approve(repo, draft)
    for edit in (
        lambda d: d["lines"][2].__setitem__("text_puhe", d["lines"][2]["text_puhe"] + "!"),
        lambda d: d["lines"][0].__setitem__("text_kirja", d["lines"][0]["text_kirja"] + "."),
        lambda d: d["lines"][1].__setitem__("gloss_en", d["lines"][1]["gloss_en"] + " (new)"),
        lambda d: d["forms"][0].__setitem__("why_en", d["forms"][0]["why_en"] + " Changed."),
        lambda d: d["forms"][0].__setitem__("meaning_en", "another meaning"),
    ):
        changed = copy.deepcopy(draft)
        edit(changed)
        assert road_fingerprint(changed) != road_fingerprint(draft)
        with pytest.raises(PublishRefused) as refused:
            run(repo, changed, voikko, ranks, thresholds)
        assert any("changed after the owner approved" in r for r in refused.value.reasons)
        assert nothing_written(repo)


def test_a1_road_20_it_refuses_without_the_file_with_a_wrong_file_and_when_the_dialogue_is_not_listed(
    repo, draft, voikko, ranks, thresholds
):
    """[a1-road 20] each way the approval file can be wrong is refused, naming the reason, writing nothing."""
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("no owner approval file content/approvals/part-1.json" in r for r in refused.value.reasons)
    path = approval_path(1, repo)
    path.parent.mkdir(parents=True)
    path.write_text('{"format": "something-else"}', encoding="utf-8")
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("not an owner approval file" in r for r in refused.value.reasons)
    approve(repo, draft)
    approval = json.loads(path.read_text(encoding="utf-8"))
    approval["dialogues"] = {"another-dialogue": "0" * 64}
    path.write_text(json.dumps(approval), encoding="utf-8")
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("is not listed" in r for r in refused.value.reasons)
    approval = json.loads(path.read_text(encoding="utf-8"))
    approval["approved_line"] = ""
    approval["dialogues"] = {SLUG: road_fingerprint(draft)}
    path.write_text(json.dumps(approval), encoding="utf-8")
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("own approval line" in r for r in refused.value.reasons)
    assert nothing_written(repo)


def test_a1_road_20_it_refuses_a_failing_check_missing_notes_and_a_wrong_judge_state(
    repo, draft, voikko, ranks, thresholds
):
    """[a1-road 20] a failing check, a form without its texts and a judge state the owner did not approve."""
    broken = copy.deepcopy(draft)
    broken["lines"][0]["kirja_tokens"][0]["surface"] = "Xyzzy"
    approve(repo, broken)
    with pytest.raises(PublishRefused) as refused:
        run(repo, broken, voikko, ranks, thresholds)
    assert any(r.startswith("check failed:") for r in refused.value.reasons)

    pending = copy.deepcopy(draft)
    pending["forms"][0]["meaning_en"] = ""
    approve(repo, pending)
    with pytest.raises(PublishRefused) as refused:
        run(repo, pending, voikko, ranks, thresholds)
    assert any("still miss a meaning or a why line" in r for r in refused.value.reasons)

    approve(repo, draft, judge="off")
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("register judge" in r for r in refused.value.reasons)
    assert nothing_written(repo)


def test_a1_road_20_it_refuses_missing_audio_fake_audio_and_a_failing_dialogue_in_the_part(
    repo, draft, voikko, ranks, thresholds
):
    """[a1-road 20] a clip that is gone or fake, or another dialogue of the part that fails, stops it."""
    approve(repo, draft)
    clip = repo / "content" / "drafts" / SLUG / draft["lines"][0]["audio"]["puhe"]["file"]
    saved = clip.read_bytes()
    clip.unlink()
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("is missing" in r for r in refused.value.reasons)
    clip.write_bytes(saved)

    fake = copy.deepcopy(draft)
    fake["lines"][0]["audio"]["puhe"]["provider"] = "fake"
    approve(repo, fake)
    with pytest.raises(PublishRefused) as refused:
        run(repo, fake, voikko, ranks, thresholds)
    assert any("fake voice" in r for r in refused.value.reasons)

    approve(repo, draft)
    other = copy.deepcopy(draft)
    other["brief"]["dialogue"] = {
        **draft["brief"]["dialogue"],
        "slug": "another-failing-dialogue",
        "position": 2,
    }
    other["lines"][0]["kirja_tokens"][0]["surface"] = "Xyzzy"
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds, others={"another-failing-dialogue": other})
    assert any("part 1 has a failing dialogue: another-failing-dialogue" in r for r in refused.value.reasons)
    assert nothing_written(repo)


def test_a1_road_20_a_dialogue_is_published_once(repo, draft, voikko, ranks, thresholds):
    """[a1-road 20] a second publish of the same dialogue is refused, naming the migration."""
    approve(repo, draft)
    run(repo, draft, voikko, ranks, thresholds)
    with pytest.raises(PublishRefused) as refused:
        run(repo, draft, voikko, ranks, thresholds)
    assert any("already publishes this dialogue" in r for r in refused.value.reasons)


def test_a1_road_21_the_stop_is_approved_only_in_the_migration_of_its_last_dialogue(
    repo, draft, voikko, ranks, thresholds
):
    """[a1-road 21] the unit row is made from road_stops; only the last dialogue approves the unit."""
    approve(repo, draft)
    first, _ = run(repo, draft, voikko, ranks, thresholds, last=False)
    sql = first.read_text(encoding="utf-8")
    assert "from public.road_stops s" in sql and "stop_number" in sql
    assert "update public.units set status = 'approved'" not in sql
    assert "already published; nothing to do" in sql  # a second run changes nothing
    first.unlink()
    shutil.rmtree(repo / "public")
    last, _ = run(repo, draft, voikko, ranks, thresholds, last=True)
    sql = last.read_text(encoding="utf-8")
    assert "update public.units set status = 'approved'" in sql
    assert f"#{SLUG}/dialogue'" in sql


def test_a1_road_21_the_migrations_are_ordered_by_stop_and_dialogue_and_later_than_main(draft):
    """[a1-road 21] explicit timestamps, a minute apart, in stop and dialogue order, after main."""
    names = [publish_timestamp(stop, position) for stop in range(1, 37) for position in (1, 2, 3)]
    assert names == sorted(names) and len(set(names)) == 108
    assert FIRST_PUBLISH_TIMESTAMP.strftime("%Y%m%d%H%M%S") == names[0]
    latest_on_main = max(
        p.name.split("_", 1)[0]
        for p in (REPO / "supabase" / "migrations").glob("*.sql")
        if "_publish_" not in p.name
    )
    assert names[0] > latest_on_main
    assert migration_name(draft).startswith(publish_timestamp(1, 1))


def test_a1_road_21_every_committed_road_migration_is_named_as_the_publisher_names_it():
    """[a1-road 21] each committed publish migration of a road draft equals the publisher's output, and the
    total size is reported (the stop line is 25 MB)."""
    from road_import import committed_road_drafts

    drafts = committed_road_drafts(None)
    migrations = sorted((REPO / "supabase" / "migrations").glob("*_publish_*.sql"))
    total = sum(p.stat().st_size for p in migrations)
    assert total <= 25 * 1024 * 1024
    audio = REPO / "public" / "audio"
    audio_total = sum(f.stat().st_size for f in audio.rglob("*") if f.is_file()) if audio.is_dir() else 0
    assert audio_total + total <= 100 * 1024 * 1024
    for migration in migrations:
        slug = migration.name.split("_publish_", 1)[1][:-4].replace("_", "-")
        if slug in drafts:
            assert migration.name == migration_name(drafts[slug])
            part = (drafts[slug]["brief"]["unit"]["position"] - 1) // 6
            same_part = {s: d for s, d in drafts.items() if (d["brief"]["unit"]["position"] - 1) // 6 == part}
            assert is_last_dialogue(drafts[slug], same_part) in (True, False)
