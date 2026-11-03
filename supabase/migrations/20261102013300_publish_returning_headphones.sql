-- Publishes the dialogue returning-headphones (unit problems-and-returns). Made by
-- scripts/generate/pipeline.py publish from content/drafts/returning-headphones. Do not edit by hand:
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
    where slug = 'returning-headphones' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'returning-headphones';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 32
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'problems-and-returns' and position = 32 and stop_number = 32;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'problems-and-returns';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'returning-headphones', 1,
    'Returning headphones')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'returning-headphones' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Returning headphones';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'returning-headphones';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluan', 'haluun',
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-65809211d876');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluan', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluan', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('palauttaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"palauttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]palauttaa[X]palautta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppppp","WORDBASES":"+palauttaa(palauttaa)"}'::jsonb,
      'palauttaa', 'palauttaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to return, to give back', 'to return, to give back', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-545f651c4670');
  end if;
  if not exists (select 1 from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'palauttaa', 'palauttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to return, to give back', 'to return, to give back')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'palauttaa', 'palauttaa',
      (select form_name_en from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa'),
      (select why_en from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa'),
      (select meaning_en from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa'),
      (select lemma_meaning_en from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to return, to give back', 'to return, to give back';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"nämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]nämä[X]nä[Sn][Nm]mä","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+nämä(nämä)"}'::jsonb,
      'nämä', 'nää',
      'nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-3071ed4181f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nämä', 'nämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nämä', 'nämä',
      (select form_name_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select why_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select meaning_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select lemma_meaning_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      'nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuuloke', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"kuuloke","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuuloke[X]kuulokke[Sn][Nm]et","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppppp","WORDBASES":"+kuuloke(kuuloke)"}'::jsonb,
      'kuulokkeet', 'kuulokkeet',
      'nominative plural', 'Adds -t for more than one: kuuloke becomes kuulokkeet.', 'headphones', 'headphone', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-0a81d5c5c860');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuulokkeet', 'kuuloke';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: kuuloke becomes kuulokkeet.', 'headphones', 'headphone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuulokkeet', 'kuuloke',
      (select form_name_en from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet'),
      (select why_en from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet'),
      (select meaning_en from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet'),
      (select lemma_meaning_en from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet'),
      'nominative plural', 'Adds -t for more than one: kuuloke becomes kuulokkeet.', 'headphones', 'headphone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sine][Nm]iissä","NUMBER":"plural","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+ne(ne)"}'::jsonb,
      'niissä', 'niis',
      'inessive plural', 'Adds -ssä for ''in'': ne becomes niissä, ''in them''. Speech says niis.', 'with them', 'they, those', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-d3747a0b89bd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niissä', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive plural', 'Adds -ssä for ''in'': ne becomes niissä, ''in them''. Speech says niis.', 'with them', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niissä', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis'),
      'inessive plural', 'Adds -ssä for ''in'': ne becomes niissä, ''in them''. Speech says niis.', 'with them', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vika', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"vika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vika[X]vik[Ses][Ny]ana","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppp","WORDBASES":"+vika(vika)"}'::jsonb,
      'vikana', 'vikana',
      'essive singular', 'Vika means fault. Mikä on vikana means ''what is wrong'', with -na.', 'wrong', 'fault, defect', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-a7f1109753d5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vikana', 'vika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Vika means fault. Mikä on vikana means ''what is wrong'', with -na.', 'wrong', 'fault, defect')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vikana', 'vika',
      (select form_name_en from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana'),
      (select why_en from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana'),
      (select meaning_en from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana'),
      (select lemma_meaning_en from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana'),
      'essive singular', 'Vika means fault. Mikä on vikana means ''what is wrong'', with -na.', 'wrong', 'fault, defect';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vasen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vasen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vasen[X]vase[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+vasen(vasen)"}'::jsonb,
      'vasen', 'vasen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'left', 'left', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-946af0d16799');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vasen', 'vasen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'left', 'left')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vasen', 'vasen',
      (select form_name_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen'),
      (select why_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen'),
      (select meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen'),
      (select lemma_meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'left', 'left';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puol[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puoli', 'puoli',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'half, side', 'half, side', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-a05be520304a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puoli', 'puoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'half, side', 'half, side')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puoli', 'puoli',
      (select form_name_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli'),
      (select why_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli'),
      (select meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli'),
      (select lemma_meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'half, side', 'half, side';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('toimia', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"toimia","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'toimi', 'toimi',
      'present tense, negative form', 'After ei the verb drops its ending: toimia becomes toimi.', 'work (doesn''t work)', 'to work, to function', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-8031c1f946bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toimi', 'toimia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: toimia becomes toimi.', 'work (doesn''t work)', 'to work, to function')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toimi', 'toimia',
      (select form_name_en from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi'),
      (select why_en from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi'),
      (select meaning_en from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi'),
      (select lemma_meaning_en from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi'),
      'present tense, negative form', 'After ei the verb drops its ending: toimia becomes toimi.', 'work (doesn''t work)', 'to work, to function';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ollenkaan', 'CLASS=seikkasana', '{"BASEFORM":"ollenkaan","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'ollenkaan', 'ollenkaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-d2f590cc0a3b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ollenkaan', 'ollenkaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ollenkaan', 'ollenkaan',
      (select form_name_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select why_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select meaning_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select lemma_meaning_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-5eb112d9aace');
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
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuitti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuitti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuitti[X]kuitt[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kuitti(kuitti)"}'::jsonb,
      'kuitti', 'kuitti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'receipt', 'receipt', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-fc5f20d15b81');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuitti', 'kuitti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'receipt', 'receipt')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuitti', 'kuitti',
      (select form_name_en from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti'),
      (select why_en from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti'),
      (select meaning_en from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti'),
      (select lemma_meaning_en from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'receipt', 'receipt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'täs',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-25ac6c76f4b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tässä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tässä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ostaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"ostaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ostaa[X]ost[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+ostaa(ostaa)"}'::jsonb,
      'ostin', 'ostin',
      'past tense, 1st person singular', 'Ostaa means to buy. -i- marks the past and -n goes with minä: ostin.', 'I bought', 'to buy', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-7849998d3c92');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ostin', 'ostaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Ostaa means to buy. -i- marks the past and -n goes with minä: ostin.', 'I bought', 'to buy')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ostin', 'ostaa',
      (select form_name_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin'),
      (select why_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin'),
      (select meaning_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin'),
      (select lemma_meaning_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin'),
      'past tense, 1st person singular', 'Ostaa means to buy. -i- marks the past and -n goes with minä: ostin.', 'I bought', 'to buy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sn][Nm]e","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+ne(ne)"}'::jsonb,
      'ne', 'ne',
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-18803b094966');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ne', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ne', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viime', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"viime","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]viime[X][Sn][Ny]viime","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+viime(viime)"}'::jsonb,
      'viime', 'viime',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'last (viime viikolla, last week)', 'last (viime viikolla, last week)', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-c7947676c505');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viime', 'viime';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'last (viime viikolla, last week)', 'last (viime viikolla, last week)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viime', 'viime',
      (select form_name_en from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime'),
      (select why_en from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime'),
      (select meaning_en from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime'),
      (select lemma_meaning_en from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'last (viime viikolla, last week)', 'last (viime viikolla, last week)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikolla', 'viikolla',
      'adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k.', '(last) week', 'week', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-e67993b3b018');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikolla', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k.', '(last) week', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikolla', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla'),
      'adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k.', '(last) week', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluatko', 'haluuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-6189aefae9f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluatko', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluatko', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sn][Nm]det","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uudet', 'uudet',
      'nominative plural', 'Adds -t for more than one: uusi becomes uudet.', 'new ones', 'new', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-a0fac22b7224');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uudet', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: uusi becomes uudet.', 'new ones', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uudet', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet'),
      'nominative plural', 'Adds -t for more than one: uusi becomes uudet.', 'new ones', 'new';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vai', 'CLASS=sidesana', '{"BASEFORM":"vai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vai[X]vai","STRUCTURE":"=ppp","WORDBASES":"+vai(vai)"}'::jsonb,
      'vai', 'vai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-83d8cf4795ac');
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
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('raha', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"raha","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]raha[X]rah[Sn][Nm]at","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+raha(raha)"}'::jsonb,
      'rahat', 'rahat',
      'nominative plural', 'Money you get back is said with -t: raha becomes rahat.', 'the money', 'money', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-b82290d92243');
  end if;
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rahat', 'raha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Money you get back is said with -t: raha becomes rahat.', 'the money', 'money')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rahat', 'raha',
      (select form_name_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat'),
      (select why_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat'),
      (select meaning_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat'),
      (select lemma_meaning_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat'),
      'nominative plural', 'Money you get back is said with -t: raha becomes rahat.', 'the money', 'money';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takaisin', 'CLASS=seikkasana', '{"BASEFORM":"takaisin","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'takaisin', 'takas',
      'adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-2c5f4daf7d39');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitos',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-c5b0481eae2b');
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
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hetki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hetki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hetki[X]hetk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hetki(hetki)"}'::jsonb,
      'hetki', 'hetki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-42dbfb913e77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hetki', 'hetki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hetki', 'hetki',
      (select form_name_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select why_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select meaning_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select lemma_meaning_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hae[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'haen', 'haen',
      'present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-0bb41a1c5be3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haen', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haen', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      'present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varasto', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"varasto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]varasto[X]varasto[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppppp","WORDBASES":"+varasto(varasto)"}'::jsonb,
      'varastosta', 'varastost',
      'elative singular', 'Adds -sta for ''from'': varasto becomes varastosta. Speech drops the last vowel: varastost.', 'from the stockroom', 'stockroom, storage', 'approved', now(), 'content/approvals/part-6.json#returning-headphones/form-729784bb72e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'varastosta', 'varasto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Adds -sta for ''from'': varasto becomes varastosta. Speech drops the last vowel: varastost.', 'from the stockroom', 'stockroom, storage')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'varastosta', 'varasto',
      (select form_name_en from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost'),
      (select why_en from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost'),
      (select meaning_en from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost'),
      (select lemma_meaning_en from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost'),
      'elative singular', 'Adds -sta for ''from'': varasto becomes varastosta. Speech drops the last vowel: varastost.', 'from the stockroom', 'stockroom, storage';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä haluun palauttaa nää kuulokkeet.',
    'Hei! Minä haluan palauttaa nämä kuulokkeet.', 'Hi! I want to return these headphones.',
    'returning-headphones/1-puhe-1ca647a42ff0.mp3', 'returning-headphones/1-kirja-503ea4af526c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 4, 'palauttaa', (select id from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa')),
    (v_line_id, 'kirja', 5, 'nämä', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'kirja', 6, 'kuulokkeet', (select id from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 4, 'palauttaa', (select id from public.forms where lemma = 'palauttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'palauttaa' and surface_puhe = 'palauttaa')),
    (v_line_id, 'puhe', 5, 'nää', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'puhe', 6, 'kuulokkeet', (select id from public.forms where lemma = 'kuuloke' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kuulokkeet' and surface_puhe = 'kuulokkeet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Emma', 'Okei. Mikä niis on vikana?',
    'Selvä. Mikä niissä on vikana?', 'OK. What''s wrong with them?',
    'returning-headphones/2-puhe-6f81a0677312.mp3', 'returning-headphones/2-kirja-a545dc926a64.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 3, 'niissä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'vikana', (select id from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 3, 'niis', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'niissä' and surface_puhe = 'niis')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'vikana', (select id from public.forms where lemma = 'vika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vikana' and surface_puhe = 'vikana'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Vasen puoli ei toimi ollenkaan.',
    'Vasen puoli ei toimi ollenkaan.', 'The left side doesn''t work at all.',
    'returning-headphones/3-puhe-7cfa9204f8ff.mp3', 'returning-headphones/3-kirja-740c2694c19a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vasen', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen')),
    (v_line_id, 'kirja', 2, 'puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli')),
    (v_line_id, 'kirja', 3, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 4, 'toimi', (select id from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi')),
    (v_line_id, 'kirja', 5, 'ollenkaan', (select id from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan')),
    (v_line_id, 'puhe', 1, 'Vasen', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasen' and surface_puhe = 'vasen')),
    (v_line_id, 'puhe', 2, 'puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puoli')),
    (v_line_id, 'puhe', 3, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 4, 'toimi', (select id from public.forms where lemma = 'toimia' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'toimi' and surface_puhe = 'toimi')),
    (v_line_id, 'puhe', 5, 'ollenkaan', (select id from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Emma', 'Onks sul kuitti?',
    'Onko sinulla kuitti?', 'Do you have the receipt?',
    'returning-headphones/4-puhe-6f4879f7a3ad.mp3', 'returning-headphones/4-kirja-ec53ce36a074.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 3, 'kuitti', (select id from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 3, 'kuitti', (select id from public.forms where lemma = 'kuitti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuitti' and surface_puhe = 'kuitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'On, täs. Mä ostin ne viime viikolla.',
    'On, tässä. Minä ostin ne viime viikolla.', 'Yes, here. I bought them last week.',
    'returning-headphones/5-puhe-741ea1711e09.mp3', 'returning-headphones/5-kirja-9e33915f6779.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'ostin', (select id from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin')),
    (v_line_id, 'kirja', 5, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 6, 'viime', (select id from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime')),
    (v_line_id, 'kirja', 7, 'viikolla', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'ostin', (select id from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostin' and surface_puhe = 'ostin')),
    (v_line_id, 'puhe', 5, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 6, 'viime', (select id from public.forms where lemma = 'viime' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viime' and surface_puhe = 'viime')),
    (v_line_id, 'puhe', 7, 'viikolla', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikolla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Emma', 'Haluuksä uudet vai rahat takas?',
    'Haluatko sinä uudet vai rahat takaisin?', 'Do you want new ones or your money back?',
    'returning-headphones/6-puhe-a7613110167a.mp3', 'returning-headphones/6-kirja-d7cd5d0f7c08.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Haluatko', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'uudet', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet')),
    (v_line_id, 'kirja', 4, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'kirja', 5, 'rahat', (select id from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat')),
    (v_line_id, 'kirja', 6, 'takaisin', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas')),
    (v_line_id, 'puhe', 1, 'Haluuk', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'uudet', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet')),
    (v_line_id, 'puhe', 4, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'puhe', 5, 'rahat', (select id from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'rahat' and surface_puhe = 'rahat')),
    (v_line_id, 'puhe', 6, 'takas', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Uudet, kiitos.',
    'Uudet, kiitos.', 'New ones, please.',
    'returning-headphones/7-puhe-499ede8ce1c2.mp3', 'returning-headphones/7-kirja-a2782979654a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Uudet', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet')),
    (v_line_id, 'kirja', 2, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 1, 'Uudet', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'uudet' and surface_puhe = 'uudet')),
    (v_line_id, 'puhe', 2, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Emma', 'Okei, hetki. Mä haen ne varastost.',
    'Selvä, hetki. Minä haen ne varastosta.', 'OK, one moment. I''ll get them from the stockroom.',
    'returning-headphones/8-puhe-e1b1d335ad90.mp3', 'returning-headphones/8-kirja-db2dfceb4649.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'hetki', (select id from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'haen', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen')),
    (v_line_id, 'kirja', 5, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 6, 'varastosta', (select id from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'hetki', (select id from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'haen', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen')),
    (v_line_id, 'puhe', 5, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 6, 'varastost', (select id from public.forms where lemma = 'varasto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'varastosta' and surface_puhe = 'varastost'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#returning-headphones/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
