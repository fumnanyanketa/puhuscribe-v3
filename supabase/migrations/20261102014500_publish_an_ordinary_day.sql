-- Publishes the dialogue an-ordinary-day (unit a-day-in-my-life). Made by
-- scripts/generate/pipeline.py publish from content/drafts/an-ordinary-day. Do not edit by hand:
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
    where slug = 'an-ordinary-day' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'an-ordinary-day';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 36
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'a-day-in-my-life' and position = 36 and stop_number = 36;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'a-day-in-my-life';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'an-ordinary-day', 1,
    'An ordinary day')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'an-ordinary-day' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'An ordinary day';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'an-ordinary-day';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('millainen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"millainen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]millainen[X]millai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+millainen(millainen)"}'::jsonb,
      'millainen', 'millanen',
      'nominative singular', 'This is the dictionary form. Speech drops the i: millanen.', 'what kind of, what is it like', 'what kind of, what like', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-10f24428d034');
  end if;
  if not exists (select 1 from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'millainen', 'millainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. Speech drops the i: millanen.', 'what kind of, what is it like', 'what kind of, what like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'millainen', 'millainen',
      (select form_name_en from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen'),
      (select why_en from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen'),
      (select meaning_en from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen'),
      (select lemma_meaning_en from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen'),
      'nominative singular', 'This is the dictionary form. Speech drops the i: millanen.', 'what kind of, what is it like', 'what kind of, what like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tavallinen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tavallinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]tapa[X]tava[Ll]lli[Xj]nen[X][Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppppp","WORDBASES":"+tava(tapa)+lli+nen(+nen)"}'::jsonb,
      'tavallinen', 'tavallinen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ordinary, usual', 'ordinary, usual', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-70633fe1dac9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tavallinen', 'tavallinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'ordinary, usual', 'ordinary, usual')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tavallinen', 'tavallinen',
      (select form_name_en from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen'),
      (select why_en from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen'),
      (select meaning_en from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen'),
      (select lemma_meaning_en from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ordinary, usual', 'ordinary, usual';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päiväsi', 'päivä',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': päiväsi. Speech drops it and says sun päivä instead.', 'your day', 'day', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-b6b567b7e087');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päiväsi', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books add -si for ''your'': päiväsi. Speech drops it and says sun päivä instead.', 'your day', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päiväsi', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä'),
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': päiväsi. Speech drops it and says sun päivä instead.', 'your day', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensin', 'CLASS=seikkasana', '{"BASEFORM":"ensin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensin[X]ensin","STRUCTURE":"=ppppp","WORDBASES":"+ensin(ensin)"}'::jsonb,
      'ensin', 'ensin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-021cabf1d941');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensin', 'ensin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensin', 'ensin',
      (select form_name_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select why_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      (select lemma_meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'first', 'first';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('herätä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"herätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]herätä[X]herää[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+herätä(herätä)"}'::jsonb,
      'herään', 'herään',
      'present tense, 1st person singular', 'Herätä means to wake up. -n goes with minä: herään.', 'I wake up', 'to wake up', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-f7491ad341d8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'herään', 'herätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Herätä means to wake up. -n goes with minä: herään.', 'I wake up', 'to wake up')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'herään', 'herätä',
      (select form_name_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään'),
      (select why_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään'),
      (select meaning_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään'),
      (select lemma_meaning_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään'),
      'present tense, 1st person singular', 'Herätä means to wake up. -n goes with minä: herään.', 'I wake up', 'to wake up';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuusi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kuusi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kuusi[X]kuu[Sabl][Ny]delta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kuusi(kuusi)"}'::jsonb,
      'kuudelta', 'kuudelta',
      'ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-e9d72c78c633');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuudelta', 'kuusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuudelta', 'kuusi',
      (select form_name_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select why_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select lemma_meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      'ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juoda', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"juoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]juoda[X]juo[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+juoda(juoda)"}'::jsonb,
      'juon', 'juon',
      'present tense, 1st person singular', 'Juoda means to drink. -n goes with minä: juon.', 'I drink', 'to drink', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-cdf6effbf7c8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juon', 'juoda';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Juoda means to drink. -n goes with minä: juon.', 'I drink', 'to drink')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juon', 'juoda',
      (select form_name_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon'),
      (select why_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon'),
      (select meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon'),
      (select lemma_meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon'),
      'present tense, 1st person singular', 'Juoda means to drink. -n goes with minä: juon.', 'I drink', 'to drink';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kahvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kahvi(kahvi)"}'::jsonb,
      'kahvia', 'kahvia',
      'partitive singular', 'The partitive adds -a for ''some'': kahvia. Here speech says it the same way.', 'coffee', 'coffee', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-304ceaba3156');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvia', 'kahvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive adds -a for ''some'': kahvia. Here speech says it the same way.', 'coffee', 'coffee')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvia', 'kahvi',
      (select form_name_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'),
      (select why_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'),
      (select meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'),
      'partitive singular', 'The partitive adds -a for ''some'': kahvia. Here speech says it the same way.', 'coffee', 'coffee';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aikainen', 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"aikainen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]aika[X]aika[Ll][Xj]inen[X]is[Sin][Nm]in","NUMBER":"plural","SIJAMUOTO":"keinonto","STRUCTURE":"=pppppppp","WORDBASES":"+aika(aika)+inen(+inen)"}'::jsonb,
      'aikaisin', 'aikasin',
      'instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-54a1444a5f36');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aikaisin', 'aikainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aikaisin', 'aikainen',
      (select form_name_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select why_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select meaning_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select lemma_meaning_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      'instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-ad4c189b50dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitten', 'sitten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitten', 'sitten',
      (select form_name_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select why_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select lemma_meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viedä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"viedä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]viedä[X]vie[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+viedä(viedä)"}'::jsonb,
      'vien', 'vien',
      'present tense, 1st person singular', 'Viedä means to take. -n goes with minä: vien.', 'I take', 'to take (somewhere), to take (time)', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-da3d93d8082d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vien', 'viedä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Viedä means to take. -n goes with minä: vien.', 'I take', 'to take (somewhere), to take (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vien', 'viedä',
      (select form_name_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien'),
      (select why_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien'),
      (select meaning_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien'),
      (select lemma_meaning_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien'),
      'present tense, 1st person singular', 'Viedä means to take. -n goes with minä: vien.', 'I take', 'to take (somewhere), to take (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"lapsi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lapsi[X]la[Sn][Nm]pset","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+lapsi(lapsi)"}'::jsonb,
      'lapset', 'lapset',
      'nominative plural', 'Adds -t for more than one: lapsi becomes lapset.', 'the kids', 'child', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-b8167c6a0fcc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lapset', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: lapsi becomes lapset.', 'the kids', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lapset', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset'),
      'nominative plural', 'Adds -t for more than one: lapsi becomes lapset.', 'the kids', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päiväkoti', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"päiväkoti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä[Bh][Bc][Ln][Xp]koti[X]kot[Sill][Ny]iin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+päivä(päivä)+koti(koti)"}'::jsonb,
      'päiväkotiin', 'päiväkotiin',
      'illative singular', 'Adds -iin for ''to'': päiväkoti becomes päiväkotiin.', 'to daycare', 'daycare, nursery', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-b36acf278400');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päiväkotiin', 'päiväkoti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -iin for ''to'': päiväkoti becomes päiväkotiin.', 'to daycare', 'daycare, nursery')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päiväkotiin', 'päiväkoti',
      (select form_name_en from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin'),
      (select why_en from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin'),
      (select meaning_en from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin'),
      (select lemma_meaning_en from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin'),
      'illative singular', 'Adds -iin for ''to'': päiväkoti becomes päiväkotiin.', 'to daycare', 'daycare, nursery';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koulu', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"koulu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Ion][Xp]koulu[X]kouluu[Sill][Ny]n","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+koulu(koulu)"}'::jsonb,
      'kouluun', 'kouluun',
      'illative singular', 'Adds -un for ''to'': koulu becomes kouluun.', 'to school', 'school', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-a7c810b281f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kouluun', 'koulu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -un for ''to'': koulu becomes kouluun.', 'to school', 'school')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kouluun', 'koulu',
      (select form_name_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun'),
      (select why_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun'),
      (select meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun'),
      (select lemma_meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun'),
      'illative singular', 'Adds -un for ''to'': koulu becomes kouluun.', 'to school', 'school';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sill][Nm]ihin","NUMBER":"plural","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töihin', 'töihin',
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-74a674b54acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töihin', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töihin', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juuri', 'CLASS=seikkasana', '{"BASEFORM":"juuri","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]juuri[X]juuri","STRUCTURE":"=ppppp","WORDBASES":"+juuri(juuri)"}'::jsonb,
      'juuri', 'just',
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-57dd552fb07a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juuri', 'juuri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juuri', 'juuri',
      (select form_name_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select why_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select lemma_meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-4f1448504014');
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niin', 'niin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niin', 'niin',
      (select form_name_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select why_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select lemma_meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-7588912c8134');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olen', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sine][Nm]issä","NUMBER":"plural","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töissä', 'töis',
      'inessive plural', 'The inessive plural of työ: töissä, ''at work''. Speech shortens -ssä to -s: töissä becomes töis.', 'at work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-fe490b0ce11e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töissä', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive plural', 'The inessive plural of työ: töissä, ''at work''. Speech shortens -ssä to -s: töissä becomes töis.', 'at work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töissä', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis'),
      'inessive plural', 'The inessive plural of työ: töissä, ''at work''. Speech shortens -ssä to -s: töissä becomes töis.', 'at work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahdeksan', 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"kahdeksan","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kahdeksan[X]kahdeks[Sela][Ny]asta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppppppp","WORDBASES":"+kahdeksan(kahdeksan)"}'::jsonb,
      'kahdeksasta', 'kaheksast',
      'elative singular', 'Adds -sta for ''from'': kahdeksan becomes kahdeksasta. Speech says kaheksast.', 'from eight', 'eight', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-e402dad8383f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdeksasta', 'kahdeksan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Adds -sta for ''from'': kahdeksan becomes kahdeksasta. Speech says kaheksast.', 'from eight', 'eight')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdeksasta', 'kahdeksan',
      (select form_name_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast'),
      (select why_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast'),
      (select meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast'),
      (select lemma_meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast'),
      'elative singular', 'Adds -sta for ''from'': kahdeksan becomes kahdeksasta. Speech says kaheksast.', 'from eight', 'eight';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sill][Ny]ään","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljään', 'neljään',
      'illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-a83956a0f1a5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neljään', 'neljä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neljään', 'neljä',
      (select form_name_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select why_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select lemma_meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      'illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-73c5475313cb');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-9f0f9f1fdd21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'me', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Me means we. People say it the same way.', 'we', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'me', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syödä', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"syödä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]syödä[X]syö[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+syödä(syödä)"}'::jsonb,
      'syömme', 'syödään',
      'present tense, 1st person plural', 'Books write me syömme. Speech says me syödään, the same form as ''one eats'', for ''we eat''.', 'we eat', 'to eat', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-41e301f64189');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syömme', 'syödä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write me syömme. Speech says me syödään, the same form as ''one eats'', for ''we eat''.', 'we eat', 'to eat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syömme', 'syödä',
      (select form_name_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään'),
      (select why_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään'),
      (select meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään'),
      (select lemma_meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään'),
      'present tense, 1st person plural', 'Books write me syömme. Speech says me syödään, the same form as ''one eats'', for ''we eat''.', 'we eat', 'to eat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sine][Ny]hdessä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhdessä', 'yhdessä',
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-9f03b11b2b04');
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
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('loppu', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"loppu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]loppu[X]lopu[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+loppu(loppu)"}'::jsonb,
      'lopuksi', 'lopuks',
      'translative singular', 'A fixed word meaning ''finally'', from loppu, ''end''. Speech drops the last i.', 'finally, last', 'end', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-c549ca8e5bd2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lopuksi', 'loppu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'A fixed word meaning ''finally'', from loppu, ''end''. Speech drops the last i.', 'finally, last', 'end')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lopuksi', 'loppu',
      (select form_name_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks'),
      (select why_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks'),
      (select meaning_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks'),
      (select lemma_meaning_en from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks'),
      'translative singular', 'A fixed word meaning ''finally'', from loppu, ''end''. Speech drops the last i.', 'finally, last', 'end';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opiskella', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"opiskella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opiskella[X]opiskele[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+opiskella(opiskella)"}'::jsonb,
      'opiskelen', 'opiskelen',
      'present tense, 1st person singular', 'Opiskella means to study. -n goes with minä: opiskelen.', 'I study', 'to study', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-947d3d000127');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opiskelen', 'opiskella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Opiskella means to study. -n goes with minä: opiskelen.', 'I study', 'to study')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opiskelen', 'opiskella',
      (select form_name_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen'),
      (select why_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen'),
      (select meaning_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen'),
      (select lemma_meaning_en from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen'),
      'present tense, 1st person singular', 'Opiskella means to study. -n goes with minä: opiskelen.', 'I study', 'to study';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-68ca7e058498');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomea', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomea', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puol[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puoli', 'puol',
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-31b91a2acd2d');
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
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tunti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tunti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tunti[X]tunt[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+tunti(tunti)"}'::jsonb,
      'tuntia', 'tuntii',
      'partitive singular', 'After puoli, ''half'', the word takes -a: tunti becomes tuntia. Speech says tuntii.', 'hour', 'hour', 'approved', now(), 'content/approvals/part-6.json#an-ordinary-day/form-b732132ef898');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuntia', 'tunti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After puoli, ''half'', the word takes -a: tunti becomes tuntia. Speech says tuntii.', 'hour', 'hour')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuntia', 'tunti',
      (select form_name_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii'),
      (select why_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii'),
      (select meaning_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii'),
      (select lemma_meaning_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii'),
      'partitive singular', 'After puoli, ''half'', the word takes -a: tunti becomes tuntia. Speech says tuntii.', 'hour', 'hour';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Sofia', 'Millanen sun tavallinen päivä on?',
    'Millainen sinun tavallinen päiväsi on?', 'What''s your ordinary day like?',
    'an-ordinary-day/1-puhe-688b56886993.mp3', 'an-ordinary-day/1-kirja-c66e13a9bc2f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Millainen', (select id from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen')),
    (v_line_id, 'kirja', 2, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 3, 'tavallinen', (select id from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen')),
    (v_line_id, 'kirja', 4, 'päiväsi', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Millanen', (select id from public.forms where lemma = 'millainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'millainen' and surface_puhe = 'millanen')),
    (v_line_id, 'puhe', 2, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 3, 'tavallinen', (select id from public.forms where lemma = 'tavallinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tavallinen' and surface_puhe = 'tavallinen')),
    (v_line_id, 'puhe', 4, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Ensin mä herään kuudelta ja juon kahvia.',
    'Ensin minä herään kuudelta ja juon kahvia.', 'First I wake up at six and drink coffee.',
    'an-ordinary-day/2-puhe-0122e169c732.mp3', 'an-ordinary-day/2-kirja-045e3030e6db.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ensin', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'herään', (select id from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään')),
    (v_line_id, 'kirja', 4, 'kuudelta', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'juon', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon')),
    (v_line_id, 'kirja', 7, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'puhe', 1, 'Ensin', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'ensin')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'herään', (select id from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'herään' and surface_puhe = 'herään')),
    (v_line_id, 'puhe', 4, 'kuudelta', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'juon', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon')),
    (v_line_id, 'puhe', 7, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Sofia', 'Aikasin!',
    'Aikaisin!', 'Early!',
    'an-ordinary-day/3-puhe-0c67e09f56dd.mp3', 'an-ordinary-day/3-kirja-985a53162d95.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aikaisin', (select id from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin')),
    (v_line_id, 'puhe', 1, 'Aikasin', (select id from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo. Sit mä vien lapset päiväkotiin ja kouluun.',
    'Kyllä. Sitten minä vien lapset päiväkotiin ja kouluun.', 'Yes. Then I take the kids to daycare and school.',
    'an-ordinary-day/4-puhe-69e9d3b54d7c.mp3', 'an-ordinary-day/4-kirja-6603defebd48.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'vien', (select id from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien')),
    (v_line_id, 'kirja', 5, 'lapset', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset')),
    (v_line_id, 'kirja', 6, 'päiväkotiin', (select id from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin')),
    (v_line_id, 'kirja', 7, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 8, 'kouluun', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'vien', (select id from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'vien' and surface_puhe = 'vien')),
    (v_line_id, 'puhe', 5, 'lapset', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'lapset' and surface_puhe = 'lapset')),
    (v_line_id, 'puhe', 6, 'päiväkotiin', (select id from public.forms where lemma = 'päiväkoti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'päiväkotiin' and surface_puhe = 'päiväkotiin')),
    (v_line_id, 'puhe', 7, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 8, 'kouluun', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kouluun' and surface_puhe = 'kouluun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Sofia', 'Ja sit töihin?',
    'Ja sitten töihin?', 'And then to work?',
    'an-ordinary-day/5-puhe-715bea4482ca.mp3', 'an-ordinary-day/5-kirja-66ca11eb88e6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 3, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 3, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Just niin. Mä oon töis kaheksast neljään.',
    'Juuri niin. Minä olen töissä kahdeksasta neljään.', 'Exactly. I''m at work from eight to four.',
    'an-ordinary-day/6-puhe-e542f0790cb2.mp3', 'an-ordinary-day/6-kirja-ba477989e6b4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Juuri', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'kirja', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 5, 'töissä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis')),
    (v_line_id, 'kirja', 6, 'kahdeksasta', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast')),
    (v_line_id, 'kirja', 7, 'neljään', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään')),
    (v_line_id, 'puhe', 1, 'Just', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'puhe', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 5, 'töis', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'töissä' and surface_puhe = 'töis')),
    (v_line_id, 'puhe', 6, 'kaheksast', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kahdeksasta' and surface_puhe = 'kaheksast')),
    (v_line_id, 'puhe', 7, 'neljään', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Sofia', 'Entä illal?',
    'Entä illalla?', 'And in the evening?',
    'an-ordinary-day/7-puhe-f6389e3741c6.mp3', 'an-ordinary-day/7-kirja-730664c461c9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Me syödään yhdessä, ja lopuks mä opiskelen suomee puol tuntii.',
    'Me syömme yhdessä, ja lopuksi minä opiskelen suomea puoli tuntia.', 'We eat together, and last I study Finnish for half an hour.',
    'an-ordinary-day/8-puhe-070efac3a700.mp3', 'an-ordinary-day/8-kirja-e8baaee8d9ea.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 2, 'syömme', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään')),
    (v_line_id, 'kirja', 3, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'lopuksi', (select id from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks')),
    (v_line_id, 'kirja', 6, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 7, 'opiskelen', (select id from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen')),
    (v_line_id, 'kirja', 8, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 9, 'puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'kirja', 10, 'tuntia', (select id from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii')),
    (v_line_id, 'puhe', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 2, 'syödään', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään')),
    (v_line_id, 'puhe', 3, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'lopuks', (select id from public.forms where lemma = 'loppu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'lopuksi' and surface_puhe = 'lopuks')),
    (v_line_id, 'puhe', 6, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 7, 'opiskelen', (select id from public.forms where lemma = 'opiskella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opiskelen' and surface_puhe = 'opiskelen')),
    (v_line_id, 'puhe', 8, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 9, 'puol', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'puhe', 10, 'tuntii', (select id from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tuntia' and surface_puhe = 'tuntii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#an-ordinary-day/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
