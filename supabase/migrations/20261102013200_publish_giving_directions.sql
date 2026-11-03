-- Publishes the dialogue giving-directions (unit directions-in-the-city). Made by
-- scripts/generate/pipeline.py publish from content/drafts/giving-directions. Do not edit by hand:
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
    where slug = 'giving-directions' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'giving-directions';
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
  values (v_unit_id, 'giving-directions', 3,
    'Giving directions')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'giving-directions' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Giving directions';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'giving-directions';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-91a5cf1932b7');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-58f467b0bcb4');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauppatori', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kauppatori","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kauppa[X]kaupp[Sn][Ny]a[Bh][Bc][Ln][Ica][Xp]tori[X]tor[Sn][Ny]i","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=pppp","WORDBASES":"+kauppa(kauppa)+tori(tori)"}'::jsonb,
      'kauppatori', 'kauppatori',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-653e7f87e376');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauppatori', 'kauppatori';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauppatori', 'kauppatori',
      (select form_name_en from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori'),
      (select why_en from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori'),
      (select meaning_en from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori'),
      (select lemma_meaning_en from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mene', 'mee',
      'imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-6f4a7faac046');
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
      'illative singular', 'Suora, straight, with -an: suoraan, straight ahead.', 'straight ahead', 'straight', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-5365495a5c62');
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
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alas', 'CLASS=seikkasana', '{"BASEFORM":"alas","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]alas[X]alas","STRUCTURE":"=pppp","WORDBASES":"+alas(alas)"}'::jsonb,
      'alas', 'alas',
      'adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-96f68b98c28a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alas', 'alas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alas', 'alas',
      (select form_name_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select why_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select meaning_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select lemma_meaning_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tätä', 'tätä',
      'partitive singular', 'The partitive singular of tämä after ''en ymmärrä'': tätä.', 'this', 'this', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-6a62bc54500c');
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
      'partitive singular', 'Moving along a street takes -a: katu becomes katua. Speech turns -ua into -uu.', 'the street', 'street', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-7c153b60a55f');
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
  if not exists (select 1 from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('meri', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"meri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]meri[X]mer[Sg][Ny]en","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+meri(meri)"}'::jsonb,
      'meren', 'meren',
      'genitive singular', 'Suuntaan, ''towards'', needs -n on the word before: meri becomes meren.', 'the sea', 'sea', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-2908b8b300ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'meren', 'meri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Suuntaan, ''towards'', needs -n on the word before: meri becomes meren.', 'the sea', 'sea')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'meren', 'meri',
      (select form_name_en from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren'),
      (select why_en from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren'),
      (select meaning_en from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren'),
      (select lemma_meaning_en from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren'),
      'genitive singular', 'Suuntaan, ''towards'', needs -n on the word before: meri becomes meren.', 'the sea', 'sea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suunta', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"suunta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suunta[X]suunt[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+suunta(suunta)"}'::jsonb,
      'suuntaan', 'suuntaan',
      'illative singular', 'Adds -an for ''to'': suunta becomes suuntaan, ''in the direction''.', 'towards', 'direction', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-73ee11e51b3e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suuntaan', 'suunta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -an for ''to'': suunta becomes suuntaan, ''in the direction''.', 'towards', 'direction')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suuntaan', 'suunta',
      (select form_name_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan'),
      (select why_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan'),
      (select meaning_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan'),
      (select lemma_meaning_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan'),
      'illative singular', 'Adds -an for ''to'': suunta becomes suuntaan, ''in the direction''.', 'towards', 'direction';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tori', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tori","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]tori[X]tor[Sn][Ny]i","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tori(tori)"}'::jsonb,
      'tori', 'tori',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-245851868f4c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tori', 'tori';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tori', 'tori',
      (select form_name_en from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori'),
      (select why_en from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori'),
      (select meaning_en from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori'),
      (select lemma_meaning_en from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'market square', 'market square';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-a392b28c6a8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aivan', 'aivan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aivan', 'aivan',
      (select form_name_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select why_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select lemma_meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ranta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ranta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]ranta[X]ranna[Sade][Ny]lla","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppp","WORDBASES":"+ranta(ranta)"}'::jsonb,
      'rannalla', 'rannal',
      'adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn. Speech says rannal.', 'by the shore', 'beach, shore', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-e66e57915cef');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rannalla', 'ranta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn. Speech says rannal.', 'by the shore', 'beach, shore')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rannalla', 'ranta',
      (select form_name_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal'),
      (select why_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal'),
      (select meaning_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal'),
      (select lemma_meaning_en from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal'),
      'adessive singular', 'Adds -lla for ''on'': ranta becomes rannalla, nt turning into nn. Speech says rannal.', 'by the shore', 'beach, shore';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-35b130e20e20');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'),
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhu[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhut', 'puhut',
      'present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-9717e4376acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhut', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhut', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut'),
      'present tense, 2nd person singular', 'Puhua, to speak, with -t for ''you'': puhut.', 'you speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-26f45640039d');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suom[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomea', 'suomee',
      'partitive singular', 'The partitive adds -a after puhua, to speak: suomea. Speech turns -ea into -ee.', 'Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-68ca7e058498');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'oletko', 'oot',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Ootsä, speech says oot for olet and joins sä to it. Books write oletko sinä.', 'are you?', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-7134b249ebd4');
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
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalainen', 'suomalainen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Finnish, a Finn', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-2a904867b7d1');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-728ddce13587');
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
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"asua","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'asunut', 'asunu',
      'past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-c180a4cb7620');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asunut', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asunut', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu'),
      'past active participle, nominative singular', 'From asua, to live. After ''olen'' this form says ''have lived''. Speech drops the last t: asunu.', 'lived (I''ve lived)', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-5bdac2fbf3a8');
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
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vuosi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"vuosi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vuosi[X]vuo[Sg][Ny]den","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+vuosi(vuosi)"}'::jsonb,
      'vuoden', 'vuoden',
      'genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-7b346a8911fb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vuoden', 'vuosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vuoden', 'vuosi',
      (select form_name_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select why_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      (select lemma_meaning_en from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'),
      'genitive singular', 'A length of time takes -n: vuosi becomes vuoden, ''for a year''.', 'for a year', 'year';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"olla","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'ollut', 'ollu',
      'past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-bd1b245c90d3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ollut', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ollut', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      'past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuukausi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kuukausi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuu[X]kuu[Sn][Ny][Bh][Bc][Ln][Xp]kausi[X]kau[Sg][Ny]den","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp=pppppp","WORDBASES":"+kuu(kuu)+kausi(kausi)"}'::jsonb,
      'kuukauden', 'kuukauden',
      'genitive singular', 'A length of time takes -n: kuukausi becomes kuukauden, ''for a month''.', 'for a month', 'month', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-e27224d046a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuukauden', 'kuukausi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A length of time takes -n: kuukausi becomes kuukauden, ''for a month''.', 'for a month', 'month')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuukauden', 'kuukausi',
      (select form_name_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden'),
      (select why_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden'),
      (select meaning_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden'),
      (select lemma_meaning_en from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden'),
      'genitive singular', 'A length of time takes -n: kuukausi becomes kuukauden, ''for a month''.', 'for a month', 'month';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oppia', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"oppia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]oppia[X]opi[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+oppia(oppia)"}'::jsonb,
      'opit', 'opit',
      'present tense, 2nd person singular', 'Oppia means to learn. -t goes with sinä, and pp turns into p: opit.', 'you learn', 'to learn', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-b1f7a849d00e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opit', 'oppia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Oppia means to learn. -t goes with sinä, and pp turns into p: opit.', 'you learn', 'to learn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opit', 'oppia',
      (select form_name_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit'),
      (select why_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit'),
      (select meaning_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit'),
      (select lemma_meaning_en from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit'),
      'present tense, 2nd person singular', 'Oppia means to learn. -t goes with sinä, and pp turns into p: opit.', 'you learn', 'to learn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nopea', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive', '{"BASEFORM":"nopea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]nopea[X]nopea[Ssti]sti","SIJAMUOTO":"kerrontosti","STRUCTURE":"=pppppppp","WORDBASES":"+nopea(nopea)"}'::jsonb,
      'nopeasti', 'nopeesti',
      'adverb form (-sti)', 'Adds -sti to nopea (fast) to say how: nopeasti. Speech turns ea into ee: nopeesti.', 'fast', 'fast, quick', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-2c69b9290cf3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nopeasti', 'nopea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb form (-sti)', 'Adds -sti to nopea (fast) to say how: nopeasti. Speech turns ea into ee: nopeesti.', 'fast', 'fast, quick')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nopeasti', 'nopea',
      (select form_name_en from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti'),
      (select why_en from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti'),
      (select meaning_en from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti'),
      (select lemma_meaning_en from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti'),
      'adverb form (-sti)', 'Adds -sti to nopea (fast) to say how: nopeasti. Speech turns ea into ee: nopeesti.', 'fast', 'fast, quick';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('onni', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"onni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]onni[X]onn[Sp][Ny]ea","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+onni(onni)"}'::jsonb,
      'onnea', 'onnee',
      'partitive singular', 'The partitive in wishes: onnea matkaan, good luck. Speech turns -ea into -ee.', 'luck', 'luck, happiness', 'approved', now(), 'content/approvals/part-6.json#giving-directions/form-fb52945cb409');
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'onnea', 'onni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive in wishes: onnea matkaan, good luck. Speech turns -ea into -ee.', 'luck', 'luck, happiness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'onnea', 'onni',
      (select form_name_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee'),
      (select why_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee'),
      (select meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee'),
      (select lemma_meaning_en from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee'),
      'partitive singular', 'The partitive in wishes: onnea matkaan, good luck. Speech turns -ea into -ee.', 'luck', 'luck, happiness';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Sofia', 'Anteeks, missä on kauppatori?',
    'Anteeksi, missä on kauppatori?', 'Excuse me, where''s the market square?',
    'giving-directions/1-puhe-713eb69294da.mp3', 'giving-directions/1-kirja-33380e04fcd1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'kauppatori', (select id from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'kauppatori', (select id from public.forms where lemma = 'kauppatori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kauppatori' and surface_puhe = 'kauppatori'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mee suoraan alas tätä katuu.',
    'Mene suoraan alas tätä katua.', 'Go straight down this street.',
    'giving-directions/2-puhe-4a37ae711343.mp3', 'giving-directions/2-kirja-969d00b71414.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mene', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'kirja', 2, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan')),
    (v_line_id, 'kirja', 3, 'alas', (select id from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas')),
    (v_line_id, 'kirja', 4, 'tätä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä')),
    (v_line_id, 'kirja', 5, 'katua', (select id from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu')),
    (v_line_id, 'puhe', 1, 'Mee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'puhe', 2, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan')),
    (v_line_id, 'puhe', 3, 'alas', (select id from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas')),
    (v_line_id, 'puhe', 4, 'tätä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tätä' and surface_puhe = 'tätä')),
    (v_line_id, 'puhe', 5, 'katuu', (select id from public.forms where lemma = 'katu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'katua' and surface_puhe = 'katuu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Sofia', 'Meren suuntaan?',
    'Meren suuntaan?', 'Towards the sea?',
    'giving-directions/3-puhe-74521c954c91.mp3', 'giving-directions/3-kirja-b55cb5535719.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Meren', (select id from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren')),
    (v_line_id, 'kirja', 2, 'suuntaan', (select id from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan')),
    (v_line_id, 'puhe', 1, 'Meren', (select id from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren')),
    (v_line_id, 'puhe', 2, 'suuntaan', (select id from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'suuntaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo. Tori on ihan meren rannal.',
    'Kyllä. Tori on aivan meren rannalla.', 'Yes. The square is right by the sea.',
    'giving-directions/4-puhe-c976a86c96b3.mp3', 'giving-directions/4-kirja-dd53c222df1a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Tori', (select id from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 5, 'meren', (select id from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren')),
    (v_line_id, 'kirja', 6, 'rannalla', (select id from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Tori', (select id from public.forms where lemma = 'tori' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tori' and surface_puhe = 'tori')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 5, 'meren', (select id from public.forms where lemma = 'meri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'meren' and surface_puhe = 'meren')),
    (v_line_id, 'puhe', 6, 'rannal', (select id from public.forms where lemma = 'ranta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'rannalla' and surface_puhe = 'rannal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Sofia', 'Kiitti! Sä puhut tosi hyvin suomee. Ootsä suomalainen?',
    'Kiitos! Sinä puhut todella hyvin suomea. Oletko sinä suomalainen?', 'Thanks! You speak really good Finnish. Are you Finnish?',
    'giving-directions/5-puhe-7eb5c5a6b314.mp3', 'giving-directions/5-kirja-5bc291238c80.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'puhut', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut')),
    (v_line_id, 'kirja', 4, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 5, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 6, 'suomea', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'kirja', 7, 'Oletko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 8, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 9, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'puhut', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'puhut' and surface_puhe = 'puhut')),
    (v_line_id, 'puhe', 4, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 5, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 6, 'suomee', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'suomea' and surface_puhe = 'suomee')),
    (v_line_id, 'puhe', 7, 'Oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'oletko' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 8, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 9, 'suomalainen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalainen' and surface_puhe = 'suomalainen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'En, mä oon Brasiliasta. Mä oon asunu täällä vuoden.',
    'En, minä olen Brasiliasta. Minä olen asunut täällä vuoden.', 'No, I''m from Brazil. I''ve lived here for a year.',
    'giving-directions/6-puhe-e41f68f2c8c8.mp3', 'giving-directions/6-kirja-abec8ae6db28.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 4, 'Brasiliasta', null),
    (v_line_id, 'kirja', 5, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 7, 'asunut', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu')),
    (v_line_id, 'kirja', 8, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 9, 'vuoden', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden')),
    (v_line_id, 'puhe', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 4, 'Brasiliasta', null),
    (v_line_id, 'puhe', 5, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 7, 'asunu', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'asunut' and surface_puhe = 'asunu')),
    (v_line_id, 'puhe', 8, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 9, 'vuoden', (select id from public.forms where lemma = 'vuosi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vuoden' and surface_puhe = 'vuoden'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Sofia', 'Mä oon ollu täällä vaan kuukauden.',
    'Minä olen ollut täällä vain kuukauden.', 'I''ve only been here a month.',
    'giving-directions/7-puhe-a8afc5b59e96.mp3', 'giving-directions/7-kirja-483722ed9332.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 3, 'ollut', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu')),
    (v_line_id, 'kirja', 4, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 5, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 6, 'kuukauden', (select id from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 3, 'ollu', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 5, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 6, 'kuukauden', (select id from public.forms where lemma = 'kuukausi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kuukauden' and surface_puhe = 'kuukauden'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Sä opit nopeesti. Onnee!',
    'Sinä opit nopeasti. Onnea!', 'You''ll learn fast. Good luck!',
    'giving-directions/8-puhe-82097a5430b8.mp3', 'giving-directions/8-kirja-22109966dc1b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 2, 'opit', (select id from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit')),
    (v_line_id, 'kirja', 3, 'nopeasti', (select id from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti')),
    (v_line_id, 'kirja', 4, 'Onnea', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee')),
    (v_line_id, 'puhe', 1, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 2, 'opit', (select id from public.forms where lemma = 'oppia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opit' and surface_puhe = 'opit')),
    (v_line_id, 'puhe', 3, 'nopeesti', (select id from public.forms where lemma = 'nopea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'nopeasti' and surface_puhe = 'nopeesti')),
    (v_line_id, 'puhe', 4, 'Onnee', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'onnea' and surface_puhe = 'onnee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#giving-directions/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#giving-directions/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
