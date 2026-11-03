-- Publishes the dialogue sauna-at-the-cottage (unit coffee-break-and-sauna). Made by
-- scripts/generate/pipeline.py publish from content/drafts/sauna-at-the-cottage. Do not edit by hand:
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
    where slug = 'sauna-at-the-cottage' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'sauna-at-the-cottage';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 25
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'coffee-break-and-sauna' and position = 25 and stop_number = 25;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'coffee-break-and-sauna';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'sauna-at-the-cottage', 3,
    'Sauna at the cottage')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'sauna-at-the-cottage' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Sauna at the cottage';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'sauna-at-the-cottage';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('heittää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"heittää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]heittää[X]heitä[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+heittää(heittää)"}'::jsonb,
      'heitänkö', 'heitänks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Heitän (I throw) with the question ending -kö: heitänkö. Speech says heitänks.', 'shall I throw', 'to throw', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-07a93f8b86b3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heitänkö', 'heittää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular, with the question ending -ko/-kö', 'Heitän (I throw) with the question ending -kö: heitänkö. Speech says heitänks.', 'shall I throw', 'to throw')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heitänkö', 'heittää',
      (select form_name_en from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks'),
      (select why_en from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks'),
      (select meaning_en from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks'),
      (select lemma_meaning_en from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks'),
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Heitän (I throw) with the question ending -kö: heitänkö. Speech says heitänks.', 'shall I throw', 'to throw';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lisä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"lisä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lisä[X]lis[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+lisä(lisä)"}'::jsonb,
      'lisää', 'lisää',
      'partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-aa8e1d0f22c9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lisää', 'lisä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lisää', 'lisä',
      (select form_name_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select why_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      (select lemma_meaning_en from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää'),
      'partitive singular', 'Lisä, extra, takes -ä here: lisää means ''more''. People say it the same way.', 'more', 'extra, addition';
  end if;
  if not exists (select 1 from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('löyly', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"löyly","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]löyly[X]löyly[Sp][Ny]ä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+löyly(löyly)"}'::jsonb,
      'löylyä', 'löylyä',
      'partitive singular', 'Adds -ä for some löyly, the steam from water on the hot stones.', 'steam', 'sauna steam', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-f57df5b4b164');
  end if;
  if not exists (select 1 from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'löylyä', 'löyly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Adds -ä for some löyly, the steam from water on the hot stones.', 'steam', 'sauna steam')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'löylyä', 'löyly',
      (select form_name_en from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä'),
      (select why_en from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä'),
      (select meaning_en from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä'),
      (select lemma_meaning_en from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä'),
      'partitive singular', 'Adds -ä for some löyly, the steam from water on the hot stones.', 'steam', 'sauna steam';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-ab6bb2b103e4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vain', 'vain';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vain', 'vain',
      (select form_name_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select why_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select meaning_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      (select lemma_meaning_en from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'),
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihana', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ihana","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]ihana[X]ihan[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+ihana(ihana)"}'::jsonb,
      'ihana', 'ihana',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-8265d7db1e21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihana', 'ihana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihana', 'ihana',
      (select form_name_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select why_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      (select lemma_meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lovely, wonderful', 'lovely, wonderful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lämpö', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lämpö","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lämpö[X]lämpö[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+lämpö(lämpö)"}'::jsonb,
      'lämpö', 'lämpö',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'heat, warmth', 'heat, warmth', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-78003ca4b4b4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lämpö', 'lämpö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'heat, warmth', 'heat, warmth')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lämpö', 'lämpö',
      (select form_name_en from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö'),
      (select why_en from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö'),
      (select meaning_en from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö'),
      (select lemma_meaning_en from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'heat, warmth', 'heat, warmth';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-00cf76bd38f0');
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
  if not exists (select 1 from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ymmärtää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"ymmärtää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ymmärtää[X]ymmärrä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+ymmärtää(ymmärtää)"}'::jsonb,
      'ymmärrän', 'ymmärrän',
      'present tense, 1st person singular', 'Ymmärtää changes to ymmärrä- and takes -n for ''I'': ymmärrän.', 'I understand', 'to understand', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-4ad1219ec6ac');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Str][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"tulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'miksi', 'miks',
      'translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-d708d830ae73');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miksi', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miksi', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks'),
      'translative singular', 'Speech drops the last i: miks. Books write miksi.', 'why', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('te', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"te","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]te[X]te[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+te(te)"}'::jsonb,
      'te', 'te',
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-2aeedafa15c7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'te', 'te';
  end if;
  if not exists (select 1 from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'te', 'te',
      (select form_name_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select why_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      (select lemma_meaning_en from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te'),
      'nominative plural', 'Te is ''you'' when you talk to more than one person. People say it the same way.', 'you (all)', 'you (more than one, or polite)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pidä[Tt][Ap][P2][Nm][Ef]tte","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pidätte', 'tykkäätte',
      'present tense, 2nd person plural', 'From pitää, to like. Books write te pidätte. Speech uses tykätä and says tykkäätte.', 'you like', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-d6ffebd948c0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pidätte', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person plural', 'From pitää, to like. Books write te pidätte. Speech uses tykätä and says tykkäätte.', 'you like', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pidätte', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte'),
      'present tense, 2nd person plural', 'From pitää, to like. Books write te pidätte. Speech uses tykätä and says tykkäätte.', 'you like', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]sauna[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'saunasta', 'saunast',
      'elative singular', 'Pitää and tykätä (to like) want -sta: sauna becomes saunasta. Speech drops the a: saunast.', 'the sauna', 'sauna', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-19ee5ad2b317');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunasta', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Pitää and tykätä (to like) want -sta: sauna becomes saunasta. Speech drops the a: saunast.', 'the sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunasta', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast'),
      'elative singular', 'Pitää and tykätä (to like) want -sta: sauna becomes saunasta. Speech drops the a: saunast.', 'the sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]menn[Tt][Ap][P4][Ef]ään[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","PERSON":"4","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mennäänkö', 'mennäänks',
      'present tense, passive, with the question ending -ko/-kö', 'Mennään, let''s go, with -kö to ask. Speech says -ks: mennäänks.', 'shall we go?', 'to go', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-eb4684110c61');
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
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pian', 'CLASS=seikkasana', '{"BASEFORM":"pian","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]pian[X]pian","STRUCTURE":"=pppp","WORDBASES":"+pian(pian)"}'::jsonb,
      'pian', 'kohta',
      'adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-ffa51b0abfb5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pian', 'pian';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pian', 'pian',
      (select form_name_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select why_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      (select lemma_meaning_en from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta'),
      'adverb', 'Speech often says kohta ''in a moment'' instead of pian.', 'soon', 'soon';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uida', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"uida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]uida[X]ui[Tn3][Ny][Sill]maan","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+uida(uida)"}'::jsonb,
      'uimaan', 'uimaan',
      'MA-infinitive, illative', 'Uida takes -maan after mennä (to go): mennä uimaan means ''to go swimming''.', 'swimming', 'to swim', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-9d9291a657b8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uimaan', 'uida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'Uida takes -maan after mennä (to go): mennä uimaan means ''to go swimming''.', 'swimming', 'to swim')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uimaan', 'uida',
      (select form_name_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan'),
      (select why_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan'),
      (select meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan'),
      (select lemma_meaning_en from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan'),
      'MA-infinitive, illative', 'Uida takes -maan after mennä (to go): mennä uimaan means ''to go swimming''.', 'swimming', 'to swim';
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('järvi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"järvi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]järvi[X]järv[Sn][Ny]i","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+järvi(järvi)"}'::jsonb,
      'järvi', 'järvi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lake', 'lake', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-e459df89a207');
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'järvi', 'järvi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'lake', 'lake')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'järvi', 'järvi',
      (select form_name_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi'),
      (select why_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi'),
      (select meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi'),
      (select lemma_meaning_en from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'lake', 'lake';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuossa', 'tos',
      'inessive singular', 'Tuo, that, with -ssa: tuossa, there. Speech says tos.', 'there', 'that', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-8e6317edf047');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","WORDBASES":"+ei(ei)"}'::jsonb,
      'eikö', 'eiks',
      'negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-471c2ec2d2cb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eikö', 'ei';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eikö', 'ei',
      (select form_name_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select why_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      (select lemma_meaning_en from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks'),
      'negative verb, 3rd person singular, with the question ending -ko/-kö', 'Ei (not) with the question ending: eikö. Speech says eiks. Eikö niin? asks ''isn''t that so?''', 'isn''t it', 'no, not';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vesi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"vesi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]vesi[X]ve[Sn][Ny]si","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+vesi(vesi)"}'::jsonb,
      'vesi', 'vesi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-2738734d9176');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vesi', 'vesi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vesi', 'vesi',
      (select form_name_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select why_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      (select lemma_meaning_en from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'water', 'water';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"olla","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'ole', 'oo',
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-0fcdf4079f8d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ole', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ole', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo'),
      'present tense, negative form', 'After ei the verb drops its ending: olla becomes ole. Speech shortens ole to oo.', 'is not, do not have', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-26f45640039d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'todella', 'todella';
  end if;
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'todella', 'todella',
      (select form_name_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select why_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select meaning_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      (select lemma_meaning_en from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi'),
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kylmä', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kylmä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kylmä[X]kylm[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+kylmä(kylmä)"}'::jsonb,
      'kylmää', 'kylmää',
      'partitive singular', 'The partitive singular matches vettä: kylmä becomes kylmää.', 'cold', 'cold', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-76a554020dad');
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
  if not exists (select 1 from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mutta', 'CLASS=sidesana', '{"BASEFORM":"mutta","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]mutta[X]mutta","STRUCTURE":"=ppppp","WORDBASES":"+mutta(mutta)"}'::jsonb,
      'mutta', 'mut',
      'conjunction', 'Speech shortens mutta to mut. Books write mutta.', 'but', 'but', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-f177cddd7c31');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('paras', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"paras","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","SIJAMUOTO":"osanto"}'::jsonb,
      'parasta', 'parasta',
      'partitive singular', 'Paras, best, ends in -ta when it means ''the best thing about it'': parasta.', 'the best (part)', 'best', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-39e3fe607348');
  end if;
  if not exists (select 1 from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'parasta', 'paras';
  end if;
  if not exists (select 1 from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Paras, best, ends in -ta when it means ''the best thing about it'': parasta.', 'the best (part)', 'best')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'parasta', 'paras',
      (select form_name_en from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta'),
      (select why_en from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta'),
      (select meaning_en from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta'),
      (select lemma_meaning_en from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta'),
      'partitive singular', 'Paras, best, ends in -ta when it means ''the best thing about it'': parasta.', 'the best (part)', 'best';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uskaltaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"uskaltaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]uskaltaa[X]uskalla[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+uskaltaa(uskaltaa)"}'::jsonb,
      'uskallan', 'uskallan',
      'present tense, 1st person singular', 'Uskaltaa changes to uskalla- and takes -n for ''I'': uskallan.', 'I dare', 'to dare', 'approved', now(), 'content/approvals/part-5.json#sauna-at-the-cottage/form-ef48a8c22ffb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uskallan', 'uskaltaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Uskaltaa changes to uskalla- and takes -n for ''I'': uskallan.', 'I dare', 'to dare')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uskallan', 'uskaltaa',
      (select form_name_en from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan'),
      (select why_en from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan'),
      (select meaning_en from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan'),
      (select lemma_meaning_en from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan'),
      'present tense, 1st person singular', 'Uskaltaa changes to uskalla- and takes -n for ''I'': uskallan.', 'I dare', 'to dare';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Leena', 'Heitänks mä lisää löylyä?',
    'Heitänkö minä lisää löylyä?', 'Shall I throw more water on the stones?',
    'sauna-at-the-cottage/1-puhe-84de7cd00e14.mp3', 'sauna-at-the-cottage/1-kirja-808ad6dcae53.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Heitänkö', (select id from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'lisää', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'kirja', 4, 'löylyä', (select id from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä')),
    (v_line_id, 'puhe', 1, 'Heitänks', (select id from public.forms where lemma = 'heittää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'heitänkö' and surface_puhe = 'heitänks')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'lisää', (select id from public.forms where lemma = 'lisä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'lisää' and surface_puhe = 'lisää')),
    (v_line_id, 'puhe', 4, 'löylyä', (select id from public.forms where lemma = 'löyly' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'löylyä' and surface_puhe = 'löylyä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Vähän vaan!',
    'Vähän vain!', 'Just a little!',
    'sauna-at-the-cottage/2-puhe-b3cc551b49c7.mp3', 'sauna-at-the-cottage/2-kirja-61f2dff87edf.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'kirja', 2, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 1, 'Vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 2, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Leena', 'Okei. Onks hyvä?',
    'Selvä. Onko hyvä?', 'OK. Is that good?',
    'sauna-at-the-cottage/3-puhe-07bf8c694309.mp3', 'sauna-at-the-cottage/3-kirja-e49f1992d946.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Joo, ihana lämpö. Nyt mä ymmärrän, miks te tykkäätte saunast.',
    'Kyllä, ihana lämpö. Nyt minä ymmärrän, miksi te pidätte saunasta.', 'Yes, lovely heat. Now I understand why you like the sauna.',
    'sauna-at-the-cottage/4-puhe-fcc7857267e5.mp3', 'sauna-at-the-cottage/4-kirja-6ca58a9894bc.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'ihana', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana')),
    (v_line_id, 'kirja', 3, 'lämpö', (select id from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö')),
    (v_line_id, 'kirja', 4, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 5, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'ymmärrän', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän')),
    (v_line_id, 'kirja', 7, 'miksi', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'kirja', 8, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'kirja', 9, 'pidätte', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte')),
    (v_line_id, 'kirja', 10, 'saunasta', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'ihana', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihana' and surface_puhe = 'ihana')),
    (v_line_id, 'puhe', 3, 'lämpö', (select id from public.forms where lemma = 'lämpö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lämpö' and surface_puhe = 'lämpö')),
    (v_line_id, 'puhe', 4, 'Nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 5, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'ymmärrän', (select id from public.forms where lemma = 'ymmärtää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'ymmärrän' and surface_puhe = 'ymmärrän')),
    (v_line_id, 'puhe', 7, 'miks', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=tulento;NUMBER=singular' and surface_kirja = 'miksi' and surface_puhe = 'miks')),
    (v_line_id, 'puhe', 8, 'te', (select id from public.forms where lemma = 'te' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'te' and surface_puhe = 'te')),
    (v_line_id, 'puhe', 9, 'tykkäätte', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'pidätte' and surface_puhe = 'tykkäätte')),
    (v_line_id, 'puhe', 10, 'saunast', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'saunasta' and surface_puhe = 'saunast'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Leena', 'Mennäänks kohta uimaan? Järvi on tos.',
    'Mennäänkö pian uimaan? Järvi on tuossa.', 'Shall we go swimming soon? The lake is right there.',
    'sauna-at-the-cottage/5-puhe-9319e0b49d84.mp3', 'sauna-at-the-cottage/5-kirja-ae88ae3d1c3f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Mennäänkö', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'kirja', 2, 'pian', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta')),
    (v_line_id, 'kirja', 3, 'uimaan', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan')),
    (v_line_id, 'kirja', 4, 'Järvi', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'tuossa', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos')),
    (v_line_id, 'puhe', 1, 'Mennäänks', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;PERSON=4;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'mennäänkö' and surface_puhe = 'mennäänks')),
    (v_line_id, 'puhe', 2, 'kohta', (select id from public.forms where lemma = 'pian' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'pian' and surface_puhe = 'kohta')),
    (v_line_id, 'puhe', 3, 'uimaan', (select id from public.forms where lemma = 'uida' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'uimaan' and surface_puhe = 'uimaan')),
    (v_line_id, 'puhe', 4, 'Järvi', (select id from public.forms where lemma = 'järvi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'järvi' and surface_puhe = 'järvi')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'tos', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Eiks vesi oo tosi kylmää?',
    'Eikö vesi ole todella kylmää?', 'Isn''t the water really cold?',
    'sauna-at-the-cottage/6-puhe-4b612a83ec0d.mp3', 'sauna-at-the-cottage/6-kirja-6f14e4bdc600.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Eikö', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks')),
    (v_line_id, 'kirja', 2, 'vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi')),
    (v_line_id, 'kirja', 3, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'kirja', 4, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 5, 'kylmää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää')),
    (v_line_id, 'puhe', 1, 'Eiks', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative;KYSYMYSLIITE=true' and surface_kirja = 'eikö' and surface_puhe = 'eiks')),
    (v_line_id, 'puhe', 2, 'vesi', (select id from public.forms where lemma = 'vesi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'vesi' and surface_puhe = 'vesi')),
    (v_line_id, 'puhe', 3, 'oo', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'ole' and surface_puhe = 'oo')),
    (v_line_id, 'puhe', 4, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 5, 'kylmää', (select id from public.forms where lemma = 'kylmä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kylmää' and surface_puhe = 'kylmää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Leena', 'On, mut se on parasta!',
    'On, mutta se on parasta!', 'It is, but that''s the best part!',
    'sauna-at-the-cottage/7-puhe-edd746cdc9e9.mp3', 'sauna-at-the-cottage/7-kirja-ed8a2e165de6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'mutta', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'parasta', (select id from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'mut', (select id from public.forms where lemma = 'mutta' and form_tag = 'CLASS=sidesana' and surface_kirja = 'mutta' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'parasta', (select id from public.forms where lemma = 'paras' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'parasta' and surface_puhe = 'parasta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Okei, mä uskallan!',
    'Selvä, minä uskallan!', 'OK, I dare!',
    'sauna-at-the-cottage/8-puhe-1580c040bc4c.mp3', 'sauna-at-the-cottage/8-kirja-3b5bf9e4a4cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'uskallan', (select id from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'uskallan', (select id from public.forms where lemma = 'uskaltaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'uskallan' and surface_puhe = 'uskallan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#sauna-at-the-cottage/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
