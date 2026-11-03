-- Publishes the dialogue joining-a-choir (unit free-time-and-hobbies). Made by
-- scripts/generate/pipeline.py publish from content/drafts/joining-a-choir. Do not edit by hand:
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
    where slug = 'joining-a-choir' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'joining-a-choir';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 22
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'free-time-and-hobbies' and position = 22 and stop_number = 22;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'free-time-and-hobbies';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'joining-a-choir', 2,
    'Joining a choir')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'joining-a-choir' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Joining a choir';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'joining-a-choir';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laulaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"laulaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laulaa[X]laula[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+laulaa(laulaa)"}'::jsonb,
      'laulan', 'laulan',
      'present tense, 1st person singular', 'Laulaa drops the last a and takes -n for ''I'': laulan.', 'I sing', 'to sing', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-c37cc30d4ec4');
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
      'inessive singular', 'Adds -ssa for ''in'': kuoro becomes kuorossa. Speech shortens -ssa to -s: kuorossa becomes kuoros.', 'in a choir', 'choir', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-aa5fee5dd7b4');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluatko', 'haluuk',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-6189aefae9f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluatko', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluatko', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Haluuksä, speech says haluu for haluat and -k for -ko, then joins sä.', 'do you want?', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tull[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulla', 'tulla',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-0dffaba9319d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulla', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulla', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukaan', 'CLASS=seikkasana', '{"BASEFORM":"mukaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]mukaan[X]mukaan","STRUCTURE":"=pppppp","WORDBASES":"+mukaan(mukaan)"}'::jsonb,
      'mukaan', 'mukaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-769eb876232e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mukaan', 'mukaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mukaan', 'mukaan',
      (select form_name_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select why_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select meaning_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      (select lemma_meaning_en from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkään', 'tykkään',
      'present tense, 1st person singular', 'Tykätä changes to tykkää- and takes -n for ''I'': tykkään.', 'I like', 'to like', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-140f37ece90d');
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
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laulaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"laulaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laulaa[X]laula[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+laulaa(laulaa)"}'::jsonb,
      'laulaa', 'laulaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sing', 'to sing', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-cd9ac3a1275f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laulaa', 'laulaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sing', 'to sing')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laulaa', 'laulaa',
      (select form_name_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa'),
      (select why_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa'),
      (select meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa'),
      (select lemma_meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to sing', 'to sing';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"osata","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'osaa', 'osaa',
      'present tense, negative form', 'After en the verb drops its ending: osata becomes osaa.', 'can (can''t sing)', 'to know how to, can', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-6fc6e606723b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osaa', 'osata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: osata becomes osaa.', 'can (can''t sing)', 'to know how to, can')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osaa', 'osata',
      (select form_name_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa'),
      (select why_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa'),
      (select meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa'),
      (select lemma_meaning_en from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa'),
      'present tense, negative form', 'After en the verb drops its ending: osata becomes osaa.', 'can (can''t sing)', 'to know how to, can';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomi', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"suomi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suomi[X]suome[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=pppppppp","WORDBASES":"+suomi(suomi)"}'::jsonb,
      'suomeksi', 'suomeks',
      'translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-016e9c711274');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomeksi', 'suomi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomeksi', 'suomi',
      (select form_name_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select why_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      (select lemma_meaning_en from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks'),
      'translative singular', 'Adds -ksi to a language to say ''in'' it: suomi becomes suomeksi. Speech drops the last i: suomeks.', 'in Finnish', 'Finnish (the language), Finland';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-4752d8dd4e2d');
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
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haitata', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"haitata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]haitata[X]haitta[Tt][Ap][P3][Ny][Eb]a","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+haitata(haitata)"}'::jsonb,
      'haittaa', 'haittaa',
      'present tense, 3rd person singular', 'Haitata, to bother, in the form for he, she or it. Ei se haittaa means that''s fine.', 'matters', 'to matter, to bother', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-70851a10c8f9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haittaa', 'haitata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Haitata, to bother, in the form for he, she or it. Ei se haittaa means that''s fine.', 'matters', 'to matter, to bother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haittaa', 'haitata',
      (select form_name_en from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa'),
      (select why_en from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa'),
      (select meaning_en from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa'),
      (select lemma_meaning_en from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa'),
      'present tense, 3rd person singular', 'Haitata, to bother, in the form for he, she or it. Ei se haittaa means that''s fine.', 'matters', 'to matter, to bother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laulaa', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"laulaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laulaa[X]laula[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+laulaa(laulaa)"}'::jsonb,
      'laulamme', 'lauletaan',
      'present tense, 1st person plural', 'Books write me laulamme. Speech says me lauletaan, the same form as ''one sings'', for ''we sing''.', 'we sing', 'to sing', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-22f1803cc69a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laulamme', 'laulaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write me laulamme. Speech says me lauletaan, the same form as ''one sings'', for ''we sing''.', 'we sing', 'to sing')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laulamme', 'laulaa',
      (select form_name_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan'),
      (select why_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan'),
      (select meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan'),
      (select lemma_meaning_en from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan'),
      'present tense, 1st person plural', 'Books write me laulamme. Speech says me lauletaan, the same form as ''one sings'', for ''we sing''.', 'we sing', 'to sing';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-fe354724e29a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myös', 'myös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myös', 'myös',
      (select form_name_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select why_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select lemma_meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too';
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('englanti', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"englanti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]englanti[X]englanni[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppppppp","WORDBASES":"+englanti(englanti)"}'::jsonb,
      'englanniksi', 'englanniks',
      'translative singular', 'Adds -ksi to a language to say ''in'' it: englanti becomes englanniksi. Speech drops the last i.', 'in English', 'English (the language), England', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-3834feab0acc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'englanniksi', 'englanti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi to a language to say ''in'' it: englanti becomes englanniksi. Speech drops the last i.', 'in English', 'English (the language), England')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'englanniksi', 'englanti',
      (select form_name_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks'),
      (select why_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks'),
      (select meaning_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks'),
      (select lemma_meaning_en from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks'),
      'translative singular', 'Adds -ksi to a language to say ''in'' it: englanti becomes englanniksi. Speech drops the last i.', 'in English', 'English (the language), England';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-a0518fcf4ae6');
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
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-2aeedafa15c7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'te', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'te', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('harjoitella', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"harjoitella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]harjoittaa[X]harjoit[Xj]ella[X]tele[Tt][Ap][P2][Nm][Ef]tte","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=pppppppppppppp","TENSE":"present_simple","WORDBASES":"+harjoit(harjoittaa)+ella(+ella)"}'::jsonb,
      'harjoittelette', 'harjottelette',
      'present tense, 2nd person plural', 'Harjoitella changes to harjoittele- and takes -tte for ''you all''. Speech drops an i: harjottelette.', 'you practise', 'to practise', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-3af0ae0e23a6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'harjoittelette', 'harjoitella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural', 'Harjoitella changes to harjoittele- and takes -tte for ''you all''. Speech drops an i: harjottelette.', 'you practise', 'to practise')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'harjoittelette', 'harjoitella',
      (select form_name_en from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette'),
      (select why_en from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette'),
      (select meaning_en from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette'),
      (select lemma_meaning_en from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette'),
      'present tense, 2nd person plural', 'Harjoitella changes to harjoittele- and takes -tte for ''you all''. Speech drops an i: harjottelette.', 'you practise', 'to practise';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiistaisin', 'CLASS=seikkasana', '{"BASEFORM":"tiistaisin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]tiistaisin[X]tiistaisin","STRUCTURE":"=pppppppppp","WORDBASES":"+tiistaisin(tiistaisin)"}'::jsonb,
      'tiistaisin', 'tiistaisin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'on Tuesdays', 'on Tuesdays', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-2049c6d104ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiistaisin', 'tiistaisin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'on Tuesdays', 'on Tuesdays')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiistaisin', 'tiistaisin',
      (select form_name_en from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin'),
      (select why_en from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin'),
      (select meaning_en from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin'),
      (select lemma_meaning_en from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'on Tuesdays', 'on Tuesdays';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('seitsemän', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"seitsemän","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]seitsemän[X]seitsem[Sabl][Ny]ältä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppppp","WORDBASES":"+seitsemän(seitsemän)"}'::jsonb,
      'seitsemältä', 'seittemältä',
      'ablative singular', 'Adds -ltä for a clock time: seitsemän becomes seitsemältä. Speech says seittemän, so seittemältä.', 'at seven', 'seven', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-092ba40d83b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'seitsemältä', 'seitsemän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä for a clock time: seitsemän becomes seitsemältä. Speech says seittemän, so seittemältä.', 'at seven', 'seven')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'seitsemältä', 'seitsemän',
      (select form_name_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä'),
      (select why_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä'),
      (select meaning_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä'),
      (select lemma_meaning_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä'),
      'ablative singular', 'Adds -ltä for a clock time: seitsemän becomes seitsemältä. Speech says seittemän, so seittemältä.', 'at seven', 'seven';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-58f467b0bcb4');
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
  if not exists (select 1 from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirkko', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kirkko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]kirkko[X]kirko[Sg][Ny]n","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kirkko(kirkko)"}'::jsonb,
      'kirkon', 'kirkon',
      'genitive singular', 'Kirkko takes -n with one k so it goes with salissa: kirkon salissa, ''in the church hall''.', 'of the church', 'church', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-c53885e592dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirkon', 'kirkko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kirkko takes -n with one k so it goes with salissa: kirkon salissa, ''in the church hall''.', 'of the church', 'church')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirkon', 'kirkko',
      (select form_name_en from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon'),
      (select why_en from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon'),
      (select meaning_en from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon'),
      (select lemma_meaning_en from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon'),
      'genitive singular', 'Kirkko takes -n with one k so it goes with salissa: kirkon salissa, ''in the church hall''.', 'of the church', 'church';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sali', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"sali","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sali[X]sali[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+sali(sali)"}'::jsonb,
      'salissa', 'salis',
      'inessive singular', 'Adds -ssa for ''in'': sali becomes salissa. Speech shortens -ssa to -s: salissa becomes salis.', 'in the hall', 'hall', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-68a8e27ce903');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'salissa', 'sali';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': sali becomes salissa. Speech shortens -ssa to -s: salissa becomes salis.', 'in the hall', 'hall')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'salissa', 'sali',
      (select form_name_en from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis'),
      (select why_en from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis'),
      (select meaning_en from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis'),
      (select lemma_meaning_en from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis'),
      'inessive singular', 'Adds -ssa for ''in'': sali becomes salissa. Speech shortens -ssa to -s: salissa becomes salis.', 'in the hall', 'hall';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-a392b28c6a8d');
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
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähellä', 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"lähellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]lähellä[X]lähe[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+lähellä(lähellä)"}'::jsonb,
      'lähellä', 'lähellä',
      'adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-fa873628ac0d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähellä', 'lähellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähellä', 'lähellä',
      (select form_name_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select why_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select meaning_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select lemma_meaning_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      'adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulen', 'tuun',
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-e0ecd37fd00f');
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
  if not exists (select 1 from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ensi', 'CLASS=seikkasana', '{"BASEFORM":"ensi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ensi[X]ensi","STRUCTURE":"=pppp","WORDBASES":"+ensi(ensi)"}'::jsonb,
      'ensi', 'ens',
      'adverb', 'Speech drops the final i: ensi becomes ens.', 'next', 'next', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-00d6b814f19a');
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
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tiistai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"tiistai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tiistai[X]tiistai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppppppp","WORDBASES":"+tiistai(tiistai)"}'::jsonb,
      'tiistaina', 'tiistaina',
      'essive singular', 'Days take -na for ''on'': tiistai becomes tiistaina.', 'on Tuesday', 'Tuesday', 'approved', now(), 'content/approvals/part-4.json#joining-a-choir/form-c641bccbf77d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiistaina', 'tiistai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': tiistai becomes tiistaina.', 'on Tuesday', 'Tuesday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiistaina', 'tiistai',
      (select form_name_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina'),
      (select why_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina'),
      (select meaning_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina'),
      (select lemma_meaning_en from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina'),
      'essive singular', 'Days take -na for ''on'': tiistai becomes tiistaina.', 'on Tuesday', 'Tuesday';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Mä laulan kuoros. Haluuksä tulla mukaan?',
    'Minä laulan kuorossa. Haluatko sinä tulla mukaan?', 'I sing in a choir. Do you want to join?',
    'joining-a-choir/1-puhe-49e5263fb081.mp3', 'joining-a-choir/1-kirja-02244b8ea418.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'laulan', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan')),
    (v_line_id, 'kirja', 3, 'kuorossa', (select id from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros')),
    (v_line_id, 'kirja', 4, 'Haluatko', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'kirja', 5, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 6, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla')),
    (v_line_id, 'kirja', 7, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'laulan', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulan' and surface_puhe = 'laulan')),
    (v_line_id, 'puhe', 3, 'kuoros', (select id from public.forms where lemma = 'kuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kuorossa' and surface_puhe = 'kuoros')),
    (v_line_id, 'puhe', 4, 'Haluuk', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'haluatko' and surface_puhe = 'haluuk')),
    (v_line_id, 'puhe', 5, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 6, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla')),
    (v_line_id, 'puhe', 7, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mä tykkään laulaa, mut mä en osaa laulaa suomeks hyvin.',
    'Minä tykkään laulaa, mutta minä en osaa laulaa suomeksi hyvin.', 'I like singing, but I can''t sing well in Finnish.',
    'joining-a-choir/2-puhe-66752fa43945.mp3', 'joining-a-choir/2-kirja-dfcb4f9cc813.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'kirja', 3, 'laulaa', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa')),
    (v_line_id, 'kirja', 4, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 7, 'osaa', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa')),
    (v_line_id, 'kirja', 8, 'laulaa', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa')),
    (v_line_id, 'kirja', 9, 'suomeksi', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks')),
    (v_line_id, 'kirja', 10, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'tykkään', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkään' and surface_puhe = 'tykkään')),
    (v_line_id, 'puhe', 3, 'laulaa', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa')),
    (v_line_id, 'puhe', 4, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 7, 'osaa', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa')),
    (v_line_id, 'puhe', 8, 'laulaa', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'laulaa' and surface_puhe = 'laulaa')),
    (v_line_id, 'puhe', 9, 'suomeks', (select id from public.forms where lemma = 'suomi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'suomeksi' and surface_puhe = 'suomeks')),
    (v_line_id, 'puhe', 10, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Ei se haittaa. Me lauletaan myös englanniks.',
    'Ei se haittaa. Me laulamme myös englanniksi.', 'That doesn''t matter. We sing in English too.',
    'joining-a-choir/3-puhe-24708951ca01.mp3', 'joining-a-choir/3-kirja-4d0a039e3239.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'haittaa', (select id from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa')),
    (v_line_id, 'kirja', 4, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 5, 'laulamme', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan')),
    (v_line_id, 'kirja', 6, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 7, 'englanniksi', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'haittaa', (select id from public.forms where lemma = 'haitata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'haittaa' and surface_puhe = 'haittaa')),
    (v_line_id, 'puhe', 4, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 5, 'lauletaan', (select id from public.forms where lemma = 'laulaa' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laulamme' and surface_puhe = 'lauletaan')),
    (v_line_id, 'puhe', 6, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 7, 'englanniks', (select id from public.forms where lemma = 'englanti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'englanniksi' and surface_puhe = 'englanniks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Millon te harjottelette?',
    'Milloin te harjoittelette?', 'When do you practise?',
    'joining-a-choir/4-puhe-6d2fb3770d03.mp3', 'joining-a-choir/4-kirja-0c54f1640330.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 3, 'harjoittelette', (select id from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette')),
    (v_line_id, 'puhe', 1, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 2, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 3, 'harjottelette', (select id from public.forms where lemma = 'harjoitella' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'harjoittelette' and surface_puhe = 'harjottelette'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'Tiistaisin seittemältä.',
    'Tiistaisin seitsemältä.', 'On Tuesdays at seven.',
    'joining-a-choir/5-puhe-e36182a0834b.mp3', 'joining-a-choir/5-kirja-65e65620e2a0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tiistaisin', (select id from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin')),
    (v_line_id, 'kirja', 2, 'seitsemältä', (select id from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä')),
    (v_line_id, 'puhe', 1, 'Tiistaisin', (select id from public.forms where lemma = 'tiistaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'tiistaisin' and surface_puhe = 'tiistaisin')),
    (v_line_id, 'puhe', 2, 'seittemältä', (select id from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'seitsemältä' and surface_puhe = 'seittemältä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Missä?',
    'Missä?', 'Where?',
    'joining-a-choir/6-puhe-e135a01d62ef.mp3', 'joining-a-choir/6-kirja-55c878c1f690.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 1, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'Kirkon salis, ihan lähellä.',
    'Kirkon salissa, aivan lähellä.', 'In the church hall, really close.',
    'joining-a-choir/7-puhe-702b9a402b5d.mp3', 'joining-a-choir/7-kirja-e437c56b2f9f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kirkon', (select id from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon')),
    (v_line_id, 'kirja', 2, 'salissa', (select id from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis')),
    (v_line_id, 'kirja', 3, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 4, 'lähellä', (select id from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä')),
    (v_line_id, 'puhe', 1, 'Kirkon', (select id from public.forms where lemma = 'kirkko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kirkon' and surface_puhe = 'kirkon')),
    (v_line_id, 'puhe', 2, 'salis', (select id from public.forms where lemma = 'sali' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'salissa' and surface_puhe = 'salis')),
    (v_line_id, 'puhe', 3, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 4, 'lähellä', (select id from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Okei, mä tuun ens tiistaina!',
    'Selvä, minä tulen ensi tiistaina!', 'OK, I''ll come next Tuesday!',
    'joining-a-choir/8-puhe-7c13636449c7.mp3', 'joining-a-choir/8-kirja-b4a89876697f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulen', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'kirja', 4, 'ensi', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'kirja', 5, 'tiistaina', (select id from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tuun', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'puhe', 4, 'ens', (select id from public.forms where lemma = 'ensi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ensi' and surface_puhe = 'ens')),
    (v_line_id, 'puhe', 5, 'tiistaina', (select id from public.forms where lemma = 'tiistai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'tiistaina' and surface_puhe = 'tiistaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#joining-a-choir/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
