-- Publishes the dialogue my-story (unit a-day-in-my-life). Made by
-- scripts/generate/pipeline.py publish from content/drafts/my-story. Do not edit by hand:
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
    where slug = 'my-story' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'my-story';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 36
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'a-day-in-my-life' and position = 36 and stop_number = 36;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'a-day-in-my-life';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'my-story', 3,
    'My story')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'my-story' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'My story';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'my-story';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kertoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kertoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kertoa[X]kerro[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+kertoa(kertoa)"}'::jsonb,
      'kerro', 'kerro',
      'imperative present tense, 2nd person singular', 'Kertoa means to tell. Dropping the last -a gives kerro, telling someone to do it.', 'tell', 'to tell', 'approved', now(), 'content/approvals/part-6.json#my-story/form-6971cd022ac8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kerro', 'kertoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Kertoa means to tell. Dropping the last -a gives kerro, telling someone to do it.', 'tell', 'to tell')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kerro', 'kertoa',
      (select form_name_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro'),
      (select why_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro'),
      (select meaning_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro'),
      (select lemma_meaning_en from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro'),
      'imperative present tense, 2nd person singular', 'Kertoa means to tell. Dropping the last -a gives kerro, telling someone to do it.', 'tell', 'to tell';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-6.json#my-story/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('itse', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"itse","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]itse[X]itse[Sela][Ny]stä[O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppppp","WORDBASES":"+itse(itse)"}'::jsonb,
      'itsestäsi', 'itsestäs',
      'elative singular, with the possessive ending for your', 'Itse with -stä and -si for ''your'': itsestäsi. Speech drops the last i: itsestäs.', 'of yourself', 'self', 'approved', now(), 'content/approvals/part-6.json#my-story/form-394bcb54aac4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'itsestäsi', 'itse';
  end if;
  if not exists (select 1 from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular, with the possessive ending for your', 'Itse with -stä and -si for ''your'': itsestäsi. Speech drops the last i: itsestäs.', 'of yourself', 'self')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'itsestäsi', 'itse',
      (select form_name_en from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs'),
      (select why_en from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs'),
      (select meaning_en from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs'),
      (select lemma_meaning_en from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs'),
      'elative singular, with the possessive ending for your', 'Itse with -stä and -si for ''your'': itsestäsi. Speech drops the last i: itsestäs.', 'of yourself', 'self';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#my-story/form-728ddce13587');
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
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#my-story/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#my-story/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-6.json#my-story/form-58f467b0bcb4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'missä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'missä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#my-story/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"asua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]asua[X]asu[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+asua(asua)"}'::jsonb,
      'asut', 'asut',
      'present tense, 2nd person singular', 'Adds -t for ''you'': asua becomes asut. People say it the same way.', 'you live', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-6.json#my-story/form-e256969dad6f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asut', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Adds -t for ''you'': asua becomes asut. People say it the same way.', 'you live', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asut', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut'),
      'present tense, 2nd person singular', 'Adds -t for ''you'': asua becomes asut. People say it the same way.', 'you live', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-6.json#my-story/form-00cf76bd38f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nyt', 'nyt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nyt', 'nyt',
      (select form_name_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select why_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select lemma_meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kallio', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kallio","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]kallio[X]kallio[Sine][Ny]ssa","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppp","WORDBASES":"+kallio(kallio)"}'::jsonb,
      'kalliossa', 'kalliossa',
      'inessive singular', 'Adds -ssa for ''in'': Kallio becomes Kalliossa.', 'in Kallio', 'rock, cliff (Kallio, a Helsinki district)', 'approved', now(), 'content/approvals/part-6.json#my-story/form-224a02f836b7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kalliossa', 'kallio';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': Kallio becomes Kalliossa.', 'in Kallio', 'rock, cliff (Kallio, a Helsinki district)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kalliossa', 'kallio',
      (select form_name_en from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa'),
      (select why_en from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa'),
      (select meaning_en from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa'),
      (select lemma_meaning_en from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa'),
      'inessive singular', 'Adds -ssa for ''in'': Kallio becomes Kalliossa.', 'in Kallio', 'rock, cliff (Kallio, a Helsinki district)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-6.json#my-story/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mies', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"mies","CLASS":"nimisana","MANUAL":"true","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"omanto"}'::jsonb,
      'mieheni', 'miehen',
      'genitive singular, with the possessive ending for my', 'Mies, man or husband. With kanssa it takes -n, and -ni adds ''my'': mieheni. Speech: mun miehen.', 'my husband', 'man, husband', 'approved', now(), 'content/approvals/part-6.json#my-story/form-84a435b7ff95');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mieheni', 'mies';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular, with the possessive ending for my', 'Mies, man or husband. With kanssa it takes -n, and -ni adds ''my'': mieheni. Speech: mun miehen.', 'my husband', 'man, husband')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mieheni', 'mies',
      (select form_name_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen'),
      (select why_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen'),
      (select meaning_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen'),
      (select lemma_meaning_en from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen'),
      'genitive singular, with the possessive ending for my', 'Mies, man or husband. With kanssa it takes -n, and -ni adds ''my'': mieheni. Speech: mun miehen.', 'my husband', 'man, husband';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sg][Ny]hden","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kahden', 'kahen',
      'genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two', 'approved', now(), 'content/approvals/part-6.json#my-story/form-c2c426a526c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahden', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahden', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen'),
      'genitive singular', 'Kaksi with -n before päästä: kahden minuutin päästä. Speech drops the d: kahen.', 'two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lapsi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"lapsi","CLASS":"nimisana","MANUAL":"true","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"omanto"}'::jsonb,
      'lapseni', 'lapsen',
      'genitive singular, with the possessive ending for my', 'Lapsi, child. With kanssa it takes -n, and -ni adds ''my'': lapseni. Speech: mun lapsen.', 'my children', 'child', 'approved', now(), 'content/approvals/part-6.json#my-story/form-8ba45f54b531');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lapseni', 'lapsi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular, with the possessive ending for my', 'Lapsi, child. With kanssa it takes -n, and -ni adds ''my'': lapseni. Speech: mun lapsen.', 'my children', 'child')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lapseni', 'lapsi',
      (select form_name_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen'),
      (select why_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen'),
      (select meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen'),
      (select lemma_meaning_en from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen'),
      'genitive singular, with the possessive ending for my', 'Lapsi, child. With kanssa it takes -n, and -ni adds ''my'': lapseni. Speech: mun lapsen.', 'my children', 'child';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa","STRUCTURE":"=pppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssa', 'kaa',
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with', 'approved', now(), 'content/approvals/part-6.json#my-story/form-6105fb644788');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#my-story/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teet', 'teet',
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#my-story/form-d8e27c6cf4bb');
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
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asiakaspalvelu', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"asiakaspalvelu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asiakas[X]asiaka[Sn][Ny]s[Bh][Bc][Lt][Xp]palvella[X]palvel[Ln][Xj]u[X]u[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp=pppppppppp","WORDBASES":"+asiakas(asiakas)+palvel(palvella)+u(+u)"}'::jsonb,
      'asiakaspalvelussa', 'asiakaspalvelus',
      'inessive singular', 'Adds -ssa for ''in'': asiakaspalvelu becomes asiakaspalvelussa. Speech shortens -ssa to -s: asiakaspalvelussa becomes asiakaspalvelus.', 'in customer service', 'customer service', 'approved', now(), 'content/approvals/part-6.json#my-story/form-df893cd83caf');
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
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-6.json#my-story/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluan', 'haluun',
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-6.json#my-story/form-65809211d876');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluan', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluan', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]oll[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppp","WORDBASES":"+olla(olla)"}'::jsonb,
      'olla', 'olla',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to be, to have', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#my-story/form-677fd2e58ace');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olla', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to be, to have', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olla', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to be, to have', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaja', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"opettaja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Ln][Xj]ja[X][Sn][Ny]ja","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+opetta(opettaa)+ja(+ja)"}'::jsonb,
      'opettaja', 'opettaja',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'teacher', 'teacher', 'approved', now(), 'content/approvals/part-6.json#my-story/form-6a35f7e46946');
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
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkäät', 'tykkäät',
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like', 'approved', now(), 'content/approvals/part-6.json#my-story/form-43715f936732');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkäät', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkäät', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdä', 'tehä',
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#my-story/form-f64c6f94ba00');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tehdä', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tehdä', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laulaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"laulaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laulaa[X]laula[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+laulaa(laulaa)"}'::jsonb,
      'laulan', 'laulan',
      'present tense, 1st person singular', 'Laulaa drops the last a and takes -n for ''I'': laulan.', 'I sing', 'to sing', 'approved', now(), 'content/approvals/part-6.json#my-story/form-c37cc30d4ec4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laulan', 'laulaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Laulaa drops the last a and takes -n for ''I'': laulan.', 'I sing', 'to sing')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laulan', 'laulaa',
      (select form_name_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan'),
      (select why_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan'),
      (select meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan'),
      (select lemma_meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan'),
      'present tense, 1st person singular', 'Laulaa drops the last a and takes -n for ''I'': laulan.', 'I sing', 'to sing';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuoro', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kuoro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuoro[X]kuoro[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+kuoro(kuoro)"}'::jsonb,
      'kuorossa', 'kuoros',
      'inessive singular', 'Adds -ssa for ''in'': kuoro becomes kuorossa. Speech shortens -ssa to -s: kuorossa becomes kuoros.', 'in a choir', 'choir', 'approved', now(), 'content/approvals/part-6.json#my-story/form-aa5fee5dd7b4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuorossa', 'kuoro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': kuoro becomes kuorossa. Speech shortens -ssa to -s: kuorossa becomes kuoros.', 'in a choir', 'choir')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuorossa', 'kuoro',
      (select form_name_en from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros'),
      (select why_en from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros'),
      (select meaning_en from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros'),
      (select lemma_meaning_en from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros'),
      'inessive singular', 'Adds -ssa for ''in'': kuoro becomes kuorossa. Speech shortens -ssa to -s: kuorossa becomes kuoros.', 'in a choir', 'choir';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käyn', 'käyn',
      'present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-6.json#my-story/form-042a57533dce');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käyn', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käyn', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn'),
      'present tense, 1st person singular', 'Käydä drops -dä and takes -n for ''I'': käyn. Käyn salilla means ''I go to the gym''.', 'I go', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]sauna[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'saunassa', 'saunas',
      'inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna', 'approved', now(), 'content/approvals/part-6.json#my-story/form-d98fbee7d5d9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunassa', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunassa', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas'),
      'inessive singular', 'Adds -ssa for ''in'': sauna becomes saunassa. Speech shortens -ssa to -s: saunassa becomes saunas.', 'in a sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhu[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhun', 'puhun',
      'present tense, 1st person singular', 'Puhua means to speak. -n goes with minä: puhun.', 'I speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-6.json#my-story/form-84d51cdf8c95');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhun', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Puhua means to speak. -n goes with minä: puhun.', 'I speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhun', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun'),
      'present tense, 1st person singular', 'Puhua means to speak. -n goes with minä: puhun.', 'I speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#my-story/form-68ca7e058498');
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
  if not exists (select 1 from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aina', 'CLASS=seikkasana', '{"BASEFORM":"aina","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aina[X]aina","STRUCTURE":"=pppp","WORDBASES":"+aina(aina)"}'::jsonb,
      'aina', 'aina',
      'adverb', 'This is the dictionary form. People say it the same way.', 'always', 'always', 'approved', now(), 'content/approvals/part-6.json#my-story/form-2f65b514975a');
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
  if not exists (select 1 from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kun', 'CLASS=sidesana', '{"BASEFORM":"kun","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kun[X]kun","STRUCTURE":"=ppp","WORDBASES":"+kun(kun)"}'::jsonb,
      'kun', 'ku',
      'conjunction', 'This is the dictionary form. Speech drops the n: ku.', 'whenever, when', 'when, once', 'approved', now(), 'content/approvals/part-6.json#my-story/form-e7ffe944b11f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kun', 'kun';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. Speech drops the n: ku.', 'whenever, when', 'when, once')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kun', 'kun',
      (select form_name_en from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku'),
      (select why_en from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku'),
      (select meaning_en from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku'),
      (select lemma_meaning_en from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku'),
      'conjunction', 'This is the dictionary form. Speech drops the n: ku.', 'whenever, when', 'when, once';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voin', 'voin',
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to', 'approved', now(), 'content/approvals/part-6.json#my-story/form-1932b7fb8d7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voin', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voin', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Pekka', 'Kerro vähän itsestäs.',
    'Kerro vähän itsestäsi.', 'Tell me a little about yourself.',
    'my-story/1-puhe-9111eff01e87.mp3', 'my-story/1-kirja-85fe288a4ce3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kerro', (select id from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro')),
    (v_line_id, 'kirja', 2, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 3, 'itsestäsi', (select id from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs')),
    (v_line_id, 'puhe', 1, 'Kerro', (select id from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro')),
    (v_line_id, 'puhe', 2, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 3, 'itsestäs', (select id from public.forms where lemma = 'itse' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'itsestäsi' and surface_puhe = 'itsestäs'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä oon Maria ja mä oon Brasiliasta.',
    'Minä olen Maria ja minä olen Brasiliasta.', 'I''m Maria and I''m from Brazil.',
    'my-story/2-puhe-552167465b71.mp3', 'my-story/2-kirja-64ca1ae08b69.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'Maria', null),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 7, 'Brasiliasta', null),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'Maria', null),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 7, 'Brasiliasta', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Pekka', 'Missä sä asut nyt?',
    'Missä sinä asut nyt?', 'Where do you live now?',
    'my-story/3-puhe-329823fac95a.mp3', 'my-story/3-kirja-c269bc53f8b7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'asut', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut')),
    (v_line_id, 'kirja', 4, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'asut', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asut' and surface_puhe = 'asut')),
    (v_line_id, 'puhe', 4, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Kalliossa, mun miehen ja kahen lapsen kaa.',
    'Kalliossa, minun mieheni ja kahden lapseni kanssa.', 'In Kallio, with my husband and two children.',
    'my-story/4-puhe-acf584f1c897.mp3', 'my-story/4-kirja-5199b095de56.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kalliossa', (select id from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa')),
    (v_line_id, 'kirja', 2, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 3, 'mieheni', (select id from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'kahden', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen')),
    (v_line_id, 'kirja', 6, 'lapseni', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen')),
    (v_line_id, 'kirja', 7, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Kalliossa', (select id from public.forms where lemma = 'kallio' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kalliossa' and surface_puhe = 'kalliossa')),
    (v_line_id, 'puhe', 2, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 3, 'miehen', (select id from public.forms where lemma = 'mies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mieheni' and surface_puhe = 'miehen')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'kahen', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kahden' and surface_puhe = 'kahen')),
    (v_line_id, 'puhe', 6, 'lapsen', (select id from public.forms where lemma = 'lapsi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'lapseni' and surface_puhe = 'lapsen')),
    (v_line_id, 'puhe', 7, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Pekka', 'Mitä sä teet?',
    'Mitä sinä teet?', 'What do you do?',
    'my-story/5-puhe-dd211e09a6a8.mp3', 'my-story/5-kirja-03790fc1eb84.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Mä oon asiakaspalvelus, mut mä haluun olla opettaja.',
    'Minä olen asiakaspalvelussa, mutta minä haluan olla opettaja.', 'I work in customer service, but I want to be a teacher.',
    'my-story/6-puhe-33beebe322cc.mp3', 'my-story/6-kirja-e347e2c61724.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'asiakaspalvelussa', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus')),
    (v_line_id, 'kirja', 4, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 7, 'olla', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla')),
    (v_line_id, 'kirja', 8, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'asiakaspalvelus', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'asiakaspalvelussa' and surface_puhe = 'asiakaspalvelus')),
    (v_line_id, 'puhe', 4, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 7, 'olla', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'olla' and surface_puhe = 'olla')),
    (v_line_id, 'puhe', 8, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Pekka', 'Ja mitä sä tykkäät tehä?',
    'Ja mitä sinä tykkäät tehdä?', 'And what do you like doing?',
    'my-story/7-puhe-d3affad6d386.mp3', 'my-story/7-kirja-e807265d9d4d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät')),
    (v_line_id, 'kirja', 5, 'tehdä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät')),
    (v_line_id, 'puhe', 5, 'tehä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mä laulan kuoros, käyn saunas ja puhun suomee aina ku mä voin!',
    'Minä laulan kuorossa, käyn saunassa ja puhun suomea aina kun minä voin!', 'I sing in a choir, go to the sauna and speak Finnish whenever I can!',
    'my-story/8-puhe-0a058b54eb7a.mp3', 'my-story/8-kirja-bce5f9dffcf4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'laulan', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan')),
    (v_line_id, 'kirja', 3, 'kuorossa', (select id from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros')),
    (v_line_id, 'kirja', 4, 'käyn', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn')),
    (v_line_id, 'kirja', 5, 'saunassa', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas')),
    (v_line_id, 'kirja', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 7, 'puhun', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun')),
    (v_line_id, 'kirja', 8, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 9, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'kirja', 10, 'kun', (select id from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku')),
    (v_line_id, 'kirja', 11, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 12, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'laulan', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan')),
    (v_line_id, 'puhe', 3, 'kuoros', (select id from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros')),
    (v_line_id, 'puhe', 4, 'käyn', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'käyn' and surface_puhe = 'käyn')),
    (v_line_id, 'puhe', 5, 'saunas', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'saunassa' and surface_puhe = 'saunas')),
    (v_line_id, 'puhe', 6, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 7, 'puhun', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhun' and surface_puhe = 'puhun')),
    (v_line_id, 'puhe', 8, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 9, 'aina', (select id from public.forms where lemma = 'aina' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aina' and surface_puhe = 'aina')),
    (v_line_id, 'puhe', 10, 'ku', (select id from public.forms where lemma = 'kun' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kun' and surface_puhe = 'ku')),
    (v_line_id, 'puhe', 11, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 12, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#my-story/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#my-story/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
