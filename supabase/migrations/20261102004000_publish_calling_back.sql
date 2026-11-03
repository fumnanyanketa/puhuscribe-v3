-- Publishes the dialogue calling-back (unit phone-calls-and-messages). Made by
-- scripts/generate/pipeline.py publish from content/drafts/calling-back. Do not edit by hand:
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
    where slug = 'calling-back' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'calling-back';
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
  values (v_unit_id, 'calling-back', 2,
    'Calling back')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'calling-back' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'Calling back';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'calling-back';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('soittaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"soittaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]soittaa[X]soit[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"past_imperfective","WORDBASES":"+soittaa(soittaa)"}'::jsonb,
      'soitit', 'soitit',
      'past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': soittaa becomes soitit, tt turning to t.', 'you called', 'to call, to play (music)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-e327468d1673');
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'soitit', 'soittaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': soittaa becomes soitit, tt turning to t.', 'you called', 'to call, to play (music)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'soitit', 'soittaa',
      (select form_name_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit'),
      (select why_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit'),
      (select meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit'),
      (select lemma_meaning_en from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit'),
      'past tense, 2nd person singular', 'Adds -i for the past and -t for ''you'': soittaa becomes soitit, tt turning to t.', 'you called', 'to call, to play (music)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulle', 'mulle',
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-6ba9c8c14d0e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulle', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulle', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'),
      'allative singular', 'Minä with -lle for ''for''. Speech shortens it to mulle.', 'for me', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jättää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"jättää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]jättää[X]jät[Tt][Ai][P1][Ny][Ef]in","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+jättää(jättää)"}'::jsonb,
      'jätin', 'jätin',
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': jättää becomes jätin, tt turning to t.', 'I left', 'to leave (behind)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-4ee3def25f50');
  end if;
  if not exists (select 1 from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'jätin', 'jättää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': jättää becomes jätin, tt turning to t.', 'I left', 'to leave (behind)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'jätin', 'jättää',
      (select form_name_en from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin'),
      (select why_en from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin'),
      (select meaning_en from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin'),
      (select lemma_meaning_en from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin'),
      'past tense, 1st person singular', 'Adds -i for the past and -n for ''I'': jättää becomes jätin, tt turning to t.', 'I left', 'to leave (behind)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viesti', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"viesti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viesti[X]viest[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp","WORDBASES":"+viesti(viesti)"}'::jsonb,
      'viestin', 'viestin',
      'genitive singular', 'Viesti, message. The thing you send takes -n here: viestin, a whole message.', 'a message', 'message', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-d12ce3e2c669');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viestin', 'viesti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Viesti, message. The thing you send takes -n here: viestin, a whole message.', 'a message', 'message')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viestin', 'viesti',
      (select form_name_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin'),
      (select why_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin'),
      (select meaning_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin'),
      (select lemma_meaning_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin'),
      'genitive singular', 'Viesti, message. The thing you send takes -n here: viestin, a whole message.', 'a message', 'message';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"kuulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kuulla[X]kuul[Tt][Ai][P2][Ny][Ef]it[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"past_imperfective","WORDBASES":"+kuulla(kuulla)"}'::jsonb,
      'kuulitko', 'kuulit',
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -ko to ask: kuulitko. Speech drops -ko: kuulit sä.', 'did you hear?', 'to hear', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-034c6c3925de');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuulitko', 'kuulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -ko to ask: kuulitko. Speech drops -ko: kuulit sä.', 'did you hear?', 'to hear')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuulitko', 'kuulla',
      (select form_name_en from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit'),
      (select why_en from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit'),
      (select meaning_en from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit'),
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -ko to ask: kuulitko. Speech drops -ko: kuulit sä.', 'did you hear?', 'to hear';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vielä', 'CLASS=seikkasana', '{"BASEFORM":"vielä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vielä[X]vielä","STRUCTURE":"=ppppp","WORDBASES":"+vielä(vielä)"}'::jsonb,
      'vielä', 'vielä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'still, yet', 'still, yet', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-2b3844766909');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sp][Ny]tä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mitä', 'mitä',
      'partitive singular', 'The partitive of mikä, what. Mitä saa olla? means What can I get you?', 'what', 'what, which', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-a0c867e0dc77');
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
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asia', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"asia","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asia[X]asia[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+asia(asia)"}'::jsonb,
      'asiaa', 'asiaa',
      'partitive singular', 'The partitive singular of asia ''matter'': ''Mitä asiaa?'' means ''What''s it about?''', 'what about (what''s it about)', 'thing, matter', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-97fb605d3b53');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asiaa', 'asia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular of asia ''matter'': ''Mitä asiaa?'' means ''What''s it about?''', 'what about (what''s it about)', 'thing, matter')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asiaa', 'asia',
      (select form_name_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa'),
      (select why_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa'),
      (select meaning_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa'),
      (select lemma_meaning_en from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa'),
      'partitive singular', 'The partitive singular of asia ''matter'': ''Mitä asiaa?'' means ''What''s it about?''', 'what about (what''s it about)', 'thing, matter';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voitko', 'voit',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-90c207b76ecc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voitko', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voitko', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hakea', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"hakea","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]hakea[X]hake[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+hakea(hakea)"}'::jsonb,
      'hakea', 'hakee',
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-16b20f797da9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hakea', 'hakea';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hakea', 'hakea',
      (select form_name_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select why_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      (select lemma_meaning_en from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee'),
      'basic form (A-infinitive)', 'Speech turns the ea at the end into ee: hakea becomes hakee. Books write hakea.', 'to pick up', 'to fetch, to pick up, to apply';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sak][Ny]ut","NUMBER":"singular","SIJAMUOTO":"kohdanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minut', 'mut',
      'accusative singular', 'The accusative singular of minä: minut, ''me'' as the one picked up. Speech says mut.', 'me', 'I, me', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-e47fb6613295');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minut', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('accusative singular', 'The accusative singular of minä: minut, ''me'' as the one picked up. Speech says mut.', 'me', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minut', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut'),
      'accusative singular', 'The accusative singular of minä: minut, ''me'' as the one picked up. Speech says mut.', 'me', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asema', 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"asema","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asema[X]asema[Sabl][Ny]lta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppp","WORDBASES":"+asema(asema)"}'::jsonb,
      'asemalta', 'asemalta',
      'ablative singular', 'Adds -lta for ''from'': asema becomes asemalta.', 'from the station', 'station', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-d22b687faae5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asemalta', 'asema';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -lta for ''from'': asema becomes asemalta.', 'from the station', 'station')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asemalta', 'asema',
      (select form_name_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta'),
      (select why_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta'),
      (select meaning_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta'),
      (select lemma_meaning_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta'),
      'ablative singular', 'Adds -lta for ''from'': asema becomes asemalta.', 'from the station', 'station';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huomenna', 'CLASS=seikkasana', '{"BASEFORM":"huomenna","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]huomenna[X]huomenna","STRUCTURE":"=pppppppp","WORDBASES":"+huomenna(huomenna)"}'::jsonb,
      'huomenna', 'huomenna',
      'adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-08b72686d46b');
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
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-b20bd263b5ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'totta', 'tosi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'totta', 'tosi',
      (select form_name_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select why_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      (select lemma_meaning_en from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta'),
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kai', 'CLASS=seikkasana', '{"BASEFORM":"kai","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kai[X]kai","STRUCTURE":"=ppp","WORDBASES":"+kai(kai)"}'::jsonb,
      'kai', 'kai',
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-b1285c45ffe6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kai', 'kai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kai', 'kai',
      (select form_name_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select why_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      (select lemma_meaning_en from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sill][Ny]hin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'mihin', 'mihin',
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-f42052a3d5f2');
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
      'illative singular', 'Aika with -an. Mihin aikaan? means at what time?', '(what) time', 'time', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-ea79f0748e36');
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
  if not exists (select 1 from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juna', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"juna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]juna[X]jun[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+juna(juna)"}'::jsonb,
      'juna', 'juna',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'train', 'train', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-6b88cad546b8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juna', 'juna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'train', 'train')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juna', 'juna',
      (select form_name_en from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna'),
      (select why_en from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna'),
      (select meaning_en from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna'),
      (select lemma_meaning_en from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'train', 'train';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ap][P3][Ny][Ef]ee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulee', 'tulee',
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-390b2cd693bb');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulee', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulee', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'),
      'present tense, 3rd person singular', 'Tulla, to come, in the form for he, she or it: tulee.', 'comes', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('puoli', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"puoli","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]puoli[X]puol[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+puoli(puoli)"}'::jsonb,
      'puoli', 'puol',
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-31b91a2acd2d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'puoli', 'puoli';
  end if;
  if not exists (select 1 from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'puoli', 'puoli',
      (select form_name_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select why_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      (select lemma_meaning_en from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol'),
      'nominative singular', 'Puoli neljä means ''half to four'', so 3.30. Speech drops the last i: puol.', 'half (half past)', 'half, side';
  end if;
  if not exists (select 1 from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('neljä', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"neljä","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]neljä[X]nelj[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+neljä(neljä)"}'::jsonb,
      'neljä', 'neljä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'four', 'four', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-f2a0946c62d5');
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
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-7588912c8134');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olen', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olen', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon'),
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('siellä', 'CLASS=seikkasana', '{"BASEFORM":"siellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]siellä[X]siellä","STRUCTURE":"=pppppp","WORDBASES":"+siellä(siellä)"}'::jsonb,
      'siellä', 'siel',
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-0fd3b38079dc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siellä', 'siellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siellä', 'siellä',
      (select form_name_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select why_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      (select lemma_meaning_en from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel'),
      'adverb', 'Siellä means there. Speech shortens -llä to -l: Siellä becomes Siel.', 'there', 'there';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähettää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"lähettää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähettää[X]lähetä[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+lähettää(lähettää)"}'::jsonb,
      'lähetä', 'laita',
      'imperative present tense, 2nd person singular', 'Lähettää, to send. To tell one person to do it, drop the ending: lähetä. Speech often says laita, ''put'', instead.', 'send', 'to send', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-0841fc01e2a3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähetä', 'lähettää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Lähettää, to send. To tell one person to do it, drop the ending: lähetä. Speech often says laita, ''put'', instead.', 'send', 'to send')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähetä', 'lähettää',
      (select form_name_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita'),
      (select why_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita'),
      (select meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita'),
      (select lemma_meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita'),
      'imperative present tense, 2nd person singular', 'Lähettää, to send. To tell one person to do it, drop the ending: lähetä. Speech often says laita, ''put'', instead.', 'send', 'to send';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viesti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"viesti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viesti[X]viest[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+viesti(viesti)"}'::jsonb,
      'viesti', 'viesti',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'message', 'message', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-201c6c28c428');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viesti', 'viesti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'message', 'message')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viesti', 'viesti',
      (select form_name_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti'),
      (select why_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti'),
      (select meaning_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti'),
      (select lemma_meaning_en from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'message', 'message';
  end if;
  if not exists (select 1 from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('jos', 'CLASS=sidesana', '{"BASEFORM":"jos","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]jos[X]jos","STRUCTURE":"=ppp","WORDBASES":"+jos(jos)"}'::jsonb,
      'jos', 'jos',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'if', 'if', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-546867beb98e');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myöhä', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"myöhä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]myöhä[X]myöhä[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+myöhä(myöhä)"}'::jsonb,
      'myöhässä', 'myöhäs',
      'inessive singular', 'Myöhässä means ''late, behind time''. Speech shortens -ssä to -s: Myöhässä becomes Myöhäs.', 'late', 'late (in myöhässä, myöhään)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-3777b263067c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myöhässä', 'myöhä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Myöhässä means ''late, behind time''. Speech shortens -ssä to -s: Myöhässä becomes Myöhäs.', 'late', 'late (in myöhässä, myöhään)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myöhässä', 'myöhä',
      (select form_name_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs'),
      (select why_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs'),
      (select meaning_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs'),
      (select lemma_meaning_en from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs'),
      'inessive singular', 'Myöhässä means ''late, behind time''. Speech shortens -ssä to -s: Myöhässä becomes Myöhäs.', 'late', 'late (in myöhässä, myöhään)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tee[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teen', 'teen',
      'present tense, 1st person singular', 'Tehdä ''to do'' becomes tee- and adds -n for ''I'': teen. People say it the same way.', 'I do (I will)', 'to do, to make', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-e78ed6ff1345');
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
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuulemiin', 'CLASS=huudahdussana', '{"BASEFORM":"kuulemiin","CLASS":"huudahdussana","MANUAL":"true"}'::jsonb,
      'kuulemiin', 'moikka',
      'interjection', 'Kuulemiin is the polite goodbye on the phone. In everyday speech people say moikka instead.', 'goodbye (on the phone)', 'goodbye (on the phone)', 'approved', now(), 'content/approvals/part-3.json#calling-back/form-17978cc3e1f1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuulemiin', 'kuulemiin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'Kuulemiin is the polite goodbye on the phone. In everyday speech people say moikka instead.', 'goodbye (on the phone)', 'goodbye (on the phone)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuulemiin', 'kuulemiin',
      (select form_name_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka'),
      (select why_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka'),
      (select meaning_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka'),
      (select lemma_meaning_en from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka'),
      'interjection', 'Kuulemiin is the polite goodbye on the phone. In everyday speech people say moikka instead.', 'goodbye (on the phone)', 'goodbye (on the phone)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Aino', 'Moi Maria! Sä soitit mulle.',
    'Hei Maria! Sinä soitit minulle.', 'Hi Maria! You called me.',
    'calling-back/1-puhe-d4d98279abe5.mp3', 'calling-back/1-kirja-5ec1b82022ef.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Maria', null),
    (v_line_id, 'kirja', 3, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'soitit', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit')),
    (v_line_id, 'kirja', 5, 'minulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Maria', null),
    (v_line_id, 'puhe', 3, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'soitit', (select id from public.forms where lemma = 'soittaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'soitit' and surface_puhe = 'soitit')),
    (v_line_id, 'puhe', 5, 'mulle', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'minulle' and surface_puhe = 'mulle'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Joo! Mä jätin viestin. Kuulitsä sen?',
    'Kyllä! Minä jätin viestin. Kuulitko sinä sen?', 'Yes! I left a message. Did you hear it?',
    'calling-back/2-puhe-6f49b7930c96.mp3', 'calling-back/2-kirja-55441853b7b4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'jätin', (select id from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin')),
    (v_line_id, 'kirja', 4, 'viestin', (select id from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin')),
    (v_line_id, 'kirja', 5, 'Kuulitko', (select id from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 7, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'jätin', (select id from public.forms where lemma = 'jättää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'jätin' and surface_puhe = 'jätin')),
    (v_line_id, 'puhe', 4, 'viestin', (select id from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'viestin' and surface_puhe = 'viestin')),
    (v_line_id, 'puhe', 5, 'Kuulit', (select id from public.forms where lemma = 'kuulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kuulitko' and surface_puhe = 'kuulit')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 7, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Aino', 'En vielä. Mitä asiaa?',
    'En vielä. Mitä asiaa?', 'Not yet. What''s it about?',
    'calling-back/3-puhe-33ab91a808c4.mp3', 'calling-back/3-kirja-34b89f3b4c48.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 2, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'kirja', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'kirja', 4, 'asiaa', (select id from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa')),
    (v_line_id, 'puhe', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 2, 'vielä', (select id from public.forms where lemma = 'vielä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vielä' and surface_puhe = 'vielä')),
    (v_line_id, 'puhe', 3, 'Mitä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'mitä' and surface_puhe = 'mitä')),
    (v_line_id, 'puhe', 4, 'asiaa', (select id from public.forms where lemma = 'asia' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'asiaa' and surface_puhe = 'asiaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Voitsä hakee mut asemalta huomenna?',
    'Voitko sinä hakea minut asemalta huomenna?', 'Can you pick me up from the station tomorrow?',
    'calling-back/4-puhe-73e596809dc7.mp3', 'calling-back/4-kirja-2dc9eb220eeb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Voitko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'hakea', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee')),
    (v_line_id, 'kirja', 4, 'minut', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut')),
    (v_line_id, 'kirja', 5, 'asemalta', (select id from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta')),
    (v_line_id, 'kirja', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'puhe', 1, 'Voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'hakee', (select id from public.forms where lemma = 'hakea' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'hakea' and surface_puhe = 'hakee')),
    (v_line_id, 'puhe', 4, 'mut', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'minut' and surface_puhe = 'mut')),
    (v_line_id, 'puhe', 5, 'asemalta', (select id from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'asemalta' and surface_puhe = 'asemalta')),
    (v_line_id, 'puhe', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Aino', 'Totta kai. Mihin aikaan juna tulee?',
    'Totta kai. Mihin aikaan juna tulee?', 'Of course. What time does the train arrive?',
    'calling-back/5-puhe-59ab92be7127.mp3', 'calling-back/5-kirja-c1e4b5c00087.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 4, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'kirja', 5, 'juna', (select id from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna')),
    (v_line_id, 'kirja', 6, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 4, 'aikaan', (select id from public.forms where lemma = 'aika' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'aikaan' and surface_puhe = 'aikaan')),
    (v_line_id, 'puhe', 5, 'juna', (select id from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna')),
    (v_line_id, 'puhe', 6, 'tulee', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulee' and surface_puhe = 'tulee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Puol neljä.',
    'Puoli neljä.', 'Half past three.',
    'calling-back/6-puhe-abb289647c6d.mp3', 'calling-back/6-kirja-cf0a7cfb22ca.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Puoli', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'kirja', 2, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä')),
    (v_line_id, 'puhe', 1, 'Puol', (select id from public.forms where lemma = 'puoli' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'puoli' and surface_puhe = 'puol')),
    (v_line_id, 'puhe', 2, 'neljä', (select id from public.forms where lemma = 'neljä' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'neljä' and surface_puhe = 'neljä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Aino', 'Okei, mä oon siel. Laita viesti, jos juna on myöhäs.',
    'Selvä, minä olen siellä. Lähetä viesti, jos juna on myöhässä.', 'OK, I''ll be there. Send a message if the train is late.',
    'calling-back/7-puhe-ead5c5a9fd38.mp3', 'calling-back/7-kirja-f18899ed1dff.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 4, 'siellä', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'kirja', 5, 'Lähetä', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita')),
    (v_line_id, 'kirja', 6, 'viesti', (select id from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti')),
    (v_line_id, 'kirja', 7, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'kirja', 8, 'juna', (select id from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna')),
    (v_line_id, 'kirja', 9, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 10, 'myöhässä', (select id from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 4, 'siel', (select id from public.forms where lemma = 'siellä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'siellä' and surface_puhe = 'siel')),
    (v_line_id, 'puhe', 5, 'Laita', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'lähetä' and surface_puhe = 'laita')),
    (v_line_id, 'puhe', 6, 'viesti', (select id from public.forms where lemma = 'viesti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'viesti' and surface_puhe = 'viesti')),
    (v_line_id, 'puhe', 7, 'jos', (select id from public.forms where lemma = 'jos' and form_tag = 'CLASS=sidesana' and surface_kirja = 'jos' and surface_puhe = 'jos')),
    (v_line_id, 'puhe', 8, 'juna', (select id from public.forms where lemma = 'juna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'juna' and surface_puhe = 'juna')),
    (v_line_id, 'puhe', 9, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 10, 'myöhäs', (select id from public.forms where lemma = 'myöhä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'myöhässä' and surface_puhe = 'myöhäs'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Mä teen niin. Moikka!',
    'Minä teen niin. Kuulemiin!', 'I will. Bye!',
    'calling-back/8-puhe-42f2f5916f89.mp3', 'calling-back/8-kirja-2c3315825437.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'kirja', 3, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 4, 'Kuulemiin', (select id from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'teen', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'teen' and surface_puhe = 'teen')),
    (v_line_id, 'puhe', 3, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 4, 'Moikka', (select id from public.forms where lemma = 'kuulemiin' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'kuulemiin' and surface_puhe = 'moikka'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#calling-back/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
