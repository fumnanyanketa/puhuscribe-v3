-- Publishes the dialogue next-year (unit my-plans). Made by
-- scripts/generate/pipeline.py publish from content/drafts/next-year. Do not edit by hand:
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
    where slug = 'next-year' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'next-year';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 34
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'my-plans' and position = 34 and stop_number = 34;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'my-plans';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'next-year', 2,
    'Next year')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'next-year' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Next year';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'next-year';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#next-year/form-a0c867e0dc77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mitä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mitä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä'),
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#next-year/form-ec7b2eab227a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinä', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinä', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'),
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aikoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"aikoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]aikoa[X]aio[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+aikoa(aikoa)"}'::jsonb,
      'aiot', 'aiot',
      'present tense, 2nd person singular', 'Aikoa means to plan. -t goes with sinä, and the k drops: aiot.', 'you plan', 'to plan to, to intend', 'approved', now(), 'content/approvals/part-6.json#next-year/form-c1b233b40923');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aiot', 'aikoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Aikoa means to plan. -t goes with sinä, and the k drops: aiot.', 'you plan', 'to plan to, to intend')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aiot', 'aikoa',
      (select form_name_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot'),
      (select why_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot'),
      (select meaning_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot'),
      (select lemma_meaning_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot'),
      'present tense, 2nd person singular', 'Aikoa means to plan. -t goes with sinä, and the k drops: aiot.', 'you plan', 'to plan to, to intend';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdä', 'tehä',
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#next-year/form-f64c6f94ba00');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tehdä', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tehdä', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensi', 'CLASS=seikkasana', '{"BASEFORM":"ensi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensi[X]ensi","STRUCTURE":"=pppp","WORDBASES":"+ensi(ensi)"}'::jsonb,
      'ensi', 'ens',
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next', 'approved', now(), 'content/approvals/part-6.json#next-year/form-00d6b814f19a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensi', 'ensi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensi', 'ensi',
      (select form_name_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select why_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select meaning_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select lemma_meaning_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vuosi', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"vuosi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vuosi[X]vuo[Ses][Ny]nna","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppp","WORDBASES":"+vuosi(vuosi)"}'::jsonb,
      'vuonna', 'vuonna',
      'essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year', 'approved', now(), 'content/approvals/part-6.json#next-year/form-a004c3b5e8e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vuonna', 'vuosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vuonna', 'vuosi',
      (select form_name_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select why_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select lemma_meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      'essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#next-year/form-728ddce13587');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minä', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minä', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä'),
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aikoa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"aikoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]aikoa[X]aio[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+aikoa(aikoa)"}'::jsonb,
      'aion', 'aion',
      'present tense, 1st person singular', 'Aikoa means to plan. -n goes with minä, and the k drops: aion.', 'I''m going to', 'to plan to, to intend', 'approved', now(), 'content/approvals/part-6.json#next-year/form-6ac8f93fe426');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aion', 'aikoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Aikoa means to plan. -n goes with minä, and the k drops: aion.', 'I''m going to', 'to plan to, to intend')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aion', 'aikoa',
      (select form_name_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion'),
      (select why_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion'),
      (select meaning_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion'),
      (select lemma_meaning_en from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion'),
      'present tense, 1st person singular', 'Aikoa means to plan. -n goes with minä, and the k drops: aion.', 'I''m going to', 'to plan to, to intend';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opiskella', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"opiskella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opiskella[X]opiskell[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppppp","WORDBASES":"+opiskella(opiskella)"}'::jsonb,
      'opiskella', 'opiskella',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to study', 'to study', 'approved', now(), 'content/approvals/part-6.json#next-year/form-ca9c04328374');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opiskella', 'opiskella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to study', 'to study')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opiskella', 'opiskella',
      (select form_name_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella'),
      (select why_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella'),
      (select meaning_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella'),
      (select lemma_meaning_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to study', 'to study';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lisä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lisä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lisä[X]lis[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lisä(lisä)"}'::jsonb,
      'lisää', 'lisää',
      'partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition', 'approved', now(), 'content/approvals/part-6.json#next-year/form-aa8e1d0f22c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lisää', 'lisä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lisää', 'lisä',
      (select form_name_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select why_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select lemma_meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      'partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#next-year/form-68ca7e058498');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomea', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomea', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#next-year/form-938eb8c80d8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ja', 'ja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ja', 'ja',
      (select form_name_en from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja'),
      (select why_en from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja'),
      (select meaning_en from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja'),
      (select lemma_meaning_en from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hake[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'hakea', 'hakee',
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-6.json#next-year/form-16b20f797da9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hakea', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hakea', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töitä', 'töitä',
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#next-year/form-a6fa8fd612dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töitä', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töitä', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koulu', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural', '{"BASEFORM":"koulu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Ion][Xp]koulu[X]koulu[Sela][Nm]ista","NUMBER":"plural","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppppp","WORDBASES":"+koulu(koulu)"}'::jsonb,
      'kouluista', 'kouluist',
      'elative plural', 'Adds -sta for ''from'', with -i- for more than one: kouluista. Speech drops the last vowel.', 'from schools', 'school', 'approved', now(), 'content/approvals/part-6.json#next-year/form-d3e6bebdbe2b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kouluista', 'koulu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative plural', 'Adds -sta for ''from'', with -i- for more than one: kouluista. Speech drops the last vowel.', 'from schools', 'school')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kouluista', 'koulu',
      (select form_name_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist'),
      (select why_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist'),
      (select meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist'),
      (select lemma_meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist'),
      'elative plural', 'Adds -sta for ''from'', with -i- for more than one: kouluista. Speech drops the last vowel.', 'from schools', 'school';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaja', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"opettaja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Ln][Xj]ja[X][Str][Ny]jaksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppppppp","WORDBASES":"+opetta(opettaa)+ja(+ja)"}'::jsonb,
      'opettajaksi', 'opettajaks',
      'translative singular', 'Adds -ksi for becoming something: opettaja becomes opettajaksi. Speech drops the last i.', 'as a teacher', 'teacher', 'approved', now(), 'content/approvals/part-6.json#next-year/form-032dad535377');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettajaksi', 'opettaja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi for becoming something: opettaja becomes opettajaksi. Speech drops the last i.', 'as a teacher', 'teacher')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettajaksi', 'opettaja',
      (select form_name_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks'),
      (select why_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks'),
      (select meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks'),
      'translative singular', 'Adds -ksi for becoming something: opettaja becomes opettajaksi. Speech drops the last i.', 'as a teacher', 'teacher';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#next-year/form-fbf4cf6cbcf9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kyllä', 'kyllä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kyllä', 'kyllä',
      (select form_name_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo'),
      (select why_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo'),
      (select meaning_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo'),
      (select lemma_meaning_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo'),
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-6.json#next-year/form-f177cddd7c31');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mutta', 'mutta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mutta', 'mutta',
      (select form_name_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select why_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select meaning_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select lemma_meaning_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensin', 'CLASS=seikkasana', '{"BASEFORM":"ensin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensin[X]ensin","STRUCTURE":"=ppppp","WORDBASES":"+ensin(ensin)"}'::jsonb,
      'ensin', 'ensin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first', 'approved', now(), 'content/approvals/part-6.json#next-year/form-021cabf1d941');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensin', 'ensin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensin', 'ensin',
      (select form_name_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select why_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select lemma_meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-6.json#next-year/form-ae1caa07874f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minun', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minun', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun'),
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pitä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitää', 'pitää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-6.json#next-year/form-7aba8e0c1b63');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitää', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitää', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"osata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]osata[X]osat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+osata(osata)"}'::jsonb,
      'osata', 'osata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to know how to, can', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#next-year/form-7b376af9f2c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osata', 'osata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to know how to, can', 'to know how to, can')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osata', 'osata',
      (select form_name_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata'),
      (select why_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata'),
      (select meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata'),
      (select lemma_meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to know how to, can', 'to know how to, can';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Ll][Xp]hyvä[X]pare[Sin][Nm][Cc]mmin","NUMBER":"plural","SIJAMUOTO":"keinonto","STRUCTURE":"=pppppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'paremmin', 'paremmin',
      'comparative, instructive plural', 'Hyvin means well. paremmin means ''better'', a form you learn as a whole.', 'better', 'good', 'approved', now(), 'content/approvals/part-6.json#next-year/form-f5e3545dc50d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paremmin', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, instructive plural', 'Hyvin means well. paremmin means ''better'', a form you learn as a whole.', 'better', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paremmin', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin'),
      'comparative, instructive plural', 'Hyvin means well. paremmin means ''better'', a form you learn as a whole.', 'better', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pystyä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pystyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Irm][Xp]pystyä[X]pysty[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"MA-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+pystyä(pystyä)"}'::jsonb,
      'pystyt', 'pystyt',
      'present tense, 2nd person singular', 'Pystyä drops the last ä and takes -t for ''you'': pystyt.', 'you can', 'to be able to', 'approved', now(), 'content/approvals/part-6.json#next-year/form-5ead2244a7f2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pystyt', 'pystyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Pystyä drops the last ä and takes -t for ''you'': pystyt.', 'you can', 'to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pystyt', 'pystyä',
      (select form_name_en from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt'),
      (select why_en from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt'),
      (select meaning_en from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt'),
      (select lemma_meaning_en from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt'),
      'present tense, 2nd person singular', 'Pystyä drops the last ä and takes -t for ''you'': pystyt.', 'you can', 'to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sill][Ny]iihen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+se(se)"}'::jsonb,
      'siihen', 'siihen',
      'illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that', 'approved', now(), 'content/approvals/part-6.json#next-year/form-1e38a8ecb7e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siihen', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siihen', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      'illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-6.json#next-year/form-99966cae578b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'entä', 'entä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'entä', 'entä',
      (select form_name_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select why_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select lemma_meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kesä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesällä', 'kesällä',
      'adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer', 'approved', now(), 'content/approvals/part-6.json#next-year/form-3edddf050b70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesällä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesällä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      'adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kesä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesällä', 'kesäl',
      'adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer', 'approved', now(), 'content/approvals/part-6.json#next-year/form-9b45c353e900');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesällä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesällä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      'adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-6.json#next-year/form-9f0f9f1fdd21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'me', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Me means we. People say it the same way.', 'we', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'me', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lentää', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"lentää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lentää[X]lennä[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+lentää(lentää)"}'::jsonb,
      'lennämme', 'lennetään',
      'present tense, 1st person plural', 'Speech uses lennetään with me, ''we''. Books write lennämme.', 'we''re flying', 'to fly', 'approved', now(), 'content/approvals/part-6.json#next-year/form-b6f4628b89bc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lennämme', 'lentää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Speech uses lennetään with me, ''we''. Books write lennämme.', 'we''re flying', 'to fly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lennämme', 'lentää',
      (select form_name_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään'),
      (select why_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään'),
      (select meaning_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään'),
      (select lemma_meaning_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään'),
      'present tense, 1st person plural', 'Speech uses lennetään with me, ''we''. Books write lennämme.', 'we''re flying', 'to fly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauan', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"kauan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauan[X]kauan[Fko][Ef]ko","KYSYMYSLIITE":"true","STRUCTURE":"=ppppppp","WORDBASES":"+kauan(kauan)"}'::jsonb,
      'kauanko', 'kauanks',
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)', 'approved', now(), 'content/approvals/part-6.json#next-year/form-15e58dd7ae2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauanko', 'kauan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauanko', 'kauan',
      (select form_name_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select why_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select lemma_meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-6.json#next-year/form-2aeedafa15c7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'te', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'te', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Nm][Ef]lette","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olette', 'ootte',
      'present tense, 2nd person plural', 'Olla means to be. -tte goes with te. Speech says ootte, like oon and oot.', 'you (all) are', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#next-year/form-067665b02d98');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olette', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural', 'Olla means to be. -tte goes with te. Speech says ootte, like oon and oot.', 'you (all) are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olette', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte'),
      'present tense, 2nd person plural', 'Olla means to be. -tte goes with te. Speech says ootte, like oon and oot.', 'you (all) are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-6.json#next-year/form-0fd3b38079dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siellä', 'siellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siellä', 'siellä',
      (select form_name_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select why_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select lemma_meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolme', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolme","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolme', 'kolme',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three', 'approved', now(), 'content/approvals/part-6.json#next-year/form-9242c81b9d91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolme', 'kolme';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolme', 'kolme',
      (select form_name_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select why_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select lemma_meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viikko[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikkoa', 'viikkoo',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week', 'approved', now(), 'content/approvals/part-6.json#next-year/form-0cc3e6dfc99a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikkoa', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikkoa', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-6.json#next-year/form-e12332115711');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'en', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'en', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('malttaa', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"malttaa","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'malta', 'malta',
      'present tense, negative form', 'After en the verb drops its ending: malttaa becomes malta. The tt becomes t.', 'wait (I can''t wait)', 'to have the patience', 'approved', now(), 'content/approvals/part-6.json#next-year/form-eb8d524c53a6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'malta', 'malttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: malttaa becomes malta. The tt becomes t.', 'wait (I can''t wait)', 'to have the patience')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'malta', 'malttaa',
      (select form_name_en from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta'),
      (select why_en from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta'),
      (select meaning_en from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta'),
      (select lemma_meaning_en from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta'),
      'present tense, negative form', 'After en the verb drops its ending: malttaa becomes malta. The tt becomes t.', 'wait (I can''t wait)', 'to have the patience';
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('odottaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"odottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]odottaa[X]odotta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+odottaa(odottaa)"}'::jsonb,
      'odottaa', 'odottaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to wait', 'to wait', 'approved', now(), 'content/approvals/part-6.json#next-year/form-db14c0bbf22f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'odottaa', 'odottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to wait', 'to wait')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'odottaa', 'odottaa',
      (select form_name_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa'),
      (select why_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa'),
      (select meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa'),
      (select lemma_meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to wait', 'to wait';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Mitä sä aiot tehä ens vuonna?',
    'Mitä sinä aiot tehdä ensi vuonna?', 'What are you planning to do next year?',
    'next-year/1-puhe-a723a20710bf.mp3', 'next-year/1-kirja-47db7e63cfb7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'aiot', (select id from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot')),
    (v_line_id, 'kirja', 4, 'tehdä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'kirja', 5, 'ensi', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'kirja', 6, 'vuonna', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'aiot', (select id from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aiot' and surface_puhe = 'aiot')),
    (v_line_id, 'puhe', 4, 'tehä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'puhe', 5, 'ens', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'puhe', 6, 'vuonna', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä aion opiskella lisää suomee ja hakee töitä kouluist.',
    'Minä aion opiskella lisää suomea ja hakea töitä kouluista.', 'I''m going to study more Finnish and apply for jobs at schools.',
    'next-year/2-puhe-f1ccf0d09072.mp3', 'next-year/2-kirja-d533d150b8ac.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'aion', (select id from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion')),
    (v_line_id, 'kirja', 3, 'opiskella', (select id from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella')),
    (v_line_id, 'kirja', 4, 'lisää', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'kirja', 5, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'hakea', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee')),
    (v_line_id, 'kirja', 8, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'kirja', 9, 'kouluista', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'aion', (select id from public.forms where lemma = 'aikoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'aion' and surface_puhe = 'aion')),
    (v_line_id, 'puhe', 3, 'opiskella', (select id from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opiskella' and surface_puhe = 'opiskella')),
    (v_line_id, 'puhe', 4, 'lisää', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'puhe', 5, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'hakee', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee')),
    (v_line_id, 'puhe', 8, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'puhe', 9, 'kouluist', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'kouluista' and surface_puhe = 'kouluist'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Opettajaks?',
    'Opettajaksi?', 'As a teacher?',
    'next-year/3-puhe-f20163b16448.mp3', 'next-year/3-kirja-6316470719d9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Opettajaksi', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks')),
    (v_line_id, 'puhe', 1, 'Opettajaks', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'opettajaksi' and surface_puhe = 'opettajaks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo, mut ensin mun pitää osata suomee paremmin.',
    'Kyllä, mutta ensin minun pitää osata suomea paremmin.', 'Yes, but first I need to know Finnish better.',
    'next-year/4-puhe-f0870e99a136.mp3', 'next-year/4-kirja-784ee4f1cab5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'ensin', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'kirja', 6, 'osata', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata')),
    (v_line_id, 'kirja', 7, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 8, 'paremmin', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'ensin', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'puhe', 6, 'osata', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'osata' and surface_puhe = 'osata')),
    (v_line_id, 'puhe', 7, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 8, 'paremmin', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'paremmin' and surface_puhe = 'paremmin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Sä pystyt siihen. Entä kesällä?',
    'Sinä pystyt siihen. Entä kesällä?', 'You can do it. And in the summer?',
    'next-year/5-puhe-60ff63ce5a84.mp3', 'next-year/5-kirja-048947ec2507.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 2, 'pystyt', (select id from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt')),
    (v_line_id, 'kirja', 3, 'siihen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen')),
    (v_line_id, 'kirja', 4, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 5, 'kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä')),
    (v_line_id, 'puhe', 1, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 2, 'pystyt', (select id from public.forms where lemma = 'pystyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pystyt' and surface_puhe = 'pystyt')),
    (v_line_id, 'puhe', 3, 'siihen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen')),
    (v_line_id, 'puhe', 4, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 5, 'kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kesäl me lennetään Brasiliaan.',
    'Kesällä me lennämme Brasiliaan.', 'In the summer we''re flying to Brazil.',
    'next-year/6-puhe-33e6d389340e.mp3', 'next-year/6-kirja-ca67c153f161.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'kirja', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 3, 'lennämme', (select id from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään')),
    (v_line_id, 'kirja', 4, 'Brasiliaan', null),
    (v_line_id, 'puhe', 1, 'Kesäl', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'puhe', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 3, 'lennetään', (select id from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lennämme' and surface_puhe = 'lennetään')),
    (v_line_id, 'puhe', 4, 'Brasiliaan', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Kauanks te ootte siel?',
    'Kauanko te olette siellä?', 'How long will you be there?',
    'next-year/7-puhe-55e35aad0662.mp3', 'next-year/7-kirja-0408fe9f1229.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kauanko', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'kirja', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 3, 'olette', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte')),
    (v_line_id, 'kirja', 4, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 1, 'Kauanks', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'puhe', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 3, 'ootte', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olette' and surface_puhe = 'ootte')),
    (v_line_id, 'puhe', 4, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kolme viikkoo. Mä en malta odottaa!',
    'Kolme viikkoa. Minä en malta odottaa!', 'Three weeks. I can''t wait!',
    'next-year/8-puhe-188414cc9b90.mp3', 'next-year/8-kirja-4be1eb7c4991.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'kirja', 2, 'viikkoa', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 5, 'malta', (select id from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta')),
    (v_line_id, 'kirja', 6, 'odottaa', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa')),
    (v_line_id, 'puhe', 1, 'Kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'puhe', 2, 'viikkoo', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 5, 'malta', (select id from public.forms where lemma = 'malttaa' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'malta' and surface_puhe = 'malta')),
    (v_line_id, 'puhe', 6, 'odottaa', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'odottaa' and surface_puhe = 'odottaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#next-year/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
