-- Publishes the dialogue do-you-have-children (unit talking-about-family). Made by
-- scripts/generate/pipeline.py publish from content/drafts/do-you-have-children. Do not edit by hand:
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
    where slug = 'do-you-have-children' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'do-you-have-children';
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
  values (v_unit_id, 'do-you-have-children', 1,
    'Do you have children?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'do-you-have-children' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Do you have children?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'do-you-have-children';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-5eb112d9aace');
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
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"lapsi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lapsi[X]la[Sp][Nm]psia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+lapsi(lapsi)"}'::jsonb,
      'lapsia', 'lapsii',
      'partitive plural', 'Lapsi becomes lapsia in a question about having any. Speech turns the last a into i: lapsii.', 'children', 'child', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-12b8d37063cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lapsia', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Lapsi becomes lapsia in a question about having any. Speech turns the last a into i: lapsii.', 'children', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lapsia', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'),
      'partitive plural', 'Lapsi becomes lapsia in a question about having any. Speech turns the last a into i: lapsii.', 'children', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lapsi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lapsi[X]la[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lapsi(lapsi)"}'::jsonb,
      'lasta', 'lasta',
      'partitive singular', 'After a number like kaksi, the word takes -a: lapsi becomes lasta, ''two children''.', 'children (after a number)', 'child', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-91c58f01ab16');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lasta', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number like kaksi, the word takes -a: lapsi becomes lasta, ''two children''.', 'children (after a number)', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lasta', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta'),
      'partitive singular', 'After a number like kaksi, the word takes -a: lapsi becomes lasta, ''two children''.', 'children (after a number)', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vanha', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"vanha","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vanha[X]vanh[Sp][Nm]oja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+vanha(vanha)"}'::jsonb,
      'vanhoja', 'vanhoja',
      'partitive plural', 'Vanha becomes vanhoja when asking about the age of several people.', 'old', 'old', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-1161283b2dc4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vanhoja', 'vanha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Vanha becomes vanhoja when asking about the age of several people.', 'old', 'old')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vanhoja', 'vanha',
      (select form_name_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja'),
      (select why_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja'),
      (select meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja'),
      (select lemma_meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja'),
      'partitive plural', 'Vanha becomes vanhoja when asking about the age of several people.', 'old', 'old';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-ae2f0cff6156');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-4ab061b662f0');
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
  if not exists (select 1 from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('poika', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"poika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]poika[X]poik[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+poika(poika)"}'::jsonb,
      'poika', 'poika',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'boy, son', 'boy, son', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-c718bd228f59');
  end if;
  if not exists (select 1 from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'poika', 'poika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'boy, son', 'boy, son')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'poika', 'poika',
      (select form_name_en from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika'),
      (select why_en from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika'),
      (select meaning_en from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika'),
      (select lemma_meaning_en from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'boy, son', 'boy, son';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viisi', 'viis',
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-56e27afb5a19');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tyttö', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tyttö","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tyttö[X]tyttö[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+tyttö(tyttö)"}'::jsonb,
      'tyttö', 'tyttö',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'girl', 'girl', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-1891b49a9b09');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tyttö', 'tyttö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'girl', 'girl')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tyttö', 'tyttö',
      (select form_name_en from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö'),
      (select why_en from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö'),
      (select meaning_en from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö'),
      (select lemma_meaning_en from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'girl', 'girl';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahdeksan', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahdeksan","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kahdeksan[X]kahdeks[Sn][Ny]an","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+kahdeksan(kahdeksan)"}'::jsonb,
      'kahdeksan', 'kaheksan',
      'nominative singular', 'Speech drops the d: kaheksan. Books write kahdeksan.', 'eight', 'eight', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-5bdfd00e7f3a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdeksan', 'kahdeksan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the d: kaheksan. Books write kahdeksan.', 'eight', 'eight')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdeksan', 'kahdeksan',
      (select form_name_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan'),
      (select why_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan'),
      (select meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan'),
      (select lemma_meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan'),
      'nominative singular', 'Speech drops the d: kaheksan. Books write kahdeksan.', 'eight', 'eight';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-483066471a02');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiva', 'kiva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiva', 'kiva',
      (select form_name_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select why_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select lemma_meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ikä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ikä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ikä[X]ik[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+ikä(ikä)"}'::jsonb,
      'ikä', 'ikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'age', 'age', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-2a9fac6ee11f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ikä', 'ikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'age', 'age')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ikä', 'ikä',
      (select form_name_en from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä'),
      (select why_en from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä'),
      (select meaning_en from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä'),
      (select lemma_meaning_en from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'age', 'age';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yksi', 'yks',
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-77de6561f822');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yksi', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yksi', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tytär', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tytär","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tytär[X]tytär[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+tytär(tytär)"}'::jsonb,
      'tytär', 'tytär',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'daughter', 'daughter', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-1846377fa291');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tytär', 'tytär';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'daughter', 'daughter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tytär', 'tytär',
      (select form_name_en from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär'),
      (select why_en from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär'),
      (select meaning_en from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär'),
      (select lemma_meaning_en from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'daughter', 'daughter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolme', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolme","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolme', 'kolme',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-9242c81b9d91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolme', 'kolme';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolme', 'kolme',
      (select form_name_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select why_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select lemma_meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three';
  end if;
  if not exists (select 1 from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('söpö', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"söpö","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]söpö[X]söpö[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+söpö(söpö)"}'::jsonb,
      'söpö', 'söpö',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'cute, sweet', 'cute, sweet', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-29364ece8e01');
  end if;
  if not exists (select 1 from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'söpö', 'söpö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'cute, sweet', 'cute, sweet')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'söpö', 'söpö',
      (select form_name_en from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö'),
      (select why_en from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö'),
      (select meaning_en from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö'),
      (select lemma_meaning_en from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'cute, sweet', 'cute, sweet';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sg][Ny]nen","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hänen', 'sen',
      'genitive singular', 'Hän (he, she) with -n for ''whose'': hänen nimensä, ''her name''. Speech uses se and says sen.', 'her', 'he, she', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-956bf17f9fd8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hänen', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Hän (he, she) with -n for ''whose'': hänen nimensä, ''her name''. Speech uses se and says sen.', 'her', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hänen', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen'),
      'genitive singular', 'Hän (he, she) with -n for ''whose'': hänen nimensä, ''her name''. Speech uses se and says sen.', 'her', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nimi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3', '{"BASEFORM":"nimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ivj][Xp]nimi[X]nim[Sn][Ny]e[O3]nsä","MALAGA_VAPAA_JALKIOSA":"true","NUMBER":"singular","POSSESSIVE":"3","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+nimi(nimi)"}'::jsonb,
      'nimensä', 'nimi',
      'nominative singular, with the possessive ending for his, her or their', 'Books add -nsä for ''his, her or their'': nimensä. Speech drops it and says sen nimi.', 'her name', 'name', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-1bbc3ba2ca0d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nimensä', 'nimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for his, her or their', 'Books add -nsä for ''his, her or their'': nimensä. Speech drops it and says sen nimi.', 'her name', 'name')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nimensä', 'nimi',
      (select form_name_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi'),
      (select why_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi'),
      (select meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi'),
      (select lemma_meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi'),
      'nominative singular, with the possessive ending for his, her or their', 'Books add -nsä for ''his, her or their'': nimensä. Speech drops it and says sen nimi.', 'her name', 'name';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhuu', 'puhuu',
      'present tense, 3rd person singular', 'Puhua doubles its last vowel for he or she: puhuu.', 'she talks', 'to speak, to talk', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-880508ea2186');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhuu', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Puhua doubles its last vowel for he or she: puhuu.', 'she talks', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhuu', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu'),
      'present tense, 3rd person singular', 'Puhua doubles its last vowel for he or she: puhuu.', 'she talks', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jo', 'CLASS=seikkasana', '{"BASEFORM":"jo","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]jo[X]jo","STRUCTURE":"=pp","WORDBASES":"+jo(jo)"}'::jsonb,
      'jo', 'jo',
      'adverb', 'This is the dictionary form. People say it the same way.', 'already', 'already', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-31092ec721a1');
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
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-26f45640039d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'todella', 'todella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'todella', 'todella',
      (select form_name_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select why_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select meaning_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select lemma_meaning_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-c89c8a769850');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paljon', 'paljon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paljon', 'paljon',
      (select form_name_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select why_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select lemma_meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s', '{"BASEFORM":"lapsi","CLASS":"nimisana","MANUAL":"true","NUMBER":"plural","POSSESSIVE":"1s","SIJAMUOTO":"nimento"}'::jsonb,
      'lapseni', 'lapset',
      'nominative plural, with the possessive ending for my', 'Lapsi, child. -set makes many, -ni adds ''my'': lapseni. Speech says mun lapset and drops -ni.', 'my children', 'child', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-9f193d6d72e6');
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
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'kans',
      'adverb', 'Speech often says kans. Books write myös.', 'too', 'also, too', 'approved', now(), 'content/approvals/part-4.json#do-you-have-children/form-300b16a8545b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myös', 'myös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often says kans. Books write myös.', 'too', 'also, too')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myös', 'myös',
      (select form_name_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans'),
      (select why_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans'),
      (select meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans'),
      (select lemma_meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans'),
      'adverb', 'Speech often says kans. Books write myös.', 'too', 'also, too';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Onks sul lapsii?',
    'Onko sinulla lapsia?', 'Do you have children?',
    'do-you-have-children/1-puhe-861174705fe6.mp3', 'do-you-have-children/1-kirja-0761bb2e414d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 3, 'lapsia', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 3, 'lapsii', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'On, mul on kaks lasta.',
    'On, minulla on kaksi lasta.', 'Yes, I have two children.',
    'do-you-have-children/2-puhe-f2db43347952.mp3', 'do-you-have-children/2-kirja-72ec2f46dfb8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 5, 'lasta', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 5, 'lasta', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lasta' and surface_puhe = 'lasta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'Kuinka vanhoja ne on?',
    'Kuinka vanhoja he ovat?', 'How old are they?',
    'do-you-have-children/3-puhe-cb46aed46ff5.mp3', 'do-you-have-children/3-kirja-f92d028bf563.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'vanhoja', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja')),
    (v_line_id, 'kirja', 3, 'he', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 4, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'vanhoja', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vanhoja' and surface_puhe = 'vanhoja')),
    (v_line_id, 'puhe', 3, 'ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Poika on viis ja tyttö kaheksan.',
    'Poika on viisi ja tyttö kahdeksan.', 'My son is five and my daughter eight.',
    'do-you-have-children/4-puhe-b7122e140d25.mp3', 'do-you-have-children/4-kirja-cd4a1c8cd3a1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Poika', (select id from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'viisi', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'tyttö', (select id from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö')),
    (v_line_id, 'kirja', 6, 'kahdeksan', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan')),
    (v_line_id, 'puhe', 1, 'Poika', (select id from public.forms where lemma = 'poika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'poika' and surface_puhe = 'poika')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'viis', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'tyttö', (select id from public.forms where lemma = 'tyttö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tyttö' and surface_puhe = 'tyttö')),
    (v_line_id, 'puhe', 6, 'kaheksan', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeksan' and surface_puhe = 'kaheksan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ville', 'Kiva ikä! Mul on yks tytär. Se on kolme.',
    'Kiva ikä! Minulla on yksi tytär. Hän on kolme.', 'Nice age! I have one daughter. She''s three.',
    'do-you-have-children/5-puhe-54105917cfe0.mp3', 'do-you-have-children/5-kirja-06561ff1cc77.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 2, 'ikä', (select id from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä')),
    (v_line_id, 'kirja', 3, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'yksi', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'kirja', 6, 'tytär', (select id from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär')),
    (v_line_id, 'kirja', 7, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 8, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 9, 'kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'puhe', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 2, 'ikä', (select id from public.forms where lemma = 'ikä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ikä' and surface_puhe = 'ikä')),
    (v_line_id, 'puhe', 3, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'yks', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'puhe', 6, 'tytär', (select id from public.forms where lemma = 'tytär' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tytär' and surface_puhe = 'tytär')),
    (v_line_id, 'puhe', 7, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 8, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 9, 'kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Söpö! Mikä sen nimi on?',
    'Söpö! Mikä hänen nimensä on?', 'Sweet! What''s her name?',
    'do-you-have-children/6-puhe-4de4b1db3356.mp3', 'do-you-have-children/6-kirja-e37145463dd9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Söpö', (select id from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö')),
    (v_line_id, 'kirja', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 3, 'hänen', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 4, 'nimensä', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Söpö', (select id from public.forms where lemma = 'söpö' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'söpö' and surface_puhe = 'söpö')),
    (v_line_id, 'puhe', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 3, 'sen', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'hänen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 4, 'nimi', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=3' and surface_kirja = 'nimensä' and surface_puhe = 'nimi')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ville', 'Ella. Se puhuu jo tosi paljon!',
    'Ella. Hän puhuu jo todella paljon!', 'Ella. She already talks a lot!',
    'do-you-have-children/7-puhe-ea2f803e1c74.mp3', 'do-you-have-children/7-kirja-69c0846ddfc8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ella', null),
    (v_line_id, 'kirja', 2, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'puhuu', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu')),
    (v_line_id, 'kirja', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'kirja', 5, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 6, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 1, 'Ella', null),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'puhuu', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhuu' and surface_puhe = 'puhuu')),
    (v_line_id, 'puhe', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'puhe', 5, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 6, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mun lapset kans!',
    'Minun lapseni myös!', 'Mine too!',
    'do-you-have-children/8-puhe-1b8b14299e9c.mp3', 'do-you-have-children/8-kirja-d7a58ac7b959.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'lapseni', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'kirja', 3, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'lapset', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'puhe', 3, 'kans', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#do-you-have-children/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
