-- Publishes the dialogue family-far-away (unit talking-about-family). Made by
-- scripts/generate/pipeline.py publish from content/drafts/family-far-away. Do not edit by hand:
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
    where slug = 'family-far-away' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'family-far-away';
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
  values (v_unit_id, 'family-far-away', 2,
    'Family far away')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'family-far-away' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Family far away';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'family-far-away';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perhe', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"perhe","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perhe[X]perhe[Sn][Ny]e[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+perhe(perhe)"}'::jsonb,
      'perheesi', 'perhe',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: perheesi. Speech drops it and says sun perhe.', 'your family', 'family', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-396721a863e1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perheesi', 'perhe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: perheesi. Speech drops it and says sun perhe.', 'your family', 'family')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perheesi', 'perhe',
      (select form_name_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe'),
      (select why_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe'),
      (select meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe'),
      (select lemma_meaning_en from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe'),
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'', with an extra e: perheesi. Speech drops it and says sun perhe.', 'your family', 'family';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vanhempi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s', '{"BASEFORM":"vanhempi","CLASS":"nimisana","MANUAL":"true","NUMBER":"plural","POSSESSIVE":"1s","SIJAMUOTO":"nimento"}'::jsonb,
      'vanhempani', 'vanhemmat',
      'nominative plural, with the possessive ending for my', 'Vanhempi, parent. Many plus ''my'': vanhempani. Speech says mun vanhemmat and drops -ni.', 'my parents', 'parent, older', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-c2e1fa777561');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vanhempani', 'vanhempi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural, with the possessive ending for my', 'Vanhempi, parent. Many plus ''my'': vanhempani. Speech says mun vanhemmat and drops -ni.', 'my parents', 'parent, older')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vanhempani', 'vanhempi',
      (select form_name_en from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat'),
      (select why_en from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat'),
      (select meaning_en from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat'),
      (select lemma_meaning_en from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat'),
      'nominative plural, with the possessive ending for my', 'Vanhempi, parent. Many plus ''my'': vanhempani. Speech says mun vanhemmat and drops -ni.', 'my parents', 'parent, older';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('veli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"veli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]veli[X]vel[Sn][Ny]je[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+veli(veli)"}'::jsonb,
      'veljeni', 'veli',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': veljeni, with lj in place of l. Speech drops it and says mun veli.', 'my brother', 'brother', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-830b8156cb7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'veljeni', 'veli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': veljeni, with lj in place of l. Speech drops it and says mun veli.', 'my brother', 'brother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'veljeni', 'veli',
      (select form_name_en from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli'),
      (select why_en from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli'),
      (select meaning_en from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli'),
      (select lemma_meaning_en from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': veljeni, with lj in place of l. Speech drops it and says mun veli.', 'my brother', 'brother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"asua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]asua[X]asu[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+asua(asua)"}'::jsonb,
      'asuvat', 'asuu',
      'present tense, 3rd person plural', 'Books add -vat for ''they'': asuvat. Speech uses the he or she form: ne asuu.', 'they live', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-4eee14e4ec56');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asuvat', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books add -vat for ''they'': asuvat. Speech uses the he or she form: ne asuu.', 'they live', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asuvat', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu'),
      'present tense, 3rd person plural', 'Books add -vat for ''they'': asuvat. Speech uses the he or she form: ne asuu.', 'they live', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-0fd3b38079dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siellä', 'siellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siellä', 'siellä',
      (select form_name_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select why_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select lemma_meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulla', 'sul',
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ikävä', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ikävä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]ikävä[X]ikäv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+ikävä(ikävä)"}'::jsonb,
      'ikävä', 'ikävä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'missing someone, sad', 'missing someone, sad', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-29b3145ca1a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ikävä', 'ikävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'missing someone, sad', 'missing someone, sad')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ikävä', 'ikävä',
      (select form_name_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä'),
      (select why_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä'),
      (select meaning_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä'),
      (select lemma_meaning_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'missing someone, sad', 'missing someone, sad';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+he(he)"}'::jsonb,
      'heitä', 'niitä',
      'partitive plural', 'Books write heitä for people. Speech uses niitä, from ne.', 'them', 'they', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-be1fcde89a2c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heitä', 'he';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Books write heitä for people. Speech uses niitä, from ne.', 'them', 'they')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heitä', 'he',
      (select form_name_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä'),
      (select why_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä'),
      (select meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä'),
      (select lemma_meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä'),
      'partitive plural', 'Books write heitä for people. Speech uses niitä, from ne.', 'them', 'they';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-26f45640039d');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('soittaa', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"soittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]soittaa[X]soita[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+soittaa(soittaa)"}'::jsonb,
      'soitamme', 'soitetaan',
      'present tense, 1st person plural', 'Books write me soitamme. Speech says me soitetaan, the same form as ''one calls'', for ''we call''.', 'we call', 'to call, to play (music)', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-0f3e33cd9c2a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'soitamme', 'soittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write me soitamme. Speech says me soitetaan, the same form as ''one calls'', for ''we call''.', 'we call', 'to call, to play (music)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'soitamme', 'soittaa',
      (select form_name_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan'),
      (select why_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan'),
      (select meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan'),
      (select lemma_meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan'),
      'present tense, 1st person plural', 'Books write me soitamme. Speech says me soitetaan, the same form as ''one calls'', for ''we call''.', 'we call', 'to call, to play (music)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('joka', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"joka","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]joka[X]jo[Sn][Ny]ka","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+joka(joka)"}'::jsonb,
      'joka', 'joka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-b29d81df11e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'joka', 'joka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'joka', 'joka',
      (select form_name_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select why_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select meaning_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select lemma_meaning_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sunnuntai', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sunnuntai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sunnuntai[X]sunnuntai[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+sunnuntai(sunnuntai)"}'::jsonb,
      'sunnuntai', 'sunnuntai',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Sunday', 'Sunday', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-5b53ccd593d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sunnuntai', 'sunnuntai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Sunday', 'Sunday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sunnuntai', 'sunnuntai',
      (select form_name_en from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai'),
      (select why_en from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai'),
      (select meaning_en from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai'),
      (select lemma_meaning_en from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Sunday', 'Sunday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ap][P3][Nm][Ef]evat[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulevatko', 'tuleeks',
      'present tense, 3rd person plural, with the question ending -ko/-kö', 'Tulevat (they come) with the question ending -ko: tulevatko. Speech says tuleeks ne.', 'will they come', 'to come', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-1ebf6fb41604');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulevatko', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural, with the question ending -ko/-kö', 'Tulevat (they come) with the question ending -ko: tulevatko. Speech says tuleeks ne.', 'will they come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulevatko', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks'),
      'present tense, 3rd person plural, with the question ending -ko/-kö', 'Tulevat (they come) with the question ending -ko: tulevatko. Speech says tuleeks ne.', 'will they come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-ae2f0cff6156');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tn3][Ny][Sill]mään","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käymään', 'käymään',
      'MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-5947e1f56514');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käymään', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käymään', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      'MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kesä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kesä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kesä[X]kesä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+kesä(kesä)"}'::jsonb,
      'kesällä', 'kesällä',
      'adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-3edddf050b70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kesällä', 'kesä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kesällä', 'kesä',
      (select form_name_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select why_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      (select lemma_meaning_en from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä'),
      'adessive singular', 'Adds -llä to kesä to say when: kesällä, ''in the summer''.', 'in the summer', 'summer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('äiti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"äiti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]äiti[X]äit[Sn][Ny]i[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+äiti(äiti)"}'::jsonb,
      'äitini', 'äiti',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-fcdb40051581');
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'äitini', 'äiti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'äitini', 'äiti',
      (select form_name_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select why_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select lemma_meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halu[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluaa', 'haluu',
      'present tense, 3rd person singular', 'Books write haluaa. Speech turns aa into uu: haluu.', 'she wants', 'to want', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-ee8d0f9ec729');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluaa', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Books write haluaa. Speech turns aa into uu: haluu.', 'she wants', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluaa', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu'),
      'present tense, 3rd person singular', 'Books write haluaa. Speech turns aa into uu: haluu.', 'she wants', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]nähd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'nähdä', 'nähä',
      'basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-7750a252583e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nähdä', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nähdä', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      'basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lumi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lumi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lumi[X]lu[Sp][Ny]nta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lumi(lumi)"}'::jsonb,
      'lunta', 'lunta',
      'partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-17f6120f7a62');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lunta', 'lumi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lunta', 'lumi',
      (select form_name_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select why_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select lemma_meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      'partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sg][Nm]idän","NUMBER":"plural","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+he(he)"}'::jsonb,
      'heidän', 'niitten',
      'genitive plural', 'Books write heidän pitää. Speech uses niitten, from ne. Pitää (must) wants this form of the person.', 'they (need to)', 'they', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-841a282e06ce');
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heidän', 'he';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive plural', 'Books write heidän pitää. Speech uses niitten, from ne. Pitää (must) wants this form of the person.', 'they (need to)', 'they')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heidän', 'he',
      (select form_name_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten'),
      (select why_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten'),
      (select meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten'),
      (select lemma_meaning_en from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten'),
      'genitive plural', 'Books write heidän pitää. Speech uses niitten, from ne. Pitää (must) wants this form of the person.', 'they (need to)', 'they';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pitä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitää', 'pitää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-7aba8e0c1b63');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tull[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulla', 'tulla',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-0dffaba9319d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulla', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulla', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talvi', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"talvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]talvi[X]talve[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+talvi(talvi)"}'::jsonb,
      'talvella', 'talvella',
      'adessive singular', 'Talvi takes -lla to say when: talvella, ''in winter''.', 'in winter', 'winter', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-0eac850b6de3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talvella', 'talvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Talvi takes -lla to say when: talvella, ''in winter''.', 'in winter', 'winter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talvella', 'talvi',
      (select form_name_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella'),
      (select why_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella'),
      (select meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella'),
      (select lemma_meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella'),
      'adessive singular', 'Talvi takes -lla to say when: talvella, ''in winter''.', 'in winter', 'winter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-4.json#family-far-away/form-b20bd263b5ae');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Onks sun perhe Brasilias?',
    'Onko sinun perheesi Brasiliassa?', 'Is your family in Brazil?',
    'family-far-away/1-puhe-0ed05b978b8e.mp3', 'family-far-away/1-kirja-b6256d0faad8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 3, 'perheesi', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe')),
    (v_line_id, 'kirja', 4, 'Brasiliassa', null),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 3, 'perhe', (select id from public.forms where lemma = 'perhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'perheesi' and surface_puhe = 'perhe')),
    (v_line_id, 'puhe', 4, 'Brasilias', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mun vanhemmat ja veli asuu siel.',
    'Minun vanhempani ja veljeni asuvat siellä.', 'My parents and brother live there.',
    'family-far-away/2-puhe-06fe430b8203.mp3', 'family-far-away/2-kirja-411b9ea10e9a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'vanhempani', (select id from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat')),
    (v_line_id, 'kirja', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'veljeni', (select id from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli')),
    (v_line_id, 'kirja', 5, 'asuvat', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu')),
    (v_line_id, 'kirja', 6, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'vanhemmat', (select id from public.forms where lemma = 'vanhempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural;POSSESSIVE=1s' and surface_kirja = 'vanhempani' and surface_puhe = 'vanhemmat')),
    (v_line_id, 'puhe', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'veli', (select id from public.forms where lemma = 'veli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'veljeni' and surface_puhe = 'veli')),
    (v_line_id, 'puhe', 5, 'asuu', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asuvat' and surface_puhe = 'asuu')),
    (v_line_id, 'puhe', 6, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Onks sul ikävä niitä?',
    'Onko sinulla ikävä heitä?', 'Do you miss them?',
    'family-far-away/3-puhe-077766c9bc58.mp3', 'family-far-away/3-kirja-ad91df691217.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 3, 'ikävä', (select id from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä')),
    (v_line_id, 'kirja', 4, 'heitä', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 3, 'ikävä', (select id from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävä' and surface_puhe = 'ikävä')),
    (v_line_id, 'puhe', 4, 'niitä', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'heitä' and surface_puhe = 'niitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo, tosi paljon. Me soitetaan joka sunnuntai.',
    'Kyllä, todella paljon. Me soitamme joka sunnuntai.', 'Yes, very much. We call every Sunday.',
    'family-far-away/4-puhe-756ccf122196.mp3', 'family-far-away/4-kirja-c8187d2d8519.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 3, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 4, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 5, 'soitamme', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan')),
    (v_line_id, 'kirja', 6, 'joka', (select id from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka')),
    (v_line_id, 'kirja', 7, 'sunnuntai', (select id from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 3, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 4, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 5, 'soitetaan', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'soitamme' and surface_puhe = 'soitetaan')),
    (v_line_id, 'puhe', 6, 'joka', (select id from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka')),
    (v_line_id, 'puhe', 7, 'sunnuntai', (select id from public.forms where lemma = 'sunnuntai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sunnuntai' and surface_puhe = 'sunnuntai'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Tuleeks ne käymään Suomes?',
    'Tulevatko he käymään Suomessa?', 'Will they come and visit Finland?',
    'family-far-away/5-puhe-5d19e7f8f490.mp3', 'family-far-away/5-kirja-cab430f2fb4c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tulevatko', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks')),
    (v_line_id, 'kirja', 2, 'he', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 3, 'käymään', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään')),
    (v_line_id, 'kirja', 4, 'Suomessa', null),
    (v_line_id, 'puhe', 1, 'Tuleeks', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulevatko' and surface_puhe = 'tuleeks')),
    (v_line_id, 'puhe', 2, 'ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 3, 'käymään', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään')),
    (v_line_id, 'puhe', 4, 'Suomes', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, kesällä! Mun äiti haluu nähä lunta.',
    'Kyllä, kesällä! Minun äitini haluaa nähdä lunta.', 'Yes, in the summer! My mother wants to see snow.',
    'family-far-away/6-puhe-447ec3a51dde.mp3', 'family-far-away/6-kirja-5957f08cc29b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä')),
    (v_line_id, 'kirja', 3, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'äitini', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti')),
    (v_line_id, 'kirja', 5, 'haluaa', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu')),
    (v_line_id, 'kirja', 6, 'nähdä', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä')),
    (v_line_id, 'kirja', 7, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'kesällä', (select id from public.forms where lemma = 'kesä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kesällä' and surface_puhe = 'kesällä')),
    (v_line_id, 'puhe', 3, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'äiti', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti')),
    (v_line_id, 'puhe', 5, 'haluu', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaa' and surface_puhe = 'haluu')),
    (v_line_id, 'puhe', 6, 'nähä', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä')),
    (v_line_id, 'puhe', 7, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Sit niitten pitää tulla talvella!',
    'Sitten heidän pitää tulla talvella!', 'Then they need to come in winter!',
    'family-far-away/7-puhe-f63af919a510.mp3', 'family-far-away/7-kirja-81b45795a348.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 2, 'heidän', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten')),
    (v_line_id, 'kirja', 3, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'kirja', 4, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla')),
    (v_line_id, 'kirja', 5, 'talvella', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella')),
    (v_line_id, 'puhe', 1, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 2, 'niitten', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'heidän' and surface_puhe = 'niitten')),
    (v_line_id, 'puhe', 3, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'puhe', 4, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla')),
    (v_line_id, 'puhe', 5, 'talvella', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvella'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Totta!',
    'Totta!', 'True!',
    'family-far-away/8-puhe-9a847ac13638.mp3', 'family-far-away/8-kirja-d43b2514026e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#family-far-away/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
