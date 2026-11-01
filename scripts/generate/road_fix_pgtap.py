# ruff: noqa: E501  (the SQL template keeps the test file's own line lengths)
"""The pgTAP test of a reviewer's fix (job 20-a1-road, "Done when" 24).

  python scripts/generate/road_fix_pgtap.py          write supabase/tests/database/a1_road_fix.test.sql
  python scripts/generate/road_fix_pgtap.py --check  exit 1 when the committed file differs

It publishes the made up fixture dialogue of job 7 (scripts/generate/fixtures/publish/draft.json), then runs
the fix migration road_fix.fix_sql() makes for a changed line 2 with a new form, twice, and proves: a learner
reads the fixed line and the whole dialogue; while a dialogue is a draft a learner reads none of it; the old
reference is in private.approval_history and approving the changed line with it again is refused; setting a
line back to draft clears its approval. Everything runs in one rolled back transaction.
"""

from __future__ import annotations

import copy
import sys
import tempfile
from pathlib import Path

from fingerprints import sha256_bytes
from fixture_outputs import REVIEW_REF, fixture_with_audio, publish_sql
from providers.voice import fake_mp3
from publish import audio_key
from road_fix import fix_sql

REPO = Path(__file__).resolve().parents[2]
TEST_FILE = REPO / "supabase" / "tests" / "database" / "a1_road_fix.test.sql"
NEW_TEXTS = {
    "text_puhe": "pgtap fixed puhe",
    "text_kirja": "pgtap fixed kirja",
    "gloss_en": "pgtap fixed gloss",
}


def fixed_draft(old: dict) -> tuple[dict, dict[tuple[int, str], str]]:
    """The fixture with line 2 changed (texts, clips) and one of its words linked to a new form."""
    new = copy.deepcopy(old)
    line = new["lines"][1]
    line.update(NEW_TEXTS)
    voices = {s["name"]: s["voice"] for s in new["brief"]["speakers"]}
    keys = {}
    for register in ("puhe", "kirja"):
        data = fake_mp3(line[f"text_{register}"], voices[line["speaker"]])
        digest = sha256_bytes(data)
        line["audio"][register] = {
            **line["audio"][register],
            "sha256": digest,
            "text": line[f"text_{register}"],
        }
        keys[(2, register)] = audio_key(new["brief"]["dialogue"]["slug"], 2, register, digest)
    token = next(t for t in line["kirja_tokens"] if t.get("form"))
    source = next(f for f in new["forms"] if f["id"] == token["form"])
    form = {
        **source,
        "id": "pgtap-form-uusi",
        "lemma": "pgtap-uusi",
        "why_en": "pgtap why: the form a fix added.",
        "meaning_en": "new",
        "lemma_meaning_en": "new",
    }
    new["forms"].append(form)
    token["form"] = form["id"]
    return new, keys


def pgtap_text() -> str:
    with tempfile.TemporaryDirectory() as folder:
        old = fixture_with_audio(Path(folder))
    new, keys = fixed_draft(old)
    slug = old["brief"]["dialogue"]["slug"]
    publish = publish_sql(old)
    fix = fix_sql(new, old, {2}, 2, keys, "scripts/generate/fixtures/publish/draft.json")
    old_ref = f"{REVIEW_REF}#line-2"
    new_ref = f"content/reviews/{slug}/round-2.json#line-2"
    lines = len(old["lines"])
    where = f"d.slug = '{slug}'"
    reader = (
        "select set_config('request.jwt.claims',\n"
        '  \'{"sub": "00000000-0000-4000-8000-0000000024a1", "role": "authenticated", "is_anonymous": true}\', true);\n'
        "set local role authenticated;\n"
    )
    return f"""-- A reviewer's fix replaces a live line (pgTAP). Made by scripts/generate/road_fix_pgtap.py from
-- scripts/generate/fixtures/publish/draft.json and the fix migration road_fix.fix_sql() makes: do not edit by hand.
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/20-a1-road/spec.md that each test protects: [a1-road N].
--
-- Runs inside one transaction that is rolled back.

begin;

create extension if not exists pgtap with schema extensions;

select plan(11);

insert into auth.users (id) values ('00000000-0000-4000-8000-0000000024a1');

select lives_ok($migration$
{publish}$migration$, '[a1-road 24] the dialogue is published, with its first references');

select lives_ok($fixrun$
{fix}$fixrun$, '[a1-road 24] the fix migration runs');

select lives_ok($fixrun$
{fix}$fixrun$, '[a1-road 24] running the fix migration a second time does nothing and does not fail');

{reader}
select is((select l.text_puhe from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where {where} and l.position = 2), '{NEW_TEXTS["text_puhe"]}',
  '[a1-road 24] a learner reads the fixed line');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where {where}), {lines}::bigint,
  '[a1-road 24] a learner reads every line of the dialogue again, never a half changed one');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id join public.forms f on f.id = t.form_id
  where {where} and l.position = 2 and f.lemma = 'pgtap-uusi'), 2::bigint,
  '[a1-road 24] the changed line''s words link to the new form in both registers');
reset role;

select is((select l.approval_ref from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where {where} and l.position = 2), '{new_ref}',
  '[a1-road 24] the changed line carries the reviewer''s new reference');

select is((select count(*) from private.approval_history h join public.dialogue_lines l
    on l.id = h.row_id and h.table_name = 'dialogue_lines'
  join public.dialogues d on d.id = l.dialogue_id
  where {where} and l.position = 2 and h.approval_ref = '{old_ref}'), 1::bigint,
  '[a1-road 24] the old reference is in private.approval_history');

select throws_like($$
  do $retry$
  begin
    update public.dialogues set status = 'draft' where slug = '{slug}';
    update public.dialogue_lines set status = 'draft'
      where dialogue_id = (select id from public.dialogues where slug = '{slug}') and position = 2;
    update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = '{old_ref}'
      where dialogue_id = (select id from public.dialogues where slug = '{slug}') and position = 2;
  end
  $retry$
$$, '%approval reference was already used%',
  '[a1-road 24] a line changed by a fix cannot be approved again with its old reference');

update public.dialogues set status = 'draft' where slug = '{slug}';
{reader}
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where {where}), 0::bigint,
  '[a1-road 24] while the dialogue is a draft a learner reads none of its lines');
reset role;

update public.dialogue_lines set status = 'draft'
  where dialogue_id = (select id from public.dialogues where slug = '{slug}') and position = 1;
select row_eq(
  $$select approved_at, approval_ref from public.dialogue_lines
    where dialogue_id = (select id from public.dialogues where slug = '{slug}') and position = 1$$,
  row(null::timestamptz, null::text),
  '[a1-road 24] setting a line back to draft still clears its approval');

select * from finish();

rollback;
"""


def main(argv: list[str]) -> int:
    text = pgtap_text()
    if "--check" in argv:
        same = TEST_FILE.is_file() and TEST_FILE.read_text(encoding="utf-8") == text
        print("The test matches the generator." if same else f"{TEST_FILE.name} differs from the generator.")
        return 0 if same else 1
    TEST_FILE.write_text(text, encoding="utf-8", newline="\n")
    print(f"Wrote {TEST_FILE.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
