-- Publishes the dialogue the-shopping-list (unit cooking-at-home). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-shopping-list. Do not edit by hand:
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
    where slug = 'the-shopping-list' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-shopping-list';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 23
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'cooking-at-home' and position = 23 and stop_number = 23;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'cooking-at-home';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'the-shopping-list', 1,
    'The shopping list')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-shopping-list' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'The shopping list';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-shopping-list';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teemme', 'tehään',
      'present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-571fca58f152');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teemme', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teemme', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään'),
      'present tense, 1st person plural', 'Books write teemme. Speech says me tehään, the same form as ''one does'', for ''we do''.', 'we do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ruoka', 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"ruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ruoka[X]ruoa[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppppp","WORDBASES":"+ruoka(ruoka)"}'::jsonb,
      'ruoaksi', 'ruuaks',
      'translative singular', 'Adds -ksi for ''as'' or ''for'': ruoka becomes ruoaksi. Speech says ruuaks.', 'for dinner', 'food, meal', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-c1558b96eb03');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ruoaksi', 'ruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Adds -ksi for ''as'' or ''for'': ruoka becomes ruoaksi. Speech says ruuaks.', 'for dinner', 'food, meal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ruoaksi', 'ruoka',
      (select form_name_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks'),
      (select why_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks'),
      (select meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks'),
      (select lemma_meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks'),
      'translative singular', 'Adds -ksi for ''as'' or ''for'': ruoka becomes ruoaksi. Speech says ruuaks.', 'for dinner', 'food, meal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lohikeitto', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lohikeitto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lohi[X]loh[Sn][Ny]i[Bh][Bc][Ln][Xp]keitto[X]keitto[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp=ppppppp","WORDBASES":"+lohi(lohi)+keitto(keitto)"}'::jsonb,
      'lohikeittoa', 'lohikeittoo',
      'partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-03111121e507');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lohikeittoa', 'lohikeitto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lohikeittoa', 'lohikeitto',
      (select form_name_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select why_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      (select lemma_meaning_en from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo'),
      'partitive singular', 'The partitive singular is used for some soup: lohikeitto becomes lohikeittoa. Speech says lohikeittoo.', 'salmon soup', 'salmon soup';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('opetella', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"opetella","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]opettaa[X]opet[Xj]ella[X]tele[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+opet(opettaa)+ella(+ella)"}'::jsonb,
      'opettelen', 'opettelen',
      'present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-d0e407cc4c7c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'opettelen', 'opetella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'opettelen', 'opetella',
      (select form_name_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select why_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select meaning_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      (select lemma_meaning_en from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen'),
      'present tense, 1st person singular', 'Opetella, to learn, with -n for ''I'': opettelen.', 'I''m learning', 'to learn, to practise';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sp][Ny]sta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaista', 'suomalaista',
      'partitive singular', 'Suomalainen changes to suomalaista to match ruokaa: suomalaista ruokaa, ''Finnish food''.', 'Finnish', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-1f666b70966f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalaista', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Suomalainen changes to suomalaista to match ruokaa: suomalaista ruokaa, ''Finnish food''.', 'Finnish', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalaista', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista'),
      'partitive singular', 'Suomalainen changes to suomalaista to match ruokaa: suomalaista ruokaa, ''Finnish food''.', 'Finnish', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ruoka', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"ruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ruoka[X]ruok[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ruoka(ruoka)"}'::jsonb,
      'ruokaa', 'ruokaa',
      'partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-cbb6d60b2833');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ruokaa', 'ruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ruokaa', 'ruoka',
      (select form_name_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select why_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'),
      'partitive singular', 'Adds -a for food in general: ruoka becomes ruokaa.', 'food', 'food, meal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('idea', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"idea","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]idea[X]idea[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+idea(idea)"}'::jsonb,
      'idea', 'idea',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'idea', 'idea', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-46360d2dde05');
  end if;
  if not exists (select 1 from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'idea', 'idea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'idea', 'idea')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'idea', 'idea',
      (select form_name_en from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea'),
      (select why_en from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea'),
      (select meaning_en from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea'),
      (select lemma_meaning_en from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'idea', 'idea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsemme', 'tarvitaan',
      'present tense, 1st person plural', 'Books write me tarvitsemme. Speech says me tarvitaan, the same form as ''one needs'', for ''we need''.', 'we need', 'to need', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-35eeeaa204a3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsemme', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Books write me tarvitsemme. Speech says me tarvitaan, the same form as ''one needs'', for ''we need''.', 'we need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsemme', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan'),
      'present tense, 1st person plural', 'Books write me tarvitsemme. Speech says me tarvitaan, the same form as ''one needs'', for ''we need''.', 'we need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lohi', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lohi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lohi[X]loh[Sp][Ny]ta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lohi(lohi)"}'::jsonb,
      'lohta', 'lohta',
      'partitive singular', 'Lohi becomes lohta for some salmon: the i drops and -ta is added.', 'salmon', 'salmon', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-8f70a52faa6b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lohta', 'lohi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Lohi becomes lohta for some salmon: the i drops and -ta is added.', 'salmon', 'salmon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lohta', 'lohi',
      (select form_name_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta'),
      (select why_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta'),
      (select meaning_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta'),
      (select lemma_meaning_en from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta'),
      'partitive singular', 'Lohi becomes lohta for some salmon: the i drops and -ta is added.', 'salmon', 'salmon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('peruna', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"peruna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]peruna[X]peruno[Sp][Nm]ita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+peruna(peruna)"}'::jsonb,
      'perunoita', 'perunoita',
      'partitive plural', 'Plural ''some'' takes -ita: peruna becomes perunoita, the last a turning into o.', 'potatoes', 'potato', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-a822a7bdfc2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perunoita', 'peruna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ita: peruna becomes perunoita, the last a turning into o.', 'potatoes', 'potato')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perunoita', 'peruna',
      (select form_name_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita'),
      (select why_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita'),
      (select meaning_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita'),
      (select lemma_meaning_en from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita'),
      'partitive plural', 'Plural ''some'' takes -ita: peruna becomes perunoita, the last a turning into o.', 'potatoes', 'potato';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('porkkana', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"porkkana","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]porkkana[X]porkkano[Sp][Nm]ita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+porkkana(porkkana)"}'::jsonb,
      'porkkanoita', 'porkkanoita',
      'partitive plural', 'Plural ''some'' takes -ita: porkkana becomes porkkanoita, the last a turning into o.', 'carrots', 'carrot', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-c127393937f5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'porkkanoita', 'porkkana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ita: porkkana becomes porkkanoita, the last a turning into o.', 'carrots', 'carrot')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'porkkanoita', 'porkkana',
      (select form_name_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita'),
      (select why_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita'),
      (select meaning_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita'),
      (select lemma_meaning_en from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita'),
      'partitive plural', 'Plural ''some'' takes -ita: porkkana becomes porkkanoita, the last a turning into o.', 'carrots', 'carrot';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kerma', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kerma","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kerma[X]kerm[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kerma(kerma)"}'::jsonb,
      'kermaa', 'kermaa',
      'partitive singular', 'The partitive singular is used for some cream: kerma becomes kermaa.', 'cream', 'cream', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-095ba3df9042');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kermaa', 'kerma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some cream: kerma becomes kermaa.', 'cream', 'cream')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kermaa', 'kerma',
      (select form_name_en from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa'),
      (select why_en from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa'),
      (select meaning_en from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa'),
      'partitive singular', 'The partitive singular is used for some cream: kerma becomes kermaa.', 'cream', 'cream';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tilli', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"tilli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tilli[X]till[Sp][Ny]iä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+tilli(tilli)"}'::jsonb,
      'tilliä', 'tilliä',
      'partitive singular', 'Adds -ä for some dill: tilli becomes tilliä.', 'dill', 'dill', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-7a8ac0635e6b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tilliä', 'tilli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -ä for some dill: tilli becomes tilliä.', 'dill', 'dill')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tilliä', 'tilli',
      (select form_name_en from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä'),
      (select why_en from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä'),
      (select meaning_en from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä'),
      (select lemma_meaning_en from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä'),
      'partitive singular', 'Adds -ä for some dill: tilli becomes tilliä.', 'dill', 'dill';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sade][Nm]illä","NUMBER":"plural","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppp","WORDBASES":"+me(me)"}'::jsonb,
      'meillä', 'meil',
      'adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-a9fe1350b93e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'meillä', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'meillä', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil'),
      'adessive plural', 'Me takes -llä for ''has'': meillä on, ''we have''. Speech shortens -llä to -l: meillä becomes meil.', 'we have', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sipuli', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"sipuli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sipuli[X]sipul[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+sipuli(sipuli)"}'::jsonb,
      'sipulia', 'sipulii',
      'partitive singular', 'Adds -a for some onion: sipuli becomes sipulia. Speech turns the a into i: sipulii.', 'onions', 'onion', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-99824ee93d30');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sipulia', 'sipuli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a for some onion: sipuli becomes sipulia. Speech turns the a into i: sipulii.', 'onions', 'onion')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sipulia', 'sipuli',
      (select form_name_en from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii'),
      (select why_en from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii'),
      (select meaning_en from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii'),
      (select lemma_meaning_en from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii'),
      'partitive singular', 'Adds -a for some onion: sipuli becomes sipulia. Speech turns the a into i: sipulii.', 'onions', 'onion';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"olla","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'ole', 'oo',
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-0fcdf4079f8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ole', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ole', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirjoittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kirjoittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kirjoittaa[X]kirjoita[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+kirjoittaa(kirjoittaa)"}'::jsonb,
      'kirjoita', 'kirjota',
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-bdca70f64fa7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjoita', 'kirjoittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjoita', 'kirjoittaa',
      (select form_name_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select why_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      (select lemma_meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota'),
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lista', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"lista","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lista[X]list[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+lista(lista)"}'::jsonb,
      'listaan', 'listaan',
      'illative singular', 'Adds -an for ''into'': lista becomes listaan. You write it into the list.', 'on the list', 'list', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-5ec5afde09ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'listaan', 'lista';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -an for ''into'': lista becomes listaan. You write it into the list.', 'on the list', 'list')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'listaan', 'lista',
      (select form_name_en from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan'),
      (select why_en from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan'),
      (select meaning_en from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan'),
      (select lemma_meaning_en from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan'),
      'illative singular', 'Adds -an for ''into'': lista becomes listaan. You write it into the list.', 'on the list', 'list';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennään', 'mennään',
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-e184450d7d09');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennään', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennään', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'),
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauppa', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"kauppa","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kauppa[X]kaupp[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+kauppa(kauppa)"}'::jsonb,
      'kauppaan', 'kauppaan',
      'illative singular', 'Adds -an for ''to'': kauppa becomes kauppaan.', 'to the shop', 'shop, store', 'approved', now(), 'content/approvals/part-4.json#the-shopping-list/form-8974894f8fac');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauppaan', 'kauppa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -an for ''to'': kauppa becomes kauppaan.', 'to the shop', 'shop, store')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauppaan', 'kauppa',
      (select form_name_en from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan'),
      (select why_en from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan'),
      (select meaning_en from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan'),
      (select lemma_meaning_en from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan'),
      'illative singular', 'Adds -an for ''to'': kauppa becomes kauppaan.', 'to the shop', 'shop, store';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Mitä me tehään ruuaks?',
    'Mitä me teemme ruoaksi?', 'What shall we make for dinner?',
    'the-shopping-list/1-puhe-3927486dfa15.mp3', 'the-shopping-list/1-kirja-8c34e16bba18.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 3, 'teemme', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään')),
    (v_line_id, 'kirja', 4, 'ruoaksi', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 3, 'tehään', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teemme' and surface_puhe = 'tehään')),
    (v_line_id, 'puhe', 4, 'ruuaks', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'ruoaksi' and surface_puhe = 'ruuaks'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Lohikeittoo! Mä opettelen suomalaista ruokaa.',
    'Lohikeittoa! Minä opettelen suomalaista ruokaa.', 'Salmon soup! I''m learning Finnish food.',
    'the-shopping-list/2-puhe-31875ae70fb7.mp3', 'the-shopping-list/2-kirja-aab3a258edf4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lohikeittoa', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen')),
    (v_line_id, 'kirja', 4, 'suomalaista', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista')),
    (v_line_id, 'kirja', 5, 'ruokaa', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa')),
    (v_line_id, 'puhe', 1, 'Lohikeittoo', (select id from public.forms where lemma = 'lohikeitto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohikeittoa' and surface_puhe = 'lohikeittoo')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'opettelen', (select id from public.forms where lemma = 'opetella' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'opettelen' and surface_puhe = 'opettelen')),
    (v_line_id, 'puhe', 4, 'suomalaista', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaista' and surface_puhe = 'suomalaista')),
    (v_line_id, 'puhe', 5, 'ruokaa', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'ruokaa' and surface_puhe = 'ruokaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'Hyvä idea. Mitä me tarvitaan?',
    'Hyvä idea. Mitä me tarvitsemme?', 'Good idea. What do we need?',
    'the-shopping-list/3-puhe-721ba7497805.mp3', 'the-shopping-list/3-kirja-54f50528d243.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'idea', (select id from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea')),
    (v_line_id, 'kirja', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 4, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 5, 'tarvitsemme', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'idea', (select id from public.forms where lemma = 'idea' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'idea' and surface_puhe = 'idea')),
    (v_line_id, 'puhe', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 4, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 5, 'tarvitaan', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsemme' and surface_puhe = 'tarvitaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Lohta, perunoita ja porkkanoita.',
    'Lohta, perunoita ja porkkanoita.', 'Salmon, potatoes and carrots.',
    'the-shopping-list/4-puhe-39608e04ec9e.mp3', 'the-shopping-list/4-kirja-3871506b4149.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lohta', (select id from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta')),
    (v_line_id, 'kirja', 2, 'perunoita', (select id from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita')),
    (v_line_id, 'kirja', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'porkkanoita', (select id from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita')),
    (v_line_id, 'puhe', 1, 'Lohta', (select id from public.forms where lemma = 'lohi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lohta' and surface_puhe = 'lohta')),
    (v_line_id, 'puhe', 2, 'perunoita', (select id from public.forms where lemma = 'peruna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'perunoita' and surface_puhe = 'perunoita')),
    (v_line_id, 'puhe', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'porkkanoita', (select id from public.forms where lemma = 'porkkana' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'porkkanoita' and surface_puhe = 'porkkanoita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Ja kermaa ja tilliä.',
    'Ja kermaa ja tilliä.', 'And cream and dill.',
    'the-shopping-list/5-puhe-2fae619d87d8.mp3', 'the-shopping-list/5-kirja-76cb50032c85.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'kermaa', (select id from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa')),
    (v_line_id, 'kirja', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'tilliä', (select id from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'kermaa', (select id from public.forms where lemma = 'kerma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kermaa' and surface_puhe = 'kermaa')),
    (v_line_id, 'puhe', 3, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'tilliä', (select id from public.forms where lemma = 'tilli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'tilliä' and surface_puhe = 'tilliä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Onks meil sipulii?',
    'Onko meillä sipulia?', 'Do we have onions?',
    'the-shopping-list/6-puhe-3969386db2a8.mp3', 'the-shopping-list/6-kirja-dd9df8e77c15.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'meillä', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil')),
    (v_line_id, 'kirja', 3, 'sipulia', (select id from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'meil', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=plural' and surface_kirja = 'meillä' and surface_puhe = 'meil')),
    (v_line_id, 'puhe', 3, 'sipulii', (select id from public.forms where lemma = 'sipuli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sipulia' and surface_puhe = 'sipulii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Ei oo. Kirjota se listaan.',
    'Ei ole. Kirjoita se listaan.', 'No. Write it on the list.',
    'the-shopping-list/7-puhe-4badf961486b.mp3', 'the-shopping-list/7-kirja-28fdddf77a19.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'kirja', 3, 'Kirjoita', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'kirja', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 5, 'listaan', (select id from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'oo', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'puhe', 3, 'Kirjota', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 5, 'listaan', (select id from public.forms where lemma = 'lista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'listaan' and surface_puhe = 'listaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Okei. Mennään kauppaan!',
    'Selvä. Mennään kauppaan!', 'OK. Let''s go to the shop!',
    'the-shopping-list/8-puhe-461bd9f4e026.mp3', 'the-shopping-list/8-kirja-c01ac19e35ee.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'kirja', 3, 'kauppaan', (select id from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'puhe', 3, 'kauppaan', (select id from public.forms where lemma = 'kauppa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kauppaan' and surface_puhe = 'kauppaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#the-shopping-list/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
