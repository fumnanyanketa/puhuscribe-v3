-- Publishes the dialogue pick-up-time (unit school-and-daycare). Made by
-- scripts/generate/pipeline.py publish from content/drafts/pick-up-time. Do not edit by hand:
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
    where slug = 'pick-up-time' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'pick-up-time';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 21
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'school-and-daycare' and position = 21 and stop_number = 21;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'school-and-daycare';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'pick-up-time', 1,
    'Pick-up time')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'pick-up-time' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Pick-up time';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'pick-up-time';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulin', 'tulin',
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-85741e401e76');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulin', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulin', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin'),
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': tulla becomes tulin.', 'I came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hake[Tn3][Ny][Sill]maan","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'hakemaan', 'hakee',
      'MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-21daceb78f26');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hakemaan', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hakemaan', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee'),
      'MA-infinitive, illative', 'After tulla ''to come'', the verb takes -maan: hakemaan. Speech says hakee.', 'to pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-d5b687de866a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hän', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hän', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('leikkiä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"leikkiä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]leikkiä[X]leikk[Tt][Ap][P3][Ny][Ef]ii","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+leikkiä(leikkiä)"}'::jsonb,
      'leikkii', 'leikkii',
      'present tense, 3rd person singular', 'Leikkiä takes the doubled last vowel for he or she: leikkii.', 'he''s playing', 'to play', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-06146fc291e0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'leikkii', 'leikkiä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Leikkiä takes the doubled last vowel for he or she: leikkii.', 'he''s playing', 'to play')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'leikkii', 'leikkiä',
      (select form_name_en from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii'),
      (select why_en from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii'),
      (select meaning_en from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii'),
      (select lemma_meaning_en from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii'),
      'present tense, 3rd person singular', 'Leikkiä takes the doubled last vowel for he or she: leikkii.', 'he''s playing', 'to play';
  end if;
  if not exists (select 1 from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('piha', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"piha","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]piha[X]piha[Sade][Ny]lla","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+piha(piha)"}'::jsonb,
      'pihalla', 'pihal',
      'adessive singular', 'Adds -lla for ''in'' an open place: piha becomes pihalla. Speech shortens -lla to -l: pihalla becomes pihal.', 'in the yard', 'yard', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-f472eda46936');
  end if;
  if not exists (select 1 from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pihalla', 'piha';
  end if;
  if not exists (select 1 from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for ''in'' an open place: piha becomes pihalla. Speech shortens -lla to -l: pihalla becomes pihal.', 'in the yard', 'yard')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pihalla', 'piha',
      (select form_name_en from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal'),
      (select why_en from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal'),
      (select meaning_en from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal'),
      (select lemma_meaning_en from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal'),
      'adessive singular', 'Adds -lla for ''in'' an open place: piha becomes pihalla. Speech shortens -lla to -l: pihalla becomes pihal.', 'in the yard', 'yard';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('miten', 'CLASS=seikkasana', '{"BASEFORM":"miten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]miten[X]miten","STRUCTURE":"=ppppp","WORDBASES":"+miten(miten)"}'::jsonb,
      'miten', 'miten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-34eb915c255e');
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
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivä', 'päivä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-178d895f9ecf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivä', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivä', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'day', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]men[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'meni', 'meni',
      'past tense, 3rd person singular', 'Mennä, to go, in the past tense for he, she or it: meni.', 'went', 'to go', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-5bc6adc301f5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'meni', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Mennä, to go, in the past tense for he, she or it: meni.', 'went', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'meni', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni'),
      'past tense, 3rd person singular', 'Mennä, to go, in the past tense for he, she or it: meni.', 'went', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syödä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"syödä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]syödä[X]sö[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+syödä(syödä)"}'::jsonb,
      'söi', 'söi',
      'past tense, 3rd person singular', 'Syödä changes to söi for something that already happened.', 'he ate', 'to eat', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-cfbc36775351');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'söi', 'syödä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Syödä changes to söi for something that already happened.', 'he ate', 'to eat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'söi', 'syödä',
      (select form_name_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi'),
      (select why_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi'),
      (select meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi'),
      (select lemma_meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi'),
      'past tense, 3rd person singular', 'Syödä changes to söi for something that already happened.', 'he ate', 'to eat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nukkua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"nukkua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nukkua[X]nukku[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+nukkua(nukkua)"}'::jsonb,
      'nukkui', 'nukku',
      'past tense, 3rd person singular', 'Books write nukkui. Speech drops the last i: nukku.', 'he slept', 'to sleep', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-b51e8f138752');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nukkui', 'nukkua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Books write nukkui. Speech drops the last i: nukku.', 'he slept', 'to sleep')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nukkui', 'nukkua',
      (select form_name_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku'),
      (select why_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku'),
      (select meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku'),
      (select lemma_meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku'),
      'past tense, 3rd person singular', 'Books write nukkui. Speech drops the last i: nukku.', 'he slept', 'to sleep';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päiväuni', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"päiväuni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sn][Ny]ä[Bh][Bc][Ln][Xp]uni[X]un[Sn][Nm]et","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppp","WORDBASES":"+päivä(päivä)+uni(uni)"}'::jsonb,
      'päiväunet', 'päiväunet',
      'nominative plural', 'Päiväuni is a day sleep. The word is used with -t: nukkua päiväunet, ''to have a nap''.', 'a nap', 'nap', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-619f5f50e0e1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päiväunet', 'päiväuni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Päiväuni is a day sleep. The word is used with -t: nukkua päiväunet, ''to have a nap''.', 'a nap', 'nap')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päiväunet', 'päiväuni',
      (select form_name_en from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet'),
      (select why_en from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet'),
      (select meaning_en from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet'),
      (select lemma_meaning_en from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet'),
      'nominative plural', 'Päiväuni is a day sleep. The word is used with -t: nukkua päiväunet, ''to have a nap''.', 'a nap', 'nap';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huomenna', 'CLASS=seikkasana', '{"BASEFORM":"huomenna","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]huomenna[X]huomenna","STRUCTURE":"=pppppppp","WORDBASES":"+huomenna(huomenna)"}'::jsonb,
      'huomenna', 'huomenna',
      'adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-08b72686d46b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'huomenna', 'huomenna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'huomenna', 'huomenna',
      (select form_name_en from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'),
      (select why_en from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'),
      (select meaning_en from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'),
      (select lemma_meaning_en from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hae[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'haen', 'haen',
      'present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-0bb41a1c5be3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haen', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haen', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen'),
      'present tense, 1st person singular', 'Hakea changes to hae- and takes -n for ''I'': haen.', 'I''ll pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sak][Ny]net","NUMBER":"singular","SIJAMUOTO":"kohdanto","STRUCTURE":"=ppppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hänet', 'sen',
      'accusative singular', 'Hän takes -t when it is the person you pick up: hänet. Speech uses se and says sen.', 'him', 'he, she', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-99ff11e02e41');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hänet', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('accusative singular', 'Hän takes -t when it is the person you pick up: hänet. Speech uses se and says sen.', 'him', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hänet', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen'),
      'accusative singular', 'Hän takes -t when it is the person you pick up: hänet. Speech uses se and says sen.', 'him', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myöhemmin', 'CLASS=seikkasana', '{"BASEFORM":"myöhemmin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myöhemmin[X]myöhemmin","STRUCTURE":"=ppppppppp","WORDBASES":"+myöhemmin(myöhemmin)"}'::jsonb,
      'myöhemmin', 'myöhemmin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'later', 'later', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-13ffb3924117');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myöhemmin', 'myöhemmin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'later', 'later')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myöhemmin', 'myöhemmin',
      (select form_name_en from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin'),
      (select why_en from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin'),
      (select meaning_en from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin'),
      (select lemma_meaning_en from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'later', 'later';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-f42052a3d5f2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mihin', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mihin', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin'),
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aika', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"aika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aika[X]aik[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+aika(aika)"}'::jsonb,
      'aikaan', 'aikaan',
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-ea79f0748e36');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aikaan', 'aika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aikaan', 'aika',
      (select form_name_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select why_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      (select lemma_meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'),
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sabl][Ny]deltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viideltä', 'viideltä',
      'ablative singular', 'Adds -ltä to a number to give a clock time. Viisi changes its s to d first: viideltä, ''at five''.', 'at five', 'five', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-d693248e8615');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-5eb112d9aace');
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
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('okei', 'CLASS=huudahdussana', '{"BASEFORM":"okei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]okei[X]okei","STRUCTURE":"=pppp","WORDBASES":"+okei(okei)"}'::jsonb,
      'okei', 'okei',
      'interjection', 'This is the dictionary form. People say it the same way.', 'OK', 'OK', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-bc19db5817f5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'okei', 'okei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'OK', 'OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'okei', 'okei',
      (select form_name_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei'),
      (select why_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei'),
      (select meaning_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei'),
      (select lemma_meaning_en from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'OK', 'OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-9f0f9f1fdd21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'me', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Me means we. People say it the same way.', 'we', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'me', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Nm][Ef]lemme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olemme', 'ollaan',
      'present tense, 1st person plural', 'Books write me olemme. Speech says me ollaan, the same form as ''one is'', for ''we are''.', 'we are', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-7d01f19d8e6b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olemme', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write me olemme. Speech says me ollaan, the same form as ''one is'', for ''we are''.', 'we are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olemme', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan'),
      'present tense, 1st person plural', 'Books write me olemme. Speech says me ollaan, the same form as ''one is'', for ''we are''.', 'we are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('auki', 'CLASS=seikkasana', '{"BASEFORM":"auki","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]auki[X]auki","STRUCTURE":"=pppp","WORDBASES":"+auki(auki)"}'::jsonb,
      'auki', 'auki',
      'adverb', 'This is the dictionary form. People say it the same way.', 'open', 'open', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-df4ac66bff49');
  end if;
  if not exists (select 1 from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'auki', 'auki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'open', 'open')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'auki', 'auki',
      (select form_name_en from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki'),
      (select why_en from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki'),
      (select meaning_en from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki'),
      (select lemma_meaning_en from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'open', 'open';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puol[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puoli', 'puol',
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-31b91a2acd2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puoli', 'puoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puoli', 'puoli',
      (select form_name_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select why_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select lemma_meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuusi', 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"kuusi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kuusi[X]kuu[Sill][Ny]teen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+kuusi(kuusi)"}'::jsonb,
      'kuuteen', 'kuuteen',
      'illative singular', 'Kuusi becomes kuuteen for ''to'': puoli kuuteen, ''half to six'', is half past five.', 'to six', 'six', 'approved', now(), 'content/approvals/part-4.json#pick-up-time/form-683dbf2d7a26');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuuteen', 'kuusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Kuusi becomes kuuteen for ''to'': puoli kuuteen, ''half to six'', is half past five.', 'to six', 'six')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuuteen', 'kuusi',
      (select form_name_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen'),
      (select why_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen'),
      (select meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen'),
      (select lemma_meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen'),
      'illative singular', 'Kuusi becomes kuuteen for ''to'': puoli kuuteen, ''half to six'', is half past five.', 'to six', 'six';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä tulin hakee Lucasta.',
    'Hei! Minä tulin hakemaan Lucasta.', 'Hi! I''ve come to pick up Lucas.',
    'pick-up-time/1-puhe-6755298b1556.mp3', 'pick-up-time/1-kirja-e3b77d81f8bf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'kirja', 4, 'hakemaan', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee')),
    (v_line_id, 'kirja', 5, 'Lucasta', null),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tulin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulin' and surface_puhe = 'tulin')),
    (v_line_id, 'puhe', 4, 'hakee', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'hakemaan' and surface_puhe = 'hakee')),
    (v_line_id, 'puhe', 5, 'Lucasta', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Sari', 'Moi! Se leikkii pihal.',
    'Hei! Hän leikkii pihalla.', 'Hi! He''s playing in the yard.',
    'pick-up-time/2-puhe-00509b6b1e34.mp3', 'pick-up-time/2-kirja-d7eb5fe95cbd.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'leikkii', (select id from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii')),
    (v_line_id, 'kirja', 4, 'pihalla', (select id from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'leikkii', (select id from public.forms where lemma = 'leikkiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'leikkii' and surface_puhe = 'leikkii')),
    (v_line_id, 'puhe', 4, 'pihal', (select id from public.forms where lemma = 'piha' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'pihalla' and surface_puhe = 'pihal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Miten päivä meni?',
    'Miten päivä meni?', 'How did the day go?',
    'pick-up-time/3-puhe-340214fdfebb.mp3', 'pick-up-time/3-kirja-986406b42927.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'kirja', 2, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä')),
    (v_line_id, 'kirja', 3, 'meni', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni')),
    (v_line_id, 'puhe', 1, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'puhe', 2, 'päivä', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'päivä' and surface_puhe = 'päivä')),
    (v_line_id, 'puhe', 3, 'meni', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'meni' and surface_puhe = 'meni'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Sari', 'Hyvin! Se söi hyvin ja nukku päiväunet.',
    'Hyvin! Hän söi hyvin ja nukkui päiväunet.', 'Well! He ate well and had a nap.',
    'pick-up-time/4-puhe-13928331f8ac.mp3', 'pick-up-time/4-kirja-9d09f4d7ad8c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 2, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'söi', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi')),
    (v_line_id, 'kirja', 4, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'nukkui', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku')),
    (v_line_id, 'kirja', 7, 'päiväunet', (select id from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet')),
    (v_line_id, 'puhe', 1, 'Hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'söi', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'söi' and surface_puhe = 'söi')),
    (v_line_id, 'puhe', 4, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'nukku', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'nukkui' and surface_puhe = 'nukku')),
    (v_line_id, 'puhe', 7, 'päiväunet', (select id from public.forms where lemma = 'päiväuni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'päiväunet' and surface_puhe = 'päiväunet'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Hyvä. Huomenna mä haen sen vähän myöhemmin.',
    'Hyvä. Huomenna minä haen hänet vähän myöhemmin.', 'Good. Tomorrow I''ll pick him up a bit later.',
    'pick-up-time/5-puhe-9d0ad1a801c4.mp3', 'pick-up-time/5-kirja-c9ecf312a5a3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'haen', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen')),
    (v_line_id, 'kirja', 5, 'hänet', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 6, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 7, 'myöhemmin', (select id from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'haen', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haen' and surface_puhe = 'haen')),
    (v_line_id, 'puhe', 5, 'sen', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'hänet' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 6, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 7, 'myöhemmin', (select id from public.forms where lemma = 'myöhemmin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myöhemmin' and surface_puhe = 'myöhemmin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Sari', 'Mihin aikaan?',
    'Mihin aikaan?', 'What time?',
    'pick-up-time/6-puhe-d49f57f42342.mp3', 'pick-up-time/6-kirja-67c114f2a35c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 2, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'puhe', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 2, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Viideltä. Onks se okei?',
    'Viideltä. Onko se okei?', 'At five. Is that OK?',
    'pick-up-time/7-puhe-338bcb1e176a.mp3', 'pick-up-time/7-kirja-eaf9af06db76.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'okei', (select id from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 1, 'Viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'okei', (select id from public.forms where lemma = 'okei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'okei' and surface_puhe = 'okei'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Sari', 'Joo, me ollaan auki puol kuuteen.',
    'Kyllä, me olemme auki puoli kuuteen.', 'Yes, we''re open until half past five.',
    'pick-up-time/8-puhe-b75e95c5b798.mp3', 'pick-up-time/8-kirja-11b58f519361.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 3, 'olemme', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan')),
    (v_line_id, 'kirja', 4, 'auki', (select id from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki')),
    (v_line_id, 'kirja', 5, 'puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'kirja', 6, 'kuuteen', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 3, 'ollaan', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan')),
    (v_line_id, 'puhe', 4, 'auki', (select id from public.forms where lemma = 'auki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'auki' and surface_puhe = 'auki')),
    (v_line_id, 'puhe', 5, 'puol', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'puhe', 6, 'kuuteen', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kuuteen' and surface_puhe = 'kuuteen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#pick-up-time/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
