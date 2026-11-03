-- Publishes the dialogue a-mistake-on-the-bill (unit problems-and-returns). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-mistake-on-the-bill. Do not edit by hand:
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
    where slug = 'a-mistake-on-the-bill' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-mistake-on-the-bill';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 32
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'problems-and-returns' and position = 32 and stop_number = 32;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'problems-and-returns';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-mistake-on-the-bill', 2,
    'A mistake on the bill')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-mistake-on-the-bill' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'A mistake on the bill';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-mistake-on-the-bill';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-91a5cf1932b7');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'täs',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-25ac6c76f4b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tässä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tässä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'),
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lasku', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"lasku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lasku[X]lasku[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+lasku(lasku)"}'::jsonb,
      'laskussa', 'laskus',
      'inessive singular', 'Adds -ssa for ''in'' or ''on'': lasku becomes laskussa. Speech says laskus.', 'on the bill', 'bill, invoice', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-05da2a1d9a00');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laskussa', 'lasku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'' or ''on'': lasku becomes laskussa. Speech says laskus.', 'on the bill', 'bill, invoice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laskussa', 'lasku',
      (select form_name_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus'),
      (select why_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus'),
      (select meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus'),
      (select lemma_meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus'),
      'inessive singular', 'Adds -ssa for ''in'' or ''on'': lasku becomes laskussa. Speech says laskus.', 'on the bill', 'bill, invoice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('virhe', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"virhe","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]virhe[X]virhe[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+virhe(virhe)"}'::jsonb,
      'virhe', 'virhe',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'mistake, error', 'mistake, error', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-6cf9c4f895c0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'virhe', 'virhe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'mistake, error', 'mistake, error')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'virhe', 'virhe',
      (select form_name_en from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe'),
      (select why_en from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe'),
      (select meaning_en from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe'),
      (select lemma_meaning_en from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'mistake, error', 'mistake, error';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'ai',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-2ab0015782b0');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syödä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"syödä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]syödä[X]sö[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+syödä(syödä)"}'::jsonb,
      'söin', 'söin',
      'past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-b626212a64ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'söin', 'syödä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'söin', 'syödä',
      (select form_name_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select why_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      (select lemma_meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin'),
      'past tense, 1st person singular', 'Syödä means to eat. In the past, with minä, it becomes söin.', 'I ate', 'to eat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sg][Ny]hden","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhden', 'yhen',
      'genitive singular', 'Yksi becomes yhden for one whole thing. Speech drops the d: yhen.', 'one', 'one', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-6d227cbb3e31');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhden', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Yksi becomes yhden for one whole thing. Speech drops the d: yhen.', 'one', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhden', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen'),
      'genitive singular', 'Yksi becomes yhden for one whole thing. Speech drops the d: yhen.', 'one', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keitto', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"keitto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]keitto[X]keito[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+keitto(keitto)"}'::jsonb,
      'keiton', 'keiton',
      'genitive singular', 'A whole thing eaten takes -n: keitto becomes keiton, tt turning into t.', 'soup', 'soup', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-40123ec9ccf7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keiton', 'keitto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A whole thing eaten takes -n: keitto becomes keiton, tt turning into t.', 'soup', 'soup')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keiton', 'keitto',
      (select form_name_en from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton'),
      (select why_en from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton'),
      (select meaning_en from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton'),
      (select lemma_meaning_en from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton'),
      'genitive singular', 'A whole thing eaten takes -n: keitto becomes keiton, tt turning into t.', 'soup', 'soup';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voi', 'CLASS=huudahdussana', '{"BASEFORM":"voi","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]voi[X]voi","STRUCTURE":"=ppp","WORDBASES":"+voi(voi)"}'::jsonb,
      'voi', 'voi',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-1477dccb7e44');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voi', 'voi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voi', 'voi',
      (select form_name_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select why_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select lemma_meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('korjata', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"korjata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]korjata[X]korjaa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+korjata(korjata)"}'::jsonb,
      'korjaan', 'korjaan',
      'present tense, 1st person singular', 'Korjata means to fix. The ending -n goes with minä: korjaan.', 'I''ll fix', 'to fix, to repair', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-42dd9e9565f3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'korjaan', 'korjata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Korjata means to fix. The ending -n goes with minä: korjaan.', 'I''ll fix', 'to fix, to repair')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'korjaan', 'korjata',
      (select form_name_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan'),
      (select why_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan'),
      (select meaning_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan'),
      (select lemma_meaning_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan'),
      'present tense, 1st person singular', 'Korjata means to fix. The ending -n goes with minä: korjaan.', 'I''ll fix', 'to fix, to repair';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-1bca14269daf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sen', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sen', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('heti', 'CLASS=seikkasana', '{"BASEFORM":"heti","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]heti[X]heti","STRUCTURE":"=pppp","WORDBASES":"+heti(heti)"}'::jsonb,
      'heti', 'heti',
      'adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-78a5f0b146da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heti', 'heti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heti', 'heti',
      (select form_name_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select why_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select meaning_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select lemma_meaning_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikään', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikään","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikään[X]mi[Sp][Ny]tään","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+mikään(mikään)"}'::jsonb,
      'mitään', 'mitään',
      'partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-22bc94820380');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mitään', 'mikään';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mitään', 'mikään',
      (select form_name_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select why_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select meaning_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select lemma_meaning_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      'partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uusi', 'uus',
      'nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-64f62e81608d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uusi', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uusi', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      'nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lasku', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lasku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lasku[X]lasku[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+lasku(lasku)"}'::jsonb,
      'lasku', 'lasku',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bill, invoice', 'bill, invoice', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-458972206b05');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lasku', 'lasku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'bill, invoice', 'bill, invoice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lasku', 'lasku',
      (select form_name_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku'),
      (select why_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku'),
      (select meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku'),
      (select lemma_meaning_en from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bill, invoice', 'bill, invoice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksitoista', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksitoista","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi[Bc]toista[Xp][X]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+kaksitoista"}'::jsonb,
      'kaksitoista', 'kakstoist',
      'nominative singular', 'Speech shortens kaksitoista to kakstoist. Books write kaksitoista.', 'twelve', 'twelve', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-b32a414e973b');
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
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-e0b2a20b7101');
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
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-00cf76bd38f0');
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
  if not exists (select 1 from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oikein', 'CLASS=seikkasana', '{"BASEFORM":"oikein","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]oikein[X]oikein","STRUCTURE":"=pppppp","WORDBASES":"+oikein(oikein)"}'::jsonb,
      'oikein', 'oikein',
      'adverb', 'This is the dictionary form. People say it the same way.', 'right, correctly', 'right, correctly', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-24c345fab84f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oikein', 'oikein';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'right, correctly', 'right, correctly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oikein', 'oikein',
      (select form_name_en from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein'),
      (select why_en from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein'),
      (select meaning_en from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein'),
      (select lemma_meaning_en from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'right, correctly', 'right, correctly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-026c280fc0ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinulle', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinulle', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle'),
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('että', 'CLASS=sidesana', '{"BASEFORM":"että","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]että[X]että","STRUCTURE":"=pppp","WORDBASES":"+että(että)"}'::jsonb,
      'että', 'et',
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-4eeca18a865d');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huomata', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"huomata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]huomata[X]huomas[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"past_imperfective","WORDBASES":"+huomata(huomata)"}'::jsonb,
      'huomasit', 'huomasit',
      'past tense, 2nd person singular', 'Huomata means to notice. -si- marks the past and -t goes with sinä: huomasit.', 'you noticed', 'to notice', 'approved', now(), 'content/approvals/part-6.json#a-mistake-on-the-bill/form-d957cb0c6797');
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'huomasit', 'huomata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Huomata means to notice. -si- marks the past and -t goes with sinä: huomasit.', 'you noticed', 'to notice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'huomasit', 'huomata',
      (select form_name_en from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit'),
      (select why_en from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit'),
      (select meaning_en from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit'),
      (select lemma_meaning_en from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit'),
      'past tense, 2nd person singular', 'Huomata means to notice. -si- marks the past and -t goes with sinä: huomasit.', 'you noticed', 'to notice';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Anteeks, täs laskus on virhe.',
    'Anteeksi, tässä laskussa on virhe.', 'Excuse me, there''s a mistake on this bill.',
    'a-mistake-on-the-bill/1-puhe-023fcd1663ef.mp3', 'a-mistake-on-the-bill/1-kirja-6514284895b7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'kirja', 3, 'laskussa', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'virhe', (select id from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 3, 'laskus', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'laskussa' and surface_puhe = 'laskus')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'virhe', (select id from public.forms where lemma = 'virhe' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'virhe' and surface_puhe = 'virhe'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Mari', 'Ai, mikä?',
    'Ai, mikä?', 'Oh, what is it?',
    'a-mistake-on-the-bill/2-puhe-4ba54da0dedc.mp3', 'a-mistake-on-the-bill/2-kirja-fc41d8d085c6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'kirja', 2, 'mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'puhe', 2, 'mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Mä söin vaan yhen keiton, mut täs on kaks.',
    'Minä söin vain yhden keiton, mutta tässä on kaksi.', 'I only had one soup, but there are two here.',
    'a-mistake-on-the-bill/3-puhe-842e962cb788.mp3', 'a-mistake-on-the-bill/3-kirja-cc349511fecc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'söin', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin')),
    (v_line_id, 'kirja', 3, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 4, 'yhden', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen')),
    (v_line_id, 'kirja', 5, 'keiton', (select id from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton')),
    (v_line_id, 'kirja', 6, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 7, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'kirja', 8, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 9, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'söin', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söin' and surface_puhe = 'söin')),
    (v_line_id, 'puhe', 3, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 4, 'yhen', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'yhden' and surface_puhe = 'yhen')),
    (v_line_id, 'puhe', 5, 'keiton', (select id from public.forms where lemma = 'keitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keiton' and surface_puhe = 'keiton')),
    (v_line_id, 'puhe', 6, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 7, 'täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 8, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 9, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Mari', 'Voi anteeks! Mä korjaan sen heti.',
    'Voi anteeksi! Minä korjaan sen heti.', 'Oh, sorry! I''ll fix it right away.',
    'a-mistake-on-the-bill/4-puhe-32cb04f3eb20.mp3', 'a-mistake-on-the-bill/4-kirja-ef2450b4c9cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'korjaan', (select id from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan')),
    (v_line_id, 'kirja', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 6, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'korjaan', (select id from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'korjaan' and surface_puhe = 'korjaan')),
    (v_line_id, 'puhe', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 6, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ei se mitään.',
    'Ei se mitään.', 'That''s OK.',
    'a-mistake-on-the-bill/5-puhe-0602bb6aba84.mp3', 'a-mistake-on-the-bill/5-kirja-1fc0ed9a718f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'mitään', (select id from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'mitään', (select id from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Mari', 'Täs on uus lasku. Kakstoist euroo.',
    'Tässä on uusi lasku. Kaksitoista euroa.', 'Here''s the new bill. Twelve euros.',
    'a-mistake-on-the-bill/6-puhe-617bba2c1010.mp3', 'a-mistake-on-the-bill/6-kirja-ec3f3ebdab86.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'uusi', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus')),
    (v_line_id, 'kirja', 4, 'lasku', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku')),
    (v_line_id, 'kirja', 5, 'Kaksitoista', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'kirja', 6, 'euroa', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo')),
    (v_line_id, 'puhe', 1, 'Täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'uus', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus')),
    (v_line_id, 'puhe', 4, 'lasku', (select id from public.forms where lemma = 'lasku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lasku' and surface_puhe = 'lasku')),
    (v_line_id, 'puhe', 5, 'Kakstoist', (select id from public.forms where lemma = 'kaksitoista' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksitoista' and surface_puhe = 'kakstoist')),
    (v_line_id, 'puhe', 6, 'euroo', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Nyt se on oikein. Kiitti!',
    'Nyt se on oikein. Kiitos!', 'Now it''s right. Thanks!',
    'a-mistake-on-the-bill/7-puhe-54bc963cdd6e.mp3', 'a-mistake-on-the-bill/7-kirja-83cd918309e1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'oikein', (select id from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein')),
    (v_line_id, 'kirja', 5, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 1, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'oikein', (select id from public.forms where lemma = 'oikein' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'oikein' and surface_puhe = 'oikein')),
    (v_line_id, 'puhe', 5, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Mari', 'Kiitti sulle, et sä huomasit.',
    'Kiitos sinulle, että sinä huomasit.', 'Thank you for noticing.',
    'a-mistake-on-the-bill/8-puhe-a9ad4e257a2b.mp3', 'a-mistake-on-the-bill/8-kirja-87cfcb57db06.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 3, 'että', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 4, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 5, 'huomasit', (select id from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 3, 'et', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 4, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 5, 'huomasit', (select id from public.forms where lemma = 'huomata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'huomasit' and surface_puhe = 'huomasit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-mistake-on-the-bill/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
