-- Publishes the dialogue a-library-card (unit at-the-library). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-library-card. Do not edit by hand:
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
    where slug = 'a-library-card' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-library-card';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 28
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'at-the-library' and position = 28 and stop_number = 28;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'at-the-library';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-library-card', 1,
    'A library card')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-library-card' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'A library card';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-library-card';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Te][Ap][P1][Ny][Ef]isin","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluaisin', 'haluisin',
      'conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-bcf5603c26d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluaisin', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluaisin', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      'conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirjastokortti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kirjastokortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kirjasto[X]kirjasto[Sn][Ny][Bh][Bc][Ln][Xp]kortti[X]kort[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp=pppppp","WORDBASES":"+kirjasto(kirjasto)+kortti(kortti)"}'::jsonb,
      'kirjastokortin', 'kirjastokortin',
      'genitive singular', 'A whole thing you want takes -n: kirjastokortti becomes kirjastokortin, tt turning into t.', 'a library card', 'library card', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-43c9b90ae35a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjastokortin', 'kirjastokortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A whole thing you want takes -n: kirjastokortti becomes kirjastokortin, tt turning into t.', 'a library card', 'library card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjastokortin', 'kirjastokortti',
      (select form_name_en from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin'),
      (select why_en from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin'),
      (select meaning_en from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin'),
      (select lemma_meaning_en from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin'),
      'genitive singular', 'A whole thing you want takes -n: kirjastokortti becomes kirjastokortin, tt turning into t.', 'a library card', 'library card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-b20bd263b5ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'totta', 'tosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'totta', 'tosi',
      (select form_name_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select why_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select lemma_meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kai', 'CLASS=seikkasana', '{"BASEFORM":"kai","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kai[X]kai","STRUCTURE":"=ppp","WORDBASES":"+kai(kai)"}'::jsonb,
      'kai', 'kai',
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-b1285c45ffe6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kai', 'kai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kai', 'kai',
      (select form_name_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select why_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select lemma_meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-5eb112d9aace');
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
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('henkilökortti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"henkilökortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]henkilö[X]henkilö[Sn][Ny][Bh][Bc][Ln][Xp]kortti[X]kortt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=pppppp","WORDBASES":"+henkilö(henkilö)+kortti(kortti)"}'::jsonb,
      'henkilökortti', 'henkilökortti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ID card', 'ID card', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-c21006d905b6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'henkilökortti', 'henkilökortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'ID card', 'ID card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'henkilökortti', 'henkilökortti',
      (select form_name_en from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti'),
      (select why_en from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti'),
      (select meaning_en from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti'),
      (select lemma_meaning_en from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ID card', 'ID card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-cc0fdb024b55');
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
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oleskelulupakortti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"oleskelulupakortti","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]oleskella[X]oleskel[Ln][Xj]u[X]u[Sn][Ny][Bh][Bc][Ln][Xp]lupa[X]lup[Sn][Ny]a[Bh][Bc][Ln][Xp]kortti[X]kortt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp=pppp=pppppp","WORDBASES":"+oleskel(oleskella)+u(+u)+lupa(lupa)+kortti(kortti)"}'::jsonb,
      'oleskelulupakortti', 'oleskelulupakortti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit card', 'residence permit card', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-b27b080b2889');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oleskelulupakortti', 'oleskelulupakortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit card', 'residence permit card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oleskelulupakortti', 'oleskelulupakortti',
      (select form_name_en from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti'),
      (select why_en from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti'),
      (select meaning_en from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti'),
      (select lemma_meaning_en from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit card', 'residence permit card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb][Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käykö', 'käyks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-5941266599a1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käykö', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käykö', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käy', 'käy',
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-24f89699a032');
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
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-e18d9223b2b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvin', 'hyvin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvin', 'hyvin',
      (select form_name_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select why_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvit[Tt][Ap][P4][Ef]aan","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitaan', 'tarvitaan',
      'present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-d64cc151ab47');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitaan', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitaan', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      'present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osoite', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"osoite","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osoite[X]osoitte[Sn][Ny]e[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppppp","WORDBASES":"+osoite(osoite)"}'::jsonb,
      'osoitteesi', 'osote',
      'nominative singular, with the possessive ending for your', 'Books write osoitteesi, adding -si for ''your''. Speech says sun osote, with oi shortened to o.', 'your address', 'address', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-e7af98474664');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osoitteesi', 'osoite';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books write osoitteesi, adding -si for ''your''. Speech says sun osote, with oi shortened to o.', 'your address', 'address')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osoitteesi', 'osoite',
      (select form_name_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote'),
      (select why_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote'),
      (select meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote'),
      (select lemma_meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote'),
      'nominative singular, with the possessive ending for your', 'Books write osoitteesi, adding -si for ''your''. Speech says sun osote, with oi shortened to o.', 'your address', 'address';
  end if;
  if not exists (select 1 from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('Fleminginkatu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"Fleminginkatu","CLASS":"nimisana","FSTOUTPUT":"[Les][Xp]Fleming[X]fleming[Sg][Ny]in[Bc][Ln][Ica][Xp]katu[X]katu[Sn][Ny]","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=ipppppppp=pppp","WORDBASES":"+flemingin(Fleming)+katu(katu)"}'::jsonb,
      'fleminginkatu', 'fleminginkatu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Fleminginkatu (a street in Helsinki)', 'Fleminginkatu (a street in Helsinki)', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-cf9bd58ca9a4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'fleminginkatu', 'Fleminginkatu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Fleminginkatu (a street in Helsinki)', 'Fleminginkatu (a street in Helsinki)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'fleminginkatu', 'Fleminginkatu',
      (select form_name_en from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu'),
      (select why_en from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu'),
      (select meaning_en from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu'),
      (select lemma_meaning_en from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Fleminginkatu (a street in Helsinki)', 'Fleminginkatu (a street in Helsinki)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viisi', 'viis',
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-56e27afb5a19');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viisi', 'viisi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viisi', 'viisi',
      (select form_name_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select why_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select lemma_meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksitoista', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksitoista","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]toista[Xp][X]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+kaksitoista"}'::jsonb,
      'kaksitoista', 'kakstoist',
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-b32a414e973b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksitoista', 'kaksitoista';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksitoista', 'kaksitoista',
      (select form_name_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select why_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select meaning_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitos',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-c5b0481eae2b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kortti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kortti[X]kortt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kortti(kortti)"}'::jsonb,
      'kortti', 'kortti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'card', 'card', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-ed5808777e7d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kortti', 'kortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'card', 'card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kortti', 'kortti',
      (select form_name_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti'),
      (select why_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti'),
      (select meaning_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti'),
      (select lemma_meaning_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'card', 'card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilmainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ilmainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]ilmainen[X]ilmai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+ilmainen(ilmainen)"}'::jsonb,
      'ilmainen', 'ilmanen',
      'nominative singular', 'Speech drops the i in the middle: ilmainen becomes ilmanen. Books write ilmainen.', 'free', 'free (no cost)', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-9c6f920944c6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ilmainen', 'ilmainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the i in the middle: ilmainen becomes ilmanen. Books write ilmainen.', 'free', 'free (no cost)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ilmainen', 'ilmainen',
      (select form_name_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen'),
      (select why_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen'),
      (select meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen'),
      (select lemma_meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen'),
      'nominative singular', 'Speech drops the i in the middle: ilmainen becomes ilmanen. Books write ilmainen.', 'free', 'free (no cost)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keksiä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"keksiä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]keksiä[X]keksi[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+keksiä(keksiä)"}'::jsonb,
      'keksi', 'keksi',
      'imperative present tense, 2nd person singular', 'Keksiä, to come up with. To tell one person to do it, drop the ending: keksi.', 'make up, choose', 'to come up with, to invent', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-6179766b58d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keksi', 'keksiä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Keksiä, to come up with. To tell one person to do it, drop the ending: keksi.', 'make up, choose', 'to come up with, to invent')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keksi', 'keksiä',
      (select form_name_en from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi'),
      (select why_en from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi'),
      (select meaning_en from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi'),
      (select lemma_meaning_en from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi'),
      'imperative present tense, 2nd person singular', 'Keksiä, to come up with. To tell one person to do it, drop the ending: keksi.', 'make up, choose', 'to come up with, to invent';
  end if;
  if not exists (select 1 from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('PIN-koodi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"PIN-koodi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xr]iii-=[X][Xp]PIN-koodi[X]pin-kood[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=iii-=ppppp","WORDBASES":"+PIN-koodi(PIN-koodi)"}'::jsonb,
      'pin-koodi', 'pin-koodi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'PIN code', 'PIN code', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-37802d38b417');
  end if;
  if not exists (select 1 from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pin-koodi', 'PIN-koodi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'PIN code', 'PIN code')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pin-koodi', 'PIN-koodi',
      (select form_name_en from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi'),
      (select why_en from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi'),
      (select meaning_en from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi'),
      (select lemma_meaning_en from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'PIN code', 'PIN code';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('moni', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true', '{"BASEFORM":"moni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]moni[X]mon[Sp][Ny]ta[Fko][Ef]ko","KYSYMYSLIITE":"true","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+moni(moni)"}'::jsonb,
      'montako', 'montaks',
      'partitive singular, with the question ending -ko/-kö', 'Monta means many. The question ending -ko makes ''how many?''. Speech says montaks.', 'how many', 'many', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-99fdf340c0b8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'montako', 'moni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular, with the question ending -ko/-kö', 'Monta means many. The question ending -ko makes ''how many?''. Speech says montaks.', 'how many', 'many')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'montako', 'moni',
      (select form_name_en from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks'),
      (select why_en from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks'),
      (select meaning_en from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks'),
      (select lemma_meaning_en from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks'),
      'partitive singular, with the question ending -ko/-kö', 'Monta means many. The question ending -ko makes ''how many?''. Speech says montaks.', 'how many', 'many';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirja', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kirja","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kirja[X]kirj[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kirja(kirja)"}'::jsonb,
      'kirjaa', 'kirjaa',
      'partitive singular', 'After montako, ''how many'', the word takes -a: kirja becomes kirjaa.', 'books', 'book', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-77a95c802b63');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjaa', 'kirja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After montako, ''how many'', the word takes -a: kirja becomes kirjaa.', 'books', 'book')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjaa', 'kirja',
      (select form_name_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa'),
      (select why_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa'),
      (select meaning_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa'),
      'partitive singular', 'After montako, ''how many'', the word takes -a: kirja becomes kirjaa.', 'books', 'book';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voin', 'voin',
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-1932b7fb8d7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voin', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voin', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lainata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"lainata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lainata[X]lainat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+lainata(lainata)"}'::jsonb,
      'lainata', 'lainata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to lend, to borrow', 'to lend, to borrow', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-fe7b62a4d4c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lainata', 'lainata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to lend, to borrow', 'to lend, to borrow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lainata', 'lainata',
      (select form_name_en from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata'),
      (select why_en from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata'),
      (select meaning_en from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata'),
      (select lemma_meaning_en from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to lend, to borrow', 'to lend, to borrow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikka', 'CLASS=sidesana', '{"BASEFORM":"vaikka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vaikka[X]vaikka","STRUCTURE":"=pppppp","WORDBASES":"+vaikka(vaikka)"}'::jsonb,
      'vaikka', 'vaikka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-db8570c5aa75');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaikka', 'vaikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaikka', 'vaikka',
      (select form_name_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select why_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select meaning_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select lemma_meaning_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisikymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viisikymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sn][Ny]si[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viisikymmentä', 'viiskyt',
      'nominative singular', 'This is the dictionary form. Speech shortens viisikymmentä to viiskyt.', 'fifty', 'fifty', 'approved', now(), 'content/approvals/part-5.json#a-library-card/form-ee0c11939a1e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viisikymmentä', 'viisikymmentä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. Speech shortens viisikymmentä to viiskyt.', 'fifty', 'fifty')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viisikymmentä', 'viisikymmentä',
      (select form_name_en from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt'),
      (select why_en from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt'),
      (select meaning_en from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt'),
      (select lemma_meaning_en from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt'),
      'nominative singular', 'This is the dictionary form. Speech shortens viisikymmentä to viiskyt.', 'fifty', 'fifty';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä haluisin kirjastokortin.',
    'Hei! Minä haluaisin kirjastokortin.', 'Hi! I''d like a library card.',
    'a-library-card/1-puhe-c5dc7b7c33f2.mp3', 'a-library-card/1-kirja-24e647e5286c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluaisin', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin')),
    (v_line_id, 'kirja', 4, 'kirjastokortin', (select id from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluisin', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin')),
    (v_line_id, 'puhe', 4, 'kirjastokortin', (select id from public.forms where lemma = 'kirjastokortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirjastokortin' and surface_puhe = 'kirjastokortin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Outi', 'Totta kai. Onks sul henkilökortti?',
    'Totta kai. Onko sinulla henkilökortti?', 'Of course. Do you have an ID card?',
    'a-library-card/2-puhe-71733589e473.mp3', 'a-library-card/2-kirja-5edc75f614b2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 4, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 5, 'henkilökortti', (select id from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 4, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 5, 'henkilökortti', (select id from public.forms where lemma = 'henkilökortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'henkilökortti' and surface_puhe = 'henkilökortti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Mul on oleskelulupakortti. Käyks se?',
    'Minulla on oleskelulupakortti. Käykö se?', 'I have a residence permit card. Will that do?',
    'a-library-card/3-puhe-6061f31a83fd.mp3', 'a-library-card/3-kirja-fb837b6ae61b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'oleskelulupakortti', (select id from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti')),
    (v_line_id, 'kirja', 4, 'Käykö', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks')),
    (v_line_id, 'kirja', 5, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'oleskelulupakortti', (select id from public.forms where lemma = 'oleskelulupakortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupakortti' and surface_puhe = 'oleskelulupakortti')),
    (v_line_id, 'puhe', 4, 'Käyks', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks')),
    (v_line_id, 'puhe', 5, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Outi', 'Käy hyvin. Ja tarvitaan sun osote.',
    'Käy hyvin. Ja tarvitaan sinun osoitteesi.', 'That''s fine. And we need your address.',
    'a-library-card/4-puhe-5a18d7821b8f.mp3', 'a-library-card/4-kirja-1b32a6f70369.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'kirja', 2, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'tarvitaan', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan')),
    (v_line_id, 'kirja', 5, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 6, 'osoitteesi', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote')),
    (v_line_id, 'puhe', 1, 'Käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'puhe', 2, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'tarvitaan', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan')),
    (v_line_id, 'puhe', 5, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 6, 'osote', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'osoitteesi' and surface_puhe = 'osote'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Fleminginkatu viis A kakstoist.',
    'Fleminginkatu viisi A kaksitoista.', 'Fleminginkatu 5 A 12.',
    'a-library-card/5-puhe-7bbe2a68857d.mp3', 'a-library-card/5-kirja-40b7c725ac0a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Fleminginkatu', (select id from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu')),
    (v_line_id, 'kirja', 2, 'viisi', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'kirja', 3, 'A', null),
    (v_line_id, 'kirja', 4, 'kaksitoista', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'puhe', 1, 'Fleminginkatu', (select id from public.forms where lemma = 'Fleminginkatu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'fleminginkatu' and surface_puhe = 'fleminginkatu')),
    (v_line_id, 'puhe', 2, 'viis', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'puhe', 3, 'A', null),
    (v_line_id, 'puhe', 4, 'kakstoist', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Outi', 'Kiitos. Kortti on ilmanen. Keksi PIN-koodi.',
    'Kiitos. Kortti on ilmainen. Keksi PIN-koodi.', 'Thank you. The card is free. Choose a PIN code.',
    'a-library-card/6-puhe-566a24dc528b.mp3', 'a-library-card/6-kirja-79c7a6efe440.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'kirja', 2, 'Kortti', (select id from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'ilmainen', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen')),
    (v_line_id, 'kirja', 5, 'Keksi', (select id from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi')),
    (v_line_id, 'kirja', 6, 'PIN-koodi', (select id from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi')),
    (v_line_id, 'puhe', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 2, 'Kortti', (select id from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kortti' and surface_puhe = 'kortti')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'ilmanen', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmainen' and surface_puhe = 'ilmanen')),
    (v_line_id, 'puhe', 5, 'Keksi', (select id from public.forms where lemma = 'keksiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keksi' and surface_puhe = 'keksi')),
    (v_line_id, 'puhe', 6, 'PIN-koodi', (select id from public.forms where lemma = 'PIN-koodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pin-koodi' and surface_puhe = 'pin-koodi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Okei. Montaks kirjaa mä voin lainata?',
    'Selvä. Montako kirjaa minä voin lainata?', 'OK. How many books can I borrow?',
    'a-library-card/7-puhe-69686700eab9.mp3', 'a-library-card/7-kirja-9b1098bc86f2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Montako', (select id from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks')),
    (v_line_id, 'kirja', 3, 'kirjaa', (select id from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa')),
    (v_line_id, 'kirja', 4, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 5, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'kirja', 6, 'lainata', (select id from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Montaks', (select id from public.forms where lemma = 'moni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular;KYSYMYSLIITE=true' and surface_kirja = 'montako' and surface_puhe = 'montaks')),
    (v_line_id, 'puhe', 3, 'kirjaa', (select id from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kirjaa' and surface_puhe = 'kirjaa')),
    (v_line_id, 'puhe', 4, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 5, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'puhe', 6, 'lainata', (select id from public.forms where lemma = 'lainata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lainata' and surface_puhe = 'lainata'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Outi', 'Vaikka viiskyt!',
    'Vaikka viisikymmentä!', 'Up to fifty!',
    'a-library-card/8-puhe-502bf7064748.mp3', 'a-library-card/8-kirja-559ed029e0bc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vaikka', (select id from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka')),
    (v_line_id, 'kirja', 2, 'viisikymmentä', (select id from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt')),
    (v_line_id, 'puhe', 1, 'Vaikka', (select id from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka')),
    (v_line_id, 'puhe', 2, 'viiskyt', (select id from public.forms where lemma = 'viisikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisikymmentä' and surface_puhe = 'viiskyt'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-library-card/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
