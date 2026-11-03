-- The published A1 road, read as a learner (pgTAP). Made by scripts/generate/road_pgtap.py from
-- content/approvals/part-<n>.json and the drafts: do not edit by hand.
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/20-a1-road/spec.md that each test protects: [a1-road N].
--
-- Runs inside one transaction that is rolled back. The numbers are what the owner approved so far:
-- 36 stops, 108 dialogues, 852 lines, 36 live stops.
-- With no part approved they are zero and road() shows no live stop.

begin;

create extension if not exists pgtap with schema extensions;

select plan(9);

insert into auth.users (id) values ('00000000-0000-4000-8000-0000000022a1');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000022a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.units where stop_number is not null), 36::bigint,
  '[a1-road 22] a learner reads 36 approved road units');
select is((select count(*) from public.dialogues d join public.units u on u.id = d.unit_id
  where u.stop_number is not null), 108::bigint,
  '[a1-road 22] a learner reads 108 approved road dialogues');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  join public.units u on u.id = d.unit_id where u.stop_number is not null), 852::bigint,
  '[a1-road 22] a learner reads 852 approved road lines');
select is_empty(
  $$ select l.id from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
     join public.units u on u.id = d.unit_id
     where u.stop_number is not null and not (
    coalesce(btrim(l.text_puhe), '') <> '' and coalesce(btrim(l.text_kirja), '') <> ''
    and coalesce(btrim(l.gloss_en), '') <> ''
    and l.audio_puhe_key ~ ('^' || d.slug || '/' || l.position || '-puhe-[0-9a-f]{12}[.]mp3$')
    and l.audio_kirja_key ~ ('^' || d.slug || '/' || l.position || '-kirja-[0-9a-f]{12}[.]mp3$')
    and l.approval_ref like ('content/approvals/part-%.json#' || d.slug || '/line-' || l.position)
  ) $$,
  '[a1-road 22] every road line has both texts, the gloss, both audio keys and an owner approval reference');
select is_empty(
  $$ select t.id from public.tokens t join public.dialogue_lines l on l.id = t.line_id
     join public.dialogues d on d.id = l.dialogue_id join public.units u on u.id = d.unit_id
     where u.stop_number is not null and t.form_id is not null and not exists (
       select 1 from public.forms f where f.id = t.form_id
         and coalesce(btrim(f.form_name_en), '') <> '' and coalesce(btrim(f.why_en), '') <> ''
         and coalesce(btrim(f.meaning_en), '') <> '' and coalesce(btrim(f.lemma_meaning_en), '') <> ''
     ) $$,
  '[a1-road 22] every road word with a form links to an approved form with a name, a why and both meanings');
select is((select count(*) from public.road() where stop_number <= 36), 36::bigint,
  '[a1-road 22] road() shows all 36 stops');
select is((select count(*) from public.road() where live), 36::bigint,
  '[a1-road 22] road() shows 36 live stops');
reset role;

-- A draft line added now is not readable. The stop, its unit and its dialogue are drafts as well.

insert into public.road_stops (number, slug, part_number, name_en, can_do_en)
  values (9101, 'pgtap-road-published', 1, 'pgtap stop', 'pgtap can do');
insert into public.units (slug, position, title_en, can_do_en, stop_number)
  values ('pgtap-road-published-unit', 9101, 'pgtap unit', 'pgtap can do', 9101);
insert into public.dialogues (unit_id, slug, position, title_en)
  select u.id, 'pgtap-road-published-dialogue', 1, 'pgtap dialogue'
  from public.units u where u.slug = 'pgtap-road-published-unit';
insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en)
  select d.id, 1, 'pgtap', 'pgtap puhe', 'pgtap kirja', 'pgtap road published draft line'
  from public.dialogues d where d.slug = 'pgtap-road-published-dialogue';

set local role authenticated;
select is((select count(*) from public.dialogue_lines where gloss_en = 'pgtap road published draft line'), 0::bigint,
  '[a1-road 22] a draft line added in the test is not readable');
select is((select live from public.road() where stop_number = 9101), false,
  '[a1-road 22] a stop with only a draft unit is not live');
reset role;

select * from finish();

rollback;
