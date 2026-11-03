-- Publishes the dialogue fixing-a-bike (unit my-work-and-skills). Made by
-- scripts/generate/pipeline.py publish from content/drafts/fixing-a-bike. Do not edit by hand:
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
    where slug = 'fixing-a-bike' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'fixing-a-bike';
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
  values (v_unit_id, 'fixing-a-bike', 3,
    'Fixing a bike')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'fixing-a-bike' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Fixing a bike';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'fixing-a-bike';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"osata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]osata[X]osaa[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+osata(osata)"}'::jsonb,
      'osaatko', 'osaat',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Osata means to know how. -t goes with sinä. Speech says osaatsä instead of -ko.', 'can you', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-0e5d59cdb03a');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('korjata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"korjata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]korjata[X]korjat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+korjata(korjata)"}'::jsonb,
      'korjata', 'korjata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to fix, to repair', 'to fix, to repair', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-6571bfacd995');
  end if;
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'korjata', 'korjata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to fix, to repair', 'to fix, to repair')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'korjata', 'korjata',
      (select form_name_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata'),
      (select why_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata'),
      (select meaning_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata'),
      (select lemma_meaning_en from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to fix, to repair', 'to fix, to repair';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pyörä', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"pyörä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pyörä[X]pyör[Sg][Ny]än","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+pyörä(pyörä)"}'::jsonb,
      'pyörän', 'pyörän',
      'genitive singular', 'A whole thing fixed takes -n: pyörä becomes pyörän.', 'a bike', 'bike, wheel', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-312e220e95f4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pyörän', 'pyörä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A whole thing fixed takes -n: pyörä becomes pyörän.', 'a bike', 'bike, wheel')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pyörän', 'pyörä',
      (select form_name_en from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän'),
      (select why_en from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän'),
      (select meaning_en from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän'),
      (select lemma_meaning_en from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän'),
      'genitive singular', 'A whole thing fixed takes -n: pyörä becomes pyörän.', 'a bike', 'bike, wheel';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('rengas', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"rengas","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]rengas[X]renkaa[Sn][Ny][O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+rengas(rengas)"}'::jsonb,
      'renkaani', 'rengas',
      'nominative singular, with the possessive ending for my', 'Books write renkaani, with -ni for ''my''. Speech says mun rengas and drops the ending.', 'my tyre', 'tyre, ring', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-da47b97254fe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'renkaani', 'rengas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books write renkaani, with -ni for ''my''. Speech says mun rengas and drops the ending.', 'my tyre', 'tyre, ring')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'renkaani', 'rengas',
      (select form_name_en from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas'),
      (select why_en from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas'),
      (select meaning_en from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas'),
      (select lemma_meaning_en from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas'),
      'nominative singular, with the possessive ending for my', 'Books write renkaani, with -ni for ''my''. Speech says mun rengas and drops the ending.', 'my tyre', 'tyre, ring';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhki', 'CLASS=seikkasana', '{"BASEFORM":"puhki","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]puhki[X]puhki","STRUCTURE":"=ppppp","WORDBASES":"+puhki(puhki)"}'::jsonb,
      'puhki', 'puhki',
      'adverb', 'This is the dictionary form. People say it the same way.', 'punctured, flat', 'punctured, flat', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-61f61fddd345');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhki', 'puhki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'punctured, flat', 'punctured, flat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhki', 'puhki',
      (select form_name_en from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki'),
      (select why_en from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki'),
      (select meaning_en from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki'),
      (select lemma_meaning_en from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'punctured, flat', 'punctured, flat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osata', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"osata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]osata[X]osaa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+osata(osata)"}'::jsonb,
      'osaan', 'osaan',
      'present tense, 1st person singular', 'Osata, to know how. With minä: osaan. Osata kieltä means to speak a language.', 'I know (a language)', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-a02f1650e73a');
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
  if not exists (select 1 from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('isä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"isä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]isä[X]is[Sn][Ny]ä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+isä(isä)"}'::jsonb,
      'isäni', 'isä',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': isäni. Speech says mun isä and drops the ending.', 'my dad', 'father, dad', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-8c0c5a8b4764');
  end if;
  if not exists (select 1 from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'isäni', 'isä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': isäni. Speech says mun isä and drops the ending.', 'my dad', 'father, dad')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'isäni', 'isä',
      (select form_name_en from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä'),
      (select why_en from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä'),
      (select meaning_en from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä'),
      (select lemma_meaning_en from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': isäni. Speech says mun isä and drops the ending.', 'my dad', 'father, dad';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"opettaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opett[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+opettaa(opettaa)"}'::jsonb,
      'opetti', 'opetti',
      'past tense, 3rd person singular', 'Opettaa means to teach. In the past, for ''he'' or ''she'', it becomes opetti.', 'taught', 'to teach', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-67211d03c0d5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opetti', 'opettaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Opettaa means to teach. In the past, for ''he'' or ''she'', it becomes opetti.', 'taught', 'to teach')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opetti', 'opettaa',
      (select form_name_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti'),
      (select why_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti'),
      (select meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti'),
      'past tense, 3rd person singular', 'Opettaa means to teach. In the past, for ''he'' or ''she'', it becomes opetti.', 'taught', 'to teach';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulle', 'mulle',
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-6ba9c8c14d0e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulle', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulle', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mahtava', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"mahtava","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"osanto"}'::jsonb,
      'mahtavaa', 'mahtavaa',
      'partitive singular', 'Mahtava, great. Said alone about good news it ends in -aa: Mahtavaa!', 'fantastic', 'fantastic, great', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-1377edc59a33');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-e12332115711');
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
      'present tense, negative form', 'After en the verb drops its ending: osata becomes osaa.', 'can (can''t sing)', 'to know how to, can', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-6fc6e606723b');
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
  if not exists (select 1 from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yhtään', 'CLASS=seikkasana', '{"BASEFORM":"yhtään","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]yhtään[X]yhtään","STRUCTURE":"=pppppp","WORDBASES":"+yhtään(yhtään)"}'::jsonb,
      'yhtään', 'yhtään',
      'adverb', 'This is the dictionary form. People say it the same way.', 'any, at all', 'any, at all', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-4bb23e324191');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhtään', 'yhtään';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'any, at all', 'any, at all')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhtään', 'yhtään',
      (select form_name_en from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään'),
      (select why_en from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään'),
      (select meaning_en from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään'),
      (select lemma_meaning_en from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'any, at all', 'any, at all';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulla', 'sul',
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-87d0163b4377');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinulla', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinulla', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul'),
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paikkaussarja', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"paikkaussarja","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]paikata[X]paikka[Ln][Xj]us[X]u[Sn][Ny]s[Bh][Bc][Ln][Xp]sarja[X]sarj[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp=ppppp","WORDBASES":"+paikka(paikata)+us(+us)+sarja(sarja)"}'::jsonb,
      'paikkaussarja', 'paikkaussarja',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'repair kit, patch kit', 'repair kit, patch kit', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-1028259c9d94');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paikkaussarja', 'paikkaussarja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'repair kit, patch kit', 'repair kit, patch kit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paikkaussarja', 'paikkaussarja',
      (select form_name_en from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja'),
      (select why_en from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja'),
      (select meaning_en from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja'),
      (select lemma_meaning_en from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'repair kit, patch kit', 'repair kit, patch kit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'täs',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-25ac6c76f4b0');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-4352ca83b810');
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
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viedä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"viedä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]viedä[X]vie[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+viedä(viedä)"}'::jsonb,
      'vie', 'vie',
      'present tense, 3rd person singular', 'Viedä, to take. With tämä, ''this'', the form is vie. Vie aikaa means it takes time.', 'takes (time)', 'to take (somewhere), to take (time)', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-1425743fd7b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vie', 'viedä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Viedä, to take. With tämä, ''this'', the form is vie. Vie aikaa means it takes time.', 'takes (time)', 'to take (somewhere), to take (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vie', 'viedä',
      (select form_name_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie'),
      (select why_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie'),
      (select meaning_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie'),
      (select lemma_meaning_en from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie'),
      'present tense, 3rd person singular', 'Viedä, to take. With tämä, ''this'', the form is vie. Vie aikaa means it takes time.', 'takes (time)', 'to take (somewhere), to take (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kymmenen', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kymmenen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Sn][Ny][Xp]kymmenen[X]kymmenen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+kymmenen(kymmenen)"}'::jsonb,
      'kymmenen', 'kymmenen',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'ten', 'ten', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-0fc03492889e');
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
      'partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-2ba98cc25249');
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
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voin', 'voin',
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-1932b7fb8d7b');
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
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opettaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"opettaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opetta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+opettaa(opettaa)"}'::jsonb,
      'opettaa', 'opettaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-85024a9e63e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettaa', 'opettaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettaa', 'opettaa',
      (select form_name_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select why_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      (select lemma_meaning_en from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to teach', 'to teach';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-026c280fc0ae');
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
  if not exists (select 1 from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neulominen', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"neulominen","CLASS":"nimisana","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"osanto"}'::jsonb,
      'neulomista', 'neulomista',
      'partitive singular', 'Neulominen, knitting. After opettaa, ''teach'', it ends in -sta: neulomista.', 'knitting', 'knitting', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-ffaaa448ac61');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neulomista', 'neulominen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Neulominen, knitting. After opettaa, ''teach'', it ends in -sta: neulomista.', 'knitting', 'knitting')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neulomista', 'neulominen',
      (select form_name_en from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista'),
      (select why_en from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista'),
      (select meaning_en from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista'),
      (select lemma_meaning_en from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista'),
      'partitive singular', 'Neulominen, knitting. After opettaa, ''teach'', it ends in -sta: neulomista.', 'knitting', 'knitting';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vastine', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"vastine","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vastine[X]vastinee[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppppppp","WORDBASES":"+vastine(vastine)"}'::jsonb,
      'vastineeksi', 'vastineeks',
      'translative singular', 'Adds -ksi: vastine becomes vastineeksi, ''in return''. Speech drops the last i.', 'in return', 'equivalent (vastineeksi, in return)', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-1668e1f6ef79');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vastineeksi', 'vastine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi: vastine becomes vastineeksi, ''in return''. Speech drops the last i.', 'in return', 'equivalent (vastineeksi, in return)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vastineeksi', 'vastine',
      (select form_name_en from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks'),
      (select why_en from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks'),
      (select meaning_en from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks'),
      (select lemma_meaning_en from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks'),
      'translative singular', 'Adds -ksi: vastine becomes vastineeksi, ''in return''. Speech drops the last i.', 'in return', 'equivalent (vastineeksi, in return)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sovittu', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive', '{"BASEFORM":"sovittu","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]sopia[X]sovi[Ll][Rt]t[Xj]tu[X]tu[Sn][Ny]","NUMBER":"singular","PARTICIPLE":"past_passive","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+sovi(sopia)+t+tu(+tu)"}'::jsonb,
      'sovittu', 'diili',
      'past passive participle, nominative singular', 'Books write sovittu, ''agreed''. Speech often says diili, from English ''deal''.', 'deal!', 'agreed, deal', 'approved', now(), 'content/approvals/part-6.json#fixing-a-bike/form-cb8a39815631');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sovittu', 'sovittu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past passive participle, nominative singular', 'Books write sovittu, ''agreed''. Speech often says diili, from English ''deal''.', 'deal!', 'agreed, deal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sovittu', 'sovittu',
      (select form_name_en from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili'),
      (select why_en from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili'),
      (select meaning_en from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili'),
      (select lemma_meaning_en from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili'),
      'past passive participle, nominative singular', 'Books write sovittu, ''agreed''. Speech often says diili, from English ''deal''.', 'deal!', 'agreed, deal';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Osaatsä korjata pyörän? Mun rengas on puhki.',
    'Osaatko sinä korjata pyörän? Minun renkaani on puhki.', 'Can you fix a bike? My tyre is flat.',
    'fixing-a-bike/1-puhe-600611eef073.mp3', 'fixing-a-bike/1-kirja-22660eabcc38.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Osaatko', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'korjata', (select id from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata')),
    (v_line_id, 'kirja', 4, 'pyörän', (select id from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän')),
    (v_line_id, 'kirja', 5, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 6, 'renkaani', (select id from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas')),
    (v_line_id, 'kirja', 7, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 8, 'puhki', (select id from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki')),
    (v_line_id, 'puhe', 1, 'Osaat', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'osaatko' and surface_puhe = 'osaat')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'korjata', (select id from public.forms where lemma = 'korjata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'korjata' and surface_puhe = 'korjata')),
    (v_line_id, 'puhe', 4, 'pyörän', (select id from public.forms where lemma = 'pyörä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pyörän' and surface_puhe = 'pyörän')),
    (v_line_id, 'puhe', 5, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 6, 'rengas', (select id from public.forms where lemma = 'rengas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'renkaani' and surface_puhe = 'rengas')),
    (v_line_id, 'puhe', 7, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 8, 'puhki', (select id from public.forms where lemma = 'puhki' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'puhki' and surface_puhe = 'puhki'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Osaan! Mun isä opetti mulle.',
    'Osaan! Minun isäni opetti minulle.', 'I can! My dad taught me.',
    'fixing-a-bike/2-puhe-8d1f84e1609b.mp3', 'fixing-a-bike/2-kirja-879b810d463c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'kirja', 2, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 3, 'isäni', (select id from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä')),
    (v_line_id, 'kirja', 4, 'opetti', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti')),
    (v_line_id, 'kirja', 5, 'minulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle')),
    (v_line_id, 'puhe', 1, 'Osaan', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'osaan' and surface_puhe = 'osaan')),
    (v_line_id, 'puhe', 2, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 3, 'isä', (select id from public.forms where lemma = 'isä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'isäni' and surface_puhe = 'isä')),
    (v_line_id, 'puhe', 4, 'opetti', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'opetti' and surface_puhe = 'opetti')),
    (v_line_id, 'puhe', 5, 'mulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Mahtavaa! Mä en osaa yhtään.',
    'Mahtavaa! Minä en osaa yhtään.', 'Fantastic! I can''t do it at all.',
    'fixing-a-bike/3-puhe-8611ac7e37ab.mp3', 'fixing-a-bike/3-kirja-5329a94ee7a0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 4, 'osaa', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa')),
    (v_line_id, 'kirja', 5, 'yhtään', (select id from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään')),
    (v_line_id, 'puhe', 1, 'Mahtavaa', (select id from public.forms where lemma = 'mahtava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mahtavaa' and surface_puhe = 'mahtavaa')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 4, 'osaa', (select id from public.forms where lemma = 'osata' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'osaa' and surface_puhe = 'osaa')),
    (v_line_id, 'puhe', 5, 'yhtään', (select id from public.forms where lemma = 'yhtään' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'yhtään' and surface_puhe = 'yhtään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Onks sul paikkaussarja?',
    'Onko sinulla paikkaussarja?', 'Do you have a repair kit?',
    'fixing-a-bike/4-puhe-865b6d30f7a9.mp3', 'fixing-a-bike/4-kirja-9652c5914e3f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 3, 'paikkaussarja', (select id from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 3, 'paikkaussarja', (select id from public.forms where lemma = 'paikkaussarja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'paikkaussarja' and surface_puhe = 'paikkaussarja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'On, täs.',
    'On, tässä.', 'Yes, here.',
    'fixing-a-bike/5-puhe-9bce4faea088.mp3', 'fixing-a-bike/5-kirja-d8e946b23c80.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Hyvä. Tää vie vaan kymmenen minuuttii.',
    'Hyvä. Tämä vie vain kymmenen minuuttia.', 'Good. This only takes ten minutes.',
    'fixing-a-bike/6-puhe-14e4da25e7b5.mp3', 'fixing-a-bike/6-kirja-d2380d640a6b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 3, 'vie', (select id from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie')),
    (v_line_id, 'kirja', 4, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'kirja', 5, 'kymmenen', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen')),
    (v_line_id, 'kirja', 6, 'minuuttia', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 3, 'vie', (select id from public.forms where lemma = 'viedä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'vie' and surface_puhe = 'vie')),
    (v_line_id, 'puhe', 4, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 5, 'kymmenen', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kymmenen' and surface_puhe = 'kymmenen')),
    (v_line_id, 'puhe', 6, 'minuuttii', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'Mä voin opettaa sulle neulomista vastineeks!',
    'Minä voin opettaa sinulle neulomista vastineeksi!', 'I can teach you knitting in return!',
    'fixing-a-bike/7-puhe-b75055ca3970.mp3', 'fixing-a-bike/7-kirja-f8be7ffbaefc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'kirja', 3, 'opettaa', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa')),
    (v_line_id, 'kirja', 4, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 5, 'neulomista', (select id from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista')),
    (v_line_id, 'kirja', 6, 'vastineeksi', (select id from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'puhe', 3, 'opettaa', (select id from public.forms where lemma = 'opettaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'opettaa' and surface_puhe = 'opettaa')),
    (v_line_id, 'puhe', 4, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 5, 'neulomista', (select id from public.forms where lemma = 'neulominen' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'neulomista' and surface_puhe = 'neulomista')),
    (v_line_id, 'puhe', 6, 'vastineeks', (select id from public.forms where lemma = 'vastine' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'vastineeksi' and surface_puhe = 'vastineeks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Diili!',
    'Sovittu!', 'Deal!',
    'fixing-a-bike/8-puhe-a4b0d8a2140d.mp3', 'fixing-a-bike/8-kirja-776aa4bf0d5a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sovittu', (select id from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili')),
    (v_line_id, 'puhe', 1, 'Diili', (select id from public.forms where lemma = 'sovittu' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_passive' and surface_kirja = 'sovittu' and surface_puhe = 'diili'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#fixing-a-bike/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#fixing-a-bike/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
