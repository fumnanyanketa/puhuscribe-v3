-- Publishes the dialogue following-the-recipe (unit cooking-at-home). Made by
-- scripts/generate/pipeline.py publish from content/drafts/following-the-recipe. Do not edit by hand:
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
    where slug = 'following-the-recipe' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'following-the-recipe';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 23
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'cooking-at-home' and position = 23 and stop_number = 23;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'cooking-at-home';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'following-the-recipe', 2,
    'Following the recipe')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'following-the-recipe' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Following the recipe';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'following-the-recipe';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensin', 'CLASS=seikkasana', '{"BASEFORM":"ensin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensin[X]ensin","STRUCTURE":"=ppppp","WORDBASES":"+ensin(ensin)"}'::jsonb,
      'ensin', 'eka',
      'adverb', 'Speech often uses the short word eka. Books write ensin.', 'first', 'first', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-ebb825750ac1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensin', 'ensin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often uses the short word eka. Books write ensin.', 'first', 'first')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensin', 'ensin',
      (select form_name_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka'),
      (select why_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka'),
      (select meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka'),
      (select lemma_meaning_en from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka'),
      'adverb', 'Speech often uses the short word eka. Books write ensin.', 'first', 'first';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuoria', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kuoria","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuoria[X]kuori[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+kuoria(kuoria)"}'::jsonb,
      'kuori', 'kuori',
      'imperative present tense, 2nd person singular', 'Kuoria, to peel. To tell one person to do it, drop the ending: kuori.', 'peel', 'to peel', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-9c9de5d4e8ea');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuori', 'kuoria';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Kuoria, to peel. To tell one person to do it, drop the ending: kuori.', 'peel', 'to peel')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuori', 'kuoria',
      (select form_name_en from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori'),
      (select why_en from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori'),
      (select meaning_en from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori'),
      (select lemma_meaning_en from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori'),
      'imperative present tense, 2nd person singular', 'Kuoria, to peel. To tell one person to do it, drop the ending: kuori.', 'peel', 'to peel';
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('peruna', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"peruna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]peruna[X]peruna[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+peruna(peruna)"}'::jsonb,
      'perunat', 'perunat',
      'nominative plural', 'Adds -t for more than one: peruna becomes perunat.', 'the potatoes', 'potato', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-d9fc599d3bfb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perunat', 'peruna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: peruna becomes perunat.', 'the potatoes', 'potato')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perunat', 'peruna',
      (select form_name_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat'),
      (select why_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat'),
      (select meaning_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat'),
      (select lemma_meaning_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat'),
      'nominative plural', 'Adds -t for more than one: peruna becomes perunat.', 'the potatoes', 'potato';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('porkkana', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"porkkana","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]porkkana[X]porkkana[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+porkkana(porkkana)"}'::jsonb,
      'porkkanat', 'porkkanat',
      'nominative plural', 'Adds -t for more than one: porkkana becomes porkkanat.', 'the carrots', 'carrot', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-c673421d9e2a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'porkkanat', 'porkkana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Adds -t for more than one: porkkana becomes porkkanat.', 'the carrots', 'carrot')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'porkkanat', 'porkkana',
      (select form_name_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat'),
      (select why_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat'),
      (select meaning_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat'),
      (select lemma_meaning_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat'),
      'nominative plural', 'Adds -t for more than one: porkkana becomes porkkanat.', 'the carrots', 'carrot';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-1df5ffb944a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'selvä', 'selvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'selvä', 'selvä',
      (select form_name_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select why_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      (select lemma_meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei'),
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('leikata', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"leikata","CLASS":"teonsana","MANUAL":"true","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","TENSE":"present_simple"}'::jsonb,
      'leikkaa', 'leikkaa',
      'imperative present tense, 2nd person singular', 'Leikata, to cut. To tell one person to do it: leikkaa. The k doubles in this form.', 'cut', 'to cut', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-c6e5d9835929');
  end if;
  if not exists (select 1 from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'leikkaa', 'leikata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Leikata, to cut. To tell one person to do it: leikkaa. The k doubles in this form.', 'cut', 'to cut')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'leikkaa', 'leikata',
      (select form_name_en from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa'),
      (select why_en from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa'),
      (select meaning_en from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa'),
      (select lemma_meaning_en from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa'),
      'imperative present tense, 2nd person singular', 'Leikata, to cut. To tell one person to do it: leikkaa. The k doubles in this form.', 'cut', 'to cut';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sn][Nm]e","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+ne(ne)"}'::jsonb,
      'ne', 'ne',
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-18803b094966');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ne', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ne', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pieni', 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"pieni","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]pieni[X]pien[Str][Nm]iksi","NUMBER":"plural","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+pieni(pieni)"}'::jsonb,
      'pieniksi', 'pieniks',
      'translative plural', 'Adds -ksi for ''into'': pieni becomes pieniksi, ''into small (pieces)''. Speech drops the last i.', 'small', 'small, little', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-70fd4e5cba31');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pieniksi', 'pieni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative plural', 'Adds -ksi for ''into'': pieni becomes pieniksi, ''into small (pieces)''. Speech drops the last i.', 'small', 'small, little')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pieniksi', 'pieni',
      (select form_name_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks'),
      (select why_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks'),
      (select meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks'),
      (select lemma_meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks'),
      'translative plural', 'Adds -ksi for ''into'': pieni becomes pieniksi, ''into small (pieces)''. Speech drops the last i.', 'small', 'small, little';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pala', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural', '{"BASEFORM":"pala","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pala[X]palo[Str][Nm]iksi","NUMBER":"plural","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+pala(pala)"}'::jsonb,
      'paloiksi', 'paloiks',
      'translative plural', 'Pala, piece. Many pieces plus -ksi for ''into'': paloiksi. Speech drops the i: paloiks.', 'into pieces', 'piece', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-1a08e56b5545');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paloiksi', 'pala';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative plural', 'Pala, piece. Many pieces plus -ksi for ''into'': paloiksi. Speech drops the i: paloiks.', 'into pieces', 'piece')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paloiksi', 'pala',
      (select form_name_en from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks'),
      (select why_en from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks'),
      (select meaning_en from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks'),
      (select lemma_meaning_en from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks'),
      'translative plural', 'Pala, piece. Many pieces plus -ksi for ''into'': paloiksi. Speech drops the i: paloiks.', 'into pieces', 'piece';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('näin', 'CLASS=seikkasana', '{"BASEFORM":"näin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]näin[X]näin","STRUCTURE":"=pppp","WORDBASES":"+näin(näin)"}'::jsonb,
      'näin', 'näin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-263e1e1ab533');
  end if;
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näin', 'näin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näin', 'näin',
      (select form_name_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select why_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select meaning_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      (select lemma_meaning_en from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'like this, this way', 'like this, this way';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"laittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laittaa[X]laita[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+laittaa(laittaa)"}'::jsonb,
      'laita', 'laita',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-6310bab3540e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laita', 'laittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laita', 'laittaa',
      (select form_name_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select why_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select lemma_meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      'imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kattila', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"kattila","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kattila[X]kattilaa[Sill][Ny]n","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppppp","WORDBASES":"+kattila(kattila)"}'::jsonb,
      'kattilaan', 'kattilaan',
      'illative singular', 'Adds -an for ''into'': kattila becomes kattilaan.', 'in the pot', 'pot, saucepan', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-8da50554a5b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kattilaan', 'kattila';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -an for ''into'': kattila becomes kattilaan.', 'in the pot', 'pot, saucepan')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kattilaan', 'kattila',
      (select form_name_en from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan'),
      (select why_en from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan'),
      (select meaning_en from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan'),
      (select lemma_meaning_en from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan'),
      'illative singular', 'Adds -an for ''into'': kattila becomes kattilaan.', 'in the pot', 'pot, saucepan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lisätä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"lisätä","CLASS":"teonsana","MANUAL":"true","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","TENSE":"present_simple"}'::jsonb,
      'lisää', 'lisää',
      'imperative present tense, 2nd person singular', 'Lisätä, to add. To tell one person to do it: lisää.', 'add', 'to add', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-0f2b13a77e10');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lisää', 'lisätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Lisätä, to add. To tell one person to do it: lisää.', 'add', 'to add')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lisää', 'lisätä',
      (select form_name_en from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select why_en from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select meaning_en from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select lemma_meaning_en from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      'imperative present tense, 2nd person singular', 'Lisätä, to add. To tell one person to do it: lisää.', 'add', 'to add';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sp][Ny]ttä","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vettä', 'vettä',
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-18de4322e3a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vettä', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vettä', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('litra', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"litra","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]litra[X]litr[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+litra(litra)"}'::jsonb,
      'litra', 'litra',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'litre', 'litre', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-bf934ebbc276');
  end if;
  if not exists (select 1 from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'litra', 'litra';
  end if;
  if not exists (select 1 from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'litre', 'litre')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'litra', 'litra',
      (select form_name_en from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra'),
      (select why_en from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra'),
      (select meaning_en from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra'),
      (select lemma_meaning_en from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'litre', 'litre';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keittää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"keittää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]keittää[X]keitä[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+keittää(keittää)"}'::jsonb,
      'keitä', 'keitä',
      'imperative present tense, 2nd person singular', 'Keittää, to boil. To tell one person to do it, drop the ending: keitä. The tt becomes t.', 'boil', 'to boil, to cook', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-d426e7a9b401');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keitä', 'keittää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Keittää, to boil. To tell one person to do it, drop the ending: keitä. The tt becomes t.', 'boil', 'to boil, to cook')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keitä', 'keittää',
      (select form_name_en from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä'),
      (select why_en from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä'),
      (select meaning_en from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä'),
      (select lemma_meaning_en from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä'),
      'imperative present tense, 2nd person singular', 'Keittää, to boil. To tell one person to do it, drop the ending: keitä. The tt becomes t.', 'boil', 'to boil, to cook';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksikymmentä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksikymmentä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]kymmentä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksikymmentä', 'kakskyt',
      'nominative singular', 'Speech shortens kaksikymmentä to kakskyt. Books write kaksikymmentä.', 'twenty', 'twenty', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-dad43b4a552c');
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
  if not exists (select 1 from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minuutti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"minuutti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]minuutti[X]minuutt[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+minuutti(minuutti)"}'::jsonb,
      'minuuttia', 'minuuttii',
      'partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-2ba98cc25249');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minuuttia', 'minuutti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minuuttia', 'minuutti',
      (select form_name_en from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'),
      (select why_en from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'),
      (select meaning_en from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'),
      (select lemma_meaning_en from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'),
      'partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lohi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lohi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lohi[X]loh[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+lohi(lohi)"}'::jsonb,
      'lohi', 'lohi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'salmon', 'salmon', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-5854f879507c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lohi', 'lohi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'salmon', 'salmon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lohi', 'lohi',
      (select form_name_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi'),
      (select why_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi'),
      (select meaning_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi'),
      (select lemma_meaning_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'salmon', 'salmon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ap][P3][Ny][Ef]ee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulee', 'tulee',
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-390b2cd693bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulee', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulee', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viimeinen', 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"viimeinen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]viimeinen[X]viimei[Ses][Ny]senä","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+viimeinen(viimeinen)"}'::jsonb,
      'viimeisenä', 'vikana',
      'essive singular', 'Adds -nä to say how or in what role: viimeinen becomes viimeisenä. Speech uses vika: vikana.', 'last', 'last', 'approved', now(), 'content/approvals/part-4.json#following-the-recipe/form-3b9211c753f8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viimeisenä', 'viimeinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Adds -nä to say how or in what role: viimeinen becomes viimeisenä. Speech uses vika: vikana.', 'last', 'last')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viimeisenä', 'viimeinen',
      (select form_name_en from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana'),
      (select why_en from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana'),
      (select meaning_en from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana'),
      (select lemma_meaning_en from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana'),
      'essive singular', 'Adds -nä to say how or in what role: viimeinen becomes viimeisenä. Speech uses vika: vikana.', 'last', 'last';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Eka kuori perunat ja porkkanat.',
    'Ensin kuori perunat ja porkkanat.', 'First peel the potatoes and carrots.',
    'following-the-recipe/1-puhe-0384b720e6aa.mp3', 'following-the-recipe/1-kirja-bf8134f30ffe.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ensin', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka')),
    (v_line_id, 'kirja', 2, 'kuori', (select id from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori')),
    (v_line_id, 'kirja', 3, 'perunat', (select id from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'porkkanat', (select id from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat')),
    (v_line_id, 'puhe', 1, 'Eka', (select id from public.forms where lemma = 'ensin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensin' and surface_puhe = 'eka')),
    (v_line_id, 'puhe', 2, 'kuori', (select id from public.forms where lemma = 'kuoria' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kuori' and surface_puhe = 'kuori')),
    (v_line_id, 'puhe', 3, 'perunat', (select id from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'perunat' and surface_puhe = 'perunat')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'porkkanat', (select id from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'porkkanat' and surface_puhe = 'porkkanat'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Okei. Ja sit?',
    'Selvä. Ja sitten?', 'OK. And then?',
    'following-the-recipe/2-puhe-a43c2ccc696a.mp3', 'following-the-recipe/2-kirja-56fea480c356.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Leikkaa ne pieniks paloiks.',
    'Leikkaa ne pieniksi paloiksi.', 'Cut them into small pieces.',
    'following-the-recipe/3-puhe-3e449fb9e413.mp3', 'following-the-recipe/3-kirja-ccebfd382a3b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Leikkaa', (select id from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa')),
    (v_line_id, 'kirja', 2, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 3, 'pieniksi', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks')),
    (v_line_id, 'kirja', 4, 'paloiksi', (select id from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks')),
    (v_line_id, 'puhe', 1, 'Leikkaa', (select id from public.forms where lemma = 'leikata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'leikkaa' and surface_puhe = 'leikkaa')),
    (v_line_id, 'puhe', 2, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 3, 'pieniks', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=tulento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'pieniksi' and surface_puhe = 'pieniks')),
    (v_line_id, 'puhe', 4, 'paloiks', (select id from public.forms where lemma = 'pala' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=plural' and surface_kirja = 'paloiksi' and surface_puhe = 'paloiks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Näin?',
    'Näin?', 'Like this?',
    'following-the-recipe/4-puhe-3694c87813e4.mp3', 'following-the-recipe/4-kirja-c4395d0fdc1a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Näin', (select id from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin')),
    (v_line_id, 'puhe', 1, 'Näin', (select id from public.forms where lemma = 'näin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'näin' and surface_puhe = 'näin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Joo, hyvä. Laita ne kattilaan ja lisää vettä.',
    'Kyllä, hyvä. Laita ne kattilaan ja lisää vettä.', 'Yes, good. Put them in the pot and add water.',
    'following-the-recipe/5-puhe-dbdf23462981.mp3', 'following-the-recipe/5-kirja-0de43d6d7cae.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 3, 'Laita', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita')),
    (v_line_id, 'kirja', 4, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 5, 'kattilaan', (select id from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan')),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'lisää', (select id from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'kirja', 8, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 3, 'Laita', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita')),
    (v_line_id, 'puhe', 4, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 5, 'kattilaan', (select id from public.forms where lemma = 'kattila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kattilaan' and surface_puhe = 'kattilaan')),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'lisää', (select id from public.forms where lemma = 'lisätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'puhe', 8, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Kuinka paljon vettä?',
    'Kuinka paljon vettä?', 'How much water?',
    'following-the-recipe/6-puhe-d09578f8650c.mp3', 'following-the-recipe/6-kirja-1bb22abef53e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 3, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 3, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Litra. Keitä kakskyt minuuttii.',
    'Litra. Keitä kaksikymmentä minuuttia.', 'A litre. Boil for twenty minutes.',
    'following-the-recipe/7-puhe-69e0c88d98b2.mp3', 'following-the-recipe/7-kirja-ca3adc5c404f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Litra', (select id from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra')),
    (v_line_id, 'kirja', 2, 'Keitä', (select id from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä')),
    (v_line_id, 'kirja', 3, 'kaksikymmentä', (select id from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt')),
    (v_line_id, 'kirja', 4, 'minuuttia', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'puhe', 1, 'Litra', (select id from public.forms where lemma = 'litra' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'litra' and surface_puhe = 'litra')),
    (v_line_id, 'puhe', 2, 'Keitä', (select id from public.forms where lemma = 'keittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'keitä' and surface_puhe = 'keitä')),
    (v_line_id, 'puhe', 3, 'kakskyt', (select id from public.forms where lemma = 'kaksikymmentä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksikymmentä' and surface_puhe = 'kakskyt')),
    (v_line_id, 'puhe', 4, 'minuuttii', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Ja lohi tulee vikana?',
    'Ja lohi tulee viimeisenä?', 'And the salmon goes in last?',
    'following-the-recipe/8-puhe-1e5d7af2f423.mp3', 'following-the-recipe/8-kirja-e6e82c989724.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'lohi', (select id from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi')),
    (v_line_id, 'kirja', 3, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee')),
    (v_line_id, 'kirja', 4, 'viimeisenä', (select id from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'lohi', (select id from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lohi' and surface_puhe = 'lohi')),
    (v_line_id, 'puhe', 3, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee')),
    (v_line_id, 'puhe', 4, 'vikana', (select id from public.forms where lemma = 'viimeinen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=olento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'viimeisenä' and surface_puhe = 'vikana'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#following-the-recipe/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
