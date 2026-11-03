-- Publishes the dialogue coffee-on-friday (unit making-a-plan). Made by
-- scripts/generate/pipeline.py publish from content/drafts/coffee-on-friday. Do not edit by hand:
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
    where slug = 'coffee-on-friday' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'coffee-on-friday';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 8
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'making-a-plan' and position = 8 and stop_number = 8;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'making-a-plan';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'coffee-on-friday', 1,
    'Coffee on Friday?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'coffee-on-friday' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Coffee on Friday?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'coffee-on-friday';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennäänkö', 'mennäänks',
      'present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-eb4684110c61');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennäänkö', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennäänkö', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      'present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvi', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"kahvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahvi[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppp","WORDBASES":"+kahvi(kahvi)"}'::jsonb,
      'kahville', 'kahville',
      'allative singular', 'Kahvi with -lle for ''to'': mennä kahville, go for coffee.', 'for coffee', 'coffee', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-7d0e810f4a23');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahville', 'kahvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Kahvi with -lle for ''to'': mennä kahville, go for coffee.', 'for coffee', 'coffee')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahville', 'kahvi',
      (select form_name_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville'),
      (select why_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville'),
      (select meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville'),
      'allative singular', 'Kahvi with -lle for ''to'': mennä kahville, go for coffee.', 'for coffee', 'coffee';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perjantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"perjantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perjantai[X]perjantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppppppppp","WORDBASES":"+perjantai(perjantai)"}'::jsonb,
      'perjantaina', 'perjantaina',
      'essive singular', 'Days take -na for ''on'': perjantai becomes perjantaina.', 'on Friday', 'Friday', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-85d910cf041c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perjantaina', 'perjantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': perjantai becomes perjantaina.', 'on Friday', 'Friday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perjantaina', 'perjantai',
      (select form_name_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina'),
      (select why_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina'),
      (select meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina'),
      (select lemma_meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina'),
      'essive singular', 'Days take -na for ''on'': perjantai becomes perjantaina.', 'on Friday', 'Friday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perjantai', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"perjantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perjantai[X]perjantai[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+perjantai(perjantai)"}'::jsonb,
      'perjantai', 'perjantai',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Friday', 'Friday', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-b932bdc67336');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perjantai', 'perjantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Friday', 'Friday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perjantai', 'perjantai',
      (select form_name_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai'),
      (select why_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai'),
      (select meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai'),
      (select lemma_meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Friday', 'Friday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käy', 'käy',
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-24f89699a032');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käy', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käy', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-cc0fdb024b55');
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
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomen', 'suomen',
      'genitive singular', 'Suomi with -n, and i turns to e: suomen kurssi, a Finnish course.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-dafe4e07eff8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomen', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Suomi with -n, and i turns to e: suomen kurssi, a Finnish course.', 'Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomen', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen'),
      'genitive singular', 'Suomi with -n, and i turns to e: suomen kurssi, a Finnish course.', 'Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kurssi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kurssi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kurssi[X]kurss[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kurssi(kurssi)"}'::jsonb,
      'kurssi', 'kurssi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'course', 'course', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-710798aad462');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kurssi', 'kurssi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'course', 'course')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kurssi', 'kurssi',
      (select form_name_en from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi'),
      (select why_en from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi'),
      (select meaning_en from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi'),
      (select lemma_meaning_en from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'course', 'course';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantai', 'lauantai',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-7bc6f4068285');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lauantai', 'lauantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Saturday', 'Saturday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lauantai', 'lauantai',
      (select form_name_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai'),
      (select why_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai'),
      (select meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai'),
      (select lemma_meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Saturday', 'Saturday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopii', 'sopii',
      'present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-a47b56ad4b54');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sopii', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sopii', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      'present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-f42052a3d5f2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mihin', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mihin', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aika', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"aika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aika[X]aik[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+aika(aika)"}'::jsonb,
      'aikaan', 'aikaan',
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-ea79f0748e36');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aikaan', 'aika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aikaan', 'aika',
      (select form_name_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select why_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select lemma_meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikka', 'CLASS=sidesana', '{"BASEFORM":"vaikka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vaikka[X]vaikka","STRUCTURE":"=pppppp","WORDBASES":"+vaikka(vaikka)"}'::jsonb,
      'vaikka', 'vaikka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-db8570c5aa75');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaikka', 'vaikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaikka', 'vaikka',
      (select form_name_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select why_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select meaning_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      (select lemma_meaning_en from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'for example, say, although', 'for example, say, although';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sabl][Ny]hdelta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kahdelta', 'kahelta',
      'ablative singular', 'Kaksi with -lta for ''at'' a clock time: kahdelta. Speech drops the d: kahelta.', 'at two', 'two', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-0f7620589a73');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-58f467b0bcb4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'missä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'missä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]nähd[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'nähdään', 'nähään',
      'present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-3154ca2238b6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nähdään', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nähdään', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      'present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvila', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kahvila","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvila[X]kahvila[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+kahvila(kahvila)"}'::jsonb,
      'kahvilan', 'kahvilan',
      'genitive singular', 'Kahvila with -n before edessä, in front of: kahvilan edessä.', 'the café', 'café', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-ec4b94229501');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvilan', 'kahvila';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kahvila with -n before edessä, in front of: kahvilan edessä.', 'the café', 'café')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvilan', 'kahvila',
      (select form_name_en from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan'),
      (select why_en from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan'),
      (select meaning_en from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan'),
      'genitive singular', 'Kahvila with -n before edessä, in front of: kahvilan edessä.', 'the café', 'café';
  end if;
  if not exists (select 1 from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('edessä', 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"edessä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]edessä[X]ede[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+edessä(edessä)"}'::jsonb,
      'edessä', 'edes',
      'inessive singular', 'Edessä comes after its word. Speech shortens -ssä to -s: Edessä becomes Edes.', 'in front of', 'in front of', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-1b8704bc3c91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'edessä', 'edessä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Edessä comes after its word. Speech shortens -ssä to -s: Edessä becomes Edes.', 'in front of', 'in front of')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'edessä', 'edessä',
      (select form_name_en from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes'),
      (select why_en from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes'),
      (select meaning_en from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes'),
      (select lemma_meaning_en from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes'),
      'inessive singular', 'Edessä comes after its word. Speech shortens -ssä to -s: Edessä becomes Edes.', 'in front of', 'in front of';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive', '{"BASEFORM":"sopia","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_passive","SIJAMUOTO":"nimento"}'::jsonb,
      'sovittu', 'sovittu',
      'past passive participle, nominative singular', 'From sopia, to agree. Sovittu means ''it is agreed'' and is said on its own to close a plan.', 'agreed, deal', 'to suit, to agree', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-e0a34444732a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sovittu', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past passive participle, nominative singular', 'From sopia, to agree. Sovittu means ''it is agreed'' and is said on its own to close a plan.', 'agreed, deal', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sovittu', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu'),
      'past passive participle, nominative singular', 'From sopia, to agree. Sovittu means ''it is agreed'' and is said on its own to close a plan.', 'agreed, deal', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-2.json#coffee-on-friday/form-3978a16fa6b0');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mennäänks kahville perjantaina?',
    'Mennäänkö kahville perjantaina?', 'Shall we go for coffee on Friday?',
    'coffee-on-friday/1-puhe-8ceddb694ddd.mp3', 'coffee-on-friday/1-kirja-bd45a84945cf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mennäänkö', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'kirja', 2, 'kahville', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville')),
    (v_line_id, 'kirja', 3, 'perjantaina', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina')),
    (v_line_id, 'puhe', 1, 'Mennäänks', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'puhe', 2, 'kahville', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kahville' and surface_puhe = 'kahville')),
    (v_line_id, 'puhe', 3, 'perjantaina', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'perjantaina' and surface_puhe = 'perjantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Perjantai ei käy, mul on suomen kurssi.',
    'Perjantai ei käy, minulla on suomen kurssi.', 'Friday doesn''t work, I have a Finnish course.',
    'coffee-on-friday/2-puhe-675197a3f469.mp3', 'coffee-on-friday/2-kirja-cce31a9599cc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Perjantai', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'kirja', 4, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'suomen', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen')),
    (v_line_id, 'kirja', 7, 'kurssi', (select id from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi')),
    (v_line_id, 'puhe', 1, 'Perjantai', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'perjantai' and surface_puhe = 'perjantai')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'puhe', 4, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'suomen', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'suomen' and surface_puhe = 'suomen')),
    (v_line_id, 'puhe', 7, 'kurssi', (select id from public.forms where lemma = 'kurssi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kurssi' and surface_puhe = 'kurssi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Entä lauantai?',
    'Entä lauantai?', 'What about Saturday?',
    'coffee-on-friday/3-puhe-d72aa3409591.mp3', 'coffee-on-friday/3-kirja-96dbe7b689b4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'lauantai', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'lauantai', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Lauantai sopii hyvin! Mihin aikaan?',
    'Lauantai sopii hyvin! Mihin aikaan?', 'Saturday suits me well! What time?',
    'coffee-on-friday/4-puhe-d58c1db51eab.mp3', 'coffee-on-friday/4-kirja-b777a55bd446.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lauantai', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai')),
    (v_line_id, 'kirja', 2, 'sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'kirja', 3, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 4, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 5, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'puhe', 1, 'Lauantai', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lauantai' and surface_puhe = 'lauantai')),
    (v_line_id, 'puhe', 2, 'sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'puhe', 3, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 4, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 5, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Vaikka kahelta?',
    'Vaikka kahdelta?', 'Say two o''clock?',
    'coffee-on-friday/5-puhe-eb54ad0b34bb.mp3', 'coffee-on-friday/5-kirja-0a8f73006c1f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vaikka', (select id from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka')),
    (v_line_id, 'kirja', 2, 'kahdelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta')),
    (v_line_id, 'puhe', 1, 'Vaikka', (select id from public.forms where lemma = 'vaikka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vaikka' and surface_puhe = 'vaikka')),
    (v_line_id, 'puhe', 2, 'kahelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kahelta on hyvä. Missä nähään?',
    'Kahdelta on hyvä. Missä nähdään?', 'Two is good. Where shall we meet?',
    'coffee-on-friday/6-puhe-208ad9656bec.mp3', 'coffee-on-friday/6-kirja-d6cc776c7269.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kahdelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 4, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 5, 'nähdään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'puhe', 1, 'Kahelta', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdelta' and surface_puhe = 'kahelta')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 4, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 5, 'nähään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Kahvilan edes.',
    'Kahvilan edessä.', 'In front of the café.',
    'coffee-on-friday/7-puhe-cf1348773386.mp3', 'coffee-on-friday/7-kirja-dc7bcd256d1f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kahvilan', (select id from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan')),
    (v_line_id, 'kirja', 2, 'edessä', (select id from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes')),
    (v_line_id, 'puhe', 1, 'Kahvilan', (select id from public.forms where lemma = 'kahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahvilan' and surface_puhe = 'kahvilan')),
    (v_line_id, 'puhe', 2, 'edes', (select id from public.forms where lemma = 'edessä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'edessä' and surface_puhe = 'edes'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Sovittu! Nähään lauantaina!',
    'Sovittu! Nähdään lauantaina!', 'Deal! See you on Saturday!',
    'coffee-on-friday/8-puhe-517a230be418.mp3', 'coffee-on-friday/8-kirja-7fb0ea337088.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sovittu', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu')),
    (v_line_id, 'kirja', 2, 'Nähdään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'kirja', 3, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 1, 'Sovittu', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'sovittu')),
    (v_line_id, 'puhe', 2, 'Nähään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'puhe', 3, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#coffee-on-friday/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
