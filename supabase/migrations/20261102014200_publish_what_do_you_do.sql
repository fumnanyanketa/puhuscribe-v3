-- Publishes the dialogue what-do-you-do (unit my-work-and-skills). Made by
-- scripts/generate/pipeline.py publish from content/drafts/what-do-you-do. Do not edit by hand:
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
    where slug = 'what-do-you-do' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'what-do-you-do';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 35
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'my-work-and-skills' and position = 35 and stop_number = 35;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'my-work-and-skills';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'what-do-you-do', 1,
    'What do you do?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'what-do-you-do' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'What do you do?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'what-do-you-do';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-a0c867e0dc77');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teet', 'teet',
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-d8e27c6cf4bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teet', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teet', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]työ[Str][Ny]kse[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'työksesi', 'työks',
      'translative singular, with the possessive ending for your', 'Mitä teet työksesi asks ''what do you do for work''. Speech drops -esi: työks.', 'for (your) work', 'work, job', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-002f0284c4ab');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työksesi', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular, with the possessive ending for your', 'Mitä teet työksesi asks ''what do you do for work''. Speech drops -esi: työks.', 'for (your) work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työksesi', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks'),
      'translative singular, with the possessive ending for your', 'Mitä teet työksesi asks ''what do you do for work''. Speech drops -esi: työks.', 'for (your) work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-7588912c8134');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olen', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asiakaspalvelu', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"asiakaspalvelu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asiakas[X]asiaka[Sn][Ny]s[Bh][Bc][Lt][Xp]palvella[X]palvel[Ln][Xj]u[X]u[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp=pppppppppp","WORDBASES":"+asiakas(asiakas)+palvel(palvella)+u(+u)"}'::jsonb,
      'asiakaspalvelussa', 'asiakaspalvelus',
      'inessive singular', 'Adds -ssa for ''in'': asiakaspalvelu becomes asiakaspalvelussa. Speech shortens -ssa to -s: asiakaspalvelussa becomes asiakaspalvelus.', 'in customer service', 'customer service', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-df893cd83caf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asiakaspalvelussa', 'asiakaspalvelu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': asiakaspalvelu becomes asiakaspalvelussa. Speech shortens -ssa to -s: asiakaspalvelussa becomes asiakaspalvelus.', 'in customer service', 'customer service')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asiakaspalvelussa', 'asiakaspalvelu',
      (select form_name_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus'),
      (select why_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus'),
      (select meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus'),
      (select lemma_meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus'),
      'inessive singular', 'Adds -ssa for ''in'': asiakaspalvelu becomes asiakaspalvelussa. Speech shortens -ssa to -s: asiakaspalvelussa becomes asiakaspalvelus.', 'in customer service', 'customer service';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ammatti', 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"ammatti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ammatti[X]ammati[Sabl][Ny]lta[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppppp","WORDBASES":"+ammatti(ammatti)"}'::jsonb,
      'ammatiltani', 'ammatiltani',
      'ablative singular, with the possessive ending for my', 'Ammatti means profession. -lta with -ni for ''my'' gives ammatiltani, ''by profession''.', 'by profession', 'profession, occupation', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-80d6cb559316');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ammatiltani', 'ammatti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular, with the possessive ending for my', 'Ammatti means profession. -lta with -ni for ''my'' gives ammatiltani, ''by profession''.', 'by profession', 'profession, occupation')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ammatiltani', 'ammatti',
      (select form_name_en from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani'),
      (select why_en from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani'),
      (select meaning_en from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani'),
      (select lemma_meaning_en from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani'),
      'ablative singular, with the possessive ending for my', 'Ammatti means profession. -lta with -ni for ''my'' gives ammatiltani, ''by profession''.', 'by profession', 'profession, occupation';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaja', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"opettaja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Ln][Xj]ja[X][Sn][Ny]ja","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+opetta(opettaa)+ja(+ja)"}'::jsonb,
      'opettaja', 'opettaja',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'teacher', 'teacher', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-6a35f7e46946');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettaja', 'opettaja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'teacher', 'teacher')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettaja', 'opettaja',
      (select form_name_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'),
      (select why_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'),
      (select meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'teacher', 'teacher';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"opettaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opet[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+opettaa(opettaa)"}'::jsonb,
      'opetit', 'opetit',
      'past tense, 2nd person singular', 'Opettaa means to teach. In the past, with sinä, it becomes opetit.', 'you taught', 'to teach', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-63b58879e062');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opetit', 'opettaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Opettaa means to teach. In the past, with sinä, it becomes opetit.', 'you taught', 'to teach')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opetit', 'opettaa',
      (select form_name_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit'),
      (select why_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit'),
      (select meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit'),
      'past tense, 2nd person singular', 'Opettaa means to teach. In the past, with sinä, it becomes opetit.', 'you taught', 'to teach';
  end if;
  if not exists (select 1 from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('matematiikka', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"matematiikka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]matematiikka[X]matematiikk[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppppp","WORDBASES":"+matematiikka(matematiikka)"}'::jsonb,
      'matematiikkaa', 'matikkaa',
      'partitive singular', 'Teaching a subject takes -a: matematiikkaa. Speech says matikka, giving matikkaa.', 'maths', 'maths', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-0abb80e04c50');
  end if;
  if not exists (select 1 from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'matematiikkaa', 'matematiikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Teaching a subject takes -a: matematiikkaa. Speech says matikka, giving matikkaa.', 'maths', 'maths')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'matematiikkaa', 'matematiikka',
      (select form_name_en from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa'),
      (select why_en from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa'),
      (select meaning_en from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa'),
      (select lemma_meaning_en from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa'),
      'partitive singular', 'Teaching a subject takes -a: matematiikkaa. Speech says matikka, giving matikkaa.', 'maths', 'maths';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('englanti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"englanti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]englanti[X]englant[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+englanti(englanti)"}'::jsonb,
      'englantia', 'englantii',
      'partitive singular', 'The partitive adds -a after puhua, to speak: englantia. Speech turns -ia into -ii.', 'English', 'English (the language), England', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-7c5091e0c295');
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'englantia', 'englanti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive adds -a after puhua, to speak: englantia. Speech turns -ia into -ii.', 'English', 'English (the language), England')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'englantia', 'englanti',
      (select form_name_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii'),
      (select why_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii'),
      (select meaning_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii'),
      (select lemma_meaning_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii'),
      'partitive singular', 'The partitive adds -a after puhua, to speak: englantia. Speech turns -ia into -ii.', 'English', 'English (the language), England';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hieno', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hieno","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hieno[X]hieno[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+hieno(hieno)"}'::jsonb,
      'hienoa', 'hienoo',
      'partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-2cd8ef2f37d5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hienoa', 'hieno';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hienoa', 'hieno',
      (select form_name_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select why_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select lemma_meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      'partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluatko', 'haluuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-6189aefae9f0');
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
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"opettaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+opettaa(opettaa)"}'::jsonb,
      'opettaa', 'opettaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-85024a9e63e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettaa', 'opettaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettaa', 'opettaa',
      (select form_name_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select why_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-eca33913649c');
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
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('unelma', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"unelma","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]unelma[X]unelm[Sn][Ny]a[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+unelma(unelma)"}'::jsonb,
      'unelmani', 'unelma',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': unelmani. Speech says mun unelma and drops the ending.', 'my dream', 'dream', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-91d7ccbb0d97');
  end if;
  if not exists (select 1 from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'unelmani', 'unelma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': unelmani. Speech says mun unelma and drops the ending.', 'my dream', 'dream')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'unelmani', 'unelma',
      (select form_name_en from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma'),
      (select why_en from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma'),
      (select meaning_en from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma'),
      (select lemma_meaning_en from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': unelmani. Speech says mun unelma and drops the ending.', 'my dream', 'dream';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koulu', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural', '{"BASEFORM":"koulu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Ion][Xp]koulu[X]koulu[Sine][Nm]issa","NUMBER":"plural","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppp","WORDBASES":"+koulu(koulu)"}'::jsonb,
      'kouluissa', 'kouluis',
      'inessive plural', 'Adds -ssa for ''in'', with -i- for more than one: kouluissa. Speech says kouluis.', 'in schools', 'school', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-0779c5b29093');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kouluissa', 'koulu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive plural', 'Adds -ssa for ''in'', with -i- for more than one: kouluissa. Speech says kouluis.', 'in schools', 'school')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kouluissa', 'koulu',
      (select form_name_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis'),
      (select why_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis'),
      (select meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis'),
      (select lemma_meaning_en from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis'),
      'inessive plural', 'Adds -ssa for ''in'', with -i- for more than one: kouluissa. Speech says kouluis.', 'in schools', 'school';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvit[Tt][Ap][P4][Ef]aan","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitaan', 'tarvitaan',
      'present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-d64cc151ab47');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitaan', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitaan', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan'),
      'present tense, passive', 'Tarvita means to need. The ending -aan says it is needed without naming who needs it.', 'is needed', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaja', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"opettaja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Ln][Xj]ja[X][Sp][Nm]jia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+opetta(opettaa)+ja(+ja)"}'::jsonb,
      'opettajia', 'opettajii',
      'partitive plural', 'Plural ''some'' takes -ia: opettaja becomes opettajia. Speech says opettajii.', 'teachers', 'teacher', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-4b7f5cb183cc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettajia', 'opettaja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ia: opettaja becomes opettajia. Speech says opettajii.', 'teachers', 'teacher')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettajia', 'opettaja',
      (select form_name_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii'),
      (select why_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii'),
      (select meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii'),
      'partitive plural', 'Plural ''some'' takes -ia: opettaja becomes opettajia. Speech says opettajii.', 'teachers', 'teacher';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('toivottava', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active', '{"BASEFORM":"toivottava","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]toivottaa[X]toivotta[Ll][Rv]v[Xj]a[X]a[Ssti]sti","PARTICIPLE":"present_active","SIJAMUOTO":"kerrontosti","STRUCTURE":"=ppppppppppppp","WORDBASES":"+toivotta(toivottaa)+v+a(+a)"}'::jsonb,
      'toivottavasti', 'toivottavasti',
      'present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)', 'approved', now(), 'content/approvals/part-6.json#what-do-you-do/form-c0b75ccd3d5f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toivottavasti', 'toivottava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toivottavasti', 'toivottava',
      (select form_name_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select why_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select meaning_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      (select lemma_meaning_en from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'),
      'present active participle, adverb form (-sti)', 'Toivottavasti means hopefully. It comes from toivoa, to hope.', 'hopefully', 'to be hoped (toivottavasti, hopefully)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Jari', 'Mitä sä teet työks?',
    'Mitä sinä teet työksesi?', 'What do you do for work?',
    'what-do-you-do/1-puhe-8f6ac744437e.mp3', 'what-do-you-do/1-kirja-f5ecfaab7421.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'kirja', 4, 'työksesi', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'puhe', 4, 'työks', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'työksesi' and surface_puhe = 'työks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä oon asiakaspalvelus. Mut ammatiltani mä oon opettaja.',
    'Minä olen asiakaspalvelussa. Mutta ammatiltani minä olen opettaja.', 'I work in customer service. But I''m a teacher by profession.',
    'what-do-you-do/2-puhe-f2ce179211b5.mp3', 'what-do-you-do/2-kirja-44a7c0b3774d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'asiakaspalvelussa', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus')),
    (v_line_id, 'kirja', 4, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'ammatiltani', (select id from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani')),
    (v_line_id, 'kirja', 6, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 7, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 8, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'asiakaspalvelus', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus')),
    (v_line_id, 'puhe', 4, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'ammatiltani', (select id from public.forms where lemma = 'ammatti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'ammatiltani' and surface_puhe = 'ammatiltani')),
    (v_line_id, 'puhe', 6, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 7, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 8, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Jari', 'Mitä sä opetit?',
    'Mitä sinä opetit?', 'What did you teach?',
    'what-do-you-do/3-puhe-7b15486dc6ad.mp3', 'what-do-you-do/3-kirja-be62890b6c47.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'opetit', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'opetit', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetit' and surface_puhe = 'opetit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Matikkaa ja englantii.',
    'Matematiikkaa ja englantia.', 'Maths and English.',
    'what-do-you-do/4-puhe-c6d8206a714a.mp3', 'what-do-you-do/4-kirja-a3dc4b729557.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Matematiikkaa', (select id from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa')),
    (v_line_id, 'kirja', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'englantia', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii')),
    (v_line_id, 'puhe', 1, 'Matikkaa', (select id from public.forms where lemma = 'matematiikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'matematiikkaa' and surface_puhe = 'matikkaa')),
    (v_line_id, 'puhe', 2, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'englantii', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Jari', 'Hienoo! Haluuksä opettaa Suomessakin?',
    'Hienoa! Haluatko sinä opettaa Suomessakin?', 'Great! Do you want to teach in Finland too?',
    'what-do-you-do/5-puhe-455ea38b056b.mp3', 'what-do-you-do/5-kirja-7167176f317e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hienoa', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'kirja', 2, 'Haluatko', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'opettaa', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa')),
    (v_line_id, 'kirja', 5, 'Suomessakin', null),
    (v_line_id, 'puhe', 1, 'Hienoo', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'puhe', 2, 'Haluuk', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'opettaa', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa')),
    (v_line_id, 'puhe', 5, 'Suomessakin', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, se on mun unelma.',
    'Kyllä, se on minun unelmani.', 'Yes, that''s my dream.',
    'what-do-you-do/6-puhe-dd890b8a2313.mp3', 'what-do-you-do/6-kirja-55ff0bb55b3e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'unelmani', (select id from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'unelma', (select id from public.forms where lemma = 'unelma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'unelmani' and surface_puhe = 'unelma'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Jari', 'Kouluis tarvitaan opettajii.',
    'Kouluissa tarvitaan opettajia.', 'Schools need teachers.',
    'what-do-you-do/7-puhe-ee616cc94c64.mp3', 'what-do-you-do/7-kirja-a72aed382d8b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kouluissa', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis')),
    (v_line_id, 'kirja', 2, 'tarvitaan', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan')),
    (v_line_id, 'kirja', 3, 'opettajia', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii')),
    (v_line_id, 'puhe', 1, 'Kouluis', (select id from public.forms where lemma = 'koulu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=plural' and surface_kirja = 'kouluissa' and surface_puhe = 'kouluis')),
    (v_line_id, 'puhe', 2, 'tarvitaan', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitaan' and surface_puhe = 'tarvitaan')),
    (v_line_id, 'puhe', 3, 'opettajii', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'opettajia' and surface_puhe = 'opettajii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Toivottavasti!',
    'Toivottavasti!', 'I hope so!',
    'what-do-you-do/8-puhe-10de4ac2c645.mp3', 'what-do-you-do/8-kirja-7aefe64da48b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Toivottavasti', (select id from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti')),
    (v_line_id, 'puhe', 1, 'Toivottavasti', (select id from public.forms where lemma = 'toivottava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'toivottavasti' and surface_puhe = 'toivottavasti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#what-do-you-do/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
