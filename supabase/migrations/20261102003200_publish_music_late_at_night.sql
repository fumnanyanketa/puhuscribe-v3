-- Publishes the dialogue music-late-at-night (unit home-and-neighbours). Made by
-- scripts/generate/pipeline.py publish from content/drafts/music-late-at-night. Do not edit by hand:
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
    where slug = 'music-late-at-night' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'music-late-at-night';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 11
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'home-and-neighbours' and position = 11 and stop_number = 11;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'home-and-neighbours';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'music-late-at-night', 3,
    'Music late at night')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'music-late-at-night' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Music late at night';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'music-late-at-night';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asua', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"asua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]asua[X]asu[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+asua(asua)"}'::jsonb,
      'asun', 'asun',
      'present tense, 1st person singular', 'Asua, to live, with -n for ''I'': asun.', 'I live', 'to live (somewhere)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-fa80f853ff79');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asun', 'asua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Asua, to live, with -n for ''I'': asun.', 'I live', 'to live (somewhere)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asun', 'asua',
      (select form_name_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun'),
      (select why_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun'),
      (select meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun'),
      (select lemma_meaning_en from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun'),
      'present tense, 1st person singular', 'Asua, to live, with -n for ''I'': asun.', 'I live', 'to live (somewhere)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sg][Nm]idän","NUMBER":"plural","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp","WORDBASES":"+te(te)"}'::jsonb,
      'teidän', 'teidän',
      'genitive plural', 'The genitive plural of te ''you all'': teidän, ''your''. People say it the same way.', 'your (plural)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-e977e6e57713');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teidän', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive plural', 'The genitive plural of te ''you all'': teidän, ''your''. People say it the same way.', 'your (plural)', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teidän', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän'),
      'genitive plural', 'The genitive plural of te ''you all'': teidän, ''your''. People say it the same way.', 'your (plural)', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alapuoli', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p', '{"BASEFORM":"alapuoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][De][Xp]ala[X]al[Sn][Ny]a[Bh][Bc][Ln][Xp]puoli[X]puole[Sade][Ny]lla[O2m]nne","NUMBER":"singular","POSSESSIVE":"2p","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppp=ppppppppppp","WORDBASES":"+ala(ala)+puoli(puoli)"}'::jsonb,
      'alapuolellanne', 'alapuolella',
      'adessive singular, with the possessive ending for your (plural)', 'Adds -lla and -nne for ''your'': alapuoli becomes alapuolellanne. Speech drops -nne: teidän alapuolella.', 'below you', 'underside, the space below', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-0e658c1258b4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alapuolellanne', 'alapuoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular, with the possessive ending for your (plural)', 'Adds -lla and -nne for ''your'': alapuoli becomes alapuolellanne. Speech drops -nne: teidän alapuolella.', 'below you', 'underside, the space below')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alapuolellanne', 'alapuoli',
      (select form_name_en from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella'),
      (select why_en from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella'),
      (select meaning_en from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella'),
      (select lemma_meaning_en from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella'),
      'adessive singular, with the possessive ending for your (plural)', 'Adds -lla and -nne for ''your'': alapuoli becomes alapuolellanne. Speech drops -nne: teidän alapuolella.', 'below you', 'underside, the space below';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaikki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaikki[X]kaikk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kaikki(kaikki)"}'::jsonb,
      'kaikki', 'kaikki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-3b27ca0bf437');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaikki', 'kaikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaikki', 'kaikki',
      (select form_name_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select why_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      (select lemma_meaning_en from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-e18d9223b2b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvin', 'hyvin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvin', 'hyvin',
      (select form_name_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select why_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sabl][Nm]iltä","NUMBER":"plural","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppp","WORDBASES":"+te(te)"}'::jsonb,
      'teiltä', 'teilt',
      'ablative plural', 'Adds -ltä for ''from'': te becomes teiltä, ''from you all''. Speech drops the last ä: teilt.', 'from your place', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-79d234f6ac7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teiltä', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative plural', 'Adds -ltä for ''from'': te becomes teiltä, ''from you all''. Speech drops the last ä: teilt.', 'from your place', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teiltä', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt'),
      'ablative plural', 'Adds -ltä for ''from'': te becomes teiltä, ''from you all''. Speech drops the last ä: teilt.', 'from your place', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"kuulua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuulua[X]kuuluu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+kuulua(kuulua)"}'::jsonb,
      'kuuluu', 'kuuluu',
      'present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-c1fa95e41d70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuuluu', 'kuulua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuuluu', 'kuulua',
      (select form_name_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select why_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select meaning_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu'),
      'present tense, 3rd person singular', 'Kuulua, to be heard. With musiikkia the verb ends in a long vowel: kuuluu.', 'is heard, comes', 'to be heard, to belong';
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('musiikki', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"musiikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]musiikki[X]musiikk[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+musiikki(musiikki)"}'::jsonb,
      'musiikkia', 'musiikkii',
      'partitive singular', 'The partitive singular is used for some music: musiikki becomes musiikkia. Speech says musiikkii.', 'music', 'music', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-3dca2e46eb8e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'musiikkia', 'musiikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for some music: musiikki becomes musiikkia. Speech says musiikkii.', 'music', 'music')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'musiikkia', 'musiikki',
      (select form_name_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii'),
      (select why_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii'),
      (select meaning_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii'),
      (select lemma_meaning_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii'),
      'partitive singular', 'The partitive singular is used for some music: musiikki becomes musiikkia. Speech says musiikkii.', 'music', 'music';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myöhä', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"myöhä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]myöhä[X]myöh[Sill][Ny]ään","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+myöhä(myöhä)"}'::jsonb,
      'myöhään', 'myöhään',
      'illative singular', 'Myöhään means ''late'' with a time: myöhään illalla, ''late in the evening''.', 'late', 'late (in myöhässä, myöhään)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-d815a182f499');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myöhään', 'myöhä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Myöhään means ''late'' with a time: myöhään illalla, ''late in the evening''.', 'late', 'late (in myöhässä, myöhään)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myöhään', 'myöhä',
      (select form_name_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään'),
      (select why_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään'),
      (select meaning_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään'),
      (select lemma_meaning_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään'),
      'illative singular', 'Myöhään means ''late'' with a time: myöhään illalla, ''late in the evening''.', 'late', 'late (in myöhässä, myöhään)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illalla', 'illal',
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-73c5475313cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'illalla', 'ilta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'illalla', 'ilta',
      (select form_name_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select why_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      (select lemma_meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'),
      'adessive singular', 'Adds -lla for a time of day: ilta becomes illalla, the t turning to l. Speech shortens -lla to -l: illalla becomes illal.', 'in the evening', 'evening';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voi', 'CLASS=huudahdussana', '{"BASEFORM":"voi","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]voi[X]voi","STRUCTURE":"=ppp","WORDBASES":"+voi(voi)"}'::jsonb,
      'voi', 'voi',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-1477dccb7e44');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voi', 'voi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voi', 'voi',
      (select form_name_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select why_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select lemma_meaning_en from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh (a cry)', 'oh (a cry)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-91a5cf1932b7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'anteeksi', 'anteeksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'anteeksi', 'anteeksi',
      (select form_name_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select why_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select meaning_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      (select lemma_meaning_en from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks'),
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tietää', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"tietää","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'tiennyt', 'tienny',
      'past active participle, nominative singular', 'After en a past action uses this form: en tiennyt. Speech drops the last t: tienny.', 'knew (I didn''t know)', 'to know', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-93775789b174');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tiennyt', 'tietää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'After en a past action uses this form: en tiennyt. Speech drops the last t: tienny.', 'knew (I didn''t know)', 'to know')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tiennyt', 'tietää',
      (select form_name_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny'),
      (select why_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny'),
      (select meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny'),
      (select lemma_meaning_en from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny'),
      'past active participle, nominative singular', 'After en a past action uses this form: en tiennyt. Speech drops the last t: tienny.', 'knew (I didn''t know)', 'to know';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikään', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikään","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikään[X]mi[Sp][Ny]tään","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+mikään(mikään)"}'::jsonb,
      'mitään', 'mitään',
      'partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-22bc94820380');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mitään', 'mikään';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mitään', 'mikään',
      (select form_name_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select why_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select meaning_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      (select lemma_meaning_en from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään'),
      'partitive singular', 'The partitive singular of mikään ''any'': mitään. ''Ei se mitään'' means ''it''s nothing, no problem''.', 'anything (nothing)', 'nothing, anything';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menen', 'meen',
      'present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-deeed6711e56');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menen', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menen', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen'),
      'present tense, 1st person singular', 'Mennä, to go, with -n for ''I'': menen. Speech says meen.', 'I''m going', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nukkua', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"nukkua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nukkua[X]nukku[Tn3][Ny][Sill]maan","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppppp","WORDBASES":"+nukkua(nukkua)"}'::jsonb,
      'nukkumaan', 'nukkuu',
      'MA-infinitive, illative', 'After mennä ''to go'', the verb takes -maan: nukkumaan. Speech says nukkuu.', 'to sleep (going to sleep)', 'to sleep', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-b8ad662a32e1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nukkumaan', 'nukkua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'After mennä ''to go'', the verb takes -maan: nukkumaan. Speech says nukkuu.', 'to sleep (going to sleep)', 'to sleep')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nukkumaan', 'nukkua',
      (select form_name_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu'),
      (select why_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu'),
      (select meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu'),
      (select lemma_meaning_en from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu'),
      'MA-infinitive, illative', 'After mennä ''to go'', the verb takes -maan: nukkumaan. Speech says nukkuu.', 'to sleep (going to sleep)', 'to sleep';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kymmenen', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kymmenen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kymmenen[X][Sabl][Ny]kymmeneltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppppp","WORDBASES":"+kymmenen(kymmenen)"}'::jsonb,
      'kymmeneltä', 'kymmeneltä',
      'ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-ee593c3c593a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kymmeneltä', 'kymmenen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kymmeneltä', 'kymmenen',
      (select form_name_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select why_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      (select lemma_meaning_en from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'),
      'ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'selvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'clear, OK', 'clear, OK', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-cff3db5ce4e8');
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
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('laittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"laittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]laittaa[X]laita[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+laittaa(laittaa)"}'::jsonb,
      'laitan', 'laitan',
      'present tense, 1st person singular', 'Adds -n for ''I'': laittaa becomes laitan, tt turning to t.', 'I put', 'to put, to make', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-cfcfcc85e871');
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'laitan', 'laittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': laittaa becomes laitan, tt turning to t.', 'I put', 'to put, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'laitan', 'laittaa',
      (select form_name_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan'),
      (select why_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan'),
      (select meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan'),
      (select lemma_meaning_en from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan'),
      'present tense, 1st person singular', 'Adds -n for ''I'': laittaa becomes laitan, tt turning to t.', 'I put', 'to put, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('musiikki', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"musiikki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]musiikki[X]musiik[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+musiikki(musiikki)"}'::jsonb,
      'musiikin', 'musiikin',
      'genitive singular', 'As the whole thing you act on, musiikki takes -n: musiikin.', 'the music', 'music', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-0f71d4328e3b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'musiikin', 'musiikki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you act on, musiikki takes -n: musiikin.', 'the music', 'music')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'musiikin', 'musiikki',
      (select form_name_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin'),
      (select why_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin'),
      (select meaning_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin'),
      (select lemma_meaning_en from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin'),
      'genitive singular', 'As the whole thing you act on, musiikki takes -n: musiikin.', 'the music', 'music';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hiljaa', 'CLASS=seikkasana', '{"BASEFORM":"hiljaa","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hiljaa[X]hiljaa","STRUCTURE":"=pppppp","WORDBASES":"+hiljaa(hiljaa)"}'::jsonb,
      'hiljaa', 'hiljaa',
      'adverb', 'This is the dictionary form. People say it the same way.', 'quietly, quiet', 'quietly, quiet', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-fb734e2b7596');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hiljaa', 'hiljaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'quietly, quiet', 'quietly, quiet')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hiljaa', 'hiljaa',
      (select form_name_en from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa'),
      (select why_en from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa'),
      (select meaning_en from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa'),
      (select lemma_meaning_en from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'quietly, quiet', 'quietly, quiet';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paljon', 'CLASS=seikkasana', '{"BASEFORM":"paljon","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'paljon', 'paljon',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a lot, much', 'a lot, much', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-c89c8a769850');
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
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('että', 'CLASS=sidesana', '{"BASEFORM":"että","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]että[X]että","STRUCTURE":"=pppp","WORDBASES":"+että(että)"}'::jsonb,
      'että', 'et',
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-4eeca18a865d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'että', 'että';
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'että', 'että',
      (select form_name_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select why_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      (select lemma_meaning_en from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et'),
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sanoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"sanoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sanoa[X]sano[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+sanoa(sanoa)"}'::jsonb,
      'sanoit', 'sanoit',
      'past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': sanoa becomes sanoit.', 'you said', 'to say, to tell', 'approved', now(), 'content/approvals/part-2.json#music-late-at-night/form-9c4fa46b6b98');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sanoit', 'sanoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': sanoa becomes sanoit.', 'you said', 'to say, to tell')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sanoit', 'sanoa',
      (select form_name_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit'),
      (select why_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit'),
      (select meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit'),
      (select lemma_meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit'),
      'past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': sanoa becomes sanoit.', 'you said', 'to say, to tell';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä asun teidän alapuolella.',
    'Hei! Minä asun teidän alapuolellanne.', 'Hi! I live below you.',
    'music-late-at-night/1-puhe-8bdfd5106fdb.mp3', 'music-late-at-night/1-kirja-daf0d5c244d1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'asun', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun')),
    (v_line_id, 'kirja', 4, 'teidän', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän')),
    (v_line_id, 'kirja', 5, 'alapuolellanne', (select id from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'asun', (select id from public.forms where lemma = 'asua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'asun' and surface_puhe = 'asun')),
    (v_line_id, 'puhe', 4, 'teidän', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=plural' and surface_kirja = 'teidän' and surface_puhe = 'teidän')),
    (v_line_id, 'puhe', 5, 'alapuolella', (select id from public.forms where lemma = 'alapuoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular;POSSESSIVE=2p' and surface_kirja = 'alapuolellanne' and surface_puhe = 'alapuolella'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Jukka', 'Moi! Onks kaikki hyvin?',
    'Hei! Onko kaikki hyvin?', 'Hi! Is everything OK?',
    'music-late-at-night/2-puhe-da61d60f3d83.mp3', 'music-late-at-night/2-kirja-44bb149b7ad5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'kirja', 4, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'puhe', 4, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Teilt kuuluu musiikkii myöhään illal.',
    'Teiltä kuuluu musiikkia myöhään illalla.', 'There''s music from your place late in the evening.',
    'music-late-at-night/3-puhe-918058f253da.mp3', 'music-late-at-night/3-kirja-872ad645c647.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Teiltä', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt')),
    (v_line_id, 'kirja', 2, 'kuuluu', (select id from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu')),
    (v_line_id, 'kirja', 3, 'musiikkia', (select id from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii')),
    (v_line_id, 'kirja', 4, 'myöhään', (select id from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään')),
    (v_line_id, 'kirja', 5, 'illalla', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal')),
    (v_line_id, 'puhe', 1, 'Teilt', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=plural' and surface_kirja = 'teiltä' and surface_puhe = 'teilt')),
    (v_line_id, 'puhe', 2, 'kuuluu', (select id from public.forms where lemma = 'kuulua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'kuuluu' and surface_puhe = 'kuuluu')),
    (v_line_id, 'puhe', 3, 'musiikkii', (select id from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'musiikkia' and surface_puhe = 'musiikkii')),
    (v_line_id, 'puhe', 4, 'myöhään', (select id from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisatulento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhään' and surface_puhe = 'myöhään')),
    (v_line_id, 'puhe', 5, 'illal', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'illalla' and surface_puhe = 'illal'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Jukka', 'Voi anteeks! Mä en tienny.',
    'Voi anteeksi! Minä en tiennyt.', 'Oh, sorry! I didn''t know.',
    'music-late-at-night/4-puhe-d65c78769215.mp3', 'music-late-at-night/4-kirja-7ceeb6d43e96.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 2, 'anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 3, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 5, 'tiennyt', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny')),
    (v_line_id, 'puhe', 1, 'Voi', (select id from public.forms where lemma = 'voi' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 2, 'anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 3, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 5, 'tienny', (select id from public.forms where lemma = 'tietää' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'tiennyt' and surface_puhe = 'tienny'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Ei se mitään. Mä meen nukkuu kymmeneltä.',
    'Ei se mitään. Minä menen nukkumaan kymmeneltä.', 'It''s OK. I go to sleep at ten.',
    'music-late-at-night/5-puhe-b8719c473a21.mp3', 'music-late-at-night/5-kirja-e73fc2d839c6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'mitään', (select id from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään')),
    (v_line_id, 'kirja', 4, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 5, 'menen', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen')),
    (v_line_id, 'kirja', 6, 'nukkumaan', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu')),
    (v_line_id, 'kirja', 7, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'mitään', (select id from public.forms where lemma = 'mikään' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitään' and surface_puhe = 'mitään')),
    (v_line_id, 'puhe', 4, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 5, 'meen', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menen' and surface_puhe = 'meen')),
    (v_line_id, 'puhe', 6, 'nukkuu', (select id from public.forms where lemma = 'nukkua' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'nukkumaan' and surface_puhe = 'nukkuu')),
    (v_line_id, 'puhe', 7, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Jukka', 'Selvä. Mä laitan musiikin hiljaa.',
    'Selvä. Minä laitan musiikin hiljaa.', 'Of course. I''ll turn the music down.',
    'music-late-at-night/6-puhe-9775988af8b3.mp3', 'music-late-at-night/6-kirja-4786515d2088.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'laitan', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan')),
    (v_line_id, 'kirja', 4, 'musiikin', (select id from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin')),
    (v_line_id, 'kirja', 5, 'hiljaa', (select id from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa')),
    (v_line_id, 'puhe', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'selvä')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'laitan', (select id from public.forms where lemma = 'laittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'laitan' and surface_puhe = 'laitan')),
    (v_line_id, 'puhe', 4, 'musiikin', (select id from public.forms where lemma = 'musiikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'musiikin' and surface_puhe = 'musiikin')),
    (v_line_id, 'puhe', 5, 'hiljaa', (select id from public.forms where lemma = 'hiljaa' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hiljaa' and surface_puhe = 'hiljaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Kiitti paljon!',
    'Kiitos paljon!', 'Thanks a lot!',
    'music-late-at-night/7-puhe-69c939aaf7e2.mp3', 'music-late-at-night/7-kirja-7410b36c2d6c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'paljon', (select id from public.forms where lemma = 'paljon' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'paljon' and surface_puhe = 'paljon'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Jukka', 'Kiitti et sä sanoit.',
    'Kiitos, että sinä sanoit.', 'Thanks for telling me.',
    'music-late-at-night/8-puhe-4dcd4218b8d3.mp3', 'music-late-at-night/8-kirja-73ea1d2a3dae.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'että', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'sanoit', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'et', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'sanoit', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'sanoit' and surface_puhe = 'sanoit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#music-late-at-night/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-2.json#music-late-at-night/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
