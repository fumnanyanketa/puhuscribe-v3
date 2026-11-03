-- Publishes the dialogue midsummer-plans (unit holidays). Made by
-- scripts/generate/pipeline.py publish from content/drafts/midsummer-plans. Do not edit by hand:
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
    where slug = 'midsummer-plans' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'midsummer-plans';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 26
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'holidays' and position = 26 and stop_number = 26;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'holidays';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'midsummer-plans', 1,
    'Midsummer plans')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'midsummer-plans' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Midsummer plans';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'midsummer-plans';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-a0c867e0dc77');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-ec7b2eab227a');
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
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-d8e27c6cf4bb');
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
  if not exists (select 1 from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juhannus', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"juhannus","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]juhannus[X]juhannu[Ses][Ny]ksena","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppppp","WORDBASES":"+juhannus(juhannus)"}'::jsonb,
      'juhannuksena', 'juhannuksena',
      'essive singular', 'Adds -na to say when: juhannus becomes juhannuksena.', 'at Midsummer', 'Midsummer', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-2fd117b0f295');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juhannuksena', 'juhannus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Adds -na to say when: juhannus becomes juhannuksena.', 'at Midsummer', 'Midsummer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juhannuksena', 'juhannus',
      (select form_name_en from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'),
      (select why_en from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'),
      (select meaning_en from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'),
      (select lemma_meaning_en from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'),
      'essive singular', 'Adds -na to say when: juhannus becomes juhannuksena.', 'at Midsummer', 'Midsummer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietää', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"tietää","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'tiedä', 'tiiä',
      'present tense, negative form', 'After en the verb drops its ending: tietää becomes tiedä. Speech says tiiä.', 'know (I don''t know)', 'to know', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-d0d7f7db40a9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiedä', 'tietää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: tietää becomes tiedä. Speech says tiiä.', 'know (I don''t know)', 'to know')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiedä', 'tietää',
      (select form_name_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä'),
      (select why_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä'),
      (select meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä'),
      (select lemma_meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä'),
      'present tense, negative form', 'After en the verb drops its ending: tietää becomes tiedä. Speech says tiiä.', 'know (I don''t know)', 'to know';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-2b3844766909');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vielä', 'vielä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vielä', 'vielä',
      (select form_name_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select why_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select lemma_meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-a0518fcf4ae6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'milloin', 'milloin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'milloin', 'milloin',
      (select form_name_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select why_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select lemma_meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesäkuu', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kesäkuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kes[Sn][Ny]ä[Bh][Bc][Ln][Xp]kuu[X]kuu[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp=pppp","WORDBASES":"+kesä(kesä)+kuu(kuu)"}'::jsonb,
      'kesäkuun', 'kesäkuun',
      'genitive singular', 'Adds -n so it goes with lopussa: kesäkuun lopussa, ''at the end of June''.', 'of June', 'June', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-a54828e4942a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesäkuun', 'kesäkuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n so it goes with lopussa: kesäkuun lopussa, ''at the end of June''.', 'of June', 'June')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesäkuun', 'kesäkuu',
      (select form_name_en from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun'),
      (select why_en from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun'),
      (select meaning_en from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun'),
      (select lemma_meaning_en from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun'),
      'genitive singular', 'Adds -n so it goes with lopussa: kesäkuun lopussa, ''at the end of June''.', 'of June', 'June';
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('loppu', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"loppu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]loppu[X]lopu[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+loppu(loppu)"}'::jsonb,
      'lopussa', 'lopus',
      'inessive singular', 'Adds -ssa for ''in'': loppu becomes lopussa, with one p. Speech shortens -ssa to -s: lopussa becomes lopus.', 'at the end', 'end', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-747f91da16f3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lopussa', 'loppu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': loppu becomes lopussa, with one p. Speech shortens -ssa to -s: lopussa becomes lopus.', 'at the end', 'end')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lopussa', 'loppu',
      (select form_name_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus'),
      (select why_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus'),
      (select meaning_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus'),
      (select lemma_meaning_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus'),
      'inessive singular', 'Adds -ssa for ''in'': loppu becomes lopussa, with one p. Speech shortens -ssa to -s: lopussa becomes lopus.', 'at the end', 'end';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aina', 'CLASS=seikkasana', '{"BASEFORM":"aina","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aina[X]aina","STRUCTURE":"=pppp","WORDBASES":"+aina(aina)"}'::jsonb,
      'aina', 'aina',
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-2f65b514975a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aina', 'aina';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aina', 'aina',
      (select form_name_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select why_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select meaning_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select lemma_meaning_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-3978a16fa6b0');
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
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sn][Nm]set","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaiset', 'suomalaiset',
      'nominative plural', 'Adds -t for more than one: suomalainen becomes suomalaiset.', 'Finns', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-d650ab7ed15c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalaiset', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: suomalainen becomes suomalaiset.', 'Finns', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalaiset', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset'),
      'nominative plural', 'Adds -t for more than one: suomalainen becomes suomalaiset.', 'Finns', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]te[Tt][Ap][P3][Nm][Ef]kevät","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tekevät', 'tekee',
      'present tense, 3rd person plural', 'Books write tekevät. Speech uses the he or she form: tekee.', 'they do', 'to do, to make', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-e52439e6835d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tekevät', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write tekevät. Speech uses the he or she form: tekee.', 'they do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tekevät', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee'),
      'present tense, 3rd person plural', 'Books write tekevät. Speech uses the he or she form: tekee.', 'they do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-ae2f0cff6156');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]men[Tt][Ap][P3][Nm][Ef]evät","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menevät', 'menee',
      'present tense, 3rd person plural', 'Books write menevät. Speech uses the he or she form: menee.', 'they go', 'to go', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-489222cad035');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menevät', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write menevät. Speech uses the he or she form: menee.', 'they go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menevät', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee'),
      'present tense, 3rd person plural', 'Books write menevät. Speech uses the he or she form: menee.', 'they go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mökki', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"mökki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mökki[X]möki[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+mökki(mökki)"}'::jsonb,
      'mökille', 'mökille',
      'allative singular', 'Adds -lle for ''to'': mökki becomes mökille, with one k.', 'to the cottage', 'cottage', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-40ce5938037e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mökille', 'mökki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''to'': mökki becomes mökille, with one k.', 'to the cottage', 'cottage')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mökille', 'mökki',
      (select form_name_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille'),
      (select why_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille'),
      (select meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille'),
      (select lemma_meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille'),
      'allative singular', 'Adds -lle for ''to'': mökki becomes mökille, with one k.', 'to the cottage', 'cottage';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saunoa', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"saunoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saunoa[X]sauno[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+saunoa(saunoa)"}'::jsonb,
      'saunovat', 'saunoo',
      'present tense, 3rd person plural', 'Books write saunovat. Speech uses the he or she form: saunoo.', 'they have a sauna', 'to have a sauna', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-fdf251006057');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunovat', 'saunoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write saunovat. Speech uses the he or she form: saunoo.', 'they have a sauna', 'to have a sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunovat', 'saunoa',
      (select form_name_en from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo'),
      (select why_en from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo'),
      (select meaning_en from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo'),
      (select lemma_meaning_en from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo'),
      'present tense, 3rd person plural', 'Books write saunovat. Speech uses the he or she form: saunoo.', 'they have a sauna', 'to have a sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('polttaa', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"polttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]polttaa[X]poltt[Tt][Ap][P3][Nm][Ef]avat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+polttaa(polttaa)"}'::jsonb,
      'polttavat', 'polttaa',
      'present tense, 3rd person plural', 'Books write polttavat. Speech uses the he or she form: polttaa.', 'they light', 'to burn, to light', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-bdb2760d3c4f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'polttavat', 'polttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write polttavat. Speech uses the he or she form: polttaa.', 'they light', 'to burn, to light')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'polttavat', 'polttaa',
      (select form_name_en from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa'),
      (select why_en from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa'),
      (select meaning_en from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa'),
      (select lemma_meaning_en from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa'),
      'present tense, 3rd person plural', 'Books write polttavat. Speech uses the he or she form: polttaa.', 'they light', 'to burn, to light';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kokko', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"kokko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kokko[X]kokko[Sp][Nm]ja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+kokko(kokko)"}'::jsonb,
      'kokkoja', 'kokkoja',
      'partitive plural', 'Plural ''some'' takes -ja: kokko becomes kokkoja.', 'bonfires', 'bonfire', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-31464dc28a98');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kokkoja', 'kokko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ja: kokko becomes kokkoja.', 'bonfires', 'bonfire')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kokkoja', 'kokko',
      (select form_name_en from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja'),
      (select why_en from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja'),
      (select meaning_en from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja'),
      (select lemma_meaning_en from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja'),
      'partitive plural', 'Plural ''some'' takes -ja: kokko becomes kokkoja.', 'bonfires', 'bonfire';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulostaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"kuulostaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuulostaa[X]kuulosta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppppp","WORDBASES":"+kuulostaa(kuulostaa)"}'::jsonb,
      'kuulostaa', 'kuulostaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sound', 'to sound', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-e2a29b08d6bc');
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
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiva[Sabl][Ny]lta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kivalta', 'kivalta',
      'ablative singular', 'Kuulostaa (to sound) wants -lta: kiva becomes kivalta, ''sounds nice''.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-cb86e7d98937');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kivalta', 'kiva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Kuulostaa (to sound) wants -lta: kiva becomes kivalta, ''sounds nice''.', 'nice', 'nice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kivalta', 'kiva',
      (select form_name_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta'),
      (select why_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta'),
      (select meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta'),
      (select lemma_meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta'),
      'ablative singular', 'Kuulostaa (to sound) wants -lta: kiva becomes kivalta, ''sounds nice''.', 'nice', 'nice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tule', 'tuu',
      'imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-a2a7fb70527b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tule', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tule', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      'imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sg][Nm]idän","NUMBER":"plural","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+me(me)"}'::jsonb,
      'meidän', 'meidän',
      'genitive plural', 'Me takes -dän for ''our'': meidän. People say it the same way.', 'our', 'we', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-2d2ace8a36b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'meidän', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive plural', 'Me takes -dän for ''our'': meidän. People say it the same way.', 'our', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'meidän', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän'),
      'genitive plural', 'Me takes -dän for ''our'': meidän. People say it the same way.', 'our', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mökki', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p', '{"BASEFORM":"mökki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mökki[X]möki[Sall][Ny]lle[O1m]mme","NUMBER":"singular","POSSESSIVE":"1p","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppppp","WORDBASES":"+mökki(mökki)"}'::jsonb,
      'mökillemme', 'mökille',
      'allative singular, with the possessive ending for our', 'Books add -lle for ''to'' and -mme for ''our'': mökillemme. Speech drops -mme: meidän mökille.', 'to our cottage', 'cottage', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-d609cd19ee75');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mökillemme', 'mökki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular, with the possessive ending for our', 'Books add -lle for ''to'' and -mme for ''our'': mökillemme. Speech drops -mme: meidän mökille.', 'to our cottage', 'cottage')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mökillemme', 'mökki',
      (select form_name_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille'),
      (select why_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille'),
      (select meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille'),
      (select lemma_meaning_en from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille'),
      'allative singular, with the possessive ending for our', 'Books add -lle for ''to'' and -mme for ''our'': mökillemme. Speech drops -mme: meidän mökille.', 'to our cottage', 'cottage';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-0fd3b38079dc');
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
  if not exists (select 1 from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tila', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tila","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tila[X]til[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tila(tila)"}'::jsonb,
      'tilaa', 'tilaa',
      'partitive singular', 'Tila, room. ''Some room'' ends in -a: tilaa.', 'room, space', 'room, space', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-0a3a02ded844');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tilaa', 'tila';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Tila, room. ''Some room'' ends in -a: tilaa.', 'room, space', 'room, space')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tilaa', 'tila',
      (select form_name_en from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa'),
      (select why_en from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa'),
      (select meaning_en from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa'),
      (select lemma_meaning_en from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa'),
      'partitive singular', 'Tila, room. ''Some room'' ends in -a: tilaa.', 'room, space', 'room, space';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oikea', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive', '{"BASEFORM":"oikea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]oikea[X]oikea[Ssti]sti","SIJAMUOTO":"kerrontosti","STRUCTURE":"=pppppppp","WORDBASES":"+oikea(oikea)"}'::jsonb,
      'oikeasti', 'oikeesti',
      'adverb form (-sti)', 'Adds -sti to oikea (real) to say how: oikeasti. Speech turns ea into ee: oikeesti.', 'really', 'right, correct', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-6af8fececad4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oikeasti', 'oikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb form (-sti)', 'Adds -sti to oikea (real) to say how: oikeasti. Speech turns ea into ee: oikeesti.', 'really', 'right, correct')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oikeasti', 'oikea',
      (select form_name_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti'),
      (select why_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti'),
      (select meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti'),
      (select lemma_meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti'),
      'adverb form (-sti)', 'Adds -sti to oikea (real) to say how: oikeasti. Speech turns ea into ee: oikeesti.', 'really', 'right, correct';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mieli', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"mieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mieli[X]miele[Sade][Ny]llä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+mieli(mieli)"}'::jsonb,
      'mielelläni', 'mielellään',
      'adessive singular, with the possessive ending for my', 'Mielelläni means ''gladly'' or ''I''d love to''. Speech often says mielellään.', 'I''d love to', 'mind (mielelläni, gladly)', 'approved', now(), 'content/approvals/part-5.json#midsummer-plans/form-f878dc82043d');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mitä sä teet juhannuksena?',
    'Mitä sinä teet juhannuksena?', 'What are you doing at Midsummer?',
    'midsummer-plans/1-puhe-926d0e0a2b42.mp3', 'midsummer-plans/1-kirja-8af8971c262d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'kirja', 4, 'juhannuksena', (select id from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'puhe', 4, 'juhannuksena', (select id from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'En tiiä vielä. Millon se on?',
    'En tiedä vielä. Milloin se on?', 'I don''t know yet. When is it?',
    'midsummer-plans/2-puhe-4b653a696c74.mp3', 'midsummer-plans/2-kirja-5eb7ff5421de.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 2, 'tiedä', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä')),
    (v_line_id, 'kirja', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'kirja', 4, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 5, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 2, 'tiiä', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tiedä' and surface_puhe = 'tiiä')),
    (v_line_id, 'puhe', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 4, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 5, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Kesäkuun lopus. Se on aina lauantaina.',
    'Kesäkuun lopussa. Se on aina lauantaina.', 'At the end of June. It''s always on a Saturday.',
    'midsummer-plans/3-puhe-e02f9ed48c5a.mp3', 'midsummer-plans/3-kirja-4b233e248e40.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kesäkuun', (select id from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun')),
    (v_line_id, 'kirja', 2, 'lopussa', (select id from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus')),
    (v_line_id, 'kirja', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'kirja', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 1, 'Kesäkuun', (select id from public.forms where lemma = 'kesäkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kesäkuun' and surface_puhe = 'kesäkuun')),
    (v_line_id, 'puhe', 2, 'lopus', (select id from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'lopussa' and surface_puhe = 'lopus')),
    (v_line_id, 'puhe', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'puhe', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mitä suomalaiset tekee juhannuksena?',
    'Mitä suomalaiset tekevät juhannuksena?', 'What do Finns do at Midsummer?',
    'midsummer-plans/4-puhe-400df546c7c9.mp3', 'midsummer-plans/4-kirja-33bf3c7c34b1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'suomalaiset', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset')),
    (v_line_id, 'kirja', 3, 'tekevät', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee')),
    (v_line_id, 'kirja', 4, 'juhannuksena', (select id from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'suomalaiset', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset')),
    (v_line_id, 'puhe', 3, 'tekee', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tekevät' and surface_puhe = 'tekee')),
    (v_line_id, 'puhe', 4, 'juhannuksena', (select id from public.forms where lemma = 'juhannus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'juhannuksena' and surface_puhe = 'juhannuksena'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Ne menee mökille, saunoo ja polttaa kokkoja.',
    'He menevät mökille, saunovat ja polttavat kokkoja.', 'They go to the cottage, have a sauna and light bonfires.',
    'midsummer-plans/5-puhe-8e52f815dd5a.mp3', 'midsummer-plans/5-kirja-91995491a4e4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'He', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 2, 'menevät', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee')),
    (v_line_id, 'kirja', 3, 'mökille', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille')),
    (v_line_id, 'kirja', 4, 'saunovat', (select id from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'polttavat', (select id from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa')),
    (v_line_id, 'kirja', 7, 'kokkoja', (select id from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja')),
    (v_line_id, 'puhe', 1, 'Ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 2, 'menee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menevät' and surface_puhe = 'menee')),
    (v_line_id, 'puhe', 3, 'mökille', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'mökille' and surface_puhe = 'mökille')),
    (v_line_id, 'puhe', 4, 'saunoo', (select id from public.forms where lemma = 'saunoa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saunovat' and surface_puhe = 'saunoo')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'polttaa', (select id from public.forms where lemma = 'polttaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'polttavat' and surface_puhe = 'polttaa')),
    (v_line_id, 'puhe', 7, 'kokkoja', (select id from public.forms where lemma = 'kokko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kokkoja' and surface_puhe = 'kokkoja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kuulostaa kivalta!',
    'Kuulostaa kivalta!', 'Sounds nice!',
    'midsummer-plans/6-puhe-a3b08778112a.mp3', 'midsummer-plans/6-kirja-bc011ec94af8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuulostaa', (select id from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa')),
    (v_line_id, 'kirja', 2, 'kivalta', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta')),
    (v_line_id, 'puhe', 1, 'Kuulostaa', (select id from public.forms where lemma = 'kuulostaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kuulostaa' and surface_puhe = 'kuulostaa')),
    (v_line_id, 'puhe', 2, 'kivalta', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kivalta' and surface_puhe = 'kivalta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Tuu meidän mökille! Siel on tilaa.',
    'Tule meidän mökillemme! Siellä on tilaa.', 'Come to our cottage! There''s room.',
    'midsummer-plans/7-puhe-f9deac34b197.mp3', 'midsummer-plans/7-kirja-d1987a322c5b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tule', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu')),
    (v_line_id, 'kirja', 2, 'meidän', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän')),
    (v_line_id, 'kirja', 3, 'mökillemme', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille')),
    (v_line_id, 'kirja', 4, 'Siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'tilaa', (select id from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa')),
    (v_line_id, 'puhe', 1, 'Tuu', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu')),
    (v_line_id, 'puhe', 2, 'meidän', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'meidän' and surface_puhe = 'meidän')),
    (v_line_id, 'puhe', 3, 'mökille', (select id from public.forms where lemma = 'mökki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular;POSSESSIVE=1p' and surface_kirja = 'mökillemme' and surface_puhe = 'mökille')),
    (v_line_id, 'puhe', 4, 'Siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'tilaa', (select id from public.forms where lemma = 'tila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilaa' and surface_puhe = 'tilaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Oikeesti? Kiitti, mielellään!',
    'Oikeasti? Kiitos, mielelläni!', 'Really? Thanks, I''d love to!',
    'midsummer-plans/8-puhe-51dc85494597.mp3', 'midsummer-plans/8-kirja-b51f3cbad480.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Oikeasti', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti')),
    (v_line_id, 'kirja', 2, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 3, 'mielelläni', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään')),
    (v_line_id, 'puhe', 1, 'Oikeesti', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti')),
    (v_line_id, 'puhe', 2, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 3, 'mielellään', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielellään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#midsummer-plans/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
