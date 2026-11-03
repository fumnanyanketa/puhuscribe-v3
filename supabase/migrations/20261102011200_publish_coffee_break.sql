-- Publishes the dialogue coffee-break (unit coffee-break-and-sauna). Made by
-- scripts/generate/pipeline.py publish from content/drafts/coffee-break. Do not edit by hand:
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
    where slug = 'coffee-break' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'coffee-break';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 25
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'coffee-break-and-sauna' and position = 25 and stop_number = 25;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'coffee-break-and-sauna';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'coffee-break', 1,
    'Coffee break')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'coffee-break' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Coffee break';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'coffee-break';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvitauko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahvitauko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sn][Ny]i[Bh][Bc][Ln][Xp]tauko[X]tauko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+kahvi(kahvi)+tauko(tauko)"}'::jsonb,
      'kahvitauko', 'kahvitauko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee break', 'coffee break', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-73c4a7a1b7bc');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tuletko', 'tuuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-34727a73c81c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuletko', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuletko', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tulet (you come) with the question ending -ko: tuletko. Speech says tuuksä, glued to sä.', 'are you coming', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulen', 'tuun',
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-e0ecd37fd00f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulen', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulen', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pulla', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"pulla","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pulla[X]pull[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+pulla(pulla)"}'::jsonb,
      'pullaa', 'pullaa',
      'partitive singular', 'Adds -a for some pulla: pullaa. Pulla is a sweet Finnish bun.', 'pulla', 'sweet bun, pulla', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-7a99b1a0614b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pullaa', 'pulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a for some pulla: pullaa. Pulla is a sweet Finnish bun.', 'pulla', 'sweet bun, pulla')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pullaa', 'pulla',
      (select form_name_en from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa'),
      (select why_en from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa'),
      (select meaning_en from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa'),
      (select lemma_meaning_en from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa'),
      'partitive singular', 'Adds -a for some pulla: pullaa. Pulla is a sweet Finnish bun.', 'pulla', 'sweet bun, pulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuoda', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tuoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tuoda[X]to[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+tuoda(tuoda)"}'::jsonb,
      'toi', 'toi',
      'past tense, 3rd person singular', 'Tuoda changes to toi for something that already happened. It looks like toi (that) in speech.', 'brought', 'to bring', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-b62ee3efa2cf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toi', 'tuoda';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Tuoda changes to toi for something that already happened. It looks like toi (that) in speech.', 'brought', 'to bring')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toi', 'tuoda',
      (select form_name_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi'),
      (select why_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi'),
      (select meaning_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi'),
      (select lemma_meaning_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi'),
      'past tense, 3rd person singular', 'Tuoda changes to toi for something that already happened. It looks like toi (that) in speech.', 'brought', 'to bring';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('korvapuusti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"korvapuusti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]korva=puusti[X]korva[Bm]puust[Sp][Nm]eja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+korvapuusti(korva=puusti)"}'::jsonb,
      'korvapuusteja', 'korvapuusteja',
      'partitive plural', 'Plural ''some'' takes -ja: korvapuusti becomes korvapuusteja, i turning into e.', 'cinnamon buns', 'cinnamon bun', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-30e82dda97da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'korvapuusteja', 'korvapuusti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ja: korvapuusti becomes korvapuusteja, i turning into e.', 'cinnamon buns', 'cinnamon bun')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'korvapuusteja', 'korvapuusti',
      (select form_name_en from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja'),
      (select why_en from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja'),
      (select meaning_en from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja'),
      (select lemma_meaning_en from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja'),
      'partitive plural', 'Plural ''some'' takes -ja: korvapuusti becomes korvapuusteja, i turning into e.', 'cinnamon buns', 'cinnamon bun';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('leipoa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"leipoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]leipoa[X]leivo[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+leipoa(leipoa)"}'::jsonb,
      'leivoin', 'leivoin',
      'past tense, 1st person singular', 'Leipoa changes to leivo- with -i- for the past and -n for ''I'': leivoin.', 'I baked', 'to bake', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-bc9bfb8b934d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'leivoin', 'leipoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Leipoa changes to leivo- with -i- for the past and -n for ''I'': leivoin.', 'I baked', 'to bake')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'leivoin', 'leipoa',
      (select form_name_en from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin'),
      (select why_en from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin'),
      (select meaning_en from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin'),
      (select lemma_meaning_en from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin'),
      'past tense, 1st person singular', 'Leipoa changes to leivo- with -i- for the past and -n for ''I'': leivoin.', 'I baked', 'to bake';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sn][Nm]e","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+ne(ne)"}'::jsonb,
      'ne', 'ne',
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-18803b094966');
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
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eilen', 'CLASS=seikkasana', '{"BASEFORM":"eilen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eilen[X]eilen","STRUCTURE":"=ppppp","WORDBASES":"+eilen(eilen)"}'::jsonb,
      'eilen', 'eilen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-937949f7d75d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eilen', 'eilen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eilen', 'eilen',
      (select form_name_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select why_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select lemma_meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]otta[Tk][Ap][P2][Nm][Ef]kaa","MOOD":"imperative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ottakaa', 'ottakaa',
      'imperative present tense, 2nd person plural', 'Adds -kaa to tell more than one person: ottakaa, ''take''.', 'help yourselves', 'to take', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-5e8584fb0486');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ottakaa', 'ottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person plural', 'Adds -kaa to tell more than one person: ottakaa, ''take''.', 'help yourselves', 'to take')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ottakaa', 'ottaa',
      (select form_name_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa'),
      (select why_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa'),
      (select meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa'),
      'imperative present tense, 2nd person plural', 'Adds -kaa to tell more than one person: ottakaa, ''take''.', 'help yourselves', 'to take';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-26f45640039d');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sp][Nm]iä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyviä', 'hyviä',
      'partitive plural', 'Hyvä becomes hyviä when talking about several things, here the buns.', 'good', 'good', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-1f5a8660e44b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyviä', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Hyvä becomes hyviä when talking about several things, here the buns.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyviä', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä'),
      'partitive plural', 'Hyvä becomes hyviä when talking about several things, here the buns.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juoda', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"juoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]juoda[X]juo[Tt][Ap][P2][Nm][Ef]tte[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+juoda(juoda)"}'::jsonb,
      'juotteko', 'juotteks',
      'present tense, 2nd person plural, with the question ending -ko/-kö', 'Juotte (you all drink) with the question ending -ko: juotteko. Speech says juotteks.', 'do you drink', 'to drink', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-cdab0b5aa901');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juotteko', 'juoda';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural, with the question ending -ko/-kö', 'Juotte (you all drink) with the question ending -ko: juotteko. Speech says juotteks.', 'do you drink', 'to drink')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juotteko', 'juoda',
      (select form_name_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks'),
      (select why_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks'),
      (select meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks'),
      (select lemma_meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks'),
      'present tense, 2nd person plural, with the question ending -ko/-kö', 'Juotte (you all drink) with the question ending -ko: juotteko. Speech says juotteks.', 'do you drink', 'to drink';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-2aeedafa15c7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'te', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'te', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aina', 'CLASS=seikkasana', '{"BASEFORM":"aina","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aina[X]aina","STRUCTURE":"=pppp","WORDBASES":"+aina(aina)"}'::jsonb,
      'aina', 'aina',
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-2f65b514975a');
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
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('näin', 'CLASS=seikkasana', '{"BASEFORM":"näin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]näin[X]näin","STRUCTURE":"=pppp","WORDBASES":"+näin(näin)"}'::jsonb,
      'näin', 'näin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-263e1e1ab533');
  end if;
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näin', 'näin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näin', 'näin',
      (select form_name_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select why_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select meaning_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select lemma_meaning_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kahvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kahvi(kahvi)"}'::jsonb,
      'kahvia', 'kahvia',
      'partitive singular', 'The partitive adds -a for ''some'': kahvia. Here speech says it the same way.', 'coffee', 'coffee', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-304ceaba3156');
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
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sn][Nm]set","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaiset', 'suomalaiset',
      'nominative plural', 'Adds -t for more than one: suomalainen becomes suomalaiset.', 'Finns', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-d650ab7ed15c');
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
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juoda', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"juoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]juoda[X]juo[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+juoda(juoda)"}'::jsonb,
      'juovat', 'juo',
      'present tense, 3rd person plural', 'Books add -vat for ''they'': juovat. Speech uses the he or she form: juo.', 'they drink', 'to drink', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-19e6c8ac55da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juovat', 'juoda';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books add -vat for ''they'': juovat. Speech uses the he or she form: juo.', 'they drink', 'to drink')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juovat', 'juoda',
      (select form_name_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo'),
      (select why_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo'),
      (select meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo'),
      (select lemma_meaning_en from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo'),
      'present tense, 3rd person plural', 'Books add -vat for ''they'': juovat. Speech uses the he or she form: juo.', 'they drink', 'to drink';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eniten', 'CLASS=seikkasana', '{"BASEFORM":"eniten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eniten[X]eniten","STRUCTURE":"=pppppp","WORDBASES":"+eniten(eniten)"}'::jsonb,
      'eniten', 'eniten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'the most', 'the most', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-e188dedd701d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eniten', 'eniten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'the most', 'the most')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eniten', 'eniten',
      (select form_name_en from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten'),
      (select why_en from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten'),
      (select meaning_en from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten'),
      (select lemma_meaning_en from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'the most', 'the most';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maailma', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"maailma","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]maailma[X]maailma[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppppp","WORDBASES":"+maailma(maailma)"}'::jsonb,
      'maailmassa', 'maailmas',
      'inessive singular', 'Adds -ssa for ''in'': maailma becomes maailmassa. Speech shortens -ssa to -s: maailmassa becomes maailmas.', 'in the world', 'world', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-6debbc157c4d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maailmassa', 'maailma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': maailma becomes maailmassa. Speech shortens -ssa to -s: maailmassa becomes maailmas.', 'in the world', 'world')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maailmassa', 'maailma',
      (select form_name_en from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas'),
      (select why_en from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas'),
      (select meaning_en from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas'),
      (select lemma_meaning_en from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas'),
      'inessive singular', 'Adds -ssa for ''in'': maailma becomes maailmassa. Speech shortens -ssa to -s: maailmassa becomes maailmas.', 'in the world', 'world';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin', '{"BASEFORM":"minä","CLASS":"asemosana","FOCUS":"kin","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä[Fkin][Ef]kin","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minäkin', 'mäkin',
      'nominative singular, with -kin (also)', 'Minä with -kin, ''too'': minäkin. Speech shortens it to mäkin.', 'I too', 'I, me', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-6b38f0a500cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minäkin', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with -kin (also)', 'Minä with -kin, ''too'': minäkin. Speech shortens it to mäkin.', 'I too', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minäkin', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin'),
      'nominative singular, with -kin (also)', 'Minä with -kin, ''too'': minäkin. Speech shortens it to mäkin.', 'I too', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opetella', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"opetella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opet[Xj]ella[X]tele[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+opet(opettaa)+ella(+ella)"}'::jsonb,
      'opettelen', 'opettelen',
      'present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-d0e407cc4c7c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettelen', 'opetella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettelen', 'opetella',
      (select form_name_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select why_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select meaning_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select lemma_meaning_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      'present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lisä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lisä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lisä[X]lis[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lisä(lisä)"}'::jsonb,
      'lisää', 'santsia',
      'partitive singular', 'Books write lisää. Speech often says santsia, mostly about more food.', 'more', 'extra, addition', 'approved', now(), 'content/approvals/part-5.json#coffee-break/form-46eea774eb8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lisää', 'lisä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Books write lisää. Speech often says santsia, mostly about more food.', 'more', 'extra, addition')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lisää', 'lisä',
      (select form_name_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia'),
      (select why_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia'),
      (select meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia'),
      (select lemma_meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia'),
      'partitive singular', 'Books write lisää. Speech often says santsia, mostly about more food.', 'more', 'extra, addition';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Kahvitauko! Tuuksä?',
    'Kahvitauko! Tuletko sinä?', 'Coffee break! Are you coming?',
    'coffee-break/1-puhe-21c605677255.mp3', 'coffee-break/1-kirja-fc3b8d55ed01.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kahvitauko', (select id from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko')),
    (v_line_id, 'kirja', 2, 'Tuletko', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 1, 'Kahvitauko', (select id from public.forms where lemma = 'kahvitauko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvitauko' and surface_puhe = 'kahvitauko')),
    (v_line_id, 'puhe', 2, 'Tuuk', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tuletko' and surface_puhe = 'tuuk')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Joo, mä tuun. Onks pullaa?',
    'Kyllä, minä tulen. Onko pullaa?', 'Yes, I''m coming. Is there pulla?',
    'coffee-break/2-puhe-38669395f9fc.mp3', 'coffee-break/2-kirja-dcecdb9d2f59.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulen', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'kirja', 4, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 5, 'pullaa', (select id from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tuun', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'puhe', 4, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 5, 'pullaa', (select id from public.forms where lemma = 'pulla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'pullaa' and surface_puhe = 'pullaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'On! Aino toi korvapuusteja.',
    'On! Aino toi korvapuusteja.', 'Yes! Aino brought cinnamon buns.',
    'coffee-break/3-puhe-525f8f609172.mp3', 'coffee-break/3-kirja-a1f477d1450d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'Aino', null),
    (v_line_id, 'kirja', 3, 'toi', (select id from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi')),
    (v_line_id, 'kirja', 4, 'korvapuusteja', (select id from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'Aino', null),
    (v_line_id, 'puhe', 3, 'toi', (select id from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'toi' and surface_puhe = 'toi')),
    (v_line_id, 'puhe', 4, 'korvapuusteja', (select id from public.forms where lemma = 'korvapuusti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'korvapuusteja' and surface_puhe = 'korvapuusteja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Aino', 'Mä leivoin ne eilen. Ottakaa!',
    'Minä leivoin ne eilen. Ottakaa!', 'I baked them yesterday. Help yourselves!',
    'coffee-break/4-puhe-08826c185007.mp3', 'coffee-break/4-kirja-bd1f5db32119.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'leivoin', (select id from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin')),
    (v_line_id, 'kirja', 3, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 4, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'kirja', 5, 'Ottakaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'leivoin', (select id from public.forms where lemma = 'leipoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'leivoin' and surface_puhe = 'leivoin')),
    (v_line_id, 'puhe', 3, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 4, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'puhe', 5, 'Ottakaa', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ottakaa' and surface_puhe = 'ottakaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Tosi hyviä! Juotteks te aina näin paljon kahvia?',
    'Todella hyviä! Juotteko te aina näin paljon kahvia?', 'Really good! Do you always drink this much coffee?',
    'coffee-break/5-puhe-dfd5383fa229.mp3', 'coffee-break/5-kirja-611817439a8c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 2, 'hyviä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä')),
    (v_line_id, 'kirja', 3, 'Juotteko', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks')),
    (v_line_id, 'kirja', 4, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'kirja', 6, 'näin', (select id from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin')),
    (v_line_id, 'kirja', 7, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 8, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'puhe', 1, 'Tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 2, 'hyviä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyviä' and surface_puhe = 'hyviä')),
    (v_line_id, 'puhe', 3, 'Juotteks', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'juotteko' and surface_puhe = 'juotteks')),
    (v_line_id, 'puhe', 4, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'puhe', 6, 'näin', (select id from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin')),
    (v_line_id, 'puhe', 7, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 8, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Ville', 'Joo. Suomalaiset juo eniten kahvia maailmas.',
    'Kyllä. Suomalaiset juovat eniten kahvia maailmassa.', 'Yes. Finns drink the most coffee in the world.',
    'coffee-break/6-puhe-3074b3b77448.mp3', 'coffee-break/6-kirja-15560a0ee0a6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Suomalaiset', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset')),
    (v_line_id, 'kirja', 3, 'juovat', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo')),
    (v_line_id, 'kirja', 4, 'eniten', (select id from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten')),
    (v_line_id, 'kirja', 5, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'kirja', 6, 'maailmassa', (select id from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Suomalaiset', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'suomalaiset' and surface_puhe = 'suomalaiset')),
    (v_line_id, 'puhe', 3, 'juo', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juovat' and surface_puhe = 'juo')),
    (v_line_id, 'puhe', 4, 'eniten', (select id from public.forms where lemma = 'eniten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eniten' and surface_puhe = 'eniten')),
    (v_line_id, 'puhe', 5, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'puhe', 6, 'maailmas', (select id from public.forms where lemma = 'maailma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'maailmassa' and surface_puhe = 'maailmas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Sit mäkin opettelen!',
    'Sitten minäkin opettelen!', 'Then I''ll learn too!',
    'coffee-break/7-puhe-5f77c01cdb63.mp3', 'coffee-break/7-kirja-863d5f922a9f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 2, 'minäkin', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin')),
    (v_line_id, 'kirja', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen')),
    (v_line_id, 'puhe', 1, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 2, 'mäkin', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular;FOCUS=kin' and surface_kirja = 'minäkin' and surface_puhe = 'mäkin')),
    (v_line_id, 'puhe', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Aino', 'Hyvä! Santsia?',
    'Hyvä! Lisää?', 'Good! More?',
    'coffee-break/8-puhe-9291eb9df42a.mp3', 'coffee-break/8-kirja-edc78118da59.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Lisää', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Santsia', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'santsia'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#coffee-break/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
