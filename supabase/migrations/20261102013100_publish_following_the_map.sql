-- Publishes the dialogue following-the-map (unit directions-in-the-city). Made by
-- scripts/generate/pipeline.py publish from content/drafts/following-the-map. Do not edit by hand:
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
    where slug = 'following-the-map' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'following-the-map';
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
  values (v_unit_id, 'following-the-map', 2,
    'Following the map')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'following-the-map' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Following the map';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'following-the-map';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-f42052a3d5f2');
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
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suunta', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"suunta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suunta[X]suunt[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppp","WORDBASES":"+suunta(suunta)"}'::jsonb,
      'suuntaan', 'päin',
      'illative singular', 'Books write mihin suuntaan, ''in which direction''. Speech says mihin päin, ''which way''.', 'which way', 'direction', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-cc5e802670d9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suuntaan', 'suunta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Books write mihin suuntaan, ''in which direction''. Speech says mihin päin, ''which way''.', 'which way', 'direction')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suuntaan', 'suunta',
      (select form_name_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin'),
      (select why_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin'),
      (select meaning_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin'),
      (select lemma_meaning_en from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin'),
      'illative singular', 'Books write mihin suuntaan, ''in which direction''. Speech says mihin päin, ''which way''.', 'which way', 'direction';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menemme', 'mennään',
      'present tense, 1st person plural', 'Speech uses mennään with me, ''we''. Books write menemme.', 'we go', 'to go', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-1cbcb0b62bb7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menemme', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Speech uses mennään with me, ''we''. Books write menemme.', 'we go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menemme', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään'),
      'present tense, 1st person plural', 'Speech uses mennään with me, ''we''. Books write menemme.', 'we go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kartta', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kartta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kartta[X]kart[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+kartta(kartta)"}'::jsonb,
      'kartan', 'kartan',
      'genitive singular', 'Mukaan, ''according to'', needs -n on the word before: kartta becomes kartan.', 'the map', 'map', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-5b656146997c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kartan', 'kartta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Mukaan, ''according to'', needs -n on the word before: kartta becomes kartan.', 'the map', 'map')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kartan', 'kartta',
      (select form_name_en from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan'),
      (select why_en from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan'),
      (select meaning_en from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan'),
      (select lemma_meaning_en from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan'),
      'genitive singular', 'Mukaan, ''according to'', needs -n on the word before: kartta becomes kartan.', 'the map', 'map';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukaan', 'CLASS=seikkasana', '{"BASEFORM":"mukaan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]mukaan[X]mukaan","STRUCTURE":"=pppppp","WORDBASES":"+mukaan(mukaan)"}'::jsonb,
      'mukaan', 'mukaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'along, with you, according to', 'along, with you, according to', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-769eb876232e');
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
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oikea', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"oikea","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]oikea[X]oikea[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppp","WORDBASES":"+oikea(oikea)"}'::jsonb,
      'oikealle', 'oikeelle',
      'allative singular', 'Oikea, right, with -lle for ''to''. Speech turns -ea into -ee: oikeelle.', 'to the right', 'right, correct', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-88962e9bc943');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oikealle', 'oikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Oikea, right, with -lle for ''to''. Speech turns -ea into -ee: oikeelle.', 'to the right', 'right, correct')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oikealle', 'oikea',
      (select form_name_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle'),
      (select why_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle'),
      (select meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle'),
      (select lemma_meaning_en from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle'),
      'allative singular', 'Oikea, right, with -lle for ''to''. Speech turns -ea into -ee: oikeelle.', 'to the right', 'right, correct';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuon', 'ton',
      'genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-e5b38e62bbf5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuon', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuon', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      'genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('silta', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"silta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]silta[X]sill[Sg][Ny]an","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+silta(silta)"}'::jsonb,
      'sillan', 'sillan',
      'genitive singular', 'Yli, ''over'', needs -n on the word before: silta becomes sillan, lt turning into ll.', 'the bridge', 'bridge', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-b1ecb4f2e254');
  end if;
  if not exists (select 1 from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sillan', 'silta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Yli, ''over'', needs -n on the word before: silta becomes sillan, lt turning into ll.', 'the bridge', 'bridge')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sillan', 'silta',
      (select form_name_en from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan'),
      (select why_en from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan'),
      (select meaning_en from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan'),
      (select lemma_meaning_en from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan'),
      'genitive singular', 'Yli, ''over'', needs -n on the word before: silta becomes sillan, lt turning into ll.', 'the bridge', 'bridge';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yli', 'CLASS=suhdesana', '{"BASEFORM":"yli","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]yli[X]yli","STRUCTURE":"=ppp","WORDBASES":"+yli(yli)"}'::jsonb,
      'yli', 'yli',
      'adposition', 'This is the dictionary form. People say it the same way.', 'over, past', 'over, past', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-e51df5672690');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yli', 'yli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'This is the dictionary form. People say it the same way.', 'over, past', 'over, past')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yli', 'yli',
      (select form_name_en from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli'),
      (select why_en from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli'),
      (select meaning_en from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli'),
      (select lemma_meaning_en from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli'),
      'adposition', 'This is the dictionary form. People say it the same way.', 'over, past', 'over, past';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suora', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suora","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suora[X]suor[Sill][Ny]aan","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+suora(suora)"}'::jsonb,
      'suoraan', 'suoraan',
      'illative singular', 'Suora, straight, with -an: suoraan, straight ahead.', 'straight ahead', 'straight', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-5365495a5c62');
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
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauan', 'CLASS=seikkasana', '{"BASEFORM":"kauan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauan[X]kauan","STRUCTURE":"=ppppp","WORDBASES":"+kauan(kauan)"}'::jsonb,
      'kauan', 'kauan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'long (time)', 'long (time)', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-4a10d56e4c31');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauan', 'kauan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'long (time)', 'long (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauan', 'kauan',
      (select form_name_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan'),
      (select why_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan'),
      (select meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan'),
      (select lemma_meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'long (time)', 'long (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-2b3844766909');
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
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viisi', 'viis',
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-56e27afb5a19');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viisi', 'viisi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viisi', 'viisi',
      (select form_name_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select why_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      (select lemma_meaning_en from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis'),
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minuutti', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"minuutti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]minuutti[X]minuutt[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+minuutti(minuutti)"}'::jsonb,
      'minuuttia', 'minuuttii',
      'partitive singular', 'After a number the noun takes the partitive: kymmenen minuuttia. Speech turns -ia into -ii.', 'minutes', 'minute', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-2ba98cc25249');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puisto', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"puisto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]puisto[X]puisto[Sg][Ny]n","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+puisto(puisto)"}'::jsonb,
      'puiston', 'puiston',
      'genitive singular', 'Takana, ''behind'', needs -n on the word before: puisto becomes puiston.', 'the park', 'park', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-5208a66d06d0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puiston', 'puisto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Takana, ''behind'', needs -n on the word before: puisto becomes puiston.', 'the park', 'park')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puiston', 'puisto',
      (select form_name_en from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston'),
      (select why_en from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston'),
      (select meaning_en from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston'),
      (select lemma_meaning_en from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston'),
      'genitive singular', 'Takana, ''behind'', needs -n on the word before: puisto becomes puiston.', 'the park', 'park';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takana', 'CLASS=seikkasana', '{"BASEFORM":"takana","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]takana[X]takana","STRUCTURE":"=pppppp","WORDBASES":"+takana(takana)"}'::jsonb,
      'takana', 'takana',
      'adverb', 'This is the dictionary form. People say it the same way.', 'behind, at the back', 'behind, at the back', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-c0ea18440ede');
  end if;
  if not exists (select 1 from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'takana', 'takana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'behind, at the back', 'behind, at the back')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'takana', 'takana',
      (select form_name_en from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana'),
      (select why_en from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana'),
      (select meaning_en from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana'),
      (select lemma_meaning_en from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'behind, at the back', 'behind, at the back';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuo', 'toi',
      'nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-e7513afe9e6b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuo', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuo', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi'),
      'nominative singular', 'Tuo means that. Speech says toi.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varmaan', 'CLASS=seikkasana', '{"BASEFORM":"varmaan","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'varmaan', 'varmaan',
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably', 'probably', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-2c21757d03b1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'varmaan', 'varmaan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'probably', 'probably')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'varmaan', 'varmaan',
      (select form_name_en from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan'),
      (select why_en from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan'),
      (select meaning_en from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan'),
      (select lemma_meaning_en from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably', 'probably';
  end if;
  if not exists (select 1 from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('punainen', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"punainen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]puna[X]puna[Ll][Xj]inen[X]i[Sn][Ny]nen","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+puna(puna)+inen(+inen)"}'::jsonb,
      'punainen', 'punanen',
      'nominative singular', 'This is the dictionary form. Speech drops the i: punanen.', 'red', 'red', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-8e5453d03c67');
  end if;
  if not exists (select 1 from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'punainen', 'punainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. Speech drops the i: punanen.', 'red', 'red')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'punainen', 'punainen',
      (select form_name_en from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen'),
      (select why_en from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen'),
      (select meaning_en from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen'),
      (select lemma_meaning_en from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen'),
      'nominative singular', 'This is the dictionary form. Speech drops the i: punanen.', 'red', 'red';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talo', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"talo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]talo[X]talo[Sn][Ny]","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+talo(talo)"}'::jsonb,
      'talo', 'talo',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'house, building', 'house, building', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-829ac69bd301');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talo', 'talo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'house, building', 'house, building')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talo', 'talo',
      (select form_name_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo'),
      (select why_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo'),
      (select meaning_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo'),
      (select lemma_meaning_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'house, building', 'house, building';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juuri', 'CLASS=seikkasana', '{"BASEFORM":"juuri","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]juuri[X]juuri","STRUCTURE":"=ppppp","WORDBASES":"+juuri(juuri)"}'::jsonb,
      'juuri', 'just',
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-57dd552fb07a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juuri', 'juuri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juuri', 'juuri',
      (select form_name_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select why_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select lemma_meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-4f1448504014');
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niin', 'niin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niin', 'niin',
      (select form_name_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select why_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      (select lemma_meaning_en from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-9f0f9f1fdd21');
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
      'present tense, 1st person plural', 'Books write me olemme. Speech says me ollaan, the same form as ''one is'', for ''we are''.', 'we are', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-7d01f19d8e6b');
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
  if not exists (select 1 from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perillä', 'CLASS=seikkasana', '{"BASEFORM":"perillä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]perillä[X]perillä","STRUCTURE":"=ppppppp","WORDBASES":"+perillä(perillä)"}'::jsonb,
      'perillä', 'perillä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'there, at your destination', 'there, at your destination', 'approved', now(), 'content/approvals/part-6.json#following-the-map/form-b3cdcf142713');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perillä', 'perillä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'there, at your destination', 'there, at your destination')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perillä', 'perillä',
      (select form_name_en from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä'),
      (select why_en from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä'),
      (select meaning_en from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä'),
      (select lemma_meaning_en from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'there, at your destination', 'there, at your destination';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Mihin päin mennään?',
    'Mihin suuntaan menemme?', 'Which way do we go?',
    'following-the-map/1-puhe-dc9c21be758d.mp3', 'following-the-map/1-kirja-dd970d3153ea.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 2, 'suuntaan', (select id from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin')),
    (v_line_id, 'kirja', 3, 'menemme', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään')),
    (v_line_id, 'puhe', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 2, 'päin', (select id from public.forms where lemma = 'suunta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'suuntaan' and surface_puhe = 'päin')),
    (v_line_id, 'puhe', 3, 'mennään', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menemme' and surface_puhe = 'mennään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Kartan mukaan oikeelle.',
    'Kartan mukaan oikealle.', 'The map says right.',
    'following-the-map/2-puhe-ee2bd533a936.mp3', 'following-the-map/2-kirja-afd9ccc84a1d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kartan', (select id from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan')),
    (v_line_id, 'kirja', 2, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan')),
    (v_line_id, 'kirja', 3, 'oikealle', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle')),
    (v_line_id, 'puhe', 1, 'Kartan', (select id from public.forms where lemma = 'kartta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kartan' and surface_puhe = 'kartan')),
    (v_line_id, 'puhe', 2, 'mukaan', (select id from public.forms where lemma = 'mukaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukaan' and surface_puhe = 'mukaan')),
    (v_line_id, 'puhe', 3, 'oikeelle', (select id from public.forms where lemma = 'oikea' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkotulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'oikealle' and surface_puhe = 'oikeelle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Ja ton sillan yli?',
    'Ja tuon sillan yli?', 'And over that bridge?',
    'following-the-map/3-puhe-f85951e7c595.mp3', 'following-the-map/3-kirja-d726a001093f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'tuon', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton')),
    (v_line_id, 'kirja', 3, 'sillan', (select id from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan')),
    (v_line_id, 'kirja', 4, 'yli', (select id from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'ton', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton')),
    (v_line_id, 'puhe', 3, 'sillan', (select id from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan')),
    (v_line_id, 'puhe', 4, 'yli', (select id from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo, sillan yli ja sit suoraan.',
    'Kyllä, sillan yli ja sitten suoraan.', 'Yes, over the bridge and then straight on.',
    'following-the-map/4-puhe-6cc124b8c865.mp3', 'following-the-map/4-kirja-5c802d1a2714.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'sillan', (select id from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan')),
    (v_line_id, 'kirja', 3, 'yli', (select id from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli')),
    (v_line_id, 'kirja', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 5, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 6, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'sillan', (select id from public.forms where lemma = 'silta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sillan' and surface_puhe = 'sillan')),
    (v_line_id, 'puhe', 3, 'yli', (select id from public.forms where lemma = 'yli' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'yli' and surface_puhe = 'yli')),
    (v_line_id, 'puhe', 4, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 5, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 6, 'suoraan', (select id from public.forms where lemma = 'suora' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suoraan' and surface_puhe = 'suoraan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Kuinka kauan vielä?',
    'Kuinka kauan vielä?', 'How much longer?',
    'following-the-map/5-puhe-577c04a93d99.mp3', 'following-the-map/5-kirja-cf6352e0ddb4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'kauan', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan')),
    (v_line_id, 'kirja', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'kauan', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kauan' and surface_puhe = 'kauan')),
    (v_line_id, 'puhe', 3, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Viis minuuttii. Se on puiston takana.',
    'Viisi minuuttia. Se on puiston takana.', 'Five minutes. It''s behind the park.',
    'following-the-map/6-puhe-428b8269b0ba.mp3', 'following-the-map/6-kirja-8d5620d174fb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Viisi', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'kirja', 2, 'minuuttia', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'kirja', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'puiston', (select id from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston')),
    (v_line_id, 'kirja', 6, 'takana', (select id from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana')),
    (v_line_id, 'puhe', 1, 'Viis', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'puhe', 2, 'minuuttii', (select id from public.forms where lemma = 'minuutti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'minuuttia' and surface_puhe = 'minuuttii')),
    (v_line_id, 'puhe', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'puiston', (select id from public.forms where lemma = 'puisto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'puiston' and surface_puhe = 'puiston')),
    (v_line_id, 'puhe', 6, 'takana', (select id from public.forms where lemma = 'takana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takana' and surface_puhe = 'takana'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Toi on varmaan se. Toi punanen talo.',
    'Tuo on varmaan se. Tuo punainen talo.', 'That must be it. That red building.',
    'following-the-map/7-puhe-b535f697330c.mp3', 'following-the-map/7-kirja-c813c08dce46.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tuo', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'varmaan', (select id from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan')),
    (v_line_id, 'kirja', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 5, 'Tuo', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'kirja', 6, 'punainen', (select id from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen')),
    (v_line_id, 'kirja', 7, 'talo', (select id from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo')),
    (v_line_id, 'puhe', 1, 'Toi', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'varmaan', (select id from public.forms where lemma = 'varmaan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'varmaan' and surface_puhe = 'varmaan')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 5, 'Toi', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tuo' and surface_puhe = 'toi')),
    (v_line_id, 'puhe', 6, 'punanen', (select id from public.forms where lemma = 'punainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'punainen' and surface_puhe = 'punanen')),
    (v_line_id, 'puhe', 7, 'talo', (select id from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talo' and surface_puhe = 'talo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Just niin! Me ollaan perillä.',
    'Juuri niin! Me olemme perillä.', 'Yes! We''re there.',
    'following-the-map/8-puhe-c9fdfe3f92bf.mp3', 'following-the-map/8-kirja-a56e3809f023.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Juuri', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'kirja', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 4, 'olemme', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan')),
    (v_line_id, 'kirja', 5, 'perillä', (select id from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä')),
    (v_line_id, 'puhe', 1, 'Just', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'puhe', 2, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 3, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 4, 'ollaan', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olemme' and surface_puhe = 'ollaan')),
    (v_line_id, 'puhe', 5, 'perillä', (select id from public.forms where lemma = 'perillä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perillä' and surface_puhe = 'perillä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#following-the-map/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
