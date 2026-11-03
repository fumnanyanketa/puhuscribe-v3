-- Publishes the dialogue changing-the-plan (unit making-a-plan). Made by
-- scripts/generate/pipeline.py publish from content/drafts/changing-the-plan. Do not edit by hand:
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
    where slug = 'changing-the-plan' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'changing-the-plan';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 8
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'making-a-plan' and position = 8 and stop_number = 8;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'making-a-plan';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'changing-the-plan', 2,
    'Changing the plan')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'changing-the-plan' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Changing the plan';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'changing-the-plan';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-124d5d19fe78');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hei', 'hei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hei', 'hei',
      (select form_name_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select why_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select meaning_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select lemma_meaning_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan', '{"BASEFORM":"päästä","CLASS":"teonsana","FOCUS":"kaan","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'pääsekään', 'pääsekään',
      'present tense, negative form, with -kaan/-kään', 'After en the verb drops its ending: päästä becomes pääse. -kään adds ''after all''.', 'can''t make it after all', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-6831d6ff4830');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pääsekään', 'päästä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form, with -kaan/-kään', 'After en the verb drops its ending: päästä becomes pääse. -kään adds ''after all''.', 'can''t make it after all', 'to get (somewhere), to get in')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pääsekään', 'päästä',
      (select form_name_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään'),
      (select why_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään'),
      (select meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään'),
      (select lemma_meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään'),
      'present tense, negative form, with -kaan/-kään', 'After en the verb drops its ending: päästä becomes pääse. -kään adds ''after all''.', 'can''t make it after all', 'to get (somewhere), to get in';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-3978a16fa6b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lauantaina', 'lauantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lauantaina', 'lauantai',
      (select form_name_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select why_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select lemma_meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voi', 'CLASS=huudahdussana', '{"BASEFORM":"voi","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]voi[X]voi","STRUCTURE":"=ppp","WORDBASES":"+voi(voi)"}'::jsonb,
      'voi', 'voi',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-1477dccb7e44');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voi', 'voi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voi', 'voi',
      (select form_name_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select why_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select lemma_meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('harmi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"harmi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]harmi[X]harm[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+harmi(harmi)"}'::jsonb,
      'harmi', 'harmi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'shame, pity', 'shame, pity', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-3e8f9b85a6db');
  end if;
  if not exists (select 1 from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'harmi', 'harmi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'shame, pity', 'shame, pity')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'harmi', 'harmi',
      (select form_name_en from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi'),
      (select why_en from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi'),
      (select meaning_en from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi'),
      (select lemma_meaning_en from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'shame, pity', 'shame, pity';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tapahtua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tapahtua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tapahtua[X]tapahtu[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppppp","TENSE":"past_imperfective","WORDBASES":"+tapahtua(tapahtua)"}'::jsonb,
      'tapahtui', 'tapahtu',
      'past tense, 3rd person singular', 'Tapahtua in the past tense: tapahtui. Speech drops the final i: tapahtu.', 'happened', 'to happen', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-54725d9e549d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tapahtui', 'tapahtua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Tapahtua in the past tense: tapahtui. Speech drops the final i: tapahtu.', 'happened', 'to happen')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tapahtui', 'tapahtua',
      (select form_name_en from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu'),
      (select why_en from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu'),
      (select meaning_en from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu'),
      (select lemma_meaning_en from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu'),
      'past tense, 3rd person singular', 'Tapahtua in the past tense: tapahtui. Speech drops the final i: tapahtu.', 'happened', 'to happen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"lapsi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lapsi[X]la[Sn][Ny]pse[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+lapsi(lapsi)"}'::jsonb,
      'lapseni', 'lapsi',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': lapseni. Speech says mun and no ending: mun lapsi.', 'my child', 'child', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-3c3c0531b9b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lapseni', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': lapseni. Speech says mun and no ending: mun lapsi.', 'my child', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lapseni', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': lapseni. Speech says mun and no ending: mun lapsi.', 'my child', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-24c73cc721d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'on', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'on', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'),
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kipeä', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kipeä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kipeä[X]kipe[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kipeä(kipeä)"}'::jsonb,
      'kipeä', 'kipee',
      'nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-91025202689d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kipeä', 'kipeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kipeä', 'kipeä',
      (select form_name_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select why_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select meaning_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select lemma_meaning_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      'nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-4752d8dd4e2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ei', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ei', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei'),
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('toivottava', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active', '{"BASEFORM":"toivottava","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]toivottaa[X]toivotta[Ll][Rv]v[Xj]a[X]a[Ssti]sti","PARTICIPLE":"present_active","SIJAMUOTO":"kerrontosti","STRUCTURE":"=ppppppppppppp","WORDBASES":"+toivotta(toivottaa)+v+a(+a)"}'::jsonb,
      'toivottavasti', 'toivottavasti',
      'present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-c0b75ccd3d5f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toivottavasti', 'toivottava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toivottavasti', 'toivottava',
      (select form_name_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select why_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select meaning_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select lemma_meaning_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      'present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-d5b687de866a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hän', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hän', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('parata', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"parata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]parata[X]para[Tt][Ap][P3][Ny][Ef]nee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+parata(parata)"}'::jsonb,
      'paranee', 'paranee',
      'present tense, 3rd person singular', 'Parata, to get better, in the form for he, she or it: paranee.', 'gets better', 'to get better, to recover', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-82f85ca27ac0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paranee', 'parata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Parata, to get better, in the form for he, she or it: paranee.', 'gets better', 'to get better, to recover')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paranee', 'parata',
      (select form_name_en from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee'),
      (select why_en from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee'),
      (select meaning_en from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee'),
      (select lemma_meaning_en from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee'),
      'present tense, 3rd person singular', 'Parata, to get better, in the form for he, she or it: paranee.', 'gets better', 'to get better, to recover';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pian', 'CLASS=seikkasana', '{"BASEFORM":"pian","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]pian[X]pian","STRUCTURE":"=pppp","WORDBASES":"+pian(pian)"}'::jsonb,
      'pian', 'pian',
      'adverb', 'This is the dictionary form. People say it the same way.', 'soon', 'soon', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-93f81e1e5356');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pian', 'pian';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'soon', 'soon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pian', 'pian',
      (select form_name_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian'),
      (select why_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian'),
      (select meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian'),
      (select lemma_meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'soon', 'soon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-35b130e20e20');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopiiko', 'sopiiks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-f0aadca6a510');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sopiiko', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sopiiko', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensi', 'CLASS=seikkasana', '{"BASEFORM":"ensi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensi[X]ensi","STRUCTURE":"=pppp","WORDBASES":"+ensi(ensi)"}'::jsonb,
      'ensi', 'ens',
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-00d6b814f19a');
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
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viikko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikko', 'viikko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'week', 'week', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-ca914f188bef');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikko', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'week', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikko', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'week', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiistai', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tiistai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tiistai[X]tiistai[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+tiistai(tiistai)"}'::jsonb,
      'tiistai', 'tiistai',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Tuesday', 'Tuesday', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-3ec1d01b42da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiistai', 'tiistai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Tuesday', 'Tuesday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiistai', 'tiistai',
      (select form_name_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai'),
      (select why_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai'),
      (select meaning_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai'),
      (select lemma_meaning_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Tuesday', 'Tuesday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tai', 'CLASS=sidesana', '{"BASEFORM":"tai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]tai[X]tai","STRUCTURE":"=ppp","WORDBASES":"+tai(tai)"}'::jsonb,
      'tai', 'tai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-e626f185f947');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tai', 'tai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tai', 'tai',
      (select form_name_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select why_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select meaning_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select lemma_meaning_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keskiviikko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"keskiviikko","CLASS":"nimisana","FSTOUTPUT":"[Lp]keski[De][Bh][Bc][Ln][Xp]viikko[X]viikko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+keski+viikko(viikko)"}'::jsonb,
      'keskiviikko', 'keskiviikko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-14e9de42295e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keskiviikko', 'keskiviikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keskiviikko', 'keskiviikko',
      (select form_name_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select why_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select lemma_meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käy', 'käy',
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-24f89699a032');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käy', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käy', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulle', 'mulle',
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-6ba9c8c14d0e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulle', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulle', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Ll][Xp]hyvä[X]par[Sn][Ny][Cs]as","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'paras', 'paras',
      'superlative, nominative singular', 'The superlative of hyvä, good: paras, best.', 'best', 'good', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-ec5ab0146a13');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paras', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, nominative singular', 'The superlative of hyvä, good: paras, best.', 'best', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paras', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras'),
      'superlative, nominative singular', 'The superlative of hyvä, good: paras, best.', 'best', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-1df5ffb944a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'selvä', 'selvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'selvä', 'selvä',
      (select form_name_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select why_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select lemma_meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keskiviikko', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"keskiviikko","CLASS":"nimisana","FSTOUTPUT":"[Lp]keski[De][Bh][Bc][Ln][Xp]viikko[X]viikko[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+keski+viikko(viikko)"}'::jsonb,
      'keskiviikkona', 'keskiviikkona',
      'essive singular', 'Keskiviikko with -na for ''on'' a day: keskiviikkona.', 'on Wednesday', 'Wednesday', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-c3b14f961abf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keskiviikkona', 'keskiviikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Keskiviikko with -na for ''on'' a day: keskiviikkona.', 'on Wednesday', 'Wednesday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keskiviikkona', 'keskiviikko',
      (select form_name_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona'),
      (select why_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona'),
      (select meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona'),
      (select lemma_meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona'),
      'essive singular', 'Keskiviikko with -na for ''on'' a day: keskiviikkona.', 'on Wednesday', 'Wednesday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-2.json#changing-the-plan/form-ad4c189b50dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitten', 'sitten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitten', 'sitten',
      (select form_name_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select why_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select lemma_meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi Aino! Mä en pääsekään lauantaina.',
    'Hei Aino! Minä en pääsekään lauantaina.', 'Hi Aino! I can''t make it on Saturday after all.',
    'changing-the-plan/1-puhe-a0742ef26a40.mp3', 'changing-the-plan/1-kirja-020e8441cd73.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Aino', null),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 5, 'pääsekään', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään')),
    (v_line_id, 'kirja', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Aino', null),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 5, 'pääsekään', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true;FOCUS=kaan' and surface_kirja = 'pääsekään' and surface_puhe = 'pääsekään')),
    (v_line_id, 'puhe', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Aino', 'Voi harmi! Mitä tapahtu?',
    'Voi harmi! Mitä tapahtui?', 'Oh, what a shame! What happened?',
    'changing-the-plan/2-puhe-0e812697fc77.mp3', 'changing-the-plan/2-kirja-88029efc3603.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'harmi', (select id from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi')),
    (v_line_id, 'kirja', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 4, 'tapahtui', (select id from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'harmi', (select id from public.forms where lemma = 'harmi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'harmi' and surface_puhe = 'harmi')),
    (v_line_id, 'puhe', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 4, 'tapahtu', (select id from public.forms where lemma = 'tapahtua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tapahtui' and surface_puhe = 'tapahtu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Mun lapsi on kipee.',
    'Minun lapseni on kipeä.', 'My child is ill.',
    'changing-the-plan/3-puhe-33432c8568d4.mp3', 'changing-the-plan/3-kirja-973a51f4a93b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'lapseni', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kipeä', (select id from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'lapsi', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsi')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kipee', (select id from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Aino', 'Voi ei. Toivottavasti se paranee pian.',
    'Voi ei. Toivottavasti hän paranee pian.', 'Oh no. I hope they get better soon.',
    'changing-the-plan/4-puhe-bac96e437ec9.mp3', 'changing-the-plan/4-kirja-ece85b008647.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'Toivottavasti', (select id from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti')),
    (v_line_id, 'kirja', 4, 'hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 5, 'paranee', (select id from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee')),
    (v_line_id, 'kirja', 6, 'pian', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'Toivottavasti', (select id from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 5, 'paranee', (select id from public.forms where lemma = 'parata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'paranee' and surface_puhe = 'paranee')),
    (v_line_id, 'puhe', 6, 'pian', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'pian'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Kiitti. Sopiiks ens viikko?',
    'Kiitos. Sopiiko ensi viikko?', 'Thanks. Does next week suit you?',
    'changing-the-plan/5-puhe-acf9837a25ac.mp3', 'changing-the-plan/5-kirja-552ee5e45066.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Sopiiko', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'kirja', 3, 'ensi', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'kirja', 4, 'viikko', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Sopiiks', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'puhe', 3, 'ens', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'puhe', 4, 'viikko', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikko' and surface_puhe = 'viikko'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Aino', 'Joo. Tiistai tai keskiviikko käy mulle.',
    'Kyllä. Tiistai tai keskiviikko käy minulle.', 'Yes. Tuesday or Wednesday works for me.',
    'changing-the-plan/6-puhe-5f039914b44b.mp3', 'changing-the-plan/6-kirja-7a26d4f50134.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Tiistai', (select id from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai')),
    (v_line_id, 'kirja', 3, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'kirja', 4, 'keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'kirja', 5, 'käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'kirja', 6, 'minulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Tiistai', (select id from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tiistai' and surface_puhe = 'tiistai')),
    (v_line_id, 'puhe', 3, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'puhe', 4, 'keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'puhe', 5, 'käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'puhe', 6, 'mulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Keskiviikko on paras.',
    'Keskiviikko on paras.', 'Wednesday is best.',
    'changing-the-plan/7-puhe-bf71efeb5540.mp3', 'changing-the-plan/7-kirja-3eac58255d79.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'paras', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras')),
    (v_line_id, 'puhe', 1, 'Keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'paras', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Aino', 'Okei, keskiviikkona sit!',
    'Selvä, keskiviikkona sitten!', 'OK, Wednesday then!',
    'changing-the-plan/8-puhe-d00b6ad8bcce.mp3', 'changing-the-plan/8-kirja-486ad6da42c3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'keskiviikkona', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona')),
    (v_line_id, 'kirja', 3, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'keskiviikkona', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'keskiviikkona' and surface_puhe = 'keskiviikkona')),
    (v_line_id, 'puhe', 3, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#changing-the-plan/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
