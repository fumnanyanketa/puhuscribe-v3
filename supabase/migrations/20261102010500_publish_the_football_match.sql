-- Publishes the dialogue the-football-match (unit free-time-and-hobbies). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-football-match. Do not edit by hand:
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
    where slug = 'the-football-match' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-football-match';
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
  values (v_unit_id, 'the-football-match', 3,
    'The football match')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-football-match' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'The football match';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-football-match';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katsoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"katsoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]katsoa[X]katso[Tt][Ai][P2][Ny][Ef]it[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppppp","TENSE":"past_imperfective","WORDBASES":"+katsoa(katsoa)"}'::jsonb,
      'katsoitko', 'katoit',
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Katsoit (you watched) with the question ending -ko: katsoitko. Speech drops the s and says katoitsä.', 'did you watch', 'to look, to watch', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-f2fd5074d597');
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'katsoitko', 'katsoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular, with the question ending -ko/-kö', 'Katsoit (you watched) with the question ending -ko: katsoitko. Speech drops the s and says katoitsä.', 'did you watch', 'to look, to watch')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'katsoitko', 'katsoa',
      (select form_name_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit'),
      (select why_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit'),
      (select meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit'),
      (select lemma_meaning_en from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit'),
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Katsoit (you watched) with the question ending -ko: katsoitko. Speech drops the s and says katoitsä.', 'did you watch', 'to look, to watch';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eilen', 'CLASS=seikkasana', '{"BASEFORM":"eilen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eilen[X]eilen","STRUCTURE":"=ppppp","WORDBASES":"+eilen(eilen)"}'::jsonb,
      'eilen', 'eilen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-937949f7d75d');
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
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jalkapallo', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"jalkapallo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]jalka[X]jalk[Sn][Ny]a[Bh][Bc][Ln][Xp]pallo[X]pallo[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+jalka(jalka)+pallo(pallo)"}'::jsonb,
      'jalkapalloa', 'jalkapalloo',
      'partitive singular', 'The partitive after pelata: jalkapalloa. Speech turns -oa into -oo.', 'football', 'football', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-b6fc43a9e379');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jalkapalloa', 'jalkapallo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive after pelata: jalkapalloa. Speech turns -oa into -oo.', 'football', 'football')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jalkapalloa', 'jalkapallo',
      (select form_name_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo'),
      (select why_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo'),
      (select meaning_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo'),
      (select lemma_meaning_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo'),
      'partitive singular', 'The partitive after pelata: jalkapalloa. Speech turns -oa into -oo.', 'football', 'football';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-b20bd263b5ae');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-b1285c45ffe6');
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
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pelata', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"pelata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]pelata[X]pelas[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+pelata(pelata)"}'::jsonb,
      'pelasi', 'pelas',
      'past tense, 3rd person singular', 'Pelata takes -si for something that already happened: pelasi. Speech drops the last i: pelas.', 'played', 'to play (a game or sport)', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-29a96afd5a22');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pelasi', 'pelata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Pelata takes -si for something that already happened: pelasi. Speech drops the last i: pelas.', 'played', 'to play (a game or sport)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pelasi', 'pelata',
      (select form_name_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas'),
      (select why_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas'),
      (select meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas'),
      (select lemma_meaning_en from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas'),
      'past tense, 3rd person singular', 'Pelata takes -si for something that already happened: pelasi. Speech drops the last i: pelas.', 'played', 'to play (a game or sport)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voittaa', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]voittaa[X]voitt[Tt][Ai][P3][Nm][Ef]ivat[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=ppppppppppp","TENSE":"past_imperfective","WORDBASES":"+voittaa(voittaa)"}'::jsonb,
      'voittivatko', 'voittiks',
      'past tense, 3rd person plural, with the question ending -ko/-kö', 'Voittivat (they won) with the question ending -ko: voittivatko. Speech says voittiks ne.', 'did they win', 'to win', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-575848e794b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voittivatko', 'voittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person plural, with the question ending -ko/-kö', 'Voittivat (they won) with the question ending -ko: voittivatko. Speech says voittiks ne.', 'did they win', 'to win')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voittivatko', 'voittaa',
      (select form_name_en from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks'),
      (select why_en from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks'),
      (select meaning_en from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks'),
      (select lemma_meaning_en from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks'),
      'past tense, 3rd person plural, with the question ending -ko/-kö', 'Voittivat (they won) with the question ending -ko: voittivatko. Speech says voittiks ne.', 'did they win', 'to win';
  end if;
  if not exists (select 1 from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('he', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"he","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]he[X]he[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+he(he)"}'::jsonb,
      'he', 'ne',
      'nominative plural', 'Speech uses ne for people too. Books write he.', 'they', 'they', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-ae2f0cff6156');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yksi', 'yks',
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-77de6561f822');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yksi', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yksi', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('onni', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"onni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]onni[X]onne[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+onni(onni)"}'::jsonb,
      'onneksi', 'onneks',
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-5df29264208f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'onneksi', 'onni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'onneksi', 'onni',
      (select form_name_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select why_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      (select lemma_meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks'),
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Tk][Ap][P3][Ny][Ef]koon","MOOD":"imperative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olkoon', 'olkoon',
      'imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-6312a6531b1e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olkoon', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olkoon', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'),
      'imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'oletko', 'oot',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-7134b249ebd4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oletko', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oletko', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aina', 'CLASS=seikkasana', '{"BASEFORM":"aina","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aina[X]aina","STRUCTURE":"=pppp","WORDBASES":"+aina(aina)"}'::jsonb,
      'aina', 'aina',
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-2f65b514975a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aina', 'aina';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aina', 'aina',
      (select form_name_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select why_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select meaning_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      (select lemma_meaning_en from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"pitää","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'pitänyt', 'tykänny',
      'past active participle, nominative singular', 'From pitää, to like. After ''olet'' this form says ''have liked''. Speech uses tykänny, from tykätä, to like.', 'liked (have you liked)', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-f6d53eff616e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitänyt', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From pitää, to like. After ''olet'' this form says ''have liked''. Speech uses tykänny, from tykätä, to like.', 'liked (have you liked)', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitänyt', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny'),
      'past active participle, nominative singular', 'From pitää, to like. After ''olet'' this form says ''have liked''. Speech uses tykänny, from tykätä, to like.', 'liked (have you liked)', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jalkapallo', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"jalkapallo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]jalka[X]jalk[Sn][Ny]a[Bh][Bc][Ln][Xp]pallo[X]pallo[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+jalka(jalka)+pallo(pallo)"}'::jsonb,
      'jalkapallosta', 'jalkapallost',
      'elative singular', 'Pitää and tykätä (to like) want -sta: jalkapallo becomes jalkapallosta. Speech drops the a: jalkapallost.', 'football', 'football', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-abd667265d35');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jalkapallosta', 'jalkapallo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Pitää and tykätä (to like) want -sta: jalkapallo becomes jalkapallosta. Speech drops the a: jalkapallost.', 'football', 'football')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jalkapallosta', 'jalkapallo',
      (select form_name_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost'),
      (select why_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost'),
      (select meaning_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost'),
      (select lemma_meaning_en from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost'),
      'elative singular', 'Pitää and tykätä (to like) want -sta: jalkapallo becomes jalkapallosta. Speech drops the a: jalkapallost.', 'football', 'football';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"koko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]koko[X]koko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+koko(koko)"}'::jsonb,
      'koko', 'koko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'size, whole', 'size, whole', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-bdc088ea5ab8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'koko', 'koko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'size, whole', 'size, whole')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'koko', 'koko',
      (select form_name_en from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko'),
      (select why_en from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko'),
      (select meaning_en from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko'),
      (select lemma_meaning_en from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'size, whole', 'size, whole';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('elämä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"elämä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]elämä[X]eläm[Sn][Ny]ä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+elämä(elämä)"}'::jsonb,
      'elämäni', 'elämän',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': elämäni. Speech says mun elämän.', 'my life', 'life', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-8399af114554');
  end if;
  if not exists (select 1 from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'elämäni', 'elämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': elämäni. Speech says mun elämän.', 'my life', 'life')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'elämäni', 'elämä',
      (select form_name_en from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän'),
      (select why_en from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän'),
      (select meaning_en from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän'),
      (select lemma_meaning_en from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': elämäni. Speech says mun elämän.', 'my life', 'life';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-728ddce13587');
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
      'present tense, 1st person singular', 'From pitää, to like. Books write pidän. Speech uses tykätä and says tykkään.', 'I like', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-33036ab9d70e');
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
  if not exists (select 1 from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('enemmän', 'CLASS=seikkasana', '{"BASEFORM":"enemmän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]enemmän[X]enemmän","STRUCTURE":"=ppppppp","WORDBASES":"+enemmän(enemmän)"}'::jsonb,
      'enemmän', 'enemmän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'more', 'more', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-c4d402b18df4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'enemmän', 'enemmän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'more', 'more')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'enemmän', 'enemmän',
      (select form_name_en from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän'),
      (select why_en from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän'),
      (select meaning_en from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän'),
      (select lemma_meaning_en from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'more', 'more';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jääkiekko', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"jääkiekko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]jää[X]jää[Sn][Ny][Bh][Bc][Ln][Xp]kiekko[X]kieko[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppp=pppppppp","WORDBASES":"+jää(jää)+kiekko(kiekko)"}'::jsonb,
      'jääkiekosta', 'jääkiekost',
      'elative singular', 'Pitää and tykätä (to like) want -sta: jääkiekko becomes jääkiekosta. Speech drops the a: jääkiekost.', 'ice hockey', 'ice hockey', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-34bab58c7497');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jääkiekosta', 'jääkiekko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Pitää and tykätä (to like) want -sta: jääkiekko becomes jääkiekosta. Speech drops the a: jääkiekost.', 'ice hockey', 'ice hockey')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jääkiekosta', 'jääkiekko',
      (select form_name_en from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost'),
      (select why_en from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost'),
      (select meaning_en from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost'),
      (select lemma_meaning_en from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost'),
      'elative singular', 'Pitää and tykätä (to like) want -sta: jääkiekko becomes jääkiekosta. Speech drops the a: jääkiekost.', 'ice hockey', 'ice hockey';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'aa',
      'interjection', 'Speech often says aa for ai, ah.', 'ah', 'oh', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-7fde14808815');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ai', 'ai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Speech often says aa for ai, ah.', 'ah', 'oh')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ai', 'ai',
      (select form_name_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa'),
      (select why_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa'),
      (select meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa'),
      (select lemma_meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa'),
      'interjection', 'Speech often says aa for ai, ah.', 'ah', 'oh';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietysti', 'CLASS=seikkasana', '{"BASEFORM":"tietysti","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'tietysti', 'tietysti',
      'adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-5bed682424b8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tietysti', 'tietysti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tietysti', 'tietysti',
      (select form_name_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select why_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select meaning_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      (select lemma_meaning_en from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'of course', 'of course';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olet', 'oot',
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-160976249e4f');
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
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalainen', 'suomalainen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Finnish, a Finn', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-4.json#the-football-match/form-2a904867b7d1');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Katoitsä eilen jalkapalloo?',
    'Katsoitko sinä eilen jalkapalloa?', 'Did you watch football yesterday?',
    'the-football-match/1-puhe-e37e5fe9711e.mp3', 'the-football-match/1-kirja-f30b72c8c1e0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Katsoitko', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'kirja', 4, 'jalkapalloa', (select id from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo')),
    (v_line_id, 'puhe', 1, 'Katoit', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'katsoitko' and surface_puhe = 'katoit')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'puhe', 4, 'jalkapalloo', (select id from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jalkapalloa' and surface_puhe = 'jalkapalloo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Totta kai! Brasilia pelas.',
    'Totta kai! Brasilia pelasi.', 'Of course! Brazil played.',
    'the-football-match/2-puhe-750e99344ced.mp3', 'the-football-match/2-kirja-5e2cf5c1bf75.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Brasilia', null),
    (v_line_id, 'kirja', 4, 'pelasi', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Brasilia', null),
    (v_line_id, 'puhe', 4, 'pelas', (select id from public.forms where lemma = 'pelata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'pelasi' and surface_puhe = 'pelas'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'Voittiks ne?',
    'Voittivatko he?', 'Did they win?',
    'the-football-match/3-puhe-fb06e1425678.mp3', 'the-football-match/3-kirja-3d10cd6f6321.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voittivatko', (select id from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks')),
    (v_line_id, 'kirja', 2, 'he', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 1, 'Voittiks', (select id from public.forms where lemma = 'voittaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voittivatko' and surface_puhe = 'voittiks')),
    (v_line_id, 'puhe', 2, 'ne', (select id from public.forms where lemma = 'he' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'he' and surface_puhe = 'ne'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo! Kaks yks.',
    'Kyllä! Kaksi yksi.', 'Yes! Two one.',
    'the-football-match/4-puhe-f00827001d22.mp3', 'the-football-match/4-kirja-5219d717638e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 3, 'yksi', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 3, 'yks', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ville', 'Onneks olkoon! Ootsä aina tykänny jalkapallost?',
    'Onneksi olkoon! Oletko sinä aina pitänyt jalkapallosta?', 'Congratulations! Have you always liked football?',
    'the-football-match/5-puhe-379167226261.mp3', 'the-football-match/5-kirja-f58be6a3de77.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onneksi', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'kirja', 2, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon')),
    (v_line_id, 'kirja', 3, 'Oletko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 4, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'kirja', 6, 'pitänyt', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny')),
    (v_line_id, 'kirja', 7, 'jalkapallosta', (select id from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost')),
    (v_line_id, 'puhe', 1, 'Onneks', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'puhe', 2, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon')),
    (v_line_id, 'puhe', 3, 'Oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 4, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 5, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'puhe', 6, 'tykänny', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'pitänyt' and surface_puhe = 'tykänny')),
    (v_line_id, 'puhe', 7, 'jalkapallost', (select id from public.forms where lemma = 'jalkapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jalkapallosta' and surface_puhe = 'jalkapallost'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, koko mun elämän. Entä sä?',
    'Kyllä, koko minun elämäni. Entä sinä?', 'Yes, all my life. And you?',
    'the-football-match/6-puhe-3d124cb39431.mp3', 'the-football-match/6-kirja-5f021ed244c3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'koko', (select id from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko')),
    (v_line_id, 'kirja', 3, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'elämäni', (select id from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän')),
    (v_line_id, 'kirja', 5, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'koko', (select id from public.forms where lemma = 'koko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koko' and surface_puhe = 'koko')),
    (v_line_id, 'puhe', 3, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'elämän', (select id from public.forms where lemma = 'elämä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'elämäni' and surface_puhe = 'elämän')),
    (v_line_id, 'puhe', 5, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ville', 'Mä tykkään enemmän jääkiekost.',
    'Minä pidän enemmän jääkiekosta.', 'I like ice hockey more.',
    'the-football-match/7-puhe-4aa6c40e204e.mp3', 'the-football-match/7-kirja-421f79f352c1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 3, 'enemmän', (select id from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän')),
    (v_line_id, 'kirja', 4, 'jääkiekosta', (select id from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tykkään', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 3, 'enemmän', (select id from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän')),
    (v_line_id, 'puhe', 4, 'jääkiekost', (select id from public.forms where lemma = 'jääkiekko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'jääkiekosta' and surface_puhe = 'jääkiekost'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Aa, tietysti. Sä oot suomalainen!',
    'Ai, tietysti. Sinä olet suomalainen!', 'Ah, of course. You''re Finnish!',
    'the-football-match/8-puhe-1a8fb4bb03a6.mp3', 'the-football-match/8-kirja-8cf8ccfe387f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa')),
    (v_line_id, 'kirja', 2, 'tietysti', (select id from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti')),
    (v_line_id, 'kirja', 3, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 5, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen')),
    (v_line_id, 'puhe', 1, 'Aa', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'aa')),
    (v_line_id, 'puhe', 2, 'tietysti', (select id from public.forms where lemma = 'tietysti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tietysti' and surface_puhe = 'tietysti')),
    (v_line_id, 'puhe', 3, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 5, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-football-match/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-4.json#the-football-match/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
