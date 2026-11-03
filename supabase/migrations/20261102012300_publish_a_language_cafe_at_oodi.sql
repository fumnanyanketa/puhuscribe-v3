-- Publishes the dialogue a-language-cafe-at-oodi (unit at-the-library). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-language-cafe-at-oodi. Do not edit by hand:
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
    where slug = 'a-language-cafe-at-oodi' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-language-cafe-at-oodi';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 28
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'at-the-library' and position = 28 and stop_number = 28;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'at-the-library';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-language-cafe-at-oodi', 3,
    'A language café at Oodi')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-language-cafe-at-oodi' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'A language café at Oodi';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-language-cafe-at-oodi';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tietää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tietää[X]tiedä[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+tietää(tietää)"}'::jsonb,
      'tiedätkö', 'tiiät',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-4b6766e4afb5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiedätkö', 'tietää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiedätkö', 'tietää',
      (select form_name_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select why_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      (select lemma_meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Tiiätsä, speech says tiiät for tiedät and joins sä. Books write tiedätkö sinä.', 'do you know?', 'to know';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('että', 'CLASS=sidesana', '{"BASEFORM":"että","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]että[X]että","STRUCTURE":"=pppp","WORDBASES":"+että(että)"}'::jsonb,
      'että', 'et',
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-4eeca18a865d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'että', 'että';
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'että', 'että',
      (select form_name_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select why_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select lemma_meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oodi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"oodi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]oodi[X]oodi[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+oodi(oodi)"}'::jsonb,
      'oodissa', 'oodis',
      'inessive singular', 'Adds -ssa for ''in'': Oodi becomes Oodissa. Speech shortens -ssa to -s: Oodissa becomes Oodis.', 'at Oodi', 'Oodi (Helsinki''s central library)', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-93e419d51820');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oodissa', 'oodi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': Oodi becomes Oodissa. Speech shortens -ssa to -s: Oodissa becomes Oodis.', 'at Oodi', 'Oodi (Helsinki''s central library)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oodissa', 'oodi',
      (select form_name_en from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis'),
      (select why_en from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis'),
      (select meaning_en from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis'),
      (select lemma_meaning_en from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis'),
      'inessive singular', 'Adds -ssa for ''in'': Oodi becomes Oodissa. Speech shortens -ssa to -s: Oodissa becomes Oodis.', 'at Oodi', 'Oodi (Helsinki''s central library)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilmainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"ilmainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]ilmainen[X]ilmai[Sp][Nm]sia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+ilmainen(ilmainen)"}'::jsonb,
      'ilmaisia', 'ilmasii',
      'partitive plural', 'Plural ''some'' takes -ia: ilmainen becomes ilmaisia. Speech says ilmasii.', 'free', 'free (no cost)', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-90342b361a7e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ilmaisia', 'ilmainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ia: ilmainen becomes ilmaisia. Speech says ilmasii.', 'free', 'free (no cost)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ilmaisia', 'ilmainen',
      (select form_name_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii'),
      (select why_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii'),
      (select meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii'),
      (select lemma_meaning_en from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii'),
      'partitive plural', 'Plural ''some'' takes -ia: ilmainen becomes ilmaisia. Speech says ilmasii.', 'free', 'free (no cost)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kielikahvila', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"kielikahvila","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kieli[X]kiel[Sn][Ny]i[Bh][Bc][Ln][Xp]kahvila[X]kahvilo[Sp][Nm]ita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=pppppppppp","WORDBASES":"+kieli(kieli)+kahvila(kahvila)"}'::jsonb,
      'kielikahviloita', 'kielikahviloita',
      'partitive plural', 'Plural ''some'' takes -ita: kielikahvila becomes kielikahviloita, the last a turning into o.', 'language cafés', 'language café', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-57dbf8b9da4f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kielikahviloita', 'kielikahvila';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ita: kielikahvila becomes kielikahviloita, the last a turning into o.', 'language cafés', 'language café')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kielikahviloita', 'kielikahvila',
      (select form_name_en from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita'),
      (select why_en from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita'),
      (select meaning_en from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita'),
      (select lemma_meaning_en from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita'),
      'partitive plural', 'Plural ''some'' takes -ita: kielikahvila becomes kielikahviloita, the last a turning into o.', 'language cafés', 'language café';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-e12332115711');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'en', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'en', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en'),
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-a0518fcf4ae6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'milloin', 'milloin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'milloin', 'milloin',
      (select form_name_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select why_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select lemma_meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('joka', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"joka","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]joka[X]jo[Sn][Ny]ka","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+joka(joka)"}'::jsonb,
      'joka', 'joka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-b29d81df11e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'joka', 'joka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'joka', 'joka',
      (select form_name_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select why_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select meaning_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      (select lemma_meaning_en from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'every, which, who', 'every, which, who';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keskiviikko', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"keskiviikko","CLASS":"nimisana","FSTOUTPUT":"[Lp]keski[De][Bh][Bc][Ln][Xp]viikko[X]viikko[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+keski+viikko(viikko)"}'::jsonb,
      'keskiviikko', 'keskiviikko',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-14e9de42295e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keskiviikko', 'keskiviikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keskiviikko', 'keskiviikko',
      (select form_name_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select why_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      (select lemma_meaning_en from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Wednesday', 'Wednesday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sabl][Ny]deltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viideltä', 'viideltä',
      'ablative singular', 'Adds -ltä to a number to give a clock time. Viisi changes its s to d first: viideltä, ''at five''.', 'at five', 'five', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-d693248e8615');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viideltä', 'viisi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä to a number to give a clock time. Viisi changes its s to d first: viideltä, ''at five''.', 'at five', 'five')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viideltä', 'viisi',
      (select form_name_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'),
      (select why_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'),
      (select meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'),
      (select lemma_meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'),
      'ablative singular', 'Adds -ltä to a number to give a clock time. Viisi changes its s to d first: viideltä, ''at five''.', 'at five', 'five';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-0fd3b38079dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siellä', 'siellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siellä', 'siellä',
      (select form_name_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select why_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select lemma_meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdään', 'tehään',
      'present tense, passive', 'Tehdä means to do. The ending -ään says it is done with no one named. Speech drops the d: tehään.', 'people do, is done', 'to do, to make', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-cdc685795ca4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tehdään', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'Tehdä means to do. The ending -ään says it is done with no one named. Speech drops the d: tehään.', 'people do, is done', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tehdään', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään'),
      'present tense, passive', 'Tehdä means to do. The ending -ään says it is done with no one named. Speech drops the d: tehään.', 'people do, is done', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhut[Tt][Ap][P4][Ef]aan","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhutaan', 'puhutaan',
      'present tense, passive', 'The passive form means ''let''s'' here. Puhua becomes puhutaan.', 'let''s speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-4bbe1589472b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhutaan', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s'' here. Puhua becomes puhutaan.', 'let''s speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhutaan', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan'),
      'present tense, passive', 'The passive form means ''let''s'' here. Puhua becomes puhutaan.', 'let''s speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-68ca7e058498');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomea', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomea', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'),
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vapaaehtoinen', 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"vapaaehtoinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lp]vapaa[Bh][Bc][Ln][Xp]ehto[X]ehto[Ll][Xj]inen[X]i[Sg][Nm]sten","NUMBER":"plural","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=ppppppppp","WORDBASES":"+vapaa+ehto(ehto)+inen(+inen)"}'::jsonb,
      'vapaaehtoisten', 'vapaaehtosten',
      'genitive plural', 'Kanssa, ''with'', needs -ten here: vapaaehtoinen becomes vapaaehtoisten. Speech drops an i: vapaaehtosten.', 'volunteers', 'volunteer', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-34ccdaa50508');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vapaaehtoisten', 'vapaaehtoinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive plural', 'Kanssa, ''with'', needs -ten here: vapaaehtoinen becomes vapaaehtoisten. Speech drops an i: vapaaehtosten.', 'volunteers', 'volunteer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vapaaehtoisten', 'vapaaehtoinen',
      (select form_name_en from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten'),
      (select why_en from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten'),
      (select meaning_en from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten'),
      (select lemma_meaning_en from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten'),
      'genitive plural', 'Kanssa, ''with'', needs -ten here: vapaaehtoinen becomes vapaaehtoisten. Speech drops an i: vapaaehtosten.', 'volunteers', 'volunteer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa","STRUCTURE":"=pppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssa', 'kaa',
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-6105fb644788');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kanssa', 'kanssa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kanssa', 'kanssa',
      (select form_name_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select why_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pit[Tt][Ap][P3][Ny][Ef]ää[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitääkö', 'pitääks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-c65047e392e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitääkö', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitääkö', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilmoittautua', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"ilmoittautua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ilmoittaa[X]ilmoittau[Xj]tua[X]tu[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppppppppp","WORDBASES":"+ilmoittau(ilmoittaa)+tua(+tua)"}'::jsonb,
      'ilmoittautua', 'ilmottautuu',
      'basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''need to''. Speech says ilmottautuu, dropping an i.', 'to sign up', 'to sign up, to register', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-8e4bcca75194');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ilmoittautua', 'ilmoittautua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''need to''. Speech says ilmottautuu, dropping an i.', 'to sign up', 'to sign up, to register')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ilmoittautua', 'ilmoittautua',
      (select form_name_en from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu'),
      (select why_en from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu'),
      (select meaning_en from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu'),
      (select lemma_meaning_en from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu'),
      'basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''need to''. Speech says ilmottautuu, dropping an i.', 'to sign up', 'to sign up, to register';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"tarvita","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'tarvitse', 'tarvii',
      'present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-f017cb16a696');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitse', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitse', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      'present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tule', 'tuu',
      'imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-a2a7fb70527b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tule', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tule', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu'),
      'imperative present tense, 2nd person singular', 'Tulla, to come. To tell one person to come, use tule. Speech says tuu.', 'come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennään', 'mennään',
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-e184450d7d09');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennään', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennään', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sine][Ny]hdessä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhdessä', 'yhdessä',
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-9f03b11b2b04');
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
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensi', 'CLASS=seikkasana', '{"BASEFORM":"ensi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensi[X]ensi","STRUCTURE":"=pppp","WORDBASES":"+ensi(ensi)"}'::jsonb,
      'ensi', 'ens',
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-00d6b814f19a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensi', 'ensi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensi', 'ensi',
      (select form_name_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select why_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select meaning_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      (select lemma_meaning_en from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens'),
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viiko[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikolla', 'viikol',
      'adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k. Speech shortens -lla to -l: viikolla becomes viikol.', '(next) week', 'week', 'approved', now(), 'content/approvals/part-5.json#a-language-cafe-at-oodi/form-ca5fbcee777a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikolla', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k. Speech shortens -lla to -l: viikolla becomes viikol.', '(next) week', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikolla', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol'),
      'adessive singular', 'Adds -lla for time: viikko becomes viikolla, kk turning into k. Speech shortens -lla to -l: viikolla becomes viikol.', '(next) week', 'week';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Tiiätsä, et Oodis on ilmasii kielikahviloita?',
    'Tiedätkö sinä, että Oodissa on ilmaisia kielikahviloita?', 'Did you know Oodi has free language cafés?',
    'a-language-cafe-at-oodi/1-puhe-a575ae68b4c7.mp3', 'a-language-cafe-at-oodi/1-kirja-af2552cafd64.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tiedätkö', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'että', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 4, 'Oodissa', (select id from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'ilmaisia', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii')),
    (v_line_id, 'kirja', 7, 'kielikahviloita', (select id from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita')),
    (v_line_id, 'puhe', 1, 'Tiiät', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tiedätkö' and surface_puhe = 'tiiät')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'et', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 4, 'Oodis', (select id from public.forms where lemma = 'oodi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'oodissa' and surface_puhe = 'oodis')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'ilmasii', (select id from public.forms where lemma = 'ilmainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'ilmaisia' and surface_puhe = 'ilmasii')),
    (v_line_id, 'puhe', 7, 'kielikahviloita', (select id from public.forms where lemma = 'kielikahvila' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kielikahviloita' and surface_puhe = 'kielikahviloita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'En! Millon?',
    'En! Milloin?', 'No! When?',
    'a-language-cafe-at-oodi/2-puhe-7325f78229ba.mp3', 'a-language-cafe-at-oodi/2-kirja-7c3ea9438e51.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 2, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 2, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Joka keskiviikko viideltä.',
    'Joka keskiviikko viideltä.', 'Every Wednesday at five.',
    'a-language-cafe-at-oodi/3-puhe-1b3949cb86d0.mp3', 'a-language-cafe-at-oodi/3-kirja-60252063ddda.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Joka', (select id from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka')),
    (v_line_id, 'kirja', 2, 'keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'kirja', 3, 'viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'puhe', 1, 'Joka', (select id from public.forms where lemma = 'joka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'joka' and surface_puhe = 'joka')),
    (v_line_id, 'puhe', 2, 'keskiviikko', (select id from public.forms where lemma = 'keskiviikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'keskiviikko' and surface_puhe = 'keskiviikko')),
    (v_line_id, 'puhe', 3, 'viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mitä siel tehään?',
    'Mitä siellä tehdään?', 'What do you do there?',
    'a-language-cafe-at-oodi/4-puhe-4ec02298efea.mp3', 'a-language-cafe-at-oodi/4-kirja-b015c865387b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 3, 'tehdään', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 3, 'tehään', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tehdään' and surface_puhe = 'tehään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Siel puhutaan suomee vapaaehtosten kaa.',
    'Siellä puhutaan suomea vapaaehtoisten kanssa.', 'You speak Finnish with volunteers.',
    'a-language-cafe-at-oodi/5-puhe-8282ab0be82d.mp3', 'a-language-cafe-at-oodi/5-kirja-53fe5ab5b135.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 2, 'puhutaan', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan')),
    (v_line_id, 'kirja', 3, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 4, 'vapaaehtoisten', (select id from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten')),
    (v_line_id, 'kirja', 5, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 2, 'puhutaan', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhutaan' and surface_puhe = 'puhutaan')),
    (v_line_id, 'puhe', 3, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 4, 'vapaaehtosten', (select id from public.forms where lemma = 'vapaaehtoinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'vapaaehtoisten' and surface_puhe = 'vapaaehtosten')),
    (v_line_id, 'puhe', 5, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Pitääks ilmottautuu?',
    'Pitääkö ilmoittautua?', 'Do you need to sign up?',
    'a-language-cafe-at-oodi/6-puhe-43daa110217d.mp3', 'a-language-cafe-at-oodi/6-kirja-41d62a2af99f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pitääkö', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'kirja', 2, 'ilmoittautua', (select id from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu')),
    (v_line_id, 'puhe', 1, 'Pitääks', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'puhe', 2, 'ilmottautuu', (select id from public.forms where lemma = 'ilmoittautua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'ilmoittautua' and surface_puhe = 'ilmottautuu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Ei tarvii. Tuu vaan.',
    'Ei tarvitse. Tule vain.', 'No need. Just come.',
    'a-language-cafe-at-oodi/7-puhe-7c203fe5e227.mp3', 'a-language-cafe-at-oodi/7-kirja-3a080a33a7e8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'tarvitse', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'kirja', 3, 'Tule', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu')),
    (v_line_id, 'kirja', 4, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'tarvii', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'puhe', 3, 'Tuu', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'tule' and surface_puhe = 'tuu')),
    (v_line_id, 'puhe', 4, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mennään yhdessä ens viikol!',
    'Mennään yhdessä ensi viikolla!', 'Let''s go together next week!',
    'a-language-cafe-at-oodi/8-puhe-71d022933457.mp3', 'a-language-cafe-at-oodi/8-kirja-46fb5d92845d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'kirja', 2, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'kirja', 3, 'ensi', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'kirja', 4, 'viikolla', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol')),
    (v_line_id, 'puhe', 1, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'puhe', 2, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'puhe', 3, 'ens', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'puhe', 4, 'viikol', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'viikolla' and surface_puhe = 'viikol'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#a-language-cafe-at-oodi/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
