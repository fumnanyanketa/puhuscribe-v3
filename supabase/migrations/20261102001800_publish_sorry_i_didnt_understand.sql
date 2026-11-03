-- Publishes the dialogue sorry-i-didnt-understand (unit asking-for-help). Made by
-- scripts/generate/pipeline.py publish from content/drafts/sorry-i-didnt-understand. Do not edit by hand:
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
    where slug = 'sorry-i-didnt-understand' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'sorry-i-didnt-understand';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 7
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'asking-for-help' and position = 7 and stop_number = 7;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'asking-for-help';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'sorry-i-didnt-understand', 1,
    'Sorry, I didn''t understand')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'sorry-i-didnt-understand' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Sorry, I didn''t understand';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'sorry-i-didnt-understand';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluatko', 'haluuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-6189aefae9f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluatko', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluatko', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('muovipussi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"muovipussi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]muovi[X]muov[Sn][Ny]i[Bh][Bc][Ln][Xp]pussi[X]puss[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+muovi(muovi)+pussi(pussi)"}'::jsonb,
      'muovipussin', 'muovipussin',
      'genitive singular', 'Muovipussi with -n when you take the whole thing: muovipussin.', 'a plastic bag', 'plastic bag', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-d2d08625670a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'muovipussin', 'muovipussi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Muovipussi with -n when you take the whole thing: muovipussin.', 'a plastic bag', 'plastic bag')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'muovipussin', 'muovipussi',
      (select form_name_en from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin'),
      (select why_en from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin'),
      (select meaning_en from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin'),
      (select lemma_meaning_en from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin'),
      'genitive singular', 'Muovipussi with -n when you take the whole thing: muovipussin.', 'a plastic bag', 'plastic bag';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vai', 'CLASS=sidesana', '{"BASEFORM":"vai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vai[X]vai","STRUCTURE":"=ppp","WORDBASES":"+vai(vai)"}'::jsonb,
      'vai', 'vai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-83d8cf4795ac');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vai', 'vai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vai', 'vai',
      (select form_name_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select why_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select meaning_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      (select lemma_meaning_en from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-5eb112d9aace');
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
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oma', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"oma","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]oma[X]om[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+oma(oma)"}'::jsonb,
      'oma', 'oma',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'own', 'own', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-fe204befffb8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oma', 'oma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'own', 'own')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oma', 'oma',
      (select form_name_en from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma'),
      (select why_en from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma'),
      (select meaning_en from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma'),
      (select lemma_meaning_en from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'own', 'own';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kassi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kassi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kassi[X]kass[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kassi(kassi)"}'::jsonb,
      'kassi', 'kassi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bag', 'bag', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-0c5ee1292bc7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kassi', 'kassi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'bag', 'bag')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kassi', 'kassi',
      (select form_name_en from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi'),
      (select why_en from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi'),
      (select meaning_en from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi'),
      (select lemma_meaning_en from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bag', 'bag';
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-91a5cf1932b7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'anteeksi', 'anteeksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'anteeksi', 'anteeksi',
      (select form_name_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select why_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select meaning_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select lemma_meaning_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-728ddce13587');
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
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ymmärtää', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"ymmärtää","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'ymmärtänyt', 'ymmärtäny',
      'past active participle, nominative singular', 'After en, ''I don''t'', a past action uses this form: en ymmärtänyt. Speech drops the last t: ymmärtäny.', 'understood (I didn''t understand)', 'to understand', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-3cd0b608f934');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ymmärtänyt', 'ymmärtää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'After en, ''I don''t'', a past action uses this form: en ymmärtänyt. Speech drops the last t: ymmärtäny.', 'understood (I didn''t understand)', 'to understand')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ymmärtänyt', 'ymmärtää',
      (select form_name_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny'),
      (select why_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny'),
      (select meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny'),
      (select lemma_meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny'),
      'past active participle, nominative singular', 'After en, ''I don''t'', a past action uses this form: en ymmärtänyt. Speech drops the last t: ymmärtäny.', 'understood (I didn''t understand)', 'to understand';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pussi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"pussi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pussi[X]puss[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+pussi(pussi)"}'::jsonb,
      'pussin', 'pussin',
      'genitive singular', 'Pussi with -n when you take the whole thing: pussin.', 'a bag', 'bag', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-fa979256af55');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pussin', 'pussi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Pussi with -n when you take the whole thing: pussin.', 'a bag', 'bag')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pussin', 'pussi',
      (select form_name_en from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'),
      (select why_en from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'),
      (select meaning_en from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'),
      (select lemma_meaning_en from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'),
      'genitive singular', 'Pussi with -n when you take the whole thing: pussin.', 'a bag', 'bag';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voitko', 'voit',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-90c207b76ecc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voitko', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voitko', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhu[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhua', 'puhuu',
      'basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-1e2e7b912f42');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhua', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhua', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      'basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hidas', 'CLASS=seikkasana;COMPARISON=comparative', '{"BASEFORM":"hidas","CLASS":"seikkasana","COMPARISON":"comparative","MANUAL":"true"}'::jsonb,
      'hitaammin', 'hitaammin',
      'comparative, adverb', 'Hidas, slow, becomes hitaammin, ''more slowly''. The d turns to t and -mmin means ''more''.', 'more slowly', 'slow', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-3c09073a2190');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hitaammin', 'hidas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, adverb', 'Hidas, slow, becomes hitaammin, ''more slowly''. The d turns to t and -mmin means ''more''.', 'more slowly', 'slow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hitaammin', 'hidas',
      (select form_name_en from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin'),
      (select why_en from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin'),
      (select meaning_en from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin'),
      (select lemma_meaning_en from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin'),
      'comparative, adverb', 'Hidas, slow, becomes hitaammin, ''more slowly''. The d turns to t and -mmin means ''more''.', 'more slowly', 'slow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-b20bd263b5ae');
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
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kai', 'CLASS=seikkasana', '{"BASEFORM":"kai","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kai[X]kai","STRUCTURE":"=ppp","WORDBASES":"+kai(kai)"}'::jsonb,
      'kai', 'kai',
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-b1285c45ffe6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kai', 'kai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kai', 'kai',
      (select form_name_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select why_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select lemma_meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsetko', 'tarviitko',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvitset, you need, with -ko to ask. Speech says tarviitko.', 'do you need?', 'to need', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-1572e0ae2eaa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsetko', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvitset, you need, with -ko to ask. Speech says tarviitko.', 'do you need?', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsetko', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Tarvitset, you need, with -ko to ask. Speech says tarviitko.', 'do you need?', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'ai',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-2ab0015782b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ai', 'ai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ai', 'ai',
      (select form_name_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select why_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select lemma_meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitos',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-c5b0481eae2b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhu[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhut', 'puhut',
      'present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-9717e4376acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhut', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhut', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      'present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jo', 'CLASS=seikkasana', '{"BASEFORM":"jo","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]jo[X]jo","STRUCTURE":"=pp","WORDBASES":"+jo(jo)"}'::jsonb,
      'jo', 'jo',
      'adverb', 'This is the dictionary form. People say it the same way.', 'already', 'already', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-31092ec721a1');
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
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-e18d9223b2b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvin', 'hyvin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvin', 'hyvin',
      (select form_name_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select why_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-68ca7e058498');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opetella', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"opetella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opet[Xj]ella[X]tele[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+opet(opettaa)+ella(+ella)"}'::jsonb,
      'opettelen', 'opettelen',
      'present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-d0e407cc4c7c');
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
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-2.json#sorry-i-didnt-understand/form-2b3844766909');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Kari', 'Haluuksä muovipussin vai onks sul oma kassi?',
    'Haluatko sinä muovipussin vai onko sinulla oma kassi?', 'Do you want a plastic bag or do you have your own bag?',
    'sorry-i-didnt-understand/1-puhe-fbb1ea5e3a56.mp3', 'sorry-i-didnt-understand/1-kirja-1f2227739b5f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Haluatko', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'muovipussin', (select id from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin')),
    (v_line_id, 'kirja', 4, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'kirja', 5, 'onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 6, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 7, 'oma', (select id from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma')),
    (v_line_id, 'kirja', 8, 'kassi', (select id from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi')),
    (v_line_id, 'puhe', 1, 'Haluuk', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'muovipussin', (select id from public.forms where lemma = 'muovipussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'muovipussin' and surface_puhe = 'muovipussin')),
    (v_line_id, 'puhe', 4, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'puhe', 5, 'onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 6, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 7, 'oma', (select id from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma')),
    (v_line_id, 'puhe', 8, 'kassi', (select id from public.forms where lemma = 'kassi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kassi' and surface_puhe = 'kassi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Anteeks, mä en ymmärtäny.',
    'Anteeksi, minä en ymmärtänyt.', 'Sorry, I didn''t understand.',
    'sorry-i-didnt-understand/2-puhe-61a84e6d1371.mp3', 'sorry-i-didnt-understand/2-kirja-9981a215bb1f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 4, 'ymmärtänyt', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 4, 'ymmärtäny', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ymmärtänyt' and surface_puhe = 'ymmärtäny'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Kari', 'Haluuksä pussin?',
    'Haluatko sinä pussin?', 'Do you want a bag?',
    'sorry-i-didnt-understand/3-puhe-03e1b34ff9a5.mp3', 'sorry-i-didnt-understand/3-kirja-cfb86d422bf8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Haluatko', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin')),
    (v_line_id, 'puhe', 1, 'Haluuk', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Voitsä puhuu vähän hitaammin?',
    'Voitko sinä puhua vähän hitaammin?', 'Could you speak a bit more slowly?',
    'sorry-i-didnt-understand/4-puhe-621651e8cffc.mp3', 'sorry-i-didnt-understand/4-kirja-7705c3964cd3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voitko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'puhua', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu')),
    (v_line_id, 'kirja', 4, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 5, 'hitaammin', (select id from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin')),
    (v_line_id, 'puhe', 1, 'Voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'puhuu', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu')),
    (v_line_id, 'puhe', 4, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 5, 'hitaammin', (select id from public.forms where lemma = 'hidas' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'hitaammin' and surface_puhe = 'hitaammin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Kari', 'Totta kai. Tarviitko pussin?',
    'Totta kai. Tarvitsetko pussin?', 'Of course. Do you need a bag?',
    'sorry-i-didnt-understand/5-puhe-f5497cf87498.mp3', 'sorry-i-didnt-understand/5-kirja-9b879ea93255.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Tarvitsetko', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko')),
    (v_line_id, 'kirja', 4, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Tarviitko', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tarvitsetko' and surface_puhe = 'tarviitko')),
    (v_line_id, 'puhe', 4, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Ai, pussin! Ei kiitos, mul on oma.',
    'Ai, pussin! Ei kiitos, minulla on oma.', 'Oh, a bag! No thanks, I have my own.',
    'sorry-i-didnt-understand/6-puhe-5e87dd018810.mp3', 'sorry-i-didnt-understand/6-kirja-569fb6bfc1fd.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'kirja', 2, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin')),
    (v_line_id, 'kirja', 3, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 4, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'kirja', 5, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 7, 'oma', (select id from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma')),
    (v_line_id, 'puhe', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'puhe', 2, 'pussin', (select id from public.forms where lemma = 'pussi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pussin' and surface_puhe = 'pussin')),
    (v_line_id, 'puhe', 3, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 4, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 5, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 7, 'oma', (select id from public.forms where lemma = 'oma' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oma' and surface_puhe = 'oma'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Kari', 'Hyvä. Sä puhut jo hyvin suomee.',
    'Hyvä. Sinä puhut jo hyvin suomea.', 'Good. You already speak Finnish well.',
    'sorry-i-didnt-understand/7-puhe-46351a91bedf.mp3', 'sorry-i-didnt-understand/7-kirja-a6c5c72a314d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'puhut', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut')),
    (v_line_id, 'kirja', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'kirja', 5, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 6, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'puhut', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut')),
    (v_line_id, 'puhe', 4, 'jo', (select id from public.forms where lemma = 'jo' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jo' and surface_puhe = 'jo')),
    (v_line_id, 'puhe', 5, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 6, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti! Mä opettelen vielä.',
    'Kiitos! Minä opettelen vielä.', 'Thanks! I''m still learning.',
    'sorry-i-didnt-understand/8-puhe-0036afcaa7dd.mp3', 'sorry-i-didnt-understand/8-kirja-5af45f211d24.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen')),
    (v_line_id, 'kirja', 4, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen')),
    (v_line_id, 'puhe', 4, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#sorry-i-didnt-understand/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
