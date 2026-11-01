-- The A1 road: tables, links, word card texts, access rules and the two functions (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/20-a1-road/spec.md that each test protects: [a1-road N].
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind, also when it runs
-- against the test project. The 36 real stops and 6 parts come from the migration; the test
-- content uses stops 9001 to 9004, which the road allows (stops past 36 are later legs).
--
-- Test learners (made inside this transaction). Acting as a learner means what PostgREST does: put
-- the token's claims in request.jwt.claims and switch to the authenticated role.
--   A = ...0020a1  finished dialogue 1 twice, 3 and 4, has 2 open, holds cards for four forms
--   B = ...0020b1  finished dialogues 1 to 5, reviewed every new form of stop 9001 and of stop 9002
--   C = ...0020c1  holds a card for one form but only has an open session
--   D = ...0020d1  nothing but a finished session on the draft dialogue 6
--
-- Test content. Stop 9001 has three approved dialogues (d1 to d3) in an approved unit, stop 9002 has
-- two approved dialogues and a draft third (d6), stop 9003 has an approved dialogue in a draft unit,
-- stop 9004 has no unit. Forms: f0 is first met in d1 (and again in d4, stop 9002), f1 and f2 in
-- d1, f3 in d2 (and again in d3), f4 in d3, f5 in d4, f6 in d5, f7 only in the draft line of d6,
-- f8 only in the dialogue of the draft unit.

begin;

create extension if not exists pgtap with schema extensions;

select plan(123);

-- [a1-road 1] The two tables, their rows and their limits --------------------------------

select has_table('public', 'road_parts', '[a1-road 1] road_parts exists');
select has_table('public', 'road_stops', '[a1-road 1] road_stops exists');
select columns_are('public', 'road_parts', array['number', 'title_en'],
  '[a1-road 1] road_parts has exactly its listed columns');
select columns_are('public', 'road_stops',
  array['number', 'slug', 'part_number', 'name_en', 'can_do_en', 'planned_dialogues'],
  '[a1-road 1] road_stops has exactly its listed columns');
select is((select count(*) from public.road_parts), 6::bigint, '[a1-road 1] the road has 6 parts');
select is((select count(*) from public.road_stops), 36::bigint, '[a1-road 1] the road has 36 stops');
select is((select name_en from public.road_stops where number = 4), 'Numbers, prices and paying',
  '[a1-road 1] stop 4 is Numbers, prices and paying');
select is((select can_do_en from public.road_stops where number = 4),
  'ask what something costs and pay by card or cash.',
  '[a1-road 1] stop 4 has the I can sentence of the markdown');
select is((select title_en from public.road_parts where number = 1), 'First words',
  '[a1-road 1] part 1 is First words');
select is((select part_number from public.road_stops where number = 7), 2,
  '[a1-road 1] stop 7 is in part 2');
select is((select array_agg(number order by number) from public.road_parts), array[1, 2, 3, 4, 5, 6],
  '[a1-road 1] the parts are numbered 1 to 6');
select lives_ok(
  $$insert into public.road_parts (number, title_en) values (7, 'pgtap later part')$$,
  '[a1-road 1] a part past 6 is allowed, for a later leg');
select lives_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (37, 'pgtap-stop-37', 7, 'pgtap stop', 'pgtap can do')$$,
  '[a1-road 1] a stop past 36 is allowed, for a later leg');
delete from public.road_stops where number = 37;
delete from public.road_parts where number = 7;
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (0, 'pgtap-zero', 1, 'pgtap stop', 'pgtap can do')$$,
  '23514', null, '[a1-road 1] a stop number must be above 0');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (9100, 'Not A Slug', 1, 'pgtap stop', 'pgtap can do')$$,
  '23514', null, '[a1-road 1] a stop slug is lower case words with hyphens');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (9100, 'pgtap-blank-name', 1, '  ', 'pgtap can do')$$,
  '23514', null, '[a1-road 1] a stop name cannot be blank');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (9100, 'pgtap-blank-can-do', 1, 'pgtap stop', '  ')$$,
  '23514', null, '[a1-road 1] an I can sentence cannot be blank');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en, planned_dialogues)
    values (9100, 'pgtap-no-dialogues', 1, 'pgtap stop', 'pgtap can do', 0)$$,
  '23514', null, '[a1-road 1] a stop plans at least one dialogue');
select throws_ok(
  $$insert into public.road_parts (number, title_en) values (9100, ' ')$$,
  '23514', null, '[a1-road 1] a part title cannot be blank');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (9100, 'pgtap-no-part', 99, 'pgtap stop', 'pgtap can do')$$,
  '23503', null, '[a1-road 1] a stop must be in a part that exists');

-- [a1-road 2] A unit may be a stop's content ----------------------------------------------

select col_is_unique('public', 'units', 'stop_number', '[a1-road 2] a stop has at most one unit');
select fk_ok('public', 'units', 'stop_number', 'public', 'road_stops', 'number',
  '[a1-road 2] units.stop_number links to road_stops');
select throws_ok(
  $$insert into public.units (slug, position, title_en, can_do_en, stop_number)
    values ('pgtap-road-unit-bad', 6, 'pgtap unit', 'pgtap can do', 5)$$,
  '23514', null, '[a1-road 2] a unit''s stop number must equal its position');
select lives_ok(
  $$insert into public.units (slug, position, title_en, can_do_en)
    values ('pgtap-road-unit-none', 9900, 'pgtap unit', 'pgtap can do')$$,
  '[a1-road 2] a unit with no stop number is allowed (the test fixture units)');

-- [a1-road 3] The two word card texts of a form -------------------------------------------
-- Each failing case below breaks one condition only. Draft forms keep every other text valid.

insert into public.forms
  (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, meaning_en, lemma_meaning_en)
values
  ('pgtap-road-m-ok', 't', 'k', 'p', 'pgtap name', 'pgtap why', 'those', 'that'),
  ('pgtap-road-m-null', 't', 'k', 'p', 'pgtap name', 'pgtap why', null, 'that'),
  ('pgtap-road-l-null', 't', 'k', 'p', 'pgtap name', 'pgtap why', 'those', null),
  ('pgtap-road-m-blank', 't', 'k', 'p', 'pgtap name', 'pgtap why', '   ', 'that'),
  ('pgtap-road-l-blank', 't', 'k', 'p', 'pgtap name', 'pgtap why', 'those', '   '),
  ('pgtap-road-m-edit', 't', 'k', 'p', 'pgtap name', 'pgtap why', 'those', 'that');

select lives_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m1'
    where lemma = 'pgtap-road-m-ok'$$,
  '[a1-road 3] a form with both meanings can be approved');
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m2'
    where lemma = 'pgtap-road-m-null'$$,
  '23514', null, '[a1-road 3] a form cannot be approved without its meaning');
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m3'
    where lemma = 'pgtap-road-l-null'$$,
  '23514', null, '[a1-road 3] a form cannot be approved without its dictionary form''s meaning');
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m4'
    where lemma = 'pgtap-road-m-blank'$$,
  '23514', null, '[a1-road 3] a form cannot be approved with a blank meaning');
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m5'
    where lemma = 'pgtap-road-l-blank'$$,
  '23514', null, '[a1-road 3] a form cannot be approved with a blank dictionary form meaning');
select throws_ok(
  $$update public.forms set meaning_en = repeat('m', 61) where lemma = 'pgtap-road-m-edit'$$,
  '23514', null, '[a1-road 3] a meaning cannot be longer than 60 characters');
select lives_ok(
  $$update public.forms set meaning_en = repeat('m', 60) where lemma = 'pgtap-road-m-edit'$$,
  '[a1-road 3] a meaning of exactly 60 characters is accepted');
select throws_ok(
  $$update public.forms set lemma_meaning_en = repeat('l', 61) where lemma = 'pgtap-road-m-edit'$$,
  '23514', null, '[a1-road 3] a dictionary form meaning cannot be longer than 60 characters');
select lives_ok(
  $$update public.forms set lemma_meaning_en = repeat('l', 60) where lemma = 'pgtap-road-m-edit'$$,
  '[a1-road 3] a dictionary form meaning of exactly 60 characters is accepted');
select throws_ok(
  $$update public.forms set meaning_en = 'a' || chr(10) || 'b' where lemma = 'pgtap-road-m-edit'$$,
  '23514', null, '[a1-road 3] a meaning cannot hold a line break');
select throws_ok(
  $$update public.forms set lemma_meaning_en = 'a' || chr(9) || 'b' where lemma = 'pgtap-road-m-edit'$$,
  '23514', null, '[a1-road 3] a dictionary form meaning cannot hold a control character');
select throws_like(
  $$update public.forms set meaning_en = 'changed' where lemma = 'pgtap-road-m-ok'$$,
  '%approved content cannot change%', '[a1-road 3] the meaning of an approved form cannot change');
select throws_like(
  $$update public.forms set lemma_meaning_en = 'changed' where lemma = 'pgtap-road-m-ok'$$,
  '%approved content cannot change%',
  '[a1-road 3] the dictionary form meaning of an approved form cannot change');
select lives_ok(
  $$update public.forms set status = 'draft' where lemma = 'pgtap-road-m-ok'$$,
  '[a1-road 3] an approved form can be set back to draft');
select row_eq(
  $$select approved_at, approval_ref from public.forms where lemma = 'pgtap-road-m-ok'$$,
  row(null::timestamptz, null::text),
  '[a1-road 3] setting a form back to draft withdraws its approval, as before');
select throws_like(
  $$update public.forms set status = 'approved', approved_at = now(), approval_ref = 'pgtap road m1'
    where lemma = 'pgtap-road-m-ok'$$,
  '%approval reference was already used%',
  '[a1-road 3] approving it again with the old reference is refused, as before');

-- [a1-road 4] Access to the two tables -----------------------------------------------------

select table_privs_are('public', 'road_parts', 'anon', array[]::text[],
  '[a1-road 4] anon has no permission on road_parts');
select table_privs_are('public', 'road_parts', 'service_role', array[]::text[],
  '[a1-road 4] service_role has no permission on road_parts');
select table_privs_are('public', 'road_parts', 'authenticated', array['SELECT'],
  '[a1-road 4] a learner may only read road_parts');
select table_privs_are('public', 'road_stops', 'anon', array[]::text[],
  '[a1-road 4] anon has no permission on road_stops');
select table_privs_are('public', 'road_stops', 'service_role', array[]::text[],
  '[a1-road 4] service_role has no permission on road_stops');
select table_privs_are('public', 'road_stops', 'authenticated', array['SELECT'],
  '[a1-road 4] a learner may only read road_stops');
select ok((select relrowsecurity from pg_class where oid = 'public.road_parts'::regclass),
  '[a1-road 4] row level security is on for road_parts');
select ok((select relrowsecurity from pg_class where oid = 'public.road_stops'::regclass),
  '[a1-road 4] row level security is on for road_stops');
select policies_are('public', 'road_parts', array['learners read the road parts'],
  '[a1-road 4] road_parts has exactly one rule');
select policies_are('public', 'road_stops', array['learners read the road stops'],
  '[a1-road 4] road_stops has exactly one rule');

set local role anon;
select throws_ok($$select * from public.road_parts$$, '42501', null,
  '[a1-road 4] anon cannot read road_parts');
select throws_ok($$select * from public.road_stops$$, '42501', null,
  '[a1-road 4] anon cannot read road_stops');
reset role;
set local role service_role;
select throws_ok($$select * from public.road_parts$$, '42501', null,
  '[a1-road 4] service_role cannot read road_parts');
select throws_ok($$select * from public.road_stops$$, '42501', null,
  '[a1-road 4] service_role cannot read road_stops');
reset role;

-- Test content and learners, written as the database owner ---------------------------------

insert into public.road_stops (number, slug, part_number, name_en, can_do_en, planned_dialogues) values
  (9001, 'pgtap-road-9001', 1, 'pgtap stop 9001', 'pgtap can do', 3),
  (9002, 'pgtap-road-9002', 1, 'pgtap stop 9002', 'pgtap can do', 3),
  (9003, 'pgtap-road-9003', 1, 'pgtap stop 9003', 'pgtap can do', 3),
  (9004, 'pgtap-road-9004', 1, 'pgtap stop 9004', 'pgtap can do', 3);

insert into public.units (slug, position, title_en, can_do_en, stop_number) values
  ('pgtap-road-unit-9001', 9001, 'pgtap unit', 'pgtap can do', 9001),
  ('pgtap-road-unit-9002', 9002, 'pgtap unit', 'pgtap can do', 9002),
  ('pgtap-road-unit-9003', 9003, 'pgtap unit', 'pgtap can do', 9003);

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.pos, 'pgtap dialogue'
  from (values
    ('pgtap-road-d1', 'pgtap-road-unit-9001', 1), ('pgtap-road-d2', 'pgtap-road-unit-9001', 2),
    ('pgtap-road-d3', 'pgtap-road-unit-9001', 3), ('pgtap-road-d4', 'pgtap-road-unit-9002', 1),
    ('pgtap-road-d5', 'pgtap-road-unit-9002', 2), ('pgtap-road-d6', 'pgtap-road-unit-9002', 3),
    ('pgtap-road-d7', 'pgtap-road-unit-9003', 1)
  ) as d(slug, unit_slug, pos)
  join public.units u on u.slug = d.unit_slug;

insert into public.forms
  (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, meaning_en, lemma_meaning_en,
   status, approved_at, approval_ref)
select 'pgtap-road-f' || n, 'pgtap-road', 'k' || n, 'p' || n, 'pgtap name', 'pgtap why', 'pgtap meaning',
       'pgtap dictionary meaning', 'approved', now(), 'pgtap road form ' || n
  from generate_series(0, 8) as n;

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, l.pos, 'pgtap', 'pgtap puhe', 'pgtap kirja', 'pgtap gloss', 'pgtap-road/p.mp3', 'pgtap-road/k.mp3'
  from (values
    ('pgtap-road-d1', 1), ('pgtap-road-d1', 2), ('pgtap-road-d2', 1), ('pgtap-road-d3', 1),
    ('pgtap-road-d4', 1), ('pgtap-road-d5', 1), ('pgtap-road-d6', 1), ('pgtap-road-d7', 1)
  ) as l(dialogue_slug, pos)
  join public.dialogues d on d.slug = l.dialogue_slug;

insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, 'kirja'::public.finnish_register, t.pos, 'pgtap-token', f.id
  from (values
    ('pgtap-road-d1', 1, 1, 'pgtap-road-f0'), ('pgtap-road-d1', 1, 2, 'pgtap-road-f1'),
    ('pgtap-road-d1', 2, 1, 'pgtap-road-f2'), ('pgtap-road-d2', 1, 1, 'pgtap-road-f3'),
    ('pgtap-road-d3', 1, 1, 'pgtap-road-f3'), ('pgtap-road-d3', 1, 2, 'pgtap-road-f4'),
    ('pgtap-road-d4', 1, 1, 'pgtap-road-f0'), ('pgtap-road-d4', 1, 2, 'pgtap-road-f5'),
    ('pgtap-road-d5', 1, 1, 'pgtap-road-f6'), ('pgtap-road-d6', 1, 1, 'pgtap-road-f7'),
    ('pgtap-road-d7', 1, 1, 'pgtap-road-f8')
  ) as t(dialogue_slug, line_pos, pos, lemma)
  join public.dialogues d on d.slug = t.dialogue_slug
  join public.dialogue_lines l on l.dialogue_id = d.id and l.position = t.line_pos
  join public.forms f on f.lemma = t.lemma;

-- Approve in the order the model needs: lines, then dialogues, then units. d6 stays a draft.
update public.dialogue_lines l set status = 'approved', approved_at = now(), approval_ref = 'pgtap road line'
  from public.dialogues d
 where d.id = l.dialogue_id and d.slug <> 'pgtap-road-d6' and d.slug like 'pgtap-road-d%';
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap road dialogue'
 where slug like 'pgtap-road-d%' and slug <> 'pgtap-road-d6';
update public.units set status = 'approved', approved_at = now(), approval_ref = 'pgtap road unit'
 where slug in ('pgtap-road-unit-9001', 'pgtap-road-unit-9002');

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000020a1'),
  ('00000000-0000-4000-8000-0000000020b1'),
  ('00000000-0000-4000-8000-0000000020c1'),
  ('00000000-0000-4000-8000-0000000020d1');

-- Sessions: learner, dialogue, finished or still open.
insert into public.sessions (user_id, dialogue_id, step_reached, started_at, ended_at)
select s.user_id::uuid, d.id, 'understand'::public.loop_step, now() - interval '2 days',
       case when s.finished then now() - interval '1 day' else null end
  from (values
    ('00000000-0000-4000-8000-0000000020a1', 'pgtap-road-d1', true),
    ('00000000-0000-4000-8000-0000000020a1', 'pgtap-road-d1', true),
    ('00000000-0000-4000-8000-0000000020a1', 'pgtap-road-d2', false),
    ('00000000-0000-4000-8000-0000000020a1', 'pgtap-road-d3', true),
    ('00000000-0000-4000-8000-0000000020a1', 'pgtap-road-d4', true),
    ('00000000-0000-4000-8000-0000000020b1', 'pgtap-road-d1', true),
    ('00000000-0000-4000-8000-0000000020b1', 'pgtap-road-d2', true),
    ('00000000-0000-4000-8000-0000000020b1', 'pgtap-road-d3', true),
    ('00000000-0000-4000-8000-0000000020b1', 'pgtap-road-d4', true),
    ('00000000-0000-4000-8000-0000000020b1', 'pgtap-road-d5', true),
    ('00000000-0000-4000-8000-0000000020c1', 'pgtap-road-d1', false),
    ('00000000-0000-4000-8000-0000000020d1', 'pgtap-road-d6', true)
  ) as s(user_id, dialogue_slug, finished)
  join public.dialogues d on d.slug = s.dialogue_slug;

-- Cards: learner and form number.
insert into public.cards (user_id, form_id)
select c.user_id::uuid, f.id
  from (values
    ('00000000-0000-4000-8000-0000000020a1', 0), ('00000000-0000-4000-8000-0000000020a1', 1),
    ('00000000-0000-4000-8000-0000000020a1', 2), ('00000000-0000-4000-8000-0000000020a1', 4),
    ('00000000-0000-4000-8000-0000000020b1', 0), ('00000000-0000-4000-8000-0000000020b1', 1),
    ('00000000-0000-4000-8000-0000000020b1', 2), ('00000000-0000-4000-8000-0000000020b1', 3),
    ('00000000-0000-4000-8000-0000000020b1', 4), ('00000000-0000-4000-8000-0000000020b1', 5),
    ('00000000-0000-4000-8000-0000000020b1', 6), ('00000000-0000-4000-8000-0000000020c1', 1)
  ) as c(user_id, n)
  join public.forms f on f.lemma = 'pgtap-road-f' || c.n;

-- Review logs: learner and form number (B reviewed f5 twice).
insert into public.review_logs
  (user_id, form_id, rating, mode, state, due, stability, difficulty, elapsed_days, last_elapsed_days,
   scheduled_days, review_time)
select r.user_id::uuid, f.id, 3, 'typed'::public.review_mode, 'review'::public.card_state, now(), 1, 1,
       0, 0, 1, now()
  from (values
    ('00000000-0000-4000-8000-0000000020a1', 0), ('00000000-0000-4000-8000-0000000020a1', 1),
    ('00000000-0000-4000-8000-0000000020a1', 2),
    ('00000000-0000-4000-8000-0000000020b1', 0), ('00000000-0000-4000-8000-0000000020b1', 1),
    ('00000000-0000-4000-8000-0000000020b1', 2), ('00000000-0000-4000-8000-0000000020b1', 3),
    ('00000000-0000-4000-8000-0000000020b1', 4), ('00000000-0000-4000-8000-0000000020b1', 5),
    ('00000000-0000-4000-8000-0000000020b1', 5), ('00000000-0000-4000-8000-0000000020b1', 6),
    ('00000000-0000-4000-8000-0000000020c1', 1)
  ) as r(user_id, n)
  join public.forms f on f.lemma = 'pgtap-road-f' || r.n;

-- [a1-road 4] What a learner reads and cannot write ------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000020a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.road_stops where number <= 36), 36::bigint,
  '[a1-road 4] a learner reads every road stop');
select is((select count(*) from public.road_parts where number <= 6), 6::bigint,
  '[a1-road 4] a learner reads every road part');
select throws_ok(
  $$insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
    values (9200, 'pgtap-learner', 1, 'x', 'x')$$,
  '42501', null, '[a1-road 4] a learner cannot add a stop');
select throws_ok(
  $$insert into public.road_parts (number, title_en) values (9200, 'x')$$,
  '42501', null, '[a1-road 4] a learner cannot add a part');
select throws_ok(
  $$update public.road_stops set name_en = 'changed' where number = 4$$,
  '42501', null, '[a1-road 4] a learner cannot change a stop');
select throws_ok(
  $$update public.road_parts set title_en = 'changed' where number = 1$$,
  '42501', null, '[a1-road 4] a learner cannot change a part');
select throws_ok(
  $$delete from public.road_stops where number = 4$$,
  '42501', null, '[a1-road 4] a learner cannot delete a stop');
select throws_ok(
  $$delete from public.road_parts where number = 1$$,
  '42501', null, '[a1-road 4] a learner cannot delete a part');

-- [a1-road 5] public.road() ---------------------------------------------------------------

select has_function('public', 'road', array[]::text[], '[a1-road 5] public.road() exists');
select ok(not (select prosecdef from pg_proc where oid = 'public.road()'::regprocedure),
  '[a1-road 5] road() is security invoker, so the learner''s own read rules apply');
select is((select provolatile::text from pg_proc where oid = 'public.road()'::regprocedure), 's',
  '[a1-road 5] road() is stable, so Postgres refuses any write inside it');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.road()'::regprocedure),
  '[a1-road 5] road() runs with an empty search_path');
select is(pg_get_function_result('public.road()'::regprocedure),
  'TABLE(stop_number integer, stop_slug text, title_en text, can_do_en text, part_number integer, '
  || 'part_title_en text, dialogues_total integer, dialogues_ready integer, dialogues_done integer, '
  || 'review_forms_total integer, review_forms_reviewed integer, lessons_total integer, '
  || 'lessons_done integer, live boolean)',
  '[a1-road 5] road() returns the listed columns: counts, names and sentences, never a Finnish word or an id');
select ok(has_function_privilege('authenticated', 'public.road()', 'EXECUTE'),
  '[a1-road 5] a learner may call road()');
select ok(not has_function_privilege('anon', 'public.road()', 'EXECUTE'),
  '[a1-road 5] anon may not call road()');
select ok(not has_function_privilege('service_role', 'public.road()', 'EXECUTE'),
  '[a1-road 5] service_role may not call road()');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.road()'::regprocedure and x.grantee = 0 $$,
  '[a1-road 5] PUBLIC may not call road()');

-- Learner A -------------------------------------------------------------------------------

select is((select count(*) from public.road() where stop_number <= 36), 36::bigint,
  '[a1-road 5] road() always returns all 36 stops');
select is((select count(*) from public.road()), 40::bigint,
  '[a1-road 5] road() returns the 36 stops and the 4 test stops, in one row each');
select is((select array_agg(stop_number order by stop_number) from public.road() where stop_number <= 5),
  array[1, 2, 3, 4, 5], '[a1-road 5] road() is in stop order');
select row_eq(
  $$select stop_slug, title_en, can_do_en, part_number, part_title_en from public.road() where stop_number = 4$$,
  row('numbers-prices-and-paying'::text, 'Numbers, prices and paying'::text,
      'ask what something costs and pay by card or cash.'::text, 1, 'First words'::text),
  '[a1-road 5] a row carries the stop, its I can sentence and its part');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9001$$,
  row(3, 3, 2, 5, 3, 4, 2, true),
  '[a1-road 5] A, stop 9001: 3 ready, 2 done (one dialogue finished twice counts once, an open session does not), 3 of 5 new forms reviewed, live');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9002$$,
  row(3, 2, 1, 2, 0, 4, 1, false),
  '[a1-road 5] A, stop 9002: a draft dialogue and its form are not counted, f0 is a new form of an earlier stop, so not live');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9003$$,
  row(3, 0, 0, 0, 0, 4, 0, false),
  '[a1-road 5] stop 9003: an approved dialogue in an unapproved unit is not counted');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9004$$,
  row(3, 0, 0, 0, 0, 4, 0, false),
  '[a1-road 5] a stop with no unit has all counts at zero');

-- [a1-road 6] public.stop_review_forms(stop) ---------------------------------------------

select has_function('public', 'stop_review_forms', array['integer'],
  '[a1-road 6] public.stop_review_forms(integer) exists');
select ok(not (select prosecdef from pg_proc where oid = 'public.stop_review_forms(integer)'::regprocedure),
  '[a1-road 6] stop_review_forms is security invoker');
select is((select provolatile::text from pg_proc where oid = 'public.stop_review_forms(integer)'::regprocedure),
  's', '[a1-road 6] stop_review_forms is stable, so it writes nothing');
select ok(
  (select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.stop_review_forms(integer)'::regprocedure),
  '[a1-road 6] stop_review_forms runs with an empty search_path');
select is(pg_get_function_result('public.stop_review_forms(integer)'::regprocedure), 'TABLE(form_id bigint)',
  '[a1-road 6] stop_review_forms returns form ids and nothing else');
select ok(has_function_privilege('authenticated', 'public.stop_review_forms(integer)', 'EXECUTE'),
  '[a1-road 6] a learner may call stop_review_forms');
select ok(not has_function_privilege('anon', 'public.stop_review_forms(integer)', 'EXECUTE'),
  '[a1-road 6] anon may not call stop_review_forms');
select ok(not has_function_privilege('service_role', 'public.stop_review_forms(integer)', 'EXECUTE'),
  '[a1-road 6] service_role may not call stop_review_forms');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.stop_review_forms(integer)'::regprocedure and x.grantee = 0 $$,
  '[a1-road 6] PUBLIC may not call stop_review_forms');
select is(
  array(select form_id from public.stop_review_forms(9001)),
  array[(select id from public.forms where lemma = 'pgtap-road-f0'),
        (select id from public.forms where lemma = 'pgtap-road-f1'),
        (select id from public.forms where lemma = 'pgtap-road-f2'),
        (select id from public.forms where lemma = 'pgtap-road-f4')],
  '[a1-road 6] A gets the met forms of stop 9001 in order of first appearance, and not f3, which has no card');
select is_empty($$select * from public.stop_review_forms(9002)$$,
  '[a1-road 6] A gets nothing for stop 9002: f0 was first met in an earlier stop, and B''s card for f5 is not A''s');
select is_empty($$select * from public.stop_review_forms(12345)$$,
  '[a1-road 6] a stop with no words returns nothing');
reset role;

-- Learner B -------------------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000020b1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9001$$,
  row(3, 3, 3, 5, 5, 4, 4, true),
  '[a1-road 5] B, stop 9001: only B''s own sessions and logs count, and the review lesson is done once every new form is reviewed');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9002$$,
  row(3, 2, 2, 2, 2, 4, 3, false),
  '[a1-road 5] B, stop 9002: two logs for one form count that form once');
select is(
  array(select form_id from public.stop_review_forms(9002)),
  array[(select id from public.forms where lemma = 'pgtap-road-f5'),
        (select id from public.forms where lemma = 'pgtap-road-f6')],
  '[a1-road 6] B gets f5 and f6 for stop 9002, and not f0, the form of an earlier stop');
select is(
  array(select form_id from public.stop_review_forms(9001)),
  array[(select id from public.forms where lemma = 'pgtap-road-f0'),
        (select id from public.forms where lemma = 'pgtap-road-f1'),
        (select id from public.forms where lemma = 'pgtap-road-f2'),
        (select id from public.forms where lemma = 'pgtap-road-f3'),
        (select id from public.forms where lemma = 'pgtap-road-f4')],
  '[a1-road 6] B gets all five new forms of stop 9001');
reset role;

-- Learner C: a card and a log, but only an open session -------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000020c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9001$$,
  row(3, 3, 0, 5, 1, 4, 0, true),
  '[a1-road 5] C, stop 9001: an open session is not a done dialogue, and one log counts one form');
select is_empty($$select * from public.stop_review_forms(9001)$$,
  '[a1-road 6] C holds a card for f1 but never finished a session with it, so nothing unmet is reviewed');
reset role;

-- Learner D: a finished session on a draft dialogue and nothing else ------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000020d1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9002$$,
  row(3, 2, 0, 2, 0, 4, 0, false),
  '[a1-road 5] D, stop 9002: a finished session on an unapproved dialogue is not a done dialogue');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road() where stop_number = 9001$$,
  row(3, 3, 0, 5, 0, 4, 0, true),
  '[a1-road 5] D, stop 9001: a learner with no sessions and no logs has zero progress');
reset role;

-- [a1-road 5] [a1-road 6] anon and service_role are refused ------------------------------------

set local role anon;
select throws_ok($$select * from public.road()$$, '42501', null, '[a1-road 5] anon cannot call road()');
select throws_ok($$select * from public.stop_review_forms(9001)$$, '42501', null,
  '[a1-road 6] anon cannot call stop_review_forms');
reset role;
set local role service_role;
select throws_ok($$select * from public.road()$$, '42501', null, '[a1-road 5] service_role cannot call road()');
reset role;

-- [a1-road 29] public.road_for_visitors(): the road with no progress, for a visitor with no account -------

select has_function('public', 'road_for_visitors', array[]::text[], '[a1-road 29] public.road_for_visitors() exists');
select ok((select prosecdef from pg_proc where oid = 'public.road_for_visitors()'::regprocedure),
  '[a1-road 29] road_for_visitors() is security definer, because the road tables are closed to anon');
select is((select provolatile::text from pg_proc where oid = 'public.road_for_visitors()'::regprocedure), 's',
  '[a1-road 29] road_for_visitors() is stable, so Postgres refuses any write inside it');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.road_for_visitors()'::regprocedure),
  '[a1-road 29] road_for_visitors() runs with an empty search_path');
select is(pg_get_function_result('public.road_for_visitors()'::regprocedure),
  pg_get_function_result('public.road()'::regprocedure),
  '[a1-road 29] road_for_visitors() returns exactly the 14 columns of road()');
select ok(has_function_privilege('anon', 'public.road_for_visitors()', 'EXECUTE'),
  '[a1-road 29] anon may call road_for_visitors()');
select ok(not has_function_privilege('authenticated', 'public.road_for_visitors()', 'EXECUTE'),
  '[a1-road 29] a learner does not call road_for_visitors(), they call road()');
select ok(not has_function_privilege('service_role', 'public.road_for_visitors()', 'EXECUTE'),
  '[a1-road 29] service_role may not call road_for_visitors()');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.road_for_visitors()'::regprocedure and x.grantee = 0 $$,
  '[a1-road 29] PUBLIC may not call road_for_visitors()');
select cmp_ok((select count(*) from public.sessions
                where user_id::text like '00000000-0000-4000-8000-0000000020%' and ended_at is not null),
  '>', 0::bigint, '[a1-road 29] the test learners do have finished sessions, so zero progress below is a real answer');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000020b1", "role": "authenticated", "is_anonymous": true}', true);
set local role anon;
select is((select count(*) from public.road_for_visitors()), 40::bigint,
  '[a1-road 29] anon gets the 36 stops and the 4 test stops, in one row each, even with a learner''s claims in the request');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road_for_visitors() where stop_number = 9001$$,
  row(3, 3, 0, 5, 0, 4, 0, true),
  '[a1-road 29] stop 9001: 3 ready, 5 new forms, live, and no progress although learner B has finished all of it');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road_for_visitors() where stop_number = 9002$$,
  row(3, 2, 0, 2, 0, 4, 0, false),
  '[a1-road 29] stop 9002: a draft dialogue and its form are not counted, and there is no progress');
select row_eq(
  $$select dialogues_total, dialogues_ready, dialogues_done, review_forms_total, review_forms_reviewed,
           lessons_total, lessons_done, live from public.road_for_visitors() where stop_number = 9003$$,
  row(3, 0, 0, 0, 0, 4, 0, false),
  '[a1-road 29] stop 9003: an approved dialogue in an unapproved unit is not counted');
select is_empty(
  $$select 1 from public.road_for_visitors()
     where dialogues_done <> 0 or review_forms_reviewed <> 0 or lessons_done <> 0$$,
  '[a1-road 29] no stop has any progress for a visitor');
select throws_ok($$select * from public.road_stops$$, '42501', null,
  '[a1-road 29] anon still cannot read road_stops');
select throws_ok($$select * from public.sessions$$, '42501', null,
  '[a1-road 29] anon still cannot read sessions');
select throws_ok($$select * from public.review_logs$$, '42501', null,
  '[a1-road 29] anon still cannot read review_logs');
select throws_ok($$select * from public.units$$, '42501', null,
  '[a1-road 29] anon still cannot read units');
select throws_ok($$select * from public.road()$$, '42501', null,
  '[a1-road 29] anon still cannot call road(), so it never sees a learner''s progress');
reset role;

-- [a1-road 5] road() writes nothing ---------------------------------------------------------

select is((select count(*) from public.sessions where user_id::text like '00000000-0000-4000-8000-0000000020%'),
  12::bigint, '[a1-road 5] [a1-road 29] after all the calls the 12 test sessions are unchanged');

select * from finish();

rollback;
