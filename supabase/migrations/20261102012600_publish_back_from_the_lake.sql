-- Publishes the dialogue back-from-the-lake (unit out-in-nature). Made by
-- scripts/generate/pipeline.py publish from content/drafts/back-from-the-lake. Do not edit by hand:
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
    where slug = 'back-from-the-lake' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'back-from-the-lake';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 29
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'out-in-nature' and position = 29 and stop_number = 29;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'out-in-nature';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'back-from-the-lake', 3,
    'Back from the lake')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'back-from-the-lake' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Back from the lake';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'back-from-the-lake';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-58f467b0bcb4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'missä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'missä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P2][Ny][Ef]lit","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'olit', 'olit',
      'past tense, 2nd person singular', 'Olla means to be. -i- marks the past and -t goes with sinä: olit.', 'you were', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-ad337fae04a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olit', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Olla means to be. -i- marks the past and -t goes with sinä: olit.', 'you were', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olit', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit'),
      'past tense, 2nd person singular', 'Olla means to be. -i- marks the past and -t goes with sinä: olit.', 'you were', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikonloppu', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"viikonloppu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sg][Ny]n[Bh][Bc][Ln][Xp]loppu[X]loppu[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppp=ppppppp","WORDBASES":"+viikon(viikko)+loppu(loppu)"}'::jsonb,
      'viikonloppuna', 'viikonloppuna',
      'essive singular', 'Viikonloppu with -na for ''at, on'' a time: viikonloppuna.', 'at the weekend', 'weekend', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-59d6b443da13');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P1][Ny][Ef]lin","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'olin', 'olin',
      'past tense, 1st person singular', 'Olla, to be, in the past tense with -n for ''I'': olin.', 'I was', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-958a4ddbf13e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olin', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Olla, to be, in the past tense with -n for ''I'': olin.', 'I was', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olin', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin'),
      'past tense, 1st person singular', 'Olla, to be, in the past tense with -n for ''I'': olin.', 'I was', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mökki', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"mökki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mökki[X]möki[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+mökki(mökki)"}'::jsonb,
      'mökillä', 'mökillä',
      'adessive singular', 'Mökki with -llä for ''at'', and kk turns to k: mökillä.', 'at the cottage', 'cottage', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-fe631950eae1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mökillä', 'mökki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Mökki with -llä for ''at'', and kk turns to k: mökillä.', 'at the cottage', 'cottage')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mökillä', 'mökki',
      (select form_name_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä'),
      (select why_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä'),
      (select meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä'),
      (select lemma_meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä'),
      'adessive singular', 'Mökki with -llä for ''at'', and kk turns to k: mökillä.', 'at the cottage', 'cottage';
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('järvi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"järvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]järvi[X]järv[Sg][Ny]en","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+järvi(järvi)"}'::jsonb,
      'järven', 'järven',
      'genitive singular', 'Rannalla, ''on the shore'', needs -n on the word before: järvi becomes järven.', 'of a lake', 'lake', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-42ccaed39e9a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'järven', 'järvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Rannalla, ''on the shore'', needs -n on the word before: järvi becomes järven.', 'of a lake', 'lake')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'järven', 'järvi',
      (select form_name_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven'),
      (select why_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven'),
      (select meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven'),
      (select lemma_meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven'),
      'genitive singular', 'Rannalla, ''on the shore'', needs -n on the word before: järvi becomes järven.', 'of a lake', 'lake';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ranta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ranta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]ranta[X]ranna[Sade][Ny]lla","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+ranta(ranta)"}'::jsonb,
      'rannalla', 'rannalla',
      'adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn.', 'on the shore', 'beach, shore', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-56fd9e6e128c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rannalla', 'ranta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn.', 'on the shore', 'beach, shore')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rannalla', 'ranta',
      (select form_name_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla'),
      (select why_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla'),
      (select meaning_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla'),
      (select lemma_meaning_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla'),
      'adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn.', 'on the shore', 'beach, shore';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuka', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kuka","CLASS":"asemosana","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"omanto"}'::jsonb,
      'kenen', 'kenen',
      'genitive singular', 'Kuka, who, becomes kenen for ''whose''.', 'whose', 'who', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-b9d3094791d9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kenen', 'kuka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kuka, who, becomes kenen for ''whose''.', 'whose', 'who')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kenen', 'kuka',
      (select form_name_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen'),
      (select why_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen'),
      (select meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen'),
      (select lemma_meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen'),
      'genitive singular', 'Kuka, who, becomes kenen for ''whose''.', 'whose', 'who';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perhe', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"perhe","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perhe[X]perhe[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+perhe(perhe)"}'::jsonb,
      'perheen', 'perheen',
      'genitive singular', 'Adds -n for ''of'': perhe becomes perheen, ''of the family''.', 'family''s', 'family', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-d9716fcaa99a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perheen', 'perhe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n for ''of'': perhe becomes perheen, ''of the family''.', 'family''s', 'family')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perheen', 'perhe',
      (select form_name_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen'),
      (select why_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen'),
      (select meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen'),
      (select lemma_meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen'),
      'genitive singular', 'Adds -n for ''of'': perhe becomes perheen, ''of the family''.', 'family''s', 'family';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P1][Nm][Ef]imme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulimme', 'tultiin',
      'past tense, 1st person plural', 'Speech uses tultiin with me, ''we''. Books write tulimme, with -i- for the past.', 'we came', 'to come', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-44a2c1edd822');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulimme', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person plural', 'Speech uses tultiin with me, ''we''. Books write tulimme, with -i- for the past.', 'we came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulimme', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin'),
      'past tense, 1st person plural', 'Speech uses tultiin with me, ''we''. Books write tulimme, with -i- for the past.', 'we came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takaisin', 'CLASS=seikkasana', '{"BASEFORM":"takaisin","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'takaisin', 'takas',
      'adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-2c5f4daf7d39');
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'takaisin', 'takaisin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'takaisin', 'takaisin',
      (select form_name_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select why_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select meaning_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select lemma_meaning_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      'adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eilen', 'CLASS=seikkasana', '{"BASEFORM":"eilen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eilen[X]eilen","STRUCTURE":"=ppppp","WORDBASES":"+eilen(eilen)"}'::jsonb,
      'eilen', 'eilen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-937949f7d75d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eilen', 'eilen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eilen', 'eilen',
      (select form_name_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select why_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select lemma_meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uida', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"uida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]uida[X]u[Tt][Ai][P2][Nm][Ef]itte[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+uida(uida)"}'::jsonb,
      'uitteko', 'uitteks',
      'past tense, 2nd person plural, with the question ending -ko/-kö', 'Uida, to swim. -i- marks the past and -tte goes with te: uitte. -ko asks. Speech uses -ks: uitteks.', 'did you swim', 'to swim', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-7135cfc532e6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uitteko', 'uida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person plural, with the question ending -ko/-kö', 'Uida, to swim. -i- marks the past and -tte goes with te: uitte. -ko asks. Speech uses -ks: uitteks.', 'did you swim', 'to swim')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uitteko', 'uida',
      (select form_name_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks'),
      (select why_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks'),
      (select meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks'),
      (select lemma_meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks'),
      'past tense, 2nd person plural, with the question ending -ko/-kö', 'Uida, to swim. -i- marks the past and -tte goes with te: uitte. -ko asks. Speech uses -ks: uitteks.', 'did you swim', 'to swim';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-2aeedafa15c7');
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
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('järvi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"järvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]järvi[X]järve[Sine][Ny]ssä","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+järvi(järvi)"}'::jsonb,
      'järvessä', 'järves',
      'inessive singular', 'Adds -ssä for ''in'': järvi becomes järvessä. Speech shortens -ssä to -s: järvessä becomes järves.', 'in the lake', 'lake', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-34199f1ea70b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'järvessä', 'järvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssä for ''in'': järvi becomes järvessä. Speech shortens -ssä to -s: järvessä becomes järves.', 'in the lake', 'lake')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'järvessä', 'järvi',
      (select form_name_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves'),
      (select why_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves'),
      (select meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves'),
      (select lemma_meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves'),
      'inessive singular', 'Adds -ssä for ''in'': järvi becomes järvessä. Speech shortens -ssä to -s: järvessä becomes järves.', 'in the lake', 'lake';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]men[Tt][Ai][P1][Nm][Ef]imme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menimme', 'mentiin',
      'past tense, 1st person plural', 'Speech uses mentiin with me, ''we''. Books write menimme, with -i- for the past.', 'we went', 'to go', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-ed1e75092390');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menimme', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person plural', 'Speech uses mentiin with me, ''we''. Books write menimme, with -i- for the past.', 'we went', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menimme', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin'),
      'past tense, 1st person plural', 'Speech uses mentiin with me, ''we''. Books write menimme, with -i- for the past.', 'we went', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('soutuvene', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"soutuvene","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]soutu[X]soutu[Sn][Ny][Bh][Bc][Ln][Xp]vene[X]venee[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+soutu(soutu)+vene(vene)"}'::jsonb,
      'soutuveneellä', 'soutuveneel',
      'adessive singular', 'Adds -llä for ''by'': soutuvene becomes soutuveneellä. Speech shortens -llä to -l: soutuveneellä becomes soutuveneel.', 'by rowing boat', 'rowing boat', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-1781e6e182a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'soutuveneellä', 'soutuvene';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''by'': soutuvene becomes soutuveneellä. Speech shortens -llä to -l: soutuveneellä becomes soutuveneel.', 'by rowing boat', 'rowing boat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'soutuveneellä', 'soutuvene',
      (select form_name_en from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel'),
      (select why_en from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel'),
      (select meaning_en from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel'),
      (select lemma_meaning_en from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel'),
      'adessive singular', 'Adds -llä for ''by'': soutuvene becomes soutuveneellä. Speech shortens -llä to -l: soutuveneellä becomes soutuveneel.', 'by rowing boat', 'rowing boat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saari', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"saari","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]saari[X]saar[Sill][Ny]een","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+saari(saari)"}'::jsonb,
      'saareen', 'saareen',
      'illative singular', 'Adds -en for ''to'': saari becomes saareen.', 'to an island', 'island', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-537e038c603c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saareen', 'saari';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -en for ''to'': saari becomes saareen.', 'to an island', 'island')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saareen', 'saari',
      (select form_name_en from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen'),
      (select why_en from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen'),
      (select meaning_en from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen'),
      (select lemma_meaning_en from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen'),
      'illative singular', 'Adds -en for ''to'': saari becomes saareen.', 'to an island', 'island';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulostaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"kuulostaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuulostaa[X]kuulosta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppppp","WORDBASES":"+kuulostaa(kuulostaa)"}'::jsonb,
      'kuulostaa', 'kuulostaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sound', 'to sound', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-e2a29b08d6bc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuulostaa', 'kuulostaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sound', 'to sound')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuulostaa', 'kuulostaa',
      (select form_name_en from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa'),
      (select why_en from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa'),
      (select meaning_en from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sound', 'to sound';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-a392b28c6a8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aivan', 'aivan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aivan', 'aivan',
      (select form_name_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select why_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select lemma_meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalaise[Sabl][Ny]lta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaiselta', 'suomalaiselta',
      'ablative singular', 'Kuulostaa, to seem by the sound of it, takes -lta: suomalainen becomes suomalaiselta.', 'Finnish', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-67474ef81ede');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalaiselta', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Kuulostaa, to seem by the sound of it, takes -lta: suomalainen becomes suomalaiselta.', 'Finnish', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalaiselta', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta'),
      'ablative singular', 'Kuulostaa, to seem by the sound of it, takes -lta: suomalainen becomes suomalaiselta.', 'Finnish', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kesä[Sabl][Ny]ltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesältä', 'kesältä',
      'ablative singular', 'Kuulostaa, to seem by the sound of it, takes -ltä: kesä becomes kesältä.', 'summer', 'summer', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-e2f5ccaabe2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesältä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Kuulostaa, to seem by the sound of it, takes -ltä: kesä becomes kesältä.', 'summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesältä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä'),
      'ablative singular', 'Kuulostaa, to seem by the sound of it, takes -ltä: kesä becomes kesältä.', 'summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P3][Ny][Ef]li","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'oli', 'oli',
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-272accd9b290');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oli', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oli', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Ll][Xp]hyvä[X]par[Sn][Ny][Cs]as","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'paras', 'paras',
      'superlative, nominative singular', 'The superlative of hyvä, good: paras, best.', 'best', 'good', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-ec5ab0146a13');
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
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikonloppu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viikonloppu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sg][Ny]n[Bh][Bc][Ln][Xp]loppu[X]loppu[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=ppppp","WORDBASES":"+viikon(viikko)+loppu(loppu)"}'::jsonb,
      'viikonloppu', 'viikonloppu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'weekend', 'weekend', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-4f622b653755');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikonloppu', 'viikonloppu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'weekend', 'weekend')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikonloppu', 'viikonloppu',
      (select form_name_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu'),
      (select why_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu'),
      (select meaning_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu'),
      (select lemma_meaning_en from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'weekend', 'weekend';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koskaan', 'CLASS=seikkasana', '{"BASEFORM":"koskaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]koskaan[X]koskaan","STRUCTURE":"=ppppppp","WORDBASES":"+koskaan(koskaan)"}'::jsonb,
      'koskaan', 'ikinä',
      'adverb', 'Speech often says ikinä. Books write koskaan. With en, both mean ''never''.', 'never (after not)', 'ever, never (with a no)', 'approved', now(), 'content/approvals/part-5.json#back-from-the-lake/form-26da91bd08a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'koskaan', 'koskaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often says ikinä. Books write koskaan. With en, both mean ''never''.', 'never (after not)', 'ever, never (with a no)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'koskaan', 'koskaan',
      (select form_name_en from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä'),
      (select why_en from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä'),
      (select meaning_en from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä'),
      (select lemma_meaning_en from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä'),
      'adverb', 'Speech often says ikinä. Books write koskaan. With en, both mean ''never''.', 'never (after not)', 'ever, never (with a no)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Missä sä olit viikonloppuna?',
    'Missä sinä olit viikonloppuna?', 'Where were you at the weekend?',
    'back-from-the-lake/1-puhe-f2c79969dce3.mp3', 'back-from-the-lake/1-kirja-7732eddd5998.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'olit', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit')),
    (v_line_id, 'kirja', 4, 'viikonloppuna', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna')),
    (v_line_id, 'puhe', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'olit', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olit' and surface_puhe = 'olit')),
    (v_line_id, 'puhe', 4, 'viikonloppuna', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'viikonloppuna' and surface_puhe = 'viikonloppuna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä olin mökillä järven rannalla.',
    'Minä olin mökillä järven rannalla.', 'I was at a cottage by a lake.',
    'back-from-the-lake/2-puhe-cf213c114eaf.mp3', 'back-from-the-lake/2-kirja-770ca8fdaf64.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olin', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin')),
    (v_line_id, 'kirja', 3, 'mökillä', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä')),
    (v_line_id, 'kirja', 4, 'järven', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven')),
    (v_line_id, 'kirja', 5, 'rannalla', (select id from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'olin', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'olin' and surface_puhe = 'olin')),
    (v_line_id, 'puhe', 3, 'mökillä', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä')),
    (v_line_id, 'puhe', 4, 'järven', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'järven' and surface_puhe = 'järven')),
    (v_line_id, 'puhe', 5, 'rannalla', (select id from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannalla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'Kenen mökillä?',
    'Kenen mökillä?', 'Whose cottage?',
    'back-from-the-lake/3-puhe-178d71afe8ae.mp3', 'back-from-the-lake/3-kirja-391ad8cb77f9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kenen', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen')),
    (v_line_id, 'kirja', 2, 'mökillä', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä')),
    (v_line_id, 'puhe', 1, 'Kenen', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kenen' and surface_puhe = 'kenen')),
    (v_line_id, 'puhe', 2, 'mökillä', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'mökillä' and surface_puhe = 'mökillä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Ainon perheen. Me tultiin takas eilen.',
    'Ainon perheen. Me tulimme takaisin eilen.', 'Aino''s family''s. We came back yesterday.',
    'back-from-the-lake/4-puhe-18df7f337f40.mp3', 'back-from-the-lake/4-kirja-51ecab9b7d0f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ainon', null),
    (v_line_id, 'kirja', 2, 'perheen', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen')),
    (v_line_id, 'kirja', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 4, 'tulimme', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin')),
    (v_line_id, 'kirja', 5, 'takaisin', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas')),
    (v_line_id, 'kirja', 6, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'puhe', 1, 'Ainon', null),
    (v_line_id, 'puhe', 2, 'perheen', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'perheen' and surface_puhe = 'perheen')),
    (v_line_id, 'puhe', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 4, 'tultiin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulimme' and surface_puhe = 'tultiin')),
    (v_line_id, 'puhe', 5, 'takas', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas')),
    (v_line_id, 'puhe', 6, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ville', 'Uitteks te järves?',
    'Uitteko te järvessä?', 'Did you swim in the lake?',
    'back-from-the-lake/5-puhe-2d994c0a0bb1.mp3', 'back-from-the-lake/5-kirja-cb3b105fa7f7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Uitteko', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks')),
    (v_line_id, 'kirja', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 3, 'järvessä', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves')),
    (v_line_id, 'puhe', 1, 'Uitteks', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'uitteko' and surface_puhe = 'uitteks')),
    (v_line_id, 'puhe', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 3, 'järves', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'järvessä' and surface_puhe = 'järves'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo! Ja me mentiin soutuveneel saareen.',
    'Kyllä! Ja me menimme soutuveneellä saareen.', 'Yes! And we rowed to an island.',
    'back-from-the-lake/6-puhe-e7ae4d5003d3.mp3', 'back-from-the-lake/6-kirja-80ed4568d162.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 4, 'menimme', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin')),
    (v_line_id, 'kirja', 5, 'soutuveneellä', (select id from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel')),
    (v_line_id, 'kirja', 6, 'saareen', (select id from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 4, 'mentiin', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'menimme' and surface_puhe = 'mentiin')),
    (v_line_id, 'puhe', 5, 'soutuveneel', (select id from public.forms where lemma = 'soutuvene' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'soutuveneellä' and surface_puhe = 'soutuveneel')),
    (v_line_id, 'puhe', 6, 'saareen', (select id from public.forms where lemma = 'saari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saareen' and surface_puhe = 'saareen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ville', 'Kuulostaa ihan suomalaiselta kesältä.',
    'Kuulostaa aivan suomalaiselta kesältä.', 'That sounds like a proper Finnish summer.',
    'back-from-the-lake/7-puhe-695822867ef4.mp3', 'back-from-the-lake/7-kirja-63f82472ae98.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuulostaa', (select id from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa')),
    (v_line_id, 'kirja', 2, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 3, 'suomalaiselta', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta')),
    (v_line_id, 'kirja', 4, 'kesältä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä')),
    (v_line_id, 'puhe', 1, 'Kuulostaa', (select id from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa')),
    (v_line_id, 'puhe', 2, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 3, 'suomalaiselta', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaiselta' and surface_puhe = 'suomalaiselta')),
    (v_line_id, 'puhe', 4, 'kesältä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kesältä' and surface_puhe = 'kesältä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Se oli paras viikonloppu ikinä!',
    'Se oli paras viikonloppu koskaan!', 'It was the best weekend ever!',
    'back-from-the-lake/8-puhe-32ad2bcb3a8b.mp3', 'back-from-the-lake/8-kirja-c2ba86931cdb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'kirja', 3, 'paras', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras')),
    (v_line_id, 'kirja', 4, 'viikonloppu', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu')),
    (v_line_id, 'kirja', 5, 'koskaan', (select id from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'puhe', 3, 'paras', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'paras' and surface_puhe = 'paras')),
    (v_line_id, 'puhe', 4, 'viikonloppu', (select id from public.forms where lemma = 'viikonloppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viikonloppu' and surface_puhe = 'viikonloppu')),
    (v_line_id, 'puhe', 5, 'ikinä', (select id from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#back-from-the-lake/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#back-from-the-lake/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
