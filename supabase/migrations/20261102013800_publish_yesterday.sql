-- Publishes the dialogue yesterday (unit my-past). Made by
-- scripts/generate/pipeline.py publish from content/drafts/yesterday. Do not edit by hand:
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
    where slug = 'yesterday' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'yesterday';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 33
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'my-past' and position = 33 and stop_number = 33;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'my-past';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'yesterday', 3,
    'Yesterday')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'yesterday' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Yesterday';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'yesterday';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-a0c867e0dc77');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]te[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teit', 'teit',
      'past tense, 2nd person singular', 'Tehdä, to do, in the past tense with -t for ''you'': teit.', 'you did', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-8ffc5a21db9d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teit', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Tehdä, to do, in the past tense with -t for ''you'': teit.', 'you did', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teit', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit'),
      'past tense, 2nd person singular', 'Tehdä, to do, in the past tense with -t for ''you'': teit.', 'you did', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eilen', 'CLASS=seikkasana', '{"BASEFORM":"eilen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eilen[X]eilen","STRUCTURE":"=ppppp","WORDBASES":"+eilen(eilen)"}'::jsonb,
      'eilen', 'eilen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-937949f7d75d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eilen', 'eilen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eilen', 'eilen',
      (select form_name_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select why_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select lemma_meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('herätä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"herätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]herätä[X]heräs[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+herätä(herätä)"}'::jsonb,
      'heräsin', 'heräsin',
      'past tense, 1st person singular', 'Herätä means to wake up. In the past, with minä, it becomes heräsin.', 'I woke up', 'to wake up', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-685d8eaab59a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heräsin', 'herätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Herätä means to wake up. In the past, with minä, it becomes heräsin.', 'I woke up', 'to wake up')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heräsin', 'herätä',
      (select form_name_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin'),
      (select why_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin'),
      (select meaning_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin'),
      (select lemma_meaning_en from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin'),
      'past tense, 1st person singular', 'Herätä means to wake up. In the past, with minä, it becomes heräsin.', 'I woke up', 'to wake up';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aikainen', 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"aikainen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]aika[X]aika[Ll][Xj]inen[X]is[Sin][Nm]in","NUMBER":"plural","SIJAMUOTO":"keinonto","STRUCTURE":"=pppppppp","WORDBASES":"+aika(aika)+inen(+inen)"}'::jsonb,
      'aikaisin', 'aikasin',
      'instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-54a1444a5f36');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aikaisin', 'aikainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aikaisin', 'aikainen',
      (select form_name_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select why_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select meaning_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      (select lemma_meaning_en from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin'),
      'instructive plural', 'A fixed word meaning ''early'', from aikainen. Speech drops an i: aikasin.', 'early', 'early';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käv[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'kävin', 'kävin',
      'past tense, 1st person singular', 'Käydä, to visit, in the past tense with -n for ''I'': kävin.', 'I visited', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-853d0c9771cf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kävin', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Käydä, to visit, in the past tense with -n for ''I'': kävin.', 'I visited', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kävin', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin'),
      'past tense, 1st person singular', 'Käydä, to visit, in the past tense with -n for ''I'': kävin.', 'I visited', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lenkki', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"lenkki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lenkki[X]lenki[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+lenkki(lenkki)"}'::jsonb,
      'lenkillä', 'lenkillä',
      'adessive singular', 'Adds -llä for ''on'': lenkki becomes lenkillä, kk turning into k.', 'on a run', 'run, walk (for exercise)', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-dc4034e3a032');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lenkillä', 'lenkki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''on'': lenkki becomes lenkillä, kk turning into k.', 'on a run', 'run, walk (for exercise)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lenkillä', 'lenkki',
      (select form_name_en from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä'),
      (select why_en from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä'),
      (select meaning_en from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä'),
      (select lemma_meaning_en from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä'),
      'adessive singular', 'Adds -llä for ''on'': lenkki becomes lenkillä, kk turning into k.', 'on a run', 'run, walk (for exercise)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamu', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"aamu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+aamu(aamu)"}'::jsonb,
      'aamulla', 'aamulla',
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla, ''in the morning''.', 'in the morning', 'morning', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-ffb14f9998f6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamulla', 'aamu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla, ''in the morning''.', 'in the morning', 'morning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamulla', 'aamu',
      (select form_name_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla'),
      (select why_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla'),
      (select meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla'),
      (select lemma_meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla'),
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla, ''in the morning''.', 'in the morning', 'morning';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ennen', 'CLASS=seikkasana', '{"BASEFORM":"ennen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ennen[X]ennen","STRUCTURE":"=ppppp","WORDBASES":"+ennen(ennen)"}'::jsonb,
      'ennen', 'ennen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'before', 'before', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-e588ac0b00a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ennen', 'ennen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'before', 'before')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ennen', 'ennen',
      (select form_name_en from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen'),
      (select why_en from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen'),
      (select meaning_en from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen'),
      (select lemma_meaning_en from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'before', 'before';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töitä', 'töitä',
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-a6fa8fd612dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töitä', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töitä', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syödä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"syödä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]syödä[X]sö[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+syödä(syödä)"}'::jsonb,
      'söin', 'söin',
      'past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-b626212a64ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'söin', 'syödä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'söin', 'syödä',
      (select form_name_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select why_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select lemma_meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      'past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamupala', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"aamupala","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sn][Ny][Bh][Bc][Ln][Xp]pala[X]pal[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp=ppppp","WORDBASES":"+aamu(aamu)+pala(pala)"}'::jsonb,
      'aamupalaa', 'aamupalaa',
      'partitive singular', 'Eating some of something takes -a: aamupala becomes aamupalaa.', 'breakfast', 'breakfast', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-9b06868d3ccc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamupalaa', 'aamupala';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Eating some of something takes -a: aamupala becomes aamupalaa.', 'breakfast', 'breakfast')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamupalaa', 'aamupala',
      (select form_name_en from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa'),
      (select why_en from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa'),
      (select meaning_en from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa'),
      (select lemma_meaning_en from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa'),
      'partitive singular', 'Eating some of something takes -a: aamupala becomes aamupalaa.', 'breakfast', 'breakfast';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulin', 'tulin',
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-85741e401e76');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulin', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulin', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sill][Nm]ihin","NUMBER":"plural","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töihin', 'töihin',
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-74a674b54acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töihin', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töihin', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-73c5475313cb');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]te[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tein', 'tein',
      'past tense, 1st person singular', 'Tehdä means to do or make. In the past, with minä, it becomes tein.', 'I made, I cooked', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-917c1d848766');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tein', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Tehdä means to do or make. In the past, with minä, it becomes tein.', 'I made, I cooked', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tein', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein'),
      'past tense, 1st person singular', 'Tehdä means to do or make. In the past, with minä, it becomes tein.', 'I made, I cooked', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ruoka', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"ruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ruoka[X]ruok[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ruoka(ruoka)"}'::jsonb,
      'ruokaa', 'ruokaa',
      'partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-cbb6d60b2833');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ruokaa', 'ruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ruokaa', 'ruoka',
      (select form_name_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select why_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      'partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katsoa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"katsoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]katsoa[X]katso[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+katsoa(katsoa)"}'::jsonb,
      'katsoin', 'katoin',
      'past tense, 1st person singular', 'Katsoa in the past tense with -n for ''I''. Speech drops the s: katoin.', 'I watched', 'to look, to watch', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-40c90f594a5b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'katsoin', 'katsoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Katsoa in the past tense with -n for ''I''. Speech drops the s: katoin.', 'I watched', 'to look, to watch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'katsoin', 'katsoa',
      (select form_name_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin'),
      (select why_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin'),
      (select meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin'),
      (select lemma_meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin'),
      'past tense, 1st person singular', 'Katsoa in the past tense with -n for ''I''. Speech drops the s: katoin.', 'I watched', 'to look, to watch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uutinen', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"uutinen","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]uutinen[X]uuti[Sp][Nm]sia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+uutinen(uutinen)"}'::jsonb,
      'uutisia', 'uutisii',
      'partitive plural', 'Watching the news takes -ia: uutinen becomes uutisia. Speech turns -ia into -ii.', 'the news', 'news, a news item', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-247c69e2a793');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uutisia', 'uutinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Watching the news takes -ia: uutinen becomes uutisia. Speech turns -ia into -ii.', 'the news', 'news, a news item')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uutisia', 'uutinen',
      (select form_name_en from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii'),
      (select why_en from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii'),
      (select meaning_en from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii'),
      (select lemma_meaning_en from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii'),
      'partitive plural', 'Watching the news takes -ia: uutinen becomes uutisia. Speech turns -ia into -ii.', 'the news', 'news, a news item';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suome[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomeksi', 'suomeks',
      'translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-016e9c711274');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomeksi', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomeksi', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      'translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selkouutinen', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"selkouutinen","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]selko[X]selko[Sn][Ny][Bh][Bc][Ln][Xp]uutinen[X]uuti[Sp][Nm]sia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+selko(selko)+uutinen(uutinen)"}'::jsonb,
      'selkouutisia', 'selkouutisii',
      'partitive plural', 'Selkouutinen becomes selkouutisia, like uutisia. Speech turns -ia into -ii.', 'easy-Finnish news', 'easy-Finnish news', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-550306d084c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'selkouutisia', 'selkouutinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Selkouutinen becomes selkouutisia, like uutisia. Speech turns -ia into -ii.', 'easy-Finnish news', 'easy-Finnish news')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'selkouutisia', 'selkouutinen',
      (select form_name_en from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii'),
      (select why_en from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii'),
      (select meaning_en from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii'),
      (select lemma_meaning_en from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii'),
      'partitive plural', 'Selkouutinen becomes selkouutisia, like uutisia. Speech turns -ia into -ii.', 'easy-Finnish news', 'easy-Finnish news';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ymmärtää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"ymmärtää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ymmärtää[X]ymmärs[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"past_imperfective","WORDBASES":"+ymmärtää(ymmärtää)"}'::jsonb,
      'ymmärsin', 'ymmärsin',
      'past tense, 1st person singular', 'Ymmärtää means to understand. In the past, with minä, it becomes ymmärsin.', 'I understood', 'to understand', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-2931e5358ced');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ymmärsin', 'ymmärtää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Ymmärtää means to understand. In the past, with minä, it becomes ymmärsin.', 'I understood', 'to understand')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ymmärsin', 'ymmärtää',
      (select form_name_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin'),
      (select why_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin'),
      (select meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin'),
      (select lemma_meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin'),
      'past tense, 1st person singular', 'Ymmärtää means to understand. In the past, with minä, it becomes ymmärsin.', 'I understood', 'to understand';
  end if;
  if not exists (select 1 from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('melkein', 'CLASS=seikkasana', '{"BASEFORM":"melkein","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]melkein[X]melkein","STRUCTURE":"=ppppppp","WORDBASES":"+melkein(melkein)"}'::jsonb,
      'melkein', 'melkein',
      'adverb', 'This is the dictionary form. People say it the same way.', 'almost', 'almost', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-cf34640e6938');
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
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaikki', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kaikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaikki[X]kaik[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kaikki(kaikki)"}'::jsonb,
      'kaiken', 'kaiken',
      'genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-6.json#yesterday/form-064e99054944');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaiken', 'kaikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaiken', 'kaikki',
      (select form_name_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select why_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      (select lemma_meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'),
      'genitive singular', 'Kaikki becomes kaiken when it is the thing you tell: kerron kaiken.', 'everything', 'all, everything, everyone';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Mitä sä teit eilen?',
    'Mitä sinä teit eilen?', 'What did you do yesterday?',
    'yesterday/1-puhe-0baff0adb353.mp3', 'yesterday/1-kirja-e119d6434ba5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teit', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit')),
    (v_line_id, 'kirja', 4, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teit', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teit' and surface_puhe = 'teit')),
    (v_line_id, 'puhe', 4, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä heräsin aikasin ja kävin lenkillä.',
    'Minä heräsin aikaisin ja kävin lenkillä.', 'I woke up early and went for a run.',
    'yesterday/2-puhe-38e49606201c.mp3', 'yesterday/2-kirja-b12bcc2b8d4c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'heräsin', (select id from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin')),
    (v_line_id, 'kirja', 3, 'aikaisin', (select id from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'kävin', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin')),
    (v_line_id, 'kirja', 6, 'lenkillä', (select id from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'heräsin', (select id from public.forms where lemma = 'herätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'heräsin' and surface_puhe = 'heräsin')),
    (v_line_id, 'puhe', 3, 'aikasin', (select id from public.forms where lemma = 'aikainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=keinonto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'aikaisin' and surface_puhe = 'aikasin')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'kävin', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kävin' and surface_puhe = 'kävin')),
    (v_line_id, 'puhe', 6, 'lenkillä', (select id from public.forms where lemma = 'lenkki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lenkillä' and surface_puhe = 'lenkillä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'Aamulla? Ennen töitä?',
    'Aamulla? Ennen töitä?', 'In the morning? Before work?',
    'yesterday/3-puhe-cb3b982b6d7f.mp3', 'yesterday/3-kirja-5021080365a7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aamulla', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla')),
    (v_line_id, 'kirja', 2, 'Ennen', (select id from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen')),
    (v_line_id, 'kirja', 3, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'puhe', 1, 'Aamulla', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamulla')),
    (v_line_id, 'puhe', 2, 'Ennen', (select id from public.forms where lemma = 'ennen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ennen' and surface_puhe = 'ennen')),
    (v_line_id, 'puhe', 3, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo. Sit mä söin aamupalaa ja tulin töihin.',
    'Kyllä. Sitten minä söin aamupalaa ja tulin töihin.', 'Yes. Then I had breakfast and came to work.',
    'yesterday/4-puhe-471d7d7fe4b4.mp3', 'yesterday/4-kirja-13507aa87eb3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'söin', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin')),
    (v_line_id, 'kirja', 5, 'aamupalaa', (select id from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa')),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'kirja', 8, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'söin', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin')),
    (v_line_id, 'puhe', 5, 'aamupalaa', (select id from public.forms where lemma = 'aamupala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'aamupalaa' and surface_puhe = 'aamupalaa')),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'puhe', 8, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ville', 'Entä illal?',
    'Entä illalla?', 'And in the evening?',
    'yesterday/5-puhe-f358970c24db.mp3', 'yesterday/5-kirja-81835e979bad.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Mä tein ruokaa ja katoin uutisii.',
    'Minä tein ruokaa ja katsoin uutisia.', 'I cooked and watched the news.',
    'yesterday/6-puhe-e609f27c69ac.mp3', 'yesterday/6-kirja-08245c3f8b4f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'tein', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein')),
    (v_line_id, 'kirja', 3, 'ruokaa', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'katsoin', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin')),
    (v_line_id, 'kirja', 6, 'uutisia', (select id from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tein', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tein' and surface_puhe = 'tein')),
    (v_line_id, 'puhe', 3, 'ruokaa', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'katoin', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'katsoin' and surface_puhe = 'katoin')),
    (v_line_id, 'puhe', 6, 'uutisii', (select id from public.forms where lemma = 'uutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'uutisia' and surface_puhe = 'uutisii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ville', 'Suomeks?',
    'Suomeksi?', 'In Finnish?',
    'yesterday/7-puhe-49d1fcbba466.mp3', 'yesterday/7-kirja-b23ff1aefcc3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Suomeksi', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks')),
    (v_line_id, 'puhe', 1, 'Suomeks', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Joo, selkouutisii. Mä ymmärsin melkein kaiken!',
    'Kyllä, selkouutisia. Minä ymmärsin melkein kaiken!', 'Yes, the easy-Finnish news. I understood almost everything!',
    'yesterday/8-puhe-a6a5bd5eb462.mp3', 'yesterday/8-kirja-927e4b8f410a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'selkouutisia', (select id from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'ymmärsin', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin')),
    (v_line_id, 'kirja', 5, 'melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'kirja', 6, 'kaiken', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'selkouutisii', (select id from public.forms where lemma = 'selkouutinen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'selkouutisia' and surface_puhe = 'selkouutisii')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'ymmärsin', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ymmärsin' and surface_puhe = 'ymmärsin')),
    (v_line_id, 'puhe', 5, 'melkein', (select id from public.forms where lemma = 'melkein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'melkein' and surface_puhe = 'melkein')),
    (v_line_id, 'puhe', 6, 'kaiken', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kaiken' and surface_puhe = 'kaiken'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#yesterday/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#yesterday/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
