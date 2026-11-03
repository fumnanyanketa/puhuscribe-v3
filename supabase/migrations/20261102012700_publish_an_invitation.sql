-- Publishes the dialogue an-invitation (unit invitations-and-celebrations). Made by
-- scripts/generate/pipeline.py publish from content/drafts/an-invitation. Do not edit by hand:
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
    where slug = 'an-invitation' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'an-invitation';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 30
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'invitations-and-celebrations' and position = 30 and stop_number = 30;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'invitations-and-celebrations';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'an-invitation', 1,
    'An invitation')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'an-invitation' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'An invitation';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'an-invitation';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pidä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pidän', 'pidän',
      'present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-69e11b1f32fa');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pidän', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pidän', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän'),
      'present tense, 1st person singular', 'Pitää changes to pidä- and takes -n for ''I'': pidän. Pitää juhlat means ''to have a party''.', 'I''m having', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('syntymäpäiväjuhla', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"syntymäpäiväjuhla","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]syntymä[X]syntym[Sn][Ny]ä[Bh][Bc][Ln][Xp]päivä[X]päiv[Sn][Ny]ä[Bh][Bc][Ln][Xp]juhla[X]juhl[Sn][Nm]at","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=ppppp=pppppp","WORDBASES":"+syntymä(syntymä)+päivä(päivä)+juhla(juhla)"}'::jsonb,
      'syntymäpäiväjuhlat', 'synttärit',
      'nominative plural', 'Books write syntymäpäiväjuhlat and speech says synttärit. Both end in -t, as a party is several celebrations.', 'a birthday party', 'birthday party', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-9b938f60974f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'syntymäpäiväjuhlat', 'syntymäpäiväjuhla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Books write syntymäpäiväjuhlat and speech says synttärit. Both end in -t, as a party is several celebrations.', 'a birthday party', 'birthday party')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'syntymäpäiväjuhlat', 'syntymäpäiväjuhla',
      (select form_name_en from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit'),
      (select why_en from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit'),
      (select meaning_en from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit'),
      (select lemma_meaning_en from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit'),
      'nominative plural', 'Books write syntymäpäiväjuhlat and speech says synttärit. Both end in -t, as a party is several celebrations.', 'a birthday party', 'birthday party';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lauantai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"lauantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lauantai[X]lauantai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=pppppppppp","WORDBASES":"+lauantai(lauantai)"}'::jsonb,
      'lauantaina', 'lauantaina',
      'essive singular', 'Days take -na for ''on'': lauantai becomes lauantaina.', 'on Saturday', 'Saturday', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-3978a16fa6b0');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Te][Ap][P2][Ny][Ef]isit[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulisitko', 'tulisit',
      'conditional present tense, 2nd person singular, with the question ending -ko/-kö', '-isi- means ''would'' and -t goes with sinä. Speech says tulisitsä instead of the -ko question.', 'would you come', 'to come', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-3168306feddd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulisitko', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 2nd person singular, with the question ending -ko/-kö', '-isi- means ''would'' and -t goes with sinä. Speech says tulisitsä instead of the -ko question.', 'would you come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulisitko', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit'),
      'conditional present tense, 2nd person singular, with the question ending -ko/-kö', '-isi- means ''would'' and -t goes with sinä. Speech says tulisitsä instead of the -ko question.', 'would you come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kutsu', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"kutsu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kutsu[X]kutsu[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kutsu(kutsu)"}'::jsonb,
      'kutsusta', 'kutsusta',
      'elative singular', 'Thanking takes -sta: kutsu becomes kutsusta, ''for the invitation''.', 'for the invitation', 'invitation', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-0b979be5b0ba');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kutsusta', 'kutsu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Thanking takes -sta: kutsu becomes kutsusta, ''for the invitation''.', 'for the invitation', 'invitation')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kutsusta', 'kutsu',
      (select form_name_en from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta'),
      (select why_en from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta'),
      (select meaning_en from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta'),
      (select lemma_meaning_en from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta'),
      'elative singular', 'Thanking takes -sta: kutsu becomes kutsusta, ''for the invitation''.', 'for the invitation', 'invitation';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Te][Ap][P1][Ny][Ef]isin","MOOD":"conditional","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulisin', 'tulisin',
      'conditional present tense, 1st person singular', 'Tulla means to come. -isi- means ''would'' and -n goes with minä: tulisin.', 'I would come', 'to come', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-bddf7f381fa8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulisin', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conditional present tense, 1st person singular', 'Tulla means to come. -isi- means ''would'' and -n goes with minä: tulisin.', 'I would come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulisin', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin'),
      'conditional present tense, 1st person singular', 'Tulla means to come. -isi- means ''would'' and -n goes with minä: tulisin.', 'I would come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mieli', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"mieli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]mieli[X]miele[Sade][Ny]llä[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+mieli(mieli)"}'::jsonb,
      'mielelläni', 'mielelläni',
      'adessive singular, with the possessive ending for my', 'A fixed word meaning ''gladly''. It comes from mieli, ''mind'', with -ni for ''my''.', 'gladly', 'mind (mielelläni, gladly)', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-b2a3108e7d77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mielelläni', 'mieli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular, with the possessive ending for my', 'A fixed word meaning ''gladly''. It comes from mieli, ''mind'', with -ni for ''my''.', 'gladly', 'mind (mielelläni, gladly)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mielelläni', 'mieli',
      (select form_name_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni'),
      (select why_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni'),
      (select meaning_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni'),
      (select lemma_meaning_en from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni'),
      'adessive singular, with the possessive ending for my', 'A fixed word meaning ''gladly''. It comes from mieli, ''mind'', with -ni for ''my''.', 'gladly', 'mind (mielelläni, gladly)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hieno', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hieno","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hieno[X]hieno[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+hieno(hieno)"}'::jsonb,
      'hienoa', 'hienoo',
      'partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-2cd8ef2f37d5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hienoa', 'hieno';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hienoa', 'hieno',
      (select form_name_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select why_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      (select lemma_meaning_en from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo'),
      'partitive singular', 'Exclamations like this take -a: hieno becomes hienoa. Speech turns -oa into -oo.', 'great', 'great, fine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alkaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"alkaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]alkaa[X]alka[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+alkaa(alkaa)"}'::jsonb,
      'alkaa', 'alkaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to start, to begin', 'to start, to begin', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-66c4c8a1800c');
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
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuusi', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kuusi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kuusi[X]kuu[Sabl][Ny]delta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+kuusi(kuusi)"}'::jsonb,
      'kuudelta', 'kuudelta',
      'ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-e9d72c78c633');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuudelta', 'kuusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuudelta', 'kuusi',
      (select form_name_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select why_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      (select lemma_meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta'),
      'ablative singular', 'Clock times take -lta: kuusi becomes kuudelta, ''at six''.', 'at six', 'six';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('luona', 'CLASS=seikkasana;POSSESSIVE=1s', '{"BASEFORM":"luona","CLASS":"seikkasana","MANUAL":"true","POSSESSIVE":"1s"}'::jsonb,
      'luonani', 'luona',
      'adverb, with the possessive ending for my', 'Luona, at someone''s place, with -ni for ''my'': luonani. Speech says mun luona and drops -ni.', 'at my place', 'at someone''s place', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-4968294b3ccf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'luonani', 'luona';
  end if;
  if not exists (select 1 from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb, with the possessive ending for my', 'Luona, at someone''s place, with -ni for ''my'': luonani. Speech says mun luona and drops -ni.', 'at my place', 'at someone''s place')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'luonani', 'luona',
      (select form_name_en from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'),
      (select why_en from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'),
      (select meaning_en from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'),
      (select lemma_meaning_en from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'),
      'adverb, with the possessive ending for my', 'Luona, at someone''s place, with -ni for ''my'': luonani. Speech says mun luona and drops -ni.', 'at my place', 'at someone''s place';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voinko', 'voinks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-cbf76e213246');
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
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuoda', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tuoda","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tuoda[X]tuod[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tuoda(tuoda)"}'::jsonb,
      'tuoda', 'tuoda',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to bring', 'to bring', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-b000f6951985');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuoda', 'tuoda';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to bring', 'to bring')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuoda', 'tuoda',
      (select form_name_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda'),
      (select why_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda'),
      (select meaning_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda'),
      (select lemma_meaning_en from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to bring', 'to bring';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jokin', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"jokin","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]jokin[X]jo[Sp][Ny]tain","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+jokin(jokin)"}'::jsonb,
      'jotain', 'jotain',
      'partitive singular', 'The partitive singular of jokin ''something'': jotain. People say it the same way.', 'something', 'something, some', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-efb6648d797c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jotain', 'jokin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular of jokin ''something'': jotain. People say it the same way.', 'something', 'something, some')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jotain', 'jokin',
      (select form_name_en from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain'),
      (select why_en from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain'),
      (select meaning_en from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain'),
      (select lemma_meaning_en from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain'),
      'partitive singular', 'The partitive singular of jokin ''something'': jotain. People say it the same way.', 'something', 'something, some';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"tarvita","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'tarvitse', 'tarvii',
      'present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-f017cb16a696');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitse', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitse', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii'),
      'present tense, negative form', 'After ei the verb drops its ending: tarvita becomes tarvitse. Speech says ei tarvii.', 'need (no need)', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jos', 'CLASS=sidesana', '{"BASEFORM":"jos","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]jos[X]jos","STRUCTURE":"=ppp","WORDBASES":"+jos(jos)"}'::jsonb,
      'jos', 'jos',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-546867beb98e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jos', 'jos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jos', 'jos',
      (select form_name_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select why_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select meaning_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      (select lemma_meaning_en from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos'),
      'conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('haluta', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"haluta","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]haluta[X]halua[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+haluta(haluta)"}'::jsonb,
      'haluat', 'haluut',
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-5d3db9de3844');
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'haluat', 'haluta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'haluat', 'haluta',
      (select form_name_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select why_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      (select lemma_meaning_en from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut'),
      'present tense, 2nd person singular', 'Adds -t for ''you'': haluta becomes haluat. Speech says haluut.', 'you want', 'to want';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jälkiruoka', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"jälkiruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]jälki[X]jälk[Sn][Ny]i[Bh][Bc][Ln][Xp]ruoka[X]ruok[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp=ppppp","WORDBASES":"+jälki(jälki)+ruoka(ruoka)"}'::jsonb,
      'jälkiruoka', 'jälkkäri',
      'nominative singular', 'This is the dictionary form. Speech says jälkkäri for jälkiruoka.', 'a dessert', 'dessert', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-4ae0a7680977');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jälkiruoka', 'jälkiruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. Speech says jälkkäri for jälkiruoka.', 'a dessert', 'dessert')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jälkiruoka', 'jälkiruoka',
      (select form_name_en from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri'),
      (select why_en from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri'),
      (select meaning_en from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri'),
      (select lemma_meaning_en from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri'),
      'nominative singular', 'This is the dictionary form. Speech says jälkkäri for jälkiruoka.', 'a dessert', 'dessert';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Te][Ap][P3][Ny][Eb]isi","MOOD":"conditional","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olisi', 'ois',
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-fc63732ba497');
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
  if not exists (select 1 from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiva', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kiva","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]kiva[X]kiv[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kiva(kiva)"}'::jsonb,
      'kiva', 'kiva',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teen', 'teen',
      'present tense, 1st person singular', 'Tehdä ''to do'' becomes tee- and adds -n for ''I'': teen. People say it the same way.', 'I do (I will)', 'to do, to make', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-e78ed6ff1345');
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
  if not exists (select 1 from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suklaapallo', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"suklaapallo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]suklaa[X]suklaa[Sn][Ny][Bh][Bc][Ln][Xp]pallo[X]pallo[Sp][Nm]ja","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp=ppppppp","WORDBASES":"+suklaa(suklaa)+pallo(pallo)"}'::jsonb,
      'suklaapalloja', 'suklaapalloja',
      'partitive plural', 'Plural ''some'' takes -ja: suklaapallo becomes suklaapalloja.', 'chocolate balls', 'chocolate ball (a no-bake sweet)', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-d143f905c8c0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suklaapalloja', 'suklaapallo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ja: suklaapallo becomes suklaapalloja.', 'chocolate balls', 'chocolate ball (a no-bake sweet)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suklaapalloja', 'suklaapallo',
      (select form_name_en from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja'),
      (select why_en from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja'),
      (select meaning_en from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja'),
      (select lemma_meaning_en from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja'),
      'partitive plural', 'Plural ''some'' takes -ja: suklaapallo becomes suklaapalloja.', 'chocolate balls', 'chocolate ball (a no-bake sweet)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ne', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"ne","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]ne[X]n[Sn][Nm]e","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+ne(ne)"}'::jsonb,
      'ne', 'ne',
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-18803b094966');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ne', 'ne';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ne', 'ne',
      (select form_name_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select why_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      (select lemma_meaning_en from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne'),
      'nominative plural', 'Ne means they, for things. Speech also uses it for people.', 'they', 'they, those';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Nm][Ef]vat","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'ovat', 'on',
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-4ab061b662f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ovat', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ovat', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'),
      'present tense, 3rd person plural', 'Books write ovat for ''they are''. Speech uses on for one thing or many.', 'are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('brasilialainen', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive', '{"BASEFORM":"brasilialainen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lep][Xp]Brasilia[X]brasilia[Ll][Dg]lai[Xj]nen[X][Sp][Nm]sia","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppppppppp","WORDBASES":"+brasilia(Brasilia)+lai+nen(+nen)"}'::jsonb,
      'brasilialaisia', 'brasilialaisii',
      'partitive plural', 'Plural ''some'' takes -ia: brasilialainen becomes brasilialaisia. Speech says brasilialaisii.', 'Brazilian', 'Brazilian', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-729ac4b17241');
  end if;
  if not exists (select 1 from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'brasilialaisia', 'brasilialainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'Plural ''some'' takes -ia: brasilialainen becomes brasilialaisia. Speech says brasilialaisii.', 'Brazilian', 'Brazilian')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'brasilialaisia', 'brasilialainen',
      (select form_name_en from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii'),
      (select why_en from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii'),
      (select meaning_en from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii'),
      (select lemma_meaning_en from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii'),
      'partitive plural', 'Plural ''some'' takes -ia: brasilialainen becomes brasilialaisia. Speech says brasilialaisii.', 'Brazilian', 'Brazilian';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tykätä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tykätä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tykätä[X]tykkää[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+tykätä(tykätä)"}'::jsonb,
      'tykkäät', 'tykkäät',
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like', 'approved', now(), 'content/approvals/part-5.json#an-invitation/form-43715f936732');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tykkäät', 'tykätä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tykkäät', 'tykätä',
      (select form_name_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select why_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      (select lemma_meaning_en from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'),
      'present tense, 2nd person singular', 'Tykätä changes to tykkää- and takes -t for ''you'': tykkäät.', 'you like', 'to like';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Ahmed', 'Mä pidän synttärit lauantaina. Tulisitsä?',
    'Minä pidän syntymäpäiväjuhlat lauantaina. Tulisitko sinä?', 'I''m having a birthday party on Saturday. Would you come?',
    'an-invitation/1-puhe-2a0279e0b804.mp3', 'an-invitation/1-kirja-1685ae0f05db.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän')),
    (v_line_id, 'kirja', 3, 'syntymäpäiväjuhlat', (select id from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit')),
    (v_line_id, 'kirja', 4, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'kirja', 5, 'Tulisitko', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'pidän', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidän' and surface_puhe = 'pidän')),
    (v_line_id, 'puhe', 3, 'synttärit', (select id from public.forms where lemma = 'syntymäpäiväjuhla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'syntymäpäiväjuhlat' and surface_puhe = 'synttärit')),
    (v_line_id, 'puhe', 4, 'lauantaina', (select id from public.forms where lemma = 'lauantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'lauantaina' and surface_puhe = 'lauantaina')),
    (v_line_id, 'puhe', 5, 'Tulisit', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=conditional;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'tulisitko' and surface_puhe = 'tulisit')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Kiitti kutsusta! Tulisin mielelläni.',
    'Kiitos kutsusta! Tulisin mielelläni.', 'Thanks for the invitation! I''d love to come.',
    'an-invitation/2-puhe-2473a9f4c4d3.mp3', 'an-invitation/2-kirja-ba274211c5f0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'kutsusta', (select id from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta')),
    (v_line_id, 'kirja', 3, 'Tulisin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin')),
    (v_line_id, 'kirja', 4, 'mielelläni', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'kutsusta', (select id from public.forms where lemma = 'kutsu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'kutsusta' and surface_puhe = 'kutsusta')),
    (v_line_id, 'puhe', 3, 'Tulisin', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=conditional;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulisin' and surface_puhe = 'tulisin')),
    (v_line_id, 'puhe', 4, 'mielelläni', (select id from public.forms where lemma = 'mieli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'mielelläni' and surface_puhe = 'mielelläni'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Ahmed', 'Hienoo! Se alkaa kuudelta mun luona.',
    'Hienoa! Se alkaa kuudelta minun luonani.', 'Great! It starts at six at my place.',
    'an-invitation/3-puhe-48caecca2522.mp3', 'an-invitation/3-kirja-9be7a50ecedf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hienoa', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'kirja', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa')),
    (v_line_id, 'kirja', 4, 'kuudelta', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta')),
    (v_line_id, 'kirja', 5, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 6, 'luonani', (select id from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona')),
    (v_line_id, 'puhe', 1, 'Hienoo', (select id from public.forms where lemma = 'hieno' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hienoa' and surface_puhe = 'hienoo')),
    (v_line_id, 'puhe', 2, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'alkaa', (select id from public.forms where lemma = 'alkaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'alkaa' and surface_puhe = 'alkaa')),
    (v_line_id, 'puhe', 4, 'kuudelta', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kuudelta' and surface_puhe = 'kuudelta')),
    (v_line_id, 'puhe', 5, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 6, 'luona', (select id from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Voinks mä tuoda jotain?',
    'Voinko minä tuoda jotain?', 'Can I bring something?',
    'an-invitation/4-puhe-b6a4a80967ce.mp3', 'an-invitation/4-kirja-88e902b871b5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voinko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tuoda', (select id from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda')),
    (v_line_id, 'kirja', 4, 'jotain', (select id from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain')),
    (v_line_id, 'puhe', 1, 'Voinks', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tuoda', (select id from public.forms where lemma = 'tuoda' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tuoda' and surface_puhe = 'tuoda')),
    (v_line_id, 'puhe', 4, 'jotain', (select id from public.forms where lemma = 'jokin' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'jotain' and surface_puhe = 'jotain'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Ahmed', 'Ei tarvii. Mut jos haluut, jälkkäri ois kiva.',
    'Ei tarvitse. Mutta jos haluat, jälkiruoka olisi kiva.', 'No need. But if you want, a dessert would be nice.',
    'an-invitation/5-puhe-16e11b0bf227.mp3', 'an-invitation/5-kirja-faf64b236961.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'tarvitse', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'kirja', 3, 'Mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 4, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'kirja', 5, 'haluat', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut')),
    (v_line_id, 'kirja', 6, 'jälkiruoka', (select id from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri')),
    (v_line_id, 'kirja', 7, 'olisi', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'kirja', 8, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'tarvii', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'tarvitse' and surface_puhe = 'tarvii')),
    (v_line_id, 'puhe', 3, 'Mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 4, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'puhe', 5, 'haluut', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluat' and surface_puhe = 'haluut')),
    (v_line_id, 'puhe', 6, 'jälkkäri', (select id from public.forms where lemma = 'jälkiruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'jälkiruoka' and surface_puhe = 'jälkkäri')),
    (v_line_id, 'puhe', 7, 'ois', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'puhe', 8, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Mä teen suklaapalloja!',
    'Minä teen suklaapalloja!', 'I''ll make chocolate balls!',
    'an-invitation/6-puhe-220c68a89b5d.mp3', 'an-invitation/6-kirja-f2018b1c9230.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'kirja', 3, 'suklaapalloja', (select id from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'puhe', 3, 'suklaapalloja', (select id from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Ahmed', 'Mitä ne on?',
    'Mitä ne ovat?', 'What are they?',
    'an-invitation/7-puhe-1a65bc96d730.mp3', 'an-invitation/7-kirja-aef77fbe6cf4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 2, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'kirja', 3, 'ovat', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 2, 'ne', (select id from public.forms where lemma = 'ne' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'ne' and surface_puhe = 'ne')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ovat' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Brasilialaisii suklaapalloja. Sä tykkäät!',
    'Brasilialaisia suklaapalloja. Sinä tykkäät!', 'Brazilian chocolate balls. You''ll love them!',
    'an-invitation/8-puhe-64cd9cf13c8a.mp3', 'an-invitation/8-kirja-523ac872b32d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Brasilialaisia', (select id from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii')),
    (v_line_id, 'kirja', 2, 'suklaapalloja', (select id from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja')),
    (v_line_id, 'kirja', 3, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät')),
    (v_line_id, 'puhe', 1, 'Brasilialaisii', (select id from public.forms where lemma = 'brasilialainen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=plural;COMPARISON=positive' and surface_kirja = 'brasilialaisia' and surface_puhe = 'brasilialaisii')),
    (v_line_id, 'puhe', 2, 'suklaapalloja', (select id from public.forms where lemma = 'suklaapallo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'suklaapalloja' and surface_puhe = 'suklaapalloja')),
    (v_line_id, 'puhe', 3, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'tykkäät', (select id from public.forms where lemma = 'tykätä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tykkäät' and surface_puhe = 'tykkäät'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#an-invitation/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
