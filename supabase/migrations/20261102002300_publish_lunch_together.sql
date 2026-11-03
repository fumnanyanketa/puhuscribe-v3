-- Publishes the dialogue lunch-together (unit making-a-plan). Made by
-- scripts/generate/pipeline.py publish from content/drafts/lunch-together. Do not edit by hand:
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
    where slug = 'lunch-together' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'lunch-together';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 8
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'making-a-plan' and position = 8 and stop_number = 8;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'making-a-plan';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'lunch-together', 3,
    'Lunch together?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'lunch-together' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Lunch together?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'lunch-together';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähteä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"lähteä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähteä[X]lähdet[Tt][Ap][P4][Ef]ään[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppppp","TENSE":"present_simple","WORDBASES":"+lähteä(lähteä)"}'::jsonb,
      'lähdetäänkö', 'lähetäänks',
      'present tense, passive, with the question ending -ko/-kö', 'Lähdetään, let''s go, with -kö to ask. Speech drops the d and says -ks.', 'shall we go?', 'to leave, to go', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-310777efe68f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähdetäänkö', 'lähteä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive, with the question ending -ko/-kö', 'Lähdetään, let''s go, with -kö to ask. Speech drops the d and says -ks.', 'shall we go?', 'to leave, to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähdetäänkö', 'lähteä',
      (select form_name_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks'),
      (select why_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks'),
      (select meaning_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks'),
      (select lemma_meaning_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks'),
      'present tense, passive, with the question ending -ko/-kö', 'Lähdetään, let''s go, with -kö to ask. Speech drops the d and says -ks.', 'shall we go?', 'to leave, to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syödä', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"syödä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]syödä[X]syö[Tn3][Ny][Sill]mään","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+syödä(syödä)"}'::jsonb,
      'syömään', 'syömään',
      'MA-infinitive, illative', 'Syödä with -mään after a verb of going: lähteä syömään, go to eat.', 'to eat', 'to eat', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-030a6c23a310');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syömään', 'syödä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'Syödä with -mään after a verb of going: lähteä syömään, go to eat.', 'to eat', 'to eat')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syömään', 'syödä',
      (select form_name_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään'),
      (select why_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään'),
      (select meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään'),
      (select lemma_meaning_en from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään'),
      'MA-infinitive, illative', 'Syödä with -mään after a verb of going: lähteä syömään, go to eat.', 'to eat', 'to eat';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-f42052a3d5f2');
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
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennään', 'mennään',
      'present tense, passive', 'The passive form means ''let''s'' here: mennään, let''s go.', 'let''s go', 'to go', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-e184450d7d09');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuossa', 'tos',
      'inessive singular', 'Tuo, that, with -ssa: tuossa, there. Speech says tos.', 'there', 'that', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-8e6317edf047');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuossa', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Tuo, that, with -ssa: tuossa, there. Speech says tos.', 'there', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuossa', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos'),
      'inessive singular', 'Tuo, that, with -ssa: tuossa, there. Speech says tos.', 'there', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kulma', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kulma","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]kulma[X]kulma[Sine][Ny]ssa","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+kulma(kulma)"}'::jsonb,
      'kulmassa', 'kulmas',
      'inessive singular', 'Kulma with -ssa for ''in, on'': kulmassa. Speech shortens -ssa to -s: kulmassa becomes kulmas.', 'on the corner', 'corner', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-daee785cf008');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kulmassa', 'kulma';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Kulma with -ssa for ''in, on'': kulmassa. Speech shortens -ssa to -s: kulmassa becomes kulmas.', 'on the corner', 'corner')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kulmassa', 'kulma',
      (select form_name_en from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas'),
      (select why_en from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas'),
      (select meaning_en from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas'),
      (select lemma_meaning_en from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas'),
      'inessive singular', 'Kulma with -ssa for ''in, on'': kulmassa. Speech shortens -ssa to -s: kulmassa becomes kulmas.', 'on the corner', 'corner';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lounaspaikka', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lounaspaikka","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]lounas[X]louna[Sn][Ny]s[Bh][Bc][Ln][Xp]paikka[X]paikk[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=pppppp","WORDBASES":"+lounas(lounas)+paikka(paikka)"}'::jsonb,
      'lounaspaikka', 'lounaspaikka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch place', 'lunch place', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-9e27db12aedc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lounaspaikka', 'lounaspaikka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch place', 'lunch place')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lounaspaikka', 'lounaspaikka',
      (select form_name_en from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka'),
      (select why_en from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka'),
      (select meaning_en from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka'),
      (select lemma_meaning_en from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lunch place', 'lunch place';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('heti', 'CLASS=seikkasana', '{"BASEFORM":"heti","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]heti[X]heti","STRUCTURE":"=pppp","WORDBASES":"+heti(heti)"}'::jsonb,
      'heti', 'heti',
      'adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-78a5f0b146da');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-cc0fdb024b55');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulla', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulla', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul'),
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-2b3844766909');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vielä', 'vielä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vielä', 'vielä',
      (select form_name_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select why_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      (select lemma_meaning_en from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yksi', 'yks',
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-77de6561f822');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yksi', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yksi', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks'),
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asia', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"asia","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asia[X]asia[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+asia(asia)"}'::jsonb,
      'asia', 'juttu',
      'nominative singular', 'Juttu is the everyday spoken word for a thing. Books write asia.', 'thing', 'thing, matter', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-7dabbf8a5d02');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asia', 'asia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Juttu is the everyday spoken word for a thing. Books write asia.', 'thing', 'thing, matter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asia', 'asia',
      (select form_name_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu'),
      (select why_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu'),
      (select meaning_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu'),
      (select lemma_meaning_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu'),
      'nominative singular', 'Juttu is the everyday spoken word for a thing. Books write asia.', 'thing', 'thing, matter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb][Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käykö', 'käyks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-5941266599a1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käykö', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käykö', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Käy, it works, with -kö to ask. Speech says -ks: käyks.', 'is it OK?', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vartti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"vartti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vartti[X]vart[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+vartti(vartti)"}'::jsonb,
      'vartin', 'vartin',
      'genitive singular', 'Vartti with -n before päästä, and tt turns to t: vartin päästä, in fifteen minutes.', 'a quarter of an hour', 'quarter of an hour', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-de3142e545c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vartin', 'vartti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Vartti with -n before päästä, and tt turns to t: vartin päästä, in fifteen minutes.', 'a quarter of an hour', 'quarter of an hour')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vartin', 'vartti',
      (select form_name_en from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin'),
      (select why_en from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin'),
      (select meaning_en from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin'),
      (select lemma_meaning_en from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin'),
      'genitive singular', 'Vartti with -n before päästä, and tt turns to t: vartin päästä, in fifteen minutes.', 'a quarter of an hour', 'quarter of an hour';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"päästä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]päästä[X]pääst[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+päästä(päästä)"}'::jsonb,
      'päästä', 'päästä',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to get (somewhere), to get in', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-c5dcc023ac08');
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
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käy', 'käy',
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-24f89699a032');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käy', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käy', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy'),
      'present tense, 3rd person singular', 'Käydä in the form for he, she or it. Ei käy means it doesn''t work.', 'works', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('odottaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"odottaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]odottaa[X]odota[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+odottaa(odottaa)"}'::jsonb,
      'odotan', 'odotan',
      'present tense, 1st person singular', 'Odottaa, to wait, with -n for ''I'', and tt turns to t: odotan.', 'I''ll wait', 'to wait', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-cc3ddf2504b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'odotan', 'odottaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Odottaa, to wait, with -n for ''I'', and tt turns to t: odotan.', 'I''ll wait', 'to wait')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'odotan', 'odottaa',
      (select form_name_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan'),
      (select why_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan'),
      (select meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan'),
      (select lemma_meaning_en from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan'),
      'present tense, 1st person singular', 'Odottaa, to wait, with -n for ''I'', and tt turns to t: odotan.', 'I''ll wait', 'to wait';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alaovi', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"alaovi","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]ala[X]al[Sn][Ny]a[Bh][Bc][Ln][Xp]ovi[X]ove[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppp=pppppp","WORDBASES":"+ala(ala)+ovi(ovi)"}'::jsonb,
      'alaovella', 'alaovella',
      'adessive singular', 'Alaovi with -lla for ''at'', and i turns to e: alaovella.', 'at the front door', 'front door (downstairs)', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-446bcc4fb0e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alaovella', 'alaovi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Alaovi with -lla for ''at'', and i turns to e: alaovella.', 'at the front door', 'front door (downstairs)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alaovella', 'alaovi',
      (select form_name_en from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella'),
      (select why_en from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella'),
      (select meaning_en from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella'),
      (select lemma_meaning_en from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella'),
      'adessive singular', 'Alaovi with -lla for ''at'', and i turns to e: alaovella.', 'at the front door', 'front door (downstairs)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pyytää', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"pyytää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]pyytää[X]pyydet[Tt][Ap][P4][Ef]ään[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppppp","TENSE":"present_simple","WORDBASES":"+pyytää(pyytää)"}'::jsonb,
      'pyydetäänkö', 'pyydetäänks',
      'present tense, passive, with the question ending -ko/-kö', 'Pyydetään, let''s ask, with -kö to ask. Speech says -ks: pyydetäänks.', 'shall we ask?', 'to ask (for), to invite', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-838bd34a0bfc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pyydetäänkö', 'pyytää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive, with the question ending -ko/-kö', 'Pyydetään, let''s ask, with -kö to ask. Speech says -ks: pyydetäänks.', 'shall we ask?', 'to ask (for), to invite')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pyydetäänkö', 'pyytää',
      (select form_name_en from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks'),
      (select why_en from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks'),
      (select meaning_en from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks'),
      (select lemma_meaning_en from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks'),
      'present tense, passive, with the question ending -ko/-kö', 'Pyydetään, let''s ask, with -kö to ask. Speech says -ks: pyydetäänks.', 'shall we ask?', 'to ask (for), to invite';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukaan', 'CLASS=seikkasana', '{"BASEFORM":"mukaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]mukaan[X]mukaan","STRUCTURE":"=pppppp","WORDBASES":"+mukaan(mukaan)"}'::jsonb,
      'mukaan', 'mukaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-769eb876232e');
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
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kysyä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"kysyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kysyä[X]kysy[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+kysyä(kysyä)"}'::jsonb,
      'kysyn', 'kysyn',
      'present tense, 1st person singular', 'Kysyä, to ask, with -n for ''I'': kysyn.', 'I''ll ask', 'to ask (a question)', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-d59b172c61ed');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kysyn', 'kysyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Kysyä, to ask, with -n for ''I'': kysyn.', 'I''ll ask', 'to ask (a question)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kysyn', 'kysyä',
      (select form_name_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn'),
      (select why_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn'),
      (select meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn'),
      (select lemma_meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn'),
      'present tense, 1st person singular', 'Kysyä, to ask, with -n for ''I'': kysyn.', 'I''ll ask', 'to ask (a question)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sabl][Ny]neltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'häneltä', 'siltä',
      'ablative singular', 'Hän with -ltä for ''from'': kysyä häneltä. Speech uses se for people: siltä.', '(ask) her', 'he, she', 'approved', now(), 'content/approvals/part-2.json#lunch-together/form-d8eaec86253c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'häneltä', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Hän with -ltä for ''from'': kysyä häneltä. Speech uses se for people: siltä.', '(ask) her', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'häneltä', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä'),
      'ablative singular', 'Hän with -ltä for ''from'': kysyä häneltä. Speech uses se for people: siltä.', '(ask) her', 'he, she';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ville', 'Lähetäänks syömään?',
    'Lähdetäänkö syömään?', 'Shall we go and eat?',
    'lunch-together/1-puhe-1ae6ae1fce58.mp3', 'lunch-together/1-kirja-9d6b15ea767e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Lähdetäänkö', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks')),
    (v_line_id, 'kirja', 2, 'syömään', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään')),
    (v_line_id, 'puhe', 1, 'Lähetäänks', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks')),
    (v_line_id, 'puhe', 2, 'syömään', (select id from public.forms where lemma = 'syödä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'syömään' and surface_puhe = 'syömään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Joo! Mihin mennään?',
    'Kyllä! Mihin mennään?', 'Yes! Where shall we go?',
    'lunch-together/2-puhe-ce16f727aded.mp3', 'lunch-together/2-kirja-419cc1cd606a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 3, 'mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 3, 'mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'mennään' and surface_puhe = 'mennään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ville', 'Tos kulmas on hyvä lounaspaikka.',
    'Tuossa kulmassa on hyvä lounaspaikka.', 'There''s a good lunch place on that corner.',
    'lunch-together/3-puhe-f2ea0de9b118.mp3', 'lunch-together/3-kirja-b350d2b37148.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tuossa', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos')),
    (v_line_id, 'kirja', 2, 'kulmassa', (select id from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 5, 'lounaspaikka', (select id from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka')),
    (v_line_id, 'puhe', 1, 'Tos', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos')),
    (v_line_id, 'puhe', 2, 'kulmas', (select id from public.forms where lemma = 'kulma' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kulmassa' and surface_puhe = 'kulmas')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 5, 'lounaspaikka', (select id from public.forms where lemma = 'lounaspaikka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lounaspaikka' and surface_puhe = 'lounaspaikka'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Okei. Lähetäänks heti?',
    'Selvä. Lähdetäänkö heti?', 'OK. Shall we go right away?',
    'lunch-together/4-puhe-cb36d0126707.mp3', 'lunch-together/4-kirja-4c77544dec3f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Lähdetäänkö', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks')),
    (v_line_id, 'kirja', 3, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Lähetäänks', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'lähdetäänkö' and surface_puhe = 'lähetäänks')),
    (v_line_id, 'puhe', 3, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ville', 'Mul on vielä yks juttu. Käyks vartin päästä?',
    'Minulla on vielä yksi asia. Käykö vartin päästä?', 'I still have one thing to do. Is fifteen minutes OK?',
    'lunch-together/5-puhe-5f62b52bae7f.mp3', 'lunch-together/5-kirja-018fce6e9dec.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'kirja', 4, 'yksi', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'kirja', 5, 'asia', (select id from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu')),
    (v_line_id, 'kirja', 6, 'Käykö', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks')),
    (v_line_id, 'kirja', 7, 'vartin', (select id from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin')),
    (v_line_id, 'kirja', 8, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä')),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 4, 'yks', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'puhe', 5, 'juttu', (select id from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asia' and surface_puhe = 'juttu')),
    (v_line_id, 'puhe', 6, 'Käyks', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'käykö' and surface_puhe = 'käyks')),
    (v_line_id, 'puhe', 7, 'vartin', (select id from public.forms where lemma = 'vartti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'vartin' and surface_puhe = 'vartin')),
    (v_line_id, 'puhe', 8, 'päästä', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'päästä' and surface_puhe = 'päästä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Käy. Mä odotan alaovella.',
    'Käy. Minä odotan alaovella.', 'Fine. I''ll wait at the front door.',
    'lunch-together/6-puhe-4e57a81ad558.mp3', 'lunch-together/6-kirja-5d4023bf30b9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'odotan', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan')),
    (v_line_id, 'kirja', 4, 'alaovella', (select id from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella')),
    (v_line_id, 'puhe', 1, 'Käy', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'käy' and surface_puhe = 'käy')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'odotan', (select id from public.forms where lemma = 'odottaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'odotan' and surface_puhe = 'odotan')),
    (v_line_id, 'puhe', 4, 'alaovella', (select id from public.forms where lemma = 'alaovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alaovella' and surface_puhe = 'alaovella'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ville', 'Hyvä. Pyydetäänks Ainokin mukaan?',
    'Hyvä. Pyydetäänkö Ainokin mukaan?', 'Good. Shall we ask Aino along too?',
    'lunch-together/7-puhe-21d32a94ef92.mp3', 'lunch-together/7-kirja-b1984a7cc33b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Pyydetäänkö', (select id from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks')),
    (v_line_id, 'kirja', 3, 'Ainokin', null),
    (v_line_id, 'kirja', 4, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Pyydetäänks', (select id from public.forms where lemma = 'pyytää' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pyydetäänkö' and surface_puhe = 'pyydetäänks')),
    (v_line_id, 'puhe', 3, 'Ainokin', null),
    (v_line_id, 'puhe', 4, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Joo, mä kysyn siltä.',
    'Kyllä, minä kysyn häneltä.', 'Yes, I''ll ask her.',
    'lunch-together/8-puhe-755adb6acac7.mp3', 'lunch-together/8-kirja-fcae83dfe76f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'kysyn', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn')),
    (v_line_id, 'kirja', 4, 'häneltä', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'kysyn', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kysyn' and surface_puhe = 'kysyn')),
    (v_line_id, 'puhe', 4, 'siltä', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'häneltä' and surface_puhe = 'siltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#lunch-together/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-2.json#lunch-together/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
