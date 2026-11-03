-- Publishes the dialogue what-do-you-like-doing (unit free-time-and-hobbies). Made by
-- scripts/generate/pipeline.py publish from content/drafts/what-do-you-like-doing. Do not edit by hand:
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
    where slug = 'what-do-you-like-doing' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'what-do-you-like-doing';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 22
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'free-time-and-hobbies' and position = 22 and stop_number = 22;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'free-time-and-hobbies';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'what-do-you-like-doing', 1,
    'What do you like doing?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'what-do-you-like-doing' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'What do you like doing?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'what-do-you-like-doing';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkäät', 'tykkäät',
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-43715f936732');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkäät', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkäät', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdä', 'tehä',
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-f64c6f94ba00');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tehdä', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tehdä', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vapaa-aika', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"vapaa-aika","CLASS":"nimisana","FSTOUTPUT":"[Lp]vapaa-[Bh][Bc][Ln][Xp]aika[X]aja[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppp-=pppppp","WORDBASES":"+vapaa+-+aika(aika)"}'::jsonb,
      'vapaa-ajalla', 'vapaa-ajalla',
      'adessive singular', 'Adds -lla for ''in'' a time: vapaa-aika becomes vapaa-ajalla, with k changing to j.', 'in your free time', 'free time', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-cfbf056f193e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vapaa-ajalla', 'vapaa-aika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''in'' a time: vapaa-aika becomes vapaa-ajalla, with k changing to j.', 'in your free time', 'free time')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vapaa-ajalla', 'vapaa-aika',
      (select form_name_en from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla'),
      (select why_en from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla'),
      (select meaning_en from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla'),
      (select lemma_meaning_en from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla'),
      'adessive singular', 'Adds -lla for ''in'' a time: vapaa-aika becomes vapaa-ajalla, with k changing to j.', 'in your free time', 'free time';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkään', 'tykkään',
      'present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-140f37ece90d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkään', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkään', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      'present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uida', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"uida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]uida[X]uid[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppp","WORDBASES":"+uida(uida)"}'::jsonb,
      'uida', 'uida',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swim', 'to swim', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-c99454c34da4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uida', 'uida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swim', 'to swim')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uida', 'uida',
      (select form_name_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida'),
      (select why_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida'),
      (select meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida'),
      (select lemma_meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swim', 'to swim';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lukea', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"lukea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lukea[X]luke[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+lukea(lukea)"}'::jsonb,
      'lukea', 'lukee',
      'basic form (A-infinitive)', 'This is the dictionary form, after tykkään (I like). Speech turns ea into ee: lukee.', 'read', 'to read', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-eb6bbfd447ab');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lukea', 'lukea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after tykkään (I like). Speech turns ea into ee: lukee.', 'read', 'to read')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lukea', 'lukea',
      (select form_name_en from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee'),
      (select why_en from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee'),
      (select meaning_en from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee'),
      (select lemma_meaning_en from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee'),
      'basic form (A-infinitive)', 'This is the dictionary form, after tykkään (I like). Speech turns ea into ee: lukee.', 'read', 'to read';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-58f467b0bcb4');
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
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"uida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]uida[X]ui[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+uida(uida)"}'::jsonb,
      'uit', 'uit',
      'present tense, 2nd person singular', 'Uida drops -da and takes -t for ''you'': uit.', 'you swim', 'to swim', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-a3abea1bb22b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uit', 'uida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Uida drops -da and takes -t for ''you'': uit.', 'you swim', 'to swim')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uit', 'uida',
      (select form_name_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit'),
      (select why_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit'),
      (select meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit'),
      (select lemma_meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit'),
      'present tense, 2nd person singular', 'Uida drops -da and takes -t for ''you'': uit.', 'you swim', 'to swim';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uimahalli', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"uimahalli","CLASS":"nimisana","FSTOUTPUT":"[Lp]uima[Bh][Bc][Ln][Ica][Xp]halli[X]halli[Sine][Ny]ssa","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppp=pppppppp","WORDBASES":"+uima+halli(halli)"}'::jsonb,
      'uimahallissa', 'uimahallis',
      'inessive singular', 'Adds -ssa for ''in'': uimahalli becomes uimahallissa. Speech shortens -ssa to -s: uimahallissa becomes uimahallis.', 'at the swimming pool', 'swimming pool (indoor)', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-f52a6eb064fb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uimahallissa', 'uimahalli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': uimahalli becomes uimahallissa. Speech shortens -ssa to -s: uimahallissa becomes uimahallis.', 'at the swimming pool', 'swimming pool (indoor)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uimahallissa', 'uimahalli',
      (select form_name_en from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis'),
      (select why_en from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis'),
      (select meaning_en from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis'),
      (select lemma_meaning_en from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis'),
      'inessive singular', 'Adds -ssa for ''in'': uimahalli becomes uimahallissa. Speech shortens -ssa to -s: uimahallissa becomes uimahallis.', 'at the swimming pool', 'swimming pool (indoor)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pelata', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pelata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]pelata[X]pelaa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+pelata(pelata)"}'::jsonb,
      'pelaan', 'pelaan',
      'present tense, 1st person singular', 'Pelata changes to pelaa- and takes -n for ''I'': pelaan.', 'I play', 'to play (a game or sport)', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-26fd1a6f4a04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pelaan', 'pelata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Pelata changes to pelaa- and takes -n for ''I'': pelaan.', 'I play', 'to play (a game or sport)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pelaan', 'pelata',
      (select form_name_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan'),
      (select why_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan'),
      (select meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan'),
      (select lemma_meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan'),
      'present tense, 1st person singular', 'Pelata changes to pelaa- and takes -n for ''I'': pelaan.', 'I play', 'to play (a game or sport)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sulkapallo', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"sulkapallo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sulka[X]sulk[Sn][Ny]a[Bh][Bc][Ln][Xp]pallo[X]pallo[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+sulka(sulka)+pallo(pallo)"}'::jsonb,
      'sulkapalloa', 'sulkapalloo',
      'partitive singular', 'After pelata (to play), a game takes -a: sulkapallo becomes sulkapalloa. Speech doubles the o: sulkapalloo.', 'badminton', 'badminton', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-595c503b2314');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sulkapalloa', 'sulkapallo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After pelata (to play), a game takes -a: sulkapallo becomes sulkapalloa. Speech doubles the o: sulkapalloo.', 'badminton', 'badminton')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sulkapalloa', 'sulkapallo',
      (select form_name_en from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo'),
      (select why_en from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo'),
      (select meaning_en from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo'),
      (select lemma_meaning_en from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo'),
      'partitive singular', 'After pelata (to play), a game takes -a: sulkapallo becomes sulkapalloa. Speech doubles the o: sulkapalloo.', 'badminton', 'badminton';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käyn', 'käyn',
      'present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-042a57533dce');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käyn', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käyn', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      'present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuntosali', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kuntosali","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kunto[X]kunto[Sn][Ny][Bh][Bc][Ln][Xp]sali[X]sali[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+kunto(kunto)+sali(sali)"}'::jsonb,
      'kuntosalilla', 'salilla',
      'adessive singular', 'Speech uses the short word sali: salilla. Books write kuntosalilla, with -lla for ''at''.', 'at the gym', 'gym', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-27b84ab7b0a7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuntosalilla', 'kuntosali';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Speech uses the short word sali: salilla. Books write kuntosalilla, with -lla for ''at''.', 'at the gym', 'gym')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuntosalilla', 'kuntosali',
      (select form_name_en from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla'),
      (select why_en from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla'),
      (select meaning_en from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla'),
      (select lemma_meaning_en from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla'),
      'adessive singular', 'Speech uses the short word sali: salilla. Books write kuntosalilla, with -lla for ''at''.', 'at the gym', 'gym';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('usein', 'CLASS=seikkasana', '{"BASEFORM":"usein","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'usein', 'usein',
      'adverb', 'This is the dictionary form. People say it the same way.', 'often', 'often', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-c6e5c9e4a651');
  end if;
  if not exists (select 1 from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'usein', 'usein';
  end if;
  if not exists (select 1 from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'often', 'often')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'usein', 'usein',
      (select form_name_en from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein'),
      (select why_en from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein'),
      (select meaning_en from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein'),
      (select lemma_meaning_en from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'often', 'often';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-05a31ace9a1d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksi', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksi', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kerta', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kerta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kerta[X]kert[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kerta(kerta)"}'::jsonb,
      'kertaa', 'kertaa',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: kolme kertaa, ''three times''.', 'times', 'time, occasion', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-1eb6785e9d13');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kertaa', 'kerta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: kolme kertaa, ''three times''.', 'times', 'time, occasion')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kertaa', 'kerta',
      (select form_name_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa'),
      (select why_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa'),
      (select meaning_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: kolme kertaa, ''three times''.', 'times', 'time, occasion';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikossa', 'viikos',
      'inessive singular', 'Adds -ssa to viikko (week), with one k: kaksi kertaa viikossa, ''twice a week''. Speech says viikos.', 'a week', 'week', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-657900c67439');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikossa', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa to viikko (week), with one k: kaksi kertaa viikossa, ''twice a week''. Speech says viikos.', 'a week', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikossa', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos'),
      'inessive singular', 'Adds -ssa to viikko (week), with one k: kaksi kertaa viikossa, ''twice a week''. Speech says viikos.', 'a week', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluan', 'haluun',
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-65809211d876');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluan', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluan', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'kans',
      'adverb', 'Speech often says kans. Books write myös.', 'too', 'also, too', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-300b16a8545b');
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
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alkaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"alkaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]alkaa[X]alka[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+alkaa(alkaa)"}'::jsonb,
      'alkaa', 'alkaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-66c4c8a1800c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alkaa', 'alkaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alkaa', 'alkaa',
      (select form_name_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select why_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select meaning_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select lemma_meaning_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pelata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"pelata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]pelata[X]pelat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+pelata(pelata)"}'::jsonb,
      'pelata', 'pelaa',
      'basic form (A-infinitive)', 'This is the dictionary form, after alkaa (to start). Speech drops the final ta: pelaa.', 'play', 'to play (a game or sport)', 'approved', now(), 'content/approvals/part-4.json#what-do-you-like-doing/form-d07b40515fec');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pelata', 'pelata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after alkaa (to start). Speech drops the final ta: pelaa.', 'play', 'to play (a game or sport)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pelata', 'pelata',
      (select form_name_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa'),
      (select why_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa'),
      (select meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa'),
      (select lemma_meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa'),
      'basic form (A-infinitive)', 'This is the dictionary form, after alkaa (to start). Speech drops the final ta: pelaa.', 'play', 'to play (a game or sport)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Mitä sä tykkäät tehä vapaa-ajalla?',
    'Mitä sinä tykkäät tehdä vapaa-ajalla?', 'What do you like doing in your free time?',
    'what-do-you-like-doing/1-puhe-a4d0718e68ac.mp3', 'what-do-you-like-doing/1-kirja-6c4218d36501.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät')),
    (v_line_id, 'kirja', 4, 'tehdä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'kirja', 5, 'vapaa-ajalla', (select id from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät')),
    (v_line_id, 'puhe', 4, 'tehä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'puhe', 5, 'vapaa-ajalla', (select id from public.forms where lemma = 'vapaa-aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'vapaa-ajalla' and surface_puhe = 'vapaa-ajalla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä tykkään uida ja lukee.',
    'Minä tykkään uida ja lukea.', 'I like swimming and reading.',
    'what-do-you-like-doing/2-puhe-92a8a603852c.mp3', 'what-do-you-like-doing/2-kirja-0357b5c34045.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 3, 'uida', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'lukea', (select id from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 3, 'uida', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'uida' and surface_puhe = 'uida')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'lukee', (select id from public.forms where lemma = 'lukea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lukea' and surface_puhe = 'lukee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Missä sä uit?',
    'Missä sinä uit?', 'Where do you swim?',
    'what-do-you-like-doing/3-puhe-4e14049b3e58.mp3', 'what-do-you-like-doing/3-kirja-c816dbfeb12b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'uit', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit')),
    (v_line_id, 'puhe', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'uit', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uit' and surface_puhe = 'uit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Uimahallis. Entä sä?',
    'Uimahallissa. Entä sinä?', 'At the swimming pool. And you?',
    'what-do-you-like-doing/4-puhe-2164194f529b.mp3', 'what-do-you-like-doing/4-kirja-98e559a89cbc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Uimahallissa', (select id from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis')),
    (v_line_id, 'kirja', 2, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 1, 'Uimahallis', (select id from public.forms where lemma = 'uimahalli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'uimahallissa' and surface_puhe = 'uimahallis')),
    (v_line_id, 'puhe', 2, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Mä pelaan sulkapalloo ja käyn salilla.',
    'Minä pelaan sulkapalloa ja käyn kuntosalilla.', 'I play badminton and go to the gym.',
    'what-do-you-like-doing/5-puhe-3c56a0037df1.mp3', 'what-do-you-like-doing/5-kirja-152e506f6bb7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'pelaan', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan')),
    (v_line_id, 'kirja', 3, 'sulkapalloa', (select id from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'käyn', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn')),
    (v_line_id, 'kirja', 6, 'kuntosalilla', (select id from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'pelaan', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pelaan' and surface_puhe = 'pelaan')),
    (v_line_id, 'puhe', 3, 'sulkapalloo', (select id from public.forms where lemma = 'sulkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sulkapalloa' and surface_puhe = 'sulkapalloo')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'käyn', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn')),
    (v_line_id, 'puhe', 6, 'salilla', (select id from public.forms where lemma = 'kuntosali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kuntosalilla' and surface_puhe = 'salilla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kuinka usein?',
    'Kuinka usein?', 'How often?',
    'what-do-you-like-doing/6-puhe-9091922c187f.mp3', 'what-do-you-like-doing/6-kirja-da278195c2be.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'usein', (select id from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'usein', (select id from public.forms where lemma = 'usein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'usein' and surface_puhe = 'usein'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Kaks kertaa viikos.',
    'Kaksi kertaa viikossa.', 'Twice a week.',
    'what-do-you-like-doing/7-puhe-dbd26240c412.mp3', 'what-do-you-like-doing/7-kirja-0c0d1596308d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 2, 'kertaa', (select id from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa')),
    (v_line_id, 'kirja', 3, 'viikossa', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos')),
    (v_line_id, 'puhe', 1, 'Kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 2, 'kertaa', (select id from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kertaa' and surface_puhe = 'kertaa')),
    (v_line_id, 'puhe', 3, 'viikos', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'viikossa' and surface_puhe = 'viikos'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Hyvä! Mä haluun kans alkaa pelaa.',
    'Hyvä! Minä haluan myös alkaa pelata.', 'Great! I want to start playing too.',
    'what-do-you-like-doing/8-puhe-34a30f5e843b.mp3', 'what-do-you-like-doing/8-kirja-b95bcf595a43.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans')),
    (v_line_id, 'kirja', 5, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa')),
    (v_line_id, 'kirja', 6, 'pelata', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 4, 'kans', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'kans')),
    (v_line_id, 'puhe', 5, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa')),
    (v_line_id, 'puhe', 6, 'pelaa', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pelata' and surface_puhe = 'pelaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#what-do-you-like-doing/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
