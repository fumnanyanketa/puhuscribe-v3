-- Publishes the dialogue tomorrow-at-work (unit my-plans). Made by
-- scripts/generate/pipeline.py publish from content/drafts/tomorrow-at-work. Do not edit by hand:
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
    where slug = 'tomorrow-at-work' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'tomorrow-at-work';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 34
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'my-plans' and position = 34 and stop_number = 34;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'my-plans';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'tomorrow-at-work', 3,
    'Tomorrow at work')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'tomorrow-at-work' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Tomorrow at work';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'tomorrow-at-work';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulla', 'sul',
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huomenna', 'CLASS=seikkasana', '{"BASEFORM":"huomenna","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]huomenna[X]huomenna","STRUCTURE":"=pppppppp","WORDBASES":"+huomenna(huomenna)"}'::jsonb,
      'huomenna', 'huomenna',
      'adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-08b72686d46b');
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
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamu', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"aamu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+aamu(aamu)"}'::jsonb,
      'aamulla', 'aamul',
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-5166646a9be8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamulla', 'aamu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamulla', 'aamu',
      (select form_name_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select why_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      (select lemma_meaning_en from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul'),
      'adessive singular', 'Adds -lla for a time of day: aamu becomes aamulla. Speech shortens -lla to -l: aamulla becomes aamul.', 'in the morning', 'morning';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('palaveri', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"palaveri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pala[X]pal[Sn][Ny]a[Bh][Bc][Ln][Xp]veri[X]ver[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=pppp","WORDBASES":"+pala(pala)+veri(veri)"}'::jsonb,
      'palaveri', 'palaveri',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'meeting', 'meeting', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-da77c42cf943');
  end if;
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'palaveri', 'palaveri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'meeting', 'meeting')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'palaveri', 'palaveri',
      (select form_name_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri'),
      (select why_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri'),
      (select meaning_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri'),
      (select lemma_meaning_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'meeting', 'meeting';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asiakas', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"asiakas","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asiakas[X]asiakkaa[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppppp","WORDBASES":"+asiakas(asiakas)"}'::jsonb,
      'asiakkaan', 'asiakkaan',
      'genitive singular', 'Kanssa, ''with'', needs -n on the word before: asiakas becomes asiakkaan.', 'a client', 'customer, client', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-d5d0b84b264d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asiakkaan', 'asiakas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kanssa, ''with'', needs -n on the word before: asiakas becomes asiakkaan.', 'a client', 'customer, client')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asiakkaan', 'asiakas',
      (select form_name_en from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan'),
      (select why_en from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan'),
      (select meaning_en from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan'),
      (select lemma_meaning_en from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan'),
      'genitive singular', 'Kanssa, ''with'', needs -n on the word before: asiakas becomes asiakkaan.', 'a client', 'customer, client';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa","STRUCTURE":"=pppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssa', 'kaa',
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-6105fb644788');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kanssa', 'kanssa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kanssa', 'kanssa',
      (select form_name_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select why_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      (select lemma_meaning_en from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'),
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iltapäivä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"iltapäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]ilt[Sn][Ny]a[Bh][Bc][Ln][Xp]päivä[X]päivä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp=pppppppp","WORDBASES":"+ilta(ilta)+päivä(päivä)"}'::jsonb,
      'iltapäivällä', 'iltapäiväl',
      'adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-de597eea4acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'iltapäivällä', 'iltapäivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'iltapäivällä', 'iltapäivä',
      (select form_name_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select why_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select meaning_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      (select lemma_meaning_en from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'),
      'adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teen', 'teen',
      'present tense, 1st person singular', 'Tehdä ''to do'' becomes tee- and adds -n for ''I'': teen. People say it the same way.', 'I do (I will)', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-e78ed6ff1345');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teen', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Tehdä ''to do'' becomes tee- and adds -n for ''I'': teen. People say it the same way.', 'I do (I will)', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teen', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen'),
      'present tense, 1st person singular', 'Tehdä ''to do'' becomes tee- and adds -n for ''I'': teen. People say it the same way.', 'I do (I will)', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('raportti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"raportti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]raportti[X]raport[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+raportti(raportti)"}'::jsonb,
      'raportin', 'raportin',
      'genitive singular', 'A whole thing made takes -n: raportti becomes raportin, tt turning into t.', 'the report', 'report', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-fd24cdfa742e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'raportin', 'raportti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'A whole thing made takes -n: raportti becomes raportin, tt turning into t.', 'the report', 'report')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'raportin', 'raportti',
      (select form_name_en from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin'),
      (select why_en from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin'),
      (select meaning_en from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin'),
      (select lemma_meaning_en from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin'),
      'genitive singular', 'A whole thing made takes -n: raportti becomes raportin, tt turning into t.', 'the report', 'report';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ehtiä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"ehtiä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ehtiä[X]ehdi[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+ehtiä(ehtiä)"}'::jsonb,
      'ehditkö', 'ehit',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Ehtiä means to have time. Books write ehditkö. Speech says ehitsä, dropping the d.', 'will you have time', 'to have time, to make it', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-f00bf48e0303');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ehditkö', 'ehtiä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Ehtiä means to have time. Books write ehditkö. Speech says ehitsä, dropping the d.', 'will you have time', 'to have time, to make it')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ehditkö', 'ehtiä',
      (select form_name_en from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit'),
      (select why_en from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit'),
      (select meaning_en from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit'),
      (select lemma_meaning_en from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Ehtiä means to have time. Books write ehditkö. Speech says ehitsä, dropping the d.', 'will you have time', 'to have time, to make it';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tehd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'tehdä', 'tehä',
      'basic form (A-infinitive)', 'This is the dictionary form, after voin (I can). Speech drops the d: tehä.', 'do', 'to do, to make', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-f64c6f94ba00');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-1bca14269daf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sen', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sen', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'),
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähettää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"lähettää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähettää[X]lähetä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+lähettää(lähettää)"}'::jsonb,
      'lähetän', 'lähetän',
      'present tense, 1st person singular', 'Lähettää means to send. -n goes with minä, and tt turns into t: lähetän.', 'I''ll send', 'to send', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-93882409b4cd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähetän', 'lähettää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Lähettää means to send. -n goes with minä, and tt turns into t: lähetän.', 'I''ll send', 'to send')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähetän', 'lähettää',
      (select form_name_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän'),
      (select why_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän'),
      (select meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän'),
      (select lemma_meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän'),
      'present tense, 1st person singular', 'Lähettää means to send. -n goes with minä, and tt turns into t: lähetän.', 'I''ll send', 'to send';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-026c280fc0ae');
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
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sill][Ny]ään","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljään', 'neljään',
      'illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-a83956a0f1a5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neljään', 'neljä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neljään', 'neljä',
      (select form_name_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select why_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      (select lemma_meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään'),
      'illative singular', 'The illative singular gives ''until'' with a clock time: neljä becomes neljään.', 'until four', 'four';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;MOOD=E-infinitive', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tn2]essä","MOOD":"E-infinitive","STRUCTURE":"=pppppppp","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennessä', 'mennes',
      'E-infinitive', 'Neljään mennessä means ''by four''. Speech shortens -ssä to -s: mennessä becomes mennes.', 'by (a time)', 'to go', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-b8f606123345');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennessä', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('E-infinitive', 'Neljään mennessä means ''by four''. Speech shortens -ssä to -s: mennessä becomes mennes.', 'by (a time)', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennessä', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes'),
      'E-infinitive', 'Neljään mennessä means ''by four''. Speech shortens -ssä to -s: mennessä becomes mennes.', 'by (a time)', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täydellinen', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"täydellinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]täydellinen[X]täydelli[Sp][Ny]stä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+täydellinen(täydellinen)"}'::jsonb,
      'täydellistä', 'täydellistä',
      'partitive singular', 'The partitive singular is used in exclamations: täydellinen becomes täydellistä.', 'great (just right)', 'perfect', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-b5ed22a41039');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täydellistä', 'täydellinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used in exclamations: täydellinen becomes täydellistä.', 'great (just right)', 'perfect')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täydellistä', 'täydellinen',
      (select form_name_en from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä'),
      (select why_en from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä'),
      (select meaning_en from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä'),
      (select lemma_meaning_en from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä'),
      'partitive singular', 'The partitive singular is used in exclamations: täydellinen becomes täydellistä.', 'great (just right)', 'perfect';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kestää', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"kestää","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'kestä', 'mitään',
      'present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)', 'approved', now(), 'content/approvals/part-6.json#tomorrow-at-work/form-6eb46dbcfd77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kestä', 'kestää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kestä', 'kestää',
      (select form_name_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select why_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select lemma_meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      'present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Hanna', 'Maria, mitä sul on huomenna?',
    'Maria, mitä sinulla on huomenna?', 'Maria, what do you have tomorrow?',
    'tomorrow-at-work/1-puhe-7db1a85bb29d.mp3', 'tomorrow-at-work/1-kirja-948891e6afee.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Maria', null),
    (v_line_id, 'kirja', 2, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 3, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'puhe', 1, 'Maria', null),
    (v_line_id, 'puhe', 2, 'mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 3, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Aamul mul on palaveri asiakkaan kaa.',
    'Aamulla minulla on palaveri asiakkaan kanssa.', 'In the morning I have a meeting with a client.',
    'tomorrow-at-work/2-puhe-639001a0bd73.mp3', 'tomorrow-at-work/2-kirja-04cdb40cb076.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Aamulla', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'kirja', 2, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'palaveri', (select id from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri')),
    (v_line_id, 'kirja', 5, 'asiakkaan', (select id from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan')),
    (v_line_id, 'kirja', 6, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Aamul', (select id from public.forms where lemma = 'aamu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamulla' and surface_puhe = 'aamul')),
    (v_line_id, 'puhe', 2, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'palaveri', (select id from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'palaveri' and surface_puhe = 'palaveri')),
    (v_line_id, 'puhe', 5, 'asiakkaan', (select id from public.forms where lemma = 'asiakas' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'asiakkaan' and surface_puhe = 'asiakkaan')),
    (v_line_id, 'puhe', 6, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Hanna', 'Ja iltapäiväl?',
    'Ja iltapäivällä?', 'And in the afternoon?',
    'tomorrow-at-work/3-puhe-a2c13c8360e2.mp3', 'tomorrow-at-work/3-kirja-f5c5234ac34e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'iltapäivällä', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'iltapäiväl', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Iltapäiväl mä teen raportin.',
    'Iltapäivällä minä teen raportin.', 'In the afternoon I''m writing the report.',
    'tomorrow-at-work/4-puhe-972d84493a93.mp3', 'tomorrow-at-work/4-kirja-66f0797143e4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Iltapäivällä', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'kirja', 4, 'raportin', (select id from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin')),
    (v_line_id, 'puhe', 1, 'Iltapäiväl', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'puhe', 4, 'raportin', (select id from public.forms where lemma = 'raportti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'raportin' and surface_puhe = 'raportin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Hanna', 'Hyvä. Ehitsä tehä sen huomenna?',
    'Hyvä. Ehditkö sinä tehdä sen huomenna?', 'Good. Will you have time to do it tomorrow?',
    'tomorrow-at-work/5-puhe-d40ecadcca98.mp3', 'tomorrow-at-work/5-kirja-3c4becaba119.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Ehditkö', (select id from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'tehdä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'kirja', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Ehit', (select id from public.forms where lemma = 'ehtiä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'ehditkö' and surface_puhe = 'ehit')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'tehä', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tehdä' and surface_puhe = 'tehä')),
    (v_line_id, 'puhe', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, mä lähetän sen sulle neljään mennes.',
    'Kyllä, minä lähetän sen sinulle neljään mennessä.', 'Yes, I''ll send it to you by four.',
    'tomorrow-at-work/6-puhe-05b71bab992d.mp3', 'tomorrow-at-work/6-kirja-cc3e0b2256d9.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'lähetän', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän')),
    (v_line_id, 'kirja', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 5, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 6, 'neljään', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään')),
    (v_line_id, 'kirja', 7, 'mennessä', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'lähetän', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetän' and surface_puhe = 'lähetän')),
    (v_line_id, 'puhe', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 5, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 6, 'neljään', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'neljään' and surface_puhe = 'neljään')),
    (v_line_id, 'puhe', 7, 'mennes', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;MOOD=E-infinitive' and surface_kirja = 'mennessä' and surface_puhe = 'mennes'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Hanna', 'Täydellistä. Kiitti!',
    'Täydellistä. Kiitos!', 'Perfect. Thanks!',
    'tomorrow-at-work/7-puhe-c783bc45a2ba.mp3', 'tomorrow-at-work/7-kirja-7f9a60a9b6c0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Täydellistä', (select id from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä')),
    (v_line_id, 'kirja', 2, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 1, 'Täydellistä', (select id from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä')),
    (v_line_id, 'puhe', 2, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Ei mitään.',
    'Ei kestä.', 'You''re welcome.',
    'tomorrow-at-work/8-puhe-a841ed2aee12.mp3', 'tomorrow-at-work/8-kirja-95cb2c48a5d5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'kestä', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'mitään', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#tomorrow-at-work/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
