-- Published content (pgTAP). Made by scripts/generate/fixture_outputs.py from
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

-- [content 15] [content 16] The publish migration, twice --------------------------

select lives_ok($migration$
-- Publishes the dialogue pgtap-publish-fixture (unit pgtap-publish-unit). Made by
-- scripts/generate/pipeline.py publish from scripts/generate/fixtures/publish/draft.json. Do not edit by hand:
-- change the draft, get the changed items reviewed again and publish again.
-- Job 7-content-pipeline, "Done when" 15. Order (docs/data-model.md): forms, then
-- the lines with their words, then the dialogue, then the unit. Running it a second
-- time does nothing, because the dialogue is then already approved.
do $publish$
declare
  v_unit_id bigint;
  v_dialogue_id bigint;
  v_line_id bigint;
  v_status public.content_status;
begin
  if exists (select 1 from public.dialogues
    where slug = 'pgtap-publish-fixture' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'pgtap-publish-fixture';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en)
  values ('pgtap-publish-unit', 900101, 'pgtap publish unit', 'pgtap can do')
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'pgtap-publish-unit' and position = 900101
    and title_en = 'pgtap publish unit' and can_do_en = 'pgtap can do';
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'pgtap-publish-unit';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'pgtap-publish-fixture', 1,
    'pgtap publish fixture')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'pgtap-publish-fixture' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'pgtap publish fixture';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'pgtap-publish-fixture';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana"}'::jsonb,
    'minä', 'mä',
    'nominative singular',
    'pgtap why: Minä means I.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-mina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minä', 'pgtap-minä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana"}'::jsonb,
    'olen', 'oon',
    'present tense, 1st person singular',
    'pgtap why: it''s olla for I.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-olen')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","KYSYMYSLIITE":"true"}'::jsonb,
    'oletko', 'ootko',
    'present tense, 2nd person singular, with the question ending -ko/-kö',
    'pgtap why: a yes or no question.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-oletko')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oletko', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana"}'::jsonb,
    'sinä', 'sä',
    'nominative singular',
    'pgtap why: Sinä means you.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-sina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinä', 'pgtap-sinä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana"}'::jsonb,
    'täällä', 'täällä',
    'adverb',
    'pgtap why: Täällä means here.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-taalla')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täällä', 'pgtap-täällä';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mä oon Aino.',
    'Minä olen Aino.', 'pgtap fixture: I''m Aino.',
    'pgtap-publish-fixture/1-puhe-b2d0c03f532e.mp3', 'pgtap-publish-fixture/1-kirja-7c7bf7ff77e8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'Aino', null),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'Aino', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'No ootko sä täällä? <script>document.title=''script ran''</script> Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas.',
    'Oletko sinä täällä? <script>document.title=''script ran''</script> Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas.', 'pgtap fixture: Are you here? (it''s a test of <b>escaping</b> & quotes)',
    'pgtap-publish-fixture/2-puhe-a31de0a2794e.mp3', 'pgtap-publish-fixture/2-kirja-2c272b74f077.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Oletko', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'No', null),
    (v_line_id, 'puhe', 2, 'ootko', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-2'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue'
  where id = v_dialogue_id;

  -- 4. The unit, unless an earlier dialogue already published it.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
$migration$, '[content 15] the publish migration the pipeline writes runs on the real schema');

select lives_ok($migration$
-- Publishes the dialogue pgtap-publish-fixture (unit pgtap-publish-unit). Made by
-- scripts/generate/pipeline.py publish from scripts/generate/fixtures/publish/draft.json. Do not edit by hand:
-- change the draft, get the changed items reviewed again and publish again.
-- Job 7-content-pipeline, "Done when" 15. Order (docs/data-model.md): forms, then
-- the lines with their words, then the dialogue, then the unit. Running it a second
-- time does nothing, because the dialogue is then already approved.
do $publish$
declare
  v_unit_id bigint;
  v_dialogue_id bigint;
  v_line_id bigint;
  v_status public.content_status;
begin
  if exists (select 1 from public.dialogues
    where slug = 'pgtap-publish-fixture' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'pgtap-publish-fixture';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en)
  values ('pgtap-publish-unit', 900101, 'pgtap publish unit', 'pgtap can do')
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'pgtap-publish-unit' and position = 900101
    and title_en = 'pgtap publish unit' and can_do_en = 'pgtap can do';
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'pgtap-publish-unit';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'pgtap-publish-fixture', 1,
    'pgtap publish fixture')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'pgtap-publish-fixture' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'pgtap publish fixture';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'pgtap-publish-fixture';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana"}'::jsonb,
    'minä', 'mä',
    'nominative singular',
    'pgtap why: Minä means I.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-mina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minä', 'pgtap-minä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana"}'::jsonb,
    'olen', 'oon',
    'present tense, 1st person singular',
    'pgtap why: it''s olla for I.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-olen')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","KYSYMYSLIITE":"true"}'::jsonb,
    'oletko', 'ootko',
    'present tense, 2nd person singular, with the question ending -ko/-kö',
    'pgtap why: a yes or no question.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-oletko')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oletko', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana"}'::jsonb,
    'sinä', 'sä',
    'nominative singular',
    'pgtap why: Sinä means you.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-sina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinä', 'pgtap-sinä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, status, approved_at, approval_ref)
  values ('pgtap-täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana"}'::jsonb,
    'täällä', 'täällä',
    'adverb',
    'pgtap why: Täällä means here.', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-taalla')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täällä', 'pgtap-täällä';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mä oon Aino.',
    'Minä olen Aino.', 'pgtap fixture: I''m Aino.',
    'pgtap-publish-fixture/1-puhe-b2d0c03f532e.mp3', 'pgtap-publish-fixture/1-kirja-7c7bf7ff77e8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'Aino', null),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'Aino', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'No ootko sä täällä? <script>document.title=''script ran''</script> Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas.',
    'Oletko sinä täällä? <script>document.title=''script ran''</script> Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas.', 'pgtap fixture: Are you here? (it''s a test of <b>escaping</b> & quotes)',
    'pgtap-publish-fixture/2-puhe-a31de0a2794e.mp3', 'pgtap-publish-fixture/2-kirja-2c272b74f077.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Oletko', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'No', null),
    (v_line_id, 'puhe', 2, 'ootko', (select id from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-2'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue'
  where id = v_dialogue_id;

  -- 4. The unit, unless an earlier dialogue already published it.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
$migration$, '[content 16] running the publish migration a second time does nothing and does not fail');

select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture'), 2::bigint,
  '[content 16] after the second run the dialogue still has 2 lines');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id where d.slug = 'pgtap-publish-fixture'), 13::bigint,
  '[content 16] after the second run the dialogue still has 13 words');
select is((select count(*) from public.forms where lemma like 'pgtap-%'), 5::bigint,
  '[content 16] after the second run there are still 5 fixture forms');

-- [content 16] A learner reads the published content -----------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000c0de7", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.units where slug = 'pgtap-publish-unit'), 1::bigint,
  '[content 16] a learner reads the published unit');
select is((select count(*) from public.dialogues where slug = 'pgtap-publish-fixture'), 1::bigint,
  '[content 16] a learner reads the published dialogue');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture' and coalesce(btrim(l.text_puhe), '') <> '' and coalesce(btrim(l.text_kirja), '') <> ''
    and coalesce(btrim(l.gloss_en), '') <> ''
    and l.audio_puhe_key ~ ('^' || d.slug || '/' || l.position || '-puhe-[0-9a-f]{12}[.]mp3$')
    and l.audio_kirja_key ~ ('^' || d.slug || '/' || l.position || '-kirja-[0-9a-f]{12}[.]mp3$')
    and l.approval_ref like ('content/reviews/' || d.slug || '/%.json#line-' || l.position)), 2::bigint,
  '[content 16] a learner reads every line with both texts, the meaning, both audio keys '
  'and an approval_ref pointing at the review file');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id where d.slug = 'pgtap-publish-fixture'), 13::bigint,
  '[content 16] a learner reads every word of every line');
select is((select count(*) from public.tokens t join public.forms f on f.id = t.form_id
  join public.dialogue_lines l on l.id = t.line_id join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture' and f.status = 'approved' and btrim(f.form_name_en) <> '' and btrim(f.why_en) <> ''
    and f.approval_ref like 'content/reviews/pgtap-publish-fixture/%.json#%'), 10::bigint,
  '[content 16] every word that links to a form links to an approved form '
  'with a name, a why and a review reference');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where not (coalesce(btrim(l.text_puhe), '') <> '' and coalesce(btrim(l.text_kirja), '') <> ''
    and coalesce(btrim(l.gloss_en), '') <> ''
    and l.audio_puhe_key ~ ('^' || d.slug || '/' || l.position || '-puhe-[0-9a-f]{12}[.]mp3$')
    and l.audio_kirja_key ~ ('^' || d.slug || '/' || l.position || '-kirja-[0-9a-f]{12}[.]mp3$')
    and l.approval_ref like ('content/reviews/' || d.slug || '/%.json#line-' || l.position))), 0::bigint,
  '[content 16] every line a learner can read, in every published dialogue, '
  'is complete and points at a review file');
select is((select count(*) from public.tokens t where t.form_id is not null and not exists (
    select 1 from public.forms f
    where f.id = t.form_id and btrim(f.form_name_en) <> '' and btrim(f.why_en) <> '')),
  0::bigint,
  '[content 16] every word a learner can read links only to forms the learner can read, '
  'with a name and a why');
select ok((select approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue' from public.dialogues where slug = 'pgtap-publish-fixture'),
  '[content 15] the dialogue approval_ref is the review file path plus the item id');
reset role;

-- [content 16] Draft content stays hidden ----------------------------------------

insert into public.dialogues (unit_id, slug, position, title_en)
select id, 'pgtap-publish-draft-dialogue', 2, 'pgtap draft dialogue' from public.units where slug = 'pgtap-publish-unit';
insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en)
select id, 1, 'pgtap', 'pgtap', 'pgtap', 'pgtap draft line' from public.dialogues
where slug = 'pgtap-publish-draft-dialogue';
select throws_ok(
  $$insert into public.dialogue_lines (dialogue_id, position, speaker)
    select id, 99, 'pgtap' from public.dialogues where slug = 'pgtap-publish-fixture'$$,
  'P0001', null, '[content 16] a draft line cannot be added to the published dialogue'
);
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000c0de7", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.dialogue_lines where gloss_en = 'pgtap draft line'), 0::bigint,
  '[content 16] a draft line added inside the test cannot be read');
select is((select count(*) from public.dialogues where slug = 'pgtap-publish-draft-dialogue'), 0::bigint,
  '[content 16] its draft dialogue cannot be read either');
reset role;

-- [content 16] Re-approving a unit and a form ------------------------------------

update public.units set status = 'draft' where slug = 'pgtap-publish-unit';
select ok((select approved_at is null and approval_ref is null from public.units where slug = 'pgtap-publish-unit'),
  '[content 16] setting an approved unit back to draft clears its approval');
select throws_ok(
  $$update public.units set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#dialogue' where slug = 'pgtap-publish-unit'$$,
  'P0001', null, '[content 16] approving the unit again with its old review reference is refused'
);
select lives_ok(
  $$update public.units set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#dialogue' where slug = 'pgtap-publish-unit'$$,
  '[content 16] approving the unit again with a new review reference works'
);
update public.forms set status = 'draft' where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular';
select ok((select approved_at is null and approval_ref is null from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular'),
  '[content 16] setting an approved form back to draft clears its approval');
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000c0de7", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular'), 0::bigint,
  '[content 16] a learner cannot read a form set back to draft');
reset role;
select throws_ok(
  $$update public.forms set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-mina' where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular'$$,
  'P0001', null, '[content 16] approving the form again with its old review reference is refused'
);
select lives_ok(
  $$update public.forms set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#pgtap-form-mina' where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular'$$,
  '[content 16] approving the form again with a new review reference works'
);

select * from finish();

rollback;
