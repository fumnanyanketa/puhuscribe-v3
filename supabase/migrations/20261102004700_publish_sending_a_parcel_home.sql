-- Publishes the dialogue sending-a-parcel-home (unit collecting-a-parcel). Made by
-- scripts/generate/pipeline.py publish from content/drafts/sending-a-parcel-home. Do not edit by hand:
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
    where slug = 'sending-a-parcel-home' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'sending-a-parcel-home';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 16
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'collecting-a-parcel' and position = 16 and stop_number = 16;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'collecting-a-parcel';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'sending-a-parcel-home', 3,
    'Sending a parcel home')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'sending-a-parcel-home' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Sending a parcel home';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'sending-a-parcel-home';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluan', 'haluun',
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-65809211d876');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluan', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluan', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun'),
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähettää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"lähettää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähettää[X]lähettä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppppp","WORDBASES":"+lähettää(lähettää)"}'::jsonb,
      'lähettää', 'lähettää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to send', 'to send', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-30323898a093');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähettää', 'lähettää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to send', 'to send')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähettää', 'lähettää',
      (select form_name_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää'),
      (select why_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää'),
      (select meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää'),
      (select lemma_meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to send', 'to send';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sg][Ny]män","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämän', 'tän',
      'genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-0b0b417b5640');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tämän', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tämän', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän'),
      'genitive singular', 'The genitive singular of tämä goes before kanssa ''with'': tämän. Speech shortens it to tän.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paketti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"paketti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]paketti[X]paket[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+paketti(paketti)"}'::jsonb,
      'paketin', 'paketin',
      'genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-e7e5785f8270');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paketin', 'paketti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paketin', 'paketti',
      (select form_name_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select why_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      (select lemma_meaning_en from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin'),
      'genitive singular', 'As the whole thing you take, paketti takes -n: paketin, tt turning to t.', 'the parcel', 'parcel, package';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laittaa', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"laittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laittaa[X]laitet[Tt][Ap][P4][Ef]aan","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+laittaa(laittaa)"}'::jsonb,
      'laitetaan', 'laitetaan',
      'present tense, passive', 'The passive laitetaan is used to say ''let''s put'' or ''we put''. People say it the same way.', 'let''s put', 'to put, to make', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-024c3a4292cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laitetaan', 'laittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive', 'The passive laitetaan is used to say ''let''s put'' or ''we put''. People say it the same way.', 'let''s put', 'to put, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laitetaan', 'laittaa',
      (select form_name_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan'),
      (select why_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan'),
      (select meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan'),
      (select lemma_meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan'),
      'present tense, passive', 'The passive laitetaan is used to say ''let''s put'' or ''we put''. People say it the same way.', 'let''s put', 'to put, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaaka', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"vaaka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vaaka[X]vaa''a[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=pppppppp","WORDBASES":"+vaaka(vaaka)"}'::jsonb,
      'vaa''alle', 'vaa''alle',
      'allative singular', 'Adds -lle for ''onto'': vaaka becomes vaa''alle. The k drops out, leaving a break mark.', 'on the scales', 'scales', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-9f4bc8d41132');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaa''alle', 'vaaka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''onto'': vaaka becomes vaa''alle. The k drops out, leaving a break mark.', 'on the scales', 'scales')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaa''alle', 'vaaka',
      (select form_name_en from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle'),
      (select why_en from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle'),
      (select meaning_en from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle'),
      (select lemma_meaning_en from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle'),
      'allative singular', 'Adds -lle for ''onto'': vaaka becomes vaa''alle. The k drops out, leaving a break mark.', 'on the scales', 'scales';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuinka', 'CLASS=sidesana', '{"BASEFORM":"kuinka","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]kuinka[X]kuinka","STRUCTURE":"=pppppp","WORDBASES":"+kuinka(kuinka)"}'::jsonb,
      'kuinka', 'kuinka',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-fd1a9ffcfdb7');
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
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-c89c8a769850');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'paljon', 'paljon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'paljon', 'paljon',
      (select form_name_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select why_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      (select lemma_meaning_en from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much';
  end if;
  if not exists (select 1 from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('painaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"painaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]painaa[X]paina[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+painaa(painaa)"}'::jsonb,
      'painaa', 'painaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to weigh, to press', 'to weigh, to press', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-b1ae42a9ddeb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'painaa', 'painaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to weigh, to press', 'to weigh, to press')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'painaa', 'painaa',
      (select form_name_en from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa'),
      (select why_en from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa'),
      (select meaning_en from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa'),
      (select lemma_meaning_en from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to weigh, to press', 'to weigh, to press';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-05a31ace9a1d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaksi', 'kaksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaksi', 'kaksi',
      (select form_name_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select why_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      (select lemma_meaning_en from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks'),
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kilo', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kilo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kilo[X]kilo[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+kilo(kilo)"}'::jsonb,
      'kiloa', 'kiloo',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: kilo becomes kiloa. Speech says kiloo.', 'kilos', 'kilo', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-b174a3020b55');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiloa', 'kilo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: kilo becomes kiloa. Speech says kiloo.', 'kilos', 'kilo')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiloa', 'kilo',
      (select form_name_en from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo'),
      (select why_en from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo'),
      (select meaning_en from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo'),
      (select lemma_meaning_en from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: kilo becomes kiloa. Speech says kiloo.', 'kilos', 'kilo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lentoposti', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lentoposti","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]lentää[X]len[Ln][Xj]to[X]to[Sn][Ny][Bh][Bc][Ln][Xp]posti[X]post[Ses][Ny]ina","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+len(lentää)+to(+to)+posti(posti)"}'::jsonb,
      'lentopostina', 'lentopostina',
      'essive singular', 'The essive singular adds -na for ''as, by'': lentoposti becomes lentopostina.', 'by airmail', 'airmail', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-ec97f73f491c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lentopostina', 'lentoposti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'The essive singular adds -na for ''as, by'': lentoposti becomes lentopostina.', 'by airmail', 'airmail')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lentopostina', 'lentoposti',
      (select form_name_en from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina'),
      (select why_en from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina'),
      (select meaning_en from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina'),
      (select lemma_meaning_en from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina'),
      'essive singular', 'The essive singular adds -na for ''as, by'': lentoposti becomes lentopostina.', 'by airmail', 'airmail';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maksaa', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"maksaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]maksaa[X]maks[Tt][Ap][P3][Ny][Ef]aa","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+maksaa(maksaa)"}'::jsonb,
      'maksaa', 'maksaa',
      'present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-859d1d409945');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maksaa', 'maksaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maksaa', 'maksaa',
      (select form_name_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select why_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      (select lemma_meaning_en from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa'),
      'present tense, 3rd person singular', 'Maksaa, to cost or pay. With se, ''it'', the verb ends in a long vowel: maksaa.', 'costs', 'to cost, to pay';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolmekymmentäviisi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolmekymmentäviisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e[Bc]kymmentä[Bc][Lu][Xp]viisi[X]vii[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=pppppppp=ppppp","WORDBASES":"+kolmekymmentä(kolme)+viisi(viisi)"}'::jsonb,
      'kolmekymmentäviisi', 'kolkytviis',
      'nominative singular', 'Speech shortens it to kolkytviis. Books write kolmekymmentäviisi.', 'thirty-five', 'thirty-five', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-129d95440cfa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolmekymmentäviisi', 'kolmekymmentäviisi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens it to kolkytviis. Books write kolmekymmentäviisi.', 'thirty-five', 'thirty-five')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolmekymmentäviisi', 'kolmekymmentäviisi',
      (select form_name_en from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis'),
      (select why_en from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis'),
      (select meaning_en from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis'),
      (select lemma_meaning_en from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis'),
      'nominative singular', 'Speech shortens it to kolkytviis. Books write kolmekymmentäviisi.', 'thirty-five', 'thirty-five';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('euro', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"euro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]euro[X]euro[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+euro(euro)"}'::jsonb,
      'euroa', 'euroo',
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-e0b2a20b7101');
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'euroa', 'euro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'euroa', 'euro',
      (select form_name_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select why_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      (select lemma_meaning_en from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'),
      'partitive singular', 'After a number the noun takes the partitive: neljä euroa. Speech turns -oa into -oo.', 'euros', 'euro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauan', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"kauan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauan[X]kauan[Fko][Ef]ko","KYSYMYSLIITE":"true","STRUCTURE":"=ppppppp","WORDBASES":"+kauan(kauan)"}'::jsonb,
      'kauanko', 'kauanks',
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-15e58dd7ae2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kauanko', 'kauan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kauanko', 'kauan',
      (select form_name_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select why_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      (select lemma_meaning_en from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks'),
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kestää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"kestää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kestää[X]kestä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+kestää(kestää)"}'::jsonb,
      'kestää', 'kestää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to last, to take (time)', 'to last, to take (time)', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-e74c90156d1c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kestää', 'kestää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to last, to take (time)', 'to last, to take (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kestää', 'kestää',
      (select form_name_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää'),
      (select why_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää'),
      (select meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää'),
      (select lemma_meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to last, to take (time)', 'to last, to take (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('noin', 'CLASS=seikkasana', '{"BASEFORM":"noin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]noin[X]noin","STRUCTURE":"=pppp","WORDBASES":"+noin(noin)"}'::jsonb,
      'noin', 'noin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-548c5d31bffe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'noin', 'noin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'noin', 'noin',
      (select form_name_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select why_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select meaning_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      (select lemma_meaning_en from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'about, roughly', 'about, roughly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viikko[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikkoa', 'viikkoo',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-0cc3e6dfc99a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikkoa', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikkoa', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('äiti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"äiti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]äiti[X]äit[Sn][Ny]i[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+äiti(äiti)"}'::jsonb,
      'äitini', 'äidin',
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': äiti becomes äitini. Speech says mun äidin, ''of my mother''.', 'my mother''s', 'mother', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-359188e9081c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'äitini', 'äiti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': äiti becomes äitini. Speech says mun äidin, ''of my mother''.', 'my mother''s', 'mother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'äitini', 'äiti',
      (select form_name_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin'),
      (select why_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin'),
      (select meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin'),
      (select lemma_meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin'),
      'nominative singular, with the possessive ending for my', 'Adds -ni for ''my'': äiti becomes äitini. Speech says mun äidin, ''of my mother''.', 'my mother''s', 'mother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syntymäpäivälahja', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"syntymäpäivälahja","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]syntymä[X]syntym[Sn][Ny]ä[Bh][Bc][Ln][Xp]päivä[X]päiv[Sn][Ny]ä[Bh][Bc][Ln][Xp]lahja[X]lahj[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=ppppp=ppppp","WORDBASES":"+syntymä(syntymä)+päivä(päivä)+lahja(lahja)"}'::jsonb,
      'syntymäpäivälahja', 'synttärilahja',
      'nominative singular', 'Speech uses the short word synttärit for a birthday: synttärilahja. Books write syntymäpäivälahja.', 'a birthday present', 'birthday present', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-3d70cca1653a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syntymäpäivälahja', 'syntymäpäivälahja';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech uses the short word synttärit for a birthday: synttärilahja. Books write syntymäpäivälahja.', 'a birthday present', 'birthday present')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syntymäpäivälahja', 'syntymäpäivälahja',
      (select form_name_en from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja'),
      (select why_en from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja'),
      (select meaning_en from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja'),
      (select lemma_meaning_en from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja'),
      'nominative singular', 'Speech uses the short word synttärit for a birthday: synttärilahja. Books write syntymäpäivälahja.', 'a birthday present', 'birthday present';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirjoittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kirjoittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kirjoittaa[X]kirjoita[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+kirjoittaa(kirjoittaa)"}'::jsonb,
      'kirjoita', 'kirjota',
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: kirjoittaa becomes kirjoita. Speech says kirjota.', 'write', 'to write', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-bdca70f64fa7');
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
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osoite', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"osoite","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osoite[X]osoite[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+osoite(osoite)"}'::jsonb,
      'osoite', 'osote',
      'nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-25a4e9144483');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osoite', 'osoite';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osoite', 'osoite',
      (select form_name_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select why_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select lemma_meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      'nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sill][Ny]hän","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tähän', 'tähän',
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-3cb39a24ba50');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tähän', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tähän', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän'),
      'illative singular', 'The illative singular of tämä ''this'': tähän, ''into this place, here''.', 'here (to this spot)', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lappu', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"lappu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lappu[X]lappuu[Sill][Ny]n","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+lappu(lappu)"}'::jsonb,
      'lappuun', 'lappuun',
      'illative singular', 'Adds -un for ''into, onto'': lappu becomes lappuun.', 'on this label', 'note, slip of paper, label', 'approved', now(), 'content/approvals/part-3.json#sending-a-parcel-home/form-8e8ff553d79c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lappuun', 'lappu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -un for ''into, onto'': lappu becomes lappuun.', 'on this label', 'note, slip of paper, label')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lappuun', 'lappu',
      (select form_name_en from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun'),
      (select why_en from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun'),
      (select meaning_en from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun'),
      (select lemma_meaning_en from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun'),
      'illative singular', 'Adds -un for ''into, onto'': lappu becomes lappuun.', 'on this label', 'note, slip of paper, label';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä haluun lähettää tän paketin Brasiliaan.',
    'Hei! Minä haluan lähettää tämän paketin Brasiliaan.', 'Hi! I want to send this parcel to Brazil.',
    'sending-a-parcel-home/1-puhe-4a212cdcc621.mp3', 'sending-a-parcel-home/1-kirja-13876eb96e54.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 4, 'lähettää', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää')),
    (v_line_id, 'kirja', 5, 'tämän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän')),
    (v_line_id, 'kirja', 6, 'paketin', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin')),
    (v_line_id, 'kirja', 7, 'Brasiliaan', null),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 4, 'lähettää', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähettää' and surface_puhe = 'lähettää')),
    (v_line_id, 'puhe', 5, 'tän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tämän' and surface_puhe = 'tän')),
    (v_line_id, 'puhe', 6, 'paketin', (select id from public.forms where lemma = 'paketti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'paketin' and surface_puhe = 'paketin')),
    (v_line_id, 'puhe', 7, 'Brasiliaan', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Jonna', 'Okei. Laitetaan se vaa''alle.',
    'Selvä. Laitetaan se vaa''alle.', 'OK. Let''s put it on the scales.',
    'sending-a-parcel-home/2-puhe-bdb1db3af00a.mp3', 'sending-a-parcel-home/2-kirja-18a20cc25dc4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Laitetaan', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'vaa''alle', (select id from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Laitetaan', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitetaan' and surface_puhe = 'laitetaan')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'vaa''alle', (select id from public.forms where lemma = 'vaaka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'vaa''alle' and surface_puhe = 'vaa''alle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Kuinka paljon se painaa?',
    'Kuinka paljon se painaa?', 'How much does it weigh?',
    'sending-a-parcel-home/3-puhe-52d7424c569d.mp3', 'sending-a-parcel-home/3-kirja-9784b76cfb34.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'kirja', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'painaa', (select id from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa')),
    (v_line_id, 'puhe', 1, 'Kuinka', (select id from public.forms where lemma = 'kuinka' and form_tag = 'CLASS=sidesana' and surface_kirja = 'kuinka' and surface_puhe = 'kuinka')),
    (v_line_id, 'puhe', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'painaa', (select id from public.forms where lemma = 'painaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'painaa' and surface_puhe = 'painaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Jonna', 'Kaks kiloo. Lentopostina se maksaa kolkytviis euroo.',
    'Kaksi kiloa. Lentopostina se maksaa kolmekymmentäviisi euroa.', 'Two kilos. By airmail it costs thirty-five euros.',
    'sending-a-parcel-home/4-puhe-e7750cf41718.mp3', 'sending-a-parcel-home/4-kirja-ecc854638bfe.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 2, 'kiloa', (select id from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo')),
    (v_line_id, 'kirja', 3, 'Lentopostina', (select id from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina')),
    (v_line_id, 'kirja', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 5, 'maksaa', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa')),
    (v_line_id, 'kirja', 6, 'kolmekymmentäviisi', (select id from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis')),
    (v_line_id, 'kirja', 7, 'euroa', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo')),
    (v_line_id, 'puhe', 1, 'Kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 2, 'kiloo', (select id from public.forms where lemma = 'kilo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kiloa' and surface_puhe = 'kiloo')),
    (v_line_id, 'puhe', 3, 'Lentopostina', (select id from public.forms where lemma = 'lentoposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lentopostina' and surface_puhe = 'lentopostina')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 5, 'maksaa', (select id from public.forms where lemma = 'maksaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'maksaa' and surface_puhe = 'maksaa')),
    (v_line_id, 'puhe', 6, 'kolkytviis', (select id from public.forms where lemma = 'kolmekymmentäviisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolmekymmentäviisi' and surface_puhe = 'kolkytviis')),
    (v_line_id, 'puhe', 7, 'euroo', (select id from public.forms where lemma = 'euro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'euroa' and surface_puhe = 'euroo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Kauanks se kestää?',
    'Kauanko se kestää?', 'How long does it take?',
    'sending-a-parcel-home/5-puhe-e64feafa1d7a.mp3', 'sending-a-parcel-home/5-kirja-ed8c0573a159.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kauanko', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'kestää', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää')),
    (v_line_id, 'puhe', 1, 'Kauanks', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'kestää', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'kestää' and surface_puhe = 'kestää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Jonna', 'Noin kaks viikkoo.',
    'Noin kaksi viikkoa.', 'About two weeks.',
    'sending-a-parcel-home/6-puhe-3d4ee7729b24.mp3', 'sending-a-parcel-home/6-kirja-66250f5202fb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Noin', (select id from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin')),
    (v_line_id, 'kirja', 2, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 3, 'viikkoa', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo')),
    (v_line_id, 'puhe', 1, 'Noin', (select id from public.forms where lemma = 'noin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'noin' and surface_puhe = 'noin')),
    (v_line_id, 'puhe', 2, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 3, 'viikkoo', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Okei. Se on mun äidin synttärilahja.',
    'Selvä. Se on minun äitini syntymäpäivälahja.', 'OK. It''s my mother''s birthday present.',
    'sending-a-parcel-home/7-puhe-3370782155b5.mp3', 'sending-a-parcel-home/7-kirja-7a3141d3f1c7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 5, 'äitini', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin')),
    (v_line_id, 'kirja', 6, 'syntymäpäivälahja', (select id from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 5, 'äidin', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äidin')),
    (v_line_id, 'puhe', 6, 'synttärilahja', (select id from public.forms where lemma = 'syntymäpäivälahja' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'syntymäpäivälahja' and surface_puhe = 'synttärilahja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Jonna', 'Kiva! Kirjota osote tähän lappuun.',
    'Kiva! Kirjoita osoite tähän lappuun.', 'Nice! Write the address on this label.',
    'sending-a-parcel-home/8-puhe-72e0afb72133.mp3', 'sending-a-parcel-home/8-kirja-1f77414a9b30.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'kirja', 2, 'Kirjoita', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'kirja', 3, 'osoite', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote')),
    (v_line_id, 'kirja', 4, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän')),
    (v_line_id, 'kirja', 5, 'lappuun', (select id from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun')),
    (v_line_id, 'puhe', 1, 'Kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 2, 'Kirjota', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kirjoita' and surface_puhe = 'kirjota')),
    (v_line_id, 'puhe', 3, 'osote', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote')),
    (v_line_id, 'puhe', 4, 'tähän', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'tähän' and surface_puhe = 'tähän')),
    (v_line_id, 'puhe', 5, 'lappuun', (select id from public.forms where lemma = 'lappu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'lappuun' and surface_puhe = 'lappuun'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-3.json#sending-a-parcel-home/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
