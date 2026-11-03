-- Publishes the dialogue a-parcel-for-the-neighbour (unit collecting-a-parcel). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-parcel-for-the-neighbour. Do not edit by hand:
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
    where slug = 'a-parcel-for-the-neighbour' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-parcel-for-the-neighbour';
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
  values (v_unit_id, 'a-parcel-for-the-neighbour', 2,
    'A parcel for the neighbour')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-parcel-for-the-neighbour' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'A parcel for the neighbour';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-parcel-for-the-neighbour';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-4352ca83b810');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tämä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tämä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asunto', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"asunto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asunto[X]asunto[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+asunto(asunto)"}'::jsonb,
      'asunto', 'asunto',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-31b82be4b373');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asunto', 'asunto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asunto', 'asunto',
      (select form_name_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select why_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select lemma_meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"asua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]asua[X]asuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+asua(asua)"}'::jsonb,
      'asuu', 'asuu',
      'present tense, 3rd person singular', 'Asua ''to live'' doubles its last vowel for ''she'': hän asuu. People say it the same way.', 'lives', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-3b0456f9c731');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asuu', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Asua ''to live'' doubles its last vowel for ''she'': hän asuu. People say it the same way.', 'lives', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asuu', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu'),
      'present tense, 3rd person singular', 'Asua ''to live'' doubles its last vowel for ''she'': hän asuu. People say it the same way.', 'lives', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viereinen', 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"viereinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]viereinen[X]viereise[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppppp","WORDBASES":"+viereinen(viereinen)"}'::jsonb,
      'viereisessä', 'viereisessä',
      'inessive singular', 'Adds -ssä to match asunnossa: viereinen becomes viereisessä, the n turning to s.', 'next-door', 'next-door, adjacent', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-ec6938c0f8a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viereisessä', 'viereinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssä to match asunnossa: viereinen becomes viereisessä, the n turning to s.', 'next-door', 'next-door, adjacent')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viereisessä', 'viereinen',
      (select form_name_en from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä'),
      (select why_en from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä'),
      (select meaning_en from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä'),
      (select lemma_meaning_en from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä'),
      'inessive singular', 'Adds -ssä to match asunnossa: viereinen becomes viereisessä, the n turning to s.', 'next-door', 'next-door, adjacent';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asunto', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"asunto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asunto[X]asunno[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppp","WORDBASES":"+asunto(asunto)"}'::jsonb,
      'asunnossa', 'asunnossa',
      'inessive singular', 'Adds -ssa for ''in'': asunto becomes asunnossa, nt turning to nn.', 'in the flat', 'flat, apartment', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-7b4b48af12c4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asunnossa', 'asunto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': asunto becomes asunnossa, nt turning to nn.', 'in the flat', 'flat, apartment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asunnossa', 'asunto',
      (select form_name_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa'),
      (select why_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa'),
      (select meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa'),
      (select lemma_meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa'),
      'inessive singular', 'Adds -ssa for ''in'': asunto becomes asunnossa, nt turning to nn.', 'in the flat', 'flat, apartment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"olla","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'ole', 'oo',
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-0fcdf4079f8d');
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
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koti', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"koti","CLASS":"nimisana","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"olento"}'::jsonb,
      'kotona', 'kotona',
      'essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-6623d0c4b9e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kotona', 'koti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kotona', 'koti',
      (select form_name_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select why_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select lemma_meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      'essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voitko', 'voit',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-90c207b76ecc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voitko', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voitko', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]otta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ottaa', 'ottaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to take', 'to take', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-0bb2d5b32826');
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
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paketti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"paketti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]paketti[X]paket[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+paketti(paketti)"}'::jsonb,
      'paketin', 'paketin',
      'genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-e7e5785f8270');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paketin', 'paketti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paketin', 'paketti',
      (select form_name_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select why_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select lemma_meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      'genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-b20bd263b5ae');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-b1285c45ffe6');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirjoittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kirjoittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kirjoittaa[X]kirjoita[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+kirjoittaa(kirjoittaa)"}'::jsonb,
      'kirjoita', 'kirjota',
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-bdca70f64fa7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjoita', 'kirjoittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjoita', 'kirjoittaa',
      (select form_name_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select why_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select lemma_meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nimi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"nimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ivj][Xp]nimi[X]nim[Sn][Ny]e[O2y]si","MALAGA_VAPAA_JALKIOSA":"true","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+nimi(nimi)"}'::jsonb,
      'nimesi', 'nimi',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-62b10330a9a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nimesi', 'nimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nimesi', 'nimi',
      (select form_name_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select why_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select lemma_meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sill][Ny]hän","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tähän', 'tähän',
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-3cb39a24ba50');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tähän', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tähän', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('painava', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active', '{"BASEFORM":"painava","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]painaa[X]paina[Ll][Rv]v[Xj]a[X][Sn][Ny]a","NUMBER":"singular","PARTICIPLE":"present_active","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+paina(painaa)+v+a(+a)"}'::jsonb,
      'painava', 'painava',
      'present active participle, nominative singular', 'Painava means ''heavy'', from painaa ''to weigh''. People say it the same way.', 'heavy', 'heavy', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-b3ca6213963b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'painava', 'painava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present active participle, nominative singular', 'Painava means ''heavy'', from painaa ''to weigh''. People say it the same way.', 'heavy', 'heavy')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'painava', 'painava',
      (select form_name_en from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava'),
      (select why_en from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava'),
      (select meaning_en from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava'),
      (select lemma_meaning_en from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava'),
      'present active participle, nominative singular', 'Painava means ''heavy'', from painaa ''to weigh''. People say it the same way.', 'heavy', 'heavy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-008b8a3eae32');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vähän', 'vähän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vähän', 'vähän',
      (select form_name_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select why_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select lemma_meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sine][Ny]iinä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+se(se)"}'::jsonb,
      'siinä', 'siin',
      'inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-68a39070d239');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siinä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siinä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      'inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirja', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"kirja","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kirja[X]kirj[Sp][Nm]oja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+kirja(kirja)"}'::jsonb,
      'kirjoja', 'kirjoja',
      'partitive plural', 'The partitive plural is used for some books: kirja becomes kirjoja.', 'books', 'book', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-53ae688ef426');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjoja', 'kirja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive plural is used for some books: kirja becomes kirjoja.', 'books', 'book')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjoja', 'kirja',
      (select form_name_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja'),
      (select why_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja'),
      (select meaning_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja'),
      (select lemma_meaning_en from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja'),
      'partitive plural', 'The partitive plural is used for some books: kirja becomes kirjoja.', 'books', 'book';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hätä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"hätä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hätä[X]hät[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hätä(hätä)"}'::jsonb,
      'hätää', 'hätää',
      'partitive singular', 'The partitive after ei: ei hätää, no worries.', 'worries', 'emergency, worry', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-83955fefc056');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('antaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"antaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]antaa[X]anna[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+antaa(antaa)"}'::jsonb,
      'annan', 'annan',
      'present tense, 1st person singular', 'Adds -n for ''I'': antaa becomes annan, nt turning to nn.', 'I give', 'to give', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-d84109680f7c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'annan', 'antaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': antaa becomes annan, nt turning to nn.', 'I give', 'to give')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'annan', 'antaa',
      (select form_name_en from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan'),
      (select why_en from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan'),
      (select meaning_en from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan'),
      (select lemma_meaning_en from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan'),
      'present tense, 1st person singular', 'Adds -n for ''I'': antaa becomes annan, nt turning to nn.', 'I give', 'to give';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-1bca14269daf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sen', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sen', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-3.json#a-parcel-for-the-neighbour/form-73c5475313cb');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Mikael', 'Moi! Onks tää Leena Virtasen asunto?',
    'Hei! Onko tämä Leena Virtasen asunto?', 'Hi! Is this Leena Virtanen''s flat?',
    'a-parcel-for-the-neighbour/1-puhe-2bb523f0c99b.mp3', 'a-parcel-for-the-neighbour/1-kirja-76b5702ebe80.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 4, 'Leena', null),
    (v_line_id, 'kirja', 5, 'Virtasen', null),
    (v_line_id, 'kirja', 6, 'asunto', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 4, 'Leena', null),
    (v_line_id, 'puhe', 5, 'Virtasen', null),
    (v_line_id, 'puhe', 6, 'asunto', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Ei, se asuu viereisessä asunnossa.',
    'Ei, hän asuu viereisessä asunnossa.', 'No, she lives in the flat next door.',
    'a-parcel-for-the-neighbour/2-puhe-42ef78de7572.mp3', 'a-parcel-for-the-neighbour/2-kirja-71803ddcacf4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'asuu', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu')),
    (v_line_id, 'kirja', 4, 'viereisessä', (select id from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä')),
    (v_line_id, 'kirja', 5, 'asunnossa', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'asuu', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuu' and surface_puhe = 'asuu')),
    (v_line_id, 'puhe', 4, 'viereisessä', (select id from public.forms where lemma = 'viereinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viereisessä' and surface_puhe = 'viereisessä')),
    (v_line_id, 'puhe', 5, 'asunnossa', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asunnossa' and surface_puhe = 'asunnossa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Mikael', 'Se ei oo kotona. Voitsä ottaa paketin?',
    'Hän ei ole kotona. Voitko sinä ottaa paketin?', 'She''s not home. Could you take the parcel?',
    'a-parcel-for-the-neighbour/3-puhe-7453afac3633.mp3', 'a-parcel-for-the-neighbour/3-kirja-1ab58954dcc5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'kirja', 4, 'kotona', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona')),
    (v_line_id, 'kirja', 5, 'Voitko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 7, 'ottaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa')),
    (v_line_id, 'kirja', 8, 'paketin', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'oo', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'puhe', 4, 'kotona', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona')),
    (v_line_id, 'puhe', 5, 'Voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 7, 'ottaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ottaa' and surface_puhe = 'ottaa')),
    (v_line_id, 'puhe', 8, 'paketin', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo, totta kai.',
    'Kyllä, totta kai.', 'Yes, of course.',
    'a-parcel-for-the-neighbour/4-puhe-7514a9392511.mp3', 'a-parcel-for-the-neighbour/4-kirja-8ecfe346263c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 3, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 3, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Mikael', 'Kiitti. Kirjota sun nimi tähän.',
    'Kiitos. Kirjoita sinun nimesi tähän.', 'Thanks. Write your name here.',
    'a-parcel-for-the-neighbour/5-puhe-c5079b477fe9.mp3', 'a-parcel-for-the-neighbour/5-kirja-4a3c68769b40.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Kirjoita', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'kirja', 3, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 4, 'nimesi', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi')),
    (v_line_id, 'kirja', 5, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Kirjota', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'puhe', 3, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 4, 'nimi', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi')),
    (v_line_id, 'puhe', 5, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Okei. Onks se painava?',
    'Selvä. Onko se painava?', 'OK. Is it heavy?',
    'a-parcel-for-the-neighbour/6-puhe-ed10b76c3224.mp3', 'a-parcel-for-the-neighbour/6-kirja-eb7c2c0efeea.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'painava', (select id from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'painava', (select id from public.forms where lemma = 'painava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'painava' and surface_puhe = 'painava'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Mikael', 'Vähän. Siin on kirjoja.',
    'Vähän. Siinä on kirjoja.', 'A little. There are books in it.',
    'a-parcel-for-the-neighbour/7-puhe-c1d95ba8fdcb.mp3', 'a-parcel-for-the-neighbour/7-kirja-83bfad03d5c7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 2, 'Siinä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kirjoja', (select id from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja')),
    (v_line_id, 'puhe', 1, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 2, 'Siin', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kirjoja', (select id from public.forms where lemma = 'kirja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kirjoja' and surface_puhe = 'kirjoja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Ei hätää. Mä annan sen Leenalle illal.',
    'Ei hätää. Minä annan sen Leenalle illalla.', 'No worries. I''ll give it to Leena this evening.',
    'a-parcel-for-the-neighbour/8-puhe-94f1c75ad660.mp3', 'a-parcel-for-the-neighbour/8-kirja-c86643ec02d1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'annan', (select id from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan')),
    (v_line_id, 'kirja', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 6, 'Leenalle', null),
    (v_line_id, 'kirja', 7, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'annan', (select id from public.forms where lemma = 'antaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'annan' and surface_puhe = 'annan')),
    (v_line_id, 'puhe', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 6, 'Leenalle', null),
    (v_line_id, 'puhe', 7, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-parcel-for-the-neighbour/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
