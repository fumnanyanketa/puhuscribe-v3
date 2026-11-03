-- Publishes the dialogue the-dark-time (unit seasons-and-the-dark-winter). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-dark-time. Do not edit by hand:
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
    where slug = 'the-dark-time' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-dark-time';
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
  values (v_unit_id, 'the-dark-time', 2,
    'The dark time')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-dark-time' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'The dark time';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-dark-time';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamu', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"aamu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+aamu(aamu)"}'::jsonb,
      'aamulla', 'aamul',
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-5166646a9be8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamulla', 'aamu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamulla', 'aamu',
      (select form_name_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select why_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select lemma_meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pimeä', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"pimeä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]pimeä[X]pime[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+pimeä(pimeä)"}'::jsonb,
      'pimeää', 'pimeetä',
      'partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-5be57482d9e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pimeää', 'pimeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pimeää', 'pimeä',
      (select form_name_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select why_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select lemma_meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      'partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iltapäivä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"iltapäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]ilt[Sn][Ny]a[Bh][Bc][Ln][Xp]päivä[X]päivä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp=pppppppp","WORDBASES":"+ilta(ilta)+päivä(päivä)"}'::jsonb,
      'iltapäivällä', 'iltapäiväl',
      'adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-de597eea4acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'iltapäivällä', 'iltapäivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'iltapäivällä', 'iltapäivä',
      (select form_name_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select why_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select meaning_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select lemma_meaning_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      'adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('taas', 'CLASS=seikkasana', '{"BASEFORM":"taas","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]taas[X]taas","STRUCTURE":"=pppp","WORDBASES":"+taas(taas)"}'::jsonb,
      'taas', 'taas',
      'adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-a5754fee25d8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'taas', 'taas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'taas', 'taas',
      (select form_name_en from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas'),
      (select why_en from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas'),
      (select meaning_en from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas'),
      (select lemma_meaning_en from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('marraskuu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"marraskuu","CLASS":"nimisana","FSTOUTPUT":"[Lnl][Xp]marras[X]marra[Sn][Ny]s[Bh][Bc][Ln][Xp]kuu[X]kuu[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=ppp","WORDBASES":"+marras(marras)+kuu(kuu)"}'::jsonb,
      'marraskuu', 'marraskuu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'November', 'November', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-e6cbb011f4a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'marraskuu', 'marraskuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'November', 'November')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'marraskuu', 'marraskuu',
      (select form_name_en from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu'),
      (select why_en from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu'),
      (select meaning_en from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu'),
      (select lemma_meaning_en from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'November', 'November';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pimeä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"pimeä","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Lnl][Xp]pimeä[X]pime[Sn][Ny][Cs]in","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+pimeä(pimeä)"}'::jsonb,
      'pimein', 'pimein',
      'superlative, nominative singular', 'Pimeä means dark. The ending -in makes ''the darkest'': pimeä becomes pimein.', 'darkest', 'dark', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-9577af3dd8d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pimein', 'pimeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, nominative singular', 'Pimeä means dark. The ending -in makes ''the darkest'': pimeä becomes pimein.', 'darkest', 'dark')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pimein', 'pimeä',
      (select form_name_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein'),
      (select why_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein'),
      (select meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein'),
      (select lemma_meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein'),
      'superlative, nominative singular', 'Pimeä means dark. The ending -in makes ''the darkest'': pimeä becomes pimein.', 'darkest', 'dark';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuukausi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuukausi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuu[X]kuu[Sn][Ny][Bh][Bc][Ln][Xp]kausi[X]kau[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=ppppp","WORDBASES":"+kuu(kuu)+kausi(kausi)"}'::jsonb,
      'kuukausi', 'kuukausi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'month', 'month', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-53aa87236c13');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuukausi', 'kuukausi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'month', 'month')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuukausi', 'kuukausi',
      (select form_name_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi'),
      (select why_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi'),
      (select meaning_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi'),
      (select lemma_meaning_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'month', 'month';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('miten', 'CLASS=seikkasana', '{"BASEFORM":"miten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]miten[X]miten","STRUCTURE":"=ppppp","WORDBASES":"+miten(miten)"}'::jsonb,
      'miten', 'miten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-34eb915c255e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miten', 'miten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miten', 'miten',
      (select form_name_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select why_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select lemma_meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-2aeedafa15c7');
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
  if not exists (select 1 from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jaksaa', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"jaksaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]jaksaa[X]jaksa[Tt][Ap][P2][Nm][Ef]tte","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+jaksaa(jaksaa)"}'::jsonb,
      'jaksatte', 'jaksatte',
      'present tense, 2nd person plural', 'Jaksaa means to have the energy. The ending -tte goes with te, ''you all''.', 'do you (all) cope', 'to cope, to have the energy', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-b631422191f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jaksatte', 'jaksaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural', 'Jaksaa means to have the energy. The ending -tte goes with te, ''you all''.', 'do you (all) cope', 'to cope, to have the energy')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jaksatte', 'jaksaa',
      (select form_name_en from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte'),
      (select why_en from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte'),
      (select meaning_en from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte'),
      (select lemma_meaning_en from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte'),
      'present tense, 2nd person plural', 'Jaksaa means to have the energy. The ending -tte goes with te, ''you all''.', 'do you (all) cope', 'to cope, to have the energy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sytyttää', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sytyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sytyttää[X]sytytä[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+sytyttää(sytyttää)"}'::jsonb,
      'sytytämme', 'sytytetään',
      'present tense, 1st person plural', 'Speech uses the form sytytetään with me, ''we''. Books write sytytämme.', 'we light', 'to light', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-b561fffae140');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sytytämme', 'sytyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Speech uses the form sytytetään with me, ''we''. Books write sytytämme.', 'we light', 'to light')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sytytämme', 'sytyttää',
      (select form_name_en from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään'),
      (select why_en from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään'),
      (select meaning_en from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään'),
      (select lemma_meaning_en from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään'),
      'present tense, 1st person plural', 'Speech uses the form sytytetään with me, ''we''. Books write sytytämme.', 'we light', 'to light';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kynttilä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"kynttilä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kynttilä[X]kynttilö[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+kynttilä(kynttilä)"}'::jsonb,
      'kynttilöitä', 'kynttilöitä',
      'partitive plural', 'Plural ''some'' takes -itä: kynttilä becomes kynttilöitä, the last ä turning into ö.', 'candles', 'candle', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-05532514e827');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kynttilöitä', 'kynttilä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -itä: kynttilä becomes kynttilöitä, the last ä turning into ö.', 'candles', 'candle')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kynttilöitä', 'kynttilä',
      (select form_name_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä'),
      (select why_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä'),
      (select meaning_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä'),
      (select lemma_meaning_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä'),
      'partitive plural', 'Plural ''some'' takes -itä: kynttilä becomes kynttilöitä, the last ä turning into ö.', 'candles', 'candle';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ulkoilla', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"ulkoilla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ulkoilla[X]ulkoile[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppppppp","TENSE":"present_simple","WORDBASES":"+ulkoilla(ulkoilla)"}'::jsonb,
      'ulkoilemme', 'ulkoillaan',
      'present tense, 1st person plural', 'Speech uses the form ulkoillaan with me, ''we''. Books write ulkoilemme.', 'we get outside', 'to be outdoors, to get outside', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-4caa3df509a9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ulkoilemme', 'ulkoilla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Speech uses the form ulkoillaan with me, ''we''. Books write ulkoilemme.', 'we get outside', 'to be outdoors, to get outside')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ulkoilemme', 'ulkoilla',
      (select form_name_en from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan'),
      (select why_en from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan'),
      (select meaning_en from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan'),
      (select lemma_meaning_en from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan'),
      'present tense, 1st person plural', 'Speech uses the form ulkoillaan with me, ''we''. Books write ulkoilemme.', 'we get outside', 'to be outdoors, to get outside';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päivä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivällä', 'päiväl',
      'adessive singular', 'Adds -llä for ''during'': päivä becomes päivällä. Speech shortens -llä to -l: päivällä becomes päiväl.', 'during the day', 'day', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-e068cd14094b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivällä', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''during'': päivä becomes päivällä. Speech shortens -llä to -l: päivällä becomes päiväl.', 'during the day', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivällä', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl'),
      'adessive singular', 'Adds -llä for ''during'': päivä becomes päivällä. Speech shortens -llä to -l: päivällä becomes päiväl.', 'during the day', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('d-vitamiini', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"d-vitamiini","CLASS":"nimisana","FSTOUTPUT":"[La][Xp]d[X]d-[Bc][Ln][Xp]vitamiini[X]vitamiin[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=q-=pppppppppp","WORDBASES":"+d(d)+-+vitamiini(vitamiini)"}'::jsonb,
      'd-vitamiinia', 'd-vitamiinii',
      'partitive singular', 'Asking about some of something takes -a: D-vitamiini becomes D-vitamiinia. Speech turns -ia into -ii.', 'vitamin D', 'vitamin D', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-f7c4720fb2d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'd-vitamiinia', 'd-vitamiini';
  end if;
  if not exists (select 1 from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Asking about some of something takes -a: D-vitamiini becomes D-vitamiinia. Speech turns -ia into -ii.', 'vitamin D', 'vitamin D')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'd-vitamiinia', 'd-vitamiini',
      (select form_name_en from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii'),
      (select why_en from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii'),
      (select meaning_en from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii'),
      (select lemma_meaning_en from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii'),
      'partitive singular', 'Asking about some of something takes -a: D-vitamiini becomes D-vitamiinia. Speech turns -ia into -ii.', 'vitamin D', 'vitamin D';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tärkeä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tärkeä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]tärkeä[X]tärke[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+tärkeä(tärkeä)"}'::jsonb,
      'tärkeä', 'tärkee',
      'nominative singular', 'This is the dictionary form. Speech turns the ending -eä into -ee: tärkee.', 'important', 'important', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-ec7e50216047');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tärkeä', 'tärkeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. Speech turns the ending -eä into -ee: tärkee.', 'important', 'important')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tärkeä', 'tärkeä',
      (select form_name_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee'),
      (select why_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee'),
      (select meaning_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee'),
      (select lemma_meaning_en from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee'),
      'nominative singular', 'This is the dictionary form. Speech turns the ending -eä into -ee: tärkee.', 'important', 'important';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('onni', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"onni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]onni[X]onne[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+onni(onni)"}'::jsonb,
      'onneksi', 'onneks',
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-5df29264208f');
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
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kesä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesällä', 'kesäl',
      'adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-9b45c353e900');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesällä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesällä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl'),
      'adessive singular', 'Adds -llä for ''in'' a season: kesä becomes kesällä. Speech shortens -llä to -l: kesällä becomes kesäl.', 'in summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('valoisa', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"valoisa","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]valoisa[X]valois[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+valoisa(valoisa)"}'::jsonb,
      'valoisaa', 'valoisaa',
      'partitive singular', 'Saying what a time is like takes -a: valoisa becomes valoisaa, ''it is light''.', 'light, bright', 'light, bright', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-437368147563');
  end if;
  if not exists (select 1 from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'valoisaa', 'valoisa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Saying what a time is like takes -a: valoisa becomes valoisaa, ''it is light''.', 'light, bright', 'light, bright')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'valoisaa', 'valoisa',
      (select form_name_en from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa'),
      (select why_en from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa'),
      (select meaning_en from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa'),
      (select lemma_meaning_en from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa'),
      'partitive singular', 'Saying what a time is like takes -a: valoisa becomes valoisaa, ''it is light''.', 'light, bright', 'light, bright';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aurinko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"aurinko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aurinko[X]aurinko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+aurinko(aurinko)"}'::jsonb,
      'aurinko', 'aurinko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sun', 'sun', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-ebd46b859a27');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aurinko', 'aurinko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'sun', 'sun')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aurinko', 'aurinko',
      (select form_name_en from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko'),
      (select why_en from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko'),
      (select meaning_en from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko'),
      (select lemma_meaning_en from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sun', 'sun';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laskea', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"laskea","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'laske', 'laske',
      'present tense, negative form', 'After ei the verb drops its ending: laskea becomes laske.', 'set (doesn''t set)', 'to set (the sun), to count, to lower', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-4c86b5c4b32f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laske', 'laskea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: laskea becomes laske.', 'set (doesn''t set)', 'to set (the sun), to count, to lower')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laske', 'laskea',
      (select form_name_en from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske'),
      (select why_en from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske'),
      (select meaning_en from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske'),
      (select lemma_meaning_en from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske'),
      'present tense, negative form', 'After ei the verb drops its ending: laskea becomes laske.', 'set (doesn''t set)', 'to set (the sun), to count, to lower';
  end if;
  if not exists (select 1 from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('melkein', 'CLASS=seikkasana', '{"BASEFORM":"melkein","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]melkein[X]melkein","STRUCTURE":"=ppppppp","WORDBASES":"+melkein(melkein)"}'::jsonb,
      'melkein', 'melkein',
      'adverb', 'This is the dictionary form. People say it the same way.', 'almost', 'almost', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-cf34640e6938');
  end if;
  if not exists (select 1 from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'melkein', 'melkein';
  end if;
  if not exists (select 1 from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'almost', 'almost')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'melkein', 'melkein',
      (select form_name_en from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein'),
      (select why_en from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein'),
      (select meaning_en from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein'),
      (select lemma_meaning_en from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'almost', 'almost';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ollenkaan', 'CLASS=seikkasana', '{"BASEFORM":"ollenkaan","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'ollenkaan', 'ollenkaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all', 'approved', now(), 'content/approvals/part-5.json#the-dark-time/form-d2f590cc0a3b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ollenkaan', 'ollenkaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ollenkaan', 'ollenkaan',
      (select form_name_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select why_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select meaning_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      (select lemma_meaning_en from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'at all', 'at all';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Aamul on pimeetä ja iltapäiväl on taas pimeetä.',
    'Aamulla on pimeää ja iltapäivällä on taas pimeää.', 'It''s dark in the morning and dark again in the afternoon.',
    'the-dark-time/1-puhe-cd5c686a5a06.mp3', 'the-dark-time/1-kirja-6d6c04c37858.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aamulla', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'pimeää', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'iltapäivällä', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'kirja', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 7, 'taas', (select id from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas')),
    (v_line_id, 'kirja', 8, 'pimeää', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä')),
    (v_line_id, 'puhe', 1, 'Aamul', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'pimeetä', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'iltapäiväl', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 7, 'taas', (select id from public.forms where lemma = 'taas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'taas' and surface_puhe = 'taas')),
    (v_line_id, 'puhe', 8, 'pimeetä', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Aino', 'Joo, marraskuu on pimein kuukausi.',
    'Kyllä, marraskuu on pimein kuukausi.', 'Yes, November is the darkest month.',
    'the-dark-time/2-puhe-2f5e7d39a443.mp3', 'the-dark-time/2-kirja-0c038f9d22cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'marraskuu', (select id from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'pimein', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein')),
    (v_line_id, 'kirja', 5, 'kuukausi', (select id from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'marraskuu', (select id from public.forms where lemma = 'marraskuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'marraskuu' and surface_puhe = 'marraskuu')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'pimein', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'pimein' and surface_puhe = 'pimein')),
    (v_line_id, 'puhe', 5, 'kuukausi', (select id from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuukausi' and surface_puhe = 'kuukausi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Miten te jaksatte?',
    'Miten te jaksatte?', 'How do you cope?',
    'the-dark-time/3-puhe-38c94e4dca96.mp3', 'the-dark-time/3-kirja-1b57139e62e0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'kirja', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 3, 'jaksatte', (select id from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte')),
    (v_line_id, 'puhe', 1, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'puhe', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 3, 'jaksatte', (select id from public.forms where lemma = 'jaksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'jaksatte' and surface_puhe = 'jaksatte'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Aino', 'Me sytytetään kynttilöitä ja ulkoillaan päiväl.',
    'Me sytytämme kynttilöitä ja ulkoilemme päivällä.', 'We light candles and get outside during the day.',
    'the-dark-time/4-puhe-0fe79ec33200.mp3', 'the-dark-time/4-kirja-d45eb5f41c40.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 2, 'sytytämme', (select id from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään')),
    (v_line_id, 'kirja', 3, 'kynttilöitä', (select id from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'ulkoilemme', (select id from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan')),
    (v_line_id, 'kirja', 6, 'päivällä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl')),
    (v_line_id, 'puhe', 1, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 2, 'sytytetään', (select id from public.forms where lemma = 'sytyttää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sytytämme' and surface_puhe = 'sytytetään')),
    (v_line_id, 'puhe', 3, 'kynttilöitä', (select id from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kynttilöitä' and surface_puhe = 'kynttilöitä')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'ulkoillaan', (select id from public.forms where lemma = 'ulkoilla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ulkoilemme' and surface_puhe = 'ulkoillaan')),
    (v_line_id, 'puhe', 6, 'päiväl', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'päivällä' and surface_puhe = 'päiväl'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ja D-vitamiinii?',
    'Ja D-vitamiinia?', 'And vitamin D?',
    'the-dark-time/5-puhe-160676db26aa.mp3', 'the-dark-time/5-kirja-da54ccb62010.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'D-vitamiinia', (select id from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'D-vitamiinii', (select id from public.forms where lemma = 'd-vitamiini' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'd-vitamiinia' and surface_puhe = 'd-vitamiinii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Aino', 'Joo, se on tärkee.',
    'Kyllä, se on tärkeä.', 'Yes, that''s important.',
    'the-dark-time/6-puhe-386775de6799.mp3', 'the-dark-time/6-kirja-8577b0d76583.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'tärkeä', (select id from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'tärkee', (select id from public.forms where lemma = 'tärkeä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'tärkeä' and surface_puhe = 'tärkee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Onneks kesäl on valoisaa.',
    'Onneksi kesällä on valoisaa.', 'Luckily it''s light in summer.',
    'the-dark-time/7-puhe-066662d1e7f7.mp3', 'the-dark-time/7-kirja-58ecf243ce58.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onneksi', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'kirja', 2, 'kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'valoisaa', (select id from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa')),
    (v_line_id, 'puhe', 1, 'Onneks', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'puhe', 2, 'kesäl', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'valoisaa', (select id from public.forms where lemma = 'valoisa' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'valoisaa' and surface_puhe = 'valoisaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Aino', 'Kesäl aurinko ei laske melkein ollenkaan!',
    'Kesällä aurinko ei laske melkein ollenkaan!', 'In summer the sun hardly sets at all!',
    'the-dark-time/8-puhe-205011ee5a19.mp3', 'the-dark-time/8-kirja-5e4790781459.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'kirja', 2, 'aurinko', (select id from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko')),
    (v_line_id, 'kirja', 3, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 4, 'laske', (select id from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske')),
    (v_line_id, 'kirja', 5, 'melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'kirja', 6, 'ollenkaan', (select id from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan')),
    (v_line_id, 'puhe', 1, 'Kesäl', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesäl')),
    (v_line_id, 'puhe', 2, 'aurinko', (select id from public.forms where lemma = 'aurinko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'aurinko' and surface_puhe = 'aurinko')),
    (v_line_id, 'puhe', 3, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 4, 'laske', (select id from public.forms where lemma = 'laskea' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'laske' and surface_puhe = 'laske')),
    (v_line_id, 'puhe', 5, 'melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'puhe', 6, 'ollenkaan', (select id from public.forms where lemma = 'ollenkaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ollenkaan' and surface_puhe = 'ollenkaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-dark-time/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
