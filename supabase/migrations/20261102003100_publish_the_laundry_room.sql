-- Publishes the dialogue the-laundry-room (unit home-and-neighbours). Made by
-- scripts/generate/pipeline.py publish from content/drafts/the-laundry-room. Do not edit by hand:
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
    where slug = 'the-laundry-room' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'the-laundry-room';
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
  values (v_unit_id, 'the-laundry-room', 2,
    'The laundry room')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'the-laundry-room' and unit_id = v_unit_id and status = 'draft'
    and position = 2 and title_en = 'The laundry room';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'the-laundry-room';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-58f467b0bcb4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'missä', 'mikä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'missä', 'mikä',
      (select form_name_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select why_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      (select lemma_meaning_en from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'),
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-5bdac2fbf3a8');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pesutupa', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"pesutupa","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]pestä[X]pes[Ln][Xj]u[X]u[Sn][Ny][Bh][Bc][Ln][Xp]tupa[X]tup[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=pppp","WORDBASES":"+pes(pestä)+u(+u)+tupa(tupa)"}'::jsonb,
      'pesutupa', 'pesutupa',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'laundry room', 'laundry room', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-19f602597f22');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pesutupa', 'pesutupa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'laundry room', 'laundry room')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pesutupa', 'pesutupa',
      (select form_name_en from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa'),
      (select why_en from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa'),
      (select meaning_en from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa'),
      (select lemma_meaning_en from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'laundry room', 'laundry room';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kellari', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kellari","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kellari[X]kellari[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppppp","WORDBASES":"+kellari(kellari)"}'::jsonb,
      'kellarissa', 'kellaris',
      'inessive singular', 'Adds -ssa for ''in'': kellari becomes kellarissa. Speech shortens -ssa to -s: kellarissa becomes kellaris.', 'in the basement', 'basement, cellar', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-fe4a40637188');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kellarissa', 'kellari';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': kellari becomes kellarissa. Speech shortens -ssa to -s: kellarissa becomes kellaris.', 'in the basement', 'basement, cellar')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kellarissa', 'kellari',
      (select form_name_en from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris'),
      (select why_en from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris'),
      (select meaning_en from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris'),
      (select lemma_meaning_en from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris'),
      'inessive singular', 'Adds -ssa for ''in'': kellari becomes kellarissa. Speech shortens -ssa to -s: kellarissa becomes kellaris.', 'in the basement', 'basement, cellar';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]mene[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'mene', 'mee',
      'imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-6f4a7faac046');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mene', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mene', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee'),
      'imperative present tense, 2nd person singular', 'Mennä without its ending tells someone to go: mene. Speech says mee.', 'go', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alas', 'CLASS=seikkasana', '{"BASEFORM":"alas","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]alas[X]alas","STRUCTURE":"=pppp","WORDBASES":"+alas(alas)"}'::jsonb,
      'alas', 'alas',
      'adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-96f68b98c28a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alas', 'alas';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alas', 'alas',
      (select form_name_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select why_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select meaning_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      (select lemma_meaning_en from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'down', 'down';
  end if;
  if not exists (select 1 from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('porras', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural', '{"BASEFORM":"porras","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]porras[X]porta[Sp][Nm]ita","NUMBER":"plural","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+porras(porras)"}'::jsonb,
      'portaita', 'portaita',
      'partitive plural', 'The partitive plural of porras ''step'': portaita, ''down the stairs''. The rr turns to rt.', 'the stairs', 'stair, step', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-00057a6776ed');
  end if;
  if not exists (select 1 from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'portaita', 'porras';
  end if;
  if not exists (select 1 from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive plural', 'The partitive plural of porras ''step'': portaita, ''down the stairs''. The rr turns to rt.', 'the stairs', 'stair, step')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'portaita', 'porras',
      (select form_name_en from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita'),
      (select why_en from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita'),
      (select meaning_en from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita'),
      (select lemma_meaning_en from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita'),
      'partitive plural', 'The partitive plural of porras ''step'': portaita, ''down the stairs''. The rr turns to rt.', 'the stairs', 'stair, step';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pit[Tt][Ap][P3][Ny][Ef]ää[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitääkö', 'pitääks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-c65047e392e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitääkö', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitääkö', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Pitää, to have to, with the question ending -ko: pitääkö? Speech uses -ks: pitääks.', 'does one have to', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"varata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]varata[X]varat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+varata(varata)"}'::jsonb,
      'varata', 'varata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to book, to reserve', 'to book, to reserve', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-f1ec0ca42237');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('varauslista', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"varauslista","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]varata[X]vara[Ln][Xj]us[X]u[Sn][Ny]s[Bh][Bc][Ln][Xp]lista[X]list[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=ppppp","WORDBASES":"+vara(varata)+us(+us)+lista(lista)"}'::jsonb,
      'varauslista', 'varauslista',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'booking list', 'booking list', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-12aa58ea9f06');
  end if;
  if not exists (select 1 from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'varauslista', 'varauslista';
  end if;
  if not exists (select 1 from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'booking list', 'booking list')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'varauslista', 'varauslista',
      (select form_name_en from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista'),
      (select why_en from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista'),
      (select meaning_en from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista'),
      (select lemma_meaning_en from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'booking list', 'booking list';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ovi', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"ovi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ovi[X]ov[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+ovi(ovi)"}'::jsonb,
      'oven', 'oven',
      'genitive singular', 'The genitive singular goes before vieressä ''next to'': ovi becomes oven.', 'the door (next to the door)', 'door', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-ea9917b227c3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oven', 'ovi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular goes before vieressä ''next to'': ovi becomes oven.', 'the door (next to the door)', 'door')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oven', 'ovi',
      (select form_name_en from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven'),
      (select why_en from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven'),
      (select meaning_en from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven'),
      (select lemma_meaning_en from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven'),
      'genitive singular', 'The genitive singular goes before vieressä ''next to'': ovi becomes oven.', 'the door (next to the door)', 'door';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vieri', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"vieri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]vieri[X]viere[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppp","WORDBASES":"+vieri(vieri)"}'::jsonb,
      'vieressä', 'vieres',
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-a54598413b94');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vieressä', 'vieri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vieressä', 'vieri',
      (select form_name_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select why_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      (select lemma_meaning_en from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'),
      'inessive singular', 'Vieressä means next to and comes after its word. Speech shortens -ssä to -s: Vieressä becomes Vieres.', 'next to', 'side (in vieressä, next to)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('entä', 'CLASS=seikkasana', '{"BASEFORM":"entä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]entä[X]entä","STRUCTURE":"=pppp","WORDBASES":"+entä(entä)"}'::jsonb,
      'entä', 'entä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-99966cae578b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'entä', 'entä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'entä', 'entä',
      (select form_name_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select why_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      (select lemma_meaning_en from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'and, what about', 'and, what about';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sauna', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sauna","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+sauna(sauna)"}'::jsonb,
      'sauna', 'sauna',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-79d7845c7d34');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sauna', 'sauna',
      (select form_name_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select why_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      (select lemma_meaning_en from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'sauna', 'sauna';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('talo', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"talo","CLASS":"nimisana","FSTOUTPUT":"[Ln][Ica][Xp]talo[X]talo[Sine][Ny]ssa","NUMBER":"singular","POSSIBLE_GEOGRAPHICAL_NAME":"true","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+talo(talo)"}'::jsonb,
      'talossa', 'talos',
      'inessive singular', 'Adds -ssa for ''in'': talo becomes talossa. Speech shortens -ssa to -s: talossa becomes talos.', 'in the building', 'house, building', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-7ea1fd2e4fc3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'talossa', 'talo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''in'': talo becomes talossa. Speech shortens -ssa to -s: talossa becomes talos.', 'in the building', 'house, building')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'talossa', 'talo',
      (select form_name_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos'),
      (select why_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos'),
      (select meaning_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos'),
      (select lemma_meaning_en from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos'),
      'inessive singular', 'Adds -ssa for ''in'': talo becomes talossa. Speech shortens -ssa to -s: talossa becomes talos.', 'in the building', 'house, building';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ylin', 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative', '{"BASEFORM":"ylin","CLASS":"laatusana","COMPARISON":"superlative","FSTOUTPUT":"[Ll][Xp]ylin[X]yl[Sine][Ny][Cs]immässä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppp","WORDBASES":"+ylin(ylin)"}'::jsonb,
      'ylimmässä', 'ylimmäs',
      'superlative, inessive singular', 'The superlative ylin means ''top''; adds -ssä for ''on'': ylimmässä. Speech shortens -ssä to -s: ylimmässä becomes ylimmäs.', 'on the top', 'top, highest', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-84e1296c6d52');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ylimmässä', 'ylin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('superlative, inessive singular', 'The superlative ylin means ''top''; adds -ssä for ''on'': ylimmässä. Speech shortens -ssä to -s: ylimmässä becomes ylimmäs.', 'on the top', 'top, highest')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ylimmässä', 'ylin',
      (select form_name_en from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs'),
      (select why_en from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs'),
      (select meaning_en from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs'),
      (select lemma_meaning_en from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs'),
      'superlative, inessive singular', 'The superlative ylin means ''top''; adds -ssä for ''on'': ylimmässä. Speech shortens -ssä to -s: ylimmässä becomes ylimmäs.', 'on the top', 'top, highest';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kerros', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"kerros","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kerros[X]kerrokse[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppppppp","WORDBASES":"+kerros(kerros)"}'::jsonb,
      'kerroksessa', 'kerrokses',
      'inessive singular', 'Adds -ssa for ''on'' a floor: kerros becomes kerroksessa. Speech shortens -ssa to -s: kerroksessa becomes kerrokses.', 'on the floor', 'floor, storey', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-87b291dcab91');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kerroksessa', 'kerros';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Adds -ssa for ''on'' a floor: kerros becomes kerroksessa. Speech shortens -ssa to -s: kerroksessa becomes kerrokses.', 'on the floor', 'floor, storey')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kerroksessa', 'kerros',
      (select form_name_en from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses'),
      (select why_en from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses'),
      (select meaning_en from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses'),
      (select lemma_meaning_en from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses'),
      'inessive singular', 'Adds -ssa for ''on'' a floor: kerros becomes kerroksessa. Speech shortens -ssa to -s: kerroksessa becomes kerrokses.', 'on the floor', 'floor, storey';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ihana', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ihana","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]ihana[X]ihan[Sp][Ny]aa","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ihana(ihana)"}'::jsonb,
      'ihanaa', 'ihanaa',
      'partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-bbaeb136ed47');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ihanaa', 'ihana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ihanaa', 'ihana',
      (select form_name_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select why_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      (select lemma_meaning_en from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa'),
      'partitive singular', 'The partitive singular is used in exclamations: ihana becomes ihanaa!', 'lovely', 'lovely, wonderful';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-728ddce13587');
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
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-65809211d876');
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
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saunavuoro', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"saunavuoro","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sauna[X]saun[Sn][Ny]a[Bh][Bc][Ln][Xp]vuoro[X]vuoro[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+sauna(sauna)+vuoro(vuoro)"}'::jsonb,
      'saunavuoron', 'saunavuoron',
      'genitive singular', 'As the thing you want, saunavuoro takes -n: saunavuoron. People say it the same way.', 'a sauna slot', 'sauna slot, sauna turn', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-554507176294');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saunavuoron', 'saunavuoro';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the thing you want, saunavuoro takes -n: saunavuoron. People say it the same way.', 'a sauna slot', 'sauna slot, sauna turn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saunavuoron', 'saunavuoro',
      (select form_name_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron'),
      (select why_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron'),
      (select meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron'),
      (select lemma_meaning_en from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron'),
      'genitive singular', 'As the thing you want, saunavuoro takes -n: saunavuoron. People say it the same way.', 'a sauna slot', 'sauna slot, sauna turn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kysyä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"kysyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]kysyä[X]kysy[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+kysyä(kysyä)"}'::jsonb,
      'kysy', 'kysy',
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: kysyä becomes kysy.', 'ask', 'to ask (a question)', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-86f0b379764e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kysy', 'kysyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: kysyä becomes kysy.', 'ask', 'to ask (a question)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kysy', 'kysyä',
      (select form_name_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy'),
      (select why_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy'),
      (select meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy'),
      (select lemma_meaning_en from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy'),
      'imperative present tense, 2nd person singular', 'The imperative for one person is the verb without its ending: kysyä becomes kysy.', 'ask', 'to ask (a question)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('isännöitsijä', 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"isännöitsijä","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]isännöidä[X]isännöitsi[Ln][Xj]jä[X][Sabl][Ny]jältä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppppppppppp","WORDBASES":"+isännöitsi(isännöidä)+jä(+jä)"}'::jsonb,
      'isännöitsijältä', 'isännöitsijältä',
      'ablative singular', 'Adds -ltä for ''from'' a person: isännöitsijä becomes isännöitsijältä.', 'from the building manager', 'building manager', 'approved', now(), 'content/approvals/part-2.json#the-laundry-room/form-8e8eee84c5b2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'isännöitsijältä', 'isännöitsijä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -ltä for ''from'' a person: isännöitsijä becomes isännöitsijältä.', 'from the building manager', 'building manager')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'isännöitsijältä', 'isännöitsijä',
      (select form_name_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä'),
      (select why_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä'),
      (select meaning_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä'),
      (select lemma_meaning_en from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä'),
      'ablative singular', 'Adds -ltä for ''from'' a person: isännöitsijä becomes isännöitsijältä.', 'from the building manager', 'building manager';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi Leena! Missä täällä on pesutupa?',
    'Hei Leena! Missä täällä on pesutupa?', 'Hi Leena! Where''s the laundry room here?',
    'the-laundry-room/1-puhe-5f8a4eef5224.mp3', 'the-laundry-room/1-kirja-23e343bf0bab.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Leena', null),
    (v_line_id, 'kirja', 3, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'kirja', 4, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'pesutupa', (select id from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Leena', null),
    (v_line_id, 'puhe', 3, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 4, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'pesutupa', (select id from public.forms where lemma = 'pesutupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pesutupa' and surface_puhe = 'pesutupa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Leena', 'Kellaris. Mee alas portaita.',
    'Kellarissa. Mene alas portaita.', 'In the basement. Go down the stairs.',
    'the-laundry-room/2-puhe-ead769d17c7a.mp3', 'the-laundry-room/2-kirja-f00e3779cde1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kellarissa', (select id from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris')),
    (v_line_id, 'kirja', 2, 'Mene', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'kirja', 3, 'alas', (select id from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas')),
    (v_line_id, 'kirja', 4, 'portaita', (select id from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita')),
    (v_line_id, 'puhe', 1, 'Kellaris', (select id from public.forms where lemma = 'kellari' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kellarissa' and surface_puhe = 'kellaris')),
    (v_line_id, 'puhe', 2, 'Mee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'mene' and surface_puhe = 'mee')),
    (v_line_id, 'puhe', 3, 'alas', (select id from public.forms where lemma = 'alas' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'alas' and surface_puhe = 'alas')),
    (v_line_id, 'puhe', 4, 'portaita', (select id from public.forms where lemma = 'porras' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=plural' and surface_kirja = 'portaita' and surface_puhe = 'portaita'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Pitääks se varata?',
    'Pitääkö se varata?', 'Do you have to book it?',
    'the-laundry-room/3-puhe-88791e82c698.mp3', 'the-laundry-room/3-kirja-ac67b64dc730.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Pitääkö', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'kirja', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 3, 'varata', (select id from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata')),
    (v_line_id, 'puhe', 1, 'Pitääks', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pitääkö' and surface_puhe = 'pitääks')),
    (v_line_id, 'puhe', 2, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 3, 'varata', (select id from public.forms where lemma = 'varata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'varata' and surface_puhe = 'varata'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Leena', 'Joo. Varauslista on oven vieres.',
    'Kyllä. Varauslista on oven vieressä.', 'Yes. The booking list is next to the door.',
    'the-laundry-room/4-puhe-45a2ec692488.mp3', 'the-laundry-room/4-kirja-16b72c9bc5a1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'Varauslista', (select id from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'oven', (select id from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven')),
    (v_line_id, 'kirja', 5, 'vieressä', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'Varauslista', (select id from public.forms where lemma = 'varauslista' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'varauslista' and surface_puhe = 'varauslista')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'oven', (select id from public.forms where lemma = 'ovi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'oven' and surface_puhe = 'oven')),
    (v_line_id, 'puhe', 5, 'vieres', (select id from public.forms where lemma = 'vieri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'vieressä' and surface_puhe = 'vieres'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Entä sauna? Onks talos sauna?',
    'Entä sauna? Onko talossa sauna?', 'And the sauna? Is there a sauna in the building?',
    'the-laundry-room/5-puhe-0c7080a2a66f.mp3', 'the-laundry-room/5-kirja-f13084fd7b78.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'kirja', 2, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna')),
    (v_line_id, 'kirja', 3, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 4, 'talossa', (select id from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos')),
    (v_line_id, 'kirja', 5, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna')),
    (v_line_id, 'puhe', 1, 'Entä', (select id from public.forms where lemma = 'entä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'entä' and surface_puhe = 'entä')),
    (v_line_id, 'puhe', 2, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna')),
    (v_line_id, 'puhe', 3, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 4, 'talos', (select id from public.forms where lemma = 'talo' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'talossa' and surface_puhe = 'talos')),
    (v_line_id, 'puhe', 5, 'sauna', (select id from public.forms where lemma = 'sauna' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sauna' and surface_puhe = 'sauna'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Leena', 'On, ylimmäs kerrokses.',
    'On, ylimmässä kerroksessa.', 'Yes, on the top floor.',
    'the-laundry-room/6-puhe-1a926989c832.mp3', 'the-laundry-room/6-kirja-6967aad42458.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'ylimmässä', (select id from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs')),
    (v_line_id, 'kirja', 3, 'kerroksessa', (select id from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'ylimmäs', (select id from public.forms where lemma = 'ylin' and form_tag = 'CLASS=laatusana;SIJAMUOTO=sisaolento;NUMBER=singular;COMPARISON=superlative' and surface_kirja = 'ylimmässä' and surface_puhe = 'ylimmäs')),
    (v_line_id, 'puhe', 3, 'kerrokses', (select id from public.forms where lemma = 'kerros' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'kerroksessa' and surface_puhe = 'kerrokses'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Ihanaa! Mä haluun saunavuoron.',
    'Ihanaa! Minä haluan saunavuoron.', 'Lovely! I want a sauna slot.',
    'the-laundry-room/7-puhe-b9fd458914e8.mp3', 'the-laundry-room/7-kirja-2a9d02ed69b0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 4, 'saunavuoron', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron')),
    (v_line_id, 'puhe', 1, 'Ihanaa', (select id from public.forms where lemma = 'ihana' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ihanaa' and surface_puhe = 'ihanaa')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 4, 'saunavuoron', (select id from public.forms where lemma = 'saunavuoro' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'saunavuoron' and surface_puhe = 'saunavuoron'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Leena', 'Kysy isännöitsijältä.',
    'Kysy isännöitsijältä.', 'Ask the building manager.',
    'the-laundry-room/8-puhe-1c2356110fc6.mp3', 'the-laundry-room/8-kirja-c62fa2e8ee18.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kysy', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy')),
    (v_line_id, 'kirja', 2, 'isännöitsijältä', (select id from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä')),
    (v_line_id, 'puhe', 1, 'Kysy', (select id from public.forms where lemma = 'kysyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'kysy' and surface_puhe = 'kysy')),
    (v_line_id, 'puhe', 2, 'isännöitsijältä', (select id from public.forms where lemma = 'isännöitsijä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'isännöitsijältä' and surface_puhe = 'isännöitsijältä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#the-laundry-room/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
