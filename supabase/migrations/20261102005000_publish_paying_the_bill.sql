-- Publishes the dialogue paying-the-bill (unit lunch-out). Made by
-- scripts/generate/pipeline.py publish from content/drafts/paying-the-bill. Do not edit by hand:
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
    where slug = 'paying-the-bill' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'paying-the-bill';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 17
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'lunch-out' and position = 17 and stop_number = 17;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'lunch-out';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'paying-the-bill', 3,
    'Paying the bill')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'paying-the-bill' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Paying the bill';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'paying-the-bill';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-91a5cf1932b7');
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
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]sa[Te][Ap][P1][Ny][Ef]isin[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saisinko', 'saisinks',
      'conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-624bde3d668d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saisinko', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saisinko', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks'),
      'conditional present tense, 1st person singular, with the question ending -ko/-kö', 'Saada, to get, with -isi for ''would'', -n for ''I'' and -ko to ask. Speech says -ks: saisinks.', 'could I have?', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lasku', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"lasku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lasku[X]lasku[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+lasku(lasku)"}'::jsonb,
      'laskun', 'laskun',
      'genitive singular', 'As the whole thing you ask for, lasku takes -n: laskun.', 'the bill', 'bill, invoice', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-b774b7aa13a4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laskun', 'lasku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you ask for, lasku takes -n: laskun.', 'the bill', 'bill, invoice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laskun', 'lasku',
      (select form_name_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun'),
      (select why_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun'),
      (select meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun'),
      (select lemma_meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun'),
      'genitive singular', 'As the whole thing you ask for, lasku takes -n: laskun.', 'the bill', 'bill, invoice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-b20bd263b5ae');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-b1285c45ffe6');
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
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maksaa', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"maksaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]maksaa[X]maksa[Tt][Ap][P2][Nm][Ef]tte[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=pppppppppp","TENSE":"present_simple","WORDBASES":"+maksaa(maksaa)"}'::jsonb,
      'maksatteko', 'maksatteks',
      'present tense, 2nd person plural, with the question ending -ko/-kö', 'Adds -tte for ''you all'' and -ko to ask: maksatteko. Speech says maksatteks.', 'are you paying?', 'to cost, to pay', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-aa2f650876ea');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maksatteko', 'maksaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural, with the question ending -ko/-kö', 'Adds -tte for ''you all'' and -ko to ask: maksatteko. Speech says maksatteks.', 'are you paying?', 'to cost, to pay')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maksatteko', 'maksaa',
      (select form_name_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks'),
      (select why_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks'),
      (select meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks'),
      (select lemma_meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks'),
      'present tense, 2nd person plural, with the question ending -ko/-kö', 'Adds -tte for ''you all'' and -ko to ask: maksatteko. Speech says maksatteks.', 'are you paying?', 'to cost, to pay';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sine][Ny]hdessä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhdessä', 'yhdessä',
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-9f03b11b2b04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhdessä', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhdessä', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vai', 'CLASS=sidesana', '{"BASEFORM":"vai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]vai[X]vai","STRUCTURE":"=ppp","WORDBASES":"+vai(vai)"}'::jsonb,
      'vai', 'vai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or (in questions)', 'or (in questions)', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-83d8cf4795ac');
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
  if not exists (select 1 from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('erikseen', 'CLASS=seikkasana', '{"BASEFORM":"erikseen","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'erikseen', 'erikseen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'separately', 'separately', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-94932b4ce06d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'erikseen', 'erikseen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'separately', 'separately')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'erikseen', 'erikseen',
      (select form_name_en from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen'),
      (select why_en from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen'),
      (select meaning_en from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen'),
      (select lemma_meaning_en from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'separately', 'separately';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maksaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"maksaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]maksaa[X]maksa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+maksaa(maksaa)"}'::jsonb,
      'maksan', 'maksan',
      'present tense, 1st person singular', 'Maksaa, to pay, with -n for ''I'': maksan.', 'I''ll pay', 'to cost, to pay', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-af34c4dec83d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maksan', 'maksaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Maksaa, to pay, with -n for ''I'': maksan.', 'I''ll pay', 'to cost, to pay')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maksan', 'maksaa',
      (select form_name_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan'),
      (select why_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan'),
      (select meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan'),
      (select lemma_meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan'),
      'present tense, 1st person singular', 'Maksaa, to pay, with -n for ''I'': maksan.', 'I''ll pay', 'to cost, to pay';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osuus', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"osuus","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osuus[X]osuu[Sn][Ny]te[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+osuus(osuus)"}'::jsonb,
      'osuuteni', 'osuuden',
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': osuus becomes osuuteni, the s turning to te. Speech says mun osuuden.', 'my share', 'share, part', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-80ab2a53d1df');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osuuteni', 'osuus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': osuus becomes osuuteni, the s turning to te. Speech says mun osuuden.', 'my share', 'share, part')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osuuteni', 'osuus',
      (select form_name_en from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden'),
      (select why_en from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden'),
      (select meaning_en from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden'),
      (select lemma_meaning_en from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden'),
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': osuus becomes osuuteni, the s turning to te. Speech says mun osuuden.', 'my share', 'share, part';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lounas', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"lounas","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]lounas[X]lounaa[Sn][Ny][O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+lounas(lounas)"}'::jsonb,
      'lounaasi', 'lounas',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': lounas becomes lounaasi. Speech just says sun lounas.', 'your lunch', 'lunch', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-508c737b2584');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lounaasi', 'lounas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your'': lounas becomes lounaasi. Speech just says sun lounas.', 'your lunch', 'lunch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lounaasi', 'lounas',
      (select form_name_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas'),
      (select why_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas'),
      (select meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas'),
      (select lemma_meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': lounas becomes lounaasi. Speech just says sun lounas.', 'your lunch', 'lunch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksitoista', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksitoista","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]toista[Xp][X]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+kaksitoista"}'::jsonb,
      'kaksitoista', 'kakstoist',
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-b32a414e973b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksitoista', 'kaksitoista';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksitoista', 'kaksitoista',
      (select form_name_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select why_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select meaning_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist'),
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('euro', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"euro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]euro[X]euro[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+euro(euro)"}'::jsonb,
      'euroa', 'euroo',
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-e0b2a20b7101');
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'euroa', 'euro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'euroa', 'euro',
      (select form_name_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select why_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select lemma_meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahvi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kahvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kahvi[X]kahv[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kahvi(kahvi)"}'::jsonb,
      'kahvi', 'kahvi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee', 'coffee', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-b1abf7d409f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahvi', 'kahvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee', 'coffee')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahvi', 'kahvi',
      (select form_name_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi'),
      (select why_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi'),
      (select meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi'),
      (select lemma_meaning_en from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'coffee', 'coffee';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"kuulua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuulua[X]kuuluu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+kuulua(kuulua)"}'::jsonb,
      'kuuluu', 'kuuluu',
      'present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-c1fa95e41d70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuuluu', 'kuulua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuuluu', 'kuulua',
      (select form_name_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select why_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select meaning_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      'present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lounas', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"lounas","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]lounas[X]lounaa[Sill][Ny]seen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppppp","WORDBASES":"+lounas(lounas)"}'::jsonb,
      'lounaaseen', 'lounaaseen',
      'illative singular', 'The illative singular adds -seen for ''into'': lounas becomes lounaaseen.', 'with lunch (into lunch)', 'lunch', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-1d3429d3aac7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lounaaseen', 'lounas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular adds -seen for ''into'': lounas becomes lounaaseen.', 'with lunch (into lunch)', 'lunch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lounaaseen', 'lounas',
      (select form_name_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen'),
      (select why_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen'),
      (select meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen'),
      (select lemma_meaning_en from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen'),
      'illative singular', 'The illative singular adds -seen for ''into'': lounas becomes lounaaseen.', 'with lunch (into lunch)', 'lunch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'ai',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-2ab0015782b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ai', 'ai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ai', 'ai',
      (select form_name_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select why_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select lemma_meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-483066471a02');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiva', 'kiva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiva', 'kiva',
      (select form_name_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select why_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select lemma_meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kortti', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"kortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kortti[X]korti[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+kortti(kortti)"}'::jsonb,
      'kortilla', 'kortil',
      'adessive singular', 'Adds -lla for ''by, with'': kortti becomes kortilla. Speech shortens -lla to -l: kortilla becomes kortil.', 'by card', 'card', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-3f61e1a0c95f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kortilla', 'kortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''by, with'': kortti becomes kortilla. Speech shortens -lla to -l: kortilla becomes kortil.', 'by card', 'card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kortilla', 'kortti',
      (select form_name_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil'),
      (select why_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil'),
      (select meaning_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil'),
      (select lemma_meaning_en from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil'),
      'adessive singular', 'Adds -lla for ''by, with'': kortti becomes kortilla. Speech shortens -lla to -l: kortilla becomes kortil.', 'by card', 'card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitos',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-c5b0481eae2b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tervetuloa', 'CLASS=huudahdussana', '{"BASEFORM":"tervetuloa","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]terve=tuloa[X]terve[Bm]tuloa","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+tervetuloa(terve=tuloa)"}'::jsonb,
      'tervetuloa', 'tervetuloo',
      'interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-bd5edcd6c10a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tervetuloa', 'tervetuloa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tervetuloa', 'tervetuloa',
      (select form_name_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select why_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select meaning_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      (select lemma_meaning_en from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo'),
      'interjection', 'Speech changes the last a to o: tervetuloa becomes tervetuloo. Books write tervetuloa.', 'welcome', 'welcome';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uudestaan', 'CLASS=seikkasana', '{"BASEFORM":"uudestaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]uudestaan[X]uudestaan","STRUCTURE":"=ppppppppp","WORDBASES":"+uudestaan(uudestaan)"}'::jsonb,
      'uudestaan', 'uudestaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again', 'approved', now(), 'content/approvals/part-3.json#paying-the-bill/form-2188bcbc25fe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uudestaan', 'uudestaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uudestaan', 'uudestaan',
      (select form_name_en from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan'),
      (select why_en from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan'),
      (select meaning_en from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan'),
      (select lemma_meaning_en from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'again', 'again';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Anteeks, saisinks mä laskun?',
    'Anteeksi, saisinko minä laskun?', 'Excuse me, could I have the bill?',
    'paying-the-bill/1-puhe-d6ae1acf5159.mp3', 'paying-the-bill/1-kirja-93b397f8bd35.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'saisinko', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'laskun', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'saisinks', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saisinko' and surface_puhe = 'saisinks')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'laskun', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'laskun' and surface_puhe = 'laskun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Mari', 'Totta kai. Maksatteks yhdessä vai erikseen?',
    'Totta kai. Maksatteko yhdessä vai erikseen?', 'Of course. Are you paying together or separately?',
    'paying-the-bill/2-puhe-2b6282a98a5c.mp3', 'paying-the-bill/2-kirja-d472878fa346.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Maksatteko', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks')),
    (v_line_id, 'kirja', 4, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'kirja', 5, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'kirja', 6, 'erikseen', (select id from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Maksatteks', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'maksatteko' and surface_puhe = 'maksatteks')),
    (v_line_id, 'puhe', 4, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'puhe', 5, 'vai', (select id from public.forms where lemma = 'vai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'vai' and surface_puhe = 'vai')),
    (v_line_id, 'puhe', 6, 'erikseen', (select id from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Erikseen. Mä maksan mun osuuden.',
    'Erikseen. Minä maksan minun osuuteni.', 'Separately. I''ll pay for mine.',
    'paying-the-bill/3-puhe-d5553bead7cc.mp3', 'paying-the-bill/3-kirja-559f67c5d010.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Erikseen', (select id from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'maksan', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'osuuteni', (select id from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden')),
    (v_line_id, 'puhe', 1, 'Erikseen', (select id from public.forms where lemma = 'erikseen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'erikseen' and surface_puhe = 'erikseen')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'maksan', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksan' and surface_puhe = 'maksan')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'osuuden', (select id from public.forms where lemma = 'osuus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'osuuteni' and surface_puhe = 'osuuden'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Mari', 'Okei. Sun lounas on kakstoist euroo.',
    'Selvä. Sinun lounaasi on kaksitoista euroa.', 'OK. Your lunch is twelve euros.',
    'paying-the-bill/4-puhe-e2b18f43c94d.mp3', 'paying-the-bill/4-kirja-b663ec137ccf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 3, 'lounaasi', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'kaksitoista', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'kirja', 6, 'euroa', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 3, 'lounas', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'lounaasi' and surface_puhe = 'lounas')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'kakstoist', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'puhe', 6, 'euroo', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ja kahvi?',
    'Ja kahvi?', 'And the coffee?',
    'paying-the-bill/5-puhe-e4adbba34a28.mp3', 'paying-the-bill/5-kirja-6db795532fd0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'kahvi', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'kahvi', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Mari', 'Kahvi kuuluu lounaaseen.',
    'Kahvi kuuluu lounaaseen.', 'Coffee is included with lunch.',
    'paying-the-bill/6-puhe-1adb241a8c75.mp3', 'paying-the-bill/6-kirja-3d9eb5e3ad9d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kahvi', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi')),
    (v_line_id, 'kirja', 2, 'kuuluu', (select id from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu')),
    (v_line_id, 'kirja', 3, 'lounaaseen', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen')),
    (v_line_id, 'puhe', 1, 'Kahvi', (select id from public.forms where lemma = 'kahvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kahvi' and surface_puhe = 'kahvi')),
    (v_line_id, 'puhe', 2, 'kuuluu', (select id from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu')),
    (v_line_id, 'puhe', 3, 'lounaaseen', (select id from public.forms where lemma = 'lounas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lounaaseen' and surface_puhe = 'lounaaseen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Ai, kiva! Kortil, kiitos.',
    'Ai, kiva! Kortilla, kiitos.', 'Oh, nice! By card, please.',
    'paying-the-bill/7-puhe-6c2e9dafb46b.mp3', 'paying-the-bill/7-kirja-414682e1fd58.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'kirja', 2, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 3, 'Kortilla', (select id from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil')),
    (v_line_id, 'kirja', 4, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'puhe', 2, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 3, 'Kortil', (select id from public.forms where lemma = 'kortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'kortilla' and surface_puhe = 'kortil')),
    (v_line_id, 'puhe', 4, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Mari', 'Kiitos. Tervetuloo uudestaan!',
    'Kiitos. Tervetuloa uudestaan!', 'Thank you. Do come again!',
    'paying-the-bill/8-puhe-fe726dd6b320.mp3', 'paying-the-bill/8-kirja-4d8298cb8896.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'kirja', 2, 'Tervetuloa', (select id from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo')),
    (v_line_id, 'kirja', 3, 'uudestaan', (select id from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan')),
    (v_line_id, 'puhe', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 2, 'Tervetuloo', (select id from public.forms where lemma = 'tervetuloa' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'tervetuloa' and surface_puhe = 'tervetuloo')),
    (v_line_id, 'puhe', 3, 'uudestaan', (select id from public.forms where lemma = 'uudestaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'uudestaan' and surface_puhe = 'uudestaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#paying-the-bill/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-3.json#paying-the-bill/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
