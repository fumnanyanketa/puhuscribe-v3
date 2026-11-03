-- Publishes the dialogue favourite-season (unit seasons-and-the-dark-winter). Made by
-- scripts/generate/pipeline.py publish from content/drafts/favourite-season. Do not edit by hand:
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
    where slug = 'favourite-season' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'favourite-season';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 27
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'seasons-and-the-dark-winter' and position = 27 and stop_number = 27;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'seasons-and-the-dark-winter';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'favourite-season', 3,
    'Favourite season')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'favourite-season' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Favourite season';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'favourite-season';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-bfff487cc1b5');
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
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-24c73cc721d6');
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
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lempivuodenaika', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"lempivuodenaika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lempi[X]lemp[Sn][Ny]i[Bh][Bc][Ln][Xp]vuosi[X]vuo[Sg][Ny]den[Bh][Bc][Ln][Xp]aika[X]aik[Sn][Ny]a[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp=pppppp","WORDBASES":"+lempi(lempi)+vuoden(vuosi)+aika(aika)"}'::jsonb,
      'lempivuodenaikasi', 'lempivuodenaika',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': lempivuodenaikasi. Speech says sun lempivuodenaika and drops the ending.', 'your favourite season', 'favourite season', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-90bbc3fa83b6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lempivuodenaikasi', 'lempivuodenaika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books add -si for ''your'': lempivuodenaikasi. Speech says sun lempivuodenaika and drops the ending.', 'your favourite season', 'favourite season')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lempivuodenaikasi', 'lempivuodenaika',
      (select form_name_en from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika'),
      (select why_en from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika'),
      (select meaning_en from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika'),
      (select lemma_meaning_en from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika'),
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': lempivuodenaikasi. Speech says sun lempivuodenaika and drops the ending.', 'your favourite season', 'favourite season';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kes[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesä', 'kesä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'summer', 'summer', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-6bfd49a29279');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietysti', 'CLASS=seikkasana', '{"BASEFORM":"tietysti","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'tietysti', 'tietysti',
      'adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-5bed682424b8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tietysti', 'tietysti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tietysti', 'tietysti',
      (select form_name_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select why_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select meaning_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select lemma_meaning_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pidä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pidän', 'tykkään',
      'present tense, 1st person singular', 'From pitää, to like. Books write pidän. Speech uses tykätä and says tykkään.', 'I like', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-33036ab9d70e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pidän', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'From pitää, to like. Books write pidän. Speech uses tykätä and says tykkään.', 'I like', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pidän', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään'),
      'present tense, 1st person singular', 'From pitää, to like. Books write pidän. Speech uses tykätä and says tykkään.', 'I like', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syksy', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"syksy","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]syksy[X]syksy[Sela][Ny]stä","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppp","WORDBASES":"+syksy(syksy)"}'::jsonb,
      'syksystä', 'syksyst',
      'elative singular', 'Liking takes -stä: syksy becomes syksystä. Speech drops the last vowel: syksyst.', 'autumn (I like autumn)', 'autumn', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-de670d50afdf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syksystä', 'syksy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Liking takes -stä: syksy becomes syksystä. Speech drops the last vowel: syksyst.', 'autumn (I like autumn)', 'autumn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syksystä', 'syksy',
      (select form_name_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst'),
      (select why_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst'),
      (select meaning_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst'),
      (select lemma_meaning_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst'),
      'elative singular', 'Liking takes -stä: syksy becomes syksystä. Speech drops the last vowel: syksyst.', 'autumn (I like autumn)', 'autumn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"puu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puu[X]puu[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+puu(puu)"}'::jsonb,
      'puut', 'puut',
      'nominative plural', 'Adds -t for more than one: puu becomes puut.', 'the trees', 'tree, wood', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-f2f52011647c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puut', 'puu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: puu becomes puut.', 'the trees', 'tree, wood')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puut', 'puu',
      (select form_name_en from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut'),
      (select why_en from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut'),
      (select meaning_en from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut'),
      (select lemma_meaning_en from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut'),
      'nominative plural', 'Adds -t for more than one: puu becomes puut.', 'the trees', 'tree, wood';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-4ab061b662f0');
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
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('värikäs', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"värikäs","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]värikäs[X]värikkä[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppp","WORDBASES":"+värikäs(värikäs)"}'::jsonb,
      'värikkäitä', 'värikkäitä',
      'partitive plural', 'Describing many things takes -itä: värikäs becomes värikkäitä.', 'colourful', 'colourful', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-19c31159c383');
  end if;
  if not exists (select 1 from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'värikkäitä', 'värikäs';
  end if;
  if not exists (select 1 from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Describing many things takes -itä: värikäs becomes värikkäitä.', 'colourful', 'colourful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'värikkäitä', 'värikäs',
      (select form_name_en from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä'),
      (select why_en from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä'),
      (select meaning_en from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä'),
      (select lemma_meaning_en from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä'),
      'partitive plural', 'Describing many things takes -itä: värikäs becomes värikkäitä.', 'colourful', 'colourful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-b20bd263b5ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'totta', 'tosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'totta', 'tosi',
      (select form_name_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select why_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select lemma_meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-f177cddd7c31');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mutta', 'mutta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mutta', 'mutta',
      (select form_name_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select why_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select meaning_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      (select lemma_meaning_en from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut'),
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syksy', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"syksy","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]syksy[X]syksy[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+syksy(syksy)"}'::jsonb,
      'syksyllä', 'syksyl',
      'adessive singular', 'Adds -llä for ''in'' a season: syksy becomes syksyllä. Speech shortens -llä to -l: syksyllä becomes syksyl.', 'in autumn', 'autumn', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-4766ad1f011b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syksyllä', 'syksy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''in'' a season: syksy becomes syksyllä. Speech shortens -llä to -l: syksyllä becomes syksyl.', 'in autumn', 'autumn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syksyllä', 'syksy',
      (select form_name_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl'),
      (select why_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl'),
      (select meaning_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl'),
      (select lemma_meaning_en from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl'),
      'adessive singular', 'Adds -llä for ''in'' a season: syksy becomes syksyllä. Speech shortens -llä to -l: syksyllä becomes syksyl.', 'in autumn', 'autumn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sataa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sataa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sataa[X]sat[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sataa(sataa)"}'::jsonb,
      'sataa', 'sataa',
      'present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-5f9ca24b3b7c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sataa', 'sataa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sataa', 'sataa',
      (select form_name_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select why_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select meaning_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select lemma_meaning_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      'present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kevät', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kevät","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kevät[X]kevä[Sn][Ny]t","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kevät(kevät)"}'::jsonb,
      'kevät', 'kevät',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'spring', 'spring', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-e52a96f5727d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kevät', 'kevät';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'spring', 'spring')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kevät', 'kevät',
      (select form_name_en from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät'),
      (select why_en from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät'),
      (select meaning_en from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät'),
      (select lemma_meaning_en from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'spring', 'spring';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'kans',
      'adverb', 'Speech often says kans. Books write myös.', 'too', 'also, too', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-300b16a8545b');
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
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Nm]ät","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivät', 'päivät',
      'nominative plural', 'Adds -t for more than one: päivä becomes päivät.', 'the days', 'day', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-aa6dcf2630cf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivät', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: päivä becomes päivät.', 'the days', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivät', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät'),
      'nominative plural', 'Adds -t for more than one: päivä becomes päivät.', 'the days', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pidetä', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pidetä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]pidetä[X]pite[Tt][Ap][P3][Nm][Ef]nevät","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+pidetä(pidetä)"}'::jsonb,
      'pitenevät', 'pitenee',
      'present tense, 3rd person plural', 'Books add -vät for ''they'': pitenevät. Speech uses the short form pitenee with more than one thing.', 'get longer', 'to get longer', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-fd281872149c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitenevät', 'pidetä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books add -vät for ''they'': pitenevät. Speech uses the short form pitenee with more than one thing.', 'get longer', 'to get longer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitenevät', 'pidetä',
      (select form_name_en from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee'),
      (select why_en from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee'),
      (select meaning_en from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee'),
      (select lemma_meaning_en from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee'),
      'present tense, 3rd person plural', 'Books add -vät for ''they'': pitenevät. Speech uses the short form pitenee with more than one thing.', 'get longer', 'to get longer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lumi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lumi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lumi[X]lu[Sn][Ny]mi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+lumi(lumi)"}'::jsonb,
      'lumi', 'lumi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-4e2c2b227f2e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lumi', 'lumi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lumi', 'lumi',
      (select form_name_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select why_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select lemma_meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sulaa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sulaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sulaa[X]sul[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sulaa(sulaa)"}'::jsonb,
      'sulaa', 'sulaa',
      'present tense, 3rd person singular', 'Sulaa, to melt. With lumi, ''snow'', the form looks the same as the dictionary form.', 'melts', 'to melt', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-6272861653c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sulaa', 'sulaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sulaa, to melt. With lumi, ''snow'', the form looks the same as the dictionary form.', 'melts', 'to melt')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sulaa', 'sulaa',
      (select form_name_en from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa'),
      (select why_en from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa'),
      (select meaning_en from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa'),
      (select lemma_meaning_en from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa'),
      'present tense, 3rd person singular', 'Sulaa, to melt. With lumi, ''snow'', the form looks the same as the dictionary form.', 'melts', 'to melt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talvi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"talvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]talvi[X]talv[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+talvi(talvi)"}'::jsonb,
      'talvi', 'talvi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-b30448401534');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talvi', 'talvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talvi', 'talvi',
      (select form_name_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select why_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select lemma_meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'kyl',
      'adverb', 'Speech shortens kyllä to kyl. Books write kyllä.', 'sure', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-7621b91f3044');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kyllä', 'kyllä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens kyllä to kyl. Books write kyllä.', 'sure', 'yes, certainly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kyllä', 'kyllä',
      (select form_name_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl'),
      (select why_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl'),
      (select meaning_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl'),
      (select lemma_meaning_en from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl'),
      'adverb', 'Speech shortens kyllä to kyl. Books write kyllä.', 'sure', 'yes, certainly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitkä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"pitkä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Lnl][Xp]pitkä[X]pis[Sn][Ny][Cs]in","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+pitkä(pitkä)"}'::jsonb,
      'pisin', 'pisin',
      'superlative, nominative singular', 'Pitkä means long. ''The longest'' is pisin, a form you learn as a whole.', 'the longest', 'long, tall', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-e471f38d7c18');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pisin', 'pitkä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, nominative singular', 'Pitkä means long. ''The longest'' is pisin, a form you learn as a whole.', 'the longest', 'long, tall')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pisin', 'pitkä',
      (select form_name_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin'),
      (select why_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin'),
      (select meaning_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin'),
      (select lemma_meaning_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin'),
      'superlative, nominative singular', 'Pitkä means long. ''The longest'' is pisin, a form you learn as a whole.', 'the longest', 'long, tall';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kylmä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"kylmä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Lnl][Xp]kylmä[X]kylm[Sn][Ny][Cs]in","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kylmä(kylmä)"}'::jsonb,
      'kylmin', 'kylmin',
      'superlative, nominative singular', 'Kylmä means cold. The ending -in makes ''the coldest'': kylmä becomes kylmin.', 'the coldest', 'cold', 'approved', now(), 'content/approvals/part-5.json#favourite-season/form-52761afff62f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kylmin', 'kylmä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, nominative singular', 'Kylmä means cold. The ending -in makes ''the coldest'': kylmä becomes kylmin.', 'the coldest', 'cold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kylmin', 'kylmä',
      (select form_name_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin'),
      (select why_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin'),
      (select meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin'),
      (select lemma_meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin'),
      'superlative, nominative singular', 'Kylmä means cold. The ending -in makes ''the coldest'': kylmä becomes kylmin.', 'the coldest', 'cold';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Mikä on sun lempivuodenaika?',
    'Mikä on sinun lempivuodenaikasi?', 'What''s your favourite season?',
    'favourite-season/1-puhe-49a562afafba.mp3', 'favourite-season/1-kirja-3f228458b5e9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 4, 'lempivuodenaikasi', (select id from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika')),
    (v_line_id, 'puhe', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 4, 'lempivuodenaika', (select id from public.forms where lemma = 'lempivuodenaika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lempivuodenaikasi' and surface_puhe = 'lempivuodenaika'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Kesä tietysti! Entä sun?',
    'Kesä tietysti! Entä sinun?', 'Summer, of course! And yours?',
    'favourite-season/2-puhe-03095622b448.mp3', 'favourite-season/2-kirja-0ff2fbedd684.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kesä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä')),
    (v_line_id, 'kirja', 2, 'tietysti', (select id from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti')),
    (v_line_id, 'kirja', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 4, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 1, 'Kesä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kesä' and surface_puhe = 'kesä')),
    (v_line_id, 'puhe', 2, 'tietysti', (select id from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti')),
    (v_line_id, 'puhe', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 4, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Mä tykkään syksyst. Puut on niin värikkäitä.',
    'Minä pidän syksystä. Puut ovat niin värikkäitä.', 'I like autumn. The trees are so colourful.',
    'favourite-season/3-puhe-169a5af1d0a3.mp3', 'favourite-season/3-kirja-1b584c6b7be3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 3, 'syksystä', (select id from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst')),
    (v_line_id, 'kirja', 4, 'Puut', (select id from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut')),
    (v_line_id, 'kirja', 5, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 7, 'värikkäitä', (select id from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tykkään', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 3, 'syksyst', (select id from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'syksystä' and surface_puhe = 'syksyst')),
    (v_line_id, 'puhe', 4, 'Puut', (select id from public.forms where lemma = 'puu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'puut' and surface_puhe = 'puut')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 7, 'värikkäitä', (select id from public.forms where lemma = 'värikäs' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'värikkäitä' and surface_puhe = 'värikkäitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Totta. Mut syksyl sataa paljon.',
    'Totta. Mutta syksyllä sataa paljon.', 'True. But it rains a lot in autumn.',
    'favourite-season/4-puhe-7caed3435489.mp3', 'favourite-season/4-kirja-fff7e7ca7e6a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'syksyllä', (select id from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl')),
    (v_line_id, 'kirja', 4, 'sataa', (select id from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa')),
    (v_line_id, 'kirja', 5, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'syksyl', (select id from public.forms where lemma = 'syksy' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'syksyllä' and surface_puhe = 'syksyl')),
    (v_line_id, 'puhe', 4, 'sataa', (select id from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa')),
    (v_line_id, 'puhe', 5, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Kevät on kans kiva. Päivät pitenee.',
    'Kevät on myös kiva. Päivät pitenevät.', 'Spring is nice too. The days get longer.',
    'favourite-season/5-puhe-6e4d5a82a485.mp3', 'favourite-season/5-kirja-47cfac019267.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kevät', (select id from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans')),
    (v_line_id, 'kirja', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 5, 'Päivät', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät')),
    (v_line_id, 'kirja', 6, 'pitenevät', (select id from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee')),
    (v_line_id, 'puhe', 1, 'Kevät', (select id from public.forms where lemma = 'kevät' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kevät' and surface_puhe = 'kevät')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kans', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans')),
    (v_line_id, 'puhe', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 5, 'Päivät', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päivät' and surface_puhe = 'päivät')),
    (v_line_id, 'puhe', 6, 'pitenee', (select id from public.forms where lemma = 'pidetä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pitenevät' and surface_puhe = 'pitenee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Ja lumi sulaa!',
    'Ja lumi sulaa!', 'And the snow melts!',
    'favourite-season/6-puhe-b8a85d6096f8.mp3', 'favourite-season/6-kirja-f766bf7a4215.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'lumi', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi')),
    (v_line_id, 'kirja', 3, 'sulaa', (select id from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'lumi', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi')),
    (v_line_id, 'puhe', 3, 'sulaa', (select id from public.forms where lemma = 'sulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sulaa' and surface_puhe = 'sulaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Talvi on kyl pisin.',
    'Talvi on kyllä pisin.', 'Winter is the longest, though.',
    'favourite-season/7-puhe-165872ce9728.mp3', 'favourite-season/7-kirja-49eb6a7fa311.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Talvi', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl')),
    (v_line_id, 'kirja', 4, 'pisin', (select id from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin')),
    (v_line_id, 'puhe', 1, 'Talvi', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kyl', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'kyl')),
    (v_line_id, 'puhe', 4, 'pisin', (select id from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pisin' and surface_puhe = 'pisin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Ja kylmin!',
    'Ja kylmin!', 'And the coldest!',
    'favourite-season/8-puhe-d33222a2bbcf.mp3', 'favourite-season/8-kirja-1e7497ec50d5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'kylmin', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'kylmin', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'kylmin' and surface_puhe = 'kylmin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#favourite-season/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#favourite-season/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
