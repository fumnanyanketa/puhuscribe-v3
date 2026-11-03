-- Publishes the dialogue whens-your-birthday (unit holidays). Made by
-- scripts/generate/pipeline.py publish from content/drafts/whens-your-birthday. Do not edit by hand:
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
    where slug = 'whens-your-birthday' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'whens-your-birthday';
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
  values (v_unit_id, 'whens-your-birthday', 3,
    'When''s your birthday?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'whens-your-birthday' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'When''s your birthday?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'whens-your-birthday';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-a0518fcf4ae6');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syntymäpäivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"syntymäpäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]syntymä[X]syntym[Sn][Ny]ä[Bh][Bc][Ln][Xp]päivä[X]päiv[Sn][Ny]ä[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=ppppppp","WORDBASES":"+syntymä(syntymä)+päivä(päivä)"}'::jsonb,
      'syntymäpäiväsi', 'synttärit',
      'nominative singular, with the possessive ending for your', 'Books write syntymäpäiväsi, with -si for ''your''. Speech uses the short word synttärit.', 'your birthday', 'birthday', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-3728e636f95a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syntymäpäiväsi', 'syntymäpäivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books write syntymäpäiväsi, with -si for ''your''. Speech uses the short word synttärit.', 'your birthday', 'birthday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syntymäpäiväsi', 'syntymäpäivä',
      (select form_name_en from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit'),
      (select why_en from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit'),
      (select meaning_en from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit'),
      (select lemma_meaning_en from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit'),
      'nominative singular, with the possessive ending for your', 'Books write syntymäpäiväsi, with -si for ''your''. Speech uses the short word synttärit.', 'your birthday', 'birthday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('toukokuu', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"toukokuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]touko[X]touko[Sn][Ny][Bh][Bc][Ln][Xp]kuu[X]kuu[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppp","WORDBASES":"+touko(touko)+kuu(kuu)"}'::jsonb,
      'toukokuun', 'toukokuun',
      'genitive singular', 'Adds -n so it goes with the day: toukokuun viides, ''the fifth of May''.', 'of May', 'May', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-0ae47dcf2d0c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toukokuun', 'toukokuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n so it goes with the day: toukokuun viides, ''the fifth of May''.', 'of May', 'May')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toukokuun', 'toukokuu',
      (select form_name_en from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun'),
      (select why_en from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun'),
      (select meaning_en from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun'),
      (select lemma_meaning_en from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun'),
      'genitive singular', 'Adds -n so it goes with the day: toukokuun viides, ''the fifth of May''.', 'of May', 'May';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viides', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viides","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viides[X]viide[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+viides(viides)"}'::jsonb,
      'viides', 'viides',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'fifth', 'fifth', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-a68315dcff8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viides', 'viides';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'fifth', 'fifth')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viides', 'viides',
      (select form_name_en from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides'),
      (select why_en from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides'),
      (select meaning_en from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides'),
      (select lemma_meaning_en from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'fifth', 'fifth';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lokakuu', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"lokakuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]loka[X]lok[Sn][Ny]a[Bh][Bc][Ln][Xp]kuu[X]kuu[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp=pppp","WORDBASES":"+loka(loka)+kuu(kuu)"}'::jsonb,
      'lokakuun', 'lokakuun',
      'genitive singular', 'Adds -n so it goes with the day: lokakuun kolmas, ''the third of October''.', 'of October', 'October', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-229b702b0ba4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lokakuun', 'lokakuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n so it goes with the day: lokakuun kolmas, ''the third of October''.', 'of October', 'October')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lokakuun', 'lokakuu',
      (select form_name_en from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun'),
      (select why_en from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun'),
      (select meaning_en from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun'),
      (select lemma_meaning_en from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun'),
      'genitive singular', 'Adds -n so it goes with the day: lokakuun kolmas, ''the third of October''.', 'of October', 'October';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolmas', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolmas","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolmas[X]kolma[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kolmas(kolmas)"}'::jsonb,
      'kolmas', 'kolmas',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'third', 'third', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-5cafb6593091');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolmas', 'kolmas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'third', 'third')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolmas', 'kolmas',
      (select form_name_en from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas'),
      (select why_en from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas'),
      (select meaning_en from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas'),
      (select lemma_meaning_en from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'third', 'third';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eli', 'CLASS=sidesana', '{"BASEFORM":"eli","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]eli[X]eli","STRUCTURE":"=ppp","WORDBASES":"+eli(eli)"}'::jsonb,
      'eli', 'eli',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-fad125e4e583');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eli', 'eli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eli', 'eli',
      (select form_name_en from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli'),
      (select why_en from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli'),
      (select meaning_en from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli'),
      (select lemma_meaning_en from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'so, that is', 'so, that is';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ylihuomenna', 'CLASS=seikkasana', '{"BASEFORM":"ylihuomenna","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]yli=huomenna[X]yli[Bm]huomenna","STRUCTURE":"=ppp=pppppppp","WORDBASES":"+ylihuomenna(yli=huomenna)"}'::jsonb,
      'ylihuomenna', 'ylihuomenna',
      'adverb', 'This is the dictionary form. People say it the same way.', 'the day after tomorrow', 'the day after tomorrow', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-31a4bcc67569');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ylihuomenna', 'ylihuomenna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'the day after tomorrow', 'the day after tomorrow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ylihuomenna', 'ylihuomenna',
      (select form_name_en from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna'),
      (select why_en from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna'),
      (select meaning_en from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna'),
      (select lemma_meaning_en from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'the day after tomorrow', 'the day after tomorrow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oikea', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive', '{"BASEFORM":"oikea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]oikea[X]oikea[Ssti]sti","SIJAMUOTO":"kerrontosti","STRUCTURE":"=pppppppp","WORDBASES":"+oikea(oikea)"}'::jsonb,
      'oikeasti', 'oikeesti',
      'adverb form (-sti)', 'Adds -sti to oikea (real) to say how: oikeasti. Speech turns ea into ee: oikeesti.', 'really', 'right, correct', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-6af8fececad4');
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
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('onni', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"onni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]onni[X]onne[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+onni(onni)"}'::jsonb,
      'onneksi', 'onneks',
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-5df29264208f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'onneksi', 'onni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'onneksi', 'onni',
      (select form_name_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select why_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select lemma_meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Tk][Ap][P3][Ny][Ef]koon","MOOD":"imperative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olkoon', 'olkoon',
      'imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-6312a6531b1e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olkoon', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olkoon', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      'imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('etukäteen', 'CLASS=seikkasana', '{"BASEFORM":"etukäteen","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'etukäteen', 'etukäteen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'in advance', 'in advance', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-d654f79c6eb9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'etukäteen', 'etukäteen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'in advance', 'in advance')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'etukäteen', 'etukäteen',
      (select form_name_en from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen'),
      (select why_en from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen'),
      (select meaning_en from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen'),
      (select lemma_meaning_en from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'in advance', 'in advance';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pidä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pidän', 'pidän',
      'present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-69e11b1f32fa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pidän', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pidän', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      'present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pieni', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"pieni","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]pieni[X]pien[Sn][Nm]et","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+pieni(pieni)"}'::jsonb,
      'pienet', 'pienet',
      'nominative plural', 'Pieni becomes pienet to match juhlat: pienet juhlat, ''a small party''.', 'small', 'small, little', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-fac842b6bd74');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pienet', 'pieni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Pieni becomes pienet to match juhlat: pienet juhlat, ''a small party''.', 'small', 'small, little')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pienet', 'pieni',
      (select form_name_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet'),
      (select why_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet'),
      (select meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet'),
      (select lemma_meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet'),
      'nominative plural', 'Pieni becomes pienet to match juhlat: pienet juhlat, ''a small party''.', 'small', 'small, little';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juhla', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"juhla","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]juhla[X]juhl[Sn][Nm]at","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+juhla(juhla)"}'::jsonb,
      'juhlat', 'juhlat',
      'nominative plural', 'Juhla always takes -t for a party: juhlat. People say it the same way.', 'a party', 'party, celebration', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-e05981654e10');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juhlat', 'juhla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Juhla always takes -t for a party: juhlat. People say it the same way.', 'a party', 'party, celebration')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juhlat', 'juhla',
      (select form_name_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat'),
      (select why_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat'),
      (select meaning_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat'),
      (select lemma_meaning_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat'),
      'nominative plural', 'Juhla always takes -t for a party: juhlat. People say it the same way.', 'a party', 'party, celebration';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-3978a16fa6b0');
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
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vanha', 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vanha","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vanha[X]vanha[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+vanha(vanha)"}'::jsonb,
      'vanhaksi', 'vanhaks',
      'translative singular', 'Adds -ksi for what you become: vanha becomes vanhaksi. Speech drops the last i: vanhaks.', 'old', 'old', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-60161379304c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vanhaksi', 'vanha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi for what you become: vanha becomes vanhaksi. Speech drops the last i: vanhaks.', 'old', 'old')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vanhaksi', 'vanha',
      (select form_name_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks'),
      (select why_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks'),
      (select meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks'),
      (select lemma_meaning_en from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks'),
      'translative singular', 'Adds -ksi for what you become: vanha becomes vanhaksi. Speech drops the last i: vanhaks.', 'old', 'old';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täyttää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"täyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]täyttää[X]täytä[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+täyttää(täyttää)"}'::jsonb,
      'täytät', 'täytät',
      'present tense, 2nd person singular', 'Täyttää becomes täytä- (tt turns to t) and takes -t for ''you'': täytät. It means turning an age.', 'you turn', 'to fill in, to fill', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-efd71ca8dad8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täytät', 'täyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Täyttää becomes täytä- (tt turns to t) and takes -t for ''you'': täytät. It means turning an age.', 'you turn', 'to fill in, to fill')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täytät', 'täyttää',
      (select form_name_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät'),
      (select why_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät'),
      (select meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät'),
      (select lemma_meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät'),
      'present tense, 2nd person singular', 'Täyttää becomes täytä- (tt turns to t) and takes -t for ''you'': täytät. It means turning an age.', 'you turn', 'to fill in, to fill';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolmekymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolmekymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolmekymmentä', 'kolkyt',
      'nominative singular', 'Speech shortens kolmekymmentä to kolkyt.', 'thirty', 'thirty', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-ac8aef3fced9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolmekymmentä', 'kolmekymmentä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens kolmekymmentä to kolkyt.', 'thirty', 'thirty')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolmekymmentä', 'kolmekymmentä',
      (select form_name_en from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt'),
      (select why_en from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt'),
      (select meaning_en from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt'),
      (select lemma_meaning_en from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt'),
      'nominative singular', 'Speech shortens kolmekymmentä to kolkyt.', 'thirty', 'thirty';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pyöreä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"pyöreä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]pyöreä[X]pyöre[Sn][Nm]ät","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+pyöreä(pyöreä)"}'::jsonb,
      'pyöreät', 'pyöreet',
      'nominative plural', 'Pyöreä becomes pyöreät to match vuodet. Speech turns eä into ee: pyöreet.', 'round', 'round', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-7877278a9c53');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pyöreät', 'pyöreä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Pyöreä becomes pyöreät to match vuodet. Speech turns eä into ee: pyöreet.', 'round', 'round')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pyöreät', 'pyöreä',
      (select form_name_en from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet'),
      (select why_en from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet'),
      (select meaning_en from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet'),
      (select lemma_meaning_en from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet'),
      'nominative plural', 'Pyöreä becomes pyöreät to match vuodet. Speech turns eä into ee: pyöreet.', 'round', 'round';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vuosi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"vuosi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vuosi[X]vuo[Sn][Nm]det","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+vuosi(vuosi)"}'::jsonb,
      'vuodet', 'vuodet',
      'nominative plural', 'Vuosi becomes vuodet for more than one. Pyöreät vuodet is a round birthday.', 'years', 'year', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-989b3aba4f1e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vuodet', 'vuosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Vuosi becomes vuodet for more than one. Pyöreät vuodet is a round birthday.', 'years', 'year')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vuodet', 'vuosi',
      (select form_name_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet'),
      (select why_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet'),
      (select meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet'),
      (select lemma_meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet'),
      'nominative plural', 'Vuosi becomes vuodet for more than one. Pyöreät vuodet is a round birthday.', 'years', 'year';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pitä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitää', 'pitää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-7aba8e0c1b63');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitää', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitää', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juhlia', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"juhlia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]juhlia[X]juhli[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+juhlia(juhlia)"}'::jsonb,
      'juhlia', 'juhlia',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to celebrate', 'to celebrate', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-abd9eef50a8f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juhlia', 'juhlia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to celebrate', 'to celebrate')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juhlia', 'juhlia',
      (select form_name_en from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia'),
      (select why_en from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia'),
      (select meaning_en from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia'),
      (select lemma_meaning_en from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to celebrate', 'to celebrate';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kunto', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kunto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kunto[X]kunno[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+kunto(kunto)"}'::jsonb,
      'kunnolla', 'kunnolla',
      'adessive singular', 'Kunnolla means ''properly''. It comes from kunto, condition.', 'properly', 'condition, shape', 'approved', now(), 'content/approvals/part-5.json#whens-your-birthday/form-b20bfbeade45');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kunnolla', 'kunto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Kunnolla means ''properly''. It comes from kunto, condition.', 'properly', 'condition, shape')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kunnolla', 'kunto',
      (select form_name_en from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla'),
      (select why_en from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla'),
      (select meaning_en from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla'),
      (select lemma_meaning_en from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla'),
      'adessive singular', 'Kunnolla means ''properly''. It comes from kunto, condition.', 'properly', 'condition, shape';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Millon sun synttärit on?',
    'Milloin sinun syntymäpäiväsi on?', 'When''s your birthday?',
    'whens-your-birthday/1-puhe-57bedba68dfd.mp3', 'whens-your-birthday/1-kirja-3c07577d32e9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 2, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 3, 'syntymäpäiväsi', (select id from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 2, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 3, 'synttärit', (select id from public.forms where lemma = 'syntymäpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'syntymäpäiväsi' and surface_puhe = 'synttärit')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Toukokuun viides. Entä sun?',
    'Toukokuun viides. Entä sinun?', 'The fifth of May. And yours?',
    'whens-your-birthday/2-puhe-c9dcbfcfbc1a.mp3', 'whens-your-birthday/2-kirja-4f7aae232d66.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Toukokuun', (select id from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun')),
    (v_line_id, 'kirja', 2, 'viides', (select id from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides')),
    (v_line_id, 'kirja', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 4, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 1, 'Toukokuun', (select id from public.forms where lemma = 'toukokuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'toukokuun' and surface_puhe = 'toukokuun')),
    (v_line_id, 'puhe', 2, 'viides', (select id from public.forms where lemma = 'viides' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viides' and surface_puhe = 'viides')),
    (v_line_id, 'puhe', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 4, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Mun on lokakuun kolmas. Eli ylihuomenna!',
    'Minun on lokakuun kolmas. Eli ylihuomenna!', 'Mine is the third of October. So the day after tomorrow!',
    'whens-your-birthday/3-puhe-453c91eee198.mp3', 'whens-your-birthday/3-kirja-854f2f83857b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'lokakuun', (select id from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun')),
    (v_line_id, 'kirja', 4, 'kolmas', (select id from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas')),
    (v_line_id, 'kirja', 5, 'Eli', (select id from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli')),
    (v_line_id, 'kirja', 6, 'ylihuomenna', (select id from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'lokakuun', (select id from public.forms where lemma = 'lokakuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lokakuun' and surface_puhe = 'lokakuun')),
    (v_line_id, 'puhe', 4, 'kolmas', (select id from public.forms where lemma = 'kolmas' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmas' and surface_puhe = 'kolmas')),
    (v_line_id, 'puhe', 5, 'Eli', (select id from public.forms where lemma = 'eli' and form_tag = 'CLASS=sidesana' and surface_kirja = 'eli' and surface_puhe = 'eli')),
    (v_line_id, 'puhe', 6, 'ylihuomenna', (select id from public.forms where lemma = 'ylihuomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylihuomenna' and surface_puhe = 'ylihuomenna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Oikeesti? Onneks olkoon etukäteen!',
    'Oikeasti? Onneksi olkoon etukäteen!', 'Really? Happy birthday in advance!',
    'whens-your-birthday/4-puhe-f18173039cdd.mp3', 'whens-your-birthday/4-kirja-4d935a691ff5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Oikeasti', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti')),
    (v_line_id, 'kirja', 2, 'Onneksi', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'kirja', 3, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon')),
    (v_line_id, 'kirja', 4, 'etukäteen', (select id from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen')),
    (v_line_id, 'puhe', 1, 'Oikeesti', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'oikeasti' and surface_puhe = 'oikeesti')),
    (v_line_id, 'puhe', 2, 'Onneks', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'puhe', 3, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon')),
    (v_line_id, 'puhe', 4, 'etukäteen', (select id from public.forms where lemma = 'etukäteen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'etukäteen' and surface_puhe = 'etukäteen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Kiitti! Mä pidän pienet juhlat lauantaina.',
    'Kiitos! Minä pidän pienet juhlat lauantaina.', 'Thanks! I''m having a small party on Saturday.',
    'whens-your-birthday/5-puhe-0a69cec8067a.mp3', 'whens-your-birthday/5-kirja-cd945c903c05.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän')),
    (v_line_id, 'kirja', 4, 'pienet', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet')),
    (v_line_id, 'kirja', 5, 'juhlat', (select id from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat')),
    (v_line_id, 'kirja', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän')),
    (v_line_id, 'puhe', 4, 'pienet', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pienet' and surface_puhe = 'pienet')),
    (v_line_id, 'puhe', 5, 'juhlat', (select id from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'juhlat')),
    (v_line_id, 'puhe', 6, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kiva! Kuinka vanhaks sä täytät?',
    'Kiva! Kuinka vanhaksi sinä täytät?', 'Nice! How old will you be?',
    'whens-your-birthday/6-puhe-6c700346f134.mp3', 'whens-your-birthday/6-kirja-b2daa1a5df93.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 2, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 3, 'vanhaksi', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks')),
    (v_line_id, 'kirja', 4, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 5, 'täytät', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät')),
    (v_line_id, 'puhe', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 2, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 3, 'vanhaks', (select id from public.forms where lemma = 'vanha' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=tulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vanhaksi' and surface_puhe = 'vanhaks')),
    (v_line_id, 'puhe', 4, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 5, 'täytät', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytät' and surface_puhe = 'täytät'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Kolkyt.',
    'Kolmekymmentä.', 'Thirty.',
    'whens-your-birthday/7-puhe-75fa4d830ef6.mp3', 'whens-your-birthday/7-kirja-64e90fd7bbe2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kolmekymmentä', (select id from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt')),
    (v_line_id, 'puhe', 1, 'Kolkyt', (select id from public.forms where lemma = 'kolmekymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentä' and surface_puhe = 'kolkyt'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Pyöreet vuodet! Pitää juhlia kunnolla.',
    'Pyöreät vuodet! Pitää juhlia kunnolla.', 'A big birthday! We need to celebrate properly.',
    'whens-your-birthday/8-puhe-e7f4288a492d.mp3', 'whens-your-birthday/8-kirja-aeb5ce416f93.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pyöreät', (select id from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet')),
    (v_line_id, 'kirja', 2, 'vuodet', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet')),
    (v_line_id, 'kirja', 3, 'Pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'kirja', 4, 'juhlia', (select id from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia')),
    (v_line_id, 'kirja', 5, 'kunnolla', (select id from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla')),
    (v_line_id, 'puhe', 1, 'Pyöreet', (select id from public.forms where lemma = 'pyöreä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pyöreät' and surface_puhe = 'pyöreet')),
    (v_line_id, 'puhe', 2, 'vuodet', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'vuodet' and surface_puhe = 'vuodet')),
    (v_line_id, 'puhe', 3, 'Pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'puhe', 4, 'juhlia', (select id from public.forms where lemma = 'juhlia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'juhlia' and surface_puhe = 'juhlia')),
    (v_line_id, 'puhe', 5, 'kunnolla', (select id from public.forms where lemma = 'kunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kunnolla' and surface_puhe = 'kunnolla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#whens-your-birthday/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#whens-your-birthday/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
