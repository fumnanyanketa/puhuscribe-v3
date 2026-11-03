-- Publishes the dialogue working-hours (unit first-day-at-work). Made by
-- scripts/generate/pipeline.py publish from content/drafts/working-hours. Do not edit by hand:
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
    where slug = 'working-hours' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'working-hours';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 19
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'first-day-at-work' and position = 19 and stop_number = 19;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'first-day-at-work';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'working-hours', 3,
    'Working hours')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'working-hours' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Working hours';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'working-hours';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-f42052a3d5f2');
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
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ea79f0748e36');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työpäivä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"työpäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]työ[Sn][Ny][Bh][Bc][Ln][Xp]päivä[X]päiv[Sn][Ny]ä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=ppp=ppppppp","WORDBASES":"+työ(työ)+päivä(päivä)"}'::jsonb,
      'työpäiväni', 'työpäivä',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': työpäiväni. Speech drops it and says mun työpäivä.', 'my working day', 'working day', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-fe3c37b1a4aa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'työpäiväni', 'työpäivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': työpäiväni. Speech drops it and says mun työpäivä.', 'my working day', 'working day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'työpäiväni', 'työpäivä',
      (select form_name_en from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä'),
      (select why_en from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä'),
      (select meaning_en from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä'),
      (select lemma_meaning_en from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': työpäiväni. Speech drops it and says mun työpäivä.', 'my working day', 'working day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alkaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"alkaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]alkaa[X]alka[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+alkaa(alkaa)"}'::jsonb,
      'alkaa', 'alkaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-66c4c8a1800c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alkaa', 'alkaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alkaa', 'alkaa',
      (select form_name_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select why_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select meaning_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      (select lemma_meaning_en from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kahdeksan', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kahdeksan","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kahdeksan[X]kahdeks[Sabl][Ny]alta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppppp","WORDBASES":"+kahdeksan(kahdeksan)"}'::jsonb,
      'kahdeksalta', 'kaheksalta',
      'ablative singular', 'Adds -lta for a time on the clock: kahdeksan becomes kahdeksalta. Speech drops the d: kaheksalta.', 'at eight', 'eight', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ec1828bc666b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kahdeksalta', 'kahdeksan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -lta for a time on the clock: kahdeksan becomes kahdeksalta. Speech drops the d: kaheksalta.', 'at eight', 'eight')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kahdeksalta', 'kahdeksan',
      (select form_name_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta'),
      (select why_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta'),
      (select meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta'),
      (select lemma_meaning_en from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta'),
      'ablative singular', 'Adds -lta for a time on the clock: kahdeksan becomes kahdeksalta. Speech drops the d: kaheksalta.', 'at eight', 'eight';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('loppua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"loppua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]loppua[X]loppuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+loppua(loppua)"}'::jsonb,
      'loppuu', 'loppuu',
      'present tense, 3rd person singular', 'Loppua ''to end'' doubles its last vowel for ''it'': se loppuu. People say it the same way.', 'ends', 'to end, to run out', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-03a0d2d534ed');
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'loppuu', 'loppua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Loppua ''to end'' doubles its last vowel for ''it'': se loppuu. People say it the same way.', 'ends', 'to end, to run out')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'loppuu', 'loppua',
      (select form_name_en from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu'),
      (select why_en from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu'),
      (select meaning_en from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu'),
      (select lemma_meaning_en from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu'),
      'present tense, 3rd person singular', 'Loppua ''to end'' doubles its last vowel for ''it'': se loppuu. People say it the same way.', 'ends', 'to end, to run out';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sabl][Ny]ältä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljältä', 'neljältä',
      'ablative singular', 'Adds -ltä for a time on the clock: neljä becomes neljältä.', 'at four', 'four', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-5e16cf8cb940');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neljältä', 'neljä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä for a time on the clock: neljä becomes neljältä.', 'at four', 'four')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neljältä', 'neljä',
      (select form_name_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä'),
      (select why_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä'),
      (select meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä'),
      (select lemma_meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä'),
      'ablative singular', 'Adds -ltä for a time on the clock: neljä becomes neljältä.', 'at four', 'four';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teenkö', 'teenks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Teen (I do) with the question ending -kö: teenkö. Speech says teenks.', 'do I do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-765a8fa63863');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teenkö', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular, with the question ending -ko/-kö', 'Teen (I do) with the question ending -kö: teenkö. Speech says teenks.', 'do I do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teenkö', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks'),
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Teen (I do) with the question ending -kö: teenkö. Speech says teenks.', 'do I do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töitä', 'töitä',
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-a6fa8fd612dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töitä', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töitä', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä'),
      'partitive plural', 'Työ becomes töitä after tehdä: tehdä töitä means ''to work''. The vowels change from yö to ö.', 'work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-fe354724e29a');
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
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-3978a16fa6b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lauantaina', 'lauantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lauantaina', 'lauantai',
      (select form_name_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select why_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      (select lemma_meaning_en from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'),
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P2][Ny]t","MOOD":"indicative","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'et', 'et',
      'negative verb, 2nd person singular', 'The word for ''not'' changes to match the person: et is ''you don''t''. A short et answers a question with no.', 'no (you don''t)', 'no, not', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-299e29ea19d4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'et', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 2nd person singular', 'The word for ''not'' changes to match the person: et is ''you don''t''. A short et answers a question with no.', 'no (you don''t)', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'et', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et'),
      'negative verb, 2nd person singular', 'The word for ''not'' changes to match the person: et is ''you don''t''. A short et answers a question with no.', 'no (you don''t)', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teet', 'teet',
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-d8e27c6cf4bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teet', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teet', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet'),
      'present tense, 2nd person singular', 'Tehdä changes to tee- and takes -t for ''you'': teet.', 'you do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maanantai', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"maanantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]maanantai[X]maanantai[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppppppp","WORDBASES":"+maanantai(maanantai)"}'::jsonb,
      'maanantaista', 'maanantaist',
      'elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-7ac76f715442');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maanantaista', 'maanantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maanantaista', 'maanantai',
      (select form_name_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select why_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select meaning_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select lemma_meaning_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      'elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perjantai', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"perjantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]perjantai[X]perjanta[Sill][Ny]ihin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppppppppp","WORDBASES":"+perjantai(perjantai)"}'::jsonb,
      'perjantaihin', 'perjantaihin',
      'illative singular', 'Perjantai with -hin for ''to'': perjantaihin, as in Monday to Friday.', 'to Friday', 'Friday', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-e1cdedefbc86');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perjantaihin', 'perjantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Perjantai with -hin for ''to'': perjantaihin, as in Monday to Friday.', 'to Friday', 'Friday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perjantaihin', 'perjantai',
      (select form_name_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin'),
      (select why_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin'),
      (select meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin'),
      (select lemma_meaning_en from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin'),
      'illative singular', 'Perjantai with -hin for ''to'': perjantaihin, as in Monday to Friday.', 'to Friday', 'Friday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voinko', 'voinks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-cbf76e213246');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voinko', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voinko', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks'),
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdä', 'tehä',
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-f64c6f94ba00');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tehdä', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tehdä', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä'),
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('etätyö', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"etätyö","CLASS":"nimisana","FSTOUTPUT":"[Lp]etä[Bh][Bc][Ln][Xp]työ[X]tö[Sp][Nm]itä","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=ppp=ppppp","WORDBASES":"+etä+työ(työ)"}'::jsonb,
      'etätöitä', 'etätöitä',
      'partitive plural', 'Etätyö becomes etätöitä after tehdä: tehdä etätöitä means ''to work from home''.', 'remote work', 'remote work', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-fd4df65767cc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'etätöitä', 'etätyö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Etätyö becomes etätöitä after tehdä: tehdä etätöitä means ''to work from home''.', 'remote work', 'remote work')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'etätöitä', 'etätyö',
      (select form_name_en from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä'),
      (select why_en from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä'),
      (select meaning_en from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä'),
      (select lemma_meaning_en from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä'),
      'partitive plural', 'Etätyö becomes etätöitä after tehdä: tehdä etätöitä means ''to work from home''.', 'remote work', 'remote work';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('perjantaisin', 'CLASS=seikkasana', '{"BASEFORM":"perjantaisin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]perjantaisin[X]perjantaisin","STRUCTURE":"=pppppppppppp","WORDBASES":"+perjantaisin(perjantaisin)"}'::jsonb,
      'perjantaisin', 'perjantaisin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'on Fridays', 'on Fridays', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-e5b8d66c8036');
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'perjantaisin', 'perjantaisin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'on Fridays', 'on Fridays')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'perjantaisin', 'perjantaisin',
      (select form_name_en from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin'),
      (select why_en from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin'),
      (select meaning_en from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin'),
      (select lemma_meaning_en from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'on Fridays', 'on Fridays';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-483066471a02');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiva', 'kiva';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiva', 'kiva',
      (select form_name_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select why_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      (select lemma_meaning_en from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sela][Ny]stä","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mistä', 'mist',
      'elative singular', 'Mikä with -stä for ''from'': mistä. Speech drops the last vowel: mist.', 'where from', 'what, which', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ed149cbc76c8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mistä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Mikä with -stä for ''from'': mistä. Speech drops the last vowel: mist.', 'where from', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mistä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist'),
      'elative singular', 'Mikä with -stä for ''from'': mistä. Speech drops the last vowel: mist.', 'where from', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]saa[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saan', 'saan',
      'present tense, 1st person singular', 'Saada drops -da and takes -n for ''I'': saan.', 'I get', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-ee4f5b290fb2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saan', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Saada drops -da and takes -n for ''I'': saan.', 'I get', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saan', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan'),
      'present tense, 1st person singular', 'Saada drops -da and takes -n for ''I'': saan.', 'I get', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('avainkortti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"avainkortti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]avain[X]avain[Sn][Ny][Bh][Bc][Ln][Xp]kortti[X]kort[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+avain(avain)+kortti(kortti)"}'::jsonb,
      'avainkortin', 'avainkortin',
      'genitive singular', 'Adds -n for the thing you get or receive: avainkortti becomes avainkortin, with one t.', 'a key card', 'key card', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-60c4f8f34ab1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'avainkortin', 'avainkortti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Adds -n for the thing you get or receive: avainkortti becomes avainkortin, with one t.', 'a key card', 'key card')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'avainkortin', 'avainkortti',
      (select form_name_en from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin'),
      (select why_en from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin'),
      (select meaning_en from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin'),
      (select lemma_meaning_en from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin'),
      'genitive singular', 'Adds -n for the thing you get or receive: avainkortti becomes avainkortin, with one t.', 'a key card', 'key card';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aula', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"aula","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aula[X]aula[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppp","WORDBASES":"+aula(aula)"}'::jsonb,
      'aulasta', 'aulasta',
      'elative singular', 'Adds -sta for ''from'': aula becomes aulasta.', 'from the lobby', 'lobby', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-374507350851');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aulasta', 'aula';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Adds -sta for ''from'': aula becomes aulasta.', 'from the lobby', 'lobby')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aulasta', 'aula',
      (select form_name_en from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta'),
      (select why_en from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta'),
      (select meaning_en from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta'),
      (select lemma_meaning_en from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta'),
      'elative singular', 'Adds -sta for ''from'': aula becomes aulasta.', 'from the lobby', 'lobby';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tule[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulen', 'tuun',
      'present tense, 1st person singular', 'Adds -en for ''I'': tulla becomes tulen. Speech says tuun.', 'I come', 'to come', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-e0ecd37fd00f');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-98e98f16f669');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinun', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinun', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun'),
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana;POSSESSIVE=2s', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa[O2y]si","POSSESSIVE":"2s","STRUCTURE":"=pppppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssasi', 'kaa',
      'adposition, with the possessive ending for your', 'Books write sinun kanssasi, adding -si for ''your''. Speech says sun kaa, a short form of kanssa.', 'with you', 'with', 'approved', now(), 'content/approvals/part-4.json#working-hours/form-4994894a01f4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kanssasi', 'kanssa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition, with the possessive ending for your', 'Books write sinun kanssasi, adding -si for ''your''. Speech says sun kaa, a short form of kanssa.', 'with you', 'with')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kanssasi', 'kanssa',
      (select form_name_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa'),
      (select why_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa'),
      (select meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa'),
      'adposition, with the possessive ending for your', 'Books write sinun kanssasi, adding -si for ''your''. Speech says sun kaa, a short form of kanssa.', 'with you', 'with';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Hanna, mihin aikaan mun työpäivä alkaa?',
    'Hanna, mihin aikaan minun työpäiväni alkaa?', 'Hanna, what time does my working day start?',
    'working-hours/1-puhe-98be88933e70.mp3', 'working-hours/1-kirja-20bbb01cedfe.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hanna', null),
    (v_line_id, 'kirja', 2, 'mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 3, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'työpäiväni', (select id from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä')),
    (v_line_id, 'kirja', 6, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa')),
    (v_line_id, 'puhe', 1, 'Hanna', null),
    (v_line_id, 'puhe', 2, 'mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 3, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'työpäivä', (select id from public.forms where lemma = 'työpäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'työpäiväni' and surface_puhe = 'työpäivä')),
    (v_line_id, 'puhe', 6, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Hanna', 'Kaheksalta. Ja se loppuu neljältä.',
    'Kahdeksalta. Ja se loppuu neljältä.', 'At eight. And it ends at four.',
    'working-hours/2-puhe-1d46f17e0545.mp3', 'working-hours/2-kirja-5acfa0e32183.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kahdeksalta', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta')),
    (v_line_id, 'kirja', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'loppuu', (select id from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu')),
    (v_line_id, 'kirja', 5, 'neljältä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä')),
    (v_line_id, 'puhe', 1, 'Kaheksalta', (select id from public.forms where lemma = 'kahdeksan' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kahdeksalta' and surface_puhe = 'kaheksalta')),
    (v_line_id, 'puhe', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'loppuu', (select id from public.forms where lemma = 'loppua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'loppuu' and surface_puhe = 'loppuu')),
    (v_line_id, 'puhe', 5, 'neljältä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'neljältä' and surface_puhe = 'neljältä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Teenks mä töitä myös lauantaina?',
    'Teenkö minä töitä myös lauantaina?', 'Do I work on Saturdays too?',
    'working-hours/3-puhe-7de3bd60e06b.mp3', 'working-hours/3-kirja-3656af2de73d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Teenkö', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'kirja', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 5, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 1, 'Teenks', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'teenkö' and surface_puhe = 'teenks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'puhe', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 5, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Hanna', 'Et. Sä teet töitä maanantaist perjantaihin.',
    'Et. Sinä teet töitä maanantaista perjantaihin.', 'No. You work Monday to Friday.',
    'working-hours/4-puhe-7d75748d00b2.mp3', 'working-hours/4-kirja-5877dd90063d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Et', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 2, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'kirja', 4, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'kirja', 5, 'maanantaista', (select id from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist')),
    (v_line_id, 'kirja', 6, 'perjantaihin', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin')),
    (v_line_id, 'puhe', 1, 'Et', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=2;MOOD=indicative' and surface_kirja = 'et' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 2, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'teet', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teet' and surface_puhe = 'teet')),
    (v_line_id, 'puhe', 4, 'töitä', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'töitä' and surface_puhe = 'töitä')),
    (v_line_id, 'puhe', 5, 'maanantaist', (select id from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist')),
    (v_line_id, 'puhe', 6, 'perjantaihin', (select id from public.forms where lemma = 'perjantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'perjantaihin' and surface_puhe = 'perjantaihin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Hyvä. Voinks mä tehä etätöitä?',
    'Hyvä. Voinko minä tehdä etätöitä?', 'Good. Can I work from home?',
    'working-hours/5-puhe-8d659fad87d3.mp3', 'working-hours/5-kirja-89f3306b1d90.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Voinko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'tehdä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'kirja', 5, 'etätöitä', (select id from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Voinks', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'tehä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'puhe', 5, 'etätöitä', (select id from public.forms where lemma = 'etätyö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'etätöitä' and surface_puhe = 'etätöitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Hanna', 'Joo, perjantaisin.',
    'Kyllä, perjantaisin.', 'Yes, on Fridays.',
    'working-hours/6-puhe-63bd5f086ffa.mp3', 'working-hours/6-kirja-faec96aa263c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'perjantaisin', (select id from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'perjantaisin', (select id from public.forms where lemma = 'perjantaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'perjantaisin' and surface_puhe = 'perjantaisin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Kiva! Mist mä saan avainkortin?',
    'Kiva! Mistä minä saan avainkortin?', 'Nice! Where do I get a key card?',
    'working-hours/7-puhe-e9f5d1201689.mp3', 'working-hours/7-kirja-7b9d4d229f49.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 2, 'Mistä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'saan', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan')),
    (v_line_id, 'kirja', 5, 'avainkortin', (select id from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin')),
    (v_line_id, 'puhe', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 2, 'Mist', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'mistä' and surface_puhe = 'mist')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'saan', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'saan' and surface_puhe = 'saan')),
    (v_line_id, 'puhe', 5, 'avainkortin', (select id from public.forms where lemma = 'avainkortti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'avainkortin' and surface_puhe = 'avainkortin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Hanna', 'Aulasta. Mä tuun sun kaa.',
    'Aulasta. Minä tulen sinun kanssasi.', 'From the lobby. I''ll come with you.',
    'working-hours/8-puhe-829fbd7eb8dd.mp3', 'working-hours/8-kirja-e7d3bde4fa5d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aulasta', (select id from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulen', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'kirja', 4, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 5, 'kanssasi', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Aulasta', (select id from public.forms where lemma = 'aula' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'aulasta' and surface_puhe = 'aulasta')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tuun', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulen' and surface_puhe = 'tuun')),
    (v_line_id, 'puhe', 4, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 5, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana;POSSESSIVE=2s' and surface_kirja = 'kanssasi' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#working-hours/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-4.json#working-hours/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
