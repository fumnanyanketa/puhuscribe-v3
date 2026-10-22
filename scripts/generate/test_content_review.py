"""The review page and reading the reviewer's file back (job 7-content-pipeline, [content N]).

The browser half of statement 13 is e2e/review-page.spec.ts, which opens the
fixture page this file keeps current.
"""

from __future__ import annotations

import argparse
import base64
import copy
import hashlib
import json
import re

import pytest

import fixture_outputs
import pipeline
from audio import make_audio
from review_import import ReviewRefused, read_round
from review_items import all_items
from review_page import REVIEW_FORMAT, SCRIPT, STYLE, write_round

SLUG = "meeting-people-new-colleague"


def make_pack(draft, folder, voice, recordings=None):
    make_audio(draft, folder, voice, recordings or folder / "no-recordings", log=lambda _m: None)
    (folder / "draft.json").write_text(json.dumps(draft, ensure_ascii=False), encoding="utf-8")
    page, manifest = write_round(draft, folder, {}, 1)
    return page, json.loads(manifest.read_text(encoding="utf-8"))


def answer(manifest, code="R1", **overrides):
    items = []
    for item_id, fingerprint in manifest["items"].items():
        entry = {"id": item_id, "fingerprint": fingerprint, "comment": ""}
        if item_id.startswith("audio-"):
            entry.update(kind="audio", verdict="right")
        else:
            entry.update(kind="other", decision="approve")
        entry.update(overrides.get(item_id, {}))
        items.append(entry)
    return {
        "format": REVIEW_FORMAT,
        "dialogue_slug": SLUG,
        "round": manifest["round"],
        "reviewer_code": code,
        "items": items,
    }


def page_json(html: str) -> dict:
    match = re.search(r'<script type="application/json" id="review-data">(.*?)</script>', html, re.S)
    return json.loads(match.group(1))


def no_recording(_line, _register):
    return False


def test_the_page_is_self_contained_and_loads_nothing_from_the_network(unit_1_draft, fake_voice, tmp_path):
    """[content 13] one self contained HTML file per round that loads nothing from the network."""
    page, _ = make_pack(unit_1_draft, tmp_path, fake_voice)
    html = page.read_text(encoding="utf-8")
    assert not re.search(r"https?:|ftp:|wss?:", html, re.I)
    assert "<link" not in html and "@import" not in html and "url(" not in html
    assert " src=" not in html, "audio is set from data inside the page, never from a file or address"
    csp = re.search(r'<meta http-equiv="Content-Security-Policy" content="([^"]+)">', html).group(1)
    assert csp.startswith("default-src 'none';")
    for text in (SCRIPT, STYLE):
        digest = base64.b64encode(hashlib.sha256(text.encode()).digest()).decode()
        assert f"'sha256-{digest}'" in csp
    assert "media-src data:" in csp


def test_the_page_shows_every_line_form_clip_and_the_whole_dialogue(unit_1_draft, fake_voice, tmp_path):
    """[content 13] per line: speaker, spoken and written text with audio, English meaning; per form:
    base form, name and why; approve, fix and comment; sounds right or wrong; one approval for the whole
    dialogue."""
    page, manifest = make_pack(unit_1_draft, tmp_path, fake_voice)
    data = page_json(page.read_text(encoding="utf-8"))
    assert [line["n"] for line in data["lines"]] == [1, 2, 3, 4, 5, 6]
    first = data["lines"][0]
    assert (first["speaker"], first["text_puhe"], first["text_kirja"], first["gloss_en"]) == (
        "Aino",
        "Moi! Mä oon Aino.",
        "Hei! Minä olen Aino.",
        "Hi! I'm Aino.",
    )
    assert first["role"] == "a colleague who has worked there for years"
    assert first["audio"]["puhe"]["mp3"] and first["audio"]["kirja"]["mp3"]
    assert first["audio"]["puhe"]["source"] == "Synthetic voice"
    olen = next(f for f in data["forms"] if f["surface_kirja"] == "olen")
    assert (olen["lemma"], olen["form_name_en"]) == ("olla", "present tense, 1st person singular")
    assert olen["why_en"]
    assert {i["id"] for i in data["items"]} == set(all_items(unit_1_draft)) == set(manifest["items"])
    assert "dialogue" in manifest["items"]
    for word in (
        "Approve",
        "Fix",
        "Comment",
        "Sounds right",
        "Sounds wrong",
        "Download my review",
        "I approve this dialogue as a whole",
        "reviewer code",
    ):
        assert word in SCRIPT


def test_drafted_text_is_escaped_and_never_markup(unit_1_draft, fake_voice, tmp_path):
    """[content 13] all drafted text is shown as text, never run as code."""
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][0]["gloss_en"] = "</script><script>document.title='ran'</script> & <b>"
    page, _ = make_pack(draft, tmp_path, fake_voice)
    html = page.read_text(encoding="utf-8")
    assert html.count("<script") == 2 and html.count("</script>") == 2
    assert "document.title='ran'" in html.replace("\\u003c", "<").replace("\\u003e", ">")
    assert page_json(html)["lines"][0]["gloss_en"] == draft["lines"][0]["gloss_en"]
    assert "textContent" in SCRIPT and "innerHTML" not in SCRIPT and "insertAdjacentHTML" not in SCRIPT


def test_a_native_recording_is_marked_on_the_page(unit_1_draft, fake_voice, tmp_path):
    """[content 6] the review page marks a native recording."""
    recordings = tmp_path / "recordings"
    (recordings / SLUG).mkdir(parents=True)
    (recordings / SLUG / "3-kirja.mp3").write_bytes(b"ID3 native")
    page, _ = make_pack(unit_1_draft, tmp_path / "pack", fake_voice, recordings)
    data = page_json(page.read_text(encoding="utf-8"))
    assert data["lines"][2]["audio"]["kirja"]["source"] == "Native recording"
    assert data["lines"][2]["audio"]["puhe"]["source"] == "Synthetic voice"


def test_the_committed_review_page_fixture_is_current():
    """[content 13] the page the browser test opens is exactly what the pipeline makes today."""
    made = fixture_outputs.outputs()[fixture_outputs.PAGE_FILE]
    assert fixture_outputs.PAGE_FILE.read_text(encoding="utf-8") == made, (
        "run python scripts/generate/fixture_outputs.py"
    )


# Reading the file back -----------------------------------------------------------------


def test_a_complete_review_is_accepted(unit_1_draft, fake_voice, tmp_path):
    """[content 14] a file that answers every item of the page is read."""
    _, manifest = make_pack(unit_1_draft, tmp_path, fake_voice)
    entries = read_round(answer(manifest), manifest, SLUG, no_recording)
    assert set(entries) == set(manifest["items"])


@pytest.mark.parametrize(
    ("change", "reason"),
    [
        (lambda r: r["items"].pop(0), "item line-1 is missing from the review file"),
        (
            lambda r: r["items"][0].update(fingerprint="0" * 64),
            "item line-1 does not match the page the reviewer saw",
        ),
        (lambda r: r["items"][0].update(decision=None), "item line-1 has no decision"),
        (
            lambda r: r["items"][0].update(
                decision="fix", fix={"text_puhe": "x", "text_kirja": "", "gloss_en": "y"}
            ),
            "item line-1 is marked fix but the corrected text is missing",
        ),
        (
            lambda r: next(i for i in r["items"] if i["id"] == "audio-2-puhe").update(verdict="wrong"),
            "item audio-2-puhe is marked sounds wrong: add a native recording at "
            f"content/recordings/{SLUG}/2-puhe.mp3",
        ),
        (
            lambda r: next(i for i in r["items"] if i["id"] == "audio-2-puhe").update(verdict=None),
            "item audio-2-puhe has no sounds right or sounds wrong",
        ),
        (lambda r: r.update(reviewer_code=""), "the reviewer code is empty"),
        (lambda r: r.update(reviewer_code="anna@example.fi"), "never a name or email"),
        (
            lambda r: next(i for i in r["items"] if i["id"] == "dialogue").update(decision=None),
            "the dialogue as a whole has no decision (approve or not yet)",
        ),
        (
            lambda r: next(i for i in r["items"] if i["id"] == "dialogue").update(decision="not-yet"),
            "the dialogue as a whole is marked not yet, but no item is marked fix or sounds wrong",
        ),
        (lambda r: r.update(dialogue_slug="another-dialogue"), "the file is for dialogue 'another-dialogue'"),
        (
            lambda r: r["items"].append({"id": "line-99", "decision": "approve"}),
            "items the page did not show: line-99",
        ),
    ],
)
def test_a_review_file_is_refused_with_a_plain_reason(unit_1_draft, fake_voice, tmp_path, change, reason):
    """[content 14] refused when an item is missing, a fingerprint does not match, a fix is open,
    a clip sounds wrong or the reviewer code is empty."""
    _, manifest = make_pack(unit_1_draft, tmp_path, fake_voice)
    review = answer(manifest)
    change(review)
    with pytest.raises(ReviewRefused) as refused:
        read_round(review, manifest, SLUG, no_recording)
    assert any(reason in r for r in refused.value.reasons), refused.value.reasons


def test_a_clip_marked_wrong_moves_on_once_a_native_recording_exists(unit_1_draft, fake_voice, tmp_path):
    """[content 6] [content 14] a sounds wrong clip is accepted only when its native recording is there."""
    _, manifest = make_pack(unit_1_draft, tmp_path, fake_voice)
    review = answer(manifest, **{"audio-2-puhe": {"verdict": "wrong"}})
    entries = read_round(review, manifest, SLUG, lambda line, register: (line, register) == (2, "puhe"))
    assert entries["audio-2-puhe"]["verdict"] == "wrong"


def test_not_yet_is_accepted_when_the_reviewer_asks_for_changes(unit_1_draft, fake_voice, tmp_path):
    """[content 14] a reviewer who wants fixes answers "not yet" for the dialogue, never a false approval."""
    _, manifest = make_pack(unit_1_draft, tmp_path, fake_voice)
    fix = {"decision": "fix", "fix": {"text_puhe": "a", "text_kirja": "b", "gloss_en": "c"}}
    review = answer(manifest, **{"line-2": fix, "dialogue": {"decision": "not-yet"}})
    assert read_round(review, manifest, SLUG, no_recording)["dialogue"]["decision"] == "not-yet"
    review = answer(manifest, **{"audio-3-kirja": {"verdict": "wrong"}, "dialogue": {"decision": "not-yet"}})
    entries = read_round(review, manifest, SLUG, lambda line, register: (line, register) == (3, "kirja"))
    assert entries["dialogue"]["decision"] == "not-yet"


def test_a_clip_path_outside_the_draft_folder_is_refused(unit_1_draft, fake_voice, tmp_path):
    """[content 13] the page reads a clip only from audio/<line>-<register>.mp3 in the draft folder."""
    make_pack(unit_1_draft, tmp_path, fake_voice)
    draft = copy.deepcopy(unit_1_draft)
    draft["lines"][0]["audio"]["puhe"]["file"] = "../../secret.txt"
    with pytest.raises(ValueError, match="audio must be audio/1-puhe.mp3"):
        write_round(draft, tmp_path, {}, 1)


def test_next_round_refuses_a_draft_whose_brief_is_not_valid(
    unit_1_draft, voikko, fake_voice, tmp_path, monkeypatch
):
    """[content 14] the brief inside draft.json is checked again before anything is read or written."""
    repo, draft_dir, reviews = setup_round(unit_1_draft, fake_voice, tmp_path)
    draft = json.loads((draft_dir / "draft.json").read_text(encoding="utf-8"))
    draft["brief"]["dialogue"]["slug"] = "../../src/x"
    (draft_dir / "draft.json").write_text(json.dumps(draft), encoding="utf-8")
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    args = argparse.Namespace(draft=str(draft_dir), out=None, reviews=str(reviews))
    assert pipeline.cmd_next_round(args, gate=voikko, repo=repo) == 1
    assert "brief is not valid" in (draft_dir / "run.log").read_text(encoding="utf-8")
    assert not (draft_dir / "review" / "round-2.html").exists()


RELINK_AND_ENRICH = {
    "calls": [
        {
            "purpose": "draft",
            "output": {"lines": [{"n": 6, "puhe_links": [1, 2, 3, 4]}]},
            "input_tokens": 300,
            "output_tokens": 40,
        },
        {
            "purpose": "why",
            "output": {
                "words": [
                    {"id": "L6.W1", "reading": 1, "why_en": "Kyllä means yes."},
                    {"id": "L6.W2", "reading": 1, "why_en": "Minä means I."},
                    {"id": "L6.W3", "reading": 1, "why_en": "Olen goes with minä."},
                    {"id": "L6.W4", "reading": 1, "why_en": ""},
                ]
            },
            "input_tokens": 500,
            "output_tokens": 120,
        },
        {
            "purpose": "judge",
            "output": {"verdicts": [{"n": 6, "same_meaning": True, "reason": "Same."}]},
            "input_tokens": 200,
            "output_tokens": 30,
        },
    ]
}


def setup_round(unit_1_draft, fake_voice, tmp_path, review_change=None):
    repo = tmp_path / "repo"
    draft_dir = repo / "content" / "drafts" / SLUG
    _, manifest = make_pack(unit_1_draft, draft_dir, fake_voice)
    review = answer(manifest)
    if review_change:
        review_change(review)
    reviews = repo / "content" / "reviews" / SLUG
    reviews.mkdir(parents=True)
    (reviews / "round-1.json").write_text(json.dumps(review, ensure_ascii=False), encoding="utf-8")
    return repo, draft_dir, reviews


def fix_line_6_and_a_why(review):
    for item in review["items"]:
        if item["id"] == "line-6":
            item.update(
                decision="fix",
                fix={
                    "text_puhe": "Joo. Mä oon Helsingist.",
                    "text_kirja": "Kyllä. Minä olen Helsingistä.",
                    "gloss_en": "Yes. I'm from Helsinki.",
                },
            )
    hei = next(i for i in review["items"] if i["id"].startswith("form-") and i["id"] == HEI_FORM[0])
    hei.update(decision="fix", fix={"why_en": "Hei is hello. People often say moi when they talk."})
    whole = next(i for i in review["items"] if i["id"] == "dialogue")
    whole.update(decision="not-yet")


HEI_FORM: list[str] = []


def test_fixes_are_applied_and_only_changed_items_go_to_the_next_round(
    unit_1_draft, voikko, fake_voice, fake_ai, tmp_path, monkeypatch
):
    """[content 14] the pipeline applies the fixes, checks and voices the changed lines only, and
    writes a next round page holding only those lines (PRD section 9)."""
    HEI_FORM[:] = [next(f["id"] for f in unit_1_draft["forms"] if f["surface_kirja"] == "hei")]
    repo, draft_dir, reviews = setup_round(unit_1_draft, fake_voice, tmp_path, fix_line_6_and_a_why)
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    args = argparse.Namespace(draft=str(draft_dir), out=None, reviews=str(reviews))
    voice_calls_before = len((tmp_path / "ai-calls.jsonl").read_text(encoding="utf-8").splitlines())
    code = pipeline.cmd_next_round(
        args,
        gate=voikko,
        ai=fake_ai(RELINK_AND_ENRICH),
        voice=fake_voice,
        repo=repo,
        recordings=tmp_path / "none",
    )
    assert code == 0
    round_2 = json.loads((draft_dir / "review" / "round-2.json").read_text(encoding="utf-8"))
    draft = json.loads((draft_dir / "draft.json").read_text(encoding="utf-8"))
    kylla = next(f["id"] for f in draft["forms"] if f["surface_kirja"] == "kyllä")
    assert set(round_2["items"]) == {
        "line-6",
        "audio-6-puhe",
        "audio-6-kirja",
        kylla,
        HEI_FORM[0],
        "dialogue",
    }
    assert draft["lines"][5]["text_kirja"] == "Kyllä. Minä olen Helsingistä."
    hei = next(f for f in draft["forms"] if f["id"] == HEI_FORM[0])
    assert hei["why_en"] == "Hei is hello. People often say moi when they talk."
    calls = [json.loads(c) for c in (tmp_path / "ai-calls.jsonl").read_text(encoding="utf-8").splitlines()]
    assert len([c for c in calls[voice_calls_before:] if c["purpose"] == "voice"]) == 2, (
        "line 6 only, both registers"
    )
    page = (draft_dir / "review" / "round-2.html").read_text(encoding="utf-8")
    assert [line["n"] for line in page_json(page)["lines"]] == [6]


def test_a_refused_review_makes_no_next_round(unit_1_draft, voikko, fake_voice, tmp_path, monkeypatch):
    """[content 14] a refused file gives plain reasons and writes nothing."""
    repo, draft_dir, reviews = setup_round(
        unit_1_draft, fake_voice, tmp_path, lambda r: r.update(reviewer_code="")
    )
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    args = argparse.Namespace(draft=str(draft_dir), out=None, reviews=str(reviews))
    assert pipeline.cmd_next_round(args, gate=voikko, repo=repo) == 1
    assert not (draft_dir / "review" / "round-2.html").exists()
    assert "the reviewer code is empty" in (draft_dir / "run.log").read_text(encoding="utf-8")


def test_a_fully_approved_round_is_ready_to_publish(unit_1_draft, voikko, fake_voice, tmp_path, monkeypatch):
    """[content 14] with no fixes there is no next round."""
    repo, draft_dir, reviews = setup_round(unit_1_draft, fake_voice, tmp_path)
    monkeypatch.setattr(pipeline, "AI_LOG", tmp_path / "ai-calls.jsonl")
    args = argparse.Namespace(draft=str(draft_dir), out=None, reviews=str(reviews))
    assert pipeline.cmd_next_round(args, gate=voikko, repo=repo) == 0
    assert not (draft_dir / "review" / "round-2.html").exists()
    assert "Ready to publish" in (draft_dir / "run.log").read_text(encoding="utf-8")
