-- Publishes the dialogue a-sick-note-for-work (unit at-the-health-centre). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-sick-note-for-work. Do not edit by hand:
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
    where slug = 'a-sick-note-for-work' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-sick-note-for-work';
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
  values (v_unit_id, 'a-sick-note-for-work', 3,
    'A sick note for work')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-sick-note-for-work' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'A sick note for work';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-sick-note-for-work';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-728ddce13587');
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
      'present tense, 1st person singular', 'Adds -n for ''I'': tarvita becomes tarvitsen. Speech says tarviin.', 'I need', 'to need', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-60958fda456e');
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
  if not exists (select 1 from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sairauslomatodistus', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"sairauslomatodistus","CLASS":"nimisana","FSTOUTPUT":"[Lnl][Xp]sairas[X]saira[Ln][Xj]us[X]u[Sn][Ny]s[Bh][Bc][Ln][Xp]loma[X]lom[Sn][Ny]a[Bh][Bc][Lt][Xp]todistaa[X]todist[Ln][Xj]us[X]u[Sg][Ny]ksen","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppp=pppp=ppppppppppp","WORDBASES":"+saira(sairas)+us(+us)+loma(loma)+todist(todistaa)+us(+us)"}'::jsonb,
      'sairauslomatodistuksen', 'sairauslomatodistuksen',
      'genitive singular', 'As the thing you need, sairauslomatodistus takes -n: sairauslomatodistuksen.', 'a sick note', 'sick note', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-087e31730670');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sairauslomatodistuksen', 'sairauslomatodistus';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the thing you need, sairauslomatodistus takes -n: sairauslomatodistuksen.', 'a sick note', 'sick note')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sairauslomatodistuksen', 'sairauslomatodistus',
      (select form_name_en from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen'),
      (select why_en from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen'),
      (select meaning_en from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen'),
      (select lemma_meaning_en from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen'),
      'genitive singular', 'As the thing you need, sairauslomatodistus takes -n: sairauslomatodistuksen.', 'a sick note', 'sick note';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('työ', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural', '{"BASEFORM":"työ","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]työ[X]tö[Sill][Nm]ihin","NUMBER":"plural","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+työ(työ)"}'::jsonb,
      'töihin', 'töihin',
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-74a674b54acd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'töihin', 'työ';
  end if;
  if not exists (select 1 from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'töihin', 'työ',
      (select form_name_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select why_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      (select lemma_meaning_en from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'),
      'illative plural', 'The illative plural of työ: töihin, ''to work, for work''. People say it the same way.', 'for work', 'work, job';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-1df5ffb944a0');
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
  if not exists (select 1 from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kauan', 'CLASS=seikkasana;KYSYMYSLIITE=true', '{"BASEFORM":"kauan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kauan[X]kauan[Fko][Ef]ko","KYSYMYSLIITE":"true","STRUCTURE":"=ppppppp","WORDBASES":"+kauan(kauan)"}'::jsonb,
      'kauanko', 'kauanks',
      'adverb, with the question ending -ko/-kö', 'Kauan, long, with -ko to ask. Speech says -ks: kauanks.', 'how long', 'long (time)', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-15e58dd7ae2d');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olet', 'oot',
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-160976249e4f');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active', '{"BASEFORM":"olla","CLASS":"laatusana","COMPARISON":"positive","MANUAL":"true","NUMBER":"singular","PARTICIPLE":"past_active","SIJAMUOTO":"nimento"}'::jsonb,
      'ollut', 'ollu',
      'past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-bd1b245c90d3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ollut', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ollut', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu'),
      'past active participle, nominative singular', 'From olla, to be. After ''olet'' this form says ''have been''. Speech drops the last t: ollu.', 'been', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kipeä', 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"kipeä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]kipeä[X]kipe[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kipeä(kipeä)"}'::jsonb,
      'kipeä', 'kipee',
      'nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-91025202689d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kipeä', 'kipeä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kipeä', 'kipeä',
      (select form_name_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select why_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select meaning_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      (select lemma_meaning_en from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'),
      'nominative singular', 'Speech turns -eä into -ee: kipeä becomes kipee.', 'ill', 'ill, sore';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('maanantai', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"maanantai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]maanantai[X]maanantai[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppppppppp","WORDBASES":"+maanantai(maanantai)"}'::jsonb,
      'maanantaista', 'maanantaist',
      'elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-7ac76f715442');
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'maanantaista', 'maanantai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'maanantaista', 'maanantai',
      (select form_name_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select why_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select meaning_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      (select lemma_meaning_en from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist'),
      'elative singular', 'Maanantai with -sta for ''from'': maanantaista. Speech drops the last vowel: maanantaist.', 'since Monday (from Monday)', 'Monday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asti', 'CLASS=suhdesana', '{"BASEFORM":"asti","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]asti[X]asti","STRUCTURE":"=pppp","WORDBASES":"+asti(asti)"}'::jsonb,
      'asti', 'asti',
      'adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-58ae00563058');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asti', 'asti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asti', 'asti',
      (select form_name_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select why_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select meaning_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      (select lemma_meaning_en from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'),
      'adposition', 'This is the dictionary form. People say it the same way.', 'until, as far as', 'until, as far as';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käv[Tt][Ai][P2][Ny][Ef]it[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppp","TENSE":"past_imperfective","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'kävitkö', 'kävit',
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -kö to ask: kävitkö. Speech drops -kö: kävit sä.', 'did you go (visit)?', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-13f7221d4c34');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kävitkö', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -kö to ask: kävitkö. Speech drops -kö: kävit sä.', 'did you go (visit)?', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kävitkö', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit'),
      'past tense, 2nd person singular, with the question ending -ko/-kö', 'Adds -i for the past, -t for ''you'' and -kö to ask: kävitkö. Speech drops -kö: kävit sä.', 'did you go (visit)?', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lääkäri', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"lääkäri","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lääkäri[X]lääkäri[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+lääkäri(lääkäri)"}'::jsonb,
      'lääkärillä', 'lääkärillä',
      'adessive singular', 'Adds -llä for ''at'': lääkäri becomes lääkärillä.', 'at the doctor''s', 'doctor', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-3314120b1dc9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lääkärillä', 'lääkäri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for ''at'': lääkäri becomes lääkärillä.', 'at the doctor''s', 'doctor')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lääkärillä', 'lääkäri',
      (select form_name_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä'),
      (select why_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä'),
      (select meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä'),
      (select lemma_meaning_en from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä'),
      'adessive singular', 'Adds -llä for ''at'': lääkäri becomes lääkärillä.', 'at the doctor''s', 'doctor';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eilen', 'CLASS=seikkasana', '{"BASEFORM":"eilen","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eilen[X]eilen","STRUCTURE":"=ppppp","WORDBASES":"+eilen(eilen)"}'::jsonb,
      'eilen', 'eilen',
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-937949f7d75d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eilen', 'eilen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eilen', 'eilen',
      (select form_name_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select why_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      (select lemma_meaning_en from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'yesterday', 'yesterday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulostaa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tulostaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulostaa[X]tulosta[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+tulostaa(tulostaa)"}'::jsonb,
      'tulostan', 'tulostan',
      'present tense, 1st person singular', 'Adds -n for ''I'': tulostaa becomes tulostan.', 'I print', 'to print', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-d6640a3f4788');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulostan', 'tulostaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': tulostaa becomes tulostan.', 'I print', 'to print')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulostan', 'tulostaa',
      (select form_name_en from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan'),
      (select why_en from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan'),
      (select meaning_en from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan'),
      (select lemma_meaning_en from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan'),
      'present tense, 1st person singular', 'Adds -n for ''I'': tulostaa becomes tulostan.', 'I print', 'to print';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sall][Ny]ulle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulle', 'sulle',
      'allative singular', 'Sinä with -lle for ''to, for''. Speech shortens it to sulle.', 'for you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-026c280fc0ae');
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
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hetki', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hetki","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]hetki[X]hetk[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+hetki(hetki)"}'::jsonb,
      'hetki', 'hetki',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-42dbfb913e77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hetki', 'hetki';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hetki', 'hetki',
      (select form_name_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select why_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select meaning_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      (select lemma_meaning_en from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'moment', 'moment';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vain', 'CLASS=seikkasana', '{"BASEFORM":"vain","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]vain[X]vain","STRUCTURE":"=pppp","WORDBASES":"+vain(vain)"}'::jsonb,
      'vain', 'vaan',
      'adverb', 'Speech says vaan. Books write vain.', 'only', 'only, just', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-ab6bb2b103e4');
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
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('saada', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"saada","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]saada[X]saa[Tt][Ap][P1][Ny][Ef]n[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+saada(saada)"}'::jsonb,
      'saanko', 'saanks',
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Saada adds -n for ''I'' and -ko to ask: saanko. Speech says saanks.', 'can I get?', 'to get, to be allowed to', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-0cb0e1e9a4d6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'saanko', 'saada';
  end if;
  if not exists (select 1 from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular, with the question ending -ko/-kö', 'Saada adds -n for ''I'' and -ko to ask: saanko. Speech says saanks.', 'can I get?', 'to get, to be allowed to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'saanko', 'saada',
      (select form_name_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks'),
      (select why_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks'),
      (select meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks'),
      (select lemma_meaning_en from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks'),
      'present tense, 1st person singular, with the question ending -ko/-kö', 'Saada adds -n for ''I'' and -ko to ask: saanko. Speech says saanks.', 'can I get?', 'to get, to be allowed to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-fe354724e29a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'myös', 'myös';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'myös', 'myös',
      (select form_name_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select why_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      (select lemma_meaning_en from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sähköposti', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"sähköposti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]sähkö[X]sähkö[Sn][Ny][Bh][Bc][Ln][Xp]posti[X]post[Sill][Ny]iin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppp=ppppppp","WORDBASES":"+sähkö(sähkö)+posti(posti)"}'::jsonb,
      'sähköpostiin', 'sähköpostiin',
      'illative singular', 'Adds -in for ''into'': sähköposti becomes sähköpostiin.', 'by email (into email)', 'email', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-f05823303c5f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sähköpostiin', 'sähköposti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Adds -in for ''into'': sähköposti becomes sähköpostiin.', 'by email (into email)', 'email')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sähköpostiin', 'sähköposti',
      (select form_name_en from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin'),
      (select why_en from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin'),
      (select meaning_en from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin'),
      (select lemma_meaning_en from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin'),
      'illative singular', 'Adds -in for ''into'': sähköposti becomes sähköpostiin.', 'by email (into email)', 'email';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('löytyä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"löytyä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]löytyä[X]löytyy[Tt][Ap][P3][Ny][Ef]","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+löytyä(löytyä)"}'::jsonb,
      'löytyy', 'löytyy',
      'present tense, 3rd person singular', 'Löytyä ''to be found'' doubles its last vowel for ''it'': löytyy.', 'can be found', 'to be found', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-84d945695359');
  end if;
  if not exists (select 1 from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'löytyy', 'löytyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Löytyä ''to be found'' doubles its last vowel for ''it'': löytyy.', 'can be found', 'to be found')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'löytyy', 'löytyä',
      (select form_name_en from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy'),
      (select why_en from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy'),
      (select meaning_en from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy'),
      (select lemma_meaning_en from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy'),
      'present tense, 3rd person singular', 'Löytyä ''to be found'' doubles its last vowel for ''it'': löytyy.', 'can be found', 'to be found';
  end if;
  if not exists (select 1 from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('omakanta', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"omakanta","CLASS":"nimisana","FSTOUTPUT":"[Lnl][Xp]oma[X]om[Sn][Ny]a[Bh][Bc][Ln][De][Xp]kanta[X]kanna[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppp=pppppppp","WORDBASES":"+oma(oma)+kanta(kanta)"}'::jsonb,
      'omakannasta', 'omakannast',
      'elative singular', 'OmaKanta with -sta for ''from'' or ''in it'': Omakannasta. The t softens to n. Speech drops the last vowel.', 'from My Kanta', 'My Kanta (Finland''s online health records)', 'approved', now(), 'content/approvals/part-3.json#a-sick-note-for-work/form-ca9cc97b1527');
  end if;
  if not exists (select 1 from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'omakannasta', 'omakanta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'OmaKanta with -sta for ''from'' or ''in it'': Omakannasta. The t softens to n. Speech drops the last vowel.', 'from My Kanta', 'My Kanta (Finland''s online health records)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'omakannasta', 'omakanta',
      (select form_name_en from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast'),
      (select why_en from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast'),
      (select meaning_en from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast'),
      (select lemma_meaning_en from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast'),
      'elative singular', 'OmaKanta with -sta for ''from'' or ''in it'': Omakannasta. The t softens to n. Speech drops the last vowel.', 'from My Kanta', 'My Kanta (Finland''s online health records)';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Moi! Mä tarviin sairauslomatodistuksen töihin.',
    'Hei! Minä tarvitsen sairauslomatodistuksen töihin.', 'Hi! I need a sick note for work.',
    'a-sick-note-for-work/1-puhe-b7a053a6d8c7.mp3', 'a-sick-note-for-work/1-kirja-6185bdf8516b.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tarvitsen', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'kirja', 4, 'sairauslomatodistuksen', (select id from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen')),
    (v_line_id, 'kirja', 5, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tarviin', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitsen' and surface_puhe = 'tarviin')),
    (v_line_id, 'puhe', 4, 'sairauslomatodistuksen', (select id from public.forms where lemma = 'sairauslomatodistus' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sairauslomatodistuksen' and surface_puhe = 'sairauslomatodistuksen')),
    (v_line_id, 'puhe', 5, 'töihin', (select id from public.forms where lemma = 'työ' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=plural' and surface_kirja = 'töihin' and surface_puhe = 'töihin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Satu', 'Okei. Kauanks sä oot ollu kipee?',
    'Selvä. Kauanko sinä olet ollut kipeä?', 'OK. How long have you been ill?',
    'a-sick-note-for-work/2-puhe-ff36083a5410.mp3', 'a-sick-note-for-work/2-kirja-bf4e8545036f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Kauanko', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 5, 'ollut', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu')),
    (v_line_id, 'kirja', 6, 'kipeä', (select id from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Kauanks', (select id from public.forms where lemma = 'kauan' and form_tag = 'CLASS=seikkasana;KYSYMYSLIITE=true' and surface_kirja = 'kauanko' and surface_puhe = 'kauanks')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 5, 'ollu', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=past_active' and surface_kirja = 'ollut' and surface_puhe = 'ollu')),
    (v_line_id, 'puhe', 6, 'kipee', (select id from public.forms where lemma = 'kipeä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'kipeä' and surface_puhe = 'kipee'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Maanantaist asti.',
    'Maanantaista asti.', 'Since Monday.',
    'a-sick-note-for-work/3-puhe-45076f0ff5dc.mp3', 'a-sick-note-for-work/3-kirja-ef1b96906306.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Maanantaista', (select id from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist')),
    (v_line_id, 'kirja', 2, 'asti', (select id from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti')),
    (v_line_id, 'puhe', 1, 'Maanantaist', (select id from public.forms where lemma = 'maanantai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'maanantaista' and surface_puhe = 'maanantaist')),
    (v_line_id, 'puhe', 2, 'asti', (select id from public.forms where lemma = 'asti' and form_tag = 'CLASS=suhdesana' and surface_kirja = 'asti' and surface_puhe = 'asti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Satu', 'Kävitsä lääkärillä?',
    'Kävitkö sinä lääkärillä?', 'Did you see a doctor?',
    'a-sick-note-for-work/4-puhe-6d3be74e160a.mp3', 'a-sick-note-for-work/4-kirja-309e463db1be.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kävitkö', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit')),
    (v_line_id, 'kirja', 2, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'lääkärillä', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä')),
    (v_line_id, 'puhe', 1, 'Kävit', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'kävitkö' and surface_puhe = 'kävit')),
    (v_line_id, 'puhe', 2, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'lääkärillä', (select id from public.forms where lemma = 'lääkäri' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lääkärillä' and surface_puhe = 'lääkärillä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Joo, eilen.',
    'Kyllä, eilen.', 'Yes, yesterday.',
    'a-sick-note-for-work/5-puhe-986f9eefc6c3.mp3', 'a-sick-note-for-work/5-kirja-4da36875f989.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'eilen', (select id from public.forms where lemma = 'eilen' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'eilen' and surface_puhe = 'eilen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Satu', 'Hyvä. Mä tulostan sen sulle. Hetki vaan.',
    'Hyvä. Minä tulostan sen sinulle. Hetki vain.', 'Good. I''ll print it for you. Just a moment.',
    'a-sick-note-for-work/6-puhe-f7f1f0d78dd7.mp3', 'a-sick-note-for-work/6-kirja-b37088bbb743.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'tulostan', (select id from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan')),
    (v_line_id, 'kirja', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 5, 'sinulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'kirja', 6, 'Hetki', (select id from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki')),
    (v_line_id, 'kirja', 7, 'vain', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'tulostan', (select id from public.forms where lemma = 'tulostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tulostan' and surface_puhe = 'tulostan')),
    (v_line_id, 'puhe', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 5, 'sulle', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'sinulle' and surface_puhe = 'sulle')),
    (v_line_id, 'puhe', 6, 'Hetki', (select id from public.forms where lemma = 'hetki' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hetki' and surface_puhe = 'hetki')),
    (v_line_id, 'puhe', 7, 'vaan', (select id from public.forms where lemma = 'vain' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'vain' and surface_puhe = 'vaan'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Kiitti. Saanks mä sen myös sähköpostiin?',
    'Kiitos. Saanko minä sen myös sähköpostiin?', 'Thanks. Can I also get it by email?',
    'a-sick-note-for-work/7-puhe-62920c61df11.mp3', 'a-sick-note-for-work/7-kirja-c6c16d10c511.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Saanko', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 5, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 6, 'sähköpostiin', (select id from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Saanks', (select id from public.forms where lemma = 'saada' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'saanko' and surface_puhe = 'saanks')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 5, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 6, 'sähköpostiin', (select id from public.forms where lemma = 'sähköposti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'sähköpostiin' and surface_puhe = 'sähköpostiin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Satu', 'Se löytyy Omakannast.',
    'Se löytyy Omakannasta.', 'You''ll find it in My Kanta.',
    'a-sick-note-for-work/8-puhe-a2a04d31df0a.mp3', 'a-sick-note-for-work/8-kirja-86c0926684aa.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'löytyy', (select id from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy')),
    (v_line_id, 'kirja', 3, 'Omakannasta', (select id from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'löytyy', (select id from public.forms where lemma = 'löytyä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'löytyy' and surface_puhe = 'löytyy')),
    (v_line_id, 'puhe', 3, 'Omakannast', (select id from public.forms where lemma = 'omakanta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'omakannasta' and surface_puhe = 'omakannast'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-3.json#a-sick-note-for-work/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
