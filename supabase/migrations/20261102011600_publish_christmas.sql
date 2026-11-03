-- Publishes the dialogue christmas (unit holidays). Made by
-- scripts/generate/pipeline.py publish from content/drafts/christmas. Do not edit by hand:
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
    where slug = 'christmas' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'christmas';
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
  values (v_unit_id, 'christmas', 2,
    'Christmas')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'christmas' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Christmas';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'christmas';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('joulu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"joulu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]joulu[X]joulu[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+joulu(joulu)"}'::jsonb,
      'joulu', 'joulu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas', 'Christmas', 'approved', now(), 'content/approvals/part-5.json#christmas/form-282360a954e2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'joulu', 'joulu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas', 'Christmas')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'joulu', 'joulu',
      (select form_name_en from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu'),
      (select why_en from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu'),
      (select meaning_en from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu'),
      (select lemma_meaning_en from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas', 'Christmas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#christmas/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sg][Ny]hden","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kahden', 'kahen',
      'genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two', 'approved', now(), 'content/approvals/part-5.json#christmas/form-c2c426a526c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahden', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahden', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      'genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikon', 'viikon',
      'genitive singular', 'The genitive singular goes before päästä ''after'': viikko becomes viikon.', 'a week (in a week)', 'week', 'approved', now(), 'content/approvals/part-5.json#christmas/form-fd2b51d3a320');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikon', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before päästä ''after'': viikko becomes viikon.', 'a week (in a week)', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikon', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon'),
      'genitive singular', 'The genitive singular goes before päästä ''after'': viikko becomes viikon.', 'a week (in a week)', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"päästä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]päästä[X]pääst[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+päästä(päästä)"}'::jsonb,
      'päästä', 'päästä',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-5.json#christmas/form-c5dcc023ac08');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päästä', 'päästä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päästä', 'päästä',
      (select form_name_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select why_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select lemma_meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'oletko', 'oot',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#christmas/form-7134b249ebd4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oletko', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oletko', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#christmas/form-ec7b2eab227a');
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
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#christmas/form-fbf4cf6cbcf9');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#christmas/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-5.json#christmas/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lentää', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"lentää","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'lennä', 'lennä',
      'present tense, negative form', 'After en the verb drops its ending: lentää becomes lennä. The nt changes to nn.', 'fly (I''m not flying)', 'to fly', 'approved', now(), 'content/approvals/part-5.json#christmas/form-d45a52012332');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lennä', 'lentää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: lentää becomes lennä. The nt changes to nn.', 'fly (I''m not flying)', 'to fly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lennä', 'lentää',
      (select form_name_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä'),
      (select why_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä'),
      (select meaning_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä'),
      (select lemma_meaning_en from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä'),
      'present tense, negative form', 'After en the verb drops its ending: lentää becomes lennä. The nt changes to nn.', 'fly (I''m not flying)', 'to fly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Ses][Ny]nä","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tänä', 'tänä',
      'essive singular', 'Tämä becomes tänä to match vuonna: tänä vuonna, ''this year''.', 'this', 'this', 'approved', now(), 'content/approvals/part-5.json#christmas/form-5f6b4549c828');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tänä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Tämä becomes tänä to match vuonna: tänä vuonna, ''this year''.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tänä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä'),
      'essive singular', 'Tämä becomes tänä to match vuonna: tänä vuonna, ''this year''.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vuosi', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"vuosi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vuosi[X]vuo[Ses][Ny]nna","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppp","WORDBASES":"+vuosi(vuosi)"}'::jsonb,
      'vuonna', 'vuonna',
      'essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year', 'approved', now(), 'content/approvals/part-5.json#christmas/form-a004c3b5e8e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vuonna', 'vuosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vuonna', 'vuosi',
      (select form_name_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select why_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      (select lemma_meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'),
      'essive singular', 'Vuosi becomes vuonna to say when: tänä vuonna, ''this year''.', 'year', 'year';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suome[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomessa', 'suomes',
      'inessive singular', 'Adds -ssa for ''in'', and si changes to e: Suomi becomes Suomessa. Speech shortens -ssa to -s: Suomessa becomes Suomes.', 'in Finland', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-5.json#christmas/form-11490962728d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomessa', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'', and si changes to e: Suomi becomes Suomessa. Speech shortens -ssa to -s: Suomessa becomes Suomes.', 'in Finland', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomessa', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes'),
      'inessive singular', 'Adds -ssa for ''in'', and si changes to e: Suomi becomes Suomessa. Speech shortens -ssa to -s: Suomessa becomes Suomes.', 'in Finland', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jouluaatto', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"jouluaatto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]joulu[X]joulu[Sn][Ny][Bh][Bc][Ln][Xp]aatto[X]aatto[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+joulu(joulu)+aatto(aatto)"}'::jsonb,
      'jouluaatto', 'jouluaatto',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas Eve', 'Christmas Eve', 'approved', now(), 'content/approvals/part-5.json#christmas/form-32b2fb97efd9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jouluaatto', 'jouluaatto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas Eve', 'Christmas Eve')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jouluaatto', 'jouluaatto',
      (select form_name_en from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto'),
      (select why_en from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto'),
      (select meaning_en from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto'),
      (select lemma_meaning_en from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Christmas Eve', 'Christmas Eve';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tärkeä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"tärkeä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Ll][Xp]tärkeä[X]tärke[Sn][Ny][Cs]in","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+tärkeä(tärkeä)"}'::jsonb,
      'tärkein', 'tärkein',
      'superlative, nominative singular', 'Tärkeä, important, with -in means ''the most'': tärkein.', 'the most important', 'important', 'approved', now(), 'content/approvals/part-5.json#christmas/form-89426e7de36b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tärkein', 'tärkeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, nominative singular', 'Tärkeä, important, with -in means ''the most'': tärkein.', 'the most important', 'important')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tärkein', 'tärkeä',
      (select form_name_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein'),
      (select why_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein'),
      (select meaning_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein'),
      (select lemma_meaning_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein'),
      'superlative, nominative singular', 'Tärkeä, important, with -in means ''the most'': tärkein.', 'the most important', 'important';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivä', 'päivä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day', 'approved', now(), 'content/approvals/part-5.json#christmas/form-178d895f9ecf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivä', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivä', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siis', 'CLASS=seikkasana', '{"BASEFORM":"siis","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siis[X]siis","STRUCTURE":"=pppp","WORDBASES":"+siis(siis)"}'::jsonb,
      'siis', 'siis',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is', 'approved', now(), 'content/approvals/part-5.json#christmas/form-e78d6a8e9d91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siis', 'siis';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siis', 'siis',
      (select form_name_en from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis'),
      (select why_en from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis'),
      (select meaning_en from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis'),
      (select lemma_meaning_en from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahdeskymmenesneljäs', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahdeskymmenesneljäs","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kahdes[X]kahde[Sn][Ny]s[Bc]kymmenes[Bc][Lu][Xp]neljäs[X]neljä[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=pppppppp=pppppp","WORDBASES":"+kahdeskymmenes(kahdes)+neljäs(neljäs)"}'::jsonb,
      'kahdeskymmenesneljäs', 'kakskytneljäs',
      'nominative singular', 'Speech shortens kahdeskymmenesneljäs to kakskytneljäs.', 'twenty-fourth', 'twenty-fourth', 'approved', now(), 'content/approvals/part-5.json#christmas/form-8e3944e8a8db');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdeskymmenesneljäs', 'kahdeskymmenesneljäs';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens kahdeskymmenesneljäs to kakskytneljäs.', 'twenty-fourth', 'twenty-fourth')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdeskymmenesneljäs', 'kahdeskymmenesneljäs',
      (select form_name_en from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs'),
      (select why_en from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs'),
      (select meaning_en from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs'),
      (select lemma_meaning_en from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs'),
      'nominative singular', 'Speech shortens kahdeskymmenesneljäs to kakskytneljäs.', 'twenty-fourth', 'twenty-fourth';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('joulukuu', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"joulukuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]joulu[X]joulu[Sn][Ny][Bh][Bc][Ln][Xp]kuu[X]kuu[Sp][Ny]ta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+joulu(joulu)+kuu(kuu)"}'::jsonb,
      'joulukuuta', 'joulukuuta',
      'partitive singular', 'A date names the month with -ta: joulukuu becomes joulukuuta.', 'of December', 'December', 'approved', now(), 'content/approvals/part-5.json#christmas/form-80b91d2bfd83');
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'joulukuuta', 'joulukuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'A date names the month with -ta: joulukuu becomes joulukuuta.', 'of December', 'December')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'joulukuuta', 'joulukuu',
      (select form_name_en from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta'),
      (select why_en from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta'),
      (select meaning_en from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta'),
      (select lemma_meaning_en from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta'),
      'partitive singular', 'A date names the month with -ta: joulukuu becomes joulukuuta.', 'of December', 'December';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juuri', 'CLASS=seikkasana', '{"BASEFORM":"juuri","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]juuri[X]juuri","STRUCTURE":"=ppppp","WORDBASES":"+juuri(juuri)"}'::jsonb,
      'juuri', 'just',
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly', 'approved', now(), 'content/approvals/part-5.json#christmas/form-57dd552fb07a');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-5.json#christmas/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-5.json#christmas/form-9f0f9f1fdd21');
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
      'present tense, 1st person plural', 'Books write me syömme. Speech says me syödään, the same form as ''one eats'', for ''we eat''.', 'we eat', 'to eat', 'approved', now(), 'content/approvals/part-5.json#christmas/form-41e301f64189');
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
  if not exists (select 1 from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kinkku', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kinkku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kinkku[X]kinkku[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+kinkku(kinkku)"}'::jsonb,
      'kinkkua', 'kinkkuu',
      'partitive singular', 'Adds -a for some ham: kinkku becomes kinkkua. Speech doubles the u: kinkkuu.', 'ham', 'ham', 'approved', now(), 'content/approvals/part-5.json#christmas/form-516a47f8ab3a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kinkkua', 'kinkku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a for some ham: kinkku becomes kinkkua. Speech doubles the u: kinkkuu.', 'ham', 'ham')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kinkkua', 'kinkku',
      (select form_name_en from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu'),
      (select why_en from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu'),
      (select meaning_en from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu'),
      (select lemma_meaning_en from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu'),
      'partitive singular', 'Adds -a for some ham: kinkku becomes kinkkua. Speech doubles the u: kinkkuu.', 'ham', 'ham';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#christmas/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laatikko', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"laatikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]laatikko[X]laatik[Sp][Nm]oita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppp","WORDBASES":"+laatikko(laatikko)"}'::jsonb,
      'laatikoita', 'laatikoita',
      'partitive plural', 'Laatikko becomes laatikoita for casseroles in general, with one k.', 'casseroles', 'casserole, box', 'approved', now(), 'content/approvals/part-5.json#christmas/form-fd8cdcd7b155');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laatikoita', 'laatikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Laatikko becomes laatikoita for casseroles in general, with one k.', 'casseroles', 'casserole, box')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laatikoita', 'laatikko',
      (select form_name_en from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita'),
      (select why_en from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita'),
      (select meaning_en from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita'),
      (select lemma_meaning_en from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita'),
      'partitive plural', 'Laatikko becomes laatikoita for casseroles in general, with one k.', 'casseroles', 'casserole, box';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-5.json#christmas/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('joulupukki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"joulupukki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]joulu[X]joulu[Sn][Ny][Bh][Bc][Ln][Xp]pukki[X]pukk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+joulu(joulu)+pukki(pukki)"}'::jsonb,
      'joulupukki', 'joulupukki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Santa Claus', 'Santa Claus', 'approved', now(), 'content/approvals/part-5.json#christmas/form-af96b7ad9fd7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'joulupukki', 'joulupukki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Santa Claus', 'Santa Claus')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'joulupukki', 'joulupukki',
      (select form_name_en from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki'),
      (select why_en from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki'),
      (select meaning_en from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki'),
      (select lemma_meaning_en from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Santa Claus', 'Santa Claus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-5.json#christmas/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ap][P3][Ny][Ef]ee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulee', 'tulee',
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come', 'approved', now(), 'content/approvals/part-5.json#christmas/form-390b2cd693bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulee', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulee', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-5.json#christmas/form-73c5475313cb');
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
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kysyä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"kysyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kysyä[X]kysyy[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+kysyä(kysyä)"}'::jsonb,
      'kysyy', 'kysyy',
      'present tense, 3rd person singular', 'Kysyä doubles its last vowel for he or she: kysyy.', 'asks', 'to ask (a question)', 'approved', now(), 'content/approvals/part-5.json#christmas/form-c1a795b941ac');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kysyy', 'kysyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Kysyä doubles its last vowel for he or she: kysyy.', 'asks', 'to ask (a question)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kysyy', 'kysyä',
      (select form_name_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy'),
      (select why_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy'),
      (select meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy'),
      (select lemma_meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy'),
      'present tense, 3rd person singular', 'Kysyä doubles its last vowel for he or she: kysyy.', 'asks', 'to ask (a question)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#christmas/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-5.json#christmas/form-5bdac2fbf3a8');
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
  if not exists (select 1 from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiltti', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"kiltti","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kiltti[X]kiltt[Sp][Nm]ejä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+kiltti(kiltti)"}'::jsonb,
      'kilttejä', 'kilttejä',
      'partitive plural', 'Plural ''some'' takes -jä: kiltti becomes kilttejä, i turning into e.', 'good (kind)', 'good, kind', 'approved', now(), 'content/approvals/part-5.json#christmas/form-09e15a679ebc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kilttejä', 'kiltti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -jä: kiltti becomes kilttejä, i turning into e.', 'good (kind)', 'good, kind')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kilttejä', 'kiltti',
      (select form_name_en from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä'),
      (select why_en from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä'),
      (select meaning_en from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä'),
      (select lemma_meaning_en from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä'),
      'partitive plural', 'Plural ''some'' takes -jä: kiltti becomes kilttejä, i turning into e.', 'good (kind)', 'good, kind';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"lapsi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lapsi[X]la[Sp][Nm]psia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+lapsi(lapsi)"}'::jsonb,
      'lapsia', 'lapsii',
      'partitive plural', 'Lapsi becomes lapsia in a question about having any. Speech turns the last a into i: lapsii.', 'children', 'child', 'approved', now(), 'content/approvals/part-5.json#christmas/form-12b8d37063cb');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-5.json#christmas/form-ae1caa07874f');
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
      'nominative plural, with the possessive ending for my', 'Lapsi, child. -set makes many, -ni adds ''my'': lapseni. Speech says mun lapset and drops -ni.', 'my children', 'child', 'approved', now(), 'content/approvals/part-5.json#christmas/form-9f193d6d72e6');
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
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkä[Tt][Ap][P3][Nm][Ef]ävät","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkäävät', 'tykkää',
      'present tense, 3rd person plural', 'Books write tykkäävät. Speech uses the he or she form: tykkää.', 'they like', 'to like', 'approved', now(), 'content/approvals/part-5.json#christmas/form-70bde388c830');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkäävät', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write tykkäävät. Speech uses the he or she form: tykkää.', 'they like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkäävät', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää'),
      'present tense, 3rd person plural', 'Books write tykkäävät. Speech uses the he or she form: tykkää.', 'they like', 'to like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sela][Ny]iitä","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppp","WORDBASES":"+se(se)"}'::jsonb,
      'siitä', 'siitä',
      'elative singular', 'Tykätä (to like) wants -stä: se becomes siitä, ''like that''.', 'that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#christmas/form-d88f6d43ec68');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siitä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Tykätä (to like) wants -stä: se becomes siitä, ''like that''.', 'that', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siitä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä'),
      'elative singular', 'Tykätä (to like) wants -stä: se becomes siitä, ''like that''.', 'that', 'it, that';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Joulu on kahen viikon päästä. Ootsä Suomes?',
    'Joulu on kahden viikon päästä. Oletko sinä Suomessa?', 'Christmas is in two weeks. Will you be in Finland?',
    'christmas/1-puhe-863407537eb5.mp3', 'christmas/1-kirja-58a3d9d6dcf5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Joulu', (select id from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'kahden', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen')),
    (v_line_id, 'kirja', 4, 'viikon', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon')),
    (v_line_id, 'kirja', 5, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä')),
    (v_line_id, 'kirja', 6, 'Oletko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 7, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 8, 'Suomessa', null),
    (v_line_id, 'puhe', 1, 'Joulu', (select id from public.forms where lemma = 'joulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulu' and surface_puhe = 'joulu')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kahen', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen')),
    (v_line_id, 'puhe', 4, 'viikon', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viikon' and surface_puhe = 'viikon')),
    (v_line_id, 'puhe', 5, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä')),
    (v_line_id, 'puhe', 6, 'Oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 7, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 8, 'Suomes', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Joo. Mä en lennä Brasiliaan tänä vuonna.',
    'Kyllä. Minä en lennä Brasiliaan tänä vuonna.', 'Yes. I''m not flying to Brazil this year.',
    'christmas/2-puhe-9f865fe846a1.mp3', 'christmas/2-kirja-e064482afafb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 4, 'lennä', (select id from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä')),
    (v_line_id, 'kirja', 5, 'Brasiliaan', null),
    (v_line_id, 'kirja', 6, 'tänä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä')),
    (v_line_id, 'kirja', 7, 'vuonna', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 4, 'lennä', (select id from public.forms where lemma = 'lentää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'lennä' and surface_puhe = 'lennä')),
    (v_line_id, 'puhe', 5, 'Brasiliaan', null),
    (v_line_id, 'puhe', 6, 'tänä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tänä' and surface_puhe = 'tänä')),
    (v_line_id, 'puhe', 7, 'vuonna', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'vuonna' and surface_puhe = 'vuonna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Suomes jouluaatto on tärkein päivä.',
    'Suomessa jouluaatto on tärkein päivä.', 'In Finland, Christmas Eve is the most important day.',
    'christmas/3-puhe-10928328e0ea.mp3', 'christmas/3-kirja-f3ee4c5538fa.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Suomessa', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes')),
    (v_line_id, 'kirja', 2, 'jouluaatto', (select id from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'tärkein', (select id from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein')),
    (v_line_id, 'kirja', 5, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä')),
    (v_line_id, 'puhe', 1, 'Suomes', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes')),
    (v_line_id, 'puhe', 2, 'jouluaatto', (select id from public.forms where lemma = 'jouluaatto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jouluaatto' and surface_puhe = 'jouluaatto')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'tärkein', (select id from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'tärkein' and surface_puhe = 'tärkein')),
    (v_line_id, 'puhe', 5, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Siis kakskytneljäs joulukuuta?',
    'Siis kahdeskymmenesneljäs joulukuuta?', 'So the twenty-fourth of December?',
    'christmas/4-puhe-d72533fd60a3.mp3', 'christmas/4-kirja-f6c85ad71086.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Siis', (select id from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis')),
    (v_line_id, 'kirja', 2, 'kahdeskymmenesneljäs', (select id from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs')),
    (v_line_id, 'kirja', 3, 'joulukuuta', (select id from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta')),
    (v_line_id, 'puhe', 1, 'Siis', (select id from public.forms where lemma = 'siis' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siis' and surface_puhe = 'siis')),
    (v_line_id, 'puhe', 2, 'kakskytneljäs', (select id from public.forms where lemma = 'kahdeskymmenesneljäs' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahdeskymmenesneljäs' and surface_puhe = 'kakskytneljäs')),
    (v_line_id, 'puhe', 3, 'joulukuuta', (select id from public.forms where lemma = 'joulukuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'joulukuuta' and surface_puhe = 'joulukuuta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'Just niin. Me syödään kinkkuu ja laatikoita.',
    'Juuri niin. Me syömme kinkkua ja laatikoita.', 'Exactly. We eat ham and casseroles.',
    'christmas/5-puhe-7f66947f5b0b.mp3', 'christmas/5-kirja-c49612ade9c0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Juuri', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'kirja', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 4, 'syömme', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään')),
    (v_line_id, 'kirja', 5, 'kinkkua', (select id from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu')),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'laatikoita', (select id from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita')),
    (v_line_id, 'puhe', 1, 'Just', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'puhe', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 4, 'syödään', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'syömme' and surface_puhe = 'syödään')),
    (v_line_id, 'puhe', 5, 'kinkkuu', (select id from public.forms where lemma = 'kinkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kinkkua' and surface_puhe = 'kinkkuu')),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'laatikoita', (select id from public.forms where lemma = 'laatikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'laatikoita' and surface_puhe = 'laatikoita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Entä joulupukki?',
    'Entä joulupukki?', 'And Santa Claus?',
    'christmas/6-puhe-967f33b8cba6.mp3', 'christmas/6-kirja-e8d0333dba32.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'joulupukki', (select id from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'joulupukki', (select id from public.forms where lemma = 'joulupukki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joulupukki' and surface_puhe = 'joulupukki'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'Se tulee illal ja kysyy: "Onks täällä kilttejä lapsii?"',
    'Hän tulee illalla ja kysyy: "Onko täällä kilttejä lapsia?"', 'He comes in the evening and asks: "Are there any good children here?"',
    'christmas/7-puhe-832052096536.mp3', 'christmas/7-kirja-1c1e8b5441bf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee')),
    (v_line_id, 'kirja', 3, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'kysyy', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy')),
    (v_line_id, 'kirja', 6, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 7, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 8, 'kilttejä', (select id from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä')),
    (v_line_id, 'kirja', 9, 'lapsia', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee')),
    (v_line_id, 'puhe', 3, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'kysyy', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyy' and surface_puhe = 'kysyy')),
    (v_line_id, 'puhe', 6, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 7, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 8, 'kilttejä', (select id from public.forms where lemma = 'kiltti' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kilttejä' and surface_puhe = 'kilttejä')),
    (v_line_id, 'puhe', 9, 'lapsii', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'lapsia' and surface_puhe = 'lapsii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mun lapset tykkää siitä.',
    'Minun lapseni tykkäävät siitä.', 'My kids will love that.',
    'christmas/8-puhe-965d517dcad2.mp3', 'christmas/8-kirja-a05cba4bbd4d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'lapseni', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'kirja', 3, 'tykkäävät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää')),
    (v_line_id, 'kirja', 4, 'siitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'lapset', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapset')),
    (v_line_id, 'puhe', 3, 'tykkää', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäävät' and surface_puhe = 'tykkää')),
    (v_line_id, 'puhe', 4, 'siitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'siitä' and surface_puhe = 'siitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#christmas/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
