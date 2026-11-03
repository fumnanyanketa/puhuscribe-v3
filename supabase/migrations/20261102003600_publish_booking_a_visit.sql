-- Publishes the dialogue booking-a-visit (unit at-the-health-centre). Made by
-- scripts/generate/pipeline.py publish from content/drafts/booking-a-visit. Do not edit by hand:
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
    where slug = 'booking-a-visit' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'booking-a-visit';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 13
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'at-the-health-centre' and position = 13 and stop_number = 13;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'at-the-health-centre';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'booking-a-visit', 1,
    'Booking a visit')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'booking-a-visit' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Booking a visit';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'booking-a-visit';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('terveysasema', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"terveysasema","CLASS":"nimisana","FSTOUTPUT":"[Lnl][Xp]terve[X]terve[Ln][Xj]ys[X]y[Sn][Ny]s[Bh][Bc][Ln][Xp]asema[X]asem[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=ppppp","WORDBASES":"+terve(terve)+ys(+ys)+asema(asema)"}'::jsonb,
      'terveysasema', 'terveysasema',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'health centre', 'health centre', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-116005bdcf17');
  end if;
  if not exists (select 1 from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'terveysasema', 'terveysasema';
  end if;
  if not exists (select 1 from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'health centre', 'health centre')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'terveysasema', 'terveysasema',
      (select form_name_en from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema'),
      (select why_en from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema'),
      (select meaning_en from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema'),
      (select lemma_meaning_en from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'health centre', 'health centre';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täällä', 'CLASS=seikkasana', '{"BASEFORM":"täällä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]täällä[X]täällä","STRUCTURE":"=pppppp","WORDBASES":"+täällä(täällä)"}'::jsonb,
      'täällä', 'täällä',
      'adverb', 'This is the dictionary form. People say it the same way.', 'here', 'here', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-5bdac2fbf3a8');
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
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitsen', 'tarviin',
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-60958fda456e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitsen', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitsen', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin'),
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lääkäri', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"lääkäri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lääkäri[X]lääkär[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppppp","WORDBASES":"+lääkäri(lääkäri)"}'::jsonb,
      'lääkärin', 'lääkärin',
      'genitive singular', 'As the thing you need, lääkäri takes -n: lääkärin.', 'a doctor', 'doctor', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-5f086cac550c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lääkärin', 'lääkäri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the thing you need, lääkäri takes -n: lääkärin.', 'a doctor', 'doctor')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lääkärin', 'lääkäri',
      (select form_name_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin'),
      (select why_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin'),
      (select meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin'),
      (select lemma_meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin'),
      'genitive singular', 'As the thing you need, lääkäri takes -n: lääkärin.', 'a doctor', 'doctor';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kurkku', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"kurkku","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kurkku[X]kurkkuu[Sill][Ny][O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppppp","WORDBASES":"+kurkku(kurkku)"}'::jsonb,
      'kurkkuuni', 'kurkkuun',
      'illative singular, with the possessive ending for my', 'Adds -un for ''into'' and -ni for ''my'': kurkku becomes kurkkuuni. Speech drops -ni: kurkkuun.', 'in my throat', 'throat, cucumber', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-c475d6e2df9b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kurkkuuni', 'kurkku';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular, with the possessive ending for my', 'Adds -un for ''into'' and -ni for ''my'': kurkku becomes kurkkuuni. Speech drops -ni: kurkkuun.', 'in my throat', 'throat, cucumber')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kurkkuuni', 'kurkku',
      (select form_name_en from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun'),
      (select why_en from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun'),
      (select meaning_en from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun'),
      (select lemma_meaning_en from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun'),
      'illative singular, with the possessive ending for my', 'Adds -un for ''into'' and -ni for ''my'': kurkku becomes kurkkuuni. Speech drops -ni: kurkkuun.', 'in my throat', 'throat, cucumber';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sattua', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sattua","CLASS":"teonsana","FSTOUTPUT":"[Lt][Irm][Xp]sattua[X]sattuu[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"MA-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+sattua(sattua)"}'::jsonb,
      'sattuu', 'sattuu',
      'present tense, 3rd person singular', 'Sattua ''to hurt'' doubles its last vowel for ''it'': sattuu. People say it the same way.', 'hurts', 'to hurt, to happen', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-815b345b2d3b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sattuu', 'sattua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sattua ''to hurt'' doubles its last vowel for ''it'': sattuu. People say it the same way.', 'hurts', 'to hurt, to happen')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sattuu', 'sattua',
      (select form_name_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu'),
      (select why_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu'),
      (select meaning_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu'),
      (select lemma_meaning_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu'),
      'present tense, 3rd person singular', 'Sattua ''to hurt'' doubles its last vowel for ''it'': sattuu. People say it the same way.', 'hurts', 'to hurt, to happen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauan', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"kauan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauan[X]kauan[Fko][Ef]ko","KYSYMYSLIITE":"true","STRUCTURE":"=ppppppp","WORDBASES":"+kauan(kauan)"}'::jsonb,
      'kauanko', 'kauanks',
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-15e58dd7ae2d');
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
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sill][Ny]iihen","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+se(se)"}'::jsonb,
      'siihen', 'siihen',
      'illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-1e38a8ecb7e5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siihen', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siihen', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen'),
      'illative singular', 'The illative singular of se ''it'': siihen, ''into it, for it''. People say it the same way.', 'for it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sattua', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"sattua","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'sattunut', 'sattunu',
      'past active participle, nominative singular', 'From sattua, to hurt. After ''on'' this form says something has gone on until now. Speech drops the t: sattunu.', 'hurt (has it hurt)', 'to hurt, to happen', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-a708d717ef7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sattunut', 'sattua';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From sattua, to hurt. After ''on'' this form says something has gone on until now. Speech drops the t: sattunu.', 'hurt (has it hurt)', 'to hurt, to happen')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sattunut', 'sattua',
      (select form_name_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu'),
      (select why_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu'),
      (select meaning_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu'),
      (select lemma_meaning_en from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu'),
      'past active participle, nominative singular', 'From sattua, to hurt. After ''on'' this form says something has gone on until now. Speech drops the t: sattunu.', 'hurt (has it hurt)', 'to hurt, to happen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kolme', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kolme","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kolme[X]kolm[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kolme(kolme)"}'::jsonb,
      'kolme', 'kolme',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'three', 'three', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-9242c81b9d91');
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
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivää', 'päivää',
      'partitive singular', 'The partitive of päivä, used in wishes like hyvää päivää.', 'day', 'day', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-09fea05a79c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'päivää', 'päivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of päivä, used in wishes like hyvää päivää.', 'day', 'day')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'päivää', 'päivä',
      (select form_name_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää'),
      (select why_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää'),
      (select meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää'),
      (select lemma_meaning_en from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää'),
      'partitive singular', 'The partitive of päivä, used in wishes like hyvää päivää.', 'day', 'day';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-938eb8c80d8d');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulla', 'mul',
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuume', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"kuume","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kuume[X]kuume[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppppp","WORDBASES":"+kuume(kuume)"}'::jsonb,
      'kuumetta', 'kuumetta',
      'partitive singular', 'The partitive singular is used for an illness you have: kuume becomes kuumetta.', 'a fever', 'fever', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-c63b6877e047');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuumetta', 'kuume';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive singular is used for an illness you have: kuume becomes kuumetta.', 'a fever', 'fever')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuumetta', 'kuume',
      (select form_name_en from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta'),
      (select why_en from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta'),
      (select meaning_en from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta'),
      (select lemma_meaning_en from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta'),
      'partitive singular', 'The partitive singular is used for an illness you have: kuume becomes kuumetta.', 'a fever', 'fever';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'onko', 'onks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinun', 'sun',
      'genitive singular', 'Sinä with -n for ''your'': sinun. Speech shortens it to sun.', 'yours', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-98e98f16f669');
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
  if not exists (select 1 from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vaikea', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vaikea","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]vaikea[X]vaike[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+vaikea(vaikea)"}'::jsonb,
      'vaikea', 'vaikee',
      'nominative singular', 'Speech turns the ea at the end into ee: vaikea becomes vaikee. Books write vaikea.', 'hard', 'hard, difficult', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-0afde5322c85');
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
  if not exists (select 1 from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niellä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"niellä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]niellä[X]niell[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+niellä(niellä)"}'::jsonb,
      'niellä', 'niellä',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swallow', 'to swallow', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-a86adf369eb7');
  end if;
  if not exists (select 1 from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'niellä', 'niellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swallow', 'to swallow')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'niellä', 'niellä',
      (select form_name_en from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä'),
      (select why_en from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä'),
      (select meaning_en from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä'),
      (select lemma_meaning_en from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to swallow', 'to swallow';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vähän', 'CLASS=seikkasana', '{"BASEFORM":"vähän","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vähän[X]vähän","STRUCTURE":"=ppppp","WORDBASES":"+vähän(vähän)"}'::jsonb,
      'vähän', 'vähän',
      'adverb', 'This is the dictionary form. People say it the same way.', 'a little, a bit', 'a little, a bit', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-008b8a3eae32');
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
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lääkäri', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lääkäri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lääkäri[X]lääkär[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp","WORDBASES":"+lääkäri(lääkäri)"}'::jsonb,
      'lääkäri', 'lääkäri',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'doctor', 'doctor', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-0e8e2443b356');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lääkäri', 'lääkäri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'doctor', 'doctor')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lääkäri', 'lääkäri',
      (select form_name_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri'),
      (select why_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri'),
      (select meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri'),
      (select lemma_meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'doctor', 'doctor';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voi', 'voi',
      'present tense, 3rd person singular', 'Voida, can. With hän or a person, the verb is voi: lääkäri voi, the doctor can.', 'can', 'can, to be able to', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-fc6219c3121b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voi', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Voida, can. With hän or a person, the verb is voi: lääkäri voi, the doctor can.', 'can', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voi', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi'),
      'present tense, 3rd person singular', 'Voida, can. With hän or a person, the verb is voi: lääkäri voi, the doctor can.', 'can', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]nähd[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'nähdä', 'nähä',
      'basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-7750a252583e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'nähdä', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'nähdä', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä'),
      'basic form (A-infinitive)', 'Speech drops the d: nähdä becomes nähä. Books write nähdä.', 'to see', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sak][Ny]ut","NUMBER":"singular","SIJAMUOTO":"kohdanto","STRUCTURE":"=ppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinut', 'sut',
      'accusative singular', 'The accusative singular of sinä: sinut, ''you'' as the one being seen. Speech says sut.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-c44ca59f3070');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sinut', 'sinä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('accusative singular', 'The accusative singular of sinä: sinut, ''you'' as the one being seen. Speech says sut.', 'you', 'you (one person)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sinut', 'sinä',
      (select form_name_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut'),
      (select why_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut'),
      (select meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut'),
      (select lemma_meaning_en from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut'),
      'accusative singular', 'The accusative singular of sinä: sinut, ''you'' as the one being seen. Speech says sut.', 'you', 'you (one person)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huomenna', 'CLASS=seikkasana', '{"BASEFORM":"huomenna","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]huomenna[X]huomenna","STRUCTURE":"=pppppppp","WORDBASES":"+huomenna(huomenna)"}'::jsonb,
      'huomenna', 'huomenna',
      'adverb', 'This is the dictionary form. People say it the same way.', 'tomorrow', 'tomorrow', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-08b72686d46b');
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
  if not exists (select 1 from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kymmenen', 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"kymmenen","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kymmenen[X][Sabl][Ny]kymmeneltä","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=pppppppppp","WORDBASES":"+kymmenen(kymmenen)"}'::jsonb,
      'kymmeneltä', 'kymmeneltä',
      'ablative singular', 'Adds -ltä for a clock time: kymmenen becomes kymmeneltä, ''at ten''.', 'at ten', 'ten', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-ee593c3c593a');
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
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#booking-a-visit/form-35b130e20e20');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Satu', 'Terveysasema, Satu täällä.',
    'Terveysasema, Satu täällä.', 'Health centre, Satu speaking.',
    'booking-a-visit/1-puhe-f97f06f170cb.mp3', 'booking-a-visit/1-kirja-7d4c5606f908.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Terveysasema', (select id from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema')),
    (v_line_id, 'kirja', 2, 'Satu', null),
    (v_line_id, 'kirja', 3, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä')),
    (v_line_id, 'puhe', 1, 'Terveysasema', (select id from public.forms where lemma = 'terveysasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'terveysasema' and surface_puhe = 'terveysasema')),
    (v_line_id, 'puhe', 2, 'Satu', null),
    (v_line_id, 'puhe', 3, 'täällä', (select id from public.forms where lemma = 'täällä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'täällä' and surface_puhe = 'täällä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Moi! Mä tarviin lääkärin. Mun kurkkuun sattuu.',
    'Hei! Minä tarvitsen lääkärin. Minun kurkkuuni sattuu.', 'Hi! I need a doctor. My throat hurts.',
    'booking-a-visit/2-puhe-c5bd29cda5e9.mp3', 'booking-a-visit/2-kirja-05a4268cde1e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tarvitsen', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'kirja', 4, 'lääkärin', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin')),
    (v_line_id, 'kirja', 5, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 6, 'kurkkuuni', (select id from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun')),
    (v_line_id, 'kirja', 7, 'sattuu', (select id from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tarviin', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'puhe', 4, 'lääkärin', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'lääkärin' and surface_puhe = 'lääkärin')),
    (v_line_id, 'puhe', 5, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 6, 'kurkkuun', (select id from public.forms where lemma = 'kurkku' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'kurkkuuni' and surface_puhe = 'kurkkuun')),
    (v_line_id, 'puhe', 7, 'sattuu', (select id from public.forms where lemma = 'sattua' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sattuu' and surface_puhe = 'sattuu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Satu', 'Kauanks siihen on sattunu?',
    'Kauanko siihen on sattunut?', 'How long has it hurt?',
    'booking-a-visit/3-puhe-ee4679d0899b.mp3', 'booking-a-visit/3-kirja-8080f228b6c0.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kauanko', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'kirja', 2, 'siihen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'sattunut', (select id from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu')),
    (v_line_id, 'puhe', 1, 'Kauanks', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'puhe', 2, 'siihen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'siihen' and surface_puhe = 'siihen')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'sattunu', (select id from public.forms where lemma = 'sattua' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'sattunut' and surface_puhe = 'sattunu'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Kolme päivää. Ja mul on kuumetta.',
    'Kolme päivää. Ja minulla on kuumetta.', 'Three days. And I have a fever.',
    'booking-a-visit/4-puhe-4b7a51030515.mp3', 'booking-a-visit/4-kirja-c0ed3ef41042.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'kirja', 2, 'päivää', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää')),
    (v_line_id, 'kirja', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 4, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 6, 'kuumetta', (select id from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta')),
    (v_line_id, 'puhe', 1, 'Kolme', (select id from public.forms where lemma = 'kolme' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kolme' and surface_puhe = 'kolme')),
    (v_line_id, 'puhe', 2, 'päivää', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää')),
    (v_line_id, 'puhe', 3, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 4, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 5, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 6, 'kuumetta', (select id from public.forms where lemma = 'kuume' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'kuumetta' and surface_puhe = 'kuumetta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Satu', 'Onks sun vaikee niellä?',
    'Onko sinun vaikea niellä?', 'Is it hard to swallow?',
    'booking-a-visit/5-puhe-512070a22a4b.mp3', 'booking-a-visit/5-kirja-d8c54c38ca22.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 2, 'sinun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'kirja', 3, 'vaikea', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee')),
    (v_line_id, 'kirja', 4, 'niellä', (select id from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä')),
    (v_line_id, 'puhe', 1, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 2, 'sun', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sinun' and surface_puhe = 'sun')),
    (v_line_id, 'puhe', 3, 'vaikee', (select id from public.forms where lemma = 'vaikea' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vaikea' and surface_puhe = 'vaikee')),
    (v_line_id, 'puhe', 4, 'niellä', (select id from public.forms where lemma = 'niellä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'niellä' and surface_puhe = 'niellä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Joo, vähän.',
    'Kyllä, vähän.', 'Yes, a little.',
    'booking-a-visit/6-puhe-bfd50d20dc58.mp3', 'booking-a-visit/6-kirja-33f82c69389d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'vähän', (select id from public.forms where lemma = 'vähän' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vähän' and surface_puhe = 'vähän'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Satu', 'Okei. Lääkäri voi nähä sut huomenna kymmeneltä.',
    'Selvä. Lääkäri voi nähdä sinut huomenna kymmeneltä.', 'OK. The doctor can see you tomorrow at ten.',
    'booking-a-visit/7-puhe-3bb8b0f96d5f.mp3', 'booking-a-visit/7-kirja-4e02f7d48337.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Lääkäri', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri')),
    (v_line_id, 'kirja', 3, 'voi', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 4, 'nähdä', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä')),
    (v_line_id, 'kirja', 5, 'sinut', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut')),
    (v_line_id, 'kirja', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'kirja', 7, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Lääkäri', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lääkäri' and surface_puhe = 'lääkäri')),
    (v_line_id, 'puhe', 3, 'voi', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 4, 'nähä', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'nähdä' and surface_puhe = 'nähä')),
    (v_line_id, 'puhe', 5, 'sut', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=kohdanto;NUMBER=singular' and surface_kirja = 'sinut' and surface_puhe = 'sut')),
    (v_line_id, 'puhe', 6, 'huomenna', (select id from public.forms where lemma = 'huomenna' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'huomenna' and surface_puhe = 'huomenna')),
    (v_line_id, 'puhe', 7, 'kymmeneltä', (select id from public.forms where lemma = 'kymmenen' and form_tag = 'CLASS=lukusana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'kymmeneltä' and surface_puhe = 'kymmeneltä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Hyvä. Kiitti!',
    'Hyvä. Kiitos!', 'Good. Thanks!',
    'booking-a-visit/8-puhe-927f61f84e01.mp3', 'booking-a-visit/8-kirja-2edf4a9876cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#booking-a-visit/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
