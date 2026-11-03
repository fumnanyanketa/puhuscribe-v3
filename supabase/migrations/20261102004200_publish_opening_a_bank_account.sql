-- Publishes the dialogue opening-a-bank-account (unit the-bank-and-kela). Made by
-- scripts/generate/pipeline.py publish from content/drafts/opening-a-bank-account. Do not edit by hand:
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
    where slug = 'opening-a-bank-account' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'opening-a-bank-account';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 15
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'the-bank-and-kela' and position = 15 and stop_number = 15;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'the-bank-and-kela';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'opening-a-bank-account', 1,
    'Opening a bank account')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'opening-a-bank-account' and unit_id = v_unit_id and status = 'draft'
    and position = 1 and title_en = 'Opening a bank account';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'opening-a-bank-account';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('seuraava', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active', '{"BASEFORM":"seuraava","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lt][Xp]seurata[X]seuraa[Ll][Rv]v[Xj]a[X][Sn][Ny]a","NUMBER":"singular","PARTICIPLE":"present_active","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp","WORDBASES":"+seuraa(seurata)+v+a(+a)"}'::jsonb,
      'seuraava', 'seuraava',
      'present active participle, nominative singular', 'Seuraava means next. It comes from seurata, to follow.', 'next', 'next', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-fe0b22931062');
  end if;
  if not exists (select 1 from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'seuraava', 'seuraava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present active participle, nominative singular', 'Seuraava means next. It comes from seurata, to follow.', 'next', 'next')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'seuraava', 'seuraava',
      (select form_name_en from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava'),
      (select why_en from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava'),
      (select meaning_en from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava'),
      (select lemma_meaning_en from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava'),
      'present active participle, nominative singular', 'Seuraava means next. It comes from seurata, to follow.', 'next', 'next';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]ol[Tk][Ap][P2][Nm][Ef]kaa","MOOD":"imperative","NEGATIVE":"false","NUMBER":"plural","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olkaa', 'ole',
      'imperative present tense, 2nd person plural', 'Olla with -kaa tells several people or a stranger politely: olkaa hyvä. Speech uses ole hyvä.', 'please (be so good)', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-57fb541697c2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'olkaa', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person plural', 'Olla with -kaa tells several people or a stranger politely: olkaa hyvä. Speech uses ole hyvä.', 'please (be so good)', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'olkaa', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole'),
      'imperative present tense, 2nd person plural', 'Olla with -kaa tells several people or a stranger politely: olkaa hyvä. Speech uses ole hyvä.', 'please (be so good)', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-124d5d19fe78');
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
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-728ddce13587');
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
      'present tense, 1st person singular', 'Haluta with -n for ''I'': haluan. Speech says haluun.', 'I want', 'to want', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-65809211d876');
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
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('avata', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"avata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]avata[X]avat[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+avata(avata)"}'::jsonb,
      'avata', 'avata',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to open', 'to open', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-bd89827ae7d0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'avata', 'avata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to open', 'to open')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'avata', 'avata',
      (select form_name_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata'),
      (select why_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata'),
      (select meaning_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata'),
      (select lemma_meaning_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to open', 'to open';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pankkitili', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"pankkitili","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]pankki[X]pankk[Sn][Ny]i[Bh][Bc][Ln][Xp]tili[X]til[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp=ppppp","WORDBASES":"+pankki(pankki)+tili(tili)"}'::jsonb,
      'pankkitilin', 'pankkitilin',
      'genitive singular', 'As the thing you open, pankkitili takes -n: pankkitilin.', 'a bank account', 'bank account', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-4505915de476');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pankkitilin', 'pankkitili';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the thing you open, pankkitili takes -n: pankkitilin.', 'a bank account', 'bank account')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pankkitilin', 'pankkitili',
      (select form_name_en from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin'),
      (select why_en from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin'),
      (select meaning_en from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin'),
      (select lemma_meaning_en from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin'),
      'genitive singular', 'As the thing you open, pankkitili takes -n: pankkitilin.', 'a bank account', 'bank account';
  end if;
  if not exists (select 1 from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('selvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"selvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]selvä[X]selv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+selvä(selvä)"}'::jsonb,
      'selvä', 'okei',
      'nominative singular', 'Okei is the everyday spoken OK. Books write selvä, which means clear.', 'OK', 'clear, OK', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-1df5ffb944a0');
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
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'On with -ko to ask a question. Speech often says -ks: onks.', 'is it?', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-5eb112d9aace');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sade][Ny]ulla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinulla', 'sul',
      'adessive singular', 'Sinä with -lla. With on it means ''you have''. Speech shortens it to sul.', 'you have', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-87d0163b4377');
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
  if not exists (select 1 from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('passi', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"passi","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]passi[X]pass[Sn][Ny]i","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+passi(passi)"}'::jsonb,
      'passi', 'passi',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'passport', 'passport', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-a8a46a7c73f0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'passi', 'passi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'passport', 'passport')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'passi', 'passi',
      (select form_name_en from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi'),
      (select why_en from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi'),
      (select meaning_en from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi'),
      (select lemma_meaning_en from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'passport', 'passport';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukana', 'CLASS=seikkasana', '{"BASEFORM":"mukana","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'mukana', 'mukana',
      'adverb', 'This is the dictionary form. People say it the same way.', 'with you, along', 'with you, along', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-34332dc97959');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mukana', 'mukana';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'with you, along', 'with you, along')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mukana', 'mukana',
      (select form_name_en from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana'),
      (select why_en from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana'),
      (select meaning_en from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana'),
      (select lemma_meaning_en from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'with you, along', 'with you, along';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ja', 'CLASS=sidesana', '{"BASEFORM":"ja","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]ja[X]ja","STRUCTURE":"=pp","WORDBASES":"+ja(ja)"}'::jsonb,
      'ja', 'ja',
      'conjunction', 'This is the dictionary form. People say it the same way.', 'and', 'and', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-938eb8c80d8d');
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
      'adessive singular', 'Minä with -lla. With on it means ''I have''. Speech shortens it to mul.', 'I have', 'I, me', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-cc0fdb024b55');
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
  if not exists (select 1 from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('oleskelulupa', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"oleskelulupa","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]oleskella[X]oleskel[Ln][Xj]u[X]u[Sn][Ny][Bh][Bc][Ln][Xp]lupa[X]lup[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppppp=pppp","WORDBASES":"+oleskel(oleskella)+u(+u)+lupa(lupa)"}'::jsonb,
      'oleskelulupa', 'oleskelulupa',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit', 'residence permit', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-8e91f1b27b81');
  end if;
  if not exists (select 1 from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oleskelulupa', 'oleskelulupa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit', 'residence permit')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oleskelulupa', 'oleskelulupa',
      (select form_name_en from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa'),
      (select why_en from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa'),
      (select meaning_en from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa'),
      (select lemma_meaning_en from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'residence permit', 'residence permit';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tarvita', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"tarvita","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tarvita[X]tarvitse[Tt][Ap][P2][Ny][Ef]t","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+tarvita(tarvita)"}'::jsonb,
      'tarvitset', 'tarviit',
      'present tense, 2nd person singular', 'Adds -t for ''you'': tarvita becomes tarvitset. Speech says tarviit.', 'you need', 'to need', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-bbff218098a9');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tarvitset', 'tarvita';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular', 'Adds -t for ''you'': tarvita becomes tarvitset. Speech says tarviit.', 'you need', 'to need')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tarvitset', 'tarvita',
      (select form_name_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit'),
      (select why_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit'),
      (select meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit'),
      (select lemma_meaning_en from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit'),
      'present tense, 2nd person singular', 'Adds -t for ''you'': tarvita becomes tarvitset. Speech says tarviit.', 'you need', 'to need';
  end if;
  if not exists (select 1 from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('myös', 'CLASS=seikkasana', '{"BASEFORM":"myös","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]myös[X]myös","STRUCTURE":"=pppp","WORDBASES":"+myös(myös)"}'::jsonb,
      'myös', 'myös',
      'adverb', 'This is the dictionary form. People say it the same way.', 'also, too', 'also, too', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-fe354724e29a');
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
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('suomalainen', 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"suomalainen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]suomalainen[X]suomalai[Sg][Ny]sen","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+suomalainen(suomalainen)"}'::jsonb,
      'suomalaisen', 'suomalaisen',
      'genitive singular', 'The genitive singular matches osoitteen: suomalainen becomes suomalaisen.', 'Finnish (a Finnish ...)', 'Finnish, a Finn', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-a31d2f4fd3fe');
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'suomalaisen', 'suomalainen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'The genitive singular matches osoitteen: suomalainen becomes suomalaisen.', 'Finnish (a Finnish ...)', 'Finnish, a Finn')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'suomalaisen', 'suomalainen',
      (select form_name_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen'),
      (select why_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen'),
      (select meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen'),
      (select lemma_meaning_en from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen'),
      'genitive singular', 'The genitive singular matches osoitteen: suomalainen becomes suomalaisen.', 'Finnish (a Finnish ...)', 'Finnish, a Finn';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osoite', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"osoite","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osoite[X]osoitte[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppppppp","WORDBASES":"+osoite(osoite)"}'::jsonb,
      'osoitteen', 'osotteen',
      'genitive singular', 'As the thing you need, osoite takes -en: osoitteen. Speech drops the i: osotteen.', 'an address', 'address', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-f42ea2e1df12');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osoitteen', 'osoite';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the thing you need, osoite takes -en: osoitteen. Speech drops the i: osotteen.', 'an address', 'address')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osoitteen', 'osoite',
      (select form_name_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen'),
      (select why_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen'),
      (select meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen'),
      (select lemma_meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen'),
      'genitive singular', 'As the thing you need, osoite takes -en: osoitteen. Speech drops the i: osotteen.', 'an address', 'address';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('osoite', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"osoite","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]osoite[X]osoite[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+osoite(osoite)"}'::jsonb,
      'osoite', 'osote',
      'nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-25a4e9144483');
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'osoite', 'osoite';
  end if;
  if not exists (select 1 from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'osoite', 'osoite',
      (select form_name_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select why_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      (select lemma_meaning_en from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote'),
      'nominative singular', 'Speech drops the i in the middle: osoite becomes osote. Books write osoite.', 'an address', 'address';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täydellinen', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"täydellinen","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]täydellinen[X]täydelli[Sp][Ny]stä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppppppp","WORDBASES":"+täydellinen(täydellinen)"}'::jsonb,
      'täydellistä', 'täydellistä',
      'partitive singular', 'The partitive singular is used in exclamations: täydellinen becomes täydellistä.', 'great (just right)', 'perfect', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-b5ed22a41039');
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
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täyttää', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"täyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]täyttää[X]täytä[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+täyttää(täyttää)"}'::jsonb,
      'täytä', 'täytä',
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: täyttää becomes täytä, tt turning to t.', 'fill in', 'to fill in, to fill', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-e3d576fed7ca');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täytä', 'täyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: täyttää becomes täytä, tt turning to t.', 'fill in', 'to fill in, to fill')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täytä', 'täyttää',
      (select form_name_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä'),
      (select why_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä'),
      (select meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä'),
      (select lemma_meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä'),
      'imperative present tense, 2nd person singular', 'The imperative for one person drops the ending: täyttää becomes täytä, tt turning to t.', 'fill in', 'to fill in, to fill';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tämä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"tämä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tämä[X]tä[Sn][Ny]mä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+tämä(tämä)"}'::jsonb,
      'tämä', 'tää',
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-4352ca83b810');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tämä', 'tämä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tämä', 'tämä',
      (select form_name_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select why_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      (select lemma_meaning_en from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää'),
      'nominative singular', 'Speech shortens tämä to tää. Books write tämä.', 'this', 'this';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lomake', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"lomake","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]lomake[X]lomake[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+lomake(lomake)"}'::jsonb,
      'lomake', 'lomake',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'form', 'form', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-a0b5ff7715ab');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lomake', 'lomake';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'form', 'form')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lomake', 'lomake',
      (select form_name_en from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake'),
      (select why_en from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake'),
      (select meaning_en from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake'),
      (select lemma_meaning_en from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'form', 'form';
  end if;
  if not exists (select 1 from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('niin', 'CLASS=seikkasana', '{"BASEFORM":"niin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]niin[X]niin","STRUCTURE":"=pppp","WORDBASES":"+niin(niin)"}'::jsonb,
      'niin', 'niin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'so, then', 'so, then', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-4f1448504014');
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
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-9f0f9f1fdd21');
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'me', 'me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative plural', 'Me means we. People say it the same way.', 'we', 'we')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'me', 'me',
      (select form_name_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select why_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      (select lemma_meaning_en from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me'),
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we';
  end if;
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('avata', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"avata","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]avata[X]avaa[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+avata(avata)"}'::jsonb,
      'avaamme', 'avataan',
      'present tense, 1st person plural', 'Adds -mme for ''we'': avata becomes avaamme. Speech uses me avataan instead.', 'we open', 'to open', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-b7260d8e21b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'avaamme', 'avata';
  end if;
  if not exists (select 1 from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Adds -mme for ''we'': avata becomes avaamme. Speech uses me avataan instead.', 'we open', 'to open')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'avaamme', 'avata',
      (select form_name_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan'),
      (select why_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan'),
      (select meaning_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan'),
      (select lemma_meaning_en from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan'),
      'present tense, 1st person plural', 'Adds -mme for ''we'': avata becomes avaamme. Speech uses me avataan instead.', 'we open', 'to open';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tili', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tili","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]tili[X]til[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+tili(tili)"}'::jsonb,
      'tilin', 'tili',
      'genitive singular', 'As the whole thing you open, tili takes -n: tilin. Speech often keeps tili.', 'the account', 'account', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-8a022daa3e60');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tilin', 'tili';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'As the whole thing you open, tili takes -n: tilin. Speech often keeps tili.', 'the account', 'account')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tilin', 'tili',
      (select form_name_en from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili'),
      (select why_en from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili'),
      (select meaning_en from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili'),
      (select lemma_meaning_en from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili'),
      'genitive singular', 'As the whole thing you open, tili takes -n: tilin. Speech often keeps tili.', 'the account', 'account';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('täyttää', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"täyttää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]täyttää[X]täytä[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+täyttää(täyttää)"}'::jsonb,
      'täytän', 'täytän',
      'present tense, 1st person singular', 'Adds -n for ''I'': täyttää becomes täytän, tt turning to t.', 'I fill in', 'to fill in, to fill', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-6723ec48ed53');
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'täytän', 'täyttää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Adds -n for ''I'': täyttää becomes täytän, tt turning to t.', 'I fill in', 'to fill in, to fill')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'täytän', 'täyttää',
      (select form_name_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän'),
      (select why_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän'),
      (select meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän'),
      (select lemma_meaning_en from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän'),
      'present tense, 1st person singular', 'Adds -n for ''I'': täyttää becomes täytän, tt turning to t.', 'I fill in', 'to fill in, to fill';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('heti', 'CLASS=seikkasana', '{"BASEFORM":"heti","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]heti[X]heti","STRUCTURE":"=pppp","WORDBASES":"+heti(heti)"}'::jsonb,
      'heti', 'heti',
      'adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away', 'approved', now(), 'content/approvals/part-3.json#opening-a-bank-account/form-78a5f0b146da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'heti', 'heti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'heti', 'heti',
      (select form_name_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select why_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select meaning_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      (select lemma_meaning_en from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'right away', 'right away';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Tiina', 'Seuraava, ole hyvä.',
    'Seuraava, olkaa hyvä.', 'Next, please.',
    'opening-a-bank-account/1-puhe-f6277cb7aded.mp3', 'opening-a-bank-account/1-kirja-567117f66815.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Seuraava', (select id from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava')),
    (v_line_id, 'kirja', 2, 'olkaa', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole')),
    (v_line_id, 'kirja', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 1, 'Seuraava', (select id from public.forms where lemma = 'seuraava' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive;PARTICIPLE=present_active' and surface_kirja = 'seuraava' and surface_puhe = 'seuraava')),
    (v_line_id, 'puhe', 2, 'ole', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olkaa' and surface_puhe = 'ole')),
    (v_line_id, 'puhe', 3, 'hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Moi! Mä haluun avata pankkitilin.',
    'Hei! Minä haluan avata pankkitilin.', 'Hi! I want to open a bank account.',
    'opening-a-bank-account/2-puhe-8a4cc862894f.mp3', 'opening-a-bank-account/2-kirja-be46d86c8fa7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'haluan', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'kirja', 4, 'avata', (select id from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata')),
    (v_line_id, 'kirja', 5, 'pankkitilin', (select id from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'haluun', (select id from public.forms where lemma = 'haluta' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'haluan' and surface_puhe = 'haluun')),
    (v_line_id, 'puhe', 4, 'avata', (select id from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'avata' and surface_puhe = 'avata')),
    (v_line_id, 'puhe', 5, 'pankkitilin', (select id from public.forms where lemma = 'pankkitili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'pankkitilin' and surface_puhe = 'pankkitilin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Tiina', 'Okei. Onks sul passi mukana?',
    'Selvä. Onko sinulla passi mukana?', 'OK. Do you have your passport with you?',
    'opening-a-bank-account/3-puhe-c306d66c7b00.mp3', 'opening-a-bank-account/3-kirja-d6006a4cc64e.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Selvä', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'kirja', 2, 'Onko', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'kirja', 3, 'sinulla', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'kirja', 4, 'passi', (select id from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi')),
    (v_line_id, 'kirja', 5, 'mukana', (select id from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana')),
    (v_line_id, 'puhe', 1, 'Okei', (select id from public.forms where lemma = 'selvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'selvä' and surface_puhe = 'okei')),
    (v_line_id, 'puhe', 2, 'Onks', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'onko' and surface_puhe = 'onks')),
    (v_line_id, 'puhe', 3, 'sul', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'sinulla' and surface_puhe = 'sul')),
    (v_line_id, 'puhe', 4, 'passi', (select id from public.forms where lemma = 'passi' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'passi' and surface_puhe = 'passi')),
    (v_line_id, 'puhe', 5, 'mukana', (select id from public.forms where lemma = 'mukana' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'mukana' and surface_puhe = 'mukana'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'On. Ja mul on oleskelulupa.',
    'On. Ja minulla on oleskelulupa.', 'Yes. And I have a residence permit.',
    'opening-a-bank-account/4-puhe-982a1e401c5d.mp3', 'opening-a-bank-account/4-kirja-b9f7210094c4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'kirja', 3, 'minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'oleskelulupa', (select id from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa')),
    (v_line_id, 'puhe', 1, 'On', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 2, 'Ja', (select id from public.forms where lemma = 'ja' and form_tag = 'CLASS=sidesana' and surface_kirja = 'ja' and surface_puhe = 'ja')),
    (v_line_id, 'puhe', 3, 'mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'oleskelulupa', (select id from public.forms where lemma = 'oleskelulupa' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'oleskelulupa' and surface_puhe = 'oleskelulupa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Tiina', 'Hyvä. Sä tarviit myös suomalaisen osotteen.',
    'Hyvä. Sinä tarvitset myös suomalaisen osoitteen.', 'Good. You also need a Finnish address.',
    'opening-a-bank-account/5-puhe-0e2301cee3cb.mp3', 'opening-a-bank-account/5-kirja-78f6f8863f7a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 3, 'tarvitset', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit')),
    (v_line_id, 'kirja', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'kirja', 5, 'suomalaisen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen')),
    (v_line_id, 'kirja', 6, 'osoitteen', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 3, 'tarviit', (select id from public.forms where lemma = 'tarvita' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'tarvitset' and surface_puhe = 'tarviit')),
    (v_line_id, 'puhe', 4, 'myös', (select id from public.forms where lemma = 'myös' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'myös' and surface_puhe = 'myös')),
    (v_line_id, 'puhe', 5, 'suomalaisen', (select id from public.forms where lemma = 'suomalainen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'suomalaisen' and surface_puhe = 'suomalaisen')),
    (v_line_id, 'puhe', 6, 'osotteen', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'osoitteen' and surface_puhe = 'osotteen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Mul on osote Kalliossa.',
    'Minulla on osoite Kalliossa.', 'I have an address in Kallio.',
    'opening-a-bank-account/6-puhe-72083d9e4580.mp3', 'opening-a-bank-account/6-kirja-e080a6637f76.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minulla', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'osoite', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote')),
    (v_line_id, 'kirja', 4, 'Kalliossa', null),
    (v_line_id, 'puhe', 1, 'Mul', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'minulla' and surface_puhe = 'mul')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'osote', (select id from public.forms where lemma = 'osoite' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'osoite' and surface_puhe = 'osote')),
    (v_line_id, 'puhe', 4, 'Kalliossa', null);
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Tiina', 'Täydellistä. Täytä tää lomake, niin me avataan tili.',
    'Täydellistä. Täytä tämä lomake, niin me avaamme tilin.', 'Perfect. Fill in this form and we''ll open the account.',
    'opening-a-bank-account/7-puhe-92227795ae0d.mp3', 'opening-a-bank-account/7-kirja-5433470843b6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Täydellistä', (select id from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä')),
    (v_line_id, 'kirja', 2, 'Täytä', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä')),
    (v_line_id, 'kirja', 3, 'tämä', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'kirja', 4, 'lomake', (select id from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake')),
    (v_line_id, 'kirja', 5, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'kirja', 6, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 7, 'avaamme', (select id from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan')),
    (v_line_id, 'kirja', 8, 'tilin', (select id from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili')),
    (v_line_id, 'puhe', 1, 'Täydellistä', (select id from public.forms where lemma = 'täydellinen' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'täydellistä' and surface_puhe = 'täydellistä')),
    (v_line_id, 'puhe', 2, 'Täytä', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'täytä' and surface_puhe = 'täytä')),
    (v_line_id, 'puhe', 3, 'tää', (select id from public.forms where lemma = 'tämä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'tämä' and surface_puhe = 'tää')),
    (v_line_id, 'puhe', 4, 'lomake', (select id from public.forms where lemma = 'lomake' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'lomake' and surface_puhe = 'lomake')),
    (v_line_id, 'puhe', 5, 'niin', (select id from public.forms where lemma = 'niin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'niin' and surface_puhe = 'niin')),
    (v_line_id, 'puhe', 6, 'me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 7, 'avataan', (select id from public.forms where lemma = 'avata' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'avaamme' and surface_puhe = 'avataan')),
    (v_line_id, 'puhe', 8, 'tili', (select id from public.forms where lemma = 'tili' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tilin' and surface_puhe = 'tili'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Kiitti! Mä täytän sen heti.',
    'Kiitos! Minä täytän sen heti.', 'Thanks! I''ll fill it in right away.',
    'opening-a-bank-account/8-puhe-490427de643b.mp3', 'opening-a-bank-account/8-kirja-a07e97f9ea55.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'täytän', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän')),
    (v_line_id, 'kirja', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 5, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'täytän', (select id from public.forms where lemma = 'täyttää' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'täytän' and surface_puhe = 'täytän')),
    (v_line_id, 'puhe', 4, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 5, 'heti', (select id from public.forms where lemma = 'heti' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'heti' and surface_puhe = 'heti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-3.json#opening-a-bank-account/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop stays a draft until its last dialogue is published, so a learner
  -- never sees a stop with a dialogue missing.
end
$publish$;
