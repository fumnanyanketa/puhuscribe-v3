-- Publishes the dialogue which-colour (unit shopping-for-clothes). Made by
-- scripts/generate/pipeline.py publish from content/drafts/which-colour. Do not edit by hand:
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
    where slug = 'which-colour' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'which-colour';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 12
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'shopping-for-clothes' and position = 12 and stop_number = 12;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'shopping-for-clothes';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'which-colour', 2,
    'Which colour?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'which-colour' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Which colour?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'which-colour';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kumpi', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kumpi","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]kumpi[X]kum[Sn][Ny]pi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kumpi(kumpi)"}'::jsonb,
      'kumpi', 'kumpi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'which (of two)', 'which (of two)', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-68ad253d7109');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kumpi', 'kumpi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'which (of two)', 'which (of two)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kumpi', 'kumpi',
      (select form_name_en from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi'),
      (select why_en from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi'),
      (select meaning_en from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi'),
      (select lemma_meaning_en from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'which (of two)', 'which (of two)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Ll][Xp]hyvä[X]pare[Sn][Ny][Cc]mpi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'parempi', 'parempi',
      'comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-f49daf34443c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'parempi', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'parempi', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      'comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sininen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"sininen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]sini[X]sin[Ll][Xj]inen[X]i[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+sin(sini)+inen(+inen)"}'::jsonb,
      'sininen', 'sininen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'blue', 'blue', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-4b3dadd0b2eb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sininen', 'sininen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'blue', 'blue')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sininen', 'sininen',
      (select form_name_en from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen'),
      (select why_en from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen'),
      (select meaning_en from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen'),
      (select lemma_meaning_en from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'blue', 'blue';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vai', 'CLASS=sidesana', '{"BASEFORM":"vai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vai[X]vai","STRUCTURE":"=ppp","WORDBASES":"+vai(vai)"}'::jsonb,
      'vai', 'vai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-83d8cf4795ac');
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
  if not exists (select 1 from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('musta', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"musta","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]musta[X]must[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+musta(musta)"}'::jsonb,
      'musta', 'musta',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'black', 'black', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-bb3ecae75b20');
  end if;
  if not exists (select 1 from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'musta', 'musta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'black', 'black')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'musta', 'musta',
      (select form_name_en from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta'),
      (select why_en from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta'),
      (select meaning_en from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta'),
      (select lemma_meaning_en from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'black', 'black';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopii', 'sopii',
      'present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-a47b56ad4b54');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-026c280fc0ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinulle', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinulle', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-26f45640039d');
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
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käytännöllinen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"käytännöllinen","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Ln][Xp]käytäntö[X]käytännö[Ll]lli[Xj]nen[X]se[Sn][Ny][Cc]mpi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppppppppppp","WORDBASES":"+käytännö(käytäntö)+lli+nen(+nen)"}'::jsonb,
      'käytännöllisempi', 'käytännöllisempi',
      'comparative, nominative singular', 'The comparative adds -mpi: käytännöllinen becomes käytännöllisempi.', 'more practical', 'practical', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-f633ef02feea');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käytännöllisempi', 'käytännöllinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, nominative singular', 'The comparative adds -mpi: käytännöllinen becomes käytännöllisempi.', 'more practical', 'practical')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käytännöllisempi', 'käytännöllinen',
      (select form_name_en from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi'),
      (select why_en from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi'),
      (select meaning_en from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi'),
      (select lemma_meaning_en from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi'),
      'comparative, nominative singular', 'The comparative adds -mpi: käytännöllinen becomes käytännöllisempi.', 'more practical', 'practical';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-b20bd263b5ae');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alennus', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"alennus","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]aleta[X]alenn[Ln][Xj]us[X]ukse[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppppppp","WORDBASES":"+alenn(aleta)+us(+us)"}'::jsonb,
      'alennuksessa', 'alessa',
      'inessive singular', 'Adds -ssa: alennus becomes alennuksessa. Speech uses the short word ale: alessa.', 'on sale', 'discount, sale', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-63cd55e57f3c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alennuksessa', 'alennus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa: alennus becomes alennuksessa. Speech uses the short word ale: alessa.', 'on sale', 'discount, sale')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alennuksessa', 'alennus',
      (select form_name_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa'),
      (select why_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa'),
      (select meaning_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa'),
      (select lemma_meaning_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa'),
      'inessive singular', 'Adds -ssa: alennus becomes alennuksessa. Speech uses the short word ale: alessa.', 'on sale', 'discount, sale';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksikymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksikymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksikymmentä', 'kakskyt',
      'nominative singular', 'Speech shortens kaksikymmentä to kakskyt. Books write kaksikymmentä.', 'twenty', 'twenty', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-dad43b4a552c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksikymmentä', 'kaksikymmentä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens kaksikymmentä to kakskyt. Books write kaksikymmentä.', 'twenty', 'twenty')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksikymmentä', 'kaksikymmentä',
      (select form_name_en from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt'),
      (select why_en from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt'),
      (select meaning_en from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt'),
      'nominative singular', 'Speech shortens kaksikymmentä to kakskyt. Books write kaksikymmentä.', 'twenty', 'twenty';
  end if;
  if not exists (select 1 from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('prosentti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"prosentti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]prosentti[X]prosentt[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppp","WORDBASES":"+prosentti(prosentti)"}'::jsonb,
      'prosenttia', 'prosenttii',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: prosentti becomes prosenttia.', 'percent', 'percent', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-b3426c2e4028');
  end if;
  if not exists (select 1 from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'prosenttia', 'prosentti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: prosentti becomes prosenttia.', 'percent', 'percent')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'prosenttia', 'prosentti',
      (select form_name_en from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii'),
      (select why_en from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii'),
      (select meaning_en from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii'),
      (select lemma_meaning_en from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: prosentti becomes prosenttia.', 'percent', 'percent';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alennus', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"alennus","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]aleta[X]alenn[Ln][Xj]us[X]u[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+alenn(aleta)+us(+us)"}'::jsonb,
      'alennusta', 'alennusta',
      'partitive singular', 'The partitive singular after a percent: kaksikymmentä prosenttia alennusta, ''20 percent off''.', 'off (discount)', 'discount, sale', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-960c9a563941');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alennusta', 'alennus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular after a percent: kaksikymmentä prosenttia alennusta, ''20 percent off''.', 'off (discount)', 'discount, sale')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alennusta', 'alennus',
      (select form_name_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta'),
      (select why_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta'),
      (select meaning_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta'),
      (select lemma_meaning_en from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta'),
      'partitive singular', 'The partitive singular after a percent: kaksikymmentä prosenttia alennusta, ''20 percent off''.', 'off (discount)', 'discount, sale';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"ottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ottaa[X]ota[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+ottaa(ottaa)"}'::jsonb,
      'ota', 'ota',
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-e8d98fab6fcd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ota', 'ottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ota', 'ottaa',
      (select form_name_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select why_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      (select lemma_meaning_en from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota'),
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: ottaa becomes ota, tt turning to t.', 'take', 'to take';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('molempi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"molempi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]molempi[X]mole[Sn][Nm][Cc]mmat","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+molempi(molempi)"}'::jsonb,
      'molemmat', 'molemmat',
      'nominative plural', 'The nominative plural of molempi: molemmat, ''both''. People say it the same way.', 'both', 'both', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-0e6e9da4f3a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'molemmat', 'molempi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'The nominative plural of molempi: molemmat, ''both''. People say it the same way.', 'both', 'both')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'molemmat', 'molempi',
      (select form_name_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat'),
      (select why_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat'),
      (select meaning_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat'),
      (select lemma_meaning_en from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat'),
      'nominative plural', 'The nominative plural of molempi: molemmat, ''both''. People say it the same way.', 'both', 'both';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"olla","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'ole', 'oo',
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-0fcdf4079f8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ole', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ole', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-4f1448504014');
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niin', 'niin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niin', 'niin',
      (select form_name_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select why_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select lemma_meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('raha', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"raha","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]raha[X]rah[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+raha(raha)"}'::jsonb,
      'rahaa', 'rahaa',
      'partitive singular', 'After ''ei ole'' the noun takes the partitive singular: raha becomes rahaa.', 'money', 'money', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-a630c3e87c89');
  end if;
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rahaa', 'raha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After ''ei ole'' the noun takes the partitive singular: raha becomes rahaa.', 'money', 'money')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rahaa', 'raha',
      (select form_name_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa'),
      (select why_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa'),
      (select meaning_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa'),
      (select lemma_meaning_en from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa'),
      'partitive singular', 'After ''ei ole'' the noun takes the partitive singular: raha becomes rahaa.', 'money', 'money';
  end if;
  if not exists (select 1 from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('no', 'CLASS=seikkasana', '{"BASEFORM":"no","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]no[X]no","STRUCTURE":"=pp","WORDBASES":"+no(no)"}'::jsonb,
      'no', 'no',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-2.json#which-colour/form-544b740d3858');
  end if;
  if not exists (select 1 from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'no', 'no';
  end if;
  if not exists (select 1 from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'no', 'no',
      (select form_name_en from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no'),
      (select why_en from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no'),
      (select meaning_en from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no'),
      (select lemma_meaning_en from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Kumpi on parempi, sininen vai musta?',
    'Kumpi on parempi, sininen vai musta?', 'Which is better, the blue or the black?',
    'which-colour/1-puhe-a9cd1685eb9c.mp3', 'which-colour/1-kirja-4154001aee39.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kumpi', (select id from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'parempi', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi')),
    (v_line_id, 'kirja', 4, 'sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen')),
    (v_line_id, 'kirja', 5, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'kirja', 6, 'musta', (select id from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta')),
    (v_line_id, 'puhe', 1, 'Kumpi', (select id from public.forms where lemma = 'kumpi' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kumpi' and surface_puhe = 'kumpi')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'parempi', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi')),
    (v_line_id, 'puhe', 4, 'sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen')),
    (v_line_id, 'puhe', 5, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'puhe', 6, 'musta', (select id from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Aino', 'Sininen! Se sopii sulle tosi hyvin.',
    'Sininen! Se sopii sinulle todella hyvin.', 'The blue! It really suits you.',
    'which-colour/2-puhe-0fe9bfaf9400.mp3', 'which-colour/2-kirja-7d79e9b3d7d6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen')),
    (v_line_id, 'kirja', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'kirja', 4, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 5, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'puhe', 4, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 5, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Mut musta on käytännöllisempi.',
    'Mutta musta on käytännöllisempi.', 'But the black is more practical.',
    'which-colour/3-puhe-3d586a4b93f5.mp3', 'which-colour/3-kirja-650911d203a4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 2, 'musta', (select id from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'käytännöllisempi', (select id from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi')),
    (v_line_id, 'puhe', 1, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 2, 'musta', (select id from public.forms where lemma = 'musta' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'musta' and surface_puhe = 'musta')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'käytännöllisempi', (select id from public.forms where lemma = 'käytännöllinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'käytännöllisempi' and surface_puhe = 'käytännöllisempi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Aino', 'Totta. Onks se alessa?',
    'Totta. Onko se alennuksessa?', 'True. Is it on sale?',
    'which-colour/4-puhe-b5d9135af432.mp3', 'which-colour/4-kirja-cbac432cd441.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'alennuksessa', (select id from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'alessa', (select id from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'alennuksessa' and surface_puhe = 'alessa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Joo, kakskyt prosenttii alennusta.',
    'Kyllä, kaksikymmentä prosenttia alennusta.', 'Yes, twenty percent off.',
    'which-colour/5-puhe-b155f045856e.mp3', 'which-colour/5-kirja-8e9163b1159a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'kaksikymmentä', (select id from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt')),
    (v_line_id, 'kirja', 3, 'prosenttia', (select id from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii')),
    (v_line_id, 'kirja', 4, 'alennusta', (select id from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'kakskyt', (select id from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt')),
    (v_line_id, 'puhe', 3, 'prosenttii', (select id from public.forms where lemma = 'prosentti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'prosenttia' and surface_puhe = 'prosenttii')),
    (v_line_id, 'puhe', 4, 'alennusta', (select id from public.forms where lemma = 'alennus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'alennusta' and surface_puhe = 'alennusta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Aino', 'Ota sit molemmat!',
    'Ota sitten molemmat!', 'Then take both!',
    'which-colour/6-puhe-9b7fd4d52d01.mp3', 'which-colour/6-kirja-691baaca1af6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'kirja', 2, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 3, 'molemmat', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat')),
    (v_line_id, 'puhe', 1, 'Ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'puhe', 2, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 3, 'molemmat', (select id from public.forms where lemma = 'molempi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'molemmat' and surface_puhe = 'molemmat'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Mul ei oo niin paljon rahaa.',
    'Minulla ei ole niin paljon rahaa.', 'I don''t have that much money.',
    'which-colour/7-puhe-2ca1ce48f322.mp3', 'which-colour/7-kirja-c0a31272c2e9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'kirja', 4, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 5, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 6, 'rahaa', (select id from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa')),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'oo', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'puhe', 4, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 5, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 6, 'rahaa', (select id from public.forms where lemma = 'raha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'rahaa' and surface_puhe = 'rahaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Aino', 'No, ota sininen.',
    'No, ota sininen.', 'Well, take the blue one.',
    'which-colour/8-puhe-b1ceea8c2c20.mp3', 'which-colour/8-kirja-ab74e350dc30.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'No', (select id from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no')),
    (v_line_id, 'kirja', 2, 'ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'kirja', 3, 'sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen')),
    (v_line_id, 'puhe', 1, 'No', (select id from public.forms where lemma = 'no' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'no' and surface_puhe = 'no')),
    (v_line_id, 'puhe', 2, 'ota', (select id from public.forms where lemma = 'ottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'ota' and surface_puhe = 'ota')),
    (v_line_id, 'puhe', 3, 'sininen', (select id from public.forms where lemma = 'sininen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'sininen' and surface_puhe = 'sininen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#which-colour/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
