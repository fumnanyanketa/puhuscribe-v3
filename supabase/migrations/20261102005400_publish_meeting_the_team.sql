-- Publishes the dialogue meeting-the-team (unit first-day-at-work). Made by
-- scripts/generate/pipeline.py publish from content/drafts/meeting-the-team. Do not edit by hand:
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
    where slug = 'meeting-the-team' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'meeting-the-team';
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
  values (v_unit_id, 'meeting-the-team', 1,
    'Meeting the team')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'meeting-the-team' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Meeting the team';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'meeting-the-team';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tervetuloa', 'CLASS=huudahdussana', '{"BASEFORM":"tervetuloa","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]terve=tuloa[X]terve[Bm]tuloa","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+tervetuloa(terve=tuloa)"}'::jsonb,
      'tervetuloa', 'tervetuloo',
      'interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-bd5edcd6c10a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tervetuloa', 'tervetuloa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tervetuloa', 'tervetuloa',
      (select form_name_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select why_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select meaning_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select lemma_meaning_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      'interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-4352ca83b810');
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
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensimmäinen', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ensimmäinen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]ensimmäinen[X]ensimmäi[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+ensimmäinen(ensimmäinen)"}'::jsonb,
      'ensimmäinen', 'eka',
      'nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-68b7d847fe2e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensimmäinen', 'ensimmäinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensimmäinen', 'ensimmäinen',
      (select form_name_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select why_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select meaning_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select lemma_meaning_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      'nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päiväsi', 'päivä',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': päiväsi. Speech drops it and says sun päivä instead.', 'your day', 'day', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-b6b567b7e087');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","WORDBASES":"+ei(ei)"}'::jsonb,
      'eikö', 'eiks',
      'negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-471c2ec2d2cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eikö', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eikö', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      'negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-fbf4cf6cbcf9');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jännittynyt', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"jännittynyt","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]jännittyä[X]jännitty[Ll][Ru]n[Xj]yt[X][Sn][Ny]yt","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+jännitty(jännittyä)+n+yt(+yt)"}'::jsonb,
      'jännittynyt', 'jännittyny',
      'past active participle, nominative singular', 'Describes how someone feels, from jännittyä, to get nervous. Speech drops the final t: jännittyny.', 'nervous', 'nervous, tense', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-9372cef709e6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jännittynyt', 'jännittynyt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'Describes how someone feels, from jännittyä, to get nervous. Speech drops the final t: jännittyny.', 'nervous', 'nervous, tense')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jännittynyt', 'jännittynyt',
      (select form_name_en from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny'),
      (select why_en from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny'),
      (select meaning_en from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny'),
      (select lemma_meaning_en from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny'),
      'past active participle, nominative singular', 'Describes how someone feels, from jännittyä, to get nervous. Speech drops the final t: jännittyny.', 'nervous', 'nervous, tense';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hätä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"hätä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hätä[X]hät[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hätä(hätä)"}'::jsonb,
      'hätää', 'hätää',
      'partitive singular', 'The partitive after ei: ei hätää, no worries.', 'worries', 'emergency, worry', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-83955fefc056');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'täs',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-25ac6c76f4b0');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-4ab061b662f0');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-ae2f0cff6156');
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
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiimi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"tiimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tiimi[X]tiimi[Sine][Ny]ssä[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppppp","WORDBASES":"+tiimi(tiimi)"}'::jsonb,
      'tiimissäsi', 'tiimissä',
      'inessive singular, with the possessive ending for your', 'Adds -ssa for ''in'' and -si for ''your'': tiimissäsi. Speech drops -si and says sun tiimissä.', 'on your team', 'team', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-e984ede0ed2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiimissäsi', 'tiimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular, with the possessive ending for your', 'Adds -ssa for ''in'' and -si for ''your'': tiimissäsi. Speech drops -si and says sun tiimissä.', 'on your team', 'team')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiimissäsi', 'tiimi',
      (select form_name_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä'),
      (select why_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä'),
      (select meaning_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä'),
      (select lemma_meaning_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä'),
      'inessive singular, with the possessive ending for your', 'Adds -ssa for ''in'' and -si for ''your'': tiimissäsi. Speech drops -si and says sun tiimissä.', 'on your team', 'team';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('että', 'CLASS=sidesana', '{"BASEFORM":"että","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]että[X]että","STRUCTURE":"=pppp","WORDBASES":"+että(että)"}'::jsonb,
      'että', 'et',
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-4eeca18a865d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'että', 'että';
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'että', 'että',
      (select form_name_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select why_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select lemma_meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulit', 'tulit',
      'past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-e3858e4b70af');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulit', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulit', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      'past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-2aeedafa15c7');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P2][Nm][Ef]tte","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teette', 'teette',
      'present tense, 2nd person plural', 'Tehdä changes to tee- and takes -tte for ''you all'': teette.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-b15cf493845a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teette', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural', 'Tehdä changes to tee- and takes -tte for ''you all'': teette.', 'you do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teette', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette'),
      'present tense, 2nd person plural', 'Tehdä changes to tee- and takes -tte for ''you all'': teette.', 'you do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-5bdac2fbf3a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täällä', 'täällä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täällä', 'täällä',
      (select form_name_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select why_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select lemma_meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teemme', 'tehään',
      'present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-571fca58f152');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teemme', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teemme', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      'present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asiakaspalvelu', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"asiakaspalvelu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asiakas[X]asiaka[Sn][Ny]s[Bh][Bc][Lt][Xp]palvella[X]palvel[Ln][Xj]u[X]u[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp=pppppppp","WORDBASES":"+asiakas(asiakas)+palvel(palvella)+u(+u)"}'::jsonb,
      'asiakaspalvelua', 'asiakaspalvelua',
      'partitive singular', 'Adds -a after a verb like tehdä (to do): asiakaspalvelu becomes asiakaspalvelua.', 'customer service', 'customer service', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-64f2a21397e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asiakaspalvelua', 'asiakaspalvelu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a after a verb like tehdä (to do): asiakaspalvelu becomes asiakaspalvelua.', 'customer service', 'customer service')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asiakaspalvelua', 'asiakaspalvelu',
      (select form_name_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua'),
      (select why_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua'),
      (select meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua'),
      (select lemma_meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua'),
      'partitive singular', 'Adds -a after a verb like tehdä (to do): asiakaspalvelu becomes asiakaspalvelua.', 'customer service', 'customer service';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työpiste', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"työpiste","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]työ[Sn][Ny][Bh][Bc][Ln][Xp]piste[X]piste[Sn][Ny]e[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=pppppppp","WORDBASES":"+työ(työ)+piste(piste)"}'::jsonb,
      'työpisteesi', 'työpiste',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: työpisteesi. Speech drops it and says sun työpiste.', 'your desk', 'workstation, desk', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-7882a6bda9ce');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työpisteesi', 'työpiste';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: työpisteesi. Speech drops it and says sun työpiste.', 'your desk', 'workstation, desk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työpisteesi', 'työpiste',
      (select form_name_en from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste'),
      (select why_en from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste'),
      (select meaning_en from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste'),
      (select lemma_meaning_en from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste'),
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: työpisteesi. Speech drops it and says sun työpiste.', 'your desk', 'workstation, desk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuolla', 'tuolla',
      'adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-38dbd7729054');
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
  if not exists (select 1 from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ikkuna', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"ikkuna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ikkuna[X]ikkuna[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+ikkuna(ikkuna)"}'::jsonb,
      'ikkunan', 'ikkunan',
      'genitive singular', 'Adds -n so it goes with vieressä (next to): ikkunan vieressä, ''by the window''.', 'of the window', 'window', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-04dd623f7b11');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ikkunan', 'ikkuna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n so it goes with vieressä (next to): ikkunan vieressä, ''by the window''.', 'of the window', 'window')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ikkunan', 'ikkuna',
      (select form_name_en from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan'),
      (select why_en from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan'),
      (select meaning_en from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan'),
      (select lemma_meaning_en from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan'),
      'genitive singular', 'Adds -n so it goes with vieressä (next to): ikkunan vieressä, ''by the window''.', 'of the window', 'window';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vieri', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"vieri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vieri[X]viere[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+vieri(vieri)"}'::jsonb,
      'vieressä', 'vieres',
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-a54598413b94');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vieressä', 'vieri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vieressä', 'vieri',
      (select form_name_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select why_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select lemma_meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paikka', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"paikka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]paikka[X]paikk[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+paikka(paikka)"}'::jsonb,
      'paikka', 'paikka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'place, spot', 'place, spot', 'approved', now(), 'content/approvals/part-4.json#meeting-the-team/form-3c524161831b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paikka', 'paikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'place, spot', 'place, spot')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paikka', 'paikka',
      (select form_name_en from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka'),
      (select why_en from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka'),
      (select meaning_en from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka'),
      (select lemma_meaning_en from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'place, spot', 'place, spot';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Hanna', 'Tervetuloo! Tää on sun eka päivä, eiks niin?',
    'Tervetuloa! Tämä on sinun ensimmäinen päiväsi, eikö niin?', 'Welcome! This is your first day, isn''t it?',
    'meeting-the-team/1-puhe-64c16e5fcd8e.mp3', 'meeting-the-team/1-kirja-6e5f66c07170.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tervetuloa', (select id from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo')),
    (v_line_id, 'kirja', 2, 'Tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 5, 'ensimmäinen', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'kirja', 6, 'päiväsi', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä')),
    (v_line_id, 'kirja', 7, 'eikö', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks')),
    (v_line_id, 'kirja', 8, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 1, 'Tervetuloo', (select id from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo')),
    (v_line_id, 'puhe', 2, 'Tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 5, 'eka', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'puhe', 6, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'päiväsi' and surface_puhe = 'päivä')),
    (v_line_id, 'puhe', 7, 'eiks', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks')),
    (v_line_id, 'puhe', 8, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Joo! Mä oon vähän jännittyny.',
    'Kyllä! Minä olen vähän jännittynyt.', 'Yes! I''m a bit nervous.',
    'meeting-the-team/2-puhe-7c8874727053.mp3', 'meeting-the-team/2-kirja-a8178fcadd38.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 4, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 5, 'jännittynyt', (select id from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 4, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 5, 'jännittyny', (select id from public.forms where lemma = 'jännittynyt' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'jännittynyt' and surface_puhe = 'jännittyny'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Hanna', 'Ei hätää. Täs on Ville ja Aino. Ne on sun tiimissä.',
    'Ei hätää. Tässä ovat Ville ja Aino. He ovat sinun tiimissäsi.', 'No worries. This is Ville and Aino. They''re on your team.',
    'meeting-the-team/3-puhe-48ad1ffd57a5.mp3', 'meeting-the-team/3-kirja-c9c41ff2cb41.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'kirja', 3, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'kirja', 4, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'Ville', null),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'Aino', null),
    (v_line_id, 'kirja', 8, 'He', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 9, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 10, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 11, 'tiimissäsi', (select id from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'hätää', (select id from public.forms where lemma = 'hätä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'hätää' and surface_puhe = 'hätää')),
    (v_line_id, 'puhe', 3, 'Täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'Ville', null),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'Aino', null),
    (v_line_id, 'puhe', 8, 'Ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 9, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 10, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 11, 'tiimissä', (select id from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'tiimissäsi' and surface_puhe = 'tiimissä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Ville', 'Moi Maria! Kiva et sä tulit.',
    'Hei Maria! Kiva, että sinä tulit.', 'Hi Maria! Great that you''re here.',
    'meeting-the-team/4-puhe-07656cd6c21b.mp3', 'meeting-the-team/4-kirja-b9d040cd5254.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Maria', null),
    (v_line_id, 'kirja', 3, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 4, 'että', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 5, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 6, 'tulit', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Maria', null),
    (v_line_id, 'puhe', 3, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 4, 'et', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 5, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 6, 'tulit', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Moi! Mitä te teette täällä?',
    'Hei! Mitä te teette täällä?', 'Hi! What do you do here?',
    'meeting-the-team/5-puhe-41f2254c09b8.mp3', 'meeting-the-team/5-kirja-24c491be9a33.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 3, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 4, 'teette', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette')),
    (v_line_id, 'kirja', 5, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 3, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 4, 'teette', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teette' and surface_puhe = 'teette')),
    (v_line_id, 'puhe', 5, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Ville', 'Me tehään asiakaspalvelua.',
    'Me teemme asiakaspalvelua.', 'We do customer service.',
    'meeting-the-team/6-puhe-9d3337353cca.mp3', 'meeting-the-team/6-kirja-357d28b3eb18.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 2, 'teemme', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään')),
    (v_line_id, 'kirja', 3, 'asiakaspalvelua', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua')),
    (v_line_id, 'puhe', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 2, 'tehään', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään')),
    (v_line_id, 'puhe', 3, 'asiakaspalvelua', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiakaspalvelua' and surface_puhe = 'asiakaspalvelua'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Hanna', 'Sun työpiste on tuolla ikkunan vieres.',
    'Sinun työpisteesi on tuolla ikkunan vieressä.', 'Your desk is over there by the window.',
    'meeting-the-team/7-puhe-45abe4c6fb2b.mp3', 'meeting-the-team/7-kirja-b5243022e878.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 2, 'työpisteesi', (select id from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'kirja', 5, 'ikkunan', (select id from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan')),
    (v_line_id, 'kirja', 6, 'vieressä', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres')),
    (v_line_id, 'puhe', 1, 'Sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 2, 'työpiste', (select id from public.forms where lemma = 'työpiste' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työpisteesi' and surface_puhe = 'työpiste')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'puhe', 5, 'ikkunan', (select id from public.forms where lemma = 'ikkuna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ikkunan' and surface_puhe = 'ikkunan')),
    (v_line_id, 'puhe', 6, 'vieres', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti! Tää on kiva paikka.',
    'Kiitos! Tämä on kiva paikka.', 'Thanks! This is a nice place.',
    'meeting-the-team/8-puhe-fa663e796550.mp3', 'meeting-the-team/8-kirja-c2e3a95f0644.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 5, 'paikka', (select id from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 5, 'paikka', (select id from public.forms where lemma = 'paikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikka' and surface_puhe = 'paikka'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#meeting-the-team/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
