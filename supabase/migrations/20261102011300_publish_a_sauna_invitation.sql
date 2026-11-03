-- Publishes the dialogue a-sauna-invitation (unit coffee-break-and-sauna). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-sauna-invitation. Do not edit by hand:
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
    where slug = 'a-sauna-invitation' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-sauna-invitation';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 25
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'coffee-break-and-sauna' and position = 25 and stop_number = 25;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'coffee-break-and-sauna';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-sauna-invitation', 2,
    'A sauna invitation')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-sauna-invitation' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'A sauna invitation';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-sauna-invitation';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sade][Nm]illä","NUMBER":"plural","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppp","WORDBASES":"+me(me)"}'::jsonb,
      'meillä', 'meil',
      'adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-a9fe1350b93e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'meillä', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'meillä', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      'adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saunavuoro', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"saunavuoro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sn][Ny]a[Bh][Bc][Ln][Xp]vuoro[X]vuoro[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+sauna(sauna)+vuoro(vuoro)"}'::jsonb,
      'saunavuoro', 'saunavuoro',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna slot, sauna turn', 'sauna slot, sauna turn', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-808f9b67f171');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunavuoro', 'saunavuoro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna slot, sauna turn', 'sauna slot, sauna turn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunavuoro', 'saunavuoro',
      (select form_name_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro'),
      (select why_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro'),
      (select meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro'),
      (select lemma_meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna slot, sauna turn', 'sauna slot, sauna turn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-3978a16fa6b0');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tuletko', 'tuuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-34727a73c81c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuletko', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuletko', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'saunaan', 'saunaan',
      'illative singular', 'Adds -an for ''to'': sauna becomes saunaan.', 'to the sauna', 'sauna', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-adc1c305d860');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunaan', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -an for ''to'': sauna becomes saunaan.', 'to the sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunaan', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan'),
      'illative singular', 'Adds -an for ''to'': sauna becomes saunaan.', 'to the sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mieli', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"mieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mieli[X]miele[Sade][Ny]llä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+mieli(mieli)"}'::jsonb,
      'mielelläni', 'mielellään',
      'adessive singular, with the possessive ending for my', 'Mielelläni means ''gladly'' or ''I''d love to''. Speech often says mielellään.', 'I''d love to', 'mind (mielelläni, gladly)', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-f878dc82043d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mielelläni', 'mieli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular, with the possessive ending for my', 'Mielelläni means ''gladly'' or ''I''d love to''. Speech often says mielellään.', 'I''d love to', 'mind (mielelläni, gladly)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mielelläni', 'mieli',
      (select form_name_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään'),
      (select why_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään'),
      (select meaning_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään'),
      (select lemma_meaning_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään'),
      'adessive singular, with the possessive ending for my', 'Mielelläni means ''gladly'' or ''I''d love to''. Speech often says mielellään.', 'I''d love to', 'mind (mielelläni, gladly)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-728ddce13587');
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
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"olla","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'ole', 'oo',
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-0fcdf4079f8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ole', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ole', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koskaan', 'CLASS=seikkasana', '{"BASEFORM":"koskaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]koskaan[X]koskaan","STRUCTURE":"=ppppppp","WORDBASES":"+koskaan(koskaan)"}'::jsonb,
      'koskaan', 'ikinä',
      'adverb', 'Speech often says ikinä. Books write koskaan. With en, both mean ''never''.', 'never (after not)', 'ever, never (with a no)', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-26da91bd08a8');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"käydä","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'käynyt', 'käyny',
      'past active participle, nominative singular', 'From käydä, to visit. After ''olen'' this form says ''have been''. Speech drops the last t: käyny.', 'been (once I''ve been)', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-ffbcf2bf8622');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käynyt', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From käydä, to visit. After ''olen'' this form says ''have been''. Speech drops the last t: käyny.', 'been (once I''ve been)', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käynyt', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny'),
      'past active participle, nominative singular', 'From käydä, to visit. After ''olen'' this form says ''have been''. Speech drops the last t: käyny.', 'been (once I''ve been)', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalaise[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaisessa', 'suomalaises',
      'inessive singular', 'Suomalainen changes to suomalaisessa to match saunassa: ''in a Finnish sauna''. Speech shortens -ssa to -s: suomalaisessa becomes suomalaises.', 'Finnish', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-deb1f8f69fd9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalaisessa', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Suomalainen changes to suomalaisessa to match saunassa: ''in a Finnish sauna''. Speech shortens -ssa to -s: suomalaisessa becomes suomalaises.', 'Finnish', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalaisessa', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises'),
      'inessive singular', 'Suomalainen changes to suomalaisessa to match saunassa: ''in a Finnish sauna''. Speech shortens -ssa to -s: suomalaisessa becomes suomalaises.', 'Finnish', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]sauna[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'saunassa', 'saunas',
      'inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-d98fbee7d5d9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunassa', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunassa', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      'inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hätä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"hätä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hätä[X]hät[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hätä(hätä)"}'::jsonb,
      'hätää', 'hätää',
      'partitive singular', 'The partitive after ei: ei hätää, no worries.', 'worries', 'emergency, worry', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-83955fefc056');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hätää', 'hätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive after ei: ei hätää, no worries.', 'worries', 'emergency, worry')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hätää', 'hätä',
      (select form_name_en from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää'),
      (select why_en from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää'),
      (select meaning_en from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää'),
      (select lemma_meaning_en from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää'),
      'partitive singular', 'The partitive after ei: ei hätää, no worries.', 'worries', 'emergency, worry';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kertoa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"kertoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kertoa[X]kerro[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+kertoa(kertoa)"}'::jsonb,
      'kerron', 'kerron',
      'present tense, 1st person singular', 'Kertoa changes to kerro- and takes -n for ''I'': kerron.', 'I''ll tell', 'to tell', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-87c7e3228a04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kerron', 'kertoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Kertoa changes to kerro- and takes -n for ''I'': kerron.', 'I''ll tell', 'to tell')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kerron', 'kertoa',
      (select form_name_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron'),
      (select why_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron'),
      (select meaning_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron'),
      (select lemma_meaning_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron'),
      'present tense, 1st person singular', 'Kertoa changes to kerro- and takes -n for ''I'': kerron.', 'I''ll tell', 'to tell';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaikki', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kaikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaikki[X]kaik[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kaikki(kaikki)"}'::jsonb,
      'kaiken', 'kaiken',
      'genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-064e99054944');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaiken', 'kaikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaiken', 'kaikki',
      (select form_name_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select why_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select lemma_meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      'genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-ae1caa07874f');
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
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-7aba8e0c1b63');
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
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]otta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ottaa', 'ottaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to take', 'to take', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-0bb2d5b32826');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ottaa', 'ottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to take', 'to take')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ottaa', 'ottaa',
      (select form_name_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa'),
      (select why_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa'),
      (select meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to take', 'to take';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukaan', 'CLASS=seikkasana', '{"BASEFORM":"mukaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]mukaan[X]mukaan","STRUCTURE":"=pppppp","WORDBASES":"+mukaan(mukaan)"}'::jsonb,
      'mukaan', 'mukaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-769eb876232e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mukaan', 'mukaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mukaan', 'mukaan',
      (select form_name_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select why_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select meaning_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select lemma_meaning_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pyyhe', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"pyyhe","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pyyhe[X]pyyhe[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+pyyhe(pyyhe)"}'::jsonb,
      'pyyhe', 'pyyhe',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'towel', 'towel', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-a72f7ecba17c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pyyhe', 'pyyhe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'towel', 'towel')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pyyhe', 'pyyhe',
      (select form_name_en from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe'),
      (select why_en from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe'),
      (select meaning_en from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe'),
      (select lemma_meaning_en from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'towel', 'towel';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juotava', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive', '{"BASEFORM":"juotava","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]juoda[X]juo[Ll][Ra]tav[Xj]a[X][Sp][Ny]aa","NUMBER":"singular","PARTICIPLE":"present_passive","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+juo(juoda)+tav+a(+a)"}'::jsonb,
      'juotavaa', 'juotavaa',
      'present passive participle, partitive singular', 'From juoda, to drink. Juotavaa means ''something to drink''.', 'something to drink', 'something to drink', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-0d81c73a08e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juotavaa', 'juotava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present passive participle, partitive singular', 'From juoda, to drink. Juotavaa means ''something to drink''.', 'something to drink', 'something to drink')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juotavaa', 'juotava',
      (select form_name_en from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa'),
      (select why_en from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa'),
      (select meaning_en from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa'),
      (select lemma_meaning_en from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa'),
      'present passive participle, partitive singular', 'From juoda, to drink. Juotavaa means ''something to drink''.', 'something to drink', 'something to drink';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-fd1a9ffcfdb7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuinka', 'kuinka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuinka', 'kuinka',
      (select form_name_en from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka'),
      (select why_en from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka'),
      (select meaning_en from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka'),
      (select lemma_meaning_en from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuuma', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kuuma","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kuuma[X]kuum[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kuuma(kuuma)"}'::jsonb,
      'kuuma', 'kuuma',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hot', 'hot', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-8e15765339bf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuuma', 'kuuma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'hot', 'hot')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuuma', 'kuuma',
      (select form_name_en from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma'),
      (select why_en from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma'),
      (select meaning_en from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma'),
      (select lemma_meaning_en from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hot', 'hot';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-0fd3b38079dc');
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
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('noin', 'CLASS=seikkasana', '{"BASEFORM":"noin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]noin[X]noin","STRUCTURE":"=pppp","WORDBASES":"+noin(noin)"}'::jsonb,
      'noin', 'noin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-548c5d31bffe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'noin', 'noin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'noin', 'noin',
      (select form_name_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select why_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select meaning_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select lemma_meaning_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahdeksankymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahdeksankymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kahdeksan[X]kahdeks[Sn][Ny]an[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp=pppppppp","WORDBASES":"+kahdeksan(kahdeksan)"}'::jsonb,
      'kahdeksankymmentä', 'kaheksankyt',
      'nominative singular', 'Speech drops the d and shortens kymmentä to kyt: kaheksankyt.', 'eighty', 'eighty', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-fd0540431668');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdeksankymmentä', 'kahdeksankymmentä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the d and shortens kymmentä to kyt: kaheksankyt.', 'eighty', 'eighty')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdeksankymmentä', 'kahdeksankymmentä',
      (select form_name_en from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt'),
      (select why_en from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt'),
      (select meaning_en from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt'),
      (select lemma_meaning_en from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt'),
      'nominative singular', 'Speech drops the d and shortens kymmentä to kyt: kaheksankyt.', 'eighty', 'eighty';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aste', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"aste","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aste[X]aste[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+aste(aste)"}'::jsonb,
      'astetta', 'astetta',
      'partitive singular', 'After a number the noun takes the partitive: kymmenen astetta.', 'degrees', 'degree', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-71079c0111ef');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'astetta', 'aste';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number the noun takes the partitive: kymmenen astetta.', 'degrees', 'degree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'astetta', 'aste',
      (select form_name_en from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta'),
      (select why_en from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta'),
      (select meaning_en from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta'),
      (select lemma_meaning_en from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta'),
      'partitive singular', 'After a number the noun takes the partitive: kymmenen astetta.', 'degrees', 'degree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voit', 'voit',
      'present tense, 2nd person singular', 'Voida drops -da and takes -t for ''you'': voit.', 'you can', 'can, to be able to', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-3d1f6ef9fe32');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voit', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Voida drops -da and takes -t for ''you'': voit.', 'you can', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voit', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit'),
      'present tense, 2nd person singular', 'Voida drops -da and takes -t for ''you'': voit.', 'you can', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('istua', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"istua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]istua[X]istu[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+istua(istua)"}'::jsonb,
      'istua', 'istuu',
      'basic form (A-infinitive)', 'This is the dictionary form, after voit (you can). Speech turns ua into uu: istuu.', 'sit', 'to sit', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-dfbb501be90a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'istua', 'istua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after voit (you can). Speech turns ua into uu: istuu.', 'sit', 'to sit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'istua', 'istua',
      (select form_name_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu'),
      (select why_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu'),
      (select meaning_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu'),
      (select lemma_meaning_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu'),
      'basic form (A-infinitive)', 'This is the dictionary form, after voit (you can). Speech turns ua into uu: istuu.', 'sit', 'to sit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alalaude', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"alalaude","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]ala[X]al[Sn][Ny]a[Bh][Bc][Ln][Xp]laude[X]lautee[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppp=ppppppppp","WORDBASES":"+ala(ala)+laude(laude)"}'::jsonb,
      'alalauteella', 'alalauteel',
      'adessive singular', 'Adds -lla for ''on'': alalaude becomes alalauteella. Speech shortens -lla to -l: alalauteella becomes alalauteel.', 'on the lower bench', 'lower bench (in a sauna)', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-b342202c09b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alalauteella', 'alalaude';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''on'': alalaude becomes alalauteella. Speech shortens -lla to -l: alalauteella becomes alalauteel.', 'on the lower bench', 'lower bench (in a sauna)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alalauteella', 'alalaude',
      (select form_name_en from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel'),
      (select why_en from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel'),
      (select meaning_en from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel'),
      (select lemma_meaning_en from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel'),
      'adessive singular', 'Adds -lla for ''on'': alalaude becomes alalauteella. Speech shortens -lla to -l: alalauteella becomes alalauteel.', 'on the lower bench', 'lower bench (in a sauna)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulen', 'tuun',
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come', 'approved', now(), 'content/approvals/part-5.json#a-sauna-invitation/form-e0ecd37fd00f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulen', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulen', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Meil on saunavuoro lauantaina. Tuuksä saunaan?',
    'Meillä on saunavuoro lauantaina. Tuletko sinä saunaan?', 'We have a sauna slot on Saturday. Will you come to the sauna?',
    'a-sauna-invitation/1-puhe-e02d3e71be61.mp3', 'a-sauna-invitation/1-kirja-511173b6a4d1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Meillä', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'saunavuoro', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro')),
    (v_line_id, 'kirja', 4, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'kirja', 5, 'Tuletko', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 7, 'saunaan', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan')),
    (v_line_id, 'puhe', 1, 'Meil', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'saunavuoro', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'saunavuoro' and surface_puhe = 'saunavuoro')),
    (v_line_id, 'puhe', 4, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 5, 'Tuuk', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 7, 'saunaan', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'saunaan' and surface_puhe = 'saunaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mielellään! Mut mä en oo ikinä käyny suomalaises saunas.',
    'Mielelläni! Mutta minä en ole koskaan käynyt suomalaisessa saunassa.', 'I''d love to! But I''ve never been in a Finnish sauna.',
    'a-sauna-invitation/2-puhe-ba618d8f59ab.mp3', 'a-sauna-invitation/2-kirja-0686be6ef007.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mielelläni', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään')),
    (v_line_id, 'kirja', 2, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 5, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'kirja', 6, 'koskaan', (select id from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä')),
    (v_line_id, 'kirja', 7, 'käynyt', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny')),
    (v_line_id, 'kirja', 8, 'suomalaisessa', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises')),
    (v_line_id, 'kirja', 9, 'saunassa', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas')),
    (v_line_id, 'puhe', 1, 'Mielellään', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään')),
    (v_line_id, 'puhe', 2, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 5, 'oo', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'puhe', 6, 'ikinä', (select id from public.forms where lemma = 'koskaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'koskaan' and surface_puhe = 'ikinä')),
    (v_line_id, 'puhe', 7, 'käyny', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'käynyt' and surface_puhe = 'käyny')),
    (v_line_id, 'puhe', 8, 'suomalaises', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisessa' and surface_puhe = 'suomalaises')),
    (v_line_id, 'puhe', 9, 'saunas', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Ei hätää. Mä kerron kaiken.',
    'Ei hätää. Minä kerron kaiken.', 'No worries. I''ll tell you everything.',
    'a-sauna-invitation/3-puhe-61ed2071f437.mp3', 'a-sauna-invitation/3-kirja-fd22f7634c4a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'kerron', (select id from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron')),
    (v_line_id, 'kirja', 5, 'kaiken', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'kerron', (select id from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kerron' and surface_puhe = 'kerron')),
    (v_line_id, 'puhe', 5, 'kaiken', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mitä mun pitää ottaa mukaan?',
    'Mitä minun pitää ottaa mukaan?', 'What do I need to bring?',
    'a-sauna-invitation/4-puhe-2783b0a99a32.mp3', 'a-sauna-invitation/4-kirja-8f56ef69a345.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 3, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'kirja', 4, 'ottaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa')),
    (v_line_id, 'kirja', 5, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 3, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'puhe', 4, 'ottaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa')),
    (v_line_id, 'puhe', 5, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'Pyyhe ja juotavaa.',
    'Pyyhe ja juotavaa.', 'A towel and something to drink.',
    'a-sauna-invitation/5-puhe-f8ecd66554df.mp3', 'a-sauna-invitation/5-kirja-da22b5340714.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pyyhe', (select id from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe')),
    (v_line_id, 'kirja', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'juotavaa', (select id from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa')),
    (v_line_id, 'puhe', 1, 'Pyyhe', (select id from public.forms where lemma = 'pyyhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pyyhe' and surface_puhe = 'pyyhe')),
    (v_line_id, 'puhe', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'juotavaa', (select id from public.forms where lemma = 'juotava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_passive' and surface_kirja = 'juotavaa' and surface_puhe = 'juotavaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kuinka kuuma siel on?',
    'Kuinka kuuma siellä on?', 'How hot is it in there?',
    'a-sauna-invitation/6-puhe-b66bcc653ccc.mp3', 'a-sauna-invitation/6-kirja-695f34535e2f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'kuuma', (select id from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma')),
    (v_line_id, 'kirja', 3, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'kuuma', (select id from public.forms where lemma = 'kuuma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kuuma' and surface_puhe = 'kuuma')),
    (v_line_id, 'puhe', 3, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'Noin kaheksankyt astetta. Mut sä voit istuu alalauteel.',
    'Noin kahdeksankymmentä astetta. Mutta sinä voit istua alalauteella.', 'About eighty degrees. But you can sit on the lower bench.',
    'a-sauna-invitation/7-puhe-7a86fa8d6ba4.mp3', 'a-sauna-invitation/7-kirja-ead6c712e64f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Noin', (select id from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin')),
    (v_line_id, 'kirja', 2, 'kahdeksankymmentä', (select id from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt')),
    (v_line_id, 'kirja', 3, 'astetta', (select id from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta')),
    (v_line_id, 'kirja', 4, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 6, 'voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit')),
    (v_line_id, 'kirja', 7, 'istua', (select id from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu')),
    (v_line_id, 'kirja', 8, 'alalauteella', (select id from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel')),
    (v_line_id, 'puhe', 1, 'Noin', (select id from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin')),
    (v_line_id, 'puhe', 2, 'kaheksankyt', (select id from public.forms where lemma = 'kahdeksankymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksankymmentä' and surface_puhe = 'kaheksankyt')),
    (v_line_id, 'puhe', 3, 'astetta', (select id from public.forms where lemma = 'aste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'astetta' and surface_puhe = 'astetta')),
    (v_line_id, 'puhe', 4, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 6, 'voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voit' and surface_puhe = 'voit')),
    (v_line_id, 'puhe', 7, 'istuu', (select id from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'istua' and surface_puhe = 'istuu')),
    (v_line_id, 'puhe', 8, 'alalauteel', (select id from public.forms where lemma = 'alalaude' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alalauteella' and surface_puhe = 'alalauteel'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Okei, mä tuun!',
    'Selvä, minä tulen!', 'OK, I''ll come!',
    'a-sauna-invitation/8-puhe-2ae9c2da238b.mp3', 'a-sauna-invitation/8-kirja-42680ba7a0fb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulen', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tuun', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-sauna-invitation/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
