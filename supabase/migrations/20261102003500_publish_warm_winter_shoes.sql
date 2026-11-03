-- Publishes the dialogue warm-winter-shoes (unit shopping-for-clothes). Made by
-- scripts/generate/pipeline.py publish from content/drafts/warm-winter-shoes. Do not edit by hand:
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
    where slug = 'warm-winter-shoes' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'warm-winter-shoes';
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
  values (v_unit_id, 'warm-winter-shoes', 3,
    'Warm winter shoes')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'warm-winter-shoes' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Warm winter shoes';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'warm-winter-shoes';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-91a5cf1932b7');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('etsiä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"etsiä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]etsiä[X]etsi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+etsiä(etsiä)"}'::jsonb,
      'etsin', 'etin',
      'present tense, 1st person singular', 'Adds -n for ''I'': etsiä becomes etsin. Speech drops the s: etin.', 'I''m looking for', 'to look for, to search', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-1ccccd57d025');
  end if;
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'etsin', 'etsiä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': etsiä becomes etsin. Speech drops the s: etin.', 'I''m looking for', 'to look for, to search')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'etsin', 'etsiä',
      (select form_name_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin'),
      (select why_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin'),
      (select meaning_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin'),
      (select lemma_meaning_en from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin'),
      'present tense, 1st person singular', 'Adds -n for ''I'': etsiä becomes etsin. Speech drops the s: etin.', 'I''m looking for', 'to look for, to search';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talvikenkä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"talvikenkä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]talvi[X]talv[Sn][Ny]i[Bh][Bc][Ln][Xp]kenkä[X]kenk[Sp][Nm]iä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+talvi(talvi)+kenkä(kenkä)"}'::jsonb,
      'talvikenkiä', 'talvikenkii',
      'partitive plural', 'The partitive plural after etsiä ''look for'': talvikenkä becomes talvikenkiä. Speech says talvikenkii.', 'winter shoes', 'winter shoe', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-d8863d8159b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talvikenkiä', 'talvikenkä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive plural after etsiä ''look for'': talvikenkä becomes talvikenkiä. Speech says talvikenkii.', 'winter shoes', 'winter shoe')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talvikenkiä', 'talvikenkä',
      (select form_name_en from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii'),
      (select why_en from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii'),
      (select meaning_en from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii'),
      (select lemma_meaning_en from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii'),
      'partitive plural', 'The partitive plural after etsiä ''look for'': talvikenkä becomes talvikenkiä. Speech says talvikenkii.', 'winter shoes', 'winter shoe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kengännumero', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kengännumero","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kenkä[X]keng[Sg][Ny]än[Bh][Bc][Ln][Xp]numero[X]numero[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=pppppp","WORDBASES":"+kengän(kenkä)+numero(numero)"}'::jsonb,
      'kengännumero', 'kengännumero',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'shoe size', 'shoe size', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-4d81b442d3d8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kengännumero', 'kengännumero';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'shoe size', 'shoe size')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kengännumero', 'kengännumero',
      (select form_name_en from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero'),
      (select why_en from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero'),
      (select meaning_en from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero'),
      (select lemma_meaning_en from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'shoe size', 'shoe size';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolmekymmentäseitsemän', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolmekymmentäseitsemän","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e[Bc]kymmentä[Bc][Lu][Xp]seitsemän[X]seitsem[Sn][Ny]än","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp=ppppppppp","WORDBASES":"+kolmekymmentä(kolme)+seitsemän(seitsemän)"}'::jsonb,
      'kolmekymmentäseitsemän', 'kolkytseittemän',
      'nominative singular', 'Speech shortens it to kolkytseittemän. Books write kolmekymmentäseitsemän.', 'thirty-seven', 'thirty-seven', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-bcc308f66e6c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolmekymmentäseitsemän', 'kolmekymmentäseitsemän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens it to kolkytseittemän. Books write kolmekymmentäseitsemän.', 'thirty-seven', 'thirty-seven')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolmekymmentäseitsemän', 'kolmekymmentäseitsemän',
      (select form_name_en from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän'),
      (select why_en from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän'),
      (select meaning_en from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän'),
      (select lemma_meaning_en from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän'),
      'nominative singular', 'Speech shortens it to kolkytseittemän. Books write kolmekymmentäseitsemän.', 'thirty-seven', 'thirty-seven';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"nämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]nämä[X]nä[Sn][Nm]mä","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+nämä(nämä)"}'::jsonb,
      'nämä', 'nää',
      'nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-3071ed4181f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nämä', 'nämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nämä', 'nämä',
      (select form_name_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select why_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select meaning_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      (select lemma_meaning_en from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää'),
      'nominative plural', 'Speech shortens nämä to nää. Books write nämä.', 'these', 'these';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-4ab061b662f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ovat', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ovat', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lämmin', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"lämmin","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]lämmin[X]läm[Sn][Nm]pimät","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+lämmin(lämmin)"}'::jsonb,
      'lämpimät', 'lämpimät',
      'nominative plural', 'The nominative plural adds -t: lämmin becomes lämpimät, the mm turning to mp.', 'warm', 'warm', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-5ae2be4111d7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lämpimät', 'lämmin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'The nominative plural adds -t: lämmin becomes lämpimät, the mm turning to mp.', 'warm', 'warm')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lämpimät', 'lämmin',
      (select form_name_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät'),
      (select why_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät'),
      (select meaning_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät'),
      (select lemma_meaning_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät'),
      'nominative plural', 'The nominative plural adds -t: lämmin becomes lämpimät, the mm turning to mp.', 'warm', 'warm';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vedenpitävä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active', '{"BASEFORM":"vedenpitävä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sg][Ny]den[Bh][Bc][Lt][Ira][Xp]pitää[X]pitä[Ll][Rv]v[Xj]ä[X][Sn][Nm]ät","NUMBER":"plural","PARTICIPLE":"present_active","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+veden(vesi)+pitä(pitää)+v+ä(+ä)"}'::jsonb,
      'vedenpitävät', 'vedenpitävät',
      'present active participle, nominative plural', 'Adds -t for more than one: vedenpitävä becomes vedenpitävät.', 'waterproof', 'waterproof', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-45161388732f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vedenpitävät', 'vedenpitävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present active participle, nominative plural', 'Adds -t for more than one: vedenpitävä becomes vedenpitävät.', 'waterproof', 'waterproof')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vedenpitävät', 'vedenpitävä',
      (select form_name_en from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät'),
      (select why_en from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät'),
      (select meaning_en from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät'),
      (select lemma_meaning_en from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät'),
      'present active participle, nominative plural', 'Adds -t for more than one: vedenpitävä becomes vedenpitävät.', 'waterproof', 'waterproof';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sn][Nm]e","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+ne(ne)"}'::jsonb,
      'ne', 'ne',
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-18803b094966');
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
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaunis', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"kaunis","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kaunis[X]kaunii[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+kaunis(kaunis)"}'::jsonb,
      'kauniit', 'kauniit',
      'nominative plural', 'The nominative plural adds -t: kaunis becomes kauniit, the s turning to i.', 'nice (beautiful)', 'beautiful', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-e1fc4c9ba1ff');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauniit', 'kaunis';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'The nominative plural adds -t: kaunis becomes kauniit, the s turning to i.', 'nice (beautiful)', 'beautiful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauniit', 'kaunis',
      (select form_name_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit'),
      (select why_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit'),
      (select meaning_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit'),
      (select lemma_meaning_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit'),
      'nominative plural', 'The nominative plural adds -t: kaunis becomes kauniit, the s turning to i.', 'nice (beautiful)', 'beautiful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kallis', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"kallis","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kallis[X]kallii[Sn][Nm]t","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+kallis(kallis)"}'::jsonb,
      'kalliit', 'kalliit',
      'nominative plural', 'The nominative plural adds -t: kallis becomes kalliit, the s turning to i.', 'expensive', 'expensive', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-f1f6a6b38e8b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kalliit', 'kallis';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'The nominative plural adds -t: kallis becomes kalliit, the s turning to i.', 'expensive', 'expensive')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kalliit', 'kallis',
      (select form_name_en from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit'),
      (select why_en from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit'),
      (select meaning_en from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit'),
      (select lemma_meaning_en from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit'),
      'nominative plural', 'The nominative plural adds -t: kallis becomes kalliit, the s turning to i.', 'expensive', 'expensive';
  end if;
  if not exists (select 1 from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('halpa', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative', '{"BASEFORM":"halpa","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Ll][Xp]halpa[X]halve[Sn][Nm][Cc]mmat","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+halpa(halpa)"}'::jsonb,
      'halvemmat', 'halvemmat',
      'comparative, nominative plural', 'The comparative of halpa is halvempi; -t for more than one: halvemmat.', 'cheaper', 'cheap', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-a2a864dc0ee6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'halvemmat', 'halpa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, nominative plural', 'The comparative of halpa is halvempi; -t for more than one: halvemmat.', 'cheaper', 'cheap')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'halvemmat', 'halpa',
      (select form_name_en from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat'),
      (select why_en from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat'),
      (select meaning_en from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat'),
      (select lemma_meaning_en from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat'),
      'comparative, nominative plural', 'The comparative of halpa is halvempi; -t for more than one: halvemmat.', 'cheaper', 'cheap';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-fe354724e29a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myös', 'myös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myös', 'myös',
      (select form_name_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select why_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select lemma_meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Nm]ät","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvät', 'hyvät',
      'nominative plural', 'The nominative plural adds -t: hyvä becomes hyvät.', 'good', 'good', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-5f45c877e6ab');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvät', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'The nominative plural adds -t: hyvä becomes hyvät.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvät', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät'),
      'nominative plural', 'The nominative plural adds -t: hyvä becomes hyvät.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voinko', 'voinks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-cbf76e213246');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voinko', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voinko', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kokeilla', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"kokeilla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kokeilla[X]kokeill[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppppp","WORDBASES":"+kokeilla(kokeilla)"}'::jsonb,
      'kokeilla', 'kokeilla',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to try, to try on', 'to try, to try on', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-5548de673a20');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kokeilla', 'kokeilla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to try, to try on', 'to try, to try on')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kokeilla', 'kokeilla',
      (select form_name_en from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla'),
      (select why_en from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla'),
      (select meaning_en from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla'),
      (select lemma_meaning_en from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to try, to try on', 'to try, to try on';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sp][Nm]iitä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+ne(ne)"}'::jsonb,
      'niitä', 'niitä',
      'partitive plural', 'The partitive plural of ne ''they'': niitä, used after kokeilla ''to try''.', 'them', 'they, those', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-bcee7be7d1e5');
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
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-b20bd263b5ae');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-b1285c45ffe6');
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
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('istua', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"istua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]istua[X]istu[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+istua(istua)"}'::jsonb,
      'istu', 'istu',
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: istua becomes istu.', 'sit', 'to sit', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-22cda8722ce6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'istu', 'istua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: istua becomes istu.', 'sit', 'to sit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'istu', 'istua',
      (select form_name_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu'),
      (select why_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu'),
      (select meaning_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu'),
      (select lemma_meaning_en from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu'),
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: istua becomes istu.', 'sit', 'to sit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sill][Ny]hän","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tähän', 'tähän',
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this', 'approved', now(), 'content/approvals/part-2.json#warm-winter-shoes/form-3cb39a24ba50');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tähän', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tähän', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Anteeks, mä etin talvikenkii.',
    'Anteeksi, minä etsin talvikenkiä.', 'Excuse me, I''m looking for winter shoes.',
    'warm-winter-shoes/1-puhe-1f4fb725bed1.mp3', 'warm-winter-shoes/1-kirja-11d1f0f67e56.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'etsin', (select id from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin')),
    (v_line_id, 'kirja', 4, 'talvikenkiä', (select id from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'etin', (select id from public.forms where lemma = 'etsiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'etsin' and surface_puhe = 'etin')),
    (v_line_id, 'puhe', 4, 'talvikenkii', (select id from public.forms where lemma = 'talvikenkä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'talvikenkiä' and surface_puhe = 'talvikenkii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Petri', 'Okei. Mikä kengännumero?',
    'Selvä. Mikä kengännumero?', 'OK. What shoe size?',
    'warm-winter-shoes/2-puhe-5f739de34634.mp3', 'warm-winter-shoes/2-kirja-072d4d59b879.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 3, 'kengännumero', (select id from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 3, 'kengännumero', (select id from public.forms where lemma = 'kengännumero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kengännumero' and surface_puhe = 'kengännumero'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Kolkytseittemän.',
    'Kolmekymmentäseitsemän.', 'Thirty-seven.',
    'warm-winter-shoes/3-puhe-93f058e192d6.mp3', 'warm-winter-shoes/3-kirja-87cf1359edc8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kolmekymmentäseitsemän', (select id from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän')),
    (v_line_id, 'puhe', 1, 'Kolkytseittemän', (select id from public.forms where lemma = 'kolmekymmentäseitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäseitsemän' and surface_puhe = 'kolkytseittemän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Petri', 'Nää on lämpimät ja vedenpitävät.',
    'Nämä ovat lämpimät ja vedenpitävät.', 'These are warm and waterproof.',
    'warm-winter-shoes/4-puhe-5ea685f2dcaf.mp3', 'warm-winter-shoes/4-kirja-5daf1e7617f9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Nämä', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'kirja', 2, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'lämpimät', (select id from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'vedenpitävät', (select id from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät')),
    (v_line_id, 'puhe', 1, 'Nää', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'lämpimät', (select id from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'lämpimät' and surface_puhe = 'lämpimät')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'vedenpitävät', (select id from public.forms where lemma = 'vedenpitävä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'vedenpitävät' and surface_puhe = 'vedenpitävät'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ne on kauniit, mut vähän kalliit.',
    'Ne ovat kauniit, mutta vähän kalliit.', 'They''re nice, but a bit expensive.',
    'warm-winter-shoes/5-puhe-11f154ca70c6.mp3', 'warm-winter-shoes/5-kirja-f34e6ab05934.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 2, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'kauniit', (select id from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit')),
    (v_line_id, 'kirja', 4, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 6, 'kalliit', (select id from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit')),
    (v_line_id, 'puhe', 1, 'Ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kauniit', (select id from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kauniit' and surface_puhe = 'kauniit')),
    (v_line_id, 'puhe', 4, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 6, 'kalliit', (select id from public.forms where lemma = 'kallis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'kalliit' and surface_puhe = 'kalliit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Petri', 'Nää halvemmat on myös hyvät.',
    'Nämä halvemmat ovat myös hyvät.', 'These cheaper ones are good too.',
    'warm-winter-shoes/6-puhe-9a5bae68fdfc.mp3', 'warm-winter-shoes/6-kirja-b73e3102ba8b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Nämä', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'kirja', 2, 'halvemmat', (select id from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat')),
    (v_line_id, 'kirja', 3, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 5, 'hyvät', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät')),
    (v_line_id, 'puhe', 1, 'Nää', (select id from public.forms where lemma = 'nämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'nämä' and surface_puhe = 'nää')),
    (v_line_id, 'puhe', 2, 'halvemmat', (select id from public.forms where lemma = 'halpa' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=comparative' and surface_kirja = 'halvemmat' and surface_puhe = 'halvemmat')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 5, 'hyvät', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'hyvät' and surface_puhe = 'hyvät'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Voinks mä kokeilla niitä?',
    'Voinko minä kokeilla niitä?', 'Can I try them on?',
    'warm-winter-shoes/7-puhe-414269d5a59e.mp3', 'warm-winter-shoes/7-kirja-6530d5b09817.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voinko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'kokeilla', (select id from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla')),
    (v_line_id, 'kirja', 4, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä')),
    (v_line_id, 'puhe', 1, 'Voinks', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'kokeilla', (select id from public.forms where lemma = 'kokeilla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kokeilla' and surface_puhe = 'kokeilla')),
    (v_line_id, 'puhe', 4, 'niitä', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'niitä' and surface_puhe = 'niitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Petri', 'Totta kai. Istu tähän.',
    'Totta kai. Istu tähän.', 'Of course. Sit here.',
    'warm-winter-shoes/8-puhe-193d85ace3e2.mp3', 'warm-winter-shoes/8-kirja-b0a61eb97cc0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Istu', (select id from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu')),
    (v_line_id, 'kirja', 4, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Istu', (select id from public.forms where lemma = 'istua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'istu' and surface_puhe = 'istu')),
    (v_line_id, 'puhe', 4, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-2.json#warm-winter-shoes/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
