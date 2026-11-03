-- Publishes the dialogue homesick (unit how-you-feel). Made by
-- scripts/generate/pipeline.py publish from content/drafts/homesick. Do not edit by hand:
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
    where slug = 'homesick' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'homesick';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 24
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'how-you-feel' and position = 24 and stop_number = 24;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'how-you-feel';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'homesick', 2,
    'Homesick')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'homesick' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Homesick';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'homesick';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-4.json#homesick/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('näyttää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"näyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]näyttää[X]näytä[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+näyttää(näyttää)"}'::jsonb,
      'näytät', 'näytät',
      'present tense, 2nd person singular', 'Näyttää becomes näytä- (tt turns to t) and takes -t for ''you'': näytät.', 'you look', 'to look, to show', 'approved', now(), 'content/approvals/part-4.json#homesick/form-e7b0def56866');
  end if;
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näytät', 'näyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Näyttää becomes näytä- (tt turns to t) and takes -t for ''you'': näytät.', 'you look', 'to look, to show')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näytät', 'näyttää',
      (select form_name_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät'),
      (select why_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät'),
      (select meaning_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät'),
      (select lemma_meaning_en from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät'),
      'present tense, 2nd person singular', 'Näyttää becomes näytä- (tt turns to t) and takes -t for ''you'': näytät.', 'you look', 'to look, to show';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-4.json#homesick/form-008b8a3eae32');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vähän', 'vähän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vähän', 'vähän',
      (select form_name_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select why_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      (select lemma_meaning_en from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('surullinen', 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"surullinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ln][Xp]suru[X]suru[Ll]lli[Xj]nen[X]se[Sabl][Ny]lta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppppppp","WORDBASES":"+suru(suru)+lli+nen(+nen)"}'::jsonb,
      'surulliselta', 'surulliselta',
      'ablative singular', 'Näyttää (to look) wants -lta: surullinen becomes surulliselta, ''look sad''.', 'sad', 'sad', 'approved', now(), 'content/approvals/part-4.json#homesick/form-90741c23eea3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'surulliselta', 'surullinen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Näyttää (to look) wants -lta: surullinen becomes surulliselta, ''look sad''.', 'sad', 'sad')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'surulliselta', 'surullinen',
      (select form_name_en from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta'),
      (select why_en from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta'),
      (select meaning_en from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta'),
      (select lemma_meaning_en from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta'),
      'ablative singular', 'Näyttää (to look) wants -lta: surullinen becomes surulliselta, ''look sad''.', 'sad', 'sad';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#homesick/form-5eb112d9aace');
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
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'all, everything, everyone', 'all, everything, everyone', 'approved', now(), 'content/approvals/part-4.json#homesick/form-3b27ca0bf437');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-4.json#homesick/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-4.json#homesick/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#homesick/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koti-ikävä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"koti-ikävä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]koti[X]kot[Sn][Ny]i-[Bh][Bc][Lnl][Xp]ikävä[X]ikäv[Sn][Ny]ä[Ln]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp-=ppppp","WORDBASES":"+koti(koti)+-+ikävä(ikävä)"}'::jsonb,
      'koti-ikävä', 'koti-ikävä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'homesickness', 'homesickness', 'approved', now(), 'content/approvals/part-4.json#homesick/form-4e1b2ce64b4c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'koti-ikävä', 'koti-ikävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'homesickness', 'homesickness')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'koti-ikävä', 'koti-ikävä',
      (select form_name_en from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä'),
      (select why_en from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä'),
      (select meaning_en from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä'),
      (select lemma_meaning_en from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'homesickness', 'homesickness';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-4.json#homesick/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ymmärtää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"ymmärtää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ymmärtää[X]ymmärrä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+ymmärtää(ymmärtää)"}'::jsonb,
      'ymmärrän', 'ymmärrän',
      'present tense, 1st person singular', 'Ymmärtää changes to ymmärrä- and takes -n for ''I'': ymmärrän.', 'I understand', 'to understand', 'approved', now(), 'content/approvals/part-4.json#homesick/form-4ad1219ec6ac');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ymmärrän', 'ymmärtää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Ymmärtää changes to ymmärrä- and takes -n for ''I'': ymmärrän.', 'I understand', 'to understand')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ymmärrän', 'ymmärtää',
      (select form_name_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän'),
      (select why_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän'),
      (select meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän'),
      (select lemma_meaning_en from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän'),
      'present tense, 1st person singular', 'Ymmärtää changes to ymmärrä- and takes -n for ''I'': ymmärrän.', 'I understand', 'to understand';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-4.json#homesick/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-4.json#homesick/form-a392b28c6a8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aivan', 'aivan';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aivan', 'aivan',
      (select form_name_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select why_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      (select lemma_meaning_en from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan'),
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('normaali', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"normaali","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]normaali[X]normaal[Sp][Ny]ia","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppp","WORDBASES":"+normaali(normaali)"}'::jsonb,
      'normaalia', 'normaalii',
      'partitive singular', 'Adds -a: normaali becomes normaalia. Speech turns the a into i: normaalii.', 'normal', 'normal', 'approved', now(), 'content/approvals/part-4.json#homesick/form-a522f42b9045');
  end if;
  if not exists (select 1 from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'normaalia', 'normaali';
  end if;
  if not exists (select 1 from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -a: normaali becomes normaalia. Speech turns the a into i: normaalii.', 'normal', 'normal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'normaalia', 'normaali',
      (select form_name_en from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii'),
      (select why_en from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii'),
      (select meaning_en from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii'),
      (select lemma_meaning_en from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii'),
      'partitive singular', 'Adds -a: normaali becomes normaalia. Speech turns the a into i: normaalii.', 'normal', 'normal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-4.json#homesick/form-5bdac2fbf3a8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täällä', 'täällä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täällä', 'täällä',
      (select form_name_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select why_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      (select lemma_meaning_en from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-4.json#homesick/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pimeä', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"pimeä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]pimeä[X]pime[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+pimeä(pimeä)"}'::jsonb,
      'pimeää', 'pimeetä',
      'partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark', 'approved', now(), 'content/approvals/part-4.json#homesick/form-5be57482d9e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pimeää', 'pimeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pimeää', 'pimeä',
      (select form_name_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select why_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      (select lemma_meaning_en from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä'),
      'partitive singular', 'Adds -ä: pimeä becomes pimeää. Speech says pimeetä.', 'dark', 'dark';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-4.json#homesick/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kylmä', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kylmä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kylmä[X]kylm[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kylmä(kylmä)"}'::jsonb,
      'kylmää', 'kylmää',
      'partitive singular', 'The partitive singular matches vettä: kylmä becomes kylmää.', 'cold', 'cold', 'approved', now(), 'content/approvals/part-4.json#homesick/form-76a554020dad');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kylmää', 'kylmä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular matches vettä: kylmä becomes kylmää.', 'cold', 'cold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kylmää', 'kylmä',
      (select form_name_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'),
      (select why_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'),
      (select meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'),
      (select lemma_meaning_en from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'),
      'partitive singular', 'The partitive singular matches vettä: kylmä becomes kylmää.', 'cold', 'cold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talvi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"talvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]talvi[X]talv[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+talvi(talvi)"}'::jsonb,
      'talvi', 'talvi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter', 'approved', now(), 'content/approvals/part-4.json#homesick/form-b30448401534');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talvi', 'talvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talvi', 'talvi',
      (select form_name_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select why_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      (select lemma_meaning_en from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'winter', 'winter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikea', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vaikea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]vaikea[X]vaike[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+vaikea(vaikea)"}'::jsonb,
      'vaikea', 'vaikee',
      'nominative singular', 'Speech turns the ea at the end into ee: vaikea becomes vaikee. Books write vaikea.', 'hard', 'hard, difficult', 'approved', now(), 'content/approvals/part-4.json#homesick/form-0afde5322c85');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vaikea', 'vaikea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech turns the ea at the end into ee: vaikea becomes vaikee. Books write vaikea.', 'hard', 'hard, difficult')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vaikea', 'vaikea',
      (select form_name_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee'),
      (select why_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee'),
      (select meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee'),
      (select lemma_meaning_en from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee'),
      'nominative singular', 'Speech turns the ea at the end into ee: vaikea becomes vaikee. Books write vaikea.', 'hard', 'hard, difficult';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennäänkö', 'mennäänks',
      'present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go', 'approved', now(), 'content/approvals/part-4.json#homesick/form-eb4684110c61');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mennäänkö', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mennäänkö', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks'),
      'present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kävely', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"kävely","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]kävellä[X]kävel[Ln][Xj]y[X]y[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppppp","WORDBASES":"+kävel(kävellä)+y(+y)"}'::jsonb,
      'kävelylle', 'kävelylle',
      'allative singular', 'Adds -lle for ''to'': kävely becomes kävelylle, ''for a walk''.', 'for a walk', 'walk', 'approved', now(), 'content/approvals/part-4.json#homesick/form-297fcb4ca234');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kävelylle', 'kävely';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''to'': kävely becomes kävelylle, ''for a walk''.', 'for a walk', 'walk')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kävelylle', 'kävely',
      (select form_name_en from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle'),
      (select why_en from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle'),
      (select meaning_en from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle'),
      (select lemma_meaning_en from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle'),
      'allative singular', 'Adds -lle for ''to'': kävely becomes kävelylle, ''for a walk''.', 'for a walk', 'walk';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yksi', 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"yksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]yksi[X]y[Sine][Ny]hdessä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+yksi(yksi)"}'::jsonb,
      'yhdessä', 'yhdessä',
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one', 'approved', now(), 'content/approvals/part-4.json#homesick/form-9f03b11b2b04');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yhdessä', 'yksi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yhdessä', 'yksi',
      (select form_name_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select why_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      (select lemma_meaning_en from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'),
      'inessive singular', 'Yhdessä means ''together''. It comes from yksi ''one'', ''in one''.', 'together', 'one';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-4.json#homesick/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Te][Ap][P3][Ny][Eb]isi","MOOD":"conditional","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olisi', 'ois',
      'conditional present tense, 3rd person singular', 'The conditional adds -isi for ''would'': olla becomes olisi. Speech shortens olisi to ois.', 'would be', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#homesick/form-fc63732ba497');
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
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'nice', 'nice', 'approved', now(), 'content/approvals/part-4.json#homesick/form-483066471a02');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-4.json#homesick/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jälkeen', 'CLASS=seikkasana', '{"BASEFORM":"jälkeen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]jälkeen[X]jälkeen","STRUCTURE":"=ppppppp","WORDBASES":"+jälkeen(jälkeen)"}'::jsonb,
      'jälkeen', 'jälkeen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'after', 'after', 'approved', now(), 'content/approvals/part-4.json#homesick/form-f1b22953d896');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jälkeen', 'jälkeen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'after', 'after')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jälkeen', 'jälkeen',
      (select form_name_en from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen'),
      (select why_en from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen'),
      (select meaning_en from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen'),
      (select lemma_meaning_en from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'after', 'after';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaakao', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kaakao","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kaakao[X]kaakao[Sp][Ny]ta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+kaakao(kaakao)"}'::jsonb,
      'kaakaota', 'kaakaota',
      'partitive singular', 'Adds -ta for some cocoa: kaakao becomes kaakaota.', 'hot chocolate', 'hot chocolate, cocoa', 'approved', now(), 'content/approvals/part-4.json#homesick/form-d1e19d788e37');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kaakaota', 'kaakao';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -ta for some cocoa: kaakao becomes kaakaota.', 'hot chocolate', 'hot chocolate, cocoa')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kaakaota', 'kaakao',
      (select form_name_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota'),
      (select why_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota'),
      (select meaning_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota'),
      (select lemma_meaning_en from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota'),
      'partitive singular', 'Adds -ta for some cocoa: kaakao becomes kaakaota.', 'hot chocolate', 'hot chocolate, cocoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-4.json#homesick/form-ae1caa07874f');
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
      'adverb, with the possessive ending for my', 'Luona, at someone''s place, with -ni for ''my'': luonani. Speech says mun luona and drops -ni.', 'at my place', 'at someone''s place', 'approved', now(), 'content/approvals/part-4.json#homesick/form-4968294b3ccf');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-4.json#homesick/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olet', 'oot',
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have', 'approved', now(), 'content/approvals/part-4.json#homesick/form-160976249e4f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olet', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olet', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot'),
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-4.json#homesick/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ystävä', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ystävä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ystävä[X]ystäv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+ystävä(ystävä)"}'::jsonb,
      'ystävä', 'ystävä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'friend', 'friend', 'approved', now(), 'content/approvals/part-4.json#homesick/form-7eb938197ae7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ystävä', 'ystävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'friend', 'friend')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ystävä', 'ystävä',
      (select form_name_en from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä'),
      (select why_en from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä'),
      (select meaning_en from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä'),
      (select lemma_meaning_en from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'friend', 'friend';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Sä näytät vähän surulliselta. Onks kaikki hyvin?',
    'Sinä näytät vähän surulliselta. Onko kaikki hyvin?', 'You look a bit sad. Is everything OK?',
    'homesick/1-puhe-f0aaa56e4b29.mp3', 'homesick/1-kirja-9429b48ea646.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 2, 'näytät', (select id from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät')),
    (v_line_id, 'kirja', 3, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 4, 'surulliselta', (select id from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta')),
    (v_line_id, 'kirja', 5, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 6, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'kirja', 7, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 2, 'näytät', (select id from public.forms where lemma = 'näyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näytät' and surface_puhe = 'näytät')),
    (v_line_id, 'puhe', 3, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 4, 'surulliselta', (select id from public.forms where lemma = 'surullinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=ulkoeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'surulliselta' and surface_puhe = 'surulliselta')),
    (v_line_id, 'puhe', 5, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 6, 'kaikki', (select id from public.forms where lemma = 'kaikki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaikki' and surface_puhe = 'kaikki')),
    (v_line_id, 'puhe', 7, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Mul on koti-ikävä.',
    'Minulla on koti-ikävä.', 'I''m homesick.',
    'homesick/2-puhe-ab26d4858767.mp3', 'homesick/2-kirja-4ce2da195965.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'koti-ikävä', (select id from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä')),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'koti-ikävä', (select id from public.forms where lemma = 'koti-ikävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'koti-ikävä' and surface_puhe = 'koti-ikävä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Mä ymmärrän. Se on ihan normaalii.',
    'Minä ymmärrän. Se on aivan normaalia.', 'I understand. That''s completely normal.',
    'homesick/3-puhe-cd953d39515d.mp3', 'homesick/3-kirja-02c4219564ac.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'ymmärrän', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän')),
    (v_line_id, 'kirja', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 6, 'normaalia', (select id from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'ymmärrän', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän')),
    (v_line_id, 'puhe', 3, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 6, 'normaalii', (select id from public.forms where lemma = 'normaali' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'normaalia' and surface_puhe = 'normaalii'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Täällä on niin pimeetä ja kylmää.',
    'Täällä on niin pimeää ja kylmää.', 'It''s so dark and cold here.',
    'homesick/4-puhe-585c33a55db8.mp3', 'homesick/4-kirja-de6da6da3654.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 4, 'pimeää', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä')),
    (v_line_id, 'kirja', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 6, 'kylmää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää')),
    (v_line_id, 'puhe', 1, 'Täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 4, 'pimeetä', (select id from public.forms where lemma = 'pimeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'pimeää' and surface_puhe = 'pimeetä')),
    (v_line_id, 'puhe', 5, 'ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 6, 'kylmää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'Talvi on vaikee. Mennäänks kävelylle yhdessä?',
    'Talvi on vaikea. Mennäänkö kävelylle yhdessä?', 'Winter is hard. Shall we go for a walk together?',
    'homesick/5-puhe-2ceb88f6e328.mp3', 'homesick/5-kirja-4341c2fe42e3.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Talvi', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'vaikea', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee')),
    (v_line_id, 'kirja', 4, 'Mennäänkö', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'kirja', 5, 'kävelylle', (select id from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle')),
    (v_line_id, 'kirja', 6, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä')),
    (v_line_id, 'puhe', 1, 'Talvi', (select id from public.forms where lemma = 'talvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'talvi' and surface_puhe = 'talvi')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'vaikee', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee')),
    (v_line_id, 'puhe', 4, 'Mennäänks', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'puhe', 5, 'kävelylle', (select id from public.forms where lemma = 'kävely' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'kävelylle' and surface_puhe = 'kävelylle')),
    (v_line_id, 'puhe', 6, 'yhdessä', (select id from public.forms where lemma = 'yksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'yhdessä' and surface_puhe = 'yhdessä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, se ois kiva.',
    'Kyllä, se olisi kiva.', 'Yes, that would be nice.',
    'homesick/6-puhe-7a24ebdd6789.mp3', 'homesick/6-kirja-5b98043d6329.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'olisi', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'kirja', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'ois', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=conditional;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'olisi' and surface_puhe = 'ois')),
    (v_line_id, 'puhe', 4, 'kiva', (select id from public.forms where lemma = 'kiva' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kiva' and surface_puhe = 'kiva'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'Ja sen jälkeen kaakaota mun luona!',
    'Ja sen jälkeen kaakaota minun luonani!', 'And after that, hot chocolate at my place!',
    'homesick/7-puhe-3fa0b6e7a3b2.mp3', 'homesick/7-kirja-b9c46fb8efa5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 2, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 3, 'jälkeen', (select id from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen')),
    (v_line_id, 'kirja', 4, 'kaakaota', (select id from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota')),
    (v_line_id, 'kirja', 5, 'minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 6, 'luonani', (select id from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona')),
    (v_line_id, 'puhe', 1, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 2, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 3, 'jälkeen', (select id from public.forms where lemma = 'jälkeen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'jälkeen' and surface_puhe = 'jälkeen')),
    (v_line_id, 'puhe', 4, 'kaakaota', (select id from public.forms where lemma = 'kaakao' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kaakaota' and surface_puhe = 'kaakaota')),
    (v_line_id, 'puhe', 5, 'mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 6, 'luona', (select id from public.forms where lemma = 'luona' and form_tag = 'CLASS=seikkasana;POSSESSIVE=1s' and surface_kirja = 'luonani' and surface_puhe = 'luona'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti, Leena. Sä oot hyvä ystävä.',
    'Kiitos, Leena. Sinä olet hyvä ystävä.', 'Thanks, Leena. You''re a good friend.',
    'homesick/8-puhe-9073a365d7ee.mp3', 'homesick/8-kirja-48354741abcd.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Leena', null),
    (v_line_id, 'kirja', 3, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 5, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 6, 'ystävä', (select id from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Leena', null),
    (v_line_id, 'puhe', 3, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 5, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 6, 'ystävä', (select id from public.forms where lemma = 'ystävä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ystävä' and surface_puhe = 'ystävä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-4.json#homesick/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
