-- Publishes the dialogue wheres-the-coffee-room (unit first-day-at-work). Made by
-- scripts/generate/pipeline.py publish from content/drafts/wheres-the-coffee-room. Do not edit by hand:
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
    where slug = 'wheres-the-coffee-room' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'wheres-the-coffee-room';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 19
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'first-day-at-work' and position = 19 and stop_number = 19;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'first-day-at-work';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'wheres-the-coffee-room', 2,
    'Where''s the coffee room?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'wheres-the-coffee-room' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Where''s the coffee room?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'wheres-the-coffee-room';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'mis',
      'inessive singular', 'Mikä with -ssä for ''in'': missä. Speech shortens it to mis.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-58d8f02852c7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'missä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Mikä with -ssä for ''in'': missä. Speech shortens it to mis.', 'where', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'missä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis'),
      'inessive singular', 'Mikä with -ssä for ''in'': missä. Speech shortens it to mis.', 'where', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvihuone', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahvihuone","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sn][Ny]i[Bh][Bc][Ln][Xp]huone[X]huone[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+kahvi(kahvi)+huone(huone)"}'::jsonb,
      'kahvihuone', 'kahvihuone',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee room, break room', 'coffee room, break room', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-da2cbd14a419');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvihuone', 'kahvihuone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee room, break room', 'coffee room, break room')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvihuone', 'kahvihuone',
      (select form_name_en from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone'),
      (select why_en from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone'),
      (select meaning_en from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee room, break room', 'coffee room, break room';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käytävä', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"käytävä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]käytävä[X]käytäv[Sg][Ny]än","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+käytävä(käytävä)"}'::jsonb,
      'käytävän', 'käytävän',
      'genitive singular', 'Adds -n so it goes with päässä (at the end): käytävän päässä, ''at the end of the corridor''.', 'of the corridor', 'corridor', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-cd75ed1ae204');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käytävän', 'käytävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n so it goes with päässä (at the end): käytävän päässä, ''at the end of the corridor''.', 'of the corridor', 'corridor')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käytävän', 'käytävä',
      (select form_name_en from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän'),
      (select why_en from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän'),
      (select meaning_en from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän'),
      (select lemma_meaning_en from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän'),
      'genitive singular', 'Adds -n so it goes with päässä (at the end): käytävän päässä, ''at the end of the corridor''.', 'of the corridor', 'corridor';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pää', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"pää","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]pää[X]pää[Sine][Ny]ssä","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+pää(pää)"}'::jsonb,
      'päässä', 'pääs',
      'inessive singular', 'Pää (head, end) with -ssä for ''in'': päässä. Speech shortens -ssä to -s: päässä becomes pääs.', 'at the end', 'head, end', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-d81708dfc306');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päässä', 'pää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Pää (head, end) with -ssä for ''in'': päässä. Speech shortens -ssä to -s: päässä becomes pääs.', 'at the end', 'head, end')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päässä', 'pää',
      (select form_name_en from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs'),
      (select why_en from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs'),
      (select meaning_en from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs'),
      (select lemma_meaning_en from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs'),
      'inessive singular', 'Pää (head, end) with -ssä for ''in'': päässä. Speech shortens -ssä to -s: päässä becomes pääs.', 'at the end', 'head, end';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vasen', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vasen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vasen[X]vasemma[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+vasen(vasen)"}'::jsonb,
      'vasemmalla', 'vasemmal',
      'adessive singular', 'Vasen changes to vasemma- and adds -lla for ''on'': vasemmalla. Speech shortens -lla to -l: vasemmalla becomes vasemmal.', 'on the left', 'left', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-010b2ddc6d88');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vasemmalla', 'vasen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Vasen changes to vasemma- and adds -lla for ''on'': vasemmalla. Speech shortens -lla to -l: vasemmalla becomes vasemmal.', 'on the left', 'left')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vasemmalla', 'vasen',
      (select form_name_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal'),
      (select why_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal'),
      (select meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal'),
      (select lemma_meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal'),
      'adessive singular', 'Vasen changes to vasemma- and adds -lla for ''on'': vasemmalla. Speech shortens -lla to -l: vasemmalla becomes vasemmal.', 'on the left', 'left';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-0fd3b38079dc');
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
  if not exists (select 1 from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvinkeitin', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahvinkeitin","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sg][Ny]in[Bh][Bc][Ln][Xp]keitin[X]keitin[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=pppppp","WORDBASES":"+kahvin(kahvi)+keitin(keitin)"}'::jsonb,
      'kahvinkeitin', 'kahvinkeitin',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee maker', 'coffee maker', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-9907e45e1a40');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvinkeitin', 'kahvinkeitin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee maker', 'coffee maker')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvinkeitin', 'kahvinkeitin',
      (select form_name_en from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin'),
      (select why_en from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin'),
      (select meaning_en from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee maker', 'coffee maker';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jääkaappi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"jääkaappi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]jää[X]jää[Sn][Ny][Bh][Bc][Ln][Xp]kaappi[X]kaapp[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=pppppp","WORDBASES":"+jää(jää)+kaappi(kaappi)"}'::jsonb,
      'jääkaappi', 'jääkaappi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'fridge', 'fridge', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-73c9f6c2f229');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jääkaappi', 'jääkaappi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'fridge', 'fridge')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jääkaappi', 'jääkaappi',
      (select form_name_en from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi'),
      (select why_en from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi'),
      (select meaning_en from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi'),
      (select lemma_meaning_en from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'fridge', 'fridge';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikroaaltouuni', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikroaaltouuni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mikro[X]mikro[Sn][Ny][Bh][Bc][Ln][Xp]aalto[X]aalto[Sn][Ny][Bh][Bc][Ln][Xp]uuni[X]uun[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp=pppp","WORDBASES":"+mikro(mikro)+aalto(aalto)+uuni(uuni)"}'::jsonb,
      'mikroaaltouuni', 'mikro',
      'nominative singular', 'Speech uses the short word mikro. Books write mikroaaltouuni.', 'microwave', 'microwave', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-8b259023a05b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mikroaaltouuni', 'mikroaaltouuni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech uses the short word mikro. Books write mikroaaltouuni.', 'microwave', 'microwave')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mikroaaltouuni', 'mikroaaltouuni',
      (select form_name_en from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro'),
      (select why_en from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro'),
      (select meaning_en from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro'),
      (select lemma_meaning_en from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro'),
      'nominative singular', 'Speech uses the short word mikro. Books write mikroaaltouuni.', 'microwave', 'microwave';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-a0518fcf4ae6');
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
  if not exists (select 1 from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvitauko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahvitauko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sn][Ny]i[Bh][Bc][Ln][Xp]tauko[X]tauko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+kahvi(kahvi)+tauko(tauko)"}'::jsonb,
      'kahvitauko', 'kahvitauko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee break', 'coffee break', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-73c4a7a1b7bc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvitauko', 'kahvitauko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee break', 'coffee break')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvitauko', 'kahvitauko',
      (select form_name_en from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko'),
      (select why_en from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko'),
      (select meaning_en from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee break', 'coffee break';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yleensä', 'CLASS=seikkasana', '{"BASEFORM":"yleensä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]yleensä[X]yleensä","STRUCTURE":"=ppppppp","WORDBASES":"+yleensä(yleensä)"}'::jsonb,
      'yleensä', 'yleensä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'usually', 'usually', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-61ead601df18');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yleensä', 'yleensä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'usually', 'usually')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yleensä', 'yleensä',
      (select form_name_en from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä'),
      (select why_en from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä'),
      (select meaning_en from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä'),
      (select lemma_meaning_en from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'usually', 'usually';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kymmenen', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kymmenen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kymmenen[X][Sabl][Ny]kymmeneltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppppp","WORDBASES":"+kymmenen(kymmenen)"}'::jsonb,
      'kymmeneltä', 'kymmeneltä',
      'ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-ee593c3c593a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kymmeneltä', 'kymmenen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kymmeneltä', 'kymmenen',
      (select form_name_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select why_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select lemma_meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      'ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sabl][Ny]hdelta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kahdelta', 'kahelta',
      'ablative singular', 'Kaksi with -lta for ''at'' a clock time: kahdelta. Speech drops the d: kahelta.', 'at two', 'two', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-0f7620589a73');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdelta', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Kaksi with -lta for ''at'' a clock time: kahdelta. Speech drops the d: kahelta.', 'at two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdelta', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'),
      'ablative singular', 'Kaksi with -lta for ''at'' a clock time: kahdelta. Speech drops the d: kahelta.', 'at two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lounas', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lounas","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]lounas[X]louna[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+lounas(lounas)"}'::jsonb,
      'lounas', 'lounas',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch', 'lunch', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-beae80faab43');
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
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puol[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puoli', 'puol',
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-31b91a2acd2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puoli', 'puoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puoli', 'puoli',
      (select form_name_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select why_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select lemma_meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksitoista', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksitoista","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]toista[Xp][X]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+kaksitoista"}'::jsonb,
      'kaksitoista', 'kakstoist',
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-b32a414e973b');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennään', 'mennään',
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-e184450d7d09');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennään', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennään', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sine][Ny]hdessä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhdessä', 'yhdessä',
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one', 'approved', now(), 'content/approvals/part-4.json#wheres-the-coffee-room/form-9f03b11b2b04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhdessä', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhdessä', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Aino, mis on kahvihuone?',
    'Aino, missä on kahvihuone?', 'Aino, where''s the coffee room?',
    'wheres-the-coffee-room/1-puhe-7bbfc7634332.mp3', 'wheres-the-coffee-room/1-kirja-53b49f8bd94b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aino', null),
    (v_line_id, 'kirja', 2, 'missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kahvihuone', (select id from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone')),
    (v_line_id, 'puhe', 1, 'Aino', null),
    (v_line_id, 'puhe', 2, 'mis', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'mis')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kahvihuone', (select id from public.forms where lemma = 'kahvihuone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvihuone' and surface_puhe = 'kahvihuone'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Aino', 'Käytävän pääs, vasemmal.',
    'Käytävän päässä, vasemmalla.', 'At the end of the corridor, on the left.',
    'wheres-the-coffee-room/2-puhe-09f3af6876d4.mp3', 'wheres-the-coffee-room/2-kirja-8f1384fdad45.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Käytävän', (select id from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän')),
    (v_line_id, 'kirja', 2, 'päässä', (select id from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs')),
    (v_line_id, 'kirja', 3, 'vasemmalla', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal')),
    (v_line_id, 'puhe', 1, 'Käytävän', (select id from public.forms where lemma = 'käytävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'käytävän' and surface_puhe = 'käytävän')),
    (v_line_id, 'puhe', 2, 'pääs', (select id from public.forms where lemma = 'pää' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'päässä' and surface_puhe = 'pääs')),
    (v_line_id, 'puhe', 3, 'vasemmal', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Onks siel kahvinkeitin?',
    'Onko siellä kahvinkeitin?', 'Is there a coffee maker there?',
    'wheres-the-coffee-room/3-puhe-5d53408e133e.mp3', 'wheres-the-coffee-room/3-kirja-aed2ee4f5afc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 3, 'kahvinkeitin', (select id from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 3, 'kahvinkeitin', (select id from public.forms where lemma = 'kahvinkeitin' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvinkeitin' and surface_puhe = 'kahvinkeitin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Aino', 'On, ja jääkaappi ja mikro.',
    'On, ja jääkaappi ja mikroaaltouuni.', 'Yes, and a fridge and a microwave.',
    'wheres-the-coffee-room/4-puhe-c2d544136a5d.mp3', 'wheres-the-coffee-room/4-kirja-e4f68b50bbc1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'jääkaappi', (select id from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'mikroaaltouuni', (select id from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'jääkaappi', (select id from public.forms where lemma = 'jääkaappi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jääkaappi' and surface_puhe = 'jääkaappi')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'mikro', (select id from public.forms where lemma = 'mikroaaltouuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikroaaltouuni' and surface_puhe = 'mikro'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Millon on kahvitauko?',
    'Milloin on kahvitauko?', 'When''s the coffee break?',
    'wheres-the-coffee-room/5-puhe-16c0119fe051.mp3', 'wheres-the-coffee-room/5-kirja-53315cd9220b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'kahvitauko', (select id from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko')),
    (v_line_id, 'puhe', 1, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kahvitauko', (select id from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Aino', 'Yleensä kymmeneltä ja kahelta.',
    'Yleensä kymmeneltä ja kahdelta.', 'Usually at ten and at two.',
    'wheres-the-coffee-room/6-puhe-53648bfd6b12.mp3', 'wheres-the-coffee-room/6-kirja-84de76fd9de0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Yleensä', (select id from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä')),
    (v_line_id, 'kirja', 2, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä')),
    (v_line_id, 'kirja', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'kahdelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta')),
    (v_line_id, 'puhe', 1, 'Yleensä', (select id from public.forms where lemma = 'yleensä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yleensä' and surface_puhe = 'yleensä')),
    (v_line_id, 'puhe', 2, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä')),
    (v_line_id, 'puhe', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'kahelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Entä lounas?',
    'Entä lounas?', 'And lunch?',
    'wheres-the-coffee-room/7-puhe-9f819d4f6314.mp3', 'wheres-the-coffee-room/7-kirja-e5b537723a3c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'lounas', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'lounas', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounas' and surface_puhe = 'lounas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Aino', 'Puol kakstoist. Mennään yhdessä!',
    'Puoli kaksitoista. Mennään yhdessä!', 'Half past eleven. Let''s go together!',
    'wheres-the-coffee-room/8-puhe-6176b1793a76.mp3', 'wheres-the-coffee-room/8-kirja-b637a9a7a2d8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'kirja', 2, 'kaksitoista', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'kirja', 3, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'kirja', 4, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'puhe', 1, 'Puol', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'puhe', 2, 'kakstoist', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'puhe', 3, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'puhe', 4, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#wheres-the-coffee-room/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
