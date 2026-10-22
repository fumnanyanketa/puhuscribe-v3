-- Data model: learning content rules (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/3-data-model/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back. The test rows (slugs and
-- glosses starting "pgtap") and the test learner exist only inside it, also
-- when the tests run against the test project. The ids of the test rows are
-- kept in transaction settings (test.*) so the tests can name rows that a
-- learner is not allowed to see.

begin;

create extension if not exists pgtap with schema extensions;

select plan(112);

-- Test content, written as the database owner -------------------------------------
-- units: approved, draft, retired
-- dialogues: approved, draft, retired and "ready" in the approved unit; approved
--            inside the draft unit
-- lines: approved, draft and retired in the approved dialogue; approved inside the
--        draft dialogue; approved inside the approved dialogue of the draft unit
-- forms: approved, draft, retired
-- Everything starts as a draft and is approved in the order the pipeline must use:
-- forms, then lines, then dialogues.

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref) values
  ('pgtap-unit-approved', 900001, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review 1'),
  ('pgtap-unit-draft', 900002, 'pgtap unit', 'pgtap can do', 'draft', null, null),
  ('pgtap-unit-retired', 900003, 'pgtap unit', 'pgtap can do', 'retired', null, null);

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, 'pgtap dialogue'
  from (values
    ('pgtap-unit-approved', 'pgtap-dialogue-approved', 1),
    ('pgtap-unit-approved', 'pgtap-dialogue-draft', 2),
    ('pgtap-unit-approved', 'pgtap-dialogue-retired', 3),
    ('pgtap-unit-approved', 'pgtap-dialogue-ready', 4),
    ('pgtap-unit-draft', 'pgtap-dialogue-in-draft-unit', 1)
  ) as d(unit_slug, slug, position)
  join public.units u on u.slug = d.unit_slug;
update public.dialogues set status = 'retired' where slug = 'pgtap-dialogue-retired';

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, l.position, 'pgtap speaker', 'pgtap puhe', 'pgtap kirja', l.gloss, 'pgtap/puhe.mp3', 'pgtap/kirja.mp3'
  from (values
    ('pgtap-dialogue-approved', 1, 'pgtap line approved'),
    ('pgtap-dialogue-approved', 2, 'pgtap line draft'),
    ('pgtap-dialogue-approved', 3, 'pgtap line retired'),
    ('pgtap-dialogue-draft', 1, 'pgtap line approved in draft dialogue'),
    ('pgtap-dialogue-draft', 2, 'pgtap line draft in draft dialogue'),
    ('pgtap-dialogue-draft', 3, 'pgtap line with a draft form'),
    ('pgtap-dialogue-draft', 4, 'pgtap line with a retired form'),
    ('pgtap-dialogue-draft', 5, 'pgtap line to approve'),
    ('pgtap-dialogue-ready', 1, 'pgtap line ready'),
    ('pgtap-dialogue-in-draft-unit', 1, 'pgtap line approved in draft unit')
  ) as l(dialogue_slug, position, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

insert into public.forms (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref) values
  ('pgtap-lemma', 'pgtap-approved', 'pgtap-k', 'pgtap-p', 'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review 3'),
  ('pgtap-lemma', 'pgtap-draft', 'pgtap-k', 'pgtap-p', 'pgtap form', 'pgtap why', 'draft', null, null),
  ('pgtap-lemma', 'pgtap-retired', 'pgtap-k', 'pgtap-p', 'pgtap form', 'pgtap why', 'retired', null, null);

insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, t.register::public.finnish_register, t.position, t.surface, f.id
  from (values
    ('pgtap line approved', 'puhe', 1, 'pgtap-token-approved-puhe', 'pgtap-approved'),
    ('pgtap line approved', 'kirja', 1, 'pgtap-token-approved-kirja', 'pgtap-approved'),
    ('pgtap line draft', 'puhe', 1, 'pgtap-token-draft-line', 'pgtap-draft'),
    ('pgtap line approved in draft dialogue', 'puhe', 1, 'pgtap-token-draft-dialogue', 'pgtap-approved'),
    ('pgtap line draft in draft dialogue', 'puhe', 1, 'pgtap-token-draft-in-draft', 'pgtap-approved'),
    ('pgtap line with a draft form', 'puhe', 1, 'pgtap-token-draft-form', 'pgtap-draft'),
    ('pgtap line with a retired form', 'puhe', 1, 'pgtap-token-retired-form', 'pgtap-retired'),
    ('pgtap line to approve', 'puhe', 1, 'pgtap-token-a-name', null),
    ('pgtap line ready', 'puhe', 1, 'pgtap-token-ready', 'pgtap-approved')
  ) as t(gloss, register, position, surface, form_tag)
  join public.dialogue_lines l on l.gloss_en = t.gloss
  left join public.forms f on f.lemma = 'pgtap-lemma' and f.form_tag = t.form_tag;

update public.dialogue_lines
   set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 4'
 where gloss_en in ('pgtap line approved', 'pgtap line approved in draft dialogue',
                    'pgtap line approved in draft unit', 'pgtap line ready');
update public.dialogue_lines set status = 'retired' where gloss_en = 'pgtap line retired';
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 2'
 where slug = 'pgtap-dialogue-in-draft-unit';

-- The read rules are each tested on their own, so the line rule is also tested
-- with a draft line inside an approved dialogue. The database never allows that
-- (see "An approved dialogue is always whole" below), so that check is switched
-- off for this one step, inside this rolled back transaction.
alter table public.dialogues disable trigger approved_dialogue_is_whole;
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 2'
 where slug = 'pgtap-dialogue-approved';
alter table public.dialogues enable trigger approved_dialogue_is_whole;

select set_config('test.line_approved', (select id::text from public.dialogue_lines where gloss_en = 'pgtap line approved'), true);
select set_config('test.line_draft', (select id::text from public.dialogue_lines where gloss_en = 'pgtap line draft'), true);
select set_config('test.form_approved', (select id::text from public.forms where form_tag = 'pgtap-approved'), true);
select set_config('test.form_draft', (select id::text from public.forms where form_tag = 'pgtap-draft'), true);
select set_config('test.unit_approved', (select id::text from public.units where slug = 'pgtap-unit-approved'), true);
select set_config('test.dialogue_ready', (select id::text from public.dialogues where slug = 'pgtap-dialogue-ready'), true);

-- [data 4] A line is approved only when every part is present -----------------------

select throws_ok(
  format($$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'r', %s = null
           where gloss_en = 'pgtap line to approve'$$, col),
  '23514', null,
  format('[data 4] a line cannot be approved without %s', col)
) from unnest(array['text_puhe', 'text_kirja', 'audio_puhe_key', 'audio_kirja_key']) as col;
select throws_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'r', gloss_en = null
    where gloss_en = 'pgtap line to approve'$$,
  '23514', null,
  '[data 4] a line cannot be approved without gloss_en'
);
select throws_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = null, approval_ref = 'r'
    where gloss_en = 'pgtap line to approve'$$,
  '23514', null,
  '[data 4] a line cannot be approved without approved_at'
);
select throws_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = null
    where gloss_en = 'pgtap line to approve'$$,
  '23514', null,
  '[data 4] a line cannot be approved without approval_ref'
);
select throws_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'r', text_puhe = '  '
    where gloss_en = 'pgtap line to approve'$$,
  '23514', null,
  '[data 4] a line cannot be approved with a blank text_puhe'
);
select lives_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 5'
    where gloss_en = 'pgtap line to approve'$$,
  '[data 4] a line with both texts, the gloss, both audio keys, the time and the reference can be approved (its one word links to no form, like a name)'
);
select throws_ok(
  $$insert into public.units (slug, position, title_en, can_do_en, status, approved_at)
    values ('pgtap-unit-no-ref', 900009, 't', 't', 'approved', now())$$,
  '23514', null,
  '[data 4] a unit cannot be approved without approval_ref'
);
select throws_ok(
  $$update public.dialogues set status = 'approved', approved_at = null, approval_ref = 'r'
    where slug = 'pgtap-dialogue-ready'$$,
  '23514', null,
  '[data 4] a dialogue cannot be approved without approved_at'
);
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'r', why_en = null
    where form_tag = 'pgtap-draft'$$,
  '23514', null,
  '[data 4] a form cannot be approved without its one line why'
);

-- [data 4] The one line "why" is one line of at most 140 characters (design review 4)

select throws_ok(
  $$update public.forms set why_en = 'pgtap first line' || chr(10) || 'pgtap second line' where form_tag = 'pgtap-draft'$$,
  '23514', null,
  '[data 4] a form''s why cannot hold a line break'
);
select throws_ok(
  $$update public.forms set why_en = repeat('w', 141) where form_tag = 'pgtap-draft'$$,
  '23514', null,
  '[data 4] a form''s why cannot be longer than 140 characters'
);
select lives_ok(
  $$update public.forms set why_en = repeat('w', 140) where form_tag = 'pgtap-draft'$$,
  '[data 4] a form''s why of exactly 140 characters on one line is accepted'
);

-- [data 4] A line is approved only when every word that links to a form links to an
-- approved form (design review 3)

select throws_like(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'r'
    where gloss_en = 'pgtap line with a draft form'$$,
  '%words link to a form that is not approved%',
  '[data 4] a line with a word linked to a draft form cannot be approved'
);
select throws_like(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'r'
    where gloss_en = 'pgtap line with a retired form'$$,
  '%words link to a form that is not approved%',
  '[data 4] a line with a word linked to a retired form cannot be approved'
);

-- [data 5] An approved dialogue is always whole: a learner never sees it with a line
-- missing (design review 1)

select throws_like(
  $$insert into public.dialogues (unit_id, slug, position, title_en, status, approved_at, approval_ref)
    values (current_setting('test.unit_approved')::bigint, 'pgtap-dialogue-no-lines', 9, 't', 'approved', now(), 'r')$$,
  '%needs at least one approved line%',
  '[data 5] a dialogue with no approved line cannot be approved'
);
select throws_like(
  $$update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'r'
    where slug = 'pgtap-dialogue-draft'$$,
  '%dialogue with a draft line cannot be approved%',
  '[data 5] a dialogue with a draft line cannot be approved'
);
select lives_ok(
  $$update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 7'
    where slug = 'pgtap-dialogue-ready'$$,
  '[data 5] a dialogue whose lines are all approved can be approved'
);
select throws_like(
  $$insert into public.dialogue_lines (dialogue_id, position, speaker)
    values (current_setting('test.dialogue_ready')::bigint, 2, 'pgtap speaker')$$,
  '%lines of an approved dialogue cannot be added, removed or change status%',
  '[data 5] a draft line cannot be added to an approved dialogue'
);
select throws_like(
  $$update public.dialogue_lines set status = 'draft' where gloss_en = 'pgtap line ready'$$,
  '%lines of an approved dialogue cannot be added, removed or change status%',
  '[data 5] a line of an approved dialogue cannot be set back to draft'
);
select throws_like(
  $$update public.dialogue_lines set status = 'retired' where gloss_en = 'pgtap line ready'$$,
  '%lines of an approved dialogue cannot be added, removed or change status%',
  '[data 5] a line of an approved dialogue cannot be retired'
);
select throws_like(
  $$update public.dialogue_lines set dialogue_id = current_setting('test.dialogue_ready')::bigint, position = 7
    where gloss_en = 'pgtap line draft in draft dialogue'$$,
  '%lines of an approved dialogue cannot be added, removed or change status%',
  '[data 5] a draft line cannot be moved into an approved dialogue'
);

-- [data 5] What a learner can read ----------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select results_eq(
  $$select slug from public.units where slug like 'pgtap-%' order by slug$$,
  array['pgtap-unit-approved'],
  '[data 5] a learner reads the approved unit, and not the draft or retired one'
);
select results_eq(
  $$select slug from public.dialogues where slug like 'pgtap-%' order by slug$$,
  array['pgtap-dialogue-approved', 'pgtap-dialogue-ready'],
  '[data 5] a learner reads the approved dialogues, and not the draft, the retired, or the approved one inside a draft unit'
);
select results_eq(
  $$select gloss_en from public.dialogue_lines where gloss_en like 'pgtap %' order by gloss_en$$,
  array['pgtap line approved', 'pgtap line ready'],
  '[data 5] a learner reads the approved lines of the approved dialogues only'
);
select is_empty(
  $$select 1 from public.dialogue_lines where gloss_en in ('pgtap line draft', 'pgtap line retired')$$,
  '[data 5] a draft or retired line cannot be read'
);
select is_empty(
  $$select 1 from public.dialogue_lines
     where gloss_en in ('pgtap line approved in draft dialogue', 'pgtap line to approve')$$,
  '[data 5] an approved line inside a draft dialogue cannot be read'
);
select is_empty(
  $$select 1 from public.dialogue_lines where gloss_en = 'pgtap line approved in draft unit'$$,
  '[data 5] an approved line of an approved dialogue inside a draft unit cannot be read'
);
select results_eq(
  $$select form_tag from public.forms where lemma = 'pgtap-lemma' order by form_tag$$,
  array['pgtap-approved'],
  '[data 5] a learner reads the approved form, and not the draft or retired one'
);
select results_eq(
  $$select surface from public.tokens where surface like 'pgtap-token-%' order by surface$$,
  array['pgtap-token-approved-kirja', 'pgtap-token-approved-puhe', 'pgtap-token-ready'],
  '[data 5] a learner reads the tokens of the approved lines only'
);
select is_empty(
  $$select 1 from public.tokens where line_id = current_setting('test.line_draft')::bigint$$,
  '[data 5] the tokens of a draft line cannot be read'
);
select is_empty(
  $$select 1 from public.tokens where surface = 'pgtap-token-draft-dialogue'$$,
  '[data 5] the tokens of an approved line inside a draft dialogue cannot be read'
);

-- [data 7] A learner cannot write content

select throws_ok(format('insert into public.%I default values', t), '42501', null,
  format('[data 7] a learner cannot add rows to %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms']) as t;
select throws_ok(format('update public.%I set %I = %I', t, c, c), '42501', null,
  format('[data 7] a learner cannot change rows in %s', t))
  from (values ('units', 'slug'), ('dialogues', 'slug'), ('dialogue_lines', 'speaker'),
               ('tokens', 'surface'), ('forms', 'lemma')) as x(t, c);
select throws_ok(format('delete from public.%I', t), '42501', null,
  format('[data 7] a learner cannot delete rows from %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms']) as t;

reset role;

-- [data 5] [data 7] anon (the publishable key, no sign in) reaches no content ------------

select set_config('request.jwt.claims', '{"role": "anon"}', true);
set local role anon;

select throws_ok(format('select * from public.%I', t), '42501', null,
  format('[data 5] anon cannot read %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms']) as t;
select throws_ok(format('insert into public.%I default values', t), '42501', null,
  format('[data 7] anon cannot add rows to %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms']) as t;
select throws_ok(format('update public.%I set %I = %I', t, c, c), '42501', null,
  format('[data 7] anon cannot change rows in %s', t))
  from (values ('units', 'slug'), ('dialogues', 'slug'), ('dialogue_lines', 'speaker'),
               ('tokens', 'surface'), ('forms', 'lemma')) as x(t, c);
select throws_ok(format('delete from public.%I', t), '42501', null,
  format('[data 7] anon cannot delete rows from %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms']) as t;

reset role;

-- [data 6] Approved content cannot change silently (as the database owner) ---------------

select throws_like(
  format($$update public.dialogue_lines set %I = 'pgtap changed' where gloss_en = 'pgtap line approved'$$, col),
  '%approved content cannot change%',
  format('[data 6] the %s of an approved line cannot change', col)
) from unnest(array['text_puhe', 'text_kirja', 'gloss_en', 'audio_puhe_key', 'audio_kirja_key', 'speaker']) as col;
select throws_like(
  $$update public.dialogue_lines set status = 'draft', text_puhe = 'pgtap changed' where gloss_en = 'pgtap line approved'$$,
  '%approved content cannot change%',
  '[data 6] an approved line cannot be un-approved and changed in the same step'
);
select throws_like(
  format($$update public.forms set %I = 'pgtap changed' where form_tag = 'pgtap-approved'$$, col),
  '%approved content cannot change%',
  format('[data 6] the %s of an approved form cannot change', col)
) from unnest(array['surface_kirja', 'surface_puhe', 'form_name_en', 'why_en']) as col;
select throws_like(
  $$update public.dialogues set title_en = 'pgtap changed' where slug = 'pgtap-dialogue-approved'$$,
  '%approved content cannot change%',
  '[data 6] the title of an approved dialogue cannot change'
);
select throws_like(
  $$update public.units set title_en = 'pgtap changed' where slug = 'pgtap-unit-approved'$$,
  '%approved content cannot change%',
  '[data 6] the title of an approved unit cannot change'
);
select throws_like(
  $$delete from public.dialogue_lines where gloss_en = 'pgtap line to approve'$$,
  '%approved content cannot be deleted%',
  '[data 6] an approved line cannot be deleted'
);
select throws_like(
  $$update public.tokens set surface = 'pgtap changed' where surface = 'pgtap-token-approved-puhe'$$,
  '%tokens of an approved line cannot change%',
  '[data 6] a token of an approved line cannot change'
);
select throws_like(
  $$insert into public.tokens (line_id, register, position, surface)
    values (current_setting('test.line_approved')::bigint, 'puhe', 2, 'pgtap-token-new')$$,
  '%tokens of an approved line cannot change%',
  '[data 6] a token cannot be added to an approved line'
);
select throws_like(
  $$delete from public.tokens where surface = 'pgtap-token-approved-kirja'$$,
  '%tokens of an approved line cannot change%',
  '[data 6] a token of an approved line cannot be deleted'
);
select throws_like(
  $$update public.tokens set line_id = current_setting('test.line_approved')::bigint
    where surface = 'pgtap-token-draft-line'$$,
  '%tokens of an approved line cannot change%',
  '[data 6] a token cannot be moved onto an approved line'
);

-- Un-approve, change, approve again, in the order the pipeline must use: the
-- dialogue goes back to draft first, so learners never see it with a line missing.
select throws_like(
  $$update public.dialogue_lines set status = 'draft' where gloss_en = 'pgtap line ready'$$,
  '%back to draft first%',
  '[data 6] a line cannot be set back to draft while its dialogue is approved'
);
select lives_ok(
  $$update public.dialogues set status = 'draft' where slug = 'pgtap-dialogue-ready'$$,
  '[data 6] the dialogue can be set back to draft'
);
select lives_ok(
  $$update public.dialogue_lines set status = 'draft' where gloss_en = 'pgtap line ready'$$,
  '[data 6] then its approved line can be set back to draft'
);
select row_eq(
  $$select approved_at, approval_ref from public.dialogue_lines where gloss_en = 'pgtap line ready'$$,
  row(null::timestamptz, null::text),
  '[data 6] setting a line back to draft withdraws its approval: approved_at and approval_ref are cleared'
);
select row_eq(
  $$select approved_at, approval_ref from public.dialogues where slug = 'pgtap-dialogue-ready'$$,
  row(null::timestamptz, null::text),
  '[data 6] setting a dialogue back to draft withdraws its approval too'
);

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is_empty(
  $$select 1 from public.dialogues where slug = 'pgtap-dialogue-ready'$$,
  '[data 6] a dialogue set back to draft is hidden from learners'
);
select is_empty(
  $$select 1 from public.dialogue_lines where gloss_en = 'pgtap line ready'$$,
  '[data 6] and so is its line'
);
reset role;

select lives_ok(
  $$update public.dialogue_lines set text_puhe = 'pgtap changed puhe' where gloss_en = 'pgtap line ready'$$,
  '[data 6] the draft line can now be changed'
);
select lives_ok(
  $$update public.tokens set surface = 'pgtap-token-ready-changed' where surface = 'pgtap-token-ready'$$,
  '[data 6] the tokens of the draft line can now be changed'
);
select throws_ok(
  $$update public.dialogue_lines set status = 'approved' where gloss_en = 'pgtap line ready'$$,
  '23514', null,
  '[data 6] the changed line cannot be approved again by its status alone'
);
select throws_like(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 4'
    where gloss_en = 'pgtap line ready'$$,
  '%approval reference was already used%',
  '[data 6] the changed line cannot be approved again with its old approval reference'
);
select lives_ok(
  $$update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 6'
    where gloss_en = 'pgtap line ready'$$,
  '[data 6] the changed line can be approved again with a new review'
);
select throws_ok(
  $$update public.dialogues set status = 'approved' where slug = 'pgtap-dialogue-ready'$$,
  '23514', null,
  '[data 6] the dialogue cannot be approved again by its status alone'
);
select throws_like(
  $$update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 7'
    where slug = 'pgtap-dialogue-ready'$$,
  '%approval reference was already used%',
  '[data 6] the dialogue cannot be approved again with its old approval reference'
);
select lives_ok(
  $$update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 8'
    where slug = 'pgtap-dialogue-ready'$$,
  '[data 6] and then its dialogue, with a new review'
);

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select results_eq(
  $$select text_puhe from public.dialogue_lines where gloss_en = 'pgtap line ready'$$,
  array['pgtap changed puhe'],
  '[data 6] learners see the changed line once it and its dialogue are approved again'
);
reset role;

-- [data 14] Content in use cannot be deleted; it is retired instead ----------------------
-- Matched on the constraint's name: Postgres 17 reports a restrict as 23503 and
-- Postgres 18 as 23001, and the name proves which link refused the delete.

select throws_like(
  $$delete from public.forms where form_tag = 'pgtap-draft'$$,
  '%foreign key constraint "tokens_form_id_fkey"%',
  '[data 14] a form that a token points to cannot be deleted'
);
select throws_like(
  $$delete from public.dialogue_lines where gloss_en = 'pgtap line draft in draft dialogue'$$,
  '%foreign key constraint "tokens_line_id_fkey"%',
  '[data 14] a line that tokens point to cannot be deleted'
);
select throws_like(
  $$delete from public.dialogues where slug = 'pgtap-dialogue-draft'$$,
  '%foreign key constraint "dialogue_lines_dialogue_id_fkey"%',
  '[data 14] a dialogue that lines point to cannot be deleted'
);
select throws_like(
  $$delete from public.units where slug = 'pgtap-unit-draft'$$,
  '%foreign key constraint "dialogues_unit_id_fkey"%',
  '[data 14] a unit that dialogues point to cannot be deleted'
);
select lives_ok(
  $$update public.forms set status = 'retired' where form_tag = 'pgtap-approved'$$,
  '[data 14] an approved form can be retired instead'
);
select row_eq(
  $$select approved_at, approval_ref from public.forms where form_tag = 'pgtap-approved'$$,
  row(null::timestamptz, null::text),
  '[data 6] retiring a form withdraws its approval'
);
select throws_like(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap review 3'
    where form_tag = 'pgtap-approved'$$,
  '%approval reference was already used%',
  '[data 6] a retired form cannot be approved again with its old approval reference'
);
select lives_ok(
  $$update public.units set status = 'retired' where slug = 'pgtap-unit-approved'$$,
  '[data 14] an approved unit can be retired instead'
);

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is_empty(
  $$select 1 from public.dialogue_lines where gloss_en like 'pgtap %'$$,
  '[data 5] [data 14] once its unit is retired, none of its lines can be read'
);
reset role;

select * from finish();

rollback;
