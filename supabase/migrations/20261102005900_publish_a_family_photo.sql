-- Publishes the dialogue a-family-photo (unit talking-about-family). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-family-photo. Do not edit by hand:
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
    where slug = 'a-family-photo' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-family-photo';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 20
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'talking-about-family' and position = 20 and stop_number = 20;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'talking-about-family';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-family-photo', 3,
    'A family photo')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-family-photo' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'A family photo';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-family-photo';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katsoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"katsoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]katsoa[X]katso[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+katsoa(katsoa)"}'::jsonb,
      'katso', 'kato',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-8350ddd0f318');
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'katso', 'katsoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'katso', 'katsoa',
      (select form_name_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select why_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select lemma_meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      'imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-4352ca83b810');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perhe', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"perhe","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perhe[X]perhe[Sn][Ny]e[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+perhe(perhe)"}'::jsonb,
      'perheeni', 'perhe',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'', with an extra e: perheeni. Speech drops it and says mun perhe.', 'my family', 'family', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-28b462828347');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perheeni', 'perhe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'', with an extra e: perheeni. Speech drops it and says mun perhe.', 'my family', 'family')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perheeni', 'perhe',
      (select form_name_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe'),
      (select why_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe'),
      (select meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe'),
      (select lemma_meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'', with an extra e: perheeni. Speech drops it and says mun perhe.', 'my family', 'family';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihana', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ihana","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]ihana[X]ihan[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+ihana(ihana)"}'::jsonb,
      'ihana', 'ihana',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-8265d7db1e21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihana', 'ihana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihana', 'ihana',
      (select form_name_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select why_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select lemma_meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuva', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuva","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuva[X]kuv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kuva(kuva)"}'::jsonb,
      'kuva', 'kuva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'picture, photo', 'picture, photo', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-d4efc9981c01');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuva', 'kuva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'picture, photo', 'picture, photo')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuva', 'kuva',
      (select form_name_en from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva'),
      (select why_en from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva'),
      (select meaning_en from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva'),
      (select lemma_meaning_en from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'picture, photo', 'picture, photo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuka', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuka","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]kuka[X]ku[Sn][Ny]ka","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kuka(kuka)"}'::jsonb,
      'kuka', 'kuka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-3050a6672faf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuka', 'kuka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuka', 'kuka',
      (select form_name_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select why_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select lemma_meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mies', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"mies","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mies[X]miehe[Sn][Ny][O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+mies(mies)"}'::jsonb,
      'mieheni', 'mies',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': mieheni, with mies changing to miehe-. Speech says mun mies.', 'my husband', 'man, husband', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-c429d8f59328');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mieheni', 'mies';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': mieheni, with mies changing to miehe-. Speech says mun mies.', 'my husband', 'man, husband')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mieheni', 'mies',
      (select form_name_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies'),
      (select why_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies'),
      (select meaning_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies'),
      (select lemma_meaning_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': mieheni, with mies changing to miehe-. Speech says mun mies.', 'my husband', 'man, husband';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"nämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]nämä[X]nä[Sn][Nm]mä","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+nämä(nämä)"}'::jsonb,
      'nämä', 'nää',
      'nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-3071ed4181f9');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s', '{"BASEFORM":"lapsi","CLASS":"nimisana","MANUAL":"true","NUMBER":"plural","POSSESSIVE":"1s","SIJAMUOTO":"nimento"}'::jsonb,
      'lapseni', 'lapset',
      'nominative plural, with the possessive ending for my', 'Lapsi, child. -set makes many, -ni adds ''my'': lapseni. Speech says mun lapset and drops -ni.', 'my children', 'child', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-9f193d6d72e6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lapseni', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural, with the possessive ending for my', 'Lapsi, child. -set makes many, -ni adds ''my'': lapseni. Speech says mun lapset and drops -ni.', 'my children', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lapseni', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset'),
      'nominative plural, with the possessive ending for my', 'Lapsi, child. -set makes many, -ni adds ''my'': lapseni. Speech says mun lapset and drops -ni.', 'my children', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-ae2f0cff6156');
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'he', 'he';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'he', 'he',
      (select form_name_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne'),
      (select why_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne'),
      (select meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne'),
      (select lemma_meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne'),
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('näyttää', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"näyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]näyttää[X]näytt[Tt][Ap][P3][Nm][Ef]ävät","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+näyttää(näyttää)"}'::jsonb,
      'näyttävät', 'näyttää',
      'present tense, 3rd person plural', 'Books add -vät for ''they'': näyttävät. Speech uses the he or she form: ne näyttää.', 'they look', 'to look, to show', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-0e35ed6a5b20');
  end if;
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näyttävät', 'näyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books add -vät for ''they'': näyttävät. Speech uses the he or she form: ne näyttää.', 'they look', 'to look, to show')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näyttävät', 'näyttää',
      (select form_name_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää'),
      (select why_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää'),
      (select meaning_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää'),
      (select lemma_meaning_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää'),
      'present tense, 3rd person plural', 'Books add -vät for ''they'': näyttävät. Speech uses the he or she form: ne näyttää.', 'they look', 'to look, to show';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iloinen', 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"iloinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]ilo[X]ilo[Ll][Xj]inen[X]is[Sabl][Nm]ilta","NUMBER":"plural","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppp","WORDBASES":"+ilo(ilo)+inen(+inen)"}'::jsonb,
      'iloisilta', 'iloisilta',
      'ablative plural', 'Näyttää (to look) wants -lta: iloinen becomes iloisilta, ''look happy'', for several people.', 'happy', 'happy, cheerful', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-887b04afc8aa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'iloisilta', 'iloinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative plural', 'Näyttää (to look) wants -lta: iloinen becomes iloisilta, ''look happy'', for several people.', 'happy', 'happy, cheerful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'iloisilta', 'iloinen',
      (select form_name_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta'),
      (select why_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta'),
      (select meaning_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta'),
      (select lemma_meaning_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta'),
      'ablative plural', 'Näyttää (to look) wants -lta: iloinen becomes iloisilta, ''look happy'', for several people.', 'happy', 'happy, cheerful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-99966cae578b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'entä', 'entä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'entä', 'entä',
      (select form_name_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select why_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select lemma_meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuo', 'toi',
      'nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-e7513afe9e6b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuo', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuo', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      'nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vanha', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vanha","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vanha[X]vanh[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+vanha(vanha)"}'::jsonb,
      'vanha', 'vanha',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'old', 'old', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-1dda4d9bd7e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vanha', 'vanha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'old', 'old')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vanha', 'vanha',
      (select form_name_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha'),
      (select why_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha'),
      (select meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha'),
      (select lemma_meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'old', 'old';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nainen', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"nainen","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]nainen[X]nai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+nainen(nainen)"}'::jsonb,
      'nainen', 'nainen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'woman', 'woman', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-3dd75ef689fa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nainen', 'nainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'woman', 'woman')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nainen', 'nainen',
      (select form_name_en from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen'),
      (select why_en from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen'),
      (select meaning_en from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen'),
      (select lemma_meaning_en from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'woman', 'woman';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('isoäiti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"isoäiti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]iso=äiti[X]iso[Bm]äit[Sn][Ny]i[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=pppppp","WORDBASES":"+isoäiti(iso=äiti)"}'::jsonb,
      'isoäitini', 'mummo',
      'nominative singular, with the possessive ending for my', 'Books write isoäitini, with -ni for ''my''. Speech uses the everyday word mummo: mun mummo.', 'my grandmother', 'grandmother', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-aff492c48642');
  end if;
  if not exists (select 1 from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'isoäitini', 'isoäiti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books write isoäitini, with -ni for ''my''. Speech uses the everyday word mummo: mun mummo.', 'my grandmother', 'grandmother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'isoäitini', 'isoäiti',
      (select form_name_en from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo'),
      (select why_en from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo'),
      (select meaning_en from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo'),
      (select lemma_meaning_en from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo'),
      'nominative singular, with the possessive ending for my', 'Books write isoäitini, with -ni for ''my''. Speech uses the everyday word mummo: mun mummo.', 'my grandmother', 'grandmother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yhdeksänkymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"yhdeksänkymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yhdeksän[X]yhdeks[Sn][Ny]än[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp=pppppppp","WORDBASES":"+yhdeksän(yhdeksän)"}'::jsonb,
      'yhdeksänkymmentä', 'yheksänkyt',
      'nominative singular', 'Speech drops the d and shortens kymmentä to kyt: yheksänkyt.', 'ninety', 'ninety', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-f99dd2957257');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhdeksänkymmentä', 'yhdeksänkymmentä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the d and shortens kymmentä to kyt: yheksänkyt.', 'ninety', 'ninety')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhdeksänkymmentä', 'yhdeksänkymmentä',
      (select form_name_en from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt'),
      (select why_en from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt'),
      (select meaning_en from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt'),
      (select lemma_meaning_en from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt'),
      'nominative singular', 'Speech drops the d and shortens kymmentä to kyt: yheksänkyt.', 'ninety', 'ninety';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hieno', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hieno","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hieno[X]hieno[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hieno(hieno)"}'::jsonb,
      'hieno', 'hieno',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'great, fine', 'great, fine', 'approved', now(), 'content/approvals/part-4.json#a-family-photo/form-70eea424843d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hieno', 'hieno';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'great, fine', 'great, fine')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hieno', 'hieno',
      (select form_name_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno'),
      (select why_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno'),
      (select meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno'),
      (select lemma_meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'great, fine', 'great, fine';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Kato, tää on mun perhe.',
    'Katso, tämä on minun perheeni.', 'Look, this is my family.',
    'a-family-photo/1-puhe-028185f42bab.mp3', 'a-family-photo/1-kirja-992e9676b233.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Katso', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'kirja', 2, 'tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'perheeni', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe')),
    (v_line_id, 'puhe', 1, 'Kato', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'puhe', 2, 'tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'perhe', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'perheeni' and surface_puhe = 'perhe'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Leena', 'Ihana kuva! Kuka tää on?',
    'Ihana kuva! Kuka tämä on?', 'Lovely photo! Who''s this?',
    'a-family-photo/2-puhe-a150101fda9b.mp3', 'a-family-photo/2-kirja-bfce0bd001ec.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ihana', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana')),
    (v_line_id, 'kirja', 2, 'kuva', (select id from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva')),
    (v_line_id, 'kirja', 3, 'Kuka', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka')),
    (v_line_id, 'kirja', 4, 'tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Ihana', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana')),
    (v_line_id, 'puhe', 2, 'kuva', (select id from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva')),
    (v_line_id, 'puhe', 3, 'Kuka', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka')),
    (v_line_id, 'puhe', 4, 'tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Se on mun mies, Pauli.',
    'Hän on minun mieheni, Pauli.', 'That''s my husband, Pauli.',
    'a-family-photo/3-puhe-9146d39d87ce.mp3', 'a-family-photo/3-kirja-4de2072f1a28.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'mieheni', (select id from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies')),
    (v_line_id, 'kirja', 5, 'Pauli', null),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'mies', (select id from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'mies')),
    (v_line_id, 'puhe', 5, 'Pauli', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Leena', 'Ja nää kaks?',
    'Ja nämä kaksi?', 'And these two?',
    'a-family-photo/4-puhe-ab1856cdba78.mp3', 'a-family-photo/4-kirja-e6375fb48ea4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'nämä', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'kirja', 3, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'nää', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'puhe', 3, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Mun lapset, Lucas ja Anna.',
    'Minun lapseni, Lucas ja Anna.', 'My children, Lucas and Anna.',
    'a-family-photo/5-puhe-1bb73c982328.mp3', 'a-family-photo/5-kirja-f0044dcc7505.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'lapseni', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'kirja', 3, 'Lucas', null),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'Anna', null),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'lapset', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'puhe', 3, 'Lucas', null),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'Anna', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Leena', 'Ne näyttää iloisilta. Entä toi vanha nainen?',
    'He näyttävät iloisilta. Entä tuo vanha nainen?', 'They look happy. And that older woman?',
    'a-family-photo/6-puhe-efc420b09264.mp3', 'a-family-photo/6-kirja-8b9bcb969673.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'He', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 2, 'näyttävät', (select id from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää')),
    (v_line_id, 'kirja', 3, 'iloisilta', (select id from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta')),
    (v_line_id, 'kirja', 4, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 5, 'tuo', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'kirja', 6, 'vanha', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha')),
    (v_line_id, 'kirja', 7, 'nainen', (select id from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen')),
    (v_line_id, 'puhe', 1, 'Ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 2, 'näyttää', (select id from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näyttävät' and surface_puhe = 'näyttää')),
    (v_line_id, 'puhe', 3, 'iloisilta', (select id from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'iloisilta' and surface_puhe = 'iloisilta')),
    (v_line_id, 'puhe', 4, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 5, 'toi', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'puhe', 6, 'vanha', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanha' and surface_puhe = 'vanha')),
    (v_line_id, 'puhe', 7, 'nainen', (select id from public.forms where lemma = 'nainen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nainen' and surface_puhe = 'nainen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Se on mun mummo. Se on yheksänkyt!',
    'Hän on minun isoäitini. Hän on yhdeksänkymmentä!', 'That''s my grandma. She''s ninety!',
    'a-family-photo/7-puhe-a5c088aec788.mp3', 'a-family-photo/7-kirja-26d89a519d6f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'isoäitini', (select id from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo')),
    (v_line_id, 'kirja', 5, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 7, 'yhdeksänkymmentä', (select id from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'mummo', (select id from public.forms where lemma = 'isoäiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isoäitini' and surface_puhe = 'mummo')),
    (v_line_id, 'puhe', 5, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 7, 'yheksänkyt', (select id from public.forms where lemma = 'yhdeksänkymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yhdeksänkymmentä' and surface_puhe = 'yheksänkyt'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Leena', 'Hieno kuva.',
    'Hieno kuva.', 'A great photo.',
    'a-family-photo/8-puhe-2839037d0ef4.mp3', 'a-family-photo/8-kirja-b3a9a6a9a4de.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hieno', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno')),
    (v_line_id, 'kirja', 2, 'kuva', (select id from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva')),
    (v_line_id, 'puhe', 1, 'Hieno', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hieno' and surface_puhe = 'hieno')),
    (v_line_id, 'puhe', 2, 'kuva', (select id from public.forms where lemma = 'kuva' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuva' and surface_puhe = 'kuva'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#a-family-photo/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-4.json#a-family-photo/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
