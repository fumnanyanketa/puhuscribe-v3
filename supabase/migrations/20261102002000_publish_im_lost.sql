-- Publishes the dialogue im-lost (unit asking-for-help). Made by
-- scripts/generate/pipeline.py publish from content/drafts/im-lost. Do not edit by hand:
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
    where slug = 'im-lost' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'im-lost';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 7
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'asking-for-help' and position = 7 and stop_number = 7;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'asking-for-help';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'im-lost', 3,
    'I''m lost')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'im-lost' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'I''m lost';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'im-lost';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('anteeksi', 'CLASS=seikkasana', '{"BASEFORM":"anteeksi","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]anteeksi[X]anteeksi","STRUCTURE":"=pppppppp","WORDBASES":"+anteeksi(anteeksi)"}'::jsonb,
      'anteeksi', 'anteeks',
      'adverb', 'Speech drops the final i: anteeksi becomes anteeks.', 'excuse me', 'sorry, excuse me', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-91a5cf1932b7');
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
  if not exists (select 1 from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('voida', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"voida","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]voida[X]voi[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]ko","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+voida(voida)"}'::jsonb,
      'voitko', 'voit',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Voit with -ko asks ''can you?'': voitko. Speech drops -ko and adds sä: voitsä.', 'can you?', 'can, to be able to', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-90c207b76ecc');
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
  if not exists (select 1 from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sinä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"sinä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]sinä[X]sin[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+sinä(sinä)"}'::jsonb,
      'sinä', 'sä',
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('auttaa', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"auttaa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]auttaa[X]autta[Tn1][Eb]a","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+auttaa(auttaa)"}'::jsonb,
      'auttaa', 'auttaa',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to help', 'to help', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-b4a17f5a61be');
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
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P1][Ny][Ef]len","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olen', 'oon',
      'present tense, 1st person singular', 'Speech drops the l and stretches the vowel: olen becomes oon. Books write olen. From olla, to be.', 'I am', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-7588912c8134');
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
  if not exists (select 1 from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('eksyksissä', 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"eksyksissä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]eksyksissä[X]eksyksi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=pppppppppp","WORDBASES":"+eksyksissä(eksyksissä)"}'::jsonb,
      'eksyksissä', 'eksyksissä',
      'inessive singular', 'Eksyksissä means lost. Olen eksyksissä is I am lost.', 'lost', 'lost', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-f1ca3186b4ae');
  end if;
  if not exists (select 1 from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'eksyksissä', 'eksyksissä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Eksyksissä means lost. Olen eksyksissä is I am lost.', 'lost', 'lost')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'eksyksissä', 'eksyksissä',
      (select form_name_en from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä'),
      (select why_en from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä'),
      (select meaning_en from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä'),
      (select lemma_meaning_en from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä'),
      'inessive singular', 'Eksyksissä means lost. Olen eksyksissä is I am lost.', 'lost', 'lost';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tosi', 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"tosi","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]tosi[X]to[Sp][Ny]tta","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+tosi(tosi)"}'::jsonb,
      'totta', 'totta',
      'partitive singular', 'From tosi, true. Totta kai means of course.', 'of course (with kai)', 'really, true', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-b20bd263b5ae');
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
      'adverb', 'This is the dictionary form. People say it the same way.', 'probably (totta kai, of course)', 'probably (totta kai, of course)', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-b1285c45ffe6');
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
      'illative singular', 'Mikä with -hin for ''to'': mihin, where to.', 'where to', 'what, which', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-f42052a3d5f2');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P2][Ny][Ef]let","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'olet', 'oot',
      'present tense, 2nd person singular', 'Speech drops the l and stretches the vowel: olet becomes oot. Books write olet. From olla, to be.', 'you are', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-160976249e4f');
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
  if not exists (select 1 from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('meno', 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"meno","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]meno[X]meno[Sine][Ny]ssa","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppppp","WORDBASES":"+meno(meno)"}'::jsonb,
      'menossa', 'menossa',
      'inessive singular', 'Olla menossa means to be on the way somewhere.', 'going', 'going', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-ec92b4edb183');
  end if;
  if not exists (select 1 from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menossa', 'meno';
  end if;
  if not exists (select 1 from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('inessive singular', 'Olla menossa means to be on the way somewhere.', 'going', 'going')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menossa', 'meno',
      (select form_name_en from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa'),
      (select why_en from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa'),
      (select meaning_en from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa'),
      (select lemma_meaning_en from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa'),
      'inessive singular', 'Olla menossa means to be on the way somewhere.', 'going', 'going';
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('rautatieasema', 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"rautatieasema","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]rauta[X]raut[Sn][Ny]a[Bh][Bc][Ln][Ica][Xp]tie[X]tie[Sn][Ny][Bh][Bc][Ln][Xp]asema[X]asema[Sall][Ny]lle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppp=ppp=pppppppp","WORDBASES":"+rauta(rauta)+tie(tie)+asema(asema)"}'::jsonb,
      'rautatieasemalle', 'rautatieasemalle',
      'allative singular', 'Rautatieasema with -lle for ''to'': rautatieasemalle.', 'to the railway station', 'railway station', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-4b19ea4b7d80');
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'rautatieasemalle', 'rautatieasema';
  end if;
  if not exists (select 1 from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Rautatieasema with -lle for ''to'': rautatieasemalle.', 'to the railway station', 'railway station')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'rautatieasemalle', 'rautatieasema',
      (select form_name_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle'),
      (select why_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle'),
      (select meaning_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle'),
      (select lemma_meaning_en from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle'),
      'allative singular', 'Rautatieasema with -lle for ''to'': rautatieasemalle.', 'to the railway station', 'railway station';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P1][Ny]n","MOOD":"indicative","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'en', 'en',
      'negative verb, 1st person singular', 'Ei with -n for ''I'': en, I do not.', 'I don''t', 'no, not', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-e12332115711');
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
  if not exists (select 1 from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('löytää', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"löytää","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'löydä', 'löydä',
      'present tense, negative form', 'After en the verb drops its ending: löytää becomes löydä, and the tt softens to d.', 'find (I can''t find)', 'to find', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-ca7890368f48');
  end if;
  if not exists (select 1 from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'löydä', 'löytää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: löytää becomes löydä, and the tt softens to d.', 'find (I can''t find)', 'to find')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'löydä', 'löytää',
      (select form_name_en from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä'),
      (select why_en from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä'),
      (select meaning_en from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä'),
      (select lemma_meaning_en from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä'),
      'present tense, negative form', 'After en the verb drops its ending: löytää becomes löydä, and the tt softens to d.', 'find (I can''t find)', 'to find';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sp][Ny]itä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+se(se)"}'::jsonb,
      'sitä', 'sitä',
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-c039ed256b06');
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sitä', 'se';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sitä', 'se',
      (select form_name_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select why_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      (select lemma_meaning_en from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'),
      'partitive singular', 'The partitive of se after en löydä: en löydä sitä.', 'it', 'it, that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sn][Ny]e","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pp","WORDBASES":"+se(se)"}'::jsonb,
      'se', 'se',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'it, that', 'it, that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-eca33913649c');
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
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ap][P3][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","TENSE":"present_simple","WORDBASES":"+olla(olla)"}'::jsonb,
      'on', 'on',
      'present tense, 3rd person singular', 'The form of olla, to be, for he, she or it. People say it the same way.', 'is', 'to be, to have', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-24c73cc721d6');
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
      'inessive singular', 'Tuo, that, with -ssa: tuossa, there. Speech says tos.', 'there', 'that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-8e6317edf047');
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
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähellä', 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"lähellä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]lähellä[X]lähe[Sade][Ny]llä","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=ppppppp","WORDBASES":"+lähellä(lähellä)"}'::jsonb,
      'lähellä', 'lähellä',
      'adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-fa873628ac0d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähellä', 'lähellä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähellä', 'lähellä',
      (select form_name_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select why_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select meaning_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      (select lemma_meaning_en from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä'),
      'adessive singular', 'Lähellä means near or close by.', 'close by', 'near, close by';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]näe[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppp","TENSE":"present_simple","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'näetkö', 'näät',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Näätsä, speech says näät for näet and joins sä. Books write näetkö sinä.', 'do you see?', 'to see', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-031b8a5362c1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näetkö', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'In Näätsä, speech says näät for näet and joins sä. Books write näetkö sinä.', 'do you see?', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näetkö', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'In Näätsä, speech says näät for näet and joins sä. Books write näetkö sinä.', 'do you see?', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuon', 'ton',
      'genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-e5b38e62bbf5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuon', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuon', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton'),
      'genitive singular', 'Tuo, that, takes -n with the thing you see: tuon. Speech shortens tuon to ton.', 'that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('iso', 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"iso","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][De][Xp]iso[X]iso[Sg][Ny]n","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=pppp","WORDBASES":"+iso(iso)"}'::jsonb,
      'ison', 'ison',
      'genitive singular', 'Iso with -n to match kellotornin: ison kellotornin.', 'big', 'big', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-b1845f63e302');
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ison', 'iso';
  end if;
  if not exists (select 1 from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Iso with -n to match kellotornin: ison kellotornin.', 'big', 'big')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ison', 'iso',
      (select form_name_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison'),
      (select why_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison'),
      (select meaning_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison'),
      (select lemma_meaning_en from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison'),
      'genitive singular', 'Iso with -n to match kellotornin: ison kellotornin.', 'big', 'big';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kellotorni', 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"kellotorni","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kello[X]kello[Sn][Ny][Bh][Bc][Ln][Xp]torni[X]torn[Sg][Ny]in","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp=pppppp","WORDBASES":"+kello(kello)+torni(torni)"}'::jsonb,
      'kellotornin', 'kellotornin',
      'genitive singular', 'Kellotorni with -n as the whole thing you see: kellotornin.', 'clock tower', 'clock tower', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-d6d93435a350');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kellotornin', 'kellotorni';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('genitive singular', 'Kellotorni with -n as the whole thing you see: kellotornin.', 'clock tower', 'clock tower')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kellotornin', 'kellotorni',
      (select form_name_en from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin'),
      (select why_en from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin'),
      (select meaning_en from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin'),
      (select lemma_meaning_en from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin'),
      'genitive singular', 'Kellotorni with -n as the whole thing you see: kellotornin.', 'clock tower', 'clock tower';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"nähdä","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'näe', 'nää',
      'present tense, negative form', 'After en the verb drops its ending: nähdä becomes näe. Speech says nää.', 'see (I don''t see)', 'to see', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-ab0c9577d9da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näe', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'After en the verb drops its ending: nähdä becomes näe. Speech says nää.', 'see (I don''t see)', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näe', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää'),
      'present tense, negative form', 'After en the verb drops its ending: nähdä becomes näe. Speech says nää.', 'see (I don''t see)', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mikä', 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular', '{"BASEFORM":"mikä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]mikä[X]mi[Sine][Ny]ssä","NUMBER":"singular","SIJAMUOTO":"sisaolento","STRUCTURE":"=ppppp","WORDBASES":"+mikä(mikä)"}'::jsonb,
      'missä', 'missä',
      'inessive singular', 'Mikä with -ssä for ''in'': missä, where.', 'where', 'what, which', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-58f467b0bcb4');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuolla', 'tuolla',
      'adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-38dbd7729054');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuolla', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuolla', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla'),
      'adessive singular', 'Tuo, that, with -lla: tuolla, over there.', 'over there', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('vasen', 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"vasen","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]vasen[X]vasemma[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppppppppp","WORDBASES":"+vasen(vasen)"}'::jsonb,
      'vasemmalla', 'vasemmalla',
      'adessive singular', 'Vasen, left, with -lla for ''on'': vasemmalla. The n turns to mm before the ending.', 'on the left', 'left', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-816e0bada9e3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'vasemmalla', 'vasen';
  end if;
  if not exists (select 1 from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Vasen, left, with -lla for ''on'': vasemmalla. The n turns to mm before the ending.', 'on the left', 'left')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'vasemmalla', 'vasen',
      (select form_name_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla'),
      (select why_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla'),
      (select meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla'),
      (select lemma_meaning_en from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla'),
      'adessive singular', 'Vasen, left, with -lla for ''on'': vasemmalla. The n turns to mm before the ending.', 'on the left', 'left';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('asema', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"asema","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]asema[X]asem[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+asema(asema)"}'::jsonb,
      'asema', 'asema',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'station', 'station', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-e428a6e5422b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'asema', 'asema';
  end if;
  if not exists (select 1 from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'station', 'station')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'asema', 'asema',
      (select form_name_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema'),
      (select why_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema'),
      (select meaning_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema'),
      (select lemma_meaning_en from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'station', 'station';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('juuri', 'CLASS=seikkasana', '{"BASEFORM":"juuri","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]juuri[X]juuri","STRUCTURE":"=ppppp","WORDBASES":"+juuri(juuri)"}'::jsonb,
      'juuri', 'just',
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-57dd552fb07a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'juuri', 'juuri';
  end if;
  if not exists (select 1 from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'juuri', 'juuri',
      (select form_name_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select why_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      (select lemma_meaning_en from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just'),
      'adverb', 'Books write juuri. In speech people say just instead.', 'right, just', 'just, right, exactly';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('alla', 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular', '{"BASEFORM":"alla","CLASS":"suhdesana","FSTOUTPUT":"[Ld][Xp]alla[X]a[Sade][Ny]lla","NUMBER":"singular","SIJAMUOTO":"ulkoolento","STRUCTURE":"=pppp","WORDBASES":"+alla(alla)"}'::jsonb,
      'alla', 'alla',
      'adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-3d6e3309dd97');
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'alla', 'alla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'alla', 'alla',
      (select form_name_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select why_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      (select lemma_meaning_en from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'),
      'adessive singular', 'Alla means under and comes after its word: sen alla.', 'under', 'under, below';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ai', 'CLASS=huudahdussana', '{"BASEFORM":"ai","CLASS":"huudahdussana","FSTOUTPUT":"[Lh][Xp]ai[X]ai","STRUCTURE":"=pp","WORDBASES":"+ai(ai)"}'::jsonb,
      'ai', 'ai',
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-2ab0015782b0');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ai', 'ai';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ai', 'ai',
      (select form_name_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select why_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      (select lemma_meaning_en from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai'),
      'interjection', 'This is the dictionary form. People say it the same way.', 'oh', 'oh';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nyt', 'CLASS=seikkasana', '{"BASEFORM":"nyt","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]nyt[X]nyt","STRUCTURE":"=ppp","WORDBASES":"+nyt(nyt)"}'::jsonb,
      'nyt', 'nyt',
      'adverb', 'This is the dictionary form. People say it the same way.', 'now', 'now', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-00cf76bd38f0');
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
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('nähdä', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"nähdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]nähdä[X]näe[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+nähdä(nähdä)"}'::jsonb,
      'näen', 'nään',
      'present tense, 1st person singular', 'Nähdä, to see, with -n for ''I'': näen. Speech says nään.', 'I see', 'to see', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-779d1cf61fb5');
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'näen', 'nähdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Nähdä, to see, with -n for ''I'': näen. Speech says nään.', 'I see', 'to see')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'näen', 'nähdä',
      (select form_name_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään'),
      (select why_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään'),
      (select meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään'),
      (select lemma_meaning_en from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään'),
      'present tense, 1st person singular', 'Nähdä, to see, with -n for ''I'': näen. Speech says nään.', 'I see', 'to see';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ei', 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative', '{"BASEFORM":"ei","CLASS":"kieltosana","FSTOUTPUT":"[Lk][Tt][Xp]ei[X]e[P3][Ny]i","MOOD":"indicative","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pp","WORDBASES":"+ei(ei)"}'::jsonb,
      'ei', 'ei',
      'negative verb, 3rd person singular', 'Ei on its own answers ''no''. People say it the same way.', 'no', 'no, not', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-4752d8dd4e2d');
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
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kestää', 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true', '{"BASEFORM":"kestää","CLASS":"teonsana","MANUAL":"true","MOOD":"indicative","NEGATIVE":"true","TENSE":"present_simple"}'::jsonb,
      'kestä', 'mitään',
      'present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-6eb46dbcfd77');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kestä', 'kestää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kestä', 'kestää',
      (select form_name_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select why_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      (select lemma_meaning_en from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään'),
      'present tense, negative form', 'Ei kestä is the polite reply to thanks. In speech people often say ei mitään, ''nothing'', instead.', 'you''re welcome (literally: it does not last)', 'to last, to take (time)';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvää', 'hyvää',
      'partitive singular', 'The partitive of hyvä, used in wishes like hyvää päivää.', 'good', 'good', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-0c7a01723f10');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hyvää', 'hyvä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'The partitive of hyvä, used in wishes like hyvää päivää.', 'good', 'good')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hyvää', 'hyvä',
      (select form_name_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää'),
      (select why_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää'),
      (select meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää'),
      (select lemma_meaning_en from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää'),
      'partitive singular', 'The partitive of hyvä, used in wishes like hyvää päivää.', 'good', 'good';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päivä', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"päivä","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]päivä[X]päiv[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppppp","WORDBASES":"+päivä(päivä)"}'::jsonb,
      'päivää', 'päivää',
      'partitive singular', 'The partitive of päivä, used in wishes like hyvää päivää.', 'day', 'day', 'approved', now(), 'content/approvals/part-2.json#im-lost/form-09fea05a79c1');
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

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Anteeks, voitsä auttaa? Mä oon eksyksissä.',
    'Anteeksi, voitko sinä auttaa? Minä olen eksyksissä.', 'Excuse me, can you help? I''m lost.',
    'im-lost/1-puhe-c271ae0d8cf0.mp3', 'im-lost/1-kirja-99767f59d2b6.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Anteeksi', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'kirja', 2, 'voitko', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'kirja', 5, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 6, 'olen', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'kirja', 7, 'eksyksissä', (select id from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä')),
    (v_line_id, 'puhe', 1, 'Anteeks', (select id from public.forms where lemma = 'anteeksi' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'anteeksi' and surface_puhe = 'anteeks')),
    (v_line_id, 'puhe', 2, 'voit', (select id from public.forms where lemma = 'voida' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'voitko' and surface_puhe = 'voit')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'auttaa', (select id from public.forms where lemma = 'auttaa' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'auttaa' and surface_puhe = 'auttaa')),
    (v_line_id, 'puhe', 5, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 6, 'oon', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olen' and surface_puhe = 'oon')),
    (v_line_id, 'puhe', 7, 'eksyksissä', (select id from public.forms where lemma = 'eksyksissä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'eksyksissä' and surface_puhe = 'eksyksissä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Tuomas', 'Totta kai. Mihin sä oot menossa?',
    'Totta kai. Mihin sinä olet menossa?', 'Of course. Where are you going?',
    'im-lost/2-puhe-90480df044d3.mp3', 'im-lost/2-kirja-2d4d4fb4c366.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'kirja', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'kirja', 3, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'kirja', 4, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 5, 'olet', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'kirja', 6, 'menossa', (select id from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa')),
    (v_line_id, 'puhe', 1, 'Totta', (select id from public.forms where lemma = 'tosi' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'totta' and surface_puhe = 'totta')),
    (v_line_id, 'puhe', 2, 'kai', (select id from public.forms where lemma = 'kai' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kai' and surface_puhe = 'kai')),
    (v_line_id, 'puhe', 3, 'Mihin', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'mihin' and surface_puhe = 'mihin')),
    (v_line_id, 'puhe', 4, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 5, 'oot', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'olet' and surface_puhe = 'oot')),
    (v_line_id, 'puhe', 6, 'menossa', (select id from public.forms where lemma = 'meno' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'menossa' and surface_puhe = 'menossa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Rautatieasemalle. Mä en löydä sitä.',
    'Rautatieasemalle. Minä en löydä sitä.', 'To the railway station. I can''t find it.',
    'im-lost/3-puhe-8574a3fefba0.mp3', 'im-lost/3-kirja-37af75a51ad7.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Rautatieasemalle', (select id from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle')),
    (v_line_id, 'kirja', 2, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 4, 'löydä', (select id from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä')),
    (v_line_id, 'kirja', 5, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä')),
    (v_line_id, 'puhe', 1, 'Rautatieasemalle', (select id from public.forms where lemma = 'rautatieasema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'rautatieasemalle' and surface_puhe = 'rautatieasemalle')),
    (v_line_id, 'puhe', 2, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 3, 'en', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 4, 'löydä', (select id from public.forms where lemma = 'löytää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'löydä' and surface_puhe = 'löydä')),
    (v_line_id, 'puhe', 5, 'sitä', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'sitä' and surface_puhe = 'sitä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Tuomas', 'Se on tos lähellä. Näätsä ton ison kellotornin?',
    'Se on tuossa lähellä. Näetkö sinä tuon ison kellotornin?', 'It''s close by. Do you see that big clock tower?',
    'im-lost/4-puhe-13e52a4ccf93.mp3', 'im-lost/4-kirja-09e73e164e95.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 3, 'tuossa', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos')),
    (v_line_id, 'kirja', 4, 'lähellä', (select id from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä')),
    (v_line_id, 'kirja', 5, 'Näetkö', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät')),
    (v_line_id, 'kirja', 6, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 7, 'tuon', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton')),
    (v_line_id, 'kirja', 8, 'ison', (select id from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison')),
    (v_line_id, 'kirja', 9, 'kellotornin', (select id from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin')),
    (v_line_id, 'puhe', 1, 'Se', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'se' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 2, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 3, 'tos', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'tuossa' and surface_puhe = 'tos')),
    (v_line_id, 'puhe', 4, 'lähellä', (select id from public.forms where lemma = 'lähellä' and form_tag = 'CLASS=seikkasana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'lähellä' and surface_puhe = 'lähellä')),
    (v_line_id, 'puhe', 5, 'Näät', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'näetkö' and surface_puhe = 'näät')),
    (v_line_id, 'puhe', 6, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 7, 'ton', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'tuon' and surface_puhe = 'ton')),
    (v_line_id, 'puhe', 8, 'ison', (select id from public.forms where lemma = 'iso' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=omanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'ison' and surface_puhe = 'ison')),
    (v_line_id, 'puhe', 9, 'kellotornin', (select id from public.forms where lemma = 'kellotorni' and form_tag = 'CLASS=nimisana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'kellotornin' and surface_puhe = 'kellotornin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'En nää. Missä?',
    'En näe. Missä?', 'I don''t see it. Where?',
    'im-lost/5-puhe-05325f5818ac.mp3', 'im-lost/5-kirja-9ea221523a91.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'kirja', 2, 'näe', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää')),
    (v_line_id, 'kirja', 3, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä')),
    (v_line_id, 'puhe', 1, 'En', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=1;MOOD=indicative' and surface_kirja = 'en' and surface_puhe = 'en')),
    (v_line_id, 'puhe', 2, 'nää', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'näe' and surface_puhe = 'nää')),
    (v_line_id, 'puhe', 3, 'Missä', (select id from public.forms where lemma = 'mikä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaolento;NUMBER=singular' and surface_kirja = 'missä' and surface_puhe = 'missä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Tuomas', 'Tuolla vasemmalla. Asema on just sen alla.',
    'Tuolla vasemmalla. Asema on juuri sen alla.', 'Over there on the left. The station is right below it.',
    'im-lost/6-puhe-87948366391e.mp3', 'im-lost/6-kirja-3cd298022ea1.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'kirja', 2, 'vasemmalla', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla')),
    (v_line_id, 'kirja', 3, 'Asema', (select id from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema')),
    (v_line_id, 'kirja', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'kirja', 5, 'juuri', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'kirja', 6, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 7, 'alla', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla')),
    (v_line_id, 'puhe', 1, 'Tuolla', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'tuolla' and surface_puhe = 'tuolla')),
    (v_line_id, 'puhe', 2, 'vasemmalla', (select id from public.forms where lemma = 'vasen' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=ulkoolento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'vasemmalla' and surface_puhe = 'vasemmalla')),
    (v_line_id, 'puhe', 3, 'Asema', (select id from public.forms where lemma = 'asema' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'asema' and surface_puhe = 'asema')),
    (v_line_id, 'puhe', 4, 'on', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'on' and surface_puhe = 'on')),
    (v_line_id, 'puhe', 5, 'just', (select id from public.forms where lemma = 'juuri' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'juuri' and surface_puhe = 'just')),
    (v_line_id, 'puhe', 6, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 7, 'alla', (select id from public.forms where lemma = 'alla' and form_tag = 'CLASS=suhdesana;SIJAMUOTO=ulkoolento;NUMBER=singular' and surface_kirja = 'alla' and surface_puhe = 'alla'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Ai, nyt mä nään! Kiitti!',
    'Ai, nyt minä näen! Kiitos!', 'Oh, now I see it! Thanks!',
    'im-lost/7-puhe-5bf2670388fc.mp3', 'im-lost/7-kirja-a9ca3a53103a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'kirja', 2, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'kirja', 3, 'minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 4, 'näen', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään')),
    (v_line_id, 'kirja', 5, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 1, 'Ai', (select id from public.forms where lemma = 'ai' and form_tag = 'CLASS=huudahdussana' and surface_kirja = 'ai' and surface_puhe = 'ai')),
    (v_line_id, 'puhe', 2, 'nyt', (select id from public.forms where lemma = 'nyt' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'nyt' and surface_puhe = 'nyt')),
    (v_line_id, 'puhe', 3, 'mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 4, 'nään', (select id from public.forms where lemma = 'nähdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'näen' and surface_puhe = 'nään')),
    (v_line_id, 'puhe', 5, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Tuomas', 'Ei mitään. Hyvää päivää!',
    'Ei kestä. Hyvää päivää!', 'You''re welcome. Have a nice day!',
    'im-lost/8-puhe-0528fc21e4b3.mp3', 'im-lost/8-kirja-b66903852b78.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'kirja', 2, 'kestä', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään')),
    (v_line_id, 'kirja', 3, 'Hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'kirja', 4, 'päivää', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää')),
    (v_line_id, 'puhe', 1, 'Ei', (select id from public.forms where lemma = 'ei' and form_tag = 'CLASS=kieltosana;NUMBER=singular;PERSON=3;MOOD=indicative' and surface_kirja = 'ei' and surface_puhe = 'ei')),
    (v_line_id, 'puhe', 2, 'mitään', (select id from public.forms where lemma = 'kestää' and form_tag = 'CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true' and surface_kirja = 'kestä' and surface_puhe = 'mitään')),
    (v_line_id, 'puhe', 3, 'Hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'puhe', 4, 'päivää', (select id from public.forms where lemma = 'päivä' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'päivää' and surface_puhe = 'päivää'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-2.json#im-lost/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-2.json#im-lost/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
