"""Files made from the made up publish fixture (job 7-content-pipeline, "Done when" 13 and 16).

  python scripts/generate/fixture_outputs.py

writes two committed files from scripts/generate/fixtures/publish/draft.json:

- supabase/tests/database/content_publish.test.sql: the pgTAP test that runs the
  publish migration the pipeline writes for the fixture, twice, reads the result
  as a learner, and covers re-approving a unit and a form.
- scripts/generate/fixtures/review/round-1.html: the fixture's review page, which
  the Playwright test opens from disk. One line holds "<script>" on purpose.

pytest fails when either committed file differs from what this script makes,
so a change to the publish SQL or the review page is always tested in the database
and the browser.
"""

from __future__ import annotations

import json
import tempfile
from pathlib import Path

from fingerprints import sha256_bytes
from providers.voice import fake_mp3
from publish import audio_key, build_sql
from review_items import DIALOGUE_ITEM, all_items
from review_page import page_data, pending_items, render_page

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
FIXTURE = HERE / "fixtures" / "publish" / "draft.json"
PGTAP_FILE = REPO / "supabase" / "tests" / "database" / "content_publish.test.sql"
PAGE_FILE = HERE / "fixtures" / "review" / "round-1.html"
REVIEW_REF = "content/reviews/pgtap-publish-fixture/round-1.json"


def fixture_with_audio(audio_dir: Path) -> dict:
    draft = json.loads(FIXTURE.read_text(encoding="utf-8"))
    voices = {s["name"]: s["voice"] for s in draft["brief"]["speakers"]}
    audio_dir.mkdir(parents=True, exist_ok=True)
    for line in draft["lines"]:
        line["audio"] = {}
        for register in ("puhe", "kirja"):
            text = line[f"text_{register}"]
            data = fake_mp3(text, voices[line["speaker"]])
            (audio_dir / f"{line['n']}-{register}.mp3").write_bytes(data)
            line["audio"][register] = {
                "file": f"audio/{line['n']}-{register}.mp3",
                "sha256": sha256_bytes(data),
                "text": text,
                "source": "synthetic",
                "provider": "fake",
                "voice": voices[line["speaker"]],
            }
    return draft


def publish_sql(draft: dict) -> str:
    refs = {item_id: f"{REVIEW_REF}#{item_id}" for item_id in all_items(draft)}
    refs["unit"] = refs[DIALOGUE_ITEM]
    keys = {
        (line["n"], register): audio_key(
            draft["brief"]["dialogue"]["slug"], line["n"], register, line["audio"][register]["sha256"]
        )
        for line in draft["lines"]
        for register in ("puhe", "kirja")
    }
    return build_sql(draft, refs, keys, "scripts/generate/fixtures/publish/draft.json")


PGTAP_HEAD = """-- Published content (pgTAP). Made by scripts/generate/fixture_outputs.py from
-- scripts/generate/fixtures/publish/draft.json: do not edit by hand.
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/7-content-pipeline/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back. It runs the publish migration
-- the pipeline writes for a made up fixture dialogue twice, then reads as a
-- learner: the unit, the dialogue, every line with both texts, the meaning, both
-- audio keys and an approval_ref pointing at a review file, and a form with a
-- name and a "why" behind every word that has one. These reads also cover every
-- dialogue really published by then. Last, it re-approves a unit and a form
-- (factory/todo.md, from job 3-data-model).

begin;

create extension if not exists pgtap with schema extensions;

select plan(23);
"""

LEARNER = (
    "select set_config('request.jwt.claims',\n"
    '  \'{"sub": "00000000-0000-4000-8000-0000000c0de7", "role": "authenticated", '
    '"is_anonymous": true}\', true);\n'
    "set local role authenticated;\n"
)

LINE_COMPLETE = """coalesce(btrim(l.text_puhe), '') <> '' and coalesce(btrim(l.text_kirja), '') <> ''
    and coalesce(btrim(l.gloss_en), '') <> ''
    and l.audio_puhe_key ~ ('^' || d.slug || '/' || l.position || '-puhe-[0-9a-f]{12}[.]mp3$')
    and l.audio_kirja_key ~ ('^' || d.slug || '/' || l.position || '-kirja-[0-9a-f]{12}[.]mp3$')
    and l.approval_ref like ('content/reviews/' || d.slug || '/%.json#line-' || l.position)"""


def pgtap_file(draft: dict) -> str:
    sql = publish_sql(draft)
    slug = draft["brief"]["dialogue"]["slug"]
    unit = draft["brief"]["unit"]["slug"]
    token_count = sum(len(line["kirja_tokens"]) + len(line["puhe_tokens"]) for line in draft["lines"])
    linked = sum(1 for line in draft["lines"] for t in line["kirja_tokens"] if t.get("form")) + sum(
        1
        for line in draft["lines"]
        for t in line["puhe_tokens"]
        if isinstance(t.get("kirja"), int) and line["kirja_tokens"][t["kirja"] - 1].get("form")
    )
    lines = len(draft["lines"])
    form_lemma = draft["forms"][0]["lemma"]
    form_tag = draft["forms"][0]["form_tag"]
    form_where = f"lemma = '{form_lemma}' and form_tag = '{form_tag}'"
    return f"""{PGTAP_HEAD}
-- [content 15] [content 16] The publish migration, twice --------------------------

select lives_ok($migration$
{sql}$migration$, '[content 15] the publish migration the pipeline writes runs on the real schema');

select lives_ok($migration$
{sql}$migration$, '[content 16] running the publish migration a second time does nothing and does not fail');

select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = '{slug}'), {lines}::bigint,
  '[content 16] after the second run the dialogue still has {lines} lines');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id where d.slug = '{slug}'), {token_count}::bigint,
  '[content 16] after the second run the dialogue still has {token_count} words');
select is((select count(*) from public.forms where lemma like 'pgtap-%'), {len(draft["forms"])}::bigint,
  '[content 16] after the second run there are still {len(draft["forms"])} fixture forms');

-- [content 16] A learner reads the published content -----------------------------

{LEARNER}
select is((select count(*) from public.units where slug = '{unit}'), 1::bigint,
  '[content 16] a learner reads the published unit');
select is((select count(*) from public.dialogues where slug = '{slug}'), 1::bigint,
  '[content 16] a learner reads the published dialogue');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = '{slug}' and {LINE_COMPLETE}), {lines}::bigint,
  '[content 16] a learner reads every line with both texts, the meaning, both audio keys '
  'and an approval_ref pointing at the review file');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id where d.slug = '{slug}'), {token_count}::bigint,
  '[content 16] a learner reads every word of every line');
select is((select count(*) from public.tokens t join public.forms f on f.id = t.form_id
  join public.dialogue_lines l on l.id = t.line_id join public.dialogues d on d.id = l.dialogue_id
  where d.slug = '{slug}' and f.status = 'approved' and btrim(f.form_name_en) <> '' and btrim(f.why_en) <> ''
    and f.approval_ref like 'content/reviews/{slug}/%.json#%'), {linked}::bigint,
  '[content 16] every word that links to a form links to an approved form '
  'with a name, a why and a review reference');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where not ({LINE_COMPLETE})), 0::bigint,
  '[content 16] every line a learner can read, in every published dialogue, '
  'is complete and points at a review file');
select is((select count(*) from public.tokens t where t.form_id is not null and not exists (
    select 1 from public.forms f
    where f.id = t.form_id and btrim(f.form_name_en) <> '' and btrim(f.why_en) <> '')),
  0::bigint,
  '[content 16] every word a learner can read links only to forms the learner can read, '
  'with a name and a why');
select ok((select approval_ref = '{REVIEW_REF}#dialogue' from public.dialogues where slug = '{slug}'),
  '[content 15] the dialogue approval_ref is the review file path plus the item id');
reset role;

-- [content 16] Draft content stays hidden ----------------------------------------

insert into public.dialogues (unit_id, slug, position, title_en)
select id, 'pgtap-publish-draft-dialogue', 2, 'pgtap draft dialogue' from public.units where slug = '{unit}';
insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en)
select id, 1, 'pgtap', 'pgtap', 'pgtap', 'pgtap draft line' from public.dialogues
where slug = 'pgtap-publish-draft-dialogue';
select throws_ok(
  $$insert into public.dialogue_lines (dialogue_id, position, speaker)
    select id, 99, 'pgtap' from public.dialogues where slug = '{slug}'$$,
  'P0001', null, '[content 16] a draft line cannot be added to the published dialogue'
);
{LEARNER}
select is((select count(*) from public.dialogue_lines where gloss_en = 'pgtap draft line'), 0::bigint,
  '[content 16] a draft line added inside the test cannot be read');
select is((select count(*) from public.dialogues where slug = 'pgtap-publish-draft-dialogue'), 0::bigint,
  '[content 16] its draft dialogue cannot be read either');
reset role;

-- [content 16] Re-approving a unit and a form ------------------------------------

update public.units set status = 'draft' where slug = '{unit}';
select ok((select approved_at is null and approval_ref is null from public.units where slug = '{unit}'),
  '[content 16] setting an approved unit back to draft clears its approval');
select throws_ok(
  $$update public.units set status = 'approved', approved_at = now(),
    approval_ref = '{REVIEW_REF}#dialogue' where slug = '{unit}'$$,
  'P0001', null, '[content 16] approving the unit again with its old review reference is refused'
);
select lives_ok(
  $$update public.units set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/{slug}/round-2.json#dialogue' where slug = '{unit}'$$,
  '[content 16] approving the unit again with a new review reference works'
);
update public.forms set status = 'draft' where {form_where};
select ok((select approved_at is null and approval_ref is null from public.forms where {form_where}),
  '[content 16] setting an approved form back to draft clears its approval');
{LEARNER}
select is((select count(*) from public.forms where {form_where}), 0::bigint,
  '[content 16] a learner cannot read a form set back to draft');
reset role;
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(),
    approval_ref = '{REVIEW_REF}#{draft["forms"][0]["id"]}' where {form_where}$$,
  'P0001', null, '[content 16] approving the form again with its old review reference is refused'
);
select lives_ok(
  $$update public.forms set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/{slug}/round-2.json#{draft["forms"][0]["id"]}' where {form_where}$$,
  '[content 16] approving the form again with a new review reference works'
);

select * from finish();

rollback;
"""


def review_page_html(draft: dict, draft_dir: Path) -> str:
    return render_page(page_data(draft, draft_dir, 1, pending_items(draft, {})))


def outputs() -> dict[Path, str]:
    with tempfile.TemporaryDirectory() as tmp:
        draft_dir = Path(tmp)
        draft = fixture_with_audio(draft_dir / "audio")
        return {PGTAP_FILE: pgtap_file(draft), PAGE_FILE: review_page_html(draft, draft_dir)}


def main() -> int:
    for path, text in outputs().items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")
        print(f"Wrote {path.relative_to(REPO).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
