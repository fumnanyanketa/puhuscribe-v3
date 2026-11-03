-- Publishes the dialogue the-first-snow (unit seasons-and-the-dark-winter). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-first-snow. Do not edit by hand:
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
    where slug = 'the-first-snow' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-first-snow';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 27
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'seasons-and-the-dark-winter' and position = 27 and stop_number = 27;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'seasons-and-the-dark-winter';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'the-first-snow', 1,
    'The first snow')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-first-snow' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'The first snow';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-first-snow';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katsoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"katsoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]katsoa[X]katso[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+katsoa(katsoa)"}'::jsonb,
      'katso', 'kato',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to look: katso. Speech drops the s: kato.', 'look', 'to look, to watch', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-8350ddd0f318');
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
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sataa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sataa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sataa[X]sat[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sataa(sataa)"}'::jsonb,
      'sataa', 'sataa',
      'present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-5f9ca24b3b7c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sataa', 'sataa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sataa', 'sataa',
      (select form_name_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select why_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select meaning_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      (select lemma_meaning_en from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa'),
      'present tense, 3rd person singular', 'Sataa, to rain or fall. Finnish needs no ''it'' here: Sataa lunta, it is snowing.', 'it''s falling (snowing)', 'to rain';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lumi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lumi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lumi[X]lu[Sp][Ny]nta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lumi(lumi)"}'::jsonb,
      'lunta', 'lunta',
      'partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-17f6120f7a62');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lunta', 'lumi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lunta', 'lumi',
      (select form_name_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select why_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      (select lemma_meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'),
      'partitive singular', 'Lumi becomes lunta for some snow: m changes to n and -ta is added.', 'snow', 'snow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensimmäinen', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ensimmäinen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]ensimmäinen[X]ensimmäi[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+ensimmäinen(ensimmäinen)"}'::jsonb,
      'ensimmäinen', 'eka',
      'nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-68b7d847fe2e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ensimmäinen', 'ensimmäinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ensimmäinen', 'ensimmäinen',
      (select form_name_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select why_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select meaning_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      (select lemma_meaning_en from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka'),
      'nominative singular', 'Speech often uses the short word eka. Books write ensimmäinen.', 'first', 'first';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lumi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lumi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lumi[X]lu[Sn][Ny]mi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+lumi(lumi)"}'::jsonb,
      'lumi', 'lumi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-4e2c2b227f2e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lumi', 'lumi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lumi', 'lumi',
      (select form_name_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select why_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      (select lemma_meaning_en from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'snow', 'snow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-4352ca83b810');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tämä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tämä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kerta', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"kerta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kerta[X]kert[Sn][Ny]a[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+kerta(kerta)"}'::jsonb,
      'kertasi', 'kerta',
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': kertasi. Speech drops it and says sun kerta.', 'your time', 'time, occasion', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-a5d4821a4f90');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kertasi', 'kerta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Books add -si for ''your'': kertasi. Speech drops it and says sun kerta.', 'your time', 'time, occasion')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kertasi', 'kerta',
      (select form_name_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta'),
      (select why_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta'),
      (select meaning_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta'),
      (select lemma_meaning_en from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta'),
      'nominative singular, with the possessive ending for your', 'Books add -si for ''your'': kertasi. Speech drops it and says sun kerta.', 'your time', 'time, occasion';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaunis', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kaunis","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kaunis[X]kauni[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+kaunis(kaunis)"}'::jsonb,
      'kaunista', 'kaunista',
      'partitive singular', 'The partitive after oli for how a place felt: oli kaunista.', 'beautiful', 'beautiful', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-0b1c14ad09fe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaunista', 'kaunis';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive after oli for how a place felt: oli kaunista.', 'beautiful', 'beautiful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaunista', 'kaunis',
      (select form_name_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista'),
      (select why_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista'),
      (select meaning_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista'),
      (select lemma_meaning_en from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista'),
      'partitive singular', 'The partitive after oli for how a place felt: oli kaunista.', 'beautiful', 'beautiful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('odottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"odottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]odottaa[X]odota[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+odottaa(odottaa)"}'::jsonb,
      'odota', 'odota',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to wait: odota. It comes from odottaa, with one t.', 'wait', 'to wait', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-1f390feba94f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'odota', 'odottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'This is how you tell someone to wait: odota. It comes from odottaa, with one t.', 'wait', 'to wait')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'odota', 'odottaa',
      (select form_name_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota'),
      (select why_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota'),
      (select meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota'),
      (select lemma_meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota'),
      'imperative present tense, 2nd person singular', 'This is how you tell someone to wait: odota. It comes from odottaa, with one t.', 'wait', 'to wait';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talvi', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"talvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]talvi[X]talve[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+talvi(talvi)"}'::jsonb,
      'talvella', 'talvel',
      'adessive singular', 'Talvi takes -lla to say when: talvella. Speech shortens -lla to -l: talvella becomes talvel.', 'in winter', 'winter', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-393179c8b612');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talvella', 'talvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Talvi takes -lla to say when: talvella. Speech shortens -lla to -l: talvella becomes talvel.', 'in winter', 'winter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talvella', 'talvi',
      (select form_name_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel'),
      (select why_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel'),
      (select meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel'),
      (select lemma_meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel'),
      'adessive singular', 'Talvi takes -lla to say when: talvella. Speech shortens -lla to -l: talvella becomes talvel.', 'in winter', 'winter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-2b3844766909');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vielä', 'vielä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vielä', 'vielä',
      (select form_name_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select why_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select lemma_meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet';
  end if;
  if not exists (select 1 from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('enemmän', 'CLASS=seikkasana', '{"BASEFORM":"enemmän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]enemmän[X]enemmän","STRUCTURE":"=ppppppp","WORDBASES":"+enemmän(enemmän)"}'::jsonb,
      'enemmän', 'enemmän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'more', 'more', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-c4d402b18df4');
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
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-5bdac2fbf3a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täällä', 'täällä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täällä', 'täällä',
      (select form_name_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select why_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select lemma_meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kylmä', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"kylmä","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Lnl][Xp]kylmä[X]kylme[Sp][Ny][Cc]mpää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+kylmä(kylmä)"}'::jsonb,
      'kylmempää', 'kylmempää',
      'comparative, partitive singular', 'Kylmä takes -mpää for ''more'': kylmempää, ''colder''.', 'colder', 'cold', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-baa121b1f64e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kylmempää', 'kylmä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, partitive singular', 'Kylmä takes -mpää for ''more'': kylmempää, ''colder''.', 'colder', 'cold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kylmempää', 'kylmä',
      (select form_name_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää'),
      (select why_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää'),
      (select meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää'),
      (select lemma_meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää'),
      'comparative, partitive singular', 'Kylmä takes -mpää for ''more'': kylmempää, ''colder''.', 'colder', 'cold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuin', 'CLASS=sidesana', '{"BASEFORM":"kuin","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuin[X]kuin","STRUCTURE":"=pppp","WORDBASES":"+kuin(kuin)"}'::jsonb,
      'kuin', 'ku',
      'conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-999024e8747e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuin', 'kuin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuin', 'kuin',
      (select form_name_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select why_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select meaning_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      (select lemma_meaning_en from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku'),
      'conjunction', 'Books write kuin. Speech shortens it to ku.', 'than', 'than, as';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsen', 'tarviin',
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-60958fda456e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsen', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsen', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lämmin', 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"lämmin","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Lnl][Xp]lämmin[X]lämpimä[Sg][Ny][Cc]mmän","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+lämmin(lämmin)"}'::jsonb,
      'lämpimämmän', 'lämpimämmän',
      'comparative, genitive singular', 'Lämmin takes -mmän for ''more'': lämpimämmän, ''warmer'', to match takin.', 'warmer', 'warm', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-8fd2eaccc3d2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lämpimämmän', 'lämmin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, genitive singular', 'Lämmin takes -mmän for ''more'': lämpimämmän, ''warmer'', to match takin.', 'warmer', 'warm')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lämpimämmän', 'lämmin',
      (select form_name_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän'),
      (select why_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän'),
      (select meaning_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän'),
      (select lemma_meaning_en from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän'),
      'comparative, genitive singular', 'Lämmin takes -mmän for ''more'': lämpimämmän, ''warmer'', to match takin.', 'warmer', 'warm';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takki', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"takki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]takki[X]tak[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+takki(takki)"}'::jsonb,
      'takin', 'takin',
      'genitive singular', 'Adds -n for the thing you need: takki becomes takin, with one k.', 'coat', 'coat, jacket', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-d65789c123fc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'takin', 'takki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n for the thing you need: takki becomes takin, with one k.', 'coat', 'coat, jacket')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'takin', 'takki',
      (select form_name_en from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin'),
      (select why_en from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin'),
      (select meaning_en from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin'),
      (select lemma_meaning_en from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin'),
      'genitive singular', 'Adds -n for the thing you need: takki becomes takin, with one k.', 'coat', 'coat, jacket';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käsine', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"käsine","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]käsine[X]käsine[Sn][Nm]et","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+käsine(käsine)"}'::jsonb,
      'käsineet', 'hanskat',
      'nominative plural', 'Speech often says hanskat. Books write käsineet.', 'gloves', 'glove', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-590854f4496c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käsineet', 'käsine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Speech often says hanskat. Books write käsineet.', 'gloves', 'glove')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käsineet', 'käsine',
      (select form_name_en from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat'),
      (select why_en from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat'),
      (select meaning_en from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat'),
      (select lemma_meaning_en from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat'),
      'nominative plural', 'Speech often says hanskat. Books write käsineet.', 'gloves', 'glove';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pipo', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"pipo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pipo[X]pipo[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+pipo(pipo)"}'::jsonb,
      'pipon', 'pipon',
      'genitive singular', 'Adds -n for the thing you need: pipo becomes pipon.', 'hat', 'beanie, knitted hat', 'approved', now(), 'content/approvals/part-5.json#the-first-snow/form-20e72c794f3b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pipon', 'pipo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n for the thing you need: pipo becomes pipon.', 'hat', 'beanie, knitted hat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pipon', 'pipo',
      (select form_name_en from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon'),
      (select why_en from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon'),
      (select meaning_en from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon'),
      (select lemma_meaning_en from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon'),
      'genitive singular', 'Adds -n for the thing you need: pipo becomes pipon.', 'hat', 'beanie, knitted hat';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Leena, kato! Sataa lunta!',
    'Leena, katso! Sataa lunta!', 'Leena, look! It''s snowing!',
    'the-first-snow/1-puhe-fb3051429557.mp3', 'the-first-snow/1-kirja-ae5f777e1591.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Leena', null),
    (v_line_id, 'kirja', 2, 'katso', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'kirja', 3, 'Sataa', (select id from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa')),
    (v_line_id, 'kirja', 4, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta')),
    (v_line_id, 'puhe', 1, 'Leena', null),
    (v_line_id, 'puhe', 2, 'kato', (select id from public.forms where lemma = 'katsoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'katso' and surface_puhe = 'kato')),
    (v_line_id, 'puhe', 3, 'Sataa', (select id from public.forms where lemma = 'sataa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sataa' and surface_puhe = 'sataa')),
    (v_line_id, 'puhe', 4, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Leena', 'Joo, eka lumi! Onks tää sun eka kerta?',
    'Kyllä, ensimmäinen lumi! Onko tämä sinun ensimmäinen kertasi?', 'Yes, the first snow! Is this your first time?',
    'the-first-snow/2-puhe-0bd1499d2328.mp3', 'the-first-snow/2-kirja-a33970cbd19b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'ensimmäinen', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'kirja', 3, 'lumi', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi')),
    (v_line_id, 'kirja', 4, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 5, 'tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 6, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 7, 'ensimmäinen', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'kirja', 8, 'kertasi', (select id from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'eka', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'puhe', 3, 'lumi', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lumi' and surface_puhe = 'lumi')),
    (v_line_id, 'puhe', 4, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 5, 'tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 6, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 7, 'eka', (select id from public.forms where lemma = 'ensimmäinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ensimmäinen' and surface_puhe = 'eka')),
    (v_line_id, 'puhe', 8, 'kerta', (select id from public.forms where lemma = 'kerta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'kertasi' and surface_puhe = 'kerta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'On! Se on niin kaunista.',
    'On! Se on niin kaunista.', 'Yes! It''s so beautiful.',
    'the-first-snow/3-puhe-517cc7085708.mp3', 'the-first-snow/3-kirja-257652e89e15.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 5, 'kaunista', (select id from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 5, 'kaunista', (select id from public.forms where lemma = 'kaunis' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kaunista' and surface_puhe = 'kaunista'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Leena', 'Odota vaan, talvel on vielä enemmän lunta.',
    'Odota vain, talvella on vielä enemmän lunta.', 'Just wait, in winter there''s even more snow.',
    'the-first-snow/4-puhe-05cc75a73eb4.mp3', 'the-first-snow/4-kirja-6b13a9e16347.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Odota', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota')),
    (v_line_id, 'kirja', 2, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 3, 'talvella', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'kirja', 6, 'enemmän', (select id from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän')),
    (v_line_id, 'kirja', 7, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta')),
    (v_line_id, 'puhe', 1, 'Odota', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'odota' and surface_puhe = 'odota')),
    (v_line_id, 'puhe', 2, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 3, 'talvel', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'talvella' and surface_puhe = 'talvel')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 6, 'enemmän', (select id from public.forms where lemma = 'enemmän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'enemmän' and surface_puhe = 'enemmän')),
    (v_line_id, 'puhe', 7, 'lunta', (select id from public.forms where lemma = 'lumi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lunta' and surface_puhe = 'lunta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Onks täällä kylmempää ku Lapis?',
    'Onko täällä kylmempää kuin Lapissa?', 'Is it colder here than in Lapland?',
    'the-first-snow/5-puhe-f79eeee78b91.mp3', 'the-first-snow/5-kirja-39a4539bf25f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 3, 'kylmempää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää')),
    (v_line_id, 'kirja', 4, 'kuin', (select id from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku')),
    (v_line_id, 'kirja', 5, 'Lapissa', null),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 3, 'kylmempää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää')),
    (v_line_id, 'puhe', 4, 'ku', (select id from public.forms where lemma = 'kuin' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuin' and surface_puhe = 'ku')),
    (v_line_id, 'puhe', 5, 'Lapis', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Leena', 'Ei, Lapis on paljon kylmempää.',
    'Ei, Lapissa on paljon kylmempää.', 'No, Lapland is much colder.',
    'the-first-snow/6-puhe-7a476706f54c.mp3', 'the-first-snow/6-kirja-41a29150c001.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'Lapissa', null),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 5, 'kylmempää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'Lapis', null),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 5, 'kylmempää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'kylmempää' and surface_puhe = 'kylmempää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Mä tarviin lämpimämmän takin.',
    'Minä tarvitsen lämpimämmän takin.', 'I need a warmer coat.',
    'the-first-snow/7-puhe-3f9410bbc9fc.mp3', 'the-first-snow/7-kirja-d4dbae0b92f8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'tarvitsen', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'kirja', 3, 'lämpimämmän', (select id from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän')),
    (v_line_id, 'kirja', 4, 'takin', (select id from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tarviin', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'puhe', 3, 'lämpimämmän', (select id from public.forms where lemma = 'lämmin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'lämpimämmän' and surface_puhe = 'lämpimämmän')),
    (v_line_id, 'puhe', 4, 'takin', (select id from public.forms where lemma = 'takki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'takin' and surface_puhe = 'takin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Leena', 'Ja hanskat ja pipon!',
    'Ja käsineet ja pipon!', 'And gloves and a hat!',
    'the-first-snow/8-puhe-b936aedb5d39.mp3', 'the-first-snow/8-kirja-ae7e30fe4362.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'käsineet', (select id from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat')),
    (v_line_id, 'kirja', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'pipon', (select id from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'hanskat', (select id from public.forms where lemma = 'käsine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'käsineet' and surface_puhe = 'hanskat')),
    (v_line_id, 'puhe', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'pipon', (select id from public.forms where lemma = 'pipo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pipon' and surface_puhe = 'pipon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#the-first-snow/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
