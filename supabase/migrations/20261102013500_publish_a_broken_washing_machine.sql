-- Publishes the dialogue a-broken-washing-machine (unit problems-and-returns). Made by
-- scripts/generate/pipeline.py publish from content/drafts/a-broken-washing-machine. Do not edit by hand:
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
    where slug = 'a-broken-washing-machine' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'a-broken-washing-machine';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 32
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'problems-and-returns' and position = 32 and stop_number = 32;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'problems-and-returns';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'a-broken-washing-machine', 3,
    'A broken washing machine')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'a-broken-washing-machine' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'A broken washing machine';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'a-broken-washing-machine';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asiakaspalvelu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"asiakaspalvelu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asiakas[X]asiaka[Sn][Ny]s[Bh][Bc][Lt][Xp]palvella[X]palvel[Ln][Xj]u[X]u[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppppp=ppppppp","WORDBASES":"+asiakas(asiakas)+palvel(palvella)+u(+u)"}'::jsonb,
      'asiakaspalvelu', 'asiakaspalvelu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'customer service', 'customer service', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-e40d7ec8a896');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asiakaspalvelu', 'asiakaspalvelu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'customer service', 'customer service')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asiakaspalvelu', 'asiakaspalvelu',
      (select form_name_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu'),
      (select why_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu'),
      (select meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu'),
      (select lemma_meaning_en from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'customer service', 'customer service';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('miten', 'CLASS=seikkasana', '{"BASEFORM":"miten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]miten[X]miten","STRUCTURE":"=ppppp","WORDBASES":"+miten(miten)"}'::jsonb,
      'miten', 'miten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-34eb915c255e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'miten', 'miten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'miten', 'miten',
      (select form_name_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select why_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      (select lemma_meaning_en from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'how', 'how';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voin', 'voin',
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-1932b7fb8d7b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'voin', 'voida';
  end if;
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'voin', 'voida',
      (select form_name_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select why_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      (select lemma_meaning_en from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin'),
      'present tense, 1st person singular', 'Voida, can, with -n for ''I'': voin.', 'I can', 'can, to be able to';
  end if;
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('auttaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"auttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]auttaa[X]autta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+auttaa(auttaa)"}'::jsonb,
      'auttaa', 'auttaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-b4a17f5a61be');
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
  if not exists (select 1 from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hei', 'CLASS=huudahdussana', '{"BASEFORM":"hei","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]hei[X]hei","STRUCTURE":"=ppp","WORDBASES":"+hei(hei)"}'::jsonb,
      'hei', 'moi',
      'interjection', 'Moi is the everyday spoken hello. Books and formal texts write hei.', 'hi', 'hi, hello', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-124d5d19fe78');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('uusi', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"uusi","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][De][Xp]uusi[X]uu[Sn][Ny]si","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+uusi(uusi)"}'::jsonb,
      'uusi', 'uus',
      'nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-64f62e81608d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'uusi', 'uusi';
  end if;
  if not exists (select 1 from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'uusi', 'uusi',
      (select form_name_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select why_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      (select lemma_meaning_en from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus'),
      'nominative singular', 'Speech drops the final i: uusi becomes uus. Books write uusi.', 'new', 'new';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pesukone', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"pesukone","CLASS":"nimisana","FSTOUTPUT":"[Lt][Xp]pestä[X]pes[Ln][Xj]u[X]u[Sn][Ny][Bh][Bc][Ln][Xp]kone[X]kone[Sn][Ny]e[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppp=ppppppp","WORDBASES":"+pes(pestä)+u(+u)+kone(kone)"}'::jsonb,
      'pesukoneeni', 'pesukone',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': pesukoneeni. Speech says mun pesukone and drops the ending.', 'my washing machine', 'washing machine', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-b21838d9e3e1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pesukoneeni', 'pesukone';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': pesukoneeni. Speech says mun pesukone and drops the ending.', 'my washing machine', 'washing machine')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pesukoneeni', 'pesukone',
      (select form_name_en from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone'),
      (select why_en from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone'),
      (select meaning_en from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone'),
      (select lemma_meaning_en from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': pesukoneeni. Speech says mun pesukone and drops the ending.', 'my washing machine', 'washing machine';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käynnistyä', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"käynnistyä","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'käynnisty', 'käynnisty',
      'present tense, negative form', 'After ei the verb drops its ending: käynnistyä becomes käynnisty.', 'start (won''t start)', 'to start (a machine)', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-0242e741d625');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käynnisty', 'käynnistyä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After ei the verb drops its ending: käynnistyä becomes käynnisty.', 'start (won''t start)', 'to start (a machine)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käynnisty', 'käynnistyä',
      (select form_name_en from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty'),
      (select why_en from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty'),
      (select meaning_en from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty'),
      (select lemma_meaning_en from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty'),
      'present tense, negative form', 'After ei the verb drops its ending: käynnistyä becomes käynnisty.', 'start (won''t start)', 'to start (a machine)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ikävä', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"ikävä","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]ikävä[X]ikäv[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+ikävä(ikävä)"}'::jsonb,
      'ikävää', 'ikävää',
      'partitive singular', 'Ikävä means sad or unpleasant. Said alone with -ä, ikävää means ''that''s a pity''.', 'sorry to hear that', 'missing someone, sad', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-3f584c669340');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ikävää', 'ikävä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Ikävä means sad or unpleasant. Said alone with -ä, ikävää means ''that''s a pity''.', 'sorry to hear that', 'missing someone, sad')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ikävää', 'ikävä',
      (select form_name_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää'),
      (select why_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää'),
      (select meaning_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää'),
      (select lemma_meaning_en from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää'),
      'partitive singular', 'Ikävä means sad or unpleasant. Said alone with -ä, ikävää means ''that''s a pity''.', 'sorry to hear that', 'missing someone, sad';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('milloin', 'CLASS=seikkasana', '{"BASEFORM":"milloin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]milloin[X]milloin","STRUCTURE":"=ppppppp","WORDBASES":"+milloin(milloin)"}'::jsonb,
      'milloin', 'millon',
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-a0518fcf4ae6');
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'milloin', 'milloin';
  end if;
  if not exists (select 1 from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'milloin', 'milloin',
      (select form_name_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select why_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      (select lemma_meaning_en from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon'),
      'adverb', 'Speech often drops an i: millon. Books write milloin.', 'when', 'when';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ostaa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"ostaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]ostaa[X]ost[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+ostaa(ostaa)"}'::jsonb,
      'ostit', 'ostit',
      'past tense, 2nd person singular', 'Ostaa means to buy. -i- marks the past and -t goes with sinä: ostit.', 'you bought', 'to buy', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ad1b15db143a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ostit', 'ostaa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Ostaa means to buy. -i- marks the past and -t goes with sinä: ostit.', 'you bought', 'to buy')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ostit', 'ostaa',
      (select form_name_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit'),
      (select why_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit'),
      (select meaning_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit'),
      (select lemma_meaning_en from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit'),
      'past tense, 2nd person singular', 'Ostaa means to buy. -i- marks the past and -t goes with sinä: ostit.', 'you bought', 'to buy';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kaksi', 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kaksi","CLASS":"lukusana","FSTOUTPUT":"[Lu][Xp]kaksi[X]ka[Sn][Ny]ksi","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+kaksi(kaksi)"}'::jsonb,
      'kaksi', 'kaks',
      'nominative singular', 'Speech drops the final i: kaksi becomes kaks.', 'two', 'two', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-05a31ace9a1d');
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
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('viikko', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"viikko","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]viikko[X]viikko[Sp][Ny]a","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppppp","WORDBASES":"+viikko(viikko)"}'::jsonb,
      'viikkoa', 'viikkoo',
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-0cc3e6dfc99a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'viikkoa', 'viikko';
  end if;
  if not exists (select 1 from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'viikkoa', 'viikko',
      (select form_name_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select why_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      (select lemma_meaning_en from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo'),
      'partitive singular', 'After a number above one, the noun takes the partitive singular: viikko becomes viikkoa. Speech says viikkoo.', 'weeks', 'week';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sitten',
      'adverb', 'This is the dictionary form. People say it the same way.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ab04c0cf38cc');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitten', 'sitten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'This is the dictionary form. People say it the same way.', 'then', 'then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitten', 'sitten',
      (select form_name_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten'),
      (select why_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten'),
      (select meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten'),
      (select lemma_meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten'),
      'adverb', 'This is the dictionary form. People say it the same way.', 'then', 'then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sitten', 'CLASS=seikkasana', '{"BASEFORM":"sitten","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]sitten[X]sitten","STRUCTURE":"=pppppp","WORDBASES":"+sitten(sitten)"}'::jsonb,
      'sitten', 'sit',
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ad4c189b50dd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitten', 'sitten';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitten', 'sitten',
      (select form_name_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select why_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      (select lemma_meaning_en from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit'),
      'adverb', 'Speech shortens sitten to sit. Books write sitten.', 'then', 'then';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sine][Ny]iinä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+se(se)"}'::jsonb,
      'siinä', 'siin',
      'inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-68a39070d239');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'siinä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'siinä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin'),
      'inessive singular', 'The inessive singular of se ''it'': siinä. Speech drops the last ä: siin.', 'in it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-24c73cc721d6');
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
  if not exists (select 1 from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('takuu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"takuu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]takuu[X]takuu[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+takuu(takuu)"}'::jsonb,
      'takuu', 'takuu',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'warranty, guarantee', 'warranty, guarantee', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-c04ec581fb5b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'takuu', 'takuu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'warranty, guarantee', 'warranty, guarantee')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'takuu', 'takuu',
      (select form_name_en from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu'),
      (select why_en from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu'),
      (select meaning_en from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu'),
      (select lemma_meaning_en from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'warranty, guarantee', 'warranty, guarantee';
  end if;
  if not exists (select 1 from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('me', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural', '{"BASEFORM":"me","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]me[X]me[Sn][Nm]","NUMBER":"plural","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+me(me)"}'::jsonb,
      'me', 'me',
      'nominative plural', 'Me means we. People say it the same way.', 'we', 'we', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-9f0f9f1fdd21');
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
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähettää', 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"lähettää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähettää[X]lähetä[Tt][Ap][P1][Nm][Ef]mme","MOOD":"indicative","NEGATIVE":"false","NUMBER":"plural","PERSON":"1","STRUCTURE":"=ppppppppp","TENSE":"present_simple","WORDBASES":"+lähettää(lähettää)"}'::jsonb,
      'lähetämme', 'lähetetään',
      'present tense, 1st person plural', 'Speech uses lähetetään with me, ''we''. Books write lähetämme.', 'we''ll send', 'to send', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-7a36e56d6749');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähetämme', 'lähettää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person plural', 'Speech uses lähetetään with me, ''we''. Books write lähetämme.', 'we''ll send', 'to send')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähetämme', 'lähettää',
      (select form_name_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään'),
      (select why_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään'),
      (select meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään'),
      (select lemma_meaning_en from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään'),
      'present tense, 1st person plural', 'Speech uses lähetetään with me, ''we''. Books write lähetämme.', 'we''ll send', 'to send';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('huoltomies', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"huoltomies","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]huolto[X]huolto[Sn][Ny][Bh][Bc][Ln][Xp]mies[X]miehe[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppppp=pppppp","WORDBASES":"+huolto(huolto)+mies(mies)"}'::jsonb,
      'huoltomiehen', 'huoltomies',
      'genitive singular', 'Books add -n for a whole person sent: huoltomiehen. Speech here keeps the dictionary form huoltomies.', 'a repair person', 'repair person', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-31c80d3e80ec');
  end if;
  if not exists (select 1 from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'huoltomiehen', 'huoltomies';
  end if;
  if not exists (select 1 from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Books add -n for a whole person sent: huoltomiehen. Speech here keeps the dictionary form huoltomies.', 'a repair person', 'repair person')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'huoltomiehen', 'huoltomies',
      (select form_name_en from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies'),
      (select why_en from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies'),
      (select meaning_en from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies'),
      (select lemma_meaning_en from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies'),
      'genitive singular', 'Books add -n for a whole person sent: huoltomiehen. Speech here keeps the dictionary form huoltomies.', 'a repair person', 'repair person';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P3][Ny][Eb]","MOOD":"indicative","NEGATIVE":"both","NUMBER":"singular","PERSON":"3","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voi', 'voi',
      'present tense, 3rd person singular', 'Voida, can. With hän or a person, the verb is voi: lääkäri voi, the doctor can.', 'can', 'can, to be able to', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-fc6219c3121b');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tull[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=ppppp","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulla', 'tulla',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-0dffaba9319d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulla', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulla', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to come', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('torstai', 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular', '{"BASEFORM":"torstai","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]torstai[X]torstai[Ses][Ny]na","NUMBER":"singular","SIJAMUOTO":"olento","STRUCTURE":"=ppppppppp","WORDBASES":"+torstai(torstai)"}'::jsonb,
      'torstaina', 'torstaina',
      'essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-bc45764ddc70');
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'torstaina', 'torstai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'torstaina', 'torstai',
      (select form_name_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select why_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      (select lemma_meaning_en from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina'),
      'essive singular', 'Days take -na for ''on'': torstai becomes torstaina.', 'on Thursday', 'Thursday';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aamupäivä', 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"aamupäivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]aamu[X]aamu[Sn][Ny][Bh][Bc][Ln][Xp]päivä[X]päivä[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp=pppppppp","WORDBASES":"+aamu(aamu)+päivä(päivä)"}'::jsonb,
      'aamupäivällä', 'aamupäiväl',
      'adessive singular', 'Adds -llä for time: aamupäivä becomes aamupäivällä. Speech shortens -llä to -l: aamupäivällä becomes aamupäiväl.', 'in the morning', 'morning (before noon)', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-1123dd726c67');
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'aamupäivällä', 'aamupäivä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Adds -llä for time: aamupäivä becomes aamupäivällä. Speech shortens -llä to -l: aamupäivällä becomes aamupäiväl.', 'in the morning', 'morning (before noon)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'aamupäivällä', 'aamupäivä',
      (select form_name_en from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl'),
      (select why_en from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl'),
      (select meaning_en from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl'),
      (select lemma_meaning_en from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl'),
      'adessive singular', 'Adds -llä for time: aamupäivä becomes aamupäivällä. Speech shortens -llä to -l: aamupäivällä becomes aamupäiväl.', 'in the morning', 'morning (before noon)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopiiko', 'sopiiks',
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-f0aadca6a510');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sopiiko', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sopiiko', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks'),
      'present tense, 3rd person singular, with the question ending -ko/-kö', 'Sopii with -ko to ask. Speech says -ks: sopiiks.', 'does it suit?', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sopia', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sopia","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sopia[X]sop[Tt][Ap][P3][Ny][Ef]ii","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sopia(sopia)"}'::jsonb,
      'sopii', 'sopii',
      'present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-a47b56ad4b54');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sopii', 'sopia';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sopii', 'sopia',
      (select form_name_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select why_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      (select lemma_meaning_en from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii'),
      'present tense, 3rd person singular', 'Sopia, to suit, in the form for he, she or it: sopii.', 'suits', 'to suit, to agree';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('apu', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"apu","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]apu[X]avu[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppp","WORDBASES":"+apu(apu)"}'::jsonb,
      'avusta', 'avusta',
      'elative singular', 'Apu, help, with -sta: avusta, and p turns to v. Kiitos takes -sta for ''thanks for''.', 'for the help', 'help', 'approved', now(), 'content/approvals/part-6.json#a-broken-washing-machine/form-0da6cd80fc33');
  end if;
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'avusta', 'apu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Apu, help, with -sta: avusta, and p turns to v. Kiitos takes -sta for ''thanks for''.', 'for the help', 'help')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'avusta', 'apu',
      (select form_name_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta'),
      (select why_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta'),
      (select meaning_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta'),
      (select lemma_meaning_en from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta'),
      'elative singular', 'Apu, help, with -sta: avusta, and p turns to v. Kiitos takes -sta for ''thanks for''.', 'for the help', 'help';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Juho', 'Asiakaspalvelu, Juho. Miten voin auttaa?',
    'Asiakaspalvelu, Juho. Miten voin auttaa?', 'Customer service, Juho speaking. How can I help?',
    'a-broken-washing-machine/1-puhe-72bec8749c66.mp3', 'a-broken-washing-machine/1-kirja-a4b443546f0f.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Asiakaspalvelu', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu')),
    (v_line_id, 'kirja', 2, 'Juho', null),
    (v_line_id, 'kirja', 3, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'kirja', 4, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'kirja', 5, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'puhe', 1, 'Asiakaspalvelu', (select id from public.forms where lemma = 'asiakaspalvelu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asiakaspalvelu' and surface_puhe = 'asiakaspalvelu')),
    (v_line_id, 'puhe', 2, 'Juho', null),
    (v_line_id, 'puhe', 3, 'Miten', (select id from public.forms where lemma = 'miten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'miten' and surface_puhe = 'miten')),
    (v_line_id, 'puhe', 4, 'voin', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'voin' and surface_puhe = 'voin')),
    (v_line_id, 'puhe', 5, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Maria', 'Moi! Mun uus pesukone ei käynnisty.',
    'Hei! Minun uusi pesukoneeni ei käynnisty.', 'Hi! My new washing machine won''t start.',
    'a-broken-washing-machine/2-puhe-eb3c8e36089e.mp3', 'a-broken-washing-machine/2-kirja-da31cb2bde0c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hei', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'kirja', 2, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 3, 'uusi', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus')),
    (v_line_id, 'kirja', 4, 'pesukoneeni', (select id from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone')),
    (v_line_id, 'kirja', 5, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 6, 'käynnisty', (select id from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty')),
    (v_line_id, 'puhe', 1, 'Moi', (select id from public.forms where lemma = 'hei' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'hei' and surface_puhe = 'moi')),
    (v_line_id, 'puhe', 2, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 3, 'uus', (select id from public.forms where lemma = 'uusi' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'uusi' and surface_puhe = 'uus')),
    (v_line_id, 'puhe', 4, 'pesukone', (select id from public.forms where lemma = 'pesukone' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'pesukoneeni' and surface_puhe = 'pesukone')),
    (v_line_id, 'puhe', 5, 'ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 6, 'käynnisty', (select id from public.forms where lemma = 'käynnistyä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'käynnisty' and surface_puhe = 'käynnisty'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Juho', 'Ikävää. Millon sä ostit sen?',
    'Ikävää. Milloin sinä ostit sen?', 'Sorry to hear that. When did you buy it?',
    'a-broken-washing-machine/3-puhe-c43b3bf01fb1.mp3', 'a-broken-washing-machine/3-kirja-ce986dfb48d1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ikävää', (select id from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää')),
    (v_line_id, 'kirja', 2, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'ostit', (select id from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit')),
    (v_line_id, 'kirja', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 1, 'Ikävää', (select id from public.forms where lemma = 'ikävä' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ikävää' and surface_puhe = 'ikävää')),
    (v_line_id, 'puhe', 2, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'ostit', (select id from public.forms where lemma = 'ostaa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'ostit' and surface_puhe = 'ostit')),
    (v_line_id, 'puhe', 5, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Maria', 'Kaks viikkoo sitten.',
    'Kaksi viikkoa sitten.', 'Two weeks ago.',
    'a-broken-washing-machine/4-puhe-d9f007eb683b.mp3', 'a-broken-washing-machine/4-kirja-8714f0c496cb.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kaksi', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'kirja', 2, 'viikkoa', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo')),
    (v_line_id, 'kirja', 3, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten')),
    (v_line_id, 'puhe', 1, 'Kaks', (select id from public.forms where lemma = 'kaksi' and form_tag = 'CLASS=lukusana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kaksi' and surface_puhe = 'kaks')),
    (v_line_id, 'puhe', 2, 'viikkoo', (select id from public.forms where lemma = 'viikko' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'viikkoa' and surface_puhe = 'viikkoo')),
    (v_line_id, 'puhe', 3, 'sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sitten'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Juho', 'Sit siin on takuu. Me lähetetään huoltomies.',
    'Sitten siinä on takuu. Me lähetämme huoltomiehen.', 'Then it''s under warranty. We''ll send a repair person.',
    'a-broken-washing-machine/5-puhe-3d803c2cb2b8.mp3', 'a-broken-washing-machine/5-kirja-27bc3525964c.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sitten', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'kirja', 2, 'siinä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin')),
    (v_line_id, 'kirja', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 4, 'takuu', (select id from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu')),
    (v_line_id, 'kirja', 5, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'kirja', 6, 'lähetämme', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään')),
    (v_line_id, 'kirja', 7, 'huoltomiehen', (select id from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies')),
    (v_line_id, 'puhe', 1, 'Sit', (select id from public.forms where lemma = 'sitten' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'sitten' and surface_puhe = 'sit')),
    (v_line_id, 'puhe', 2, 'siin', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'siinä' and surface_puhe = 'siin')),
    (v_line_id, 'puhe', 3, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 4, 'takuu', (select id from public.forms where lemma = 'takuu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'takuu' and surface_puhe = 'takuu')),
    (v_line_id, 'puhe', 5, 'Me', (select id from public.forms where lemma = 'me' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=plural' and surface_kirja = 'me' and surface_puhe = 'me')),
    (v_line_id, 'puhe', 6, 'lähetetään', (select id from public.forms where lemma = 'lähettää' and form_tag = 'CLASS=teonsana;NUMBER=plural;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'lähetämme' and surface_puhe = 'lähetetään')),
    (v_line_id, 'puhe', 7, 'huoltomies', (select id from public.forms where lemma = 'huoltomies' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'huoltomiehen' and surface_puhe = 'huoltomies'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Maria', 'Hyvä. Millon se voi tulla?',
    'Hyvä. Milloin hän voi tulla?', 'Good. When can they come?',
    'a-broken-washing-machine/6-puhe-a04b6ed9b2b2.mp3', 'a-broken-washing-machine/6-kirja-fb073e6d8efa.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Milloin', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'kirja', 3, 'hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'voi', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'kirja', 5, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Millon', (select id from public.forms where lemma = 'milloin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'milloin' and surface_puhe = 'millon')),
    (v_line_id, 'puhe', 3, 'se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'voi', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'voi' and surface_puhe = 'voi')),
    (v_line_id, 'puhe', 5, 'tulla', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'tulla' and surface_puhe = 'tulla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Juho', 'Torstaina aamupäiväl. Sopiiks se?',
    'Torstaina aamupäivällä. Sopiiko se?', 'On Thursday morning. Does that suit you?',
    'a-broken-washing-machine/7-puhe-5ebe99b19549.mp3', 'a-broken-washing-machine/7-kirja-bbcdc1b3de02.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Torstaina', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina')),
    (v_line_id, 'kirja', 2, 'aamupäivällä', (select id from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl')),
    (v_line_id, 'kirja', 3, 'Sopiiko', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'kirja', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 1, 'Torstaina', (select id from public.forms where lemma = 'torstai' and form_tag = 'CLASS=nimisana;SIJAMUOTO=olento;NUMBER=singular' and surface_kirja = 'torstaina' and surface_puhe = 'torstaina')),
    (v_line_id, 'puhe', 2, 'aamupäiväl', (select id from public.forms where lemma = 'aamupäivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'aamupäivällä' and surface_puhe = 'aamupäiväl')),
    (v_line_id, 'puhe', 3, 'Sopiiks', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'sopiiko' and surface_puhe = 'sopiiks')),
    (v_line_id, 'puhe', 4, 'se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Maria', 'Sopii. Kiitti avusta!',
    'Sopii. Kiitos avusta!', 'That''s fine. Thanks for the help!',
    'a-broken-washing-machine/8-puhe-7cdc8ce297e0.mp3', 'a-broken-washing-machine/8-kirja-09dabf163fb8.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'kirja', 2, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 3, 'avusta', (select id from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta')),
    (v_line_id, 'puhe', 1, 'Sopii', (select id from public.forms where lemma = 'sopia' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sopii' and surface_puhe = 'sopii')),
    (v_line_id, 'puhe', 2, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 3, 'avusta', (select id from public.forms where lemma = 'apu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'avusta' and surface_puhe = 'avusta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-6.json#a-broken-washing-machine/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
