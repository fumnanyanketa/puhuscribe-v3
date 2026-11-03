-- Publishes the dialogue booking-a-haircut (unit times-and-appointments). Made by
-- scripts/generate/pipeline.py publish from content/drafts/booking-a-haircut. Do not edit by hand:
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
    where slug = 'booking-a-haircut' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'booking-a-haircut';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 9
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'times-and-appointments' and position = 9 and stop_number = 9;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'times-and-appointments';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'booking-a-haircut', 2,
    'Booking a haircut')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'booking-a-haircut' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Booking a haircut';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'booking-a-haircut';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kampaamo', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kampaamo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kampaamo[X]kampaamo[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+kampaamo(kampaamo)"}'::jsonb,
      'kampaamo', 'kampaamo',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hair salon', 'hair salon', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-2f7c80fe0d1f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kampaamo', 'kampaamo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'hair salon', 'hair salon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kampaamo', 'kampaamo',
      (select form_name_en from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo'),
      (select why_en from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo'),
      (select meaning_en from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo'),
      (select lemma_meaning_en from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'hair salon', 'hair salon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Te][Ap][P1][Ny][Ef]isin","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluaisin', 'haluisin',
      'conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-bcf5603c26d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluaisin', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluaisin', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin'),
      'conditional present tense, 1st person singular', 'Haluta with -isi for ''would'' and -n for ''I''. Speech drops the a: haluisin.', 'I''d like', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"varata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]varata[X]varat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+varata(varata)"}'::jsonb,
      'varata', 'varata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to book, to reserve', 'to book, to reserve', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-f1ec0ca42237');
  end if;
  if not exists (select 1 from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'varata', 'varata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to book, to reserve', 'to book, to reserve')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'varata', 'varata',
      (select form_name_en from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata'),
      (select why_en from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata'),
      (select meaning_en from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata'),
      (select lemma_meaning_en from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to book, to reserve', 'to book, to reserve';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aika', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"aika","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aika[X]aj[Sg][Ny]an","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+aika(aika)"}'::jsonb,
      'ajan', 'ajan',
      'genitive singular', 'Aika, time, becomes ajan when you book one: varata ajan. The k drops out and n is added.', 'an appointment, a time', 'time', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-93b6680ccedc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ajan', 'aika';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Aika, time, becomes ajan when you book one: varata ajan. The k drops out and n is added.', 'an appointment, a time', 'time')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ajan', 'aika',
      (select form_name_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan'),
      (select why_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan'),
      (select meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan'),
      (select lemma_meaning_en from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan'),
      'genitive singular', 'Aika, time, becomes ajan when you book one: varata ajan. The k drops out and n is added.', 'an appointment, a time', 'time';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hiustenleikkuu', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"hiustenleikkuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hius[X]hiu[Sg][Nm]sten[Bh][Bc][Ln][Xp]leikkuu[X]leikkuu[Sill][Ny]seen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp=ppppppppppp","WORDBASES":"+hiusten(hius)+leikkuu(leikkuu)"}'::jsonb,
      'hiustenleikkuuseen', 'hiustenleikkuuseen',
      'illative singular', 'Adds -seen for ''into, for'': hiustenleikkuu becomes hiustenleikkuuseen. The illative singular shows what the time is for.', 'for a haircut', 'haircut', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-4f04cd4a7329');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hiustenleikkuuseen', 'hiustenleikkuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -seen for ''into, for'': hiustenleikkuu becomes hiustenleikkuuseen. The illative singular shows what the time is for.', 'for a haircut', 'haircut')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hiustenleikkuuseen', 'hiustenleikkuu',
      (select form_name_en from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen'),
      (select why_en from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen'),
      (select meaning_en from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen'),
      (select lemma_meaning_en from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen'),
      'illative singular', 'Adds -seen for ''into, for'': hiustenleikkuu becomes hiustenleikkuuseen. The illative singular shows what the time is for.', 'for a haircut', 'haircut';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopiiko', 'sopiiks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-f0aadca6a510');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sopiiko', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sopiiko', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('torstai', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"torstai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]torstai[X]torstai[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+torstai(torstai)"}'::jsonb,
      'torstai', 'torstai',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Thursday', 'Thursday', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-e0024e71b891');
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'torstai', 'torstai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'Thursday', 'Thursday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'torstai', 'torstai',
      (select form_name_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai'),
      (select why_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai'),
      (select meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai'),
      (select lemma_meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'Thursday', 'Thursday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-f42052a3d5f2');
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
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-ea79f0748e36');
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
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolme', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kolme","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sabl][Ny]elta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolmelta', 'kolmelta',
      'ablative singular', 'Adds -lta to a number to give a clock time: kolme becomes kolmelta, ''at three''.', 'at three', 'three', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-7835f2e38366');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolmelta', 'kolme';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -lta to a number to give a clock time: kolme becomes kolmelta, ''at three''.', 'at three', 'three')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolmelta', 'kolme',
      (select form_name_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta'),
      (select why_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta'),
      (select meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta'),
      (select lemma_meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta'),
      'ablative singular', 'Adds -lta to a number to give a clock time: kolme becomes kolmelta, ''at three''.', 'at three', 'three';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tai', 'CLASS=sidesana', '{"BASEFORM":"tai","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]tai[X]tai","STRUCTURE":"=ppp","WORDBASES":"+tai(tai)"}'::jsonb,
      'tai', 'tai',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-e626f185f947');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tai', 'tai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tai', 'tai',
      (select form_name_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select why_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select meaning_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      (select lemma_meaning_en from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'or', 'or';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-ad4c189b50dd');
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
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sabl][Ny]deltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viideltä', 'viideltä',
      'ablative singular', 'Adds -ltä to a number to give a clock time. Viisi changes its s to d first: viideltä, ''at five''.', 'at five', 'five', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-d693248e8615');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Te][Ap][P3][Ny][Eb]isi","MOOD":"conditional","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olisi', 'ois',
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-fc63732ba497');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olisi', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olisi', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois'),
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"comparative","FSTOUTPUT":"[Ll][Xp]hyvä[X]pare[Sn][Ny][Cc]mpi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'parempi', 'parempi',
      'comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-f49daf34443c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'parempi', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'parempi', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'),
      'comparative, nominative singular', 'The comparative of hyvä ''good'' is irregular: hyvä, parempi. People say it the same way.', 'better', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'selvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'clear, OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-cff3db5ce4e8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'selvä', 'selvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'clear, OK', 'clear, OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'selvä', 'selvä',
      (select form_name_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä'),
      (select why_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä'),
      (select meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä'),
      (select lemma_meaning_en from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'clear, OK', 'clear, OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-bfff487cc1b5');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nimi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"nimi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ivj][Xp]nimi[X]nim[Sn][Ny]e[O2y]si","MALAGA_VAPAA_JALKIOSA":"true","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+nimi(nimi)"}'::jsonb,
      'nimesi', 'nimi',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-62b10330a9a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nimesi', 'nimi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nimesi', 'nimi',
      (select form_name_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select why_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      (select lemma_meaning_en from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your''; nimi turns its i to e first: nimesi. Speech just says sun nimi.', 'your name', 'name';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]nähd[Tt][Ap][P4][Ef]ään","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'nähdään', 'nähään',
      'present tense, passive', 'The passive form means ''let''s see each other''. Speech drops the d: nähään.', 'see you', 'to see', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-3154ca2238b6');
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
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('torstai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"torstai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]torstai[X]torstai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppppppp","WORDBASES":"+torstai(torstai)"}'::jsonb,
      'torstaina', 'torstaina',
      'essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday', 'approved', now(), 'content/approvals/part-2.json#booking-a-haircut/form-bc45764ddc70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'torstaina', 'torstai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'torstaina', 'torstai',
      (select form_name_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select why_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select lemma_meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      'essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Kaisa', 'Kampaamo Kaisa, moi!',
    'Kampaamo Kaisa, hei!', 'Kaisa''s hair salon, hello!',
    'booking-a-haircut/1-puhe-b84050f60d96.mp3', 'booking-a-haircut/1-kirja-722f8e954943.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kampaamo', (select id from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo')),
    (v_line_id, 'kirja', 2, 'Kaisa', null),
    (v_line_id, 'kirja', 3, 'hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 1, 'Kampaamo', (select id from public.forms where lemma = 'kampaamo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kampaamo' and surface_puhe = 'kampaamo')),
    (v_line_id, 'puhe', 2, 'Kaisa', null),
    (v_line_id, 'puhe', 3, 'moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Moi! Mä haluisin varata ajan hiustenleikkuuseen.',
    'Hei! Minä haluaisin varata ajan hiustenleikkuuseen.', 'Hi! I''d like to book a haircut.',
    'booking-a-haircut/2-puhe-7eb422c981a1.mp3', 'booking-a-haircut/2-kirja-2b5cd3babe61.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluaisin', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin')),
    (v_line_id, 'kirja', 4, 'varata', (select id from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata')),
    (v_line_id, 'kirja', 5, 'ajan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan')),
    (v_line_id, 'kirja', 6, 'hiustenleikkuuseen', (select id from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluisin', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluaisin' and surface_puhe = 'haluisin')),
    (v_line_id, 'puhe', 4, 'varata', (select id from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata')),
    (v_line_id, 'puhe', 5, 'ajan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'ajan' and surface_puhe = 'ajan')),
    (v_line_id, 'puhe', 6, 'hiustenleikkuuseen', (select id from public.forms where lemma = 'hiustenleikkuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'hiustenleikkuuseen' and surface_puhe = 'hiustenleikkuuseen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Kaisa', 'Okei. Sopiiks torstai?',
    'Selvä. Sopiiko torstai?', 'OK. Does Thursday suit you?',
    'booking-a-haircut/3-puhe-f9d057e524e8.mp3', 'booking-a-haircut/3-kirja-68329d928bec.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Sopiiko', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'kirja', 3, 'torstai', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Sopiiks', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'puhe', 3, 'torstai', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'torstai' and surface_puhe = 'torstai'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mihin aikaan?',
    'Mihin aikaan?', 'What time?',
    'booking-a-haircut/4-puhe-999907116aca.mp3', 'booking-a-haircut/4-kirja-3355031d6240.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 2, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'puhe', 1, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 2, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Kaisa', 'Kolmelta tai sit viideltä.',
    'Kolmelta tai sitten viideltä.', 'At three or at five.',
    'booking-a-haircut/5-puhe-3fa1a6269262.mp3', 'booking-a-haircut/5-kirja-e09167baf849.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kolmelta', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta')),
    (v_line_id, 'kirja', 2, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'kirja', 3, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 4, 'viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'puhe', 1, 'Kolmelta', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kolmelta' and surface_puhe = 'kolmelta')),
    (v_line_id, 'puhe', 2, 'tai', (select id from public.forms where lemma = 'tai' and form_tag = 'CLASS=sidesana' and surface_kirja = 'tai' and surface_puhe = 'tai')),
    (v_line_id, 'puhe', 3, 'sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 4, 'viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Viideltä ois parempi.',
    'Viideltä olisi parempi.', 'Five would be better.',
    'booking-a-haircut/6-puhe-d03a85928f4a.mp3', 'booking-a-haircut/6-kirja-083b4a87fef4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'kirja', 2, 'olisi', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'kirja', 3, 'parempi', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi')),
    (v_line_id, 'puhe', 1, 'Viideltä', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'viideltä' and surface_puhe = 'viideltä')),
    (v_line_id, 'puhe', 2, 'ois', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'puhe', 3, 'parempi', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=comparative' and surface_kirja = 'parempi' and surface_puhe = 'parempi'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Kaisa', 'Selvä. Mikä sun nimi on?',
    'Selvä. Mikä sinun nimesi on?', 'Fine. What''s your name?',
    'booking-a-haircut/7-puhe-c8a20a82a8ba.mp3', 'booking-a-haircut/7-kirja-b3d0b159c2df.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä')),
    (v_line_id, 'kirja', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 3, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 4, 'nimesi', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä')),
    (v_line_id, 'puhe', 2, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 3, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 4, 'nimi', (select id from public.forms where lemma = 'nimi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'nimesi' and surface_puhe = 'nimi')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Maria Silva. Kiitti, nähään torstaina!',
    'Maria Silva. Kiitos, nähdään torstaina!', 'Maria Silva. Thanks, see you on Thursday!',
    'booking-a-haircut/8-puhe-584c9ee806e5.mp3', 'booking-a-haircut/8-kirja-5e0dcd8ff6f3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Maria', null),
    (v_line_id, 'kirja', 2, 'Silva', null),
    (v_line_id, 'kirja', 3, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 4, 'nähdään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'kirja', 5, 'torstaina', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina')),
    (v_line_id, 'puhe', 1, 'Maria', null),
    (v_line_id, 'puhe', 2, 'Silva', null),
    (v_line_id, 'puhe', 3, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 4, 'nähään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'nähdään' and surface_puhe = 'nähään')),
    (v_line_id, 'puhe', 5, 'torstaina', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#booking-a-haircut/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
