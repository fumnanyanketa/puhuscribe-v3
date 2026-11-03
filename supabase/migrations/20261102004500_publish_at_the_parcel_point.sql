-- Publishes the dialogue at-the-parcel-point (unit collecting-a-parcel). Made by
-- scripts/generate/pipeline.py publish from content/drafts/at-the-parcel-point. Do not edit by hand:
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
    where slug = 'at-the-parcel-point' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'at-the-parcel-point';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 16
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'collecting-a-parcel' and position = 16 and stop_number = 16;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'collecting-a-parcel';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'at-the-parcel-point', 1,
    'At the parcel point')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'at-the-parcel-point' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'At the parcel point';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'at-the-parcel-point';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulin', 'tulin',
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-85741e401e76');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulin', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulin', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hake[Tn3][Ny][Sill]maan","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'hakemaan', 'hakee',
      'MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-21daceb78f26');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hakemaan', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hakemaan', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      'MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paketti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"paketti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]paketti[X]pakett[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+paketti(paketti)"}'::jsonb,
      'pakettia', 'pakettii',
      'partitive singular', 'The partitive singular after hakemaan: paketti becomes pakettia. Speech says pakettii.', 'a parcel', 'parcel, package', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-69abb1ef0a61');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pakettia', 'paketti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular after hakemaan: paketti becomes pakettia. Speech says pakettii.', 'a parcel', 'parcel, package')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pakettia', 'paketti',
      (select form_name_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii'),
      (select why_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii'),
      (select meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii'),
      (select lemma_meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii'),
      'partitive singular', 'The partitive singular after hakemaan: paketti becomes pakettia. Speech says pakettii.', 'a parcel', 'parcel, package';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-1df5ffb944a0');
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
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-5eb112d9aace');
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
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('seurantakoodi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"seurantakoodi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]seuranta[X]seurant[Sn][Ny]a[Bh][Bc][Ln][Xp]koodi[X]kood[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp=ppppp","WORDBASES":"+seuranta(seuranta)+koodi(koodi)"}'::jsonb,
      'seurantakoodi', 'seurantakoodi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'tracking code', 'tracking code', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-184225c75a3e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'seurantakoodi', 'seurantakoodi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'tracking code', 'tracking code')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'seurantakoodi', 'seurantakoodi',
      (select form_name_en from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi'),
      (select why_en from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi'),
      (select meaning_en from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi'),
      (select lemma_meaning_en from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'tracking code', 'tracking code';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'tässä',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä. Said when handing something over.', 'here you are', 'this', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-c1b13a0ae69c');
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
  if not exists (select 1 from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhelin', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"puhelin","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puhelin[X]puhelime[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppppp","WORDBASES":"+puhelin(puhelin)"}'::jsonb,
      'puhelimessa', 'puhelimessa',
      'inessive singular', 'Adds -ssa for ''in, on'': puhelin becomes puhelimessa, the n turning to me.', 'on the phone', 'phone', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-00d138a331d0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhelimessa', 'puhelin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in, on'': puhelin becomes puhelimessa, the n turning to me.', 'on the phone', 'phone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhelimessa', 'puhelin',
      (select form_name_en from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa'),
      (select why_en from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa'),
      (select meaning_en from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa'),
      (select lemma_meaning_en from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa'),
      'inessive singular', 'Adds -ssa for ''in, on'': puhelin becomes puhelimessa, the n turning to me.', 'on the phone', 'phone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-bfff487cc1b5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mikä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mikä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-98e98f16f669');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinun', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinun', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sukunimi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"sukunimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suku[X]suku[Sn][Ny][Bh][Bc][Ln][Ivj][Xp]nimi[X]nim[Sn][Ny]e[O2y]si","MALAGA_VAPAA_JALKIOSA":"true","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=pppppp","WORDBASES":"+suku(suku)+nimi(nimi)"}'::jsonb,
      'sukunimesi', 'sukunimi',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; sukunimi turns its i to e first: sukunimesi. Speech says sun sukunimi.', 'your surname', 'surname', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-8fa9e71cd10c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sukunimesi', 'sukunimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your''; sukunimi turns its i to e first: sukunimesi. Speech says sun sukunimi.', 'your surname', 'surname')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sukunimesi', 'sukunimi',
      (select form_name_en from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi'),
      (select why_en from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi'),
      (select meaning_en from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi'),
      (select lemma_meaning_en from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; sukunimi turns its i to e first: sukunimesi. Speech says sun sukunimi.', 'your surname', 'surname';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('henkilöllisyystodistus', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"henkilöllisyystodistus","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]henkilö[X]henkilö[Ll]lli[Xj]nen[X]sy[Ln][Xj]ys[X]y[Sn][Ny]s[Bh][Bc][Lt][Xp]todistaa[X]todist[Ln][Xj]us[X]u[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppppppppp=pppppppp","WORDBASES":"+henkilö(henkilö)+llisy(+nen)+ys(+ys)+todist(todistaa)+us(+us)"}'::jsonb,
      'henkilöllisyystodistus', 'henkilöllisyystodistus',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'proof of identity, ID', 'proof of identity, ID', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-8512c03016d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'henkilöllisyystodistus', 'henkilöllisyystodistus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'proof of identity, ID', 'proof of identity, ID')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'henkilöllisyystodistus', 'henkilöllisyystodistus',
      (select form_name_en from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus'),
      (select why_en from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus'),
      (select meaning_en from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus'),
      (select lemma_meaning_en from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'proof of identity, ID', 'proof of identity, ID';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ajokortti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"ajokortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ajo[X]ajo[Sn][Ny][Bh][Bc][Ln][Xp]kortti[X]kortt[Sn][Ny]i[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=pppppppp","WORDBASES":"+ajo(ajo)+kortti(kortti)"}'::jsonb,
      'ajokorttini', 'ajokortti',
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': ajokortti becomes ajokorttini. Speech just says mun ajokortti.', 'my driving licence', 'driving licence', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-7b516c6a0552');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ajokorttini', 'ajokortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': ajokortti becomes ajokorttini. Speech just says mun ajokortti.', 'my driving licence', 'driving licence')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ajokorttini', 'ajokortti',
      (select form_name_en from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti'),
      (select why_en from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti'),
      (select meaning_en from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti'),
      (select lemma_meaning_en from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti'),
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': ajokortti becomes ajokorttini. Speech just says mun ajokortti.', 'my driving licence', 'driving licence';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paketti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"paketti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]paketti[X]pakett[Sn][Ny]i[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+paketti(paketti)"}'::jsonb,
      'pakettisi', 'paketti',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': paketti becomes pakettisi. Speech just says sun paketti.', 'your parcel', 'parcel, package', 'approved', now(), 'content/approvals/part-3.json#at-the-parcel-point/form-ab93b5f121bc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pakettisi', 'paketti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your'': paketti becomes pakettisi. Speech just says sun paketti.', 'your parcel', 'parcel, package')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pakettisi', 'paketti',
      (select form_name_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti'),
      (select why_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti'),
      (select meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti'),
      (select lemma_meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': paketti becomes pakettisi. Speech just says sun paketti.', 'your parcel', 'parcel, package';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä tulin hakee pakettii.',
    'Hei! Minä tulin hakemaan pakettia.', 'Hi! I''ve come to pick up a parcel.',
    'at-the-parcel-point/1-puhe-f3acb77a264b.mp3', 'at-the-parcel-point/1-kirja-8997a60bb92b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'kirja', 4, 'hakemaan', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee')),
    (v_line_id, 'kirja', 5, 'pakettia', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'puhe', 4, 'hakee', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee')),
    (v_line_id, 'puhe', 5, 'pakettii', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pakettia' and surface_puhe = 'pakettii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Jonna', 'Okei. Onks sul seurantakoodi?',
    'Selvä. Onko sinulla seurantakoodi?', 'OK. Do you have the tracking code?',
    'at-the-parcel-point/2-puhe-0cd8b747b8ba.mp3', 'at-the-parcel-point/2-kirja-ddd1882cdfd0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 4, 'seurantakoodi', (select id from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 4, 'seurantakoodi', (select id from public.forms where lemma = 'seurantakoodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seurantakoodi' and surface_puhe = 'seurantakoodi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Joo, tässä puhelimessa.',
    'Kyllä, tässä puhelimessa.', 'Yes, here on my phone.',
    'at-the-parcel-point/3-puhe-9956642cfa5f.mp3', 'at-the-parcel-point/3-kirja-f414de6eb88d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'kirja', 3, 'puhelimessa', (select id from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'puhe', 3, 'puhelimessa', (select id from public.forms where lemma = 'puhelin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'puhelimessa' and surface_puhe = 'puhelimessa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Jonna', 'Kiitti. Mikä sun sukunimi on?',
    'Kiitos. Mikä sinun sukunimesi on?', 'Thanks. What''s your surname?',
    'at-the-parcel-point/4-puhe-0a6f8089b00b.mp3', 'at-the-parcel-point/4-kirja-30ec478cdc42.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 3, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 4, 'sukunimesi', (select id from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 3, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 4, 'sukunimi', (select id from public.forms where lemma = 'sukunimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'sukunimesi' and surface_puhe = 'sukunimi')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Silva. Äs, ii, äl, vee, aa.',
    'Silva. S, I, L, V, A.', 'Silva. S, I, L, V, A.',
    'at-the-parcel-point/5-puhe-320afc59e4bd.mp3', 'at-the-parcel-point/5-kirja-5ea609017479.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Silva', null),
    (v_line_id, 'kirja', 2, 'S', null),
    (v_line_id, 'kirja', 3, 'I', null),
    (v_line_id, 'kirja', 4, 'L', null),
    (v_line_id, 'kirja', 5, 'V', null),
    (v_line_id, 'kirja', 6, 'A', null),
    (v_line_id, 'puhe', 1, 'Silva', null),
    (v_line_id, 'puhe', 2, 'Äs', null),
    (v_line_id, 'puhe', 3, 'ii', null),
    (v_line_id, 'puhe', 4, 'äl', null),
    (v_line_id, 'puhe', 5, 'vee', null),
    (v_line_id, 'puhe', 6, 'aa', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Jonna', 'Ja henkilöllisyystodistus?',
    'Ja henkilöllisyystodistus?', 'And some ID?',
    'at-the-parcel-point/6-puhe-b288faf5a631.mp3', 'at-the-parcel-point/6-kirja-4144cbffacec.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'henkilöllisyystodistus', (select id from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'henkilöllisyystodistus', (select id from public.forms where lemma = 'henkilöllisyystodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilöllisyystodistus' and surface_puhe = 'henkilöllisyystodistus'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Tässä on mun ajokortti.',
    'Tässä on minun ajokorttini.', 'Here''s my driving licence.',
    'at-the-parcel-point/7-puhe-be4a2244505d.mp3', 'at-the-parcel-point/7-kirja-adca683b947f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'ajokorttini', (select id from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti')),
    (v_line_id, 'puhe', 1, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'ajokortti', (select id from public.forms where lemma = 'ajokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ajokorttini' and surface_puhe = 'ajokortti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Jonna', 'Kiitti. Tässä on sun paketti.',
    'Kiitos. Tässä on sinun pakettisi.', 'Thanks. Here''s your parcel.',
    'at-the-parcel-point/8-puhe-58f43ecd05ce.mp3', 'at-the-parcel-point/8-kirja-bec6f24e3850.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 5, 'pakettisi', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'tässä')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 5, 'paketti', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'pakettisi' and surface_puhe = 'paketti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#at-the-parcel-point/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
