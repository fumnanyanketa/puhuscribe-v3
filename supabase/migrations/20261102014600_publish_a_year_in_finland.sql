-- Publishes the dialogue a-year-in-finland (unit a-day-in-my-life). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-year-in-finland. Do not edit by hand:
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
    where slug = 'a-year-in-finland' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-year-in-finland';
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
  values (v_unit_id, 'a-year-in-finland', 2,
    'A year in Finland')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-year-in-finland' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'A year in Finland';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-year-in-finland';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-00cf76bd38f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nyt', 'nyt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nyt', 'nyt',
      (select form_name_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select why_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select lemma_meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olet', 'oot',
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-160976249e4f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olet', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olet', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"asua","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'asunut', 'asunu',
      'past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-c180a4cb7620');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asunut', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asunut', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      'past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vuosi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"vuosi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vuosi[X]vuo[Sg][Ny]den","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+vuosi(vuosi)"}'::jsonb,
      'vuoden', 'vuoden',
      'genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-7b346a8911fb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vuoden', 'vuosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vuoden', 'vuosi',
      (select form_name_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select why_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select lemma_meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      'genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sabl][Ny]ltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'miltä', 'miltä',
      'ablative singular', 'Miltä tuntuu asks ''how does it feel''. mikä, ''what'', takes -ltä: miltä.', 'how (does it feel)', 'what, which', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-97e8d36e8981');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miltä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Miltä tuntuu asks ''how does it feel''. mikä, ''what'', takes -ltä: miltä.', 'how (does it feel)', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miltä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä'),
      'ablative singular', 'Miltä tuntuu asks ''how does it feel''. mikä, ''what'', takes -ltä: miltä.', 'how (does it feel)', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuntua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tuntua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tuntua[X]tuntuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tuntua(tuntua)"}'::jsonb,
      'tuntuu', 'tuntuu',
      'present tense, 3rd person singular', 'Tuntua means to feel. The form for ''it'' doubles the last vowel: tuntuu.', 'feels', 'to feel, to seem', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-01232654a447');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuntuu', 'tuntua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tuntua means to feel. The form for ''it'' doubles the last vowel: tuntuu.', 'feels', 'to feel, to seem')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuntuu', 'tuntua',
      (select form_name_en from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu'),
      (select why_en from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu'),
      (select meaning_en from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu'),
      (select lemma_meaning_en from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu'),
      'present tense, 3rd person singular', 'Tuntua means to feel. The form for ''it'' doubles the last vowel: tuntuu.', 'feels', 'to feel, to seem';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyvä[Sabl][Ny]ltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvältä', 'hyvältä',
      'ablative singular', 'Answering miltä takes -ltä: hyvä becomes hyvältä, ''it feels good''.', 'good', 'good', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-f819ad03d7d3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvältä', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Answering miltä takes -ltä: hyvä becomes hyvältä, ''it feels good''.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvältä', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä'),
      'ablative singular', 'Answering miltä takes -ltä: hyvä becomes hyvältä, ''it feels good''.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alku', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"alku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]alku[X]alu[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+alku(alku)"}'::jsonb,
      'alussa', 'alus',
      'inessive singular', 'Adds -ssa for ''in'': alku becomes alussa, and the k drops. Speech says alus.', 'at first', 'beginning, start', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-1c3e763fad29');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alussa', 'alku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': alku becomes alussa, and the k drops. Speech says alus.', 'at first', 'beginning, start')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alussa', 'alku',
      (select form_name_en from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus'),
      (select why_en from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus'),
      (select meaning_en from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus'),
      (select lemma_meaning_en from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus'),
      'inessive singular', 'Adds -ssa for ''in'': alku becomes alussa, and the k drops. Speech says alus.', 'at first', 'beginning, start';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaikki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaikki[X]kaikk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kaikki(kaikki)"}'::jsonb,
      'kaikki', 'kaikki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-3b27ca0bf437');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaikki', 'kaikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaikki', 'kaikki',
      (select form_name_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select why_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select lemma_meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P3][Ny][Ef]li","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'oli', 'oli',
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-272accd9b290');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oli', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oli', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikea', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vaikea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]vaikea[X]vaike[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+vaikea(vaikea)"}'::jsonb,
      'vaikeaa', 'vaikeeta',
      'partitive singular', 'Describing kaikki takes -a: vaikea becomes vaikeaa. Speech says vaikeeta.', 'hard', 'hard, difficult', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-1d8a092d20e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaikeaa', 'vaikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Describing kaikki takes -a: vaikea becomes vaikeaa. Speech says vaikeeta.', 'hard', 'hard, difficult')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaikeaa', 'vaikea',
      (select form_name_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta'),
      (select why_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta'),
      (select meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta'),
      (select lemma_meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta'),
      'partitive singular', 'Describing kaikki takes -a: vaikea becomes vaikeaa. Speech says vaikeeta.', 'hard', 'hard, difficult';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikea', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"vaikea","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Ll][Xp]vaikea[X]vaike[Sp][Ny][Cs]inta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+vaikea(vaikea)"}'::jsonb,
      'vaikeinta', 'vaikeinta',
      'superlative, partitive singular', 'Vaikea means hard. -in makes ''hardest'', and -ta follows mikä oli: vaikeinta.', 'the hardest', 'hard, difficult', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-2a18018085ce');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaikeinta', 'vaikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, partitive singular', 'Vaikea means hard. -in makes ''hardest'', and -ta follows mikä oli: vaikeinta.', 'the hardest', 'hard, difficult')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaikeinta', 'vaikea',
      (select form_name_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta'),
      (select why_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta'),
      (select meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta'),
      (select lemma_meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta'),
      'superlative, partitive singular', 'Vaikea means hard. -in makes ''hardest'', and -ta follows mikä oli: vaikeinta.', 'the hardest', 'hard, difficult';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kieli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kieli[X]kiel[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kieli(kieli)"}'::jsonb,
      'kieli', 'kieli',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'language, tongue', 'language, tongue', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-1af90ca3ce82');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kieli', 'kieli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'language, tongue', 'language, tongue')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kieli', 'kieli',
      (select form_name_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli'),
      (select why_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli'),
      (select meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli'),
      (select lemma_meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'language, tongue', 'language, tongue';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pimeys', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"pimeys","CLASS":"nimisana","FSTOUTPUT":"[Lnl][Xp]pimeä[X]pime[Ln][Xj]ys[X]y[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+pime(pimeä)+ys(+ys)"}'::jsonb,
      'pimeys', 'pimeys',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'darkness', 'darkness', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-403efe6a2690');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pimeys', 'pimeys';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'darkness', 'darkness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pimeys', 'pimeys',
      (select form_name_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys'),
      (select why_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys'),
      (select meaning_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys'),
      (select lemma_meaning_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'darkness', 'darkness';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-728ddce13587');
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
      'present tense, 1st person singular', 'From pitää, to like. Books write pidän. Speech uses tykätä and says tykkään.', 'I like', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-33036ab9d70e');
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
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('molempi', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural', '{"BASEFORM":"molempi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]molempi[X]mole[Sela][Nm][Cc]mmista","NUMBER":"plural","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppppp","WORDBASES":"+molempi(molempi)"}'::jsonb,
      'molemmista', 'molemmist',
      'elative plural', 'Liking takes -sta: molemmat becomes molemmista. Speech drops the last vowel.', 'both', 'both', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-60a44210d79c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'molemmista', 'molempi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative plural', 'Liking takes -sta: molemmat becomes molemmista. Speech drops the last vowel.', 'both', 'both')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'molemmista', 'molempi',
      (select form_name_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist'),
      (select why_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist'),
      (select meaning_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist'),
      (select lemma_meaning_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist'),
      'elative plural', 'Liking takes -sta: molemmat becomes molemmista. Speech drops the last vowel.', 'both', 'both';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pimeys', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin', '{"BASEFORM":"pimeys","CLASS":"nimisana","FOCUS":"kin","FSTOUTPUT":"[Lnl][Xp]pimeä[X]pime[Ln][Xj]ys[X]yde[Sela][Ny]stä[Fkin][Ef]kin","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppppppppp","WORDBASES":"+pime(pimeä)+ys(+ys)"}'::jsonb,
      'pimeydestäkin', 'pimeydestäkin',
      'elative singular, with -kin (also)', 'Liking takes -stä: pimeys becomes pimeydestä. -kin adds ''even'': pimeydestäkin.', 'even the dark', 'darkness', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-c7a8e96225d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pimeydestäkin', 'pimeys';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular, with -kin (also)', 'Liking takes -stä: pimeys becomes pimeydestä. -kin adds ''even'': pimeydestäkin.', 'even the dark', 'darkness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pimeydestäkin', 'pimeys',
      (select form_name_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin'),
      (select why_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin'),
      (select meaning_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin'),
      (select lemma_meaning_en from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin'),
      'elative singular, with -kin (also)', 'Liking takes -stä: pimeys becomes pimeydestä. -kin adds ''even'': pimeydestäkin.', 'even the dark', 'darkness';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kynttilä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"kynttilä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kynttilä[X]kynttilä[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+kynttilä(kynttilä)"}'::jsonb,
      'kynttilät', 'kynttilät',
      'nominative plural', 'Adds -t for more than one: kynttilä becomes kynttilät.', 'candles', 'candle', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-b5c9f7f1faed');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kynttilät', 'kynttilä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: kynttilä becomes kynttilät.', 'candles', 'candle')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kynttilät', 'kynttilä',
      (select form_name_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät'),
      (select why_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät'),
      (select meaning_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät'),
      (select lemma_meaning_en from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät'),
      'nominative plural', 'Adds -t for more than one: kynttilä becomes kynttilät.', 'candles', 'candle';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'sauna', 'sauna',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-79d7845c7d34');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sauna', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaakao', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaakao","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaakao[X]kaakao[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kaakao(kaakao)"}'::jsonb,
      'kaakao', 'kaakao',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hot chocolate, cocoa', 'hot chocolate, cocoa', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-32a8ae07a193');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaakao', 'kaakao';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'hot chocolate, cocoa', 'hot chocolate, cocoa')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaakao', 'kaakao',
      (select form_name_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao'),
      (select why_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao'),
      (select meaning_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao'),
      (select lemma_meaning_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hot chocolate, cocoa', 'hot chocolate, cocoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-26f45640039d');
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
  if not exists (select 1 from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kodikas', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kodikas","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kodikas[X]kodika[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+kodikas(kodikas)"}'::jsonb,
      'kodikasta', 'kodikasta',
      'partitive singular', 'Describing se, ''it'', as a feeling takes -ta: kodikas becomes kodikasta.', 'cosy', 'cosy, homely', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-6658e0f146be');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kodikasta', 'kodikas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Describing se, ''it'', as a feeling takes -ta: kodikas becomes kodikasta.', 'cosy', 'cosy, homely')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kodikasta', 'kodikas',
      (select form_name_en from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta'),
      (select why_en from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta'),
      (select meaning_en from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta'),
      (select lemma_meaning_en from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta'),
      'partitive singular', 'Describing se, ''it'', as a feeling takes -ta: kodikas becomes kodikasta.', 'cosy', 'cosy, homely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-a392b28c6a8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aivan', 'aivan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aivan', 'aivan',
      (select form_name_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select why_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select lemma_meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalainen', 'suomalainen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Finnish, a Finn', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-2a904867b7d1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalainen', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Finnish, a Finn', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalainen', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Finnish, a Finn', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('melkein', 'CLASS=seikkasana', '{"BASEFORM":"melkein","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]melkein[X]melkein","STRUCTURE":"=ppppppp","WORDBASES":"+melkein(melkein)"}'::jsonb,
      'melkein', 'melkein',
      'adverb', 'This is the dictionary form. People say it the same way.', 'almost', 'almost', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-cf34640e6938');
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
  if not exists (select 1 from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juoda', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"juoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]juoda[X]juo[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+juoda(juoda)"}'::jsonb,
      'juon', 'juon',
      'present tense, 1st person singular', 'Juoda means to drink. -n goes with minä: juon.', 'I drink', 'to drink', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-cdf6effbf7c8');
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
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-2b3844766909');
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
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana;COMPARISON=comparative', '{"BASEFORM":"vähän","CLASS":"seikkasana","COMPARISON":"comparative","MANUAL":"true"}'::jsonb,
      'vähemmän', 'vähemmän',
      'comparative, adverb', 'Vähän, a little. The comparative is vähemmän, ''less''.', 'less', 'a little, a bit', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-26237af47930');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vähemmän', 'vähän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, adverb', 'Vähän, a little. The comparative is vähemmän, ''less''.', 'less', 'a little, a bit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vähemmän', 'vähän',
      (select form_name_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän'),
      (select why_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän'),
      (select meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän'),
      (select lemma_meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän'),
      'comparative, adverb', 'Vähän, a little. The comparative is vähemmän, ''less''.', 'less', 'a little, a bit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kahvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kahvi(kahvi)"}'::jsonb,
      'kahvia', 'kahvia',
      'partitive singular', 'The partitive adds -a for ''some'': kahvia. Here speech says it the same way.', 'coffee', 'coffee', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-304ceaba3156');
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
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuin', 'CLASS=sidesana', '{"BASEFORM":"kuin","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuin[X]kuin","STRUCTURE":"=pppp","WORDBASES":"+kuin(kuin)"}'::jsonb,
      'kuin', 'ku',
      'conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as', 'approved', now(), 'content/approvals/part-6.json#a-year-in-finland/form-999024e8747e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuin', 'kuin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuin', 'kuin',
      (select form_name_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select why_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select meaning_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select lemma_meaning_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      'conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Nyt sä oot asunu Suomes vuoden. Miltä tuntuu?',
    'Nyt sinä olet asunut Suomessa vuoden. Miltä tuntuu?', 'You''ve lived in Finland for a year now. How does it feel?',
    'a-year-in-finland/1-puhe-85644af06a0f.mp3', 'a-year-in-finland/1-kirja-b4d74c062c45.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 4, 'asunut', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu')),
    (v_line_id, 'kirja', 5, 'Suomessa', null),
    (v_line_id, 'kirja', 6, 'vuoden', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden')),
    (v_line_id, 'kirja', 7, 'Miltä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä')),
    (v_line_id, 'kirja', 8, 'tuntuu', (select id from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu')),
    (v_line_id, 'puhe', 1, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 4, 'asunu', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu')),
    (v_line_id, 'puhe', 5, 'Suomes', null),
    (v_line_id, 'puhe', 6, 'vuoden', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden')),
    (v_line_id, 'puhe', 7, 'Miltä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'miltä' and surface_puhe = 'miltä')),
    (v_line_id, 'puhe', 8, 'tuntuu', (select id from public.forms where lemma = 'tuntua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tuntuu' and surface_puhe = 'tuntuu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Hyvältä! Alus kaikki oli vaikeeta.',
    'Hyvältä! Alussa kaikki oli vaikeaa.', 'Good! At first everything was hard.',
    'a-year-in-finland/2-puhe-a6b648f6eb08.mp3', 'a-year-in-finland/2-kirja-2e67eb80f483.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvältä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä')),
    (v_line_id, 'kirja', 2, 'Alussa', (select id from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus')),
    (v_line_id, 'kirja', 3, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'kirja', 4, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'kirja', 5, 'vaikeaa', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta')),
    (v_line_id, 'puhe', 1, 'Hyvältä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvältä' and surface_puhe = 'hyvältä')),
    (v_line_id, 'puhe', 2, 'Alus', (select id from public.forms where lemma = 'alku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alussa' and surface_puhe = 'alus')),
    (v_line_id, 'puhe', 3, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'puhe', 4, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'puhe', 5, 'vaikeeta', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikeaa' and surface_puhe = 'vaikeeta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Mikä oli vaikeinta?',
    'Mikä oli vaikeinta?', 'What was the hardest?',
    'a-year-in-finland/3-puhe-39ac2a2291c5.mp3', 'a-year-in-finland/3-kirja-06bd1ec8b1ad.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'kirja', 3, 'vaikeinta', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta')),
    (v_line_id, 'puhe', 1, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'puhe', 3, 'vaikeinta', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'vaikeinta' and surface_puhe = 'vaikeinta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Kieli ja pimeys. Mut nyt mä tykkään molemmist.',
    'Kieli ja pimeys. Mutta nyt minä pidän molemmista.', 'The language and the dark. But now I like both.',
    'a-year-in-finland/4-puhe-69c2c44a0620.mp3', 'a-year-in-finland/4-kirja-3ca8fb440421.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kieli', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli')),
    (v_line_id, 'kirja', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'pimeys', (select id from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys')),
    (v_line_id, 'kirja', 4, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 6, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 7, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 8, 'molemmista', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist')),
    (v_line_id, 'puhe', 1, 'Kieli', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kieli' and surface_puhe = 'kieli')),
    (v_line_id, 'puhe', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'pimeys', (select id from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pimeys' and surface_puhe = 'pimeys')),
    (v_line_id, 'puhe', 4, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 6, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 7, 'tykkään', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 8, 'molemmist', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Molemmist? Pimeydestäkin?',
    'Molemmista? Pimeydestäkin?', 'Both? Even the dark?',
    'a-year-in-finland/5-puhe-acb2ee2125b1.mp3', 'a-year-in-finland/5-kirja-1838cb064917.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Molemmista', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist')),
    (v_line_id, 'kirja', 2, 'Pimeydestäkin', (select id from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin')),
    (v_line_id, 'puhe', 1, 'Molemmist', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=plural' and surface_kirja = 'molemmista' and surface_puhe = 'molemmist')),
    (v_line_id, 'puhe', 2, 'Pimeydestäkin', (select id from public.forms where lemma = 'pimeys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;FOCUS=kin' and surface_kirja = 'pimeydestäkin' and surface_puhe = 'pimeydestäkin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo! Kynttilät, sauna ja kaakao. Se on tosi kodikasta.',
    'Kyllä! Kynttilät, sauna ja kaakao. Se on todella kodikasta.', 'Yes! Candles, sauna and hot chocolate. It''s really cosy.',
    'a-year-in-finland/6-puhe-9bc9533c32ee.mp3', 'a-year-in-finland/6-kirja-7b3a794e853c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Kynttilät', (select id from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät')),
    (v_line_id, 'kirja', 3, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'kaakao', (select id from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao')),
    (v_line_id, 'kirja', 6, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 7, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 8, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 9, 'kodikasta', (select id from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Kynttilät', (select id from public.forms where lemma = 'kynttilä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'kynttilät' and surface_puhe = 'kynttilät')),
    (v_line_id, 'puhe', 3, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'kaakao', (select id from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaakao' and surface_puhe = 'kaakao')),
    (v_line_id, 'puhe', 6, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 7, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 8, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 9, 'kodikasta', (select id from public.forms where lemma = 'kodikas' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kodikasta' and surface_puhe = 'kodikasta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Sä oot nyt ihan suomalainen!',
    'Sinä olet nyt aivan suomalainen!', 'You''re totally Finnish now!',
    'a-year-in-finland/7-puhe-92052af599ed.mp3', 'a-year-in-finland/7-kirja-20c065864d69.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 2, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 3, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 4, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 5, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen')),
    (v_line_id, 'puhe', 1, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 2, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 3, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 4, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 5, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Melkein! Mut mä juon vielä vähemmän kahvia ku sä.',
    'Melkein! Mutta minä juon vielä vähemmän kahvia kuin sinä.', 'Almost! But I still drink less coffee than you.',
    'a-year-in-finland/8-puhe-02cd99f6bafc.mp3', 'a-year-in-finland/8-kirja-fb749e4b73a7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'kirja', 2, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'juon', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon')),
    (v_line_id, 'kirja', 5, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'kirja', 6, 'vähemmän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän')),
    (v_line_id, 'kirja', 7, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'kirja', 8, 'kuin', (select id from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku')),
    (v_line_id, 'kirja', 9, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 1, 'Melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'puhe', 2, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'juon', (select id from public.forms where lemma = 'juoda' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'juon' and surface_puhe = 'juon')),
    (v_line_id, 'puhe', 5, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 6, 'vähemmän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana;COMPARISON=comparative' and surface_kirja = 'vähemmän' and surface_puhe = 'vähemmän')),
    (v_line_id, 'puhe', 7, 'kahvia', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kahvia' and surface_puhe = 'kahvia')),
    (v_line_id, 'puhe', 8, 'ku', (select id from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku')),
    (v_line_id, 'puhe', 9, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-year-in-finland/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
