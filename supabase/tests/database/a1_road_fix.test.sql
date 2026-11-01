-- A reviewer's fix replaces a live line (pgTAP). Made by scripts/generate/road_fix_pgtap.py from
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
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana"}'::jsonb,
    'minä', 'mä',
    'nominative singular',
    'pgtap why: Minä means I.', 'I',
    'I', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-mina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minä', 'pgtap-minä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana"}'::jsonb,
    'olen', 'oon',
    'present tense, 1st person singular',
    'pgtap why: it''s olla for I.', 'I am',
    'to be', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-olen')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","KYSYMYSLIITE":"true"}'::jsonb,
    'oletko', 'ootko',
    'present tense, 2nd person singular, with the question ending -ko/-kö',
    'pgtap why: a yes or no question.', 'are you',
    'to be', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-oletko')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oletko', 'pgtap-olla';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana"}'::jsonb,
    'sinä', 'sä',
    'nominative singular',
    'pgtap why: Sinä means you.', 'you',
    'you', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-sina')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;
  if not exists (select 1 from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinä', 'pgtap-sinä';
  end if;
  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana"}'::jsonb,
    'täällä', 'täällä',
    'adverb',
    'pgtap why: Täällä means here.', 'here',
    'here', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-1.json#pgtap-form-taalla')
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
$migration$, '[a1-road 24] the dialogue is published, with its first references');

select lives_ok($fix$
-- Fix round 2 of the dialogue pgtap-publish-fixture. Made by scripts/generate/pipeline.py
-- road-next-round from scripts/generate/fixtures/publish/draft.json. Do not edit by hand. Job 20-a1-road, "Done when" 24.
-- One transaction: the dialogue is a draft while its lines change, so a learner never reads a
-- half changed dialogue; the old approvals stay in private.approval_history, so they cannot be
-- used again. Running it a second time does nothing.
do $fix$
declare
  v_dialogue_id bigint;
  v_line_id bigint;
begin
  select id into v_dialogue_id from public.dialogues
  where slug = 'pgtap-publish-fixture' and status = 'approved';
  if v_dialogue_id is null then
    raise notice 'dialogue % is not published; nothing to fix', 'pgtap-publish-fixture';
    return;
  end if;
  if exists (select 1 from public.dialogue_lines l where l.dialogue_id = v_dialogue_id
    and l.approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#line-2') then
    raise notice 'fix round 2 of % is already applied; nothing to do', 'pgtap-publish-fixture';
    return;
  end if;

  -- 1. The dialogue is hidden from learners until every change is in.
  update public.dialogues set status = 'draft' where id = v_dialogue_id;

  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-uusi', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","KYSYMYSLIITE":"true"}'::jsonb,
    'oletko', 'ootko',
    'present tense, 2nd person singular, with the question ending -ko/-kö', 'pgtap why: the form a fix added.', 'new',
    'new', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-2.json#pgtap-form-uusi')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;

  -- Line 2.
  update public.dialogue_lines set status = 'draft' where dialogue_id = v_dialogue_id and position = 2;
  update public.dialogue_lines set text_puhe = 'pgtap fixed puhe',
    text_kirja = 'pgtap fixed kirja', gloss_en = 'pgtap fixed gloss',
    audio_puhe_key = 'pgtap-publish-fixture/2-puhe-61e56a1b90d1.mp3', audio_kirja_key = 'pgtap-publish-fixture/2-kirja-a8660b35847d.mp3'
  where dialogue_id = v_dialogue_id and position = 2
  returning id into v_line_id;
  delete from public.tokens where line_id = v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id) values
    (v_line_id, 'kirja', 1, 'Oletko', (select id from public.forms where lemma = 'pgtap-uusi' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'No', null),
    (v_line_id, 'puhe', 2, 'ootko', (select id from public.forms where lemma = 'pgtap-uusi' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));

  -- 2. Approve the changed lines with the reviewer's new references, then the dialogue.
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#line-2'
  where dialogue_id = v_dialogue_id and position = 2;
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#dialogue'
  where id = v_dialogue_id;
end
$fix$;
$fix$, '[a1-road 24] the fix migration runs');

select lives_ok($fix$
-- Fix round 2 of the dialogue pgtap-publish-fixture. Made by scripts/generate/pipeline.py
-- road-next-round from scripts/generate/fixtures/publish/draft.json. Do not edit by hand. Job 20-a1-road, "Done when" 24.
-- One transaction: the dialogue is a draft while its lines change, so a learner never reads a
-- half changed dialogue; the old approvals stay in private.approval_history, so they cannot be
-- used again. Running it a second time does nothing.
do $fix$
declare
  v_dialogue_id bigint;
  v_line_id bigint;
begin
  select id into v_dialogue_id from public.dialogues
  where slug = 'pgtap-publish-fixture' and status = 'approved';
  if v_dialogue_id is null then
    raise notice 'dialogue % is not published; nothing to fix', 'pgtap-publish-fixture';
    return;
  end if;
  if exists (select 1 from public.dialogue_lines l where l.dialogue_id = v_dialogue_id
    and l.approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#line-2') then
    raise notice 'fix round 2 of % is already applied; nothing to do', 'pgtap-publish-fixture';
    return;
  end if;

  -- 1. The dialogue is hidden from learners until every change is in.
  update public.dialogues set status = 'draft' where id = v_dialogue_id;

  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
  values ('pgtap-uusi', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","KYSYMYSLIITE":"true"}'::jsonb,
    'oletko', 'ootko',
    'present tense, 2nd person singular, with the question ending -ko/-kö', 'pgtap why: the form a fix added.', 'new',
    'new', 'approved', now(), 'content/reviews/pgtap-publish-fixture/round-2.json#pgtap-form-uusi')
  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;

  -- Line 2.
  update public.dialogue_lines set status = 'draft' where dialogue_id = v_dialogue_id and position = 2;
  update public.dialogue_lines set text_puhe = 'pgtap fixed puhe',
    text_kirja = 'pgtap fixed kirja', gloss_en = 'pgtap fixed gloss',
    audio_puhe_key = 'pgtap-publish-fixture/2-puhe-61e56a1b90d1.mp3', audio_kirja_key = 'pgtap-publish-fixture/2-kirja-a8660b35847d.mp3'
  where dialogue_id = v_dialogue_id and position = 2
  returning id into v_line_id;
  delete from public.tokens where line_id = v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id) values
    (v_line_id, 'kirja', 1, 'Oletko', (select id from public.forms where lemma = 'pgtap-uusi' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'No', null),
    (v_line_id, 'puhe', 2, 'ootko', (select id from public.forms where lemma = 'pgtap-uusi' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'ootko')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'pgtap-sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'pgtap-täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));

  -- 2. Approve the changed lines with the reviewer's new references, then the dialogue.
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#line-2'
  where dialogue_id = v_dialogue_id and position = 2;
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/reviews/pgtap-publish-fixture/round-2.json#dialogue'
  where id = v_dialogue_id;
end
$fix$;
$fix$, '[a1-road 24] running the fix migration a second time does nothing and does not fail');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select l.text_puhe from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture' and l.position = 2), 'pgtap fixed puhe',
  '[a1-road 24] a learner reads the fixed line');
select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture'), 2::bigint,
  '[a1-road 24] a learner reads every line of the dialogue again, never a half changed one');
select is((select count(*) from public.tokens t join public.dialogue_lines l on l.id = t.line_id
  join public.dialogues d on d.id = l.dialogue_id join public.forms f on f.id = t.form_id
  where d.slug = 'pgtap-publish-fixture' and l.position = 2 and f.lemma = 'pgtap-uusi'), 2::bigint,
  '[a1-road 24] the changed line''s words link to the new form in both registers');
reset role;

select is((select l.approval_ref from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture' and l.position = 2), 'content/reviews/pgtap-publish-fixture/round-2.json#line-2',
  '[a1-road 24] the changed line carries the reviewer''s new reference');

select is((select count(*) from private.approval_history h join public.dialogue_lines l
    on l.id = h.row_id and h.table_name = 'dialogue_lines'
  join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture' and l.position = 2 and h.approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-2'), 1::bigint,
  '[a1-road 24] the old reference is in private.approval_history');

select throws_like($$
  do $retry$
  begin
    update public.dialogues set status = 'draft' where slug = 'pgtap-publish-fixture';
    update public.dialogue_lines set status = 'draft'
      where dialogue_id = (select id from public.dialogues where slug = 'pgtap-publish-fixture') and position = 2;
    update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'content/reviews/pgtap-publish-fixture/round-1.json#line-2'
      where dialogue_id = (select id from public.dialogues where slug = 'pgtap-publish-fixture') and position = 2;
  end
  $retry$
$$, '%approval reference was already used%',
  '[a1-road 24] a line changed by a fix cannot be approved again with its old reference');

update public.dialogues set status = 'draft' where slug = 'pgtap-publish-fixture';
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select count(*) from public.dialogue_lines l join public.dialogues d on d.id = l.dialogue_id
  where d.slug = 'pgtap-publish-fixture'), 0::bigint,
  '[a1-road 24] while the dialogue is a draft a learner reads none of its lines');
reset role;

update public.dialogue_lines set status = 'draft'
  where dialogue_id = (select id from public.dialogues where slug = 'pgtap-publish-fixture') and position = 1;
select row_eq(
  $$select approved_at, approval_ref from public.dialogue_lines
    where dialogue_id = (select id from public.dialogues where slug = 'pgtap-publish-fixture') and position = 1$$,
  row(null::timestamptz, null::text),
  '[a1-road 24] setting a line back to draft still clears its approval');

select * from finish();

rollback;
