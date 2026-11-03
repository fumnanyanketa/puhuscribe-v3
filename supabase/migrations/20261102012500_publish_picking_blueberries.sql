-- Publishes the dialogue picking-blueberries (unit out-in-nature). Made by
-- scripts/generate/pipeline.py publish from content/drafts/picking-blueberries. Do not edit by hand:
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
    where slug = 'picking-blueberries' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'picking-blueberries';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 29
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'out-in-nature' and position = 29 and stop_number = 29;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'out-in-nature';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'picking-blueberries', 2,
    'Picking blueberries')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'picking-blueberries' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Picking blueberries';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'picking-blueberries';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katsoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"katsoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]katsoa[X]katso[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+katsoa(katsoa)"}'::jsonb,
      'katso', 'kato',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-8350ddd0f318');
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'katso', 'katsoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'katso', 'katsoa',
      (select form_name_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select why_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      (select lemma_meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato'),
      'imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mustikka', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"mustikka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mustikka[X]mustik[Sp][Nm]oita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppp","WORDBASES":"+mustikka(mustikka)"}'::jsonb,
      'mustikoita', 'mustikoita',
      'partitive plural', 'Plural ''some'' takes -ita: mustikka becomes mustikoita, kk turning into k.', 'blueberries', 'blueberry', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-beb4218dfba2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mustikoita', 'mustikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ita: mustikka becomes mustikoita, kk turning into k.', 'blueberries', 'blueberry')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mustikoita', 'mustikka',
      (select form_name_en from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'),
      (select why_en from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'),
      (select meaning_en from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'),
      (select lemma_meaning_en from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'),
      'partitive plural', 'Plural ''some'' takes -ita: mustikka becomes mustikoita, kk turning into k.', 'blueberries', 'blueberry';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]saa[Tt][Ap][P3][Ny][Eb][Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saako', 'saaks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Saada, may, with the question ending -ko: saako? Speech uses -ks: saaks.', 'is it allowed', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-ef78e99a7c25');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saako', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Saada, may, with the question ending -ko: saako? Speech uses -ks: saaks.', 'is it allowed', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saako', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Saada, may, with the question ending -ko: saako? Speech uses -ks: saaks.', 'is it allowed', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sp][Nm]iitä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+ne(ne)"}'::jsonb,
      'niitä', 'niitä',
      'partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-bcee7be7d1e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niitä', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niitä', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'),
      'partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('poimia', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"poimia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]poimia[X]poimi[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+poimia(poimia)"}'::jsonb,
      'poimia', 'poimii',
      'basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ia into -ii: poimii.', 'to pick', 'to pick', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-ddea4cdf8570');
  end if;
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'poimia', 'poimia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ia into -ii: poimii.', 'to pick', 'to pick')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'poimia', 'poimia',
      (select form_name_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii'),
      (select why_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii'),
      (select meaning_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii'),
      (select lemma_meaning_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii'),
      'basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ia into -ii: poimii.', 'to pick', 'to pick';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]saa[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saa', 'saa',
      'present tense, 3rd person singular', 'From saada. Mitä saa olla? is a set phrase for ''What can I get you?''', 'may (in Mitä saa olla?)', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-8d5b7d527ca0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saa', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'From saada. Mitä saa olla? is a set phrase for ''What can I get you?''', 'may (in Mitä saa olla?)', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saa', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa'),
      'present tense, 3rd person singular', 'From saada. Mitä saa olla? is a set phrase for ''What can I get you?''', 'may (in Mitä saa olla?)', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suome[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomessa', 'suomes',
      'inessive singular', 'Adds -ssa for ''in'', and si changes to e: Suomi becomes Suomessa. Speech shortens -ssa to -s: Suomessa becomes Suomes.', 'in Finland', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-11490962728d');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jokamiehenoikeus', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"jokamiehenoikeus","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]joka=mies[X]joka[Bm]miehe[Sg][Ny]n[Bh][Bc][Lnl][Xp]oikea[X]oike[Ln][Xj]us[X]u[Sn][Nm]det","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=pppppp=pppppppp","WORDBASES":"+jokamiehen(joka=mies)+oike(oikea)+us(+us)"}'::jsonb,
      'jokamiehenoikeudet', 'jokamiehenoikeudet',
      'nominative plural', 'Finns say this with -t, as several rights: jokamiehenoikeus becomes jokamiehenoikeudet.', 'everyone''s right to roam', 'everyone''s right to roam', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-4920a47cae32');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jokamiehenoikeudet', 'jokamiehenoikeus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Finns say this with -t, as several rights: jokamiehenoikeus becomes jokamiehenoikeudet.', 'everyone''s right to roam', 'everyone''s right to roam')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jokamiehenoikeudet', 'jokamiehenoikeus',
      (select form_name_en from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet'),
      (select why_en from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet'),
      (select meaning_en from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet'),
      (select lemma_meaning_en from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet'),
      'nominative plural', 'Finns say this with -t, as several rights: jokamiehenoikeus becomes jokamiehenoikeudet.', 'everyone''s right to roam', 'everyone''s right to roam';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarkoittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarkoittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarkoittaa[X]tarkoitt[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppppppp","TENSE":"present_simple","WORDBASES":"+tarkoittaa(tarkoittaa)"}'::jsonb,
      'tarkoittaa', 'tarkottaa',
      'present tense, 3rd person singular', 'Tarkoittaa, to mean. With ''tuo sana'' the verb ends in a long vowel. Speech drops the i: tarkottaa.', 'means', 'to mean', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-e8893d00d23d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarkoittaa', 'tarkoittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tarkoittaa, to mean. With ''tuo sana'' the verb ends in a long vowel. Speech drops the i: tarkottaa.', 'means', 'to mean')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarkoittaa', 'tarkoittaa',
      (select form_name_en from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa'),
      (select why_en from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa'),
      (select meaning_en from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa'),
      (select lemma_meaning_en from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa'),
      'present tense, 3rd person singular', 'Tarkoittaa, to mean. With ''tuo sana'' the verb ends in a long vowel. Speech drops the i: tarkottaa.', 'means', 'to mean';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaikki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaikki[X]kaikk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kaikki(kaikki)"}'::jsonb,
      'kaikki', 'kaikki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-3b27ca0bf437');
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
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]saa[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saavat', 'saa',
      'present tense, 3rd person plural', 'Books add -vat for ''they'': saavat. Speech uses the short form saa with kaikki, ''everyone''.', 'can, are allowed', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-99a664403261');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saavat', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books add -vat for ''they'': saavat. Speech uses the short form saa with kaikki, ''everyone''.', 'can, are allowed', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saavat', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa'),
      'present tense, 3rd person plural', 'Books add -vat for ''they'': saavat. Speech uses the short form saa with kaikki, ''everyone''.', 'can, are allowed', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('liikkua', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"liikkua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]liikkua[X]liikku[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+liikkua(liikkua)"}'::jsonb,
      'liikkua', 'liikkuu',
      'basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ua into -uu.', 'to move around', 'to move (around)', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-bc1a0696022f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'liikkua', 'liikkua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ua into -uu.', 'to move around', 'to move (around)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'liikkua', 'liikkua',
      (select form_name_en from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu'),
      (select why_en from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu'),
      (select meaning_en from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu'),
      (select lemma_meaning_en from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu'),
      'basic form (A-infinitive)', 'This is the dictionary form, used after saa, ''may''. Speech turns the ending -ua into -uu.', 'to move around', 'to move (around)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('luonto', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"luonto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]luonto[X]luonno[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppp","WORDBASES":"+luonto(luonto)"}'::jsonb,
      'luonnossa', 'luonnos',
      'inessive singular', 'Adds -ssa for ''in'': luonto becomes luonnossa, nt turning into nn. Speech says luonnos.', 'in nature', 'nature', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-f7121f74c115');
  end if;
  if not exists (select 1 from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'luonnossa', 'luonto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': luonto becomes luonnossa, nt turning into nn. Speech says luonnos.', 'in nature', 'nature')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'luonnossa', 'luonto',
      (select form_name_en from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos'),
      (select why_en from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos'),
      (select meaning_en from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos'),
      (select lemma_meaning_en from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos'),
      'inessive singular', 'Adds -ssa for ''in'': luonto becomes luonnossa, nt turning into nn. Speech says luonnos.', 'in nature', 'nature';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('marja', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"marja","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]marja[X]marj[Sp][Nm]oja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+marja(marja)"}'::jsonb,
      'marjoja', 'marjoja',
      'partitive plural', 'Plural ''some'' takes -ja: marja becomes marjoja, the last a turning into o.', 'berries', 'berry', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-fadae9bebf98');
  end if;
  if not exists (select 1 from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'marjoja', 'marja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ja: marja becomes marjoja, the last a turning into o.', 'berries', 'berry')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'marjoja', 'marja',
      (select form_name_en from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja'),
      (select why_en from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja'),
      (select meaning_en from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja'),
      (select lemma_meaning_en from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja'),
      'partitive plural', 'Plural ''some'' takes -ja: marja becomes marjoja, the last a turning into o.', 'berries', 'berry';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mahtava', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"mahtava","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"osanto"}'::jsonb,
      'mahtavaa', 'mahtavaa',
      'partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-1377edc59a33');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mahtavaa', 'mahtava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mahtavaa', 'mahtava',
      (select form_name_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select why_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select meaning_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select lemma_meaning_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      'partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sieni', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"sieni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sieni[X]sien[Sn][Nm]et","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+sieni(sieni)"}'::jsonb,
      'sienet', 'sienet',
      'nominative plural', 'Adds -t for more than one: sieni becomes sienet.', 'mushrooms', 'mushroom', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-bd5b9c4e91be');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sienet', 'sieni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: sieni becomes sienet.', 'mushrooms', 'mushroom')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sienet', 'sieni',
      (select form_name_en from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet'),
      (select why_en from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet'),
      (select meaning_en from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet'),
      (select lemma_meaning_en from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet'),
      'nominative plural', 'Adds -t for more than one: sieni becomes sienet.', 'mushrooms', 'mushroom';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin', '{"BASEFORM":"ne","CLASS":"asemosana","FOCUS":"kin","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sp][Nm]iitä[Fkin][Ef]kin","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+ne(ne)"}'::jsonb,
      'niitäkin', 'niitäkin',
      'partitive plural, with -kin (also)', 'Niitä means ''them''. The ending -kin adds ''too'': niitäkin.', 'those too', 'they, those', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-3f98424b1f05');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niitäkin', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural, with -kin (also)', 'Niitä means ''them''. The ending -kin adds ''too'': niitäkin.', 'those too', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niitäkin', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin'),
      'partitive plural, with -kin (also)', 'Niitä means ''them''. The ending -kin adds ''too'': niitäkin.', 'those too', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ole[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ole', 'ole',
      'imperative present tense, 2nd person singular', 'The imperative for one person is olla without its ending: ole. ''Ole hyvä'' means ''here you are'' or ''you''re welcome''.', 'be (here you are)', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-cf236284c229');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ole', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person is olla without its ending: ole. ''Ole hyvä'' means ''here you are'' or ''you''re welcome''.', 'be (here you are)', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ole', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole'),
      'imperative present tense, 2nd person singular', 'The imperative for one person is olla without its ending: ole. ''Ole hyvä'' means ''here you are'' or ''you''re welcome''.', 'be (here you are)', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varovainen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"varovainen","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"nimento"}'::jsonb,
      'varovainen', 'varovainen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'careful', 'careful', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-e76edb14e9f5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'varovainen', 'varovainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'careful', 'careful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'varovainen', 'varovainen',
      (select form_name_en from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen'),
      (select why_en from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen'),
      (select meaning_en from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen'),
      (select lemma_meaning_en from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'careful', 'careful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osa', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"osa","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osa[X]os[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+osa(osa)"}'::jsonb,
      'osa', 'osa',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'part, some', 'part, some', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-7b309eb706e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osa', 'osa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'part, some', 'part, some')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osa', 'osa',
      (select form_name_en from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa'),
      (select why_en from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa'),
      (select meaning_en from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa'),
      (select lemma_meaning_en from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'part, some', 'part, some';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myrkyllinen', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"myrkyllinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]myrkky[X]myrky[Ll]lli[Xj]nen[X][Sp][Nm]siä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+myrky(myrkky)+lli+nen(+nen)"}'::jsonb,
      'myrkyllisiä', 'myrkyllisiä',
      'partitive plural', 'Plural ''some'' takes -iä: myrkyllinen becomes myrkyllisiä.', 'poisonous', 'poisonous', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-f138dafca65f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myrkyllisiä', 'myrkyllinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -iä: myrkyllinen becomes myrkyllisiä.', 'poisonous', 'poisonous')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myrkyllisiä', 'myrkyllinen',
      (select form_name_en from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä'),
      (select why_en from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä'),
      (select meaning_en from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä'),
      (select lemma_meaning_en from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä'),
      'partitive plural', 'Plural ''some'' takes -iä: myrkyllinen becomes myrkyllisiä.', 'poisonous', 'poisonous';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('poimia', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"poimia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]poimia[X]poimi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+poimia(poimia)"}'::jsonb,
      'poimin', 'poimin',
      'present tense, 1st person singular', 'Poimia means to pick. The ending -n goes with minä: poimin.', 'I pick', 'to pick', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-517310fcc9d2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'poimin', 'poimia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Poimia means to pick. The ending -n goes with minä: poimin.', 'I pick', 'to pick')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'poimin', 'poimia',
      (select form_name_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin'),
      (select why_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin'),
      (select meaning_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin'),
      (select lemma_meaning_en from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin'),
      'present tense, 1st person singular', 'Poimia means to pick. The ending -n goes with minä: poimin.', 'I pick', 'to pick';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-5.json#picking-blueberries/form-ab6bb2b103e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vain', 'vain';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vain', 'vain',
      (select form_name_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select why_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select meaning_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select lemma_meaning_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Kato, mustikoita!',
    'Katso, mustikoita!', 'Look, blueberries!',
    'picking-blueberries/1-puhe-e6a9dd3f9d48.mp3', 'picking-blueberries/1-kirja-cfd6f3194b1e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Katso', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'kirja', 2, 'mustikoita', (select id from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita')),
    (v_line_id, 'puhe', 1, 'Kato', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'puhe', 2, 'mustikoita', (select id from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Saaks niitä poimii?',
    'Saako niitä poimia?', 'Are we allowed to pick them?',
    'picking-blueberries/2-puhe-5ed5429baecb.mp3', 'picking-blueberries/2-kirja-99543807c53f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Saako', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks')),
    (v_line_id, 'kirja', 2, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä')),
    (v_line_id, 'kirja', 3, 'poimia', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii')),
    (v_line_id, 'puhe', 1, 'Saaks', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saako' and surface_puhe = 'saaks')),
    (v_line_id, 'puhe', 2, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä')),
    (v_line_id, 'puhe', 3, 'poimii', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Saa. Suomes on jokamiehenoikeudet.',
    'Saa. Suomessa on jokamiehenoikeudet.', 'Yes. Finland has everyone''s right to roam.',
    'picking-blueberries/3-puhe-04aa34301846.mp3', 'picking-blueberries/3-kirja-000eaba9e871.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Saa', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa')),
    (v_line_id, 'kirja', 2, 'Suomessa', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'jokamiehenoikeudet', (select id from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet')),
    (v_line_id, 'puhe', 1, 'Saa', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'saa' and surface_puhe = 'saa')),
    (v_line_id, 'puhe', 2, 'Suomes', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'suomessa' and surface_puhe = 'suomes')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'jokamiehenoikeudet', (select id from public.forms where lemma = 'jokamiehenoikeus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'jokamiehenoikeudet' and surface_puhe = 'jokamiehenoikeudet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mitä se tarkottaa?',
    'Mitä se tarkoittaa?', 'What does that mean?',
    'picking-blueberries/4-puhe-bbd162e2c5d5.mp3', 'picking-blueberries/4-kirja-a9fafadfd8ad.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'tarkoittaa', (select id from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'tarkottaa', (select id from public.forms where lemma = 'tarkoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarkoittaa' and surface_puhe = 'tarkottaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Kaikki saa liikkuu luonnos ja poimii marjoja.',
    'Kaikki saavat liikkua luonnossa ja poimia marjoja.', 'Everyone can move around in nature and pick berries.',
    'picking-blueberries/5-puhe-f6d87392a9d8.mp3', 'picking-blueberries/5-kirja-633cd5138d25.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'kirja', 2, 'saavat', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa')),
    (v_line_id, 'kirja', 3, 'liikkua', (select id from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu')),
    (v_line_id, 'kirja', 4, 'luonnossa', (select id from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'poimia', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii')),
    (v_line_id, 'kirja', 7, 'marjoja', (select id from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja')),
    (v_line_id, 'puhe', 1, 'Kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'puhe', 2, 'saa', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saavat' and surface_puhe = 'saa')),
    (v_line_id, 'puhe', 3, 'liikkuu', (select id from public.forms where lemma = 'liikkua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'liikkua' and surface_puhe = 'liikkuu')),
    (v_line_id, 'puhe', 4, 'luonnos', (select id from public.forms where lemma = 'luonto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'luonnossa' and surface_puhe = 'luonnos')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'poimii', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'poimia' and surface_puhe = 'poimii')),
    (v_line_id, 'puhe', 7, 'marjoja', (select id from public.forms where lemma = 'marja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'marjoja' and surface_puhe = 'marjoja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Mahtavaa! Entä sienet?',
    'Mahtavaa! Entä sienet?', 'Fantastic! And mushrooms?',
    'picking-blueberries/6-puhe-86c8971507ae.mp3', 'picking-blueberries/6-kirja-027e0fc7b2b4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'kirja', 2, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 3, 'sienet', (select id from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet')),
    (v_line_id, 'puhe', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'puhe', 2, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 3, 'sienet', (select id from public.forms where lemma = 'sieni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'sienet' and surface_puhe = 'sienet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Niitäkin, mut ole varovainen. Osa on myrkyllisiä.',
    'Niitäkin, mutta ole varovainen. Osa on myrkyllisiä.', 'Those too, but be careful. Some are poisonous.',
    'picking-blueberries/7-puhe-10b8ad455d45.mp3', 'picking-blueberries/7-kirja-f54205fb6e70.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Niitäkin', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin')),
    (v_line_id, 'kirja', 2, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole')),
    (v_line_id, 'kirja', 4, 'varovainen', (select id from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen')),
    (v_line_id, 'kirja', 5, 'Osa', (select id from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa')),
    (v_line_id, 'kirja', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 7, 'myrkyllisiä', (select id from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä')),
    (v_line_id, 'puhe', 1, 'Niitäkin', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural;FOCUS=kin' and surface_kirja = 'niitäkin' and surface_puhe = 'niitäkin')),
    (v_line_id, 'puhe', 2, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ole' and surface_puhe = 'ole')),
    (v_line_id, 'puhe', 4, 'varovainen', (select id from public.forms where lemma = 'varovainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'varovainen' and surface_puhe = 'varovainen')),
    (v_line_id, 'puhe', 5, 'Osa', (select id from public.forms where lemma = 'osa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osa' and surface_puhe = 'osa')),
    (v_line_id, 'puhe', 6, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 7, 'myrkyllisiä', (select id from public.forms where lemma = 'myrkyllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'myrkyllisiä' and surface_puhe = 'myrkyllisiä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mä poimin vaan mustikoita!',
    'Minä poimin vain mustikoita!', 'I''ll just pick blueberries!',
    'picking-blueberries/8-puhe-21c43f990b08.mp3', 'picking-blueberries/8-kirja-de55bf16ed95.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'poimin', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin')),
    (v_line_id, 'kirja', 3, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 4, 'mustikoita', (select id from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'poimin', (select id from public.forms where lemma = 'poimia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'poimin' and surface_puhe = 'poimin')),
    (v_line_id, 'puhe', 3, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 4, 'mustikoita', (select id from public.forms where lemma = 'mustikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'mustikoita' and surface_puhe = 'mustikoita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#picking-blueberries/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
