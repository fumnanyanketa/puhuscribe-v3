-- Publishes the dialogue this-weekend (unit my-plans). Made by
-- scripts/generate/pipeline.py publish from content/drafts/this-weekend. Do not edit by hand:
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
    where slug = 'this-weekend' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'this-weekend';
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
  values (v_unit_id, 'this-weekend', 1,
    'This weekend')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'this-weekend' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'This weekend';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'this-weekend';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-a0c867e0dc77');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teet', 'teet',
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-d8e27c6cf4bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teet', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teet', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikonloppu', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"viikonloppu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sg][Ny]n[Bh][Bc][Ln][Xp]loppu[X]loppu[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppp=ppppppp","WORDBASES":"+viikon(viikko)+loppu(loppu)"}'::jsonb,
      'viikonloppuna', 'viikonloppuna',
      'essive singular', 'Viikonloppu with -na for ''at, on'' a time: viikonloppuna.', 'at the weekend', 'weekend', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-59d6b443da13');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikonloppuna', 'viikonloppu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Viikonloppu with -na for ''at, on'' a time: viikonloppuna.', 'at the weekend', 'weekend')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikonloppuna', 'viikonloppu',
      (select form_name_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'),
      (select why_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'),
      (select meaning_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'),
      (select lemma_meaning_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'),
      'essive singular', 'Viikonloppu with -na for ''at, on'' a time: viikonloppuna.', 'at the weekend', 'weekend';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-3978a16fa6b0');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menen', 'meen',
      'present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-deeed6711e56');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menen', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menen', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      'present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirpputori', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"kirpputori","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kirppu[X]kirppu[Sn][Ny][Bh][Bc][Ln][Ica][Xp]tori[X]tori[Sall][Ny]lle","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppp=ppppppp","WORDBASES":"+kirppu(kirppu)+tori(tori)"}'::jsonb,
      'kirpputorille', 'kirpparille',
      'allative singular', 'Adds -lle for ''to'': kirpputori becomes kirpputorille. Speech says kirppari, giving kirpparille.', 'to a flea market', 'flea market', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-ac1d72cdfc93');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirpputorille', 'kirpputori';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''to'': kirpputori becomes kirpputorille. Speech says kirppari, giving kirpparille.', 'to a flea market', 'flea market')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirpputorille', 'kirpputori',
      (select form_name_en from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille'),
      (select why_en from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille'),
      (select meaning_en from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille'),
      (select lemma_meaning_en from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille'),
      'allative singular', 'Adds -lle for ''to'': kirpputori becomes kirpputorille. Speech says kirppari, giving kirpparille.', 'to a flea market', 'flea market';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-483066471a02');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiva', 'kiva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiva', 'kiva',
      (select form_name_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select why_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select lemma_meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('etsiä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"etsiä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]etsiä[X]etsi[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+etsiä(etsiä)"}'::jsonb,
      'etsit', 'etit',
      'present tense, 2nd person singular', 'Etsiä means to look for. -t goes with sinä. Speech drops the s: etit.', 'you are looking for', 'to look for, to search', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-ce245a86e18f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'etsit', 'etsiä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Etsiä means to look for. -t goes with sinä. Speech drops the s: etit.', 'you are looking for', 'to look for, to search')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'etsit', 'etsiä',
      (select form_name_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit'),
      (select why_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit'),
      (select meaning_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit'),
      (select lemma_meaning_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit'),
      'present tense, 2nd person singular', 'Etsiä means to look for. -t goes with sinä. Speech drops the s: etit.', 'you are looking for', 'to look for, to search';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pöytä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"pöytä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pöytä[X]pöyt[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+pöytä(pöytä)"}'::jsonb,
      'pöytää', 'pöytää',
      'partitive singular', 'Looking for something takes -ä: pöytä becomes pöytää.', 'a table', 'table', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-b31cc77b6479');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pöytää', 'pöytä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Looking for something takes -ä: pöytä becomes pöytää.', 'a table', 'table')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pöytää', 'pöytä',
      (select form_name_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää'),
      (select why_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää'),
      (select meaning_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää'),
      (select lemma_meaning_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää'),
      'partitive singular', 'Looking for something takes -ä: pöytä becomes pöytää.', 'a table', 'table';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuoli', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"tuoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tuoli[X]tuol[Sp][Nm]eja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+tuoli(tuoli)"}'::jsonb,
      'tuoleja', 'tuoleja',
      'partitive plural', 'Plural ''some'' takes -ja: tuoli becomes tuoleja, i turning into e.', 'chairs', 'chair', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-42064c68a479');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuoleja', 'tuoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ja: tuoli becomes tuoleja, i turning into e.', 'chairs', 'chair')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuoleja', 'tuoli',
      (select form_name_en from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja'),
      (select why_en from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja'),
      (select meaning_en from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja'),
      (select lemma_meaning_en from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja'),
      'partitive plural', 'Plural ''some'' takes -ja: tuoli becomes tuoleja, i turning into e.', 'chairs', 'chair';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsen', 'tarviin',
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-60958fda456e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsen', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsen', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sp][Nm]iitä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+ne(ne)"}'::jsonb,
      'niitä', 'niitä',
      'partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-bcee7be7d1e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niitä', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niitä', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      'partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sill][Ny]teen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uuteen', 'uuteen',
      'illative singular', 'Adds -en to match asuntoon: uusi becomes uuteen.', 'new', 'new', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-dab43ce618d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uuteen', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -en to match asuntoon: uusi becomes uuteen.', 'new', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uuteen', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen'),
      'illative singular', 'Adds -en to match asuntoon: uusi becomes uuteen.', 'new', 'new';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asunto', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"asunto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asunto[X]asuntoo[Sill][Ny]n","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+asunto(asunto)"}'::jsonb,
      'asuntoon', 'asuntoon',
      'illative singular', 'Adds -on for ''into'' or ''for'': asunto becomes asuntoon.', 'to the flat', 'flat, apartment', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-daed7c602585');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asuntoon', 'asunto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -on for ''into'' or ''for'': asunto becomes asuntoon.', 'to the flat', 'flat, apartment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asuntoon', 'asunto',
      (select form_name_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'),
      (select why_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'),
      (select meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'),
      (select lemma_meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'),
      'illative singular', 'Adds -on for ''into'' or ''for'': asunto becomes asuntoon.', 'to the flat', 'flat, apartment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'ai',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-2ab0015782b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ai', 'ai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ai', 'ai',
      (select form_name_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select why_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select lemma_meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('muuttaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"muuttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]muuttaa[X]muuta[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+muuttaa(muuttaa)"}'::jsonb,
      'muutat', 'muutat',
      'present tense, 2nd person singular', 'Muuttaa means to move house. -t goes with sinä: muutat.', 'you''re moving', 'to move (house), to change', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-3c8ccb3c8e39');
  end if;
  if not exists (select 1 from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'muutat', 'muuttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Muuttaa means to move house. -t goes with sinä: muutat.', 'you''re moving', 'to move (house), to change')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'muutat', 'muuttaa',
      (select form_name_en from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat'),
      (select why_en from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat'),
      (select meaning_en from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat'),
      (select lemma_meaning_en from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat'),
      'present tense, 2nd person singular', 'Muuttaa means to move house. -t goes with sinä: muutat.', 'you''re moving', 'to move (house), to change';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensi', 'CLASS=seikkasana', '{"BASEFORM":"ensi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensi[X]ensi","STRUCTURE":"=pppp","WORDBASES":"+ensi(ensi)"}'::jsonb,
      'ensi', 'ens',
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-00d6b814f19a');
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
  if not exists (select 1 from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuu', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuu[X]kuu[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+kuu(kuu)"}'::jsonb,
      'kuussa', 'kuus',
      'inessive singular', 'Adds -ssa for time: kuu becomes kuussa. Speech says ens kuus.', '(next) month', 'moon, month', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-6d2f6933e50a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuussa', 'kuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for time: kuu becomes kuussa. Speech says ens kuus.', '(next) month', 'moon, month')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuussa', 'kuu',
      (select form_name_en from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus'),
      (select why_en from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus'),
      (select meaning_en from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus'),
      (select lemma_meaning_en from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus'),
      'inessive singular', 'Adds -ssa for time: kuu becomes kuussa. Speech says ens kuus.', '(next) month', 'moon, month';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iso', 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"iso","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Lnl][De][Xp]iso[X]iso[Sill][Ny][Cc]mpaan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+iso(iso)"}'::jsonb,
      'isompaan', 'isompaan',
      'comparative, illative singular', 'Iso means big. -mpa- makes ''bigger'' and -an adds ''to'': isompaan.', 'bigger', 'big', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-55f1725a5e5a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'isompaan', 'iso';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, illative singular', 'Iso means big. -mpa- makes ''bigger'' and -an adds ''to'': isompaan.', 'bigger', 'big')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'isompaan', 'iso',
      (select form_name_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan'),
      (select why_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan'),
      (select meaning_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan'),
      (select lemma_meaning_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan'),
      'comparative, illative singular', 'Iso means big. -mpa- makes ''bigger'' and -an adds ''to'': isompaan.', 'bigger', 'big';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsetko', 'tarviik',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvita means to need. Books write tarvitsetko. Speech says tarviiksä.', 'do you need', 'to need', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-c4394c6350ab');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsetko', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvita means to need. Books write tarvitsetko. Speech says tarviiksä.', 'do you need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsetko', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvita means to need. Books write tarvitsetko. Speech says tarviiksä.', 'do you need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('apu', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"apu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]apu[X]apu[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+apu(apu)"}'::jsonb,
      'apua', 'apuu',
      'partitive singular', 'After tarvita ''to need'', the noun takes the partitive singular: apu becomes apua. Speech says apuu.', 'help', 'help', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-d6e476a78927');
  end if;
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'apua', 'apu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After tarvita ''to need'', the noun takes the partitive singular: apu becomes apua. Speech says apuu.', 'help', 'help')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'apua', 'apu',
      (select form_name_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu'),
      (select why_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu'),
      (select meaning_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu'),
      (select lemma_meaning_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu'),
      'partitive singular', 'After tarvita ''to need'', the noun takes the partitive singular: apu becomes apua. Speech says apuu.', 'help', 'help';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('muutto', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"muutto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]muutto[X]muuto[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+muutto(muutto)"}'::jsonb,
      'muutossa', 'muutos',
      'inessive singular', 'Adds -ssa for ''in'' or ''with'': muutto becomes muutossa, tt turning into t. Speech says muutos.', 'with the move', 'move (to a new home)', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-2c9129ac89e1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'muutossa', 'muutto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'' or ''with'': muutto becomes muutossa, tt turning into t. Speech says muutos.', 'with the move', 'move (to a new home)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'muutossa', 'muutto',
      (select form_name_en from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos'),
      (select why_en from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos'),
      (select meaning_en from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos'),
      (select lemma_meaning_en from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos'),
      'inessive singular', 'Adds -ssa for ''in'' or ''with'': muutto becomes muutossa, tt turning into t. Speech says muutos.', 'with the move', 'move (to a new home)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-eca33913649c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'se', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'se', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Te][Ap][P3][Ny][Eb]isi","MOOD":"conditional","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olisi', 'ois',
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-fc63732ba497');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olisi', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olisi', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihana', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ihana","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]ihana[X]ihan[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ihana(ihana)"}'::jsonb,
      'ihanaa', 'ihanaa',
      'partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful', 'approved', now(), 'content/approvals/part-6.json#this-weekend/form-bbaeb136ed47');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihanaa', 'ihana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihanaa', 'ihana',
      (select form_name_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select why_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      'partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mitä sä teet viikonloppuna?',
    'Mitä sinä teet viikonloppuna?', 'What are you doing at the weekend?',
    'this-weekend/1-puhe-6e1a5ab0a3f8.mp3', 'this-weekend/1-kirja-95aa4c450f4c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'kirja', 4, 'viikonloppuna', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'puhe', 4, 'viikonloppuna', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Lauantaina mä meen kirpparille.',
    'Lauantaina minä menen kirpputorille.', 'On Saturday I''m going to a flea market.',
    'this-weekend/2-puhe-8fe709ab194a.mp3', 'this-weekend/2-kirja-473ca9c55ff5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'menen', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen')),
    (v_line_id, 'kirja', 4, 'kirpputorille', (select id from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille')),
    (v_line_id, 'puhe', 1, 'Lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'meen', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen')),
    (v_line_id, 'puhe', 4, 'kirpparille', (select id from public.forms where lemma = 'kirpputori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kirpputorille' and surface_puhe = 'kirpparille'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Kiva! Mitä sä etit?',
    'Kiva! Mitä sinä etsit?', 'Nice! What are you looking for?',
    'this-weekend/3-puhe-18d317c8ffa2.mp3', 'this-weekend/3-kirja-be16f5ba4818.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 2, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'etsit', (select id from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit')),
    (v_line_id, 'puhe', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 2, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'etit', (select id from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsit' and surface_puhe = 'etit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Pöytää ja tuoleja. Mä tarviin niitä uuteen asuntoon.',
    'Pöytää ja tuoleja. Minä tarvitsen niitä uuteen asuntoon.', 'A table and chairs. I need them for my new flat.',
    'this-weekend/4-puhe-3eb072da5a84.mp3', 'this-weekend/4-kirja-72eb353e1216.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pöytää', (select id from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää')),
    (v_line_id, 'kirja', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'tuoleja', (select id from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja')),
    (v_line_id, 'kirja', 4, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 5, 'tarvitsen', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'kirja', 6, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä')),
    (v_line_id, 'kirja', 7, 'uuteen', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen')),
    (v_line_id, 'kirja', 8, 'asuntoon', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon')),
    (v_line_id, 'puhe', 1, 'Pöytää', (select id from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pöytää' and surface_puhe = 'pöytää')),
    (v_line_id, 'puhe', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'tuoleja', (select id from public.forms where lemma = 'tuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'tuoleja' and surface_puhe = 'tuoleja')),
    (v_line_id, 'puhe', 4, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 5, 'tarviin', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'puhe', 6, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä')),
    (v_line_id, 'puhe', 7, 'uuteen', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuteen' and surface_puhe = 'uuteen')),
    (v_line_id, 'puhe', 8, 'asuntoon', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Ai, sä muutat?',
    'Ai, sinä muutat?', 'Oh, you''re moving?',
    'this-weekend/5-puhe-85fbdef1a2ce.mp3', 'this-weekend/5-kirja-430bc6c96b4f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'muutat', (select id from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat')),
    (v_line_id, 'puhe', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'muutat', (select id from public.forms where lemma = 'muuttaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'muutat' and surface_puhe = 'muutat'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, ens kuus. Isompaan asuntoon.',
    'Kyllä, ensi kuussa. Isompaan asuntoon.', 'Yes, next month. To a bigger flat.',
    'this-weekend/6-puhe-8658c8a7f175.mp3', 'this-weekend/6-kirja-1834677132cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'ensi', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'kirja', 3, 'kuussa', (select id from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus')),
    (v_line_id, 'kirja', 4, 'Isompaan', (select id from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan')),
    (v_line_id, 'kirja', 5, 'asuntoon', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'ens', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'puhe', 3, 'kuus', (select id from public.forms where lemma = 'kuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuussa' and surface_puhe = 'kuus')),
    (v_line_id, 'puhe', 4, 'Isompaan', (select id from public.forms where lemma = 'iso' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'isompaan' and surface_puhe = 'isompaan')),
    (v_line_id, 'puhe', 5, 'asuntoon', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'asuntoon' and surface_puhe = 'asuntoon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Tarviiksä apuu muutos?',
    'Tarvitsetko sinä apua muutossa?', 'Do you need help with the move?',
    'this-weekend/7-puhe-6e021cd2cd8d.mp3', 'this-weekend/7-kirja-23b9b84399b6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tarvitsetko', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'apua', (select id from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu')),
    (v_line_id, 'kirja', 4, 'muutossa', (select id from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos')),
    (v_line_id, 'puhe', 1, 'Tarviik', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviik')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'apuu', (select id from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'apua' and surface_puhe = 'apuu')),
    (v_line_id, 'puhe', 4, 'muutos', (select id from public.forms where lemma = 'muutto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'muutossa' and surface_puhe = 'muutos'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Joo, se ois ihanaa!',
    'Kyllä, se olisi ihanaa!', 'Yes, that would be wonderful!',
    'this-weekend/8-puhe-f3d65400120b.mp3', 'this-weekend/8-kirja-7e7f309a0cef.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'olisi', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'kirja', 4, 'ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'ois', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'puhe', 4, 'ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#this-weekend/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
