-- Publishes the dialogue a-job-interview (unit my-work-and-skills). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-job-interview. Do not edit by hand:
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
    where slug = 'a-job-interview' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-job-interview';
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
  values (v_unit_id, 'a-job-interview', 2,
    'A job interview')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-job-interview' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'A job interview';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-job-interview';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'kertoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kerro' and surface_puhe = 'kerro') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kertoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kertoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kertoa[X]kerro[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+kertoa(kertoa)"}'::jsonb,
      'kerro', 'kerro',
      'imperative present tense, 2nd person singular', 'Kertoa means to tell. Dropping the last -a gives kerro, telling someone to do it.', 'tell', 'to tell', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-6971cd022ac8');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-008b8a3eae32');
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
      'elative singular, with the possessive ending for your', 'Itse with -stä and -si for ''your'': itsestäsi. Speech drops the last i: itsestäs.', 'of yourself', 'self', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-394bcb54aac4');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-728ddce13587');
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
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaja', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"opettaja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Ln][Xj]ja[X][Sn][Ny]ja","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+opetta(opettaa)+ja(+ja)"}'::jsonb,
      'opettaja', 'opettaja',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'teacher', 'teacher', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-6a35f7e46946');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"osata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]osata[X]osaa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+osata(osata)"}'::jsonb,
      'osaan', 'osaan',
      'present tense, 1st person singular', 'Osata, to know how. With minä: osaan. Osata kieltä means to speak a language.', 'I know (a language)', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-a02f1650e73a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osaan', 'osata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Osata, to know how. With minä: osaan. Osata kieltä means to speak a language.', 'I know (a language)', 'to know how to, can')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osaan', 'osata',
      (select form_name_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan'),
      (select why_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan'),
      (select meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan'),
      (select lemma_meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan'),
      'present tense, 1st person singular', 'Osata, to know how. With minä: osaan. Osata kieltä means to speak a language.', 'I know (a language)', 'to know how to, can';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljää', 'neljää',
      'partitive singular', 'Osata, ''know'', takes -ä here: neljä becomes neljää.', 'four', 'four', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-10227e9ce36b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neljää', 'neljä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Osata, ''know'', takes -ä here: neljä becomes neljää.', 'four', 'four')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neljää', 'neljä',
      (select form_name_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää'),
      (select why_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää'),
      (select meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää'),
      (select lemma_meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää'),
      'partitive singular', 'Osata, ''know'', takes -ä here: neljä becomes neljää.', 'four', 'four';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kieli', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kieli[X]kiel[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kieli(kieli)"}'::jsonb,
      'kieltä', 'kieltä',
      'partitive singular', 'After a number like kaksi, the word takes -tä: kieli becomes kieltä, ''two languages''.', 'languages (after a number)', 'language, tongue', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-367b63e1fdea');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kieltä', 'kieli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number like kaksi, the word takes -tä: kieli becomes kieltä, ''two languages''.', 'languages (after a number)', 'language, tongue')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kieltä', 'kieli',
      (select form_name_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä'),
      (select why_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä'),
      (select meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä'),
      (select lemma_meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä'),
      'partitive singular', 'After a number like kaksi, the word takes -tä: kieli becomes kieltä, ''two languages''.', 'languages (after a number)', 'language, tongue';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kieli', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"kieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kieli[X]kiel[Sp][Nm]iä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kieli(kieli)"}'::jsonb,
      'kieliä', 'kieliä',
      'partitive plural', 'Plural ''some'' takes -iä: kieli becomes kieliä.', 'languages', 'language, tongue', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-f654a47c533c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kieliä', 'kieli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -iä: kieli becomes kieliä.', 'languages', 'language, tongue')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kieliä', 'kieli',
      (select form_name_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä'),
      (select why_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä'),
      (select meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä'),
      (select lemma_meaning_en from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä'),
      'partitive plural', 'Plural ''some'' takes -iä: kieli becomes kieliä.', 'languages', 'language, tongue';
  end if;
  if not exists (select 1 from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('portugali', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"portugali","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]portugali[X]portugal[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppp","WORDBASES":"+portugali(portugali)"}'::jsonb,
      'portugalia', 'portugalia',
      'partitive singular', 'After puhua (to speak), a language takes -a: portugali becomes portugalia.', 'Portuguese', 'Portuguese (the language)', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-36ec387e2b61');
  end if;
  if not exists (select 1 from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'portugalia', 'portugali';
  end if;
  if not exists (select 1 from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After puhua (to speak), a language takes -a: portugali becomes portugalia.', 'Portuguese', 'Portuguese (the language)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'portugalia', 'portugali',
      (select form_name_en from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia'),
      (select why_en from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia'),
      (select meaning_en from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia'),
      (select lemma_meaning_en from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia'),
      'partitive singular', 'After puhua (to speak), a language takes -a: portugali becomes portugalia.', 'Portuguese', 'Portuguese (the language)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('englanti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"englanti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]englanti[X]englant[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+englanti(englanti)"}'::jsonb,
      'englantia', 'englantii',
      'partitive singular', 'The partitive adds -a after puhua, to speak: englantia. Speech turns -ia into -ii.', 'English', 'English (the language), England', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-7c5091e0c295');
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
  if not exists (select 1 from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('espanja', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"espanja","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]espanja[X]espanja[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+espanja(espanja)"}'::jsonb,
      'espanjaa', 'espanjaa',
      'partitive singular', 'Knowing a language takes -a: espanja becomes espanjaa.', 'Spanish', 'Spanish (the language), Spain', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-ab1005e5e316');
  end if;
  if not exists (select 1 from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'espanjaa', 'espanja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Knowing a language takes -a: espanja becomes espanjaa.', 'Spanish', 'Spanish (the language), Spain')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'espanjaa', 'espanja',
      (select form_name_en from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa'),
      (select why_en from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa'),
      (select meaning_en from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa'),
      (select lemma_meaning_en from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa'),
      'partitive singular', 'Knowing a language takes -a: espanja becomes espanjaa.', 'Spanish', 'Spanish (the language), Spain';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-68ca7e058498');
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
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hieno', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hieno","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hieno[X]hieno[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+hieno(hieno)"}'::jsonb,
      'hienoa', 'hienoo',
      'partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-2cd8ef2f37d5');
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
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"osata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]osata[X]osaa[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+osata(osata)"}'::jsonb,
      'osaatko', 'osaat',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Osata means to know how. -t goes with sinä. Speech says osaatsä instead of -ko.', 'can you', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-0e5d59cdb03a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osaatko', 'osata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Osata means to know how. -t goes with sinä. Speech says osaatsä instead of -ko.', 'can you', 'to know how to, can')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osaatko', 'osata',
      (select form_name_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat'),
      (select why_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat'),
      (select meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat'),
      (select lemma_meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Osata means to know how. -t goes with sinä. Speech says osaatsä instead of -ko.', 'can you', 'to know how to, can';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käyttää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"käyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käyttää[X]käyttä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+käyttää(käyttää)"}'::jsonb,
      'käyttää', 'käyttää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to use', 'to use', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-b3023dddc4dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käyttää', 'käyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to use', 'to use')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käyttää', 'käyttää',
      (select form_name_en from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää'),
      (select why_en from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää'),
      (select meaning_en from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää'),
      (select lemma_meaning_en from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to use', 'to use';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietokone', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tietokone","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tieto[X]tieto[Sn][Ny][Bh][Bc][Ln][Xp]kone[X]kone[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+tieto(tieto)+kone(kone)"}'::jsonb,
      'tietokonetta', 'tietokonetta',
      'partitive singular', 'Käyttää, ''use'', takes -tta here: tietokone becomes tietokonetta.', 'a computer', 'computer', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-e41e49d0774c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tietokonetta', 'tietokone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Käyttää, ''use'', takes -tta here: tietokone becomes tietokonetta.', 'a computer', 'computer')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tietokonetta', 'tietokone',
      (select form_name_en from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta'),
      (select why_en from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta'),
      (select meaning_en from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta'),
      (select lemma_meaning_en from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta'),
      'partitive singular', 'Käyttää, ''use'', takes -tta here: tietokone becomes tietokonetta.', 'a computer', 'computer';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työskennellä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"työskennellä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]työskennellä[X]työskennell[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppppppppp","WORDBASES":"+työskennellä(työskennellä)"}'::jsonb,
      'työskennellä', 'työskennellä',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to work', 'to work', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-9e988535e9cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työskennellä', 'työskennellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to work', 'to work')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työskennellä', 'työskennellä',
      (select form_name_en from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä'),
      (select why_en from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä'),
      (select meaning_en from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä'),
      (select lemma_meaning_en from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to work', 'to work';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiimi', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tiimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tiimi[X]tiimi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+tiimi(tiimi)"}'::jsonb,
      'tiimissä', 'tiimis',
      'inessive singular', 'Adds -ssä for ''in'': tiimi becomes tiimissä. Speech shortens -ssä to -s: tiimissä becomes tiimis.', 'in a team', 'team', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-c5bf45063f6f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiimissä', 'tiimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssä for ''in'': tiimi becomes tiimissä. Speech shortens -ssä to -s: tiimissä becomes tiimis.', 'in a team', 'team')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiimissä', 'tiimi',
      (select form_name_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis'),
      (select why_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis'),
      (select meaning_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis'),
      (select lemma_meaning_en from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis'),
      'inessive singular', 'Adds -ssä for ''in'': tiimi becomes tiimissä. Speech shortens -ssä to -s: tiimissä becomes tiimis.', 'in a team', 'team';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'miksi', 'miks',
      'translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-d708d830ae73');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miksi', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miksi', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      'translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluat', 'haluut',
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-5d3db9de3844');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluat', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluat', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sg][Ny]män","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämän', 'tän',
      'genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-0b0b417b5640');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tämän', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tämän', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      'genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]työ[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'työn', 'työn',
      'genitive singular', 'A whole thing wanted takes -n: työ becomes työn.', 'the job', 'work, job', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-227700e8e556');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työn', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A whole thing wanted takes -n: työ becomes työn.', 'the job', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työn', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn'),
      'genitive singular', 'A whole thing wanted takes -n: työ becomes työn.', 'the job', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkään', 'tykkään',
      'present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-140f37ece90d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkään', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkään', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään'),
      'present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('auttaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"auttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]auttaa[X]autta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+auttaa(auttaa)"}'::jsonb,
      'auttaa', 'auttaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-b4a17f5a61be');
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'auttaa', 'auttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'auttaa', 'auttaa',
      (select form_name_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select why_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select meaning_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select lemma_meaning_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihminen', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"ihminen","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ihminen[X]ihmi[Sp][Nm]siä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+ihminen(ihminen)"}'::jsonb,
      'ihmisiä', 'ihmisii',
      'partitive plural', 'The partitive for many: ihminen becomes ihmisiä. Speech turns -iä into -ii.', 'people', 'person, human', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-b81e45bf69a4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihmisiä', 'ihminen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive for many: ihminen becomes ihmisiä. Speech turns -iä into -ii.', 'people', 'person, human')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihmisiä', 'ihminen',
      (select form_name_en from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii'),
      (select why_en from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii'),
      (select meaning_en from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii'),
      (select lemma_meaning_en from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii'),
      'partitive plural', 'The partitive for many: ihminen becomes ihmisiä. Speech turns -iä into -ii.', 'people', 'person, human';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oppia', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"oppia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]oppia[X]oppi[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+oppia(oppia)"}'::jsonb,
      'oppia', 'oppii',
      'basic form (A-infinitive)', 'This is the dictionary form, used after tykkään, ''I like''. Speech turns the ending -ia into -ii.', 'to learn', 'to learn', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-6f4dc7f0f210');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oppia', 'oppia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, used after tykkään, ''I like''. Speech turns the ending -ia into -ii.', 'to learn', 'to learn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oppia', 'oppia',
      (select form_name_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii'),
      (select why_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii'),
      (select meaning_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii'),
      (select lemma_meaning_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii'),
      'basic form (A-infinitive)', 'This is the dictionary form, used after tykkään, ''I like''. Speech turns the ending -ia into -ii.', 'to learn', 'to learn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uutta', 'uutta',
      'partitive singular', 'Learning some of something takes -tta: uusi becomes uutta.', 'new things', 'new', 'approved', now(), 'content/approvals/part-6.json#a-job-interview/form-0edce537f160');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uutta', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Learning some of something takes -tta: uusi becomes uutta.', 'new things', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uutta', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta'),
      'partitive singular', 'Learning some of something takes -tta: uusi becomes uutta.', 'new things', 'new';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Kirsi', 'Kerro vähän itsestäs.',
    'Kerro vähän itsestäsi.', 'Tell me a little about yourself.',
    'a-job-interview/1-puhe-9346dd73bab4.mp3', 'a-job-interview/1-kirja-d8495ce151de.mp3')
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
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä oon Maria. Mä oon opettaja ja mä osaan neljää kieltä.',
    'Minä olen Maria. Minä olen opettaja ja minä osaan neljää kieltä.', 'I''m Maria. I''m a teacher and I speak four languages.',
    'a-job-interview/2-puhe-86dd97e33e39.mp3', 'a-job-interview/2-kirja-63474df8fed5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'Maria', null),
    (v_line_id, 'kirja', 4, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 5, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 6, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja')),
    (v_line_id, 'kirja', 7, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 8, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 9, 'osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'kirja', 10, 'neljää', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää')),
    (v_line_id, 'kirja', 11, 'kieltä', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'Maria', null),
    (v_line_id, 'puhe', 4, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 5, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 6, 'opettaja', (select id from public.forms where lemma = 'opettaja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'opettaja' and surface_puhe = 'opettaja')),
    (v_line_id, 'puhe', 7, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 8, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 9, 'osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'puhe', 10, 'neljää', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neljää' and surface_puhe = 'neljää')),
    (v_line_id, 'puhe', 11, 'kieltä', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kieltä' and surface_puhe = 'kieltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Kirsi', 'Mitä kieliä?',
    'Mitä kieliä?', 'Which languages?',
    'a-job-interview/3-puhe-8a41a3a3e8a6.mp3', 'a-job-interview/3-kirja-fad835defc89.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'kieliä', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'kieliä', (select id from public.forms where lemma = 'kieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'kieliä' and surface_puhe = 'kieliä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Portugalia, englantii, espanjaa ja vähän suomee.',
    'Portugalia, englantia, espanjaa ja vähän suomea.', 'Portuguese, English, Spanish and a little Finnish.',
    'a-job-interview/4-puhe-6a81a05ad6b2.mp3', 'a-job-interview/4-kirja-a3448b4ccc59.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Portugalia', (select id from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia')),
    (v_line_id, 'kirja', 2, 'englantia', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii')),
    (v_line_id, 'kirja', 3, 'espanjaa', (select id from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 6, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 1, 'Portugalia', (select id from public.forms where lemma = 'portugali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'portugalia' and surface_puhe = 'portugalia')),
    (v_line_id, 'puhe', 2, 'englantii', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'englantia' and surface_puhe = 'englantii')),
    (v_line_id, 'puhe', 3, 'espanjaa', (select id from public.forms where lemma = 'espanja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'espanjaa' and surface_puhe = 'espanjaa')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 6, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Kirsi', 'Hienoo. Osaatsä käyttää tietokonetta hyvin?',
    'Hienoa. Osaatko sinä käyttää tietokonetta hyvin?', 'Great. Can you use a computer well?',
    'a-job-interview/5-puhe-bf920de66183.mp3', 'a-job-interview/5-kirja-3422b0e0aabf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hienoa', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'kirja', 2, 'Osaatko', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'käyttää', (select id from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää')),
    (v_line_id, 'kirja', 5, 'tietokonetta', (select id from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta')),
    (v_line_id, 'kirja', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Hienoo', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'puhe', 2, 'Osaat', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'käyttää', (select id from public.forms where lemma = 'käyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'käyttää' and surface_puhe = 'käyttää')),
    (v_line_id, 'puhe', 5, 'tietokonetta', (select id from public.forms where lemma = 'tietokone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tietokonetta' and surface_puhe = 'tietokonetta')),
    (v_line_id, 'puhe', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo. Ja mä osaan työskennellä tiimis.',
    'Kyllä. Ja minä osaan työskennellä tiimissä.', 'Yes. And I can work in a team.',
    'a-job-interview/6-puhe-d0b8775e3d64.mp3', 'a-job-interview/6-kirja-d0aa9967d5f7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'kirja', 5, 'työskennellä', (select id from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä')),
    (v_line_id, 'kirja', 6, 'tiimissä', (select id from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'puhe', 5, 'työskennellä', (select id from public.forms where lemma = 'työskennellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'työskennellä' and surface_puhe = 'työskennellä')),
    (v_line_id, 'puhe', 6, 'tiimis', (select id from public.forms where lemma = 'tiimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tiimissä' and surface_puhe = 'tiimis'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Kirsi', 'Miks sä haluut tän työn?',
    'Miksi sinä haluat tämän työn?', 'Why do you want this job?',
    'a-job-interview/7-puhe-55f443cb856c.mp3', 'a-job-interview/7-kirja-eafa4cad5a94.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Miksi', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'haluat', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut')),
    (v_line_id, 'kirja', 4, 'tämän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän')),
    (v_line_id, 'kirja', 5, 'työn', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn')),
    (v_line_id, 'puhe', 1, 'Miks', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'haluut', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut')),
    (v_line_id, 'puhe', 4, 'tän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän')),
    (v_line_id, 'puhe', 5, 'työn', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työn' and surface_puhe = 'työn'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mä tykkään auttaa ihmisii ja oppii uutta.',
    'Minä tykkään auttaa ihmisiä ja oppia uutta.', 'I like helping people and learning new things.',
    'a-job-interview/8-puhe-094067d2532c.mp3', 'a-job-interview/8-kirja-343cfc719133.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 3, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'kirja', 4, 'ihmisiä', (select id from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'oppia', (select id from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii')),
    (v_line_id, 'kirja', 7, 'uutta', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 3, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'puhe', 4, 'ihmisii', (select id from public.forms where lemma = 'ihminen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'ihmisiä' and surface_puhe = 'ihmisii')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'oppii', (select id from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'oppia' and surface_puhe = 'oppii')),
    (v_line_id, 'puhe', 7, 'uutta', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uutta' and surface_puhe = 'uutta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-job-interview/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
