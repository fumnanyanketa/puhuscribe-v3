-- Publishes the dialogue todays-lunch (unit lunch-out). Made by
-- scripts/generate/pipeline.py publish from content/drafts/todays-lunch. Do not edit by hand:
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
    where slug = 'todays-lunch' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'todays-lunch';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 17
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'lunch-out' and position = 17 and stop_number = 17;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'lunch-out';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'todays-lunch', 1,
    'Today''s lunch')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'todays-lunch' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Today''s lunch';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'todays-lunch';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tietää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tietää[X]tiedä[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+tietää(tietää)"}'::jsonb,
      'tiedätkö', 'tiiät',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-4b6766e4afb5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiedätkö', 'tietää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiedätkö', 'tietää',
      (select form_name_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select why_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select lemma_meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jo', 'CLASS=seikkasana', '{"BASEFORM":"jo","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]jo[X]jo","STRUCTURE":"=pp","WORDBASES":"+jo(jo)"}'::jsonb,
      'jo', 'jo',
      'adverb', 'This is the dictionary form. People say it the same way.', 'already', 'already', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-31092ec721a1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jo', 'jo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'already', 'already')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jo', 'jo',
      (select form_name_en from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo'),
      (select why_en from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo'),
      (select meaning_en from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo'),
      (select lemma_meaning_en from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'already', 'already';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluat', 'haluut',
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-5d3db9de3844');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluat', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluat', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sg][Ny]än","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivän', 'päivän',
      'genitive singular', 'The genitive singular adds -n for ''of'': päivä becomes päivän, ''of the day''.', 'the day''s (today''s)', 'day', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-9b916a54b1b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivän', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular adds -n for ''of'': päivä becomes päivän, ''of the day''.', 'the day''s (today''s)', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivän', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän'),
      'genitive singular', 'The genitive singular adds -n for ''of'': päivä becomes päivän, ''of the day''.', 'the day''s (today''s)', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lounas', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lounas","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]lounas[X]louna[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+lounas(lounas)"}'::jsonb,
      'lounas', 'lounas',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch', 'lunch', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-beae80faab43');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lounas', 'lounas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch', 'lunch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lounas', 'lounas',
      (select form_name_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'),
      (select why_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'),
      (select meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'),
      (select lemma_meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch', 'lunch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lohikeitto', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lohikeitto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lohi[X]loh[Sn][Ny]i[Bh][Bc][Ln][Xp]keitto[X]keitto[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp=ppppppp","WORDBASES":"+lohi(lohi)+keitto(keitto)"}'::jsonb,
      'lohikeittoa', 'lohikeittoo',
      'partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-03111121e507');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lohikeittoa', 'lohikeitto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lohikeittoa', 'lohikeitto',
      (select form_name_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select why_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select lemma_meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      'partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tai', 'CLASS=sidesana', '{"BASEFORM":"tai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]tai[X]tai","STRUCTURE":"=ppp","WORDBASES":"+tai(tai)"}'::jsonb,
      'tai', 'tai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-e626f185f947');
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
  if not exists (select 1 from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanapasta', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kanapasta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kana[X]kan[Sn][Ny]a[Bh][Bc][Ln][Xp]pasta[X]past[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp=pppppp","WORDBASES":"+kana(kana)+pasta(pasta)"}'::jsonb,
      'kanapastaa', 'kanapastaa',
      'partitive singular', 'The partitive singular is used for some pasta: kanapasta becomes kanapastaa.', 'chicken pasta', 'chicken pasta', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-b3a539afd315');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kanapastaa', 'kanapasta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some pasta: kanapasta becomes kanapastaa.', 'chicken pasta', 'chicken pasta')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kanapastaa', 'kanapasta',
      (select form_name_en from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa'),
      (select why_en from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa'),
      (select meaning_en from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa'),
      'partitive singular', 'The partitive singular is used for some pasta: kanapasta becomes kanapastaa.', 'chicken pasta', 'chicken pasta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]otta[Te][Ap][P1][Ny][Ef]isin","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ottaisin', 'ottaisin',
      'conditional present tense, 1st person singular', 'The conditional adds -isi for ''would'': ottaa becomes ottaisin, ''I would take''.', 'I''d have (take)', 'to take', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-0b7e1458e3ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ottaisin', 'ottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular', 'The conditional adds -isi for ''would'': ottaa becomes ottaisin, ''I would take''.', 'I''d have (take)', 'to take')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ottaisin', 'ottaa',
      (select form_name_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin'),
      (select why_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin'),
      (select meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin'),
      (select lemma_meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin'),
      'conditional present tense, 1st person singular', 'The conditional adds -isi for ''would'': ottaa becomes ottaisin, ''I would take''.', 'I''d have (take)', 'to take';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lohikeitto', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"lohikeitto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lohi[X]loh[Sn][Ny]i[Bh][Bc][Ln][Xp]keitto[X]keito[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp=pppppp","WORDBASES":"+lohi(lohi)+keitto(keitto)"}'::jsonb,
      'lohikeiton', 'lohikeiton',
      'genitive singular', 'As the whole thing you order, lohikeitto takes -n: lohikeiton, tt turning to t.', 'the salmon soup', 'salmon soup', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-851b0b9dc383');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lohikeiton', 'lohikeitto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you order, lohikeitto takes -n: lohikeiton, tt turning to t.', 'the salmon soup', 'salmon soup')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lohikeiton', 'lohikeitto',
      (select form_name_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton'),
      (select why_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton'),
      (select meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton'),
      (select lemma_meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton'),
      'genitive singular', 'As the whole thing you order, lohikeitto takes -n: lohikeiton, tt turning to t.', 'the salmon soup', 'salmon soup';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-ed646e1f1923');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvä', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvä', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('valinta', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"valinta","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]valita[X]vali[Ln]n[Xj]ta[X]t[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+vali(valita)+n+ta(+ta)"}'::jsonb,
      'valinta', 'valinta',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'choice', 'choice', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-37c6a3c3431d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'valinta', 'valinta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'choice', 'choice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'valinta', 'valinta',
      (select form_name_en from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta'),
      (select why_en from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta'),
      (select meaning_en from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta'),
      (select lemma_meaning_en from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'choice', 'choice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('leipä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"leipä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]leipä[X]leip[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+leipä(leipä)"}'::jsonb,
      'leipä', 'leipä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bread', 'bread', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-f2ed9620047e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'leipä', 'leipä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'bread', 'bread')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'leipä', 'leipä',
      (select form_name_en from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä'),
      (select why_en from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä'),
      (select meaning_en from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä'),
      (select lemma_meaning_en from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bread', 'bread';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('salaatti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"salaatti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]salaatti[X]salaatt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+salaatti(salaatti)"}'::jsonb,
      'salaatti', 'salaatti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'salad', 'salad', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-296ba57bddef');
  end if;
  if not exists (select 1 from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'salaatti', 'salaatti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'salad', 'salad')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'salaatti', 'salaatti',
      (select form_name_en from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti'),
      (select why_en from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti'),
      (select meaning_en from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti'),
      (select lemma_meaning_en from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'salad', 'salad';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-4ab061b662f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ovat', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ovat', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuolla', 'tuolla',
      'adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-38dbd7729054');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuolla', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuolla', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      'adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pöytä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"pöytä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pöytä[X]pöydä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+pöytä(pöytä)"}'::jsonb,
      'pöydällä', 'pöydällä',
      'adessive singular', 'Adds -llä for ''on'': pöytä becomes pöydällä, the t turning to d.', 'on the table', 'table', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-af34b1e25047');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pöydällä', 'pöytä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''on'': pöytä becomes pöydällä, the t turning to d.', 'on the table', 'table')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pöydällä', 'pöytä',
      (select form_name_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä'),
      (select why_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä'),
      (select meaning_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä'),
      (select lemma_meaning_en from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä'),
      'adessive singular', 'Adds -llä for ''on'': pöytä becomes pöydällä, the t turning to d.', 'on the table', 'table';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]sa[Te][Ap][P1][Ny][Ef]isin[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saisinko', 'saisinks',
      'conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-624bde3d668d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saisinko', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saisinko', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      'conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-fe354724e29a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myös', 'myös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myös', 'myös',
      (select form_name_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select why_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select lemma_meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sp][Ny]ttä","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vettä', 'vettä',
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-18de4322e3a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vettä', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vettä', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sn][Ny]si","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vesi', 'vesi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-2738734d9176');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vesi', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vesi', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilmainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ilmainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]ilmainen[X]ilmai[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+ilmainen(ilmainen)"}'::jsonb,
      'ilmaista', 'ilmasta',
      'partitive singular', 'The partitive singular after vesi ''water'': ilmainen becomes ilmaista. Speech says ilmasta.', 'free', 'free (no cost)', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-e8c921add616');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ilmaista', 'ilmainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular after vesi ''water'': ilmainen becomes ilmaista. Speech says ilmasta.', 'free', 'free (no cost)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ilmaista', 'ilmainen',
      (select form_name_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta'),
      (select why_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta'),
      (select meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta'),
      (select lemma_meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta'),
      'partitive singular', 'The partitive singular after vesi ''water'': ilmainen becomes ilmaista. Speech says ilmasta.', 'free', 'free (no cost)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]ota[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ota', 'ota',
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-e8d98fab6fcd');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuosta', 'tosta',
      'elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-ee758ee6468a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuosta', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuosta', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      'elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kannu', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"kannu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kannu[X]kannu[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kannu(kannu)"}'::jsonb,
      'kannusta', 'kannusta',
      'elative singular', 'Kannu, jug, with -sta for ''from'': kannusta.', 'from the jug', 'jug', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-996853a538b4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kannusta', 'kannu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Kannu, jug, with -sta for ''from'': kannusta.', 'from the jug', 'jug')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kannusta', 'kannu',
      (select form_name_en from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta'),
      (select why_en from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta'),
      (select meaning_en from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta'),
      (select lemma_meaning_en from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta'),
      'elative singular', 'Kannu, jug, with -sta for ''from'': kannusta.', 'from the jug', 'jug';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihana', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ihana","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]ihana[X]ihan[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ihana(ihana)"}'::jsonb,
      'ihanaa', 'ihanaa',
      'partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful', 'approved', now(), 'content/approvals/part-3.json#todays-lunch/form-bbaeb136ed47');
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
  values (v_dialogue_id, 1, 'Mari', 'Moi! Tiiätsä jo, mitä sä haluut?',
    'Hei! Tiedätkö sinä jo, mitä sinä haluat?', 'Hi! Do you know what you''d like?',
    'todays-lunch/1-puhe-86328907b05f.mp3', 'todays-lunch/1-kirja-7776399c328b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Tiedätkö', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'kirja', 5, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 7, 'haluat', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Tiiät', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'puhe', 5, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 7, 'haluut', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mikä on päivän lounas?',
    'Mikä on päivän lounas?', 'What''s today''s lunch?',
    'todays-lunch/2-puhe-bdb51ee26817.mp3', 'todays-lunch/2-kirja-f6dee3e61aef.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'päivän', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän')),
    (v_line_id, 'kirja', 4, 'lounas', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas')),
    (v_line_id, 'puhe', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'päivän', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'päivän' and surface_puhe = 'päivän')),
    (v_line_id, 'puhe', 4, 'lounas', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Mari', 'Lohikeittoo tai kanapastaa.',
    'Lohikeittoa tai kanapastaa.', 'Salmon soup or chicken pasta.',
    'todays-lunch/3-puhe-b958d462679e.mp3', 'todays-lunch/3-kirja-00c96c586572.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lohikeittoa', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo')),
    (v_line_id, 'kirja', 2, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'kirja', 3, 'kanapastaa', (select id from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa')),
    (v_line_id, 'puhe', 1, 'Lohikeittoo', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo')),
    (v_line_id, 'puhe', 2, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'puhe', 3, 'kanapastaa', (select id from public.forms where lemma = 'kanapasta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kanapastaa' and surface_puhe = 'kanapastaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mä ottaisin lohikeiton.',
    'Minä ottaisin lohikeiton.', 'I''d have the salmon soup.',
    'todays-lunch/4-puhe-859d8e49fac5.mp3', 'todays-lunch/4-kirja-ab7ef179dbe2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'ottaisin', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin')),
    (v_line_id, 'kirja', 3, 'lohikeiton', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'ottaisin', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottaisin' and surface_puhe = 'ottaisin')),
    (v_line_id, 'puhe', 3, 'lohikeiton', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lohikeiton' and surface_puhe = 'lohikeiton'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Mari', 'Hyvä valinta. Leipä ja salaatti on tuolla pöydällä.',
    'Hyvä valinta. Leipä ja salaatti ovat tuolla pöydällä.', 'Good choice. Bread and salad are on that table.',
    'todays-lunch/5-puhe-52a821c0834f.mp3', 'todays-lunch/5-kirja-730bac35a2da.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'valinta', (select id from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta')),
    (v_line_id, 'kirja', 3, 'Leipä', (select id from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'salaatti', (select id from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti')),
    (v_line_id, 'kirja', 6, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 7, 'tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'kirja', 8, 'pöydällä', (select id from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'valinta', (select id from public.forms where lemma = 'valinta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'valinta' and surface_puhe = 'valinta')),
    (v_line_id, 'puhe', 3, 'Leipä', (select id from public.forms where lemma = 'leipä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'leipä' and surface_puhe = 'leipä')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'salaatti', (select id from public.forms where lemma = 'salaatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'salaatti' and surface_puhe = 'salaatti')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 7, 'tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'puhe', 8, 'pöydällä', (select id from public.forms where lemma = 'pöytä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pöydällä' and surface_puhe = 'pöydällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kiitti. Saisinks mä myös vettä?',
    'Kiitos. Saisinko minä myös vettä?', 'Thanks. Could I also have some water?',
    'todays-lunch/6-puhe-1138dc11ff5b.mp3', 'todays-lunch/6-kirja-08a109779991.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Saisinko', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 5, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Saisinks', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 5, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Mari', 'Vesi on ilmasta. Ota tosta kannusta.',
    'Vesi on ilmaista. Ota tuosta kannusta.', 'Water is free. Take it from that jug.',
    'todays-lunch/7-puhe-7f8caf75e543.mp3', 'todays-lunch/7-kirja-ca5c07bca58e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'ilmaista', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta')),
    (v_line_id, 'kirja', 4, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'kirja', 5, 'tuosta', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta')),
    (v_line_id, 'kirja', 6, 'kannusta', (select id from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta')),
    (v_line_id, 'puhe', 1, 'Vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'ilmasta', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ilmaista' and surface_puhe = 'ilmasta')),
    (v_line_id, 'puhe', 4, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'puhe', 5, 'tosta', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta')),
    (v_line_id, 'puhe', 6, 'kannusta', (select id from public.forms where lemma = 'kannu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kannusta' and surface_puhe = 'kannusta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Ihanaa. Kiitti!',
    'Ihanaa. Kiitos!', 'Lovely. Thanks!',
    'todays-lunch/8-puhe-225900da43c0.mp3', 'todays-lunch/8-kirja-1d7796a40411.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa')),
    (v_line_id, 'kirja', 2, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 1, 'Ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa')),
    (v_line_id, 'puhe', 2, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#todays-lunch/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
