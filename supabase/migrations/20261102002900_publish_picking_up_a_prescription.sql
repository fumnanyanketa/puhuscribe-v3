-- Publishes the dialogue picking-up-a-prescription (unit at-the-pharmacy). Made by
-- scripts/generate/pipeline.py publish from content/drafts/picking-up-a-prescription. Do not edit by hand:
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
    where slug = 'picking-up-a-prescription' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'picking-up-a-prescription';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 10
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'at-the-pharmacy' and position = 10 and stop_number = 10;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'at-the-pharmacy';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'picking-up-a-prescription', 3,
    'Picking up a prescription')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'picking-up-a-prescription' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Picking up a prescription';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'picking-up-a-prescription';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-cc0fdb024b55');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulla', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulla', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('resepti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"resepti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]resepti[X]resept[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+resepti(resepti)"}'::jsonb,
      'resepti', 'resepti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'prescription, recipe', 'prescription, recipe', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-074773d23914');
  end if;
  if not exists (select 1 from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'resepti', 'resepti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'prescription, recipe', 'prescription, recipe')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'resepti', 'resepti',
      (select form_name_en from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti'),
      (select why_en from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti'),
      (select meaning_en from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti'),
      (select lemma_meaning_en from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'prescription, recipe', 'prescription, recipe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-5eb112d9aace');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'onko', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'onko', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulla', 'sul',
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-87d0163b4377');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinulla', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinulla', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kelakortti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kelakortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kela[X]kel[Sn][Ny]a[Bh][Bc][Ln][Xp]kortti[X]kortt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=pppppp","WORDBASES":"+kela(kela)+kortti(kortti)"}'::jsonb,
      'kelakortti', 'kelakortti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Kela card (Finnish health insurance card)', 'Kela card (Finnish health insurance card)', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-b1468c555e65');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kelakortti', 'kelakortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Kela card (Finnish health insurance card)', 'Kela card (Finnish health insurance card)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kelakortti', 'kelakortti',
      (select form_name_en from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti'),
      (select why_en from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti'),
      (select meaning_en from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti'),
      (select lemma_meaning_en from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Kela card (Finnish health insurance card)', 'Kela card (Finnish health insurance card)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'tässä',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä. Said when handing something over.', 'here you are', 'this', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-c1b13a0ae69c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tässä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Tämä, this, with -ssä for ''in'': tässä. Said when handing something over.', 'here you are', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tässä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä'),
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä. Said when handing something over.', 'here you are', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lääke', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lääke","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lääke[X]lääke[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+lääke(lääke)"}'::jsonb,
      'lääke', 'lääke',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'medicine', 'medicine', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-205226b849df');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lääke', 'lääke';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'medicine', 'medicine')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lääke', 'lääke',
      (select form_name_en from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke'),
      (select why_en from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke'),
      (select meaning_en from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke'),
      (select lemma_meaning_en from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'medicine', 'medicine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('valmis', 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"valmis","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]valmis[X]valmi[Ses][Ny]ina","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppp","WORDBASES":"+valmis(valmis)"}'::jsonb,
      'valmiina', 'valmiina',
      'essive singular', 'Valmis, ready, takes -na here: valmiina, ''ready and waiting''. The s changes to i before the ending.', 'ready', 'ready, finished', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-62384fce0283');
  end if;
  if not exists (select 1 from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'valmiina', 'valmis';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Valmis, ready, takes -na here: valmiina, ''ready and waiting''. The s changes to i before the ending.', 'ready', 'ready, finished')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'valmiina', 'valmis',
      (select form_name_en from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina'),
      (select why_en from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina'),
      (select meaning_en from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina'),
      (select lemma_meaning_en from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina'),
      'essive singular', 'Valmis, ready, takes -na here: valmiina, ''ready and waiting''. The s changes to i before the ending.', 'ready', 'ready, finished';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]ota[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ota', 'ota',
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-e8d98fab6fcd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ota', 'ottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ota', 'ottaa',
      (select form_name_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select why_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select lemma_meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sp][Ny]itä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+se(se)"}'::jsonb,
      'sitä', 'sitä',
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-c039ed256b06');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamu', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"aamu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+aamu(aamu)"}'::jsonb,
      'aamulla', 'aamul',
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-5166646a9be8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamulla', 'aamu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamulla', 'aamu',
      (select form_name_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select why_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select lemma_meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-73c5475313cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'illalla', 'ilta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'illalla', 'ilta',
      (select form_name_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select why_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select lemma_meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ruoka', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"ruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ruoka[X]ruo[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+ruoka(ruoka)"}'::jsonb,
      'ruoan', 'ruuan',
      'genitive singular', 'The genitive singular goes before kanssa ''with'': ruoka becomes ruoan. Speech says ruuan.', 'food', 'food, meal', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-08a391170527');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ruoan', 'ruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before kanssa ''with'': ruoka becomes ruoan. Speech says ruuan.', 'food', 'food, meal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ruoan', 'ruoka',
      (select form_name_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan'),
      (select why_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan'),
      (select meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan'),
      (select lemma_meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan'),
      'genitive singular', 'The genitive singular goes before kanssa ''with'': ruoka becomes ruoan. Speech says ruuan.', 'food', 'food, meal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa","STRUCTURE":"=pppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssa', 'kaa',
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-6105fb644788');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kanssa', 'kanssa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kanssa', 'kanssa',
      (select form_name_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select why_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vai', 'CLASS=sidesana', '{"BASEFORM":"vai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vai[X]vai","STRUCTURE":"=ppp","WORDBASES":"+vai(vai)"}'::jsonb,
      'vai', 'vai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-83d8cf4795ac');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vai', 'vai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vai', 'vai',
      (select form_name_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select why_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select meaning_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select lemma_meaning_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilman', 'CLASS=suhdesana', '{"BASEFORM":"ilman","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]ilman[X]ilman","STRUCTURE":"=ppppp","WORDBASES":"+ilman(ilman)"}'::jsonb,
      'ilman', 'ilman',
      'adposition', 'This is the dictionary form. People say it the same way.', 'without', 'without', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-95eeba05861c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ilman', 'ilman';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'This is the dictionary form. People say it the same way.', 'without', 'without')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ilman', 'ilman',
      (select form_name_en from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman'),
      (select why_en from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman'),
      (select meaning_en from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman'),
      (select lemma_meaning_en from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman'),
      'adposition', 'This is the dictionary form. People say it the same way.', 'without', 'without';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"paljon","CLASS":"seikkasana","KYSYMYSLIITE":"true","MANUAL":"true"}'::jsonb,
      'paljonko', 'paljonks',
      'adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-40bfc95558ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paljonko', 'paljon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paljonko', 'paljon',
      (select form_name_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select why_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select lemma_meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      'adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maksaa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"maksaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]maksaa[X]maks[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+maksaa(maksaa)"}'::jsonb,
      'maksaa', 'maksaa',
      'present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-859d1d409945');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maksaa', 'maksaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maksaa', 'maksaa',
      (select form_name_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select why_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select lemma_meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      'present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kela', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kela","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kela[X]kel[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+kela(kela)"}'::jsonb,
      'kelan', 'kelan',
      'genitive singular', 'The genitive singular adds -n for ''of'': Kela becomes Kelan, ''Kela''s''.', 'Kela''s', 'Kela (the Finnish social insurance office)', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-25173aeff97f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kelan', 'kela';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular adds -n for ''of'': Kela becomes Kelan, ''Kela''s''.', 'Kela''s', 'Kela (the Finnish social insurance office)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kelan', 'kela',
      (select form_name_en from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan'),
      (select why_en from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan'),
      (select meaning_en from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan'),
      (select lemma_meaning_en from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan'),
      'genitive singular', 'The genitive singular adds -n for ''of'': Kela becomes Kelan, ''Kela''s''.', 'Kela''s', 'Kela (the Finnish social insurance office)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('korvaus', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"korvaus","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]korvata[X]korva[Ln][Xj]us[X]u[Sg][Ny]ksen","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppppp","WORDBASES":"+korva(korvata)+us(+us)"}'::jsonb,
      'korvauksen', 'korvauksen',
      'genitive singular', 'The genitive singular goes before kanssa ''with'': korvaus becomes korvauksen.', 'the refund', 'refund, compensation', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-749e7cd18313');
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'korvauksen', 'korvaus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before kanssa ''with'': korvaus becomes korvauksen.', 'the refund', 'refund, compensation')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'korvauksen', 'korvaus',
      (select form_name_en from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen'),
      (select why_en from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen'),
      (select meaning_en from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen'),
      (select lemma_meaning_en from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen'),
      'genitive singular', 'The genitive singular goes before kanssa ''with'': korvaus becomes korvauksen.', 'the refund', 'refund, compensation';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-05a31ace9a1d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksi', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksi', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('euro', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"euro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]euro[X]euro[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+euro(euro)"}'::jsonb,
      'euroa', 'euroo',
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro', 'approved', now(), 'content/approvals/part-2.json#picking-up-a-prescription/form-e0b2a20b7101');
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'euroa', 'euro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'euroa', 'euro',
      (select form_name_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select why_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select lemma_meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mul on resepti.',
    'Hei! Minulla on resepti.', 'Hi! I have a prescription.',
    'picking-up-a-prescription/1-puhe-c6259267023f.mp3', 'picking-up-a-prescription/1-kirja-cdc7bebc89c9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'resepti', (select id from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'resepti', (select id from public.forms where lemma = 'resepti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'resepti' and surface_puhe = 'resepti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Laura', 'Okei. Onks sul Kelakortti?',
    'Selvä. Onko sinulla Kelakortti?', 'OK. Do you have a Kela card?',
    'picking-up-a-prescription/2-puhe-8f52512278f5.mp3', 'picking-up-a-prescription/2-kirja-d88aca6e7190.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 4, 'Kelakortti', (select id from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 4, 'Kelakortti', (select id from public.forms where lemma = 'kelakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kelakortti' and surface_puhe = 'kelakortti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'On, tässä.',
    'On, tässä.', 'Yes, here.',
    'picking-up-a-prescription/3-puhe-b64c318536c4.mp3', 'picking-up-a-prescription/3-kirja-265a7a4d95c8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Laura', 'Kiitti. Lääke on valmiina. Ota sitä aamul ja illal.',
    'Kiitos. Lääke on valmiina. Ota sitä aamulla ja illalla.', 'Thanks. The medicine is ready. Take it morning and evening.',
    'picking-up-a-prescription/4-puhe-bae8decb03a2.mp3', 'picking-up-a-prescription/4-kirja-d34f57da3feb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Lääke', (select id from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'valmiina', (select id from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina')),
    (v_line_id, 'kirja', 5, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'kirja', 6, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä')),
    (v_line_id, 'kirja', 7, 'aamulla', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'kirja', 8, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 9, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Lääke', (select id from public.forms where lemma = 'lääke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääke' and surface_puhe = 'lääke')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'valmiina', (select id from public.forms where lemma = 'valmis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valmiina' and surface_puhe = 'valmiina')),
    (v_line_id, 'puhe', 5, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'puhe', 6, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä')),
    (v_line_id, 'puhe', 7, 'aamul', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'puhe', 8, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 9, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ruuan kaa vai ilman?',
    'Ruoan kanssa vai ilman?', 'With food or without?',
    'picking-up-a-prescription/5-puhe-b5e498a8f6be.mp3', 'picking-up-a-prescription/5-kirja-84f342089115.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ruoan', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan')),
    (v_line_id, 'kirja', 2, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'kirja', 3, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'kirja', 4, 'ilman', (select id from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman')),
    (v_line_id, 'puhe', 1, 'Ruuan', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan')),
    (v_line_id, 'puhe', 2, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 3, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'puhe', 4, 'ilman', (select id from public.forms where lemma = 'ilman' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'ilman' and surface_puhe = 'ilman'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Laura', 'Ruuan kaa.',
    'Ruoan kanssa.', 'With food.',
    'picking-up-a-prescription/6-puhe-ad710efa654f.mp3', 'picking-up-a-prescription/6-kirja-28b3dc89beaf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ruoan', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan')),
    (v_line_id, 'kirja', 2, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Ruuan', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ruoan' and surface_puhe = 'ruuan')),
    (v_line_id, 'puhe', 2, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Paljonks se maksaa?',
    'Paljonko se maksaa?', 'How much is it?',
    'picking-up-a-prescription/7-puhe-fc2ab7685159.mp3', 'picking-up-a-prescription/7-kirja-1f981158cd70.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Paljonko', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'maksaa', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa')),
    (v_line_id, 'puhe', 1, 'Paljonks', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'maksaa', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Laura', 'Kelan korvauksen kaa kaks euroo.',
    'Kelan korvauksen kanssa kaksi euroa.', 'With the Kela refund, two euros.',
    'picking-up-a-prescription/8-puhe-6aef6923b3ba.mp3', 'picking-up-a-prescription/8-kirja-d8270745a574.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kelan', (select id from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan')),
    (v_line_id, 'kirja', 2, 'korvauksen', (select id from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen')),
    (v_line_id, 'kirja', 3, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'kirja', 4, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 5, 'euroa', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo')),
    (v_line_id, 'puhe', 1, 'Kelan', (select id from public.forms where lemma = 'kela' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kelan' and surface_puhe = 'kelan')),
    (v_line_id, 'puhe', 2, 'korvauksen', (select id from public.forms where lemma = 'korvaus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'korvauksen' and surface_puhe = 'korvauksen')),
    (v_line_id, 'puhe', 3, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 4, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 5, 'euroo', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-2.json#picking-up-a-prescription/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
