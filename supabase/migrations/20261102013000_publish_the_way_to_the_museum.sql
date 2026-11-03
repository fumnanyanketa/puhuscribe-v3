-- Publishes the dialogue the-way-to-the-museum (unit directions-in-the-city). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-way-to-the-museum. Do not edit by hand:
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
    where slug = 'the-way-to-the-museum' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-way-to-the-museum';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 31
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'directions-in-the-city' and position = 31 and stop_number = 31;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'directions-in-the-city';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'the-way-to-the-museum', 1,
    'The way to the museum')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-way-to-the-museum' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'The way to the museum';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-way-to-the-museum';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-91a5cf1932b7');
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
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('miten', 'CLASS=seikkasana', '{"BASEFORM":"miten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]miten[X]miten","STRUCTURE":"=ppppp","WORDBASES":"+miten(miten)"}'::jsonb,
      'miten', 'miten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-34eb915c255e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miten', 'miten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miten', 'miten',
      (select form_name_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select why_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select lemma_meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"päästä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]päästä[X]pääse[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+päästä(päästä)"}'::jsonb,
      'pääsen', 'pääsen',
      'present tense, 1st person singular', 'Päästä, to get somewhere, with -n for ''I'': pääsen.', 'I get (there)', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-ba15b2fde78d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pääsen', 'päästä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Päästä, to get somewhere, with -n for ''I'': pääsen.', 'I get (there)', 'to get (somewhere), to get in')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pääsen', 'päästä',
      (select form_name_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen'),
      (select why_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen'),
      (select meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen'),
      (select lemma_meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen'),
      'present tense, 1st person singular', 'Päästä, to get somewhere, with -n for ''I'': pääsen.', 'I get (there)', 'to get (somewhere), to get in';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mene', 'mee',
      'imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-6f4a7faac046');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mene', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mene', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      'imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suora', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suora","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suora[X]suor[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+suora(suora)"}'::jsonb,
      'suoraan', 'suoraan',
      'illative singular', 'Suora, straight, with -an: suoraan, straight ahead.', 'straight ahead', 'straight', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-5365495a5c62');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suoraan', 'suora';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Suora, straight, with -an: suoraan, straight ahead.', 'straight ahead', 'straight')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suoraan', 'suora',
      (select form_name_en from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan'),
      (select why_en from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan'),
      (select meaning_en from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan'),
      (select lemma_meaning_en from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan'),
      'illative singular', 'Suora, straight, with -an: suoraan, straight ahead.', 'straight ahead', 'straight';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tätä', 'tätä',
      'partitive singular', 'The partitive singular of tämä after ''en ymmärrä'': tätä.', 'this', 'this', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-6a62bc54500c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tätä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular of tämä after ''en ymmärrä'': tätä.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tätä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä'),
      'partitive singular', 'The partitive singular of tämä after ''en ymmärrä'': tätä.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('katu', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"katu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]katu[X]katu[Sp][Ny]a","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+katu(katu)"}'::jsonb,
      'katua', 'katuu',
      'partitive singular', 'Moving along a street takes -a: katu becomes katua. Speech turns -ua into -uu.', 'the street', 'street', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-7c153b60a55f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'katua', 'katu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Moving along a street takes -a: katu becomes katua. Speech turns -ua into -uu.', 'the street', 'street')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'katua', 'katu',
      (select form_name_en from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'),
      (select why_en from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'),
      (select meaning_en from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'),
      (select lemma_meaning_en from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'),
      'partitive singular', 'Moving along a street takes -a: katu becomes katua. Speech turns -ua into -uu.', 'the street', 'street';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitkä', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"pitkä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]pitkä[X]pitkä[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppp","WORDBASES":"+pitkä(pitkä)"}'::jsonb,
      'pitkälle', 'pitkälle',
      'allative singular', 'Adds -lle for ''to'' a point: pitkä, ''long'', becomes pitkälle, ''how far''.', 'far', 'long, tall', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-fe337beeeafe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitkälle', 'pitkä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''to'' a point: pitkä, ''long'', becomes pitkälle, ''how far''.', 'far', 'long, tall')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitkälle', 'pitkä',
      (select form_name_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle'),
      (select why_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle'),
      (select meaning_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle'),
      (select lemma_meaning_en from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle'),
      'allative singular', 'Adds -lle for ''to'' a point: pitkä, ''long'', becomes pitkälle, ''how far''.', 'far', 'long, tall';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('toinen', 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"toinen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]toinen[X]toi[Sill][Ny]seen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+toinen(toinen)"}'::jsonb,
      'toiseen', 'toiseen',
      'illative singular', 'Adds -en for ''to'': toinen becomes toiseen, to match risteykseen.', 'to the second', 'second, other', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-88d9fe3c1ea1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'toiseen', 'toinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -en for ''to'': toinen becomes toiseen, to match risteykseen.', 'to the second', 'second, other')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'toiseen', 'toinen',
      (select form_name_en from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen'),
      (select why_en from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen'),
      (select meaning_en from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen'),
      (select lemma_meaning_en from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen'),
      'illative singular', 'Adds -en for ''to'': toinen becomes toiseen, to match risteykseen.', 'to the second', 'second, other';
  end if;
  if not exists (select 1 from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('risteys', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"risteys","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]risteys[X]ristey[Sill][Ny]kseen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppppppp","WORDBASES":"+risteys(risteys)"}'::jsonb,
      'risteykseen', 'risteykseen',
      'illative singular', 'Adds -en for ''to'': risteys becomes risteykseen.', 'to the crossing', 'crossing, junction', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-79342e863f13');
  end if;
  if not exists (select 1 from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'risteykseen', 'risteys';
  end if;
  if not exists (select 1 from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -en for ''to'': risteys becomes risteykseen.', 'to the crossing', 'crossing, junction')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'risteykseen', 'risteys',
      (select form_name_en from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen'),
      (select why_en from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen'),
      (select meaning_en from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen'),
      (select lemma_meaning_en from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen'),
      'illative singular', 'Adds -en for ''to'': risteys becomes risteykseen.', 'to the crossing', 'crossing, junction';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asti', 'CLASS=suhdesana', '{"BASEFORM":"asti","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]asti[X]asti","STRUCTURE":"=pppp","WORDBASES":"+asti(asti)"}'::jsonb,
      'asti', 'asti',
      'adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-58ae00563058');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asti', 'asti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asti', 'asti',
      (select form_name_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select why_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select meaning_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select lemma_meaning_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      'adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kääntyä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kääntyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kääntyä[X]käänny[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+kääntyä(kääntyä)"}'::jsonb,
      'käänny', 'käänny',
      'imperative present tense, 2nd person singular', 'Kääntyä, to turn. To tell one person to turn, use käänny: the nt becomes nn.', 'turn', 'to turn', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-bcbc840c68eb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käänny', 'kääntyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Kääntyä, to turn. To tell one person to turn, use käänny: the nt becomes nn.', 'turn', 'to turn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käänny', 'kääntyä',
      (select form_name_en from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny'),
      (select why_en from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny'),
      (select meaning_en from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny'),
      (select lemma_meaning_en from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny'),
      'imperative present tense, 2nd person singular', 'Kääntyä, to turn. To tell one person to turn, use käänny: the nt becomes nn.', 'turn', 'to turn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vasen', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vasen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vasen[X]vasemma[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppppp","WORDBASES":"+vasen(vasen)"}'::jsonb,
      'vasemmalle', 'vasemmalle',
      'allative singular', 'Adds -lle for direction: vasen becomes vasemmalle, ''to the left''.', 'to the left', 'left', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-fdbe75f7a0bd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vasemmalle', 'vasen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for direction: vasen becomes vasemmalle, ''to the left''.', 'to the left', 'left')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vasemmalle', 'vasen',
      (select form_name_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle'),
      (select why_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle'),
      (select meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle'),
      (select lemma_meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle'),
      'allative singular', 'Adds -lle for direction: vasen becomes vasemmalle, ''to the left''.', 'to the left', 'left';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oikea', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"oikea","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]oikea[X]oikea[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+oikea(oikea)"}'::jsonb,
      'oikealla', 'oikeel',
      'adessive singular', 'Adds -lla for ''on'': oikea becomes oikealla. Speech says oikeel.', 'on the right', 'right, correct', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-12f3eabb7de9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oikealla', 'oikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''on'': oikea becomes oikealla. Speech says oikeel.', 'on the right', 'right, correct')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oikealla', 'oikea',
      (select form_name_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel'),
      (select why_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel'),
      (select meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel'),
      (select lemma_meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel'),
      'adessive singular', 'Adds -lla for ''on'': oikea becomes oikealla. Speech says oikeel.', 'on the right', 'right, correct';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puole[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puolella', 'puolel',
      'adessive singular', 'Adds -lla for ''on'': puoli becomes puolella. Speech shortens -lla to -l: puolella becomes puolel.', 'side', 'half, side', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-9b2e89310018');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puolella', 'puoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''on'': puoli becomes puolella. Speech shortens -lla to -l: puolella becomes puolel.', 'side', 'half, side')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puolella', 'puoli',
      (select form_name_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel'),
      (select why_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel'),
      (select meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel'),
      (select lemma_meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel'),
      'adessive singular', 'Adds -lla for ''on'': puoli becomes puolella. Speech shortens -lla to -l: puolella becomes puolel.', 'side', 'half, side';
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('rautatieasema', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"rautatieasema","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]rauta[X]raut[Sn][Ny]a[Bh][Bc][Ln][Ica][Xp]tie[X]tie[Sn][Ny][Bh][Bc][Ln][Xp]asema[X]asem[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=ppp=pppppp","WORDBASES":"+rauta(rauta)+tie(tie)+asema(asema)"}'::jsonb,
      'rautatieaseman', 'rautatieaseman',
      'genitive singular', 'Vieressä, ''next to'', needs -n on the word before: rautatieasema becomes rautatieaseman.', 'the railway station', 'railway station', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-953705540742');
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rautatieaseman', 'rautatieasema';
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Vieressä, ''next to'', needs -n on the word before: rautatieasema becomes rautatieaseman.', 'the railway station', 'railway station')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rautatieaseman', 'rautatieasema',
      (select form_name_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman'),
      (select why_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman'),
      (select meaning_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman'),
      (select lemma_meaning_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman'),
      'genitive singular', 'Vieressä, ''next to'', needs -n on the word before: rautatieasema becomes rautatieaseman.', 'the railway station', 'railway station';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vieri', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"vieri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vieri[X]viere[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+vieri(vieri)"}'::jsonb,
      'vieressä', 'vieres',
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-a54598413b94');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vieressä', 'vieri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vieressä', 'vieri',
      (select form_name_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select why_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select lemma_meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauas', 'CLASS=seikkasana', '{"BASEFORM":"kauas","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauas[X]kaukana","STRUCTURE":"=ppppppp","WORDBASES":"+kauas(kauas)"}'::jsonb,
      'kaukana', 'kaukana',
      'adverb', 'Kaukana means far away, at a distance.', 'far', 'far (away)', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-c31870137cbc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaukana', 'kauas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Kaukana means far away, at a distance.', 'far', 'far (away)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaukana', 'kauas',
      (select form_name_en from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana'),
      (select why_en from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana'),
      (select meaning_en from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana'),
      (select lemma_meaning_en from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana'),
      'adverb', 'Kaukana means far away, at a distance.', 'far', 'far (away)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kymmenen', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kymmenen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Sn][Ny][Xp]kymmenen[X]kymmenen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+kymmenen(kymmenen)"}'::jsonb,
      'kymmenen', 'kymmenen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ten', 'ten', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-0fc03492889e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kymmenen', 'kymmenen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'ten', 'ten')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kymmenen', 'kymmenen',
      (select form_name_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen'),
      (select why_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen'),
      (select meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen'),
      (select lemma_meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ten', 'ten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minuutti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"minuutti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]minuutti[X]minuutt[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+minuutti(minuutti)"}'::jsonb,
      'minuuttia', 'minuuttii',
      'partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-2ba98cc25249');
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
  if not exists (select 1 from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kävellä', 'CLASS=teonsana;MOOD=E-infinitive', '{"BASEFORM":"kävellä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kävellä[X]kävell[Tn2]en","MOOD":"E-infinitive","STRUCTURE":"=pppppppp","WORDBASES":"+kävellä(kävellä)"}'::jsonb,
      'kävellen', 'kävellen',
      'E-infinitive', 'Kävellä means to walk. The ending -en means ''by walking'': kävellen.', 'on foot', 'to walk', 'approved', now(), 'content/approvals/part-6.json#the-way-to-the-museum/form-3466a7928f96');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kävellen', 'kävellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('E-infinitive', 'Kävellä means to walk. The ending -en means ''by walking'': kävellen.', 'on foot', 'to walk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kävellen', 'kävellä',
      (select form_name_en from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen'),
      (select why_en from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen'),
      (select meaning_en from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen'),
      (select lemma_meaning_en from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen'),
      'E-infinitive', 'Kävellä means to walk. The ending -en means ''by walking'': kävellen.', 'on foot', 'to walk';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Anteeks, miten mä pääsen Ateneumiin?',
    'Anteeksi, miten minä pääsen Ateneumiin?', 'Excuse me, how do I get to the Ateneum?',
    'the-way-to-the-museum/1-puhe-2e4868354f2d.mp3', 'the-way-to-the-museum/1-kirja-0519a5795ab1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'pääsen', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen')),
    (v_line_id, 'kirja', 5, 'Ateneumiin', null),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'pääsen', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pääsen' and surface_puhe = 'pääsen')),
    (v_line_id, 'puhe', 5, 'Ateneumiin', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Pasi', 'Mee suoraan tätä katuu.',
    'Mene suoraan tätä katua.', 'Go straight along this street.',
    'the-way-to-the-museum/2-puhe-6315feb4ba08.mp3', 'the-way-to-the-museum/2-kirja-a08ffd6d9ef5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mene', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'kirja', 2, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan')),
    (v_line_id, 'kirja', 3, 'tätä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä')),
    (v_line_id, 'kirja', 4, 'katua', (select id from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu')),
    (v_line_id, 'puhe', 1, 'Mee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'puhe', 2, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan')),
    (v_line_id, 'puhe', 3, 'tätä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä')),
    (v_line_id, 'puhe', 4, 'katuu', (select id from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Kuinka pitkälle?',
    'Kuinka pitkälle?', 'How far?',
    'the-way-to-the-museum/3-puhe-71dda4c96ede.mp3', 'the-way-to-the-museum/3-kirja-2f63a023ae96.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'pitkälle', (select id from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'pitkälle', (select id from public.forms where lemma = 'pitkä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pitkälle' and surface_puhe = 'pitkälle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Pasi', 'Toiseen risteykseen asti. Sit käänny vasemmalle.',
    'Toiseen risteykseen asti. Sitten käänny vasemmalle.', 'To the second crossing. Then turn left.',
    'the-way-to-the-museum/4-puhe-f84cadf05582.mp3', 'the-way-to-the-museum/4-kirja-bbcdae5d2be6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Toiseen', (select id from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen')),
    (v_line_id, 'kirja', 2, 'risteykseen', (select id from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen')),
    (v_line_id, 'kirja', 3, 'asti', (select id from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti')),
    (v_line_id, 'kirja', 4, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 5, 'käänny', (select id from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny')),
    (v_line_id, 'kirja', 6, 'vasemmalle', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle')),
    (v_line_id, 'puhe', 1, 'Toiseen', (select id from public.forms where lemma = 'toinen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'toiseen' and surface_puhe = 'toiseen')),
    (v_line_id, 'puhe', 2, 'risteykseen', (select id from public.forms where lemma = 'risteys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'risteykseen' and surface_puhe = 'risteykseen')),
    (v_line_id, 'puhe', 3, 'asti', (select id from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti')),
    (v_line_id, 'puhe', 4, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 5, 'käänny', (select id from public.forms where lemma = 'kääntyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käänny' and surface_puhe = 'käänny')),
    (v_line_id, 'puhe', 6, 'vasemmalle', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Vasemmalle, okei. Ja sit?',
    'Vasemmalle, selvä. Ja sitten?', 'Left, OK. And then?',
    'the-way-to-the-museum/5-puhe-05cce26484bf.mp3', 'the-way-to-the-museum/5-kirja-3c1b0cba22ca.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vasemmalle', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle')),
    (v_line_id, 'kirja', 2, 'selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 1, 'Vasemmalle', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalle' and surface_puhe = 'vasemmalle')),
    (v_line_id, 'puhe', 2, 'okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Pasi', 'Ateneum on oikeel puolel, rautatieaseman vieres.',
    'Ateneum on oikealla puolella, rautatieaseman vieressä.', 'The Ateneum is on the right, next to the railway station.',
    'the-way-to-the-museum/6-puhe-d46496cc2935.mp3', 'the-way-to-the-museum/6-kirja-53a032d2eda2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ateneum', null),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'oikealla', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel')),
    (v_line_id, 'kirja', 4, 'puolella', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel')),
    (v_line_id, 'kirja', 5, 'rautatieaseman', (select id from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman')),
    (v_line_id, 'kirja', 6, 'vieressä', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres')),
    (v_line_id, 'puhe', 1, 'Ateneum', null),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'oikeel', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealla' and surface_puhe = 'oikeel')),
    (v_line_id, 'puhe', 4, 'puolel', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'puolella' and surface_puhe = 'puolel')),
    (v_line_id, 'puhe', 5, 'rautatieaseman', (select id from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'rautatieaseman' and surface_puhe = 'rautatieaseman')),
    (v_line_id, 'puhe', 6, 'vieres', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Onks se kaukana?',
    'Onko se kaukana?', 'Is it far?',
    'the-way-to-the-museum/7-puhe-384e571d3496.mp3', 'the-way-to-the-museum/7-kirja-1186027d37ee.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'kaukana', (select id from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'kaukana', (select id from public.forms where lemma = 'kauas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kaukana' and surface_puhe = 'kaukana'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Pasi', 'Ei, kymmenen minuuttii kävellen.',
    'Ei, kymmenen minuuttia kävellen.', 'No, ten minutes on foot.',
    'the-way-to-the-museum/8-puhe-27c6abb153a4.mp3', 'the-way-to-the-museum/8-kirja-0a323c0dc7f4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'kymmenen', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen')),
    (v_line_id, 'kirja', 3, 'minuuttia', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'kirja', 4, 'kävellen', (select id from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'kymmenen', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen')),
    (v_line_id, 'puhe', 3, 'minuuttii', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'puhe', 4, 'kävellen', (select id from public.forms where lemma = 'kävellä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'kävellen' and surface_puhe = 'kävellen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#the-way-to-the-museum/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
