-- Publishes the dialogue water-under-the-sink (unit housing-and-repairs). Made by
-- scripts/generate/pipeline.py publish from content/drafts/water-under-the-sink. Do not edit by hand:
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
    where slug = 'water-under-the-sink' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'water-under-the-sink';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 18
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'housing-and-repairs' and position = 18 and stop_number = 18;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'housing-and-repairs';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'water-under-the-sink', 2,
    'Water under the sink')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'water-under-the-sink' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Water under the sink';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'water-under-the-sink';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('keittiö', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"keittiö","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]keittiö[X]keittiö[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+keittiö(keittiö)"}'::jsonb,
      'keittiön', 'keittiön',
      'genitive singular', 'The genitive singular adds -n for ''of'': keittiö becomes keittiön.', 'the kitchen''s', 'kitchen', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-02695f0e04c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'keittiön', 'keittiö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular adds -n for ''of'': keittiö becomes keittiön.', 'the kitchen''s', 'kitchen')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'keittiön', 'keittiö',
      (select form_name_en from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön'),
      (select why_en from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön'),
      (select meaning_en from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön'),
      (select lemma_meaning_en from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön'),
      'genitive singular', 'The genitive singular adds -n for ''of'': keittiö becomes keittiön.', 'the kitchen''s', 'kitchen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiskiallas', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tiskiallas","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tiski[X]tisk[Sn][Ny]i[Bh][Bc][Ln][Xp]allas[X]altaa[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+tiski(tiski)+allas(allas)"}'::jsonb,
      'tiskialtaan', 'tiskialtaan',
      'genitive singular', 'The genitive singular goes before alla ''under'': tiskiallas becomes tiskialtaan.', 'the sink (under the sink)', 'kitchen sink', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-817f37d0ac27');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiskialtaan', 'tiskiallas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before alla ''under'': tiskiallas becomes tiskialtaan.', 'the sink (under the sink)', 'kitchen sink')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiskialtaan', 'tiskiallas',
      (select form_name_en from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan'),
      (select why_en from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan'),
      (select meaning_en from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan'),
      (select lemma_meaning_en from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan'),
      'genitive singular', 'The genitive singular goes before alla ''under'': tiskiallas becomes tiskialtaan.', 'the sink (under the sink)', 'kitchen sink';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alla', 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"alla","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]alla[X]a[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp","WORDBASES":"+alla(alla)"}'::jsonb,
      'alla', 'alla',
      'adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-3d6e3309dd97');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alla', 'alla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alla', 'alla',
      (select form_name_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select why_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select lemma_meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      'adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sp][Ny]ttä","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vettä', 'vettä',
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-18de4322e3a2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vettä', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vettä', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'),
      'partitive singular', 'The partitive singular is used for some water: vesi becomes vettä, the si turning to tt.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voi', 'CLASS=huudahdussana', '{"BASEFORM":"voi","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]voi[X]voi","STRUCTURE":"=ppp","WORDBASES":"+voi(voi)"}'::jsonb,
      'voi', 'voi',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-1477dccb7e44');
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
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"paljon","CLASS":"seikkasana","KYSYMYSLIITE":"true","MANUAL":"true"}'::jsonb,
      'paljonko', 'paljonks',
      'adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-40bfc95558ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paljonko', 'paljon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paljonko', 'paljon',
      (select form_name_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select why_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      (select lemma_meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks'),
      'adverb, with the question ending -ko/-kö', 'Paljon with the question ending -ko asks ''how much?''. Speech uses -ks: paljonks.', 'how much', 'a lot, much';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sp][Ny]itä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+se(se)"}'::jsonb,
      'sitä', 'sitä',
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-c039ed256b06');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pieni', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"pieni","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]pieni[X]pien[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+pieni(pieni)"}'::jsonb,
      'pieni', 'pieni',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'small, little', 'small, little', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-67a3c3282d5c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pieni', 'pieni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'small, little', 'small, little')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pieni', 'pieni',
      (select form_name_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni'),
      (select why_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni'),
      (select meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni'),
      (select lemma_meaning_en from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'small, little', 'small, little';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lätäkkö', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lätäkkö","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lätäkkö[X]lätäk[Sn][Ny]kö","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+lätäkkö(lätäkkö)"}'::jsonb,
      'lätäkkö', 'lätäkkö',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'puddle', 'puddle', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-a4e91ea37ffc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lätäkkö', 'lätäkkö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'puddle', 'puddle')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lätäkkö', 'lätäkkö',
      (select form_name_en from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö'),
      (select why_en from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö'),
      (select meaning_en from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö'),
      (select lemma_meaning_en from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'puddle', 'puddle';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tippua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tippua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tippua[X]tippuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tippua(tippua)"}'::jsonb,
      'tippuu', 'tippuu',
      'present tense, 3rd person singular', 'Tippua ''to drip'' doubles its last vowel for ''it'': tippuu. People say it the same way.', 'drips', 'to drip', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-f548f084d151');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tippuu', 'tippua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tippua ''to drip'' doubles its last vowel for ''it'': tippuu. People say it the same way.', 'drips', 'to drip')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tippuu', 'tippua',
      (select form_name_en from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu'),
      (select why_en from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu'),
      (select meaning_en from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu'),
      (select lemma_meaning_en from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu'),
      'present tense, 3rd person singular', 'Tippua ''to drip'' doubles its last vowel for ''it'': tippuu. People say it the same way.', 'drips', 'to drip';
  end if;
  if not exists (select 1 from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('putki', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"putki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]putki[X]putke[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppp","WORDBASES":"+putki(putki)"}'::jsonb,
      'putkesta', 'putkest',
      'elative singular', 'Adds -sta for ''from'': putki becomes putkesta, the i turning to e. Speech drops the last a.', 'from the pipe', 'pipe', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-5664f1b689f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'putkesta', 'putki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Adds -sta for ''from'': putki becomes putkesta, the i turning to e. Speech drops the last a.', 'from the pipe', 'pipe')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'putkesta', 'putki',
      (select form_name_en from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest'),
      (select why_en from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest'),
      (select meaning_en from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest'),
      (select lemma_meaning_en from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest'),
      'elative singular', 'Adds -sta for ''from'': putki becomes putkesta, the i turning to e. Speech drops the last a.', 'from the pipe', 'pipe';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"laittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laittaa[X]laita[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+laittaa(laittaa)"}'::jsonb,
      'laita', 'laita',
      'imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-6310bab3540e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laita', 'laittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laita', 'laittaa',
      (select form_name_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select why_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      (select lemma_meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita'),
      'imperative present tense, 2nd person singular', 'This is how you tell someone to put: laita. It comes from laittaa, with one t.', 'put', 'to put, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ämpäri', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ämpäri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ämpäri[X]ämpär[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+ämpäri(ämpäri)"}'::jsonb,
      'ämpäri', 'ämpäri',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bucket', 'bucket', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-d6881c9a784a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ämpäri', 'ämpäri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'bucket', 'bucket')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ämpäri', 'ämpäri',
      (select form_name_en from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri'),
      (select why_en from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri'),
      (select meaning_en from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri'),
      (select lemma_meaning_en from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'bucket', 'bucket';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alla', 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"alla","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]alla[X]a[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppp","WORDBASES":"+alla(alla)"}'::jsonb,
      'alle', 'alle',
      'allative singular', 'Alle means ''to under, under it''. People say it the same way.', 'under (it)', 'under, below', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-3d5c4ad76865');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alle', 'alla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Alle means ''to under, under it''. People say it the same way.', 'under (it)', 'under, below')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alle', 'alla',
      (select form_name_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle'),
      (select why_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle'),
      (select meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle'),
      (select lemma_meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle'),
      'allative singular', 'Alle means ''to under, under it''. People say it the same way.', 'under (it)', 'under, below';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulen', 'tuun',
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-e0ecd37fd00f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulen', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulen', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun'),
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tunti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tunti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tunti[X]tunn[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+tunti(tunti)"}'::jsonb,
      'tunnin', 'tunnin',
      'genitive singular', 'The genitive singular goes before päästä ''after'': tunti becomes tunnin.', 'an hour (in an hour)', 'hour', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-34495941bb9e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tunnin', 'tunti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before päästä ''after'': tunti becomes tunnin.', 'an hour (in an hour)', 'hour')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tunnin', 'tunti',
      (select form_name_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin'),
      (select why_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin'),
      (select meaning_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin'),
      (select lemma_meaning_en from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin'),
      'genitive singular', 'The genitive singular goes before päästä ''after'': tunti becomes tunnin.', 'an hour (in an hour)', 'hour';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"päästä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]päästä[X]pääst[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+päästä(päästä)"}'::jsonb,
      'päästä', 'päästä',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-c5dcc023ac08');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päästä', 'päästä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päästä', 'päästä',
      (select form_name_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select why_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      (select lemma_meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pit[Tt][Ap][P3][Ny][Ef]ää[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitääkö', 'pitääks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-c65047e392e5');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sulkea', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"sulkea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sulkea[X]sulke[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+sulkea(sulkea)"}'::jsonb,
      'sulkea', 'sulkee',
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: sulkea becomes sulkee. Books write sulkea.', 'to turn off', 'to close, to block', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-473a6e1364d2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sulkea', 'sulkea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Speech turns the ea at the end into ee: sulkea becomes sulkee. Books write sulkea.', 'to turn off', 'to close, to block')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sulkea', 'sulkea',
      (select form_name_en from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee'),
      (select why_en from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee'),
      (select meaning_en from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee'),
      (select lemma_meaning_en from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee'),
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: sulkea becomes sulkee. Books write sulkea.', 'to turn off', 'to close, to block';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sn][Ny]si","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vesi', 'vesi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-2738734d9176');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vesi', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vesi', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"tarvita","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'tarvitse', 'tarvii',
      'present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-f017cb16a696');
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
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jos', 'CLASS=sidesana', '{"BASEFORM":"jos","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]jos[X]jos","STRUCTURE":"=ppp","WORDBASES":"+jos(jos)"}'::jsonb,
      'jos', 'jos',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-546867beb98e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jos', 'jos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jos', 'jos',
      (select form_name_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select why_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select meaning_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select lemma_meaning_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koti', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"koti","CLASS":"nimisana","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"olento"}'::jsonb,
      'kotona', 'kotona',
      'essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-6623d0c4b9e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kotona', 'koti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kotona', 'koti',
      (select form_name_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select why_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      (select lemma_meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'),
      'essive singular', 'Koti with -na means ''at home'': kotona. The i of koti turns into o before the ending. You hear it every day.', 'at home', 'home';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-ed646e1f1923');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvä', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvä', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]nähd[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'nähdään', 'nähään',
      'present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-3154ca2238b6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nähdään', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nähdään', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään'),
      'present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pian', 'CLASS=seikkasana', '{"BASEFORM":"pian","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]pian[X]pian","STRUCTURE":"=pppp","WORDBASES":"+pian(pian)"}'::jsonb,
      'pian', 'kohta',
      'adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon', 'approved', now(), 'content/approvals/part-3.json#water-under-the-sink/form-ffa51b0abfb5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pian', 'pian';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pian', 'pian',
      (select form_name_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select why_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select lemma_meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      'adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Keittiön tiskialtaan alla on vettä.',
    'Hei! Keittiön tiskialtaan alla on vettä.', 'Hi! There''s water under the kitchen sink.',
    'water-under-the-sink/1-puhe-de73bc694b76.mp3', 'water-under-the-sink/1-kirja-7f092880cc1d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Keittiön', (select id from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön')),
    (v_line_id, 'kirja', 3, 'tiskialtaan', (select id from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan')),
    (v_line_id, 'kirja', 4, 'alla', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Keittiön', (select id from public.forms where lemma = 'keittiö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'keittiön' and surface_puhe = 'keittiön')),
    (v_line_id, 'puhe', 3, 'tiskialtaan', (select id from public.forms where lemma = 'tiskiallas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tiskialtaan' and surface_puhe = 'tiskialtaan')),
    (v_line_id, 'puhe', 4, 'alla', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'vettä', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'vettä' and surface_puhe = 'vettä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Raimo', 'Voi ei. Paljonks sitä on?',
    'Voi ei. Paljonko sitä on?', 'Oh no. How much is there?',
    'water-under-the-sink/2-puhe-ca742482d629.mp3', 'water-under-the-sink/2-kirja-a200c5bb79cf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 3, 'Paljonko', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks')),
    (v_line_id, 'kirja', 4, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 3, 'Paljonks', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'paljonko' and surface_puhe = 'paljonks')),
    (v_line_id, 'puhe', 4, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Pieni lätäkkö. Se tippuu putkest.',
    'Pieni lätäkkö. Se tippuu putkesta.', 'A small puddle. It''s dripping from the pipe.',
    'water-under-the-sink/3-puhe-bd00789007dd.mp3', 'water-under-the-sink/3-kirja-2fb7f0df2df8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pieni', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni')),
    (v_line_id, 'kirja', 2, 'lätäkkö', (select id from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö')),
    (v_line_id, 'kirja', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'tippuu', (select id from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu')),
    (v_line_id, 'kirja', 5, 'putkesta', (select id from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest')),
    (v_line_id, 'puhe', 1, 'Pieni', (select id from public.forms where lemma = 'pieni' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pieni' and surface_puhe = 'pieni')),
    (v_line_id, 'puhe', 2, 'lätäkkö', (select id from public.forms where lemma = 'lätäkkö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lätäkkö' and surface_puhe = 'lätäkkö')),
    (v_line_id, 'puhe', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'tippuu', (select id from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu')),
    (v_line_id, 'puhe', 5, 'putkest', (select id from public.forms where lemma = 'putki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'putkesta' and surface_puhe = 'putkest'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Raimo', 'Laita ämpäri alle. Mä tuun tunnin päästä.',
    'Laita ämpäri alle. Minä tulen tunnin päästä.', 'Put a bucket under it. I''ll come in an hour.',
    'water-under-the-sink/4-puhe-645684107577.mp3', 'water-under-the-sink/4-kirja-1ae6caa0fcc4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Laita', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita')),
    (v_line_id, 'kirja', 2, 'ämpäri', (select id from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri')),
    (v_line_id, 'kirja', 3, 'alle', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle')),
    (v_line_id, 'kirja', 4, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 5, 'tulen', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'kirja', 6, 'tunnin', (select id from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin')),
    (v_line_id, 'kirja', 7, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä')),
    (v_line_id, 'puhe', 1, 'Laita', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'laita' and surface_puhe = 'laita')),
    (v_line_id, 'puhe', 2, 'ämpäri', (select id from public.forms where lemma = 'ämpäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ämpäri' and surface_puhe = 'ämpäri')),
    (v_line_id, 'puhe', 3, 'alle', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'alle' and surface_puhe = 'alle')),
    (v_line_id, 'puhe', 4, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 5, 'tuun', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'puhe', 6, 'tunnin', (select id from public.forms where lemma = 'tunti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tunnin' and surface_puhe = 'tunnin')),
    (v_line_id, 'puhe', 7, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Kiitti. Pitääks mun sulkee vesi?',
    'Kiitos. Pitääkö minun sulkea vesi?', 'Thanks. Should I turn off the water?',
    'water-under-the-sink/5-puhe-b020c81f6fb2.mp3', 'water-under-the-sink/5-kirja-5565b655164d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Pitääkö', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'kirja', 3, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 4, 'sulkea', (select id from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee')),
    (v_line_id, 'kirja', 5, 'vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Pitääks', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'puhe', 3, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 4, 'sulkee', (select id from public.forms where lemma = 'sulkea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'sulkea' and surface_puhe = 'sulkee')),
    (v_line_id, 'puhe', 5, 'vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Raimo', 'Ei tarvii, jos se tippuu vaan vähän.',
    'Ei tarvitse, jos se tippuu vain vähän.', 'No need, if it''s only dripping a little.',
    'water-under-the-sink/6-puhe-a5110096a44e.mp3', 'water-under-the-sink/6-kirja-0f92a742df04.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'tarvitse', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'kirja', 3, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'kirja', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 5, 'tippuu', (select id from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu')),
    (v_line_id, 'kirja', 6, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 7, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'tarvii', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'puhe', 3, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 5, 'tippuu', (select id from public.forms where lemma = 'tippua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tippuu' and surface_puhe = 'tippuu')),
    (v_line_id, 'puhe', 6, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 7, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Okei. Mä oon kotona.',
    'Selvä. Minä olen kotona.', 'OK. I''ll be home.',
    'water-under-the-sink/7-puhe-446b4b0bf7a6.mp3', 'water-under-the-sink/7-kirja-96aeaf6fffde.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 4, 'kotona', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 4, 'kotona', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'kotona' and surface_puhe = 'kotona'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Raimo', 'Hyvä. Nähään kohta.',
    'Hyvä. Nähdään pian.', 'Good. See you soon.',
    'water-under-the-sink/8-puhe-f273b5cfa2c6.mp3', 'water-under-the-sink/8-kirja-9d5cfba42f18.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Nähdään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'kirja', 3, 'pian', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Nähään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'puhe', 3, 'kohta', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#water-under-the-sink/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
