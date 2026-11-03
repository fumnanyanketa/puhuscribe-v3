-- Publishes the dialogue hows-it-going (unit how-you-feel). Made by
-- scripts/generate/pipeline.py publish from content/drafts/hows-it-going. Do not edit by hand:
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
    where slug = 'hows-it-going' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'hows-it-going';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 24
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'how-you-feel' and position = 24 and stop_number = 24;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'how-you-feel';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'hows-it-going', 1,
    'How''s it going?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'hows-it-going' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'How''s it going?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'hows-it-going';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-124d5d19fe78');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hei', 'hei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hei', 'hei',
      (select form_name_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select why_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select meaning_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      (select lemma_meaning_en from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'),
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('miten', 'CLASS=seikkasana', '{"BASEFORM":"miten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]miten[X]miten","STRUCTURE":"=ppppp","WORDBASES":"+miten(miten)"}'::jsonb,
      'miten', 'miten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-34eb915c255e');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]men[Tt][Ap][P3][Ny][Ef]ee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menee', 'menee',
      'present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-c90f7ee357bd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menee', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menee', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      'present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihan', 'CLASS=seikkasana', '{"BASEFORM":"ihan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ihan[X]ihan","STRUCTURE":"=pppp","WORDBASES":"+ihan(ihan)"}'::jsonb,
      'ihan', 'ihan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'quite, really, just', 'quite, really, just', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-f0a709b48382');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihan', 'ihan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'quite, really, just', 'quite, really, just')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihan', 'ihan',
      (select form_name_en from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan'),
      (select why_en from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan'),
      (select meaning_en from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan'),
      (select lemma_meaning_en from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'quite, really, just', 'quite, really, just';
  end if;
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('okei', 'CLASS=huudahdussana', '{"BASEFORM":"okei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]okei[X]okei","STRUCTURE":"=pppp","WORDBASES":"+okei(okei)"}'::jsonb,
      'okei', 'ok',
      'interjection', 'Speech often says ok. Books write okei.', 'OK', 'OK', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-a1abac21b21b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'okei', 'okei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Speech often says ok. Books write okei.', 'OK', 'OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'okei', 'okei',
      (select form_name_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok'),
      (select why_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok'),
      (select meaning_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok'),
      (select lemma_meaning_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok'),
      'interjection', 'Speech often says ok. Books write okei.', 'OK', 'OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('väsyttää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"väsyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]väsyttää[X]väsyttä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppppp","WORDBASES":"+väsyttää(väsyttää)"}'::jsonb,
      'väsyttää', 'väsyttää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to make tired, to feel tired', 'to make tired, to feel tired', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-1394800df5ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'väsyttää', 'väsyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to make tired, to feel tired', 'to make tired, to feel tired')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'väsyttää', 'väsyttää',
      (select form_name_en from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää'),
      (select why_en from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää'),
      (select meaning_en from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää'),
      (select lemma_meaning_en from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to make tired, to feel tired', 'to make tired, to feel tired';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'miksi', 'miks',
      'translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-d708d830ae73');
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
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nukkua', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"nukkua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nukkua[X]nuku[Tt][Ai][P2][Ny][Ef]it[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"past_imperfective","WORDBASES":"+nukkua(nukkua)"}'::jsonb,
      'nukuitko', 'nukuit',
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Nukuit (you slept) with the question ending -ko: nukuitko. Speech drops it and says nukuitsä.', 'did you sleep', 'to sleep', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-3b5a8fd092a9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nukuitko', 'nukkua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular, with the question ending -ko/-kö', 'Nukuit (you slept) with the question ending -ko: nukuitko. Speech drops it and says nukuitsä.', 'did you sleep', 'to sleep')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nukuitko', 'nukkua',
      (select form_name_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit'),
      (select why_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit'),
      (select meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit'),
      (select lemma_meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit'),
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Nukuit (you slept) with the question ending -ko: nukuitko. Speech drops it and says nukuitsä.', 'did you sleep', 'to sleep';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huono', 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive', '{"BASEFORM":"huono","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]huono[X]huono[Ssti]sti","SIJAMUOTO":"kerrontosti","STRUCTURE":"=pppppppp","WORDBASES":"+huono(huono)"}'::jsonb,
      'huonosti', 'huonosti',
      'adverb form (-sti)', 'Adds -sti to huono (bad) to say how: huonosti.', 'badly', 'bad, poor', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-5390d3b69cf5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'huonosti', 'huono';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb form (-sti)', 'Adds -sti to huono (bad) to say how: huonosti.', 'badly', 'bad, poor')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'huonosti', 'huono',
      (select form_name_en from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti'),
      (select why_en from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti'),
      (select meaning_en from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti'),
      (select lemma_meaning_en from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti'),
      'adverb form (-sti)', 'Adds -sti to huono (bad) to say how: huonosti.', 'badly', 'bad, poor';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('naapuri', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural', '{"BASEFORM":"naapuri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]naapuri[X]naapure[Sade][Nm]illa","NUMBER":"plural","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppppppp","WORDBASES":"+naapuri(naapuri)"}'::jsonb,
      'naapureilla', 'naapureilla',
      'adessive plural', 'Adds -lla for ''had'' or ''has'': naapureilla oli, ''the neighbours had''.', 'the neighbours had', 'neighbour', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-9b683f183d6e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'naapureilla', 'naapuri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive plural', 'Adds -lla for ''had'' or ''has'': naapureilla oli, ''the neighbours had''.', 'the neighbours had', 'neighbour')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'naapureilla', 'naapuri',
      (select form_name_en from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla'),
      (select why_en from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla'),
      (select meaning_en from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla'),
      (select lemma_meaning_en from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla'),
      'adessive plural', 'Adds -lla for ''had'' or ''has'': naapureilla oli, ''the neighbours had''.', 'the neighbours had', 'neighbour';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P3][Ny][Ef]li","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'oli', 'oli',
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-272accd9b290');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oli', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oli', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juhla', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"juhla","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]juhla[X]juhl[Sn][Nm]at","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+juhla(juhla)"}'::jsonb,
      'juhlat', 'bileet',
      'nominative plural', 'Speech often says bileet. Books write juhlat. Both always end in -t.', 'a party', 'party, celebration', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-0b96b320646c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juhlat', 'juhla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Speech often says bileet. Books write juhlat. Both always end in -t.', 'a party', 'party, celebration')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juhlat', 'juhla',
      (select form_name_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet'),
      (select why_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet'),
      (select meaning_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet'),
      (select lemma_meaning_en from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet'),
      'nominative plural', 'Speech often says bileet. Books write juhlat. Both always end in -t.', 'a party', 'party, celebration';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voi', 'CLASS=huudahdussana', '{"BASEFORM":"voi","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]voi[X]voi","STRUCTURE":"=ppp","WORDBASES":"+voi(voi)"}'::jsonb,
      'voi', 'voi',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-1477dccb7e44');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-99966cae578b');
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
  if not exists (select 1 from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('muuten', 'CLASS=seikkasana', '{"BASEFORM":"muuten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]muuten[X]muuten","STRUCTURE":"=pppppp","WORDBASES":"+muuten(muuten)"}'::jsonb,
      'muuten', 'muuten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'otherwise, by the way', 'otherwise, by the way', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-16b94fbfaff8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'muuten', 'muuten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'otherwise, by the way', 'otherwise, by the way')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'muuten', 'muuten',
      (select form_name_en from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten'),
      (select why_en from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten'),
      (select meaning_en from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten'),
      (select lemma_meaning_en from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'otherwise, by the way', 'otherwise, by the way';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]sa[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+saada(saada)"}'::jsonb,
      'sain', 'sain',
      'past tense, 1st person singular', 'Saada takes -i for something that already happened, then -n for ''I'': sain.', 'I got', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-f67664c6ca7a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sain', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Saada takes -i for something that already happened, then -n for ''I'': sain.', 'I got', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sain', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain'),
      'past tense, 1st person singular', 'Saada takes -i for something that already happened, then -n for ''I'': sain.', 'I got', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sg][Ny]den","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uuden', 'uuden',
      'genitive singular', 'The genitive singular matches kortin: uusi becomes uuden, the si turning to de.', 'a new', 'new', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-2e813451fa2c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uuden', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular matches kortin: uusi becomes uuden, the si turning to de.', 'a new', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uuden', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden'),
      'genitive singular', 'The genitive singular matches kortin: uusi becomes uuden, the si turning to de.', 'a new', 'new';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työpaikka', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"työpaikka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]työ[Sn][Ny][Bh][Bc][Ln][Xp]paikka[X]paik[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp=pppppp","WORDBASES":"+työ(työ)+paikka(paikka)"}'::jsonb,
      'työpaikan', 'työpaikan',
      'genitive singular', 'Adds -n for the thing you get: työpaikka becomes työpaikan, with one k.', 'job', 'job, workplace', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-3fc12e80b54d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työpaikan', 'työpaikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n for the thing you get: työpaikka becomes työpaikan, with one k.', 'job', 'job, workplace')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työpaikan', 'työpaikka',
      (select form_name_en from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan'),
      (select why_en from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan'),
      (select meaning_en from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan'),
      (select lemma_meaning_en from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan'),
      'genitive singular', 'Adds -n for the thing you get: työpaikka becomes työpaikan, with one k.', 'job', 'job, workplace';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mahtava', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"mahtava","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"osanto"}'::jsonb,
      'mahtavaa', 'mahtavaa',
      'partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-1377edc59a33');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mahtavaa', 'mahtava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mahtavaa', 'mahtava',
      (select form_name_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select why_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select meaning_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      (select lemma_meaning_en from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa'),
      'partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great';
  end if;
  if not exists (select 1 from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('onni', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"onni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]onni[X]onne[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+onni(onni)"}'::jsonb,
      'onneksi', 'onneks',
      'translative singular', 'Onni, luck, with -ksi. Onneksi olkoon means congratulations. Speech says onneks.', 'luckily (in onneksi olkoon, congratulations)', 'luck, happiness', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-5df29264208f');
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
      'imperative present tense, 3rd person singular', 'A wish form of olla: olkoon, may it be. Used in onneksi olkoon.', 'may it be', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-6312a6531b1e');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-26f45640039d');
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
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iloinen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"iloinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]ilo[X]ilo[Ll][Xj]inen[X]i[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+ilo(ilo)+inen(+inen)"}'::jsonb,
      'iloinen', 'iloinen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'happy, cheerful', 'happy, cheerful', 'approved', now(), 'content/approvals/part-4.json#hows-it-going/form-703f8f4ce1cc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'iloinen', 'iloinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'happy, cheerful', 'happy, cheerful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'iloinen', 'iloinen',
      (select form_name_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen'),
      (select why_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen'),
      (select meaning_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen'),
      (select lemma_meaning_en from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'happy, cheerful', 'happy, cheerful';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Moi Maria! Miten menee?',
    'Hei Maria! Miten menee?', 'Hi Maria! How''s it going?',
    'hows-it-going/1-puhe-a38033d9f2f0.mp3', 'hows-it-going/1-kirja-e540bbc6d390.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Maria', null),
    (v_line_id, 'kirja', 3, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'kirja', 4, 'menee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Maria', null),
    (v_line_id, 'puhe', 3, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'puhe', 4, 'menee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Ihan ok. Vähän väsyttää.',
    'Ihan okei. Vähän väsyttää.', 'OK. I''m a bit tired.',
    'hows-it-going/2-puhe-1da0503fca92.mp3', 'hows-it-going/2-kirja-87ded18adc4c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ihan', (select id from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 2, 'okei', (select id from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok')),
    (v_line_id, 'kirja', 3, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 4, 'väsyttää', (select id from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää')),
    (v_line_id, 'puhe', 1, 'Ihan', (select id from public.forms where lemma = 'ihan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ihan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 2, 'ok', (select id from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'ok')),
    (v_line_id, 'puhe', 3, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 4, 'väsyttää', (select id from public.forms where lemma = 'väsyttää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'väsyttää' and surface_puhe = 'väsyttää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Miks? Nukuitsä huonosti?',
    'Miksi? Nukuitko sinä huonosti?', 'Why? Did you sleep badly?',
    'hows-it-going/3-puhe-be6c74698878.mp3', 'hows-it-going/3-kirja-730c243cbb50.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Miksi', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'kirja', 2, 'Nukuitko', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'huonosti', (select id from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti')),
    (v_line_id, 'puhe', 1, 'Miks', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'puhe', 2, 'Nukuit', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'nukuitko' and surface_puhe = 'nukuit')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'huonosti', (select id from public.forms where lemma = 'huono' and form_tag = 'CLASS=laatusana;SIJAMUOTO=kerrontosti;COMPARISON=positive' and surface_kirja = 'huonosti' and surface_puhe = 'huonosti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo. Naapureilla oli bileet.',
    'Kyllä. Naapureilla oli juhlat.', 'Yes. The neighbours had a party.',
    'hows-it-going/4-puhe-670e2466644c.mp3', 'hows-it-going/4-kirja-a53805427015.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Naapureilla', (select id from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla')),
    (v_line_id, 'kirja', 3, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'kirja', 4, 'juhlat', (select id from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Naapureilla', (select id from public.forms where lemma = 'naapuri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'naapureilla' and surface_puhe = 'naapureilla')),
    (v_line_id, 'puhe', 3, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'puhe', 4, 'bileet', (select id from public.forms where lemma = 'juhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'juhlat' and surface_puhe = 'bileet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Voi ei. Entä muuten?',
    'Voi ei. Entä muuten?', 'Oh no. And otherwise?',
    'hows-it-going/5-puhe-4d166a19ab0a.mp3', 'hows-it-going/5-kirja-ac7a0ac4f0ea.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 4, 'muuten', (select id from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 4, 'muuten', (select id from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Muuten hyvin! Mä sain uuden työpaikan.',
    'Muuten hyvin! Minä sain uuden työpaikan.', 'Otherwise good! I got a new job.',
    'hows-it-going/6-puhe-ded224554cf1.mp3', 'hows-it-going/6-kirja-38f9c0c10280.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Muuten', (select id from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten')),
    (v_line_id, 'kirja', 2, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'sain', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain')),
    (v_line_id, 'kirja', 5, 'uuden', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden')),
    (v_line_id, 'kirja', 6, 'työpaikan', (select id from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan')),
    (v_line_id, 'puhe', 1, 'Muuten', (select id from public.forms where lemma = 'muuten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'muuten' and surface_puhe = 'muuten')),
    (v_line_id, 'puhe', 2, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'sain', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sain' and surface_puhe = 'sain')),
    (v_line_id, 'puhe', 5, 'uuden', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uuden' and surface_puhe = 'uuden')),
    (v_line_id, 'puhe', 6, 'työpaikan', (select id from public.forms where lemma = 'työpaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'työpaikan' and surface_puhe = 'työpaikan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Mahtavaa! Onneks olkoon!',
    'Mahtavaa! Onneksi olkoon!', 'Fantastic! Congratulations!',
    'hows-it-going/7-puhe-640d8b05accf.mp3', 'hows-it-going/7-kirja-bc3463714100.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'kirja', 2, 'Onneksi', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'kirja', 3, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon')),
    (v_line_id, 'puhe', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'puhe', 2, 'Onneks', (select id from public.forms where lemma = 'onni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'onneksi' and surface_puhe = 'onneks')),
    (v_line_id, 'puhe', 3, 'olkoon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkoon' and surface_puhe = 'olkoon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti! Mä oon tosi iloinen.',
    'Kiitos! Minä olen todella iloinen.', 'Thanks! I''m really happy.',
    'hows-it-going/8-puhe-d846b6e05c57.mp3', 'hows-it-going/8-kirja-b4ba988f262c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 4, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 5, 'iloinen', (select id from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 4, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 5, 'iloinen', (select id from public.forms where lemma = 'iloinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'iloinen' and surface_puhe = 'iloinen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#hows-it-going/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
