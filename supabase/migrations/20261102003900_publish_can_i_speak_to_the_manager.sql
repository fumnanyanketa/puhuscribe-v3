-- Publishes the dialogue can-i-speak-to-the-manager (unit phone-calls-and-messages). Made by
-- scripts/generate/pipeline.py publish from content/drafts/can-i-speak-to-the-manager. Do not edit by hand:
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
    where slug = 'can-i-speak-to-the-manager' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'can-i-speak-to-the-manager';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 14
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'phone-calls-and-messages' and position = 14 and stop_number = 14;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'phone-calls-and-messages';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'can-i-speak-to-the-manager', 1,
    'Can I speak to the manager?')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'can-i-speak-to-the-manager' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Can I speak to the manager?';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'can-i-speak-to-the-manager';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asunto', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"asunto","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asunto[X]asunto[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+asunto(asunto)"}'::jsonb,
      'asunto', 'asunto',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-31b82be4b373');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asunto', 'asunto';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asunto', 'asunto',
      (select form_name_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select why_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      (select lemma_meaning_en from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'flat, apartment', 'flat, apartment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tässä', 'täs',
      'inessive singular', 'Tämä, this, with -ssä for ''in'': tässä, here. Speech shortens -ssä to -s: tässä becomes täs.', 'here', 'this', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-25ac6c76f4b0');
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
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voinko', 'voinks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Voin, I can, with -ko to ask. Speech says -ks: voinks.', 'can I?', 'can, to be able to', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-cbf76e213246');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puhua', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"puhua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]puhua[X]puhu[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+puhua(puhua)"}'::jsonb,
      'puhua', 'puhuu',
      'basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-1e2e7b912f42');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puhua', 'puhua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puhua', 'puhua',
      (select form_name_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select why_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      (select lemma_meaning_en from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu'),
      'basic form (A-infinitive)', 'Puhua in its basic form after voitko. Speech turns -ua into -uu.', 'speak', 'to speak, to talk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('isännöitsijä', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"isännöitsijä","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]isännöidä[X]isännöitsi[Ln][Xj]jä[X][Sg][Ny]jän","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppppppppp","WORDBASES":"+isännöitsi(isännöidä)+jä(+jä)"}'::jsonb,
      'isännöitsijän', 'isännöitsijän',
      'genitive singular', 'The genitive singular goes before kanssa ''with'': isännöitsijä becomes isännöitsijän.', 'the building manager''s', 'building manager', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-f8845f3fcd5b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'isännöitsijän', 'isännöitsijä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before kanssa ''with'': isännöitsijä becomes isännöitsijän.', 'the building manager''s', 'building manager')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'isännöitsijän', 'isännöitsijä',
      (select form_name_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän'),
      (select why_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän'),
      (select meaning_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän'),
      (select lemma_meaning_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän'),
      'genitive singular', 'The genitive singular goes before kanssa ''with'': isännöitsijä becomes isännöitsijän.', 'the building manager''s', 'building manager';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kanssa', 'CLASS=suhdesana', '{"BASEFORM":"kanssa","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]kanssa[X]kanssa","STRUCTURE":"=pppppp","WORDBASES":"+kanssa(kanssa)"}'::jsonb,
      'kanssa', 'kaa',
      'adposition', 'Speech shortens kanssa to kaa. Books write kanssa.', 'with', 'with', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-6105fb644788');
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
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-d5b687de866a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hän', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hän', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se'),
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-00cf76bd38f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nyt', 'nyt';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nyt', 'nyt',
      (select form_name_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select why_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      (select lemma_meaning_en from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now';
  end if;
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('palaveri', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"palaveri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]palaveri[X]palaveri[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppppp","WORDBASES":"+palaveri(palaveri)"}'::jsonb,
      'palaverissa', 'palaverissa',
      'inessive singular', 'Adds -ssa for ''in'': palaveri becomes palaverissa.', 'in a meeting', 'meeting', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-3884ca1cfb91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'palaverissa', 'palaveri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': palaveri becomes palaverissa.', 'in a meeting', 'meeting')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'palaverissa', 'palaveri',
      (select form_name_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa'),
      (select why_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa'),
      (select meaning_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa'),
      (select lemma_meaning_en from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa'),
      'inessive singular', 'Adds -ssa for ''in'': palaveri becomes palaverissa.', 'in a meeting', 'meeting';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('auttaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"auttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]auttaa[X]autta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+auttaa(auttaa)"}'::jsonb,
      'auttaa', 'auttaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-b4a17f5a61be');
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'auttaa', 'auttaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'auttaa', 'auttaa',
      (select form_name_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select why_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select meaning_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      (select lemma_meaning_en from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kysymys', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kysymys","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kysymys[X]kysymy[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+kysymys(kysymys)"}'::jsonb,
      'kysymys', 'kysymys',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'question', 'question', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-cf72ec523e3f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kysymys', 'kysymys';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'question', 'question')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kysymys', 'kysymys',
      (select form_name_en from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys'),
      (select why_en from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys'),
      (select meaning_en from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys'),
      (select lemma_meaning_en from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'question', 'question';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saunavuoro', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"saunavuoro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sn][Ny]a[Bh][Bc][Ln][Xp]vuoro[X]vuoro[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppp=pppppppp","WORDBASES":"+sauna(sauna)+vuoro(vuoro)"}'::jsonb,
      'saunavuorosta', 'saunavuorosta',
      'elative singular', 'Adds -sta for ''about'': saunavuoro becomes saunavuorosta.', 'about the sauna slot', 'sauna slot, sauna turn', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-e65b8aa2359c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunavuorosta', 'saunavuoro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Adds -sta for ''about'': saunavuoro becomes saunavuorosta.', 'about the sauna slot', 'sauna slot, sauna turn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunavuorosta', 'saunavuoro',
      (select form_name_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta'),
      (select why_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta'),
      (select meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta'),
      (select lemma_meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta'),
      'elative singular', 'Adds -sta for ''about'': saunavuoro becomes saunavuorosta.', 'about the sauna slot', 'sauna slot, sauna turn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('soittaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"soittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]soittaa[X]soitta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppppp","WORDBASES":"+soittaa(soittaa)"}'::jsonb,
      'soittaa', 'soittaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to call, to play (music)', 'to call, to play (music)', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-3974c630f6b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'soittaa', 'soittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to call, to play (music)', 'to call, to play (music)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'soittaa', 'soittaa',
      (select form_name_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa'),
      (select why_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa'),
      (select meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa'),
      (select lemma_meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to call, to play (music)', 'to call, to play (music)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-026c280fc0ae');
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
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takaisin', 'CLASS=seikkasana', '{"BASEFORM":"takaisin","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'takaisin', 'takas',
      'adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-2c5f4daf7d39');
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'takaisin', 'takaisin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'takaisin', 'takaisin',
      (select form_name_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select why_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select meaning_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      (select lemma_meaning_en from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas'),
      'adverb', 'Speech shortens takaisin to takas. Books write takaisin.', 'back', 'back';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iltapäivä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"iltapäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]ilt[Sn][Ny]a[Bh][Bc][Ln][Xp]päivä[X]päivä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp=pppppppp","WORDBASES":"+ilta(ilta)+päivä(päivä)"}'::jsonb,
      'iltapäivällä', 'iltapäiväl',
      'adessive singular', 'Adds -llä for a time of day: iltapäivä becomes iltapäivällä. Speech shortens -llä to -l: iltapäivällä becomes iltapäiväl.', 'in the afternoon', 'afternoon', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-de597eea4acd');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sn][Ny]kä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mikä', 'mikä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'what, which', 'what, which', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-bfff487cc1b5');
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
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('numero', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s', '{"BASEFORM":"numero","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]numero[X]numero[Sn][Ny][O2y]si","NUMBER":"singular","POSSESSIVE":"2s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+numero(numero)"}'::jsonb,
      'numerosi', 'numero',
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': numero becomes numerosi. Speech just says sun numero.', 'your number', 'number', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-38ce48baa6dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'numerosi', 'numero';
  end if;
  if not exists (select 1 from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for your', 'Adds -si for ''your'': numero becomes numerosi. Speech just says sun numero.', 'your number', 'number')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'numerosi', 'numero',
      (select form_name_en from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero'),
      (select why_en from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero'),
      (select meaning_en from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero'),
      (select lemma_meaning_en from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero'),
      'nominative singular, with the possessive ending for your', 'Adds -si for ''your'': numero becomes numerosi. Speech just says sun numero.', 'your number', 'number';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nolla', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"nolla","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]nolla[X]noll[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+nolla(nolla)"}'::jsonb,
      'nolla', 'nolla',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'zero', 'zero', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-0cdfec6fd195');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nolla', 'nolla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'zero', 'zero')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nolla', 'nolla',
      (select form_name_en from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla'),
      (select why_en from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla'),
      (select meaning_en from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla'),
      (select lemma_meaning_en from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'zero', 'zero';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljä', 'neljä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'four', 'four', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-f2a0946c62d5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'neljä', 'neljä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'four', 'four')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'neljä', 'neljä',
      (select form_name_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä'),
      (select why_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä'),
      (select meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä'),
      (select lemma_meaning_en from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'four', 'four';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viisi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viisi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]viisi[X]vii[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+viisi(viisi)"}'::jsonb,
      'viisi', 'viis',
      'nominative singular', 'Speech drops the final i: viisi becomes viis.', 'five', 'five', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-56e27afb5a19');
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
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yksi', 'yks',
      'nominative singular', 'Speech drops the final i: yksi becomes yks.', 'one', 'one', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-77de6561f822');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolme', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolme","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolme', 'kolme',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-9242c81b9d91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kolme', 'kolme';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kolme', 'kolme',
      (select form_name_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select why_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      (select lemma_meaning_en from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuusi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuusi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kuusi[X]kuu[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kuusi(kuusi)"}'::jsonb,
      'kuusi', 'kuus',
      'nominative singular', 'Speech drops the final i: kuusi becomes kuus.', 'six', 'six', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-0790aad5d8d9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuusi', 'kuusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: kuusi becomes kuus.', 'six', 'six')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuusi', 'kuusi',
      (select form_name_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus'),
      (select why_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus'),
      (select meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus'),
      (select lemma_meaning_en from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus'),
      'nominative singular', 'Speech drops the final i: kuusi becomes kuus.', 'six', 'six';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('seitsemän', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"seitsemän","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]seitsemän[X]seitsem[Sn][Ny]än","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppppp","WORDBASES":"+seitsemän(seitsemän)"}'::jsonb,
      'seitsemän', 'seittemän',
      'nominative singular', 'Speech softens the ts to tt: seitsemän becomes seittemän. Books write seitsemän.', 'seven', 'seven', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-3336db778c04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'seitsemän', 'seitsemän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech softens the ts to tt: seitsemän becomes seittemän. Books write seitsemän.', 'seven', 'seven')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'seitsemän', 'seitsemän',
      (select form_name_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän'),
      (select why_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän'),
      (select meaning_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän'),
      (select lemma_meaning_en from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän'),
      'nominative singular', 'Speech softens the ts to tt: seitsemän becomes seittemän. Books write seitsemän.', 'seven', 'seven';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kirjoittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"kirjoittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kirjoittaa[X]kirjoit[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"past_imperfective","WORDBASES":"+kirjoittaa(kirjoittaa)"}'::jsonb,
      'kirjoitin', 'kirjotin',
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': kirjoittaa becomes kirjoitin. Speech drops the i: kirjotin.', 'I wrote', 'to write', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-e565ad3553a0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kirjoitin', 'kirjoittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': kirjoittaa becomes kirjoitin. Speech drops the i: kirjotin.', 'I wrote', 'to write')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kirjoitin', 'kirjoittaa',
      (select form_name_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin'),
      (select why_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin'),
      (select meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin'),
      (select lemma_meaning_en from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin'),
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': kirjoittaa becomes kirjoitin. Speech drops the i: kirjotin.', 'I wrote', 'to write';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ylös', 'CLASS=seikkasana', '{"BASEFORM":"ylös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]ylös[X]ylös","STRUCTURE":"=pppp","WORDBASES":"+ylös(ylös)"}'::jsonb,
      'ylös', 'ylös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'up', 'up', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-f0f54efe701b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ylös', 'ylös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'up', 'up')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ylös', 'ylös',
      (select form_name_en from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös'),
      (select why_en from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös'),
      (select meaning_en from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös'),
      (select lemma_meaning_en from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'up', 'up';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulemiin', 'CLASS=huudahdussana', '{"BASEFORM":"kuulemiin","CLASS":"huudahdussana","MANUAL":"true"}'::jsonb,
      'kuulemiin', 'kuulemiin',
      'interjection', 'This is the dictionary form. People say it the same way.', 'goodbye (on the phone)', 'goodbye (on the phone)', 'approved', now(), 'content/approvals/part-3.json#can-i-speak-to-the-manager/form-3caaaaf5830c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuulemiin', 'kuulemiin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'goodbye (on the phone)', 'goodbye (on the phone)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuulemiin', 'kuulemiin',
      (select form_name_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin'),
      (select why_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin'),
      (select meaning_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'goodbye (on the phone)', 'goodbye (on the phone)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Kalle', 'Asunto Oy Kallio, Kalle täs.',
    'Asunto Oy Kallio, Kalle tässä.', 'Kallio Housing, Kalle speaking.',
    'can-i-speak-to-the-manager/1-puhe-84fc1d5bcd51.mp3', 'can-i-speak-to-the-manager/1-kirja-94d03ced73e3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Asunto', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto')),
    (v_line_id, 'kirja', 2, 'Oy', null),
    (v_line_id, 'kirja', 3, 'Kallio', null),
    (v_line_id, 'kirja', 4, 'Kalle', null),
    (v_line_id, 'kirja', 5, 'tässä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs')),
    (v_line_id, 'puhe', 1, 'Asunto', (select id from public.forms where lemma = 'asunto' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asunto' and surface_puhe = 'asunto')),
    (v_line_id, 'puhe', 2, 'Oy', null),
    (v_line_id, 'puhe', 3, 'Kallio', null),
    (v_line_id, 'puhe', 4, 'Kalle', null),
    (v_line_id, 'puhe', 5, 'täs', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tässä' and surface_puhe = 'täs'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Moi! Voinks mä puhuu isännöitsijän kaa?',
    'Hei! Voinko minä puhua isännöitsijän kanssa?', 'Hi! Can I speak with the building manager?',
    'can-i-speak-to-the-manager/2-puhe-21e994d5e69a.mp3', 'can-i-speak-to-the-manager/2-kirja-8e760999c244.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Voinko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'puhua', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu')),
    (v_line_id, 'kirja', 5, 'isännöitsijän', (select id from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän')),
    (v_line_id, 'kirja', 6, 'kanssa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Voinks', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'puhuu', (select id from public.forms where lemma = 'puhua' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'puhua' and surface_puhe = 'puhuu')),
    (v_line_id, 'puhe', 5, 'isännöitsijän', (select id from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'isännöitsijän' and surface_puhe = 'isännöitsijän')),
    (v_line_id, 'puhe', 6, 'kaa', (select id from public.forms where lemma = 'kanssa' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'kanssa' and surface_puhe = 'kaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Kalle', 'Se on nyt palaverissa. Voinks mä auttaa?',
    'Hän on nyt palaverissa. Voinko minä auttaa?', 'He''s in a meeting now. Can I help?',
    'can-i-speak-to-the-manager/3-puhe-a5ec398e2588.mp3', 'can-i-speak-to-the-manager/3-kirja-f964b9cad3e2.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 4, 'palaverissa', (select id from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa')),
    (v_line_id, 'kirja', 5, 'Voinko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'kirja', 6, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 7, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 4, 'palaverissa', (select id from public.forms where lemma = 'palaveri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'palaverissa' and surface_puhe = 'palaverissa')),
    (v_line_id, 'puhe', 5, 'Voinks', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voinko' and surface_puhe = 'voinks')),
    (v_line_id, 'puhe', 6, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 7, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Mul on kysymys saunavuorosta.',
    'Minulla on kysymys saunavuorosta.', 'I have a question about the sauna slot.',
    'can-i-speak-to-the-manager/4-puhe-90a19c6592ad.mp3', 'can-i-speak-to-the-manager/4-kirja-42a1cf7884ac.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'kysymys', (select id from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys')),
    (v_line_id, 'kirja', 4, 'saunavuorosta', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta')),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'kysymys', (select id from public.forms where lemma = 'kysymys' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kysymys' and surface_puhe = 'kysymys')),
    (v_line_id, 'puhe', 4, 'saunavuorosta', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunavuorosta' and surface_puhe = 'saunavuorosta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Kalle', 'Se soittaa sulle takas iltapäiväl. Mikä sun numero on?',
    'Hän soittaa sinulle takaisin iltapäivällä. Mikä sinun numerosi on?', 'He''ll call you back in the afternoon. What''s your number?',
    'can-i-speak-to-the-manager/5-puhe-a27c8f7c01ea.mp3', 'can-i-speak-to-the-manager/5-kirja-17027350442f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'soittaa', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa')),
    (v_line_id, 'kirja', 3, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 4, 'takaisin', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas')),
    (v_line_id, 'kirja', 5, 'iltapäivällä', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'kirja', 6, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'kirja', 7, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 8, 'numerosi', (select id from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero')),
    (v_line_id, 'kirja', 9, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'soittaa', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'soittaa' and surface_puhe = 'soittaa')),
    (v_line_id, 'puhe', 3, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 4, 'takas', (select id from public.forms where lemma = 'takaisin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'takaisin' and surface_puhe = 'takas')),
    (v_line_id, 'puhe', 5, 'iltapäiväl', (select id from public.forms where lemma = 'iltapäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'iltapäivällä' and surface_puhe = 'iltapäiväl')),
    (v_line_id, 'puhe', 6, 'Mikä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'mikä' and surface_puhe = 'mikä')),
    (v_line_id, 'puhe', 7, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 8, 'numero', (select id from public.forms where lemma = 'numero' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=2s' and surface_kirja = 'numerosi' and surface_puhe = 'numero')),
    (v_line_id, 'puhe', 9, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Nolla neljä viis, yks kaks kolme, neljä viis kuus seittemän.',
    'Nolla neljä viisi, yksi kaksi kolme, neljä viisi kuusi seitsemän.', '045 123 4567.',
    'can-i-speak-to-the-manager/6-puhe-916ae632c043.mp3', 'can-i-speak-to-the-manager/6-kirja-d438d349a23c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Nolla', (select id from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla')),
    (v_line_id, 'kirja', 2, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä')),
    (v_line_id, 'kirja', 3, 'viisi', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'kirja', 4, 'yksi', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'kirja', 5, 'kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 6, 'kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'kirja', 7, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä')),
    (v_line_id, 'kirja', 8, 'viisi', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'kirja', 9, 'kuusi', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus')),
    (v_line_id, 'kirja', 10, 'seitsemän', (select id from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän')),
    (v_line_id, 'puhe', 1, 'Nolla', (select id from public.forms where lemma = 'nolla' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'nolla' and surface_puhe = 'nolla')),
    (v_line_id, 'puhe', 2, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä')),
    (v_line_id, 'puhe', 3, 'viis', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'puhe', 4, 'yks', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'yksi' and surface_puhe = 'yks')),
    (v_line_id, 'puhe', 5, 'kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 6, 'kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'puhe', 7, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä')),
    (v_line_id, 'puhe', 8, 'viis', (select id from public.forms where lemma = 'viisi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viisi' and surface_puhe = 'viis')),
    (v_line_id, 'puhe', 9, 'kuus', (select id from public.forms where lemma = 'kuusi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuusi' and surface_puhe = 'kuus')),
    (v_line_id, 'puhe', 10, 'seittemän', (select id from public.forms where lemma = 'seitsemän' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'seitsemän' and surface_puhe = 'seittemän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Kalle', 'Kiitti, mä kirjotin sen ylös.',
    'Kiitos, minä kirjoitin sen ylös.', 'Thanks, I wrote it down.',
    'can-i-speak-to-the-manager/7-puhe-40225179e7f5.mp3', 'can-i-speak-to-the-manager/7-kirja-1bc2ff66785f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'kirjoitin', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin')),
    (v_line_id, 'kirja', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 5, 'ylös', (select id from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'kirjotin', (select id from public.forms where lemma = 'kirjoittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'kirjoitin' and surface_puhe = 'kirjotin')),
    (v_line_id, 'puhe', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 5, 'ylös', (select id from public.forms where lemma = 'ylös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'ylös' and surface_puhe = 'ylös'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti, kuulemiin!',
    'Kiitos, kuulemiin!', 'Thanks, goodbye!',
    'can-i-speak-to-the-manager/8-puhe-8c97d6ae7065.mp3', 'can-i-speak-to-the-manager/8-kirja-b5d97480046d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'kuulemiin', (select id from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'kuulemiin', (select id from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'kuulemiin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#can-i-speak-to-the-manager/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
