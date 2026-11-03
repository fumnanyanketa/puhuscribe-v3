-- Publishes the dialogue leaving-the-party (unit invitations-and-celebrations). Made by
-- scripts/generate/pipeline.py publish from content/drafts/leaving-the-party. Do not edit by hand:
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
    where slug = 'leaving-the-party' and status = 'approved') then
    raise notice 'dialogue % is already published; nothing to do', 'leaving-the-party';
    return;
  end if;

  -- The unit, as a draft until the end.
  insert into public.units (slug, position, title_en, can_do_en, stop_number)
  select s.slug, s.number, s.name_en, s.can_do_en, s.number from public.road_stops s
  where s.number = 30
  on conflict (slug) do nothing;
  select id, status into strict v_unit_id, v_status from public.units
  where slug = 'invitations-and-celebrations' and position = 30 and stop_number = 30;
  if v_status = 'retired' then
    raise exception 'unit % is retired', 'invitations-and-celebrations';
  end if;

  -- The dialogue, as a draft until its lines are approved.
  insert into public.dialogues (unit_id, slug, position, title_en)
  values (v_unit_id, 'leaving-the-party', 3,
    'Leaving the party')
  on conflict (slug) do nothing;
  select id into strict v_dialogue_id from public.dialogues
  where slug = 'leaving-the-party' and unit_id = v_unit_id and status = 'draft'
    and position = 3 and title_en = 'Leaving the party';
  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then
    raise exception 'dialogue % already has lines; fix them through the review rounds',
      'leaving-the-party';
  end if;

  -- 1. Forms, approved. An existing form must already be approved.
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sg][Ny]un","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minun', 'mun',
      'genitive singular', 'Minä with -n: minun pitää means I have to. Speech shortens it to mun.', 'I (have to)', 'I, me', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-ae1caa07874f');
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
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pitää', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"pitää","CLASS":"teonsana","FSTOUTPUT":"[Lt][Ira][Xp]pitää[X]pitä[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","REQUIRE_FOLLOWING_VERB":"A-infinitive","STRUCTURE":"=ppppp","WORDBASES":"+pitää(pitää)"}'::jsonb,
      'pitää', 'pitää',
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-7aba8e0c1b63');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pitää', 'pitää';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pitää', 'pitää',
      (select form_name_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select why_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      (select lemma_meaning_en from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää'),
      'basic form (A-infinitive)', 'This is the dictionary form. People say it the same way.', 'to have to, to like, to hold', 'to have to, to like, to hold';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('lähteä', 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both', '{"BASEFORM":"lähteä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]lähteä[X]lähte[Tn1][Eb]ä","MOOD":"A-infinitive","NEGATIVE":"both","STRUCTURE":"=pppppp","WORDBASES":"+lähteä(lähteä)"}'::jsonb,
      'lähteä', 'lähtee',
      'basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''have to''. Speech turns the ending -eä into -ee.', 'to leave', 'to leave, to go', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-7ecce5fcf810');
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'lähteä', 'lähteä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''have to''. Speech turns the ending -eä into -ee.', 'to leave', 'to leave, to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'lähteä', 'lähteä',
      (select form_name_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee'),
      (select why_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee'),
      (select meaning_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee'),
      (select lemma_meaning_en from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee'),
      'basic form (A-infinitive)', 'This is the dictionary form, used after pitää, ''have to''. Speech turns the ending -eä into -ee.', 'to leave', 'to leave, to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitti',
      'nominative singular', 'Kiitti is the everyday spoken thanks. Books write kiitos.', 'thank you', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-35b130e20e20');
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
  if not exists (select 1 from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('todella', 'CLASS=seikkasana', '{"BASEFORM":"todella","CLASS":"seikkasana","MANUAL":"true"}'::jsonb,
      'todella', 'tosi',
      'adverb', 'Books write todella. In speech people use tosi, ''really'', instead.', 'really', 'really', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-26f45640039d');
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
  if not exists (select 1 from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mukava', 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"mukava","CLASS":"nimisana_laatusana","COMPARISON":"positive","FSTOUTPUT":"[Lnl][Xp]mukava[X]mukava[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppppp","WORDBASES":"+mukava(mukava)"}'::jsonb,
      'mukavasta', 'kivast',
      'elative singular', 'Thanking takes -sta. Books write mukavasta. Speech uses another word, kiva, and says kivast.', 'lovely', 'nice, pleasant', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-79f62220c93d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'mukavasta', 'mukava';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Thanking takes -sta. Books write mukavasta. Speech uses another word, kiva, and says kivast.', 'lovely', 'nice, pleasant')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'mukavasta', 'mukava',
      (select form_name_en from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast'),
      (select why_en from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast'),
      (select meaning_en from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast'),
      (select lemma_meaning_en from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast'),
      'elative singular', 'Thanking takes -sta. Books write mukavasta. Speech uses another word, kiva, and says kivast.', 'lovely', 'nice, pleasant';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ilta', 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"ilta","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ilta[X]illa[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=ppppppp","WORDBASES":"+ilta(ilta)"}'::jsonb,
      'illasta', 'illast',
      'elative singular', 'Thanking takes -sta: ilta becomes illasta, lt turning into ll. Speech says illast.', 'for the evening', 'evening', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-eeb17ffd1b1c');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'illasta', 'ilta';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Thanking takes -sta: ilta becomes illasta, lt turning into ll. Speech says illast.', 'for the evening', 'evening')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'illasta', 'ilta',
      (select form_name_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast'),
      (select why_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast'),
      (select meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast'),
      (select lemma_meaning_en from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast'),
      'elative singular', 'Thanking takes -sta: ilta becomes illasta, lt turning into ll. Speech says illast.', 'for the evening', 'evening';
  end if;
  if not exists (select 1 from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('että', 'CLASS=sidesana', '{"BASEFORM":"että","CLASS":"sidesana","FSTOUTPUT":"[Lc][Xp]että[X]että","STRUCTURE":"=pppp","WORDBASES":"+että(että)"}'::jsonb,
      'että', 'et',
      'conjunction', 'Speech shortens että to et. Books write että.', 'that', 'that', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-4eeca18a865d');
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
      'nominative singular', 'Speech shortens sinä to sä. Books write sinä.', 'you', 'you (one person)', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-ec7b2eab227a');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P2][Ny][Ef]it","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=ppppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tulit', 'tulit',
      'past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-e3858e4b70af');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tulit', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tulit', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'),
      'past tense, 2nd person singular', 'Adds -i for something that already happened, then -t for ''you'': tulit.', 'you came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('ruoka', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"ruoka","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]ruoka[X]ruok[Sn][Ny]a","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppppp","WORDBASES":"+ruoka(ruoka)"}'::jsonb,
      'ruoka', 'ruoka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'food, meal', 'food, meal', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-07958fc6f22a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'ruoka', 'ruoka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'food, meal', 'food, meal')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'ruoka', 'ruoka',
      (select form_name_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka'),
      (select why_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka'),
      (select meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka'),
      (select lemma_meaning_en from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'food, meal', 'food, meal';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('olla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"olla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]olla[X]o[Tt][Ai][P3][Ny][Ef]li","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppp","TENSE":"past_imperfective","WORDBASES":"+olla(olla)"}'::jsonb,
      'oli', 'oli',
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-272accd9b290');
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'oli', 'olla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'oli', 'olla',
      (select form_name_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select why_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      (select lemma_meaning_en from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli'),
      'past tense, 3rd person singular', 'Olla, to be, in the past tense for he, she or it: oli.', 'it was', 'to be, to have';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sp][Ny]ää","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=ppppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvää', 'hyvää',
      'partitive singular', 'The partitive of hyvä, used in wishes like hyvää päivää.', 'good', 'good', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-0c7a01723f10');
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
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kuka', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kuka","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]kuka[X]ku[Sn][Ny]ka","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+kuka(kuka)"}'::jsonb,
      'kuka', 'kuka',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-3050a6672faf');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kuka', 'kuka';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kuka', 'kuka',
      (select form_name_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select why_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      (select lemma_meaning_en from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'who', 'who';
  end if;
  if not exists (select 1 from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('se', 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular', '{"BASEFORM":"se","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]se[X]s[Sg][Ny]en","NUMBER":"singular","SIJAMUOTO":"omanto","STRUCTURE":"=ppp","WORDBASES":"+se(se)"}'::jsonb,
      'sen', 'sen',
      'genitive singular', 'Se with -n when the whole thing is the object: kirjoittaa sen.', 'it', 'it, that', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-1bca14269daf');
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
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tehdä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tehdä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tehdä[X]tek[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+tehdä(tehdä)"}'::jsonb,
      'teki', 'teki',
      'past tense, 3rd person singular', 'Tehdä means to make. In the past, for ''he'' or ''she'', it becomes teki.', 'made', 'to do, to make', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-8fc7839ed65f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'teki', 'tehdä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Tehdä means to make. In the past, for ''he'' or ''she'', it becomes teki.', 'made', 'to do, to make')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'teki', 'tehdä',
      (select form_name_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki'),
      (select why_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki'),
      (select meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki'),
      (select lemma_meaning_en from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki'),
      'past tense, 3rd person singular', 'Tehdä means to make. In the past, for ''he'' or ''she'', it becomes teki.', 'made', 'to do, to make';
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('äiti', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s', '{"BASEFORM":"äiti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]äiti[X]äit[Sn][Ny]i[O1y]ni","NUMBER":"singular","POSSESSIVE":"1s","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+äiti(äiti)"}'::jsonb,
      'äitini', 'äiti',
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-fcdb40051581');
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'äitini', 'äiti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'äitini', 'äiti',
      (select form_name_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select why_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      (select lemma_meaning_en from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti'),
      'nominative singular, with the possessive ending for my', 'Books add -ni for ''my'': äitini. Speech drops it and says mun äiti.', 'my mother', 'mother';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sn][Ny]n","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=ppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hän', 'se',
      'nominative singular', 'Speech uses se for a person. Books write hän.', 'he, she', 'he, she', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-d5b687de866a');
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
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tulla', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false', '{"BASEFORM":"tulla","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]tulla[X]tul[Tt][Ai][P3][Ny][Ef]i","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=pppp","TENSE":"past_imperfective","WORDBASES":"+tulla(tulla)"}'::jsonb,
      'tuli', 'tuli',
      'past tense, 3rd person singular', 'Tulla means to come. -i marks the past: tuli, ''she came''.', 'came', 'to come', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-01430b9259ed');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuli', 'tulla';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('past tense, 3rd person singular', 'Tulla means to come. -i marks the past: tuli, ''she came''.', 'came', 'to come')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuli', 'tulla',
      (select form_name_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli'),
      (select why_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli'),
      (select meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli'),
      (select lemma_meaning_en from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli'),
      'past tense, 3rd person singular', 'Tulla means to come. -i marks the past: tuli, ''she came''.', 'came', 'to come';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('käydä', 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive', '{"BASEFORM":"käydä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]käydä[X]käy[Tn3][Ny][Sill]mään","MOOD":"MA-infinitive","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=ppppppp","WORDBASES":"+käydä(käydä)"}'::jsonb,
      'käymään', 'käymään',
      'MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-5947e1f56514');
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'käymään', 'käydä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'käymään', 'käydä',
      (select form_name_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select why_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      (select lemma_meaning_en from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'),
      'MA-infinitive, illative', 'Käydä takes -mään after tulla (to come): tulla käymään means ''to come and visit''.', 'to visit', 'to visit, to go, to be OK';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sanoa', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both', '{"BASEFORM":"sanoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sanoa[X]sano[Tk][Ap][P2][Ny][Eb]","MOOD":"imperative","NEGATIVE":"both","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppp","TENSE":"present_simple","WORDBASES":"+sanoa(sanoa)"}'::jsonb,
      'sano', 'sano',
      'imperative present tense, 2nd person singular', 'Sanoa means to say. Dropping the last -a gives sano, telling someone to say it.', 'tell', 'to say, to tell', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-a9b62b940415');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sano', 'sanoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('imperative present tense, 2nd person singular', 'Sanoa means to say. Dropping the last -a gives sano, telling someone to say it.', 'tell', 'to say, to tell')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sano', 'sanoa',
      (select form_name_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano'),
      (select why_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano'),
      (select meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano'),
      (select lemma_meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano'),
      'imperative present tense, 2nd person singular', 'Sanoa means to say. Dropping the last -a gives sano, telling someone to say it.', 'tell', 'to say, to tell';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hän', 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular', '{"BASEFORM":"hän","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]hän[X]hä[Sall][Ny]nelle","NUMBER":"singular","SIJAMUOTO":"ulkotulento","STRUCTURE":"=ppppppp","WORDBASES":"+hän(hän)"}'::jsonb,
      'hänelle', 'sille',
      'allative singular', 'Adds -lle for ''to'': hän becomes hänelle. Speech uses se for people, giving sille.', 'to her', 'he, she', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-5d0eed500da8');
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'hänelle', 'hän';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('allative singular', 'Adds -lle for ''to'': hän becomes hänelle. Speech uses se for people, giving sille.', 'to her', 'he, she')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'hänelle', 'hän',
      (select form_name_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille'),
      (select why_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille'),
      (select meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille'),
      (select lemma_meaning_en from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille'),
      'allative singular', 'Adds -lle for ''to'': hän becomes hänelle. Speech uses se for people, giving sille.', 'to her', 'he, she';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kiitos', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"kiitos","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]kiitos[X]kiito[Sn][Ny]s","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp","WORDBASES":"+kiitos(kiitos)"}'::jsonb,
      'kiitos', 'kiitos',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-c5b0481eae2b');
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kiitos', 'kiitos';
  end if;
  if not exists (select 1 from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kiitos', 'kiitos',
      (select form_name_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select why_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      (select lemma_meaning_en from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos'),
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'thank you, thanks', 'thank you, thanks';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sabl][Ny]ulta","NUMBER":"singular","SIJAMUOTO":"ulkoeronto","STRUCTURE":"=ppppppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minulta', 'multa',
      'ablative singular', 'Adds -lta for ''from'' a person: minä becomes minulta. Speech shortens it to multa.', 'from me', 'I, me', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-1f7a1d6fbf4d');
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'minulta', 'minä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('ablative singular', 'Adds -lta for ''from'' a person: minä becomes minulta. Speech shortens it to multa.', 'from me', 'I, me')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'minulta', 'minä',
      (select form_name_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa'),
      (select why_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa'),
      (select meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa'),
      (select lemma_meaning_en from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa'),
      'ablative singular', 'Adds -lta for ''from'' a person: minä becomes minulta. Speech shortens it to multa.', 'from me', 'I, me';
  end if;
  if not exists (select 1 from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('minä', 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"minä","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]minä[X]min[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+minä(minä)"}'::jsonb,
      'minä', 'mä',
      'nominative singular', 'Speech shortens minä to mä. Books write minä.', 'I', 'I, me', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-728ddce13587');
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
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('sanoa', 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"sanoa","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]sanoa[X]sano[Tt][Ap][P1][Ny][Ef]n","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"1","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+sanoa(sanoa)"}'::jsonb,
      'sanon', 'sanon',
      'present tense, 1st person singular', 'Sanoa means to say. The ending -n goes with minä: sanon.', 'I will (tell)', 'to say, to tell', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-ac0fcc7cee3a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'sanon', 'sanoa';
  end if;
  if not exists (select 1 from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 1st person singular', 'Sanoa means to say. The ending -n goes with minä: sanon.', 'I will (tell)', 'to say, to tell')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'sanon', 'sanoa',
      (select form_name_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon'),
      (select why_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon'),
      (select meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon'),
      (select lemma_meaning_en from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon'),
      'present tense, 1st person singular', 'Sanoa means to say. The ending -n goes with minä: sanon.', 'I will (tell)', 'to say, to tell';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('päästä', 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true', '{"BASEFORM":"päästä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]päästä[X]pääse[Tt][Ap][P2][Ny][Ef]t[Fko][Ef]kö","KYSYMYSLIITE":"true","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"2","STRUCTURE":"=pppppppp","TENSE":"present_simple","WORDBASES":"+päästä(päästä)"}'::jsonb,
      'pääsetkö', 'pääsek',
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Päästä means to get somewhere. -t goes with sinä and -kö asks. Speech says pääseksä.', 'can you get', 'to get (somewhere), to get in', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-5e5215d5be81');
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pääsetkö', 'päästä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 2nd person singular, with the question ending -ko/-kö', 'Päästä means to get somewhere. -t goes with sinä and -kö asks. Speech says pääseksä.', 'can you get', 'to get (somewhere), to get in')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pääsetkö', 'päästä',
      (select form_name_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek'),
      (select why_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek'),
      (select meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek'),
      (select lemma_meaning_en from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek'),
      'present tense, 2nd person singular, with the question ending -ko/-kö', 'Päästä means to get somewhere. -t goes with sinä and -kö asks. Speech says pääseksä.', 'can you get', 'to get (somewhere), to get in';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('koti', 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular', '{"BASEFORM":"koti","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]koti[X]kot[Sill][Ny]iin","NUMBER":"singular","SIJAMUOTO":"sisatulento","STRUCTURE":"=pppppp","WORDBASES":"+koti(koti)"}'::jsonb,
      'kotiin', 'kotiin',
      'illative singular', 'Koti means home. Going there adds -in: kotiin.', 'home', 'home', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-36d6add642da');
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'kotiin', 'koti';
  end if;
  if not exists (select 1 from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('illative singular', 'Koti means home. Going there adds -in: kotiin.', 'home', 'home')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'kotiin', 'koti',
      (select form_name_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin'),
      (select why_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin'),
      (select meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin'),
      (select lemma_meaning_en from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin'),
      'illative singular', 'Koti means home. Going there adds -in: kotiin.', 'home', 'home';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvin', 'CLASS=seikkasana', '{"BASEFORM":"hyvin","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]hyvin[X]hyvin","STRUCTURE":"=ppppp","WORDBASES":"+hyvin(hyvin)"}'::jsonb,
      'hyvin', 'hyvin',
      'adverb', 'This is the dictionary form. People say it the same way.', 'well', 'well', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-e18d9223b2b2');
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
  if not exists (select 1 from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('kyllä', 'CLASS=seikkasana', '{"BASEFORM":"kyllä","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]kyllä[X]kyllä","STRUCTURE":"=ppppp","WORDBASES":"+kyllä(kyllä)"}'::jsonb,
      'kyllä', 'joo',
      'adverb', 'Joo is the everyday spoken yes. Books write kyllä.', 'yes', 'yes, certainly', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-fbf4cf6cbcf9');
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
  if not exists (select 1 from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('raitiovaunu', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{"BASEFORM":"raitiovaunu","CLASS":"nimisana","FSTOUTPUT":"[Lp]raitio[Bh][Bc][Ln][Xp]vaunu[X]vaunu[Sn][Ny]","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppppp=ppppp","WORDBASES":"+raitio+vaunu(vaunu)"}'::jsonb,
      'raitiovaunu', 'ratikka',
      'nominative singular', 'Ratikka is the everyday spoken word. Books write raitiovaunu.', 'tram', 'tram', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-9b8a7d430a8e');
  end if;
  if not exists (select 1 from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'raitiovaunu', 'raitiovaunu';
  end if;
  if not exists (select 1 from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'Ratikka is the everyday spoken word. Books write raitiovaunu.', 'tram', 'tram')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'raitiovaunu', 'raitiovaunu',
      (select form_name_en from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka'),
      (select why_en from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka'),
      (select meaning_en from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka'),
      (select lemma_meaning_en from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka'),
      'nominative singular', 'Ratikka is the everyday spoken word. Books write raitiovaunu.', 'tram', 'tram';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('mennä', 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false', '{"BASEFORM":"mennä","CLASS":"teonsana","FSTOUTPUT":"[Lt][Xp]mennä[X]men[Tt][Ap][P3][Ny][Ef]ee","MOOD":"indicative","NEGATIVE":"false","NUMBER":"singular","PERSON":"3","STRUCTURE":"=ppppp","TENSE":"present_simple","WORDBASES":"+mennä(mennä)"}'::jsonb,
      'menee', 'menee',
      'present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-c90f7ee357bd');
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'menee', 'mennä';
  end if;
  if not exists (select 1 from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'menee', 'mennä',
      (select form_name_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select why_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      (select lemma_meaning_en from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee'),
      'present tense, 3rd person singular', 'Mennä, to go, in the form for he, she or it: menee.', 'goes', 'to go';
  end if;
  if not exists (select 1 from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('aivan', 'CLASS=seikkasana', '{"BASEFORM":"aivan","CLASS":"seikkasana","FSTOUTPUT":"[Ls][Xp]aivan[X]aivan","STRUCTURE":"=ppppp","WORDBASES":"+aivan(aivan)"}'::jsonb,
      'aivan', 'ihan',
      'adverb', 'Ihan is the everyday spoken word. Books write aivan.', 'really', 'quite, right, completely', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-a392b28c6a8d');
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
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('tuo', 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular', '{"BASEFORM":"tuo","CLASS":"asemosana","FSTOUTPUT":"[Lr][Xp]tuo[X]tuo[Sela][Ny]sta","NUMBER":"singular","SIJAMUOTO":"sisaeronto","STRUCTURE":"=pppppp","WORDBASES":"+tuo(tuo)"}'::jsonb,
      'tuosta', 'tosta',
      'elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-ee758ee6468a');
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'tuosta', 'tuo';
  end if;
  if not exists (select 1 from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'tuosta', 'tuo',
      (select form_name_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select why_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      (select lemma_meaning_en from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'),
      'elative singular', 'Tuo, that, with -sta for ''from'': tuosta. Speech says tosta.', 'from that', 'that';
  end if;
  if not exists (select 1 from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('hyvä', 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive', '{"BASEFORM":"hyvä","CLASS":"laatusana","COMPARISON":"positive","FSTOUTPUT":"[Ll][Xp]hyvä[X]hyv[Sn][Ny]ä","NUMBER":"singular","SIJAMUOTO":"nimento","STRUCTURE":"=pppp","WORDBASES":"+hyvä(hyvä)"}'::jsonb,
      'hyvä', 'hyvä',
      'nominative singular', 'This is the dictionary form. People say it the same way.', 'good', 'good', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-ed646e1f1923');
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
  if not exists (select 1 from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('yö', 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular', '{"BASEFORM":"yö","CLASS":"nimisana","FSTOUTPUT":"[Ln][Xp]yö[X][Sp][Ny]yötä","NUMBER":"singular","SIJAMUOTO":"osanto","STRUCTURE":"=pppp","WORDBASES":"+yö(yö)"}'::jsonb,
      'yötä', 'yötä',
      'partitive singular', 'Good wishes take -tä: yö becomes yötä, as in hyvää yötä.', 'night', 'night', 'approved', now(), 'content/approvals/part-5.json#leaving-the-party/form-8e20e5983e6f');
  end if;
  if not exists (select 1 from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'yötä', 'yö';
  end if;
  if not exists (select 1 from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('partitive singular', 'Good wishes take -tä: yö becomes yötä, as in hyvää yötä.', 'night', 'night')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'yötä', 'yö',
      (select form_name_en from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä'),
      (select why_en from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä'),
      (select meaning_en from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä'),
      (select lemma_meaning_en from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä'),
      'partitive singular', 'Good wishes take -tä: yö becomes yötä, as in hyvää yötä.', 'night', 'night';
  end if;

  -- 2. Lines with their words, each approved after its words are in.
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 1, 'Maria', 'Mun pitää lähtee. Kiitti tosi kivast illast!',
    'Minun pitää lähteä. Kiitos todella mukavasta illasta!', 'I need to go. Thanks for a really lovely evening!',
    'leaving-the-party/1-puhe-a8407a3858b3.mp3', 'leaving-the-party/1-kirja-48f3691618af.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'kirja', 3, 'lähteä', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee')),
    (v_line_id, 'kirja', 4, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 5, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 6, 'mukavasta', (select id from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast')),
    (v_line_id, 'kirja', 7, 'illasta', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'pitää', (select id from public.forms where lemma = 'pitää' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'pitää' and surface_puhe = 'pitää')),
    (v_line_id, 'puhe', 3, 'lähtee', (select id from public.forms where lemma = 'lähteä' and form_tag = 'CLASS=teonsana;MOOD=A-infinitive;NEGATIVE=both' and surface_kirja = 'lähteä' and surface_puhe = 'lähtee')),
    (v_line_id, 'puhe', 4, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 5, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 6, 'kivast', (select id from public.forms where lemma = 'mukava' and form_tag = 'CLASS=nimisana_laatusana;SIJAMUOTO=sisaeronto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'mukavasta' and surface_puhe = 'kivast')),
    (v_line_id, 'puhe', 7, 'illast', (select id from public.forms where lemma = 'ilta' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'illasta' and surface_puhe = 'illast'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-1'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 2, 'Ahmed', 'Kiitti et sä tulit!',
    'Kiitos, että sinä tulit!', 'Thanks for coming!',
    'leaving-the-party/2-puhe-5837ba5beaaf.mp3', 'leaving-the-party/2-kirja-68e7b6f9e98d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'kirja', 2, 'että', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'kirja', 3, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 4, 'tulit', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit')),
    (v_line_id, 'puhe', 1, 'Kiitti', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitti')),
    (v_line_id, 'puhe', 2, 'et', (select id from public.forms where lemma = 'että' and form_tag = 'CLASS=sidesana' and surface_kirja = 'että' and surface_puhe = 'et')),
    (v_line_id, 'puhe', 3, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 4, 'tulit', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tulit' and surface_puhe = 'tulit'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-2'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 3, 'Maria', 'Ruoka oli tosi hyvää. Kuka sen teki?',
    'Ruoka oli todella hyvää. Kuka sen teki?', 'The food was really good. Who made it?',
    'leaving-the-party/3-puhe-0a87df14b1e1.mp3', 'leaving-the-party/3-kirja-723ccebd493d.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Ruoka', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka')),
    (v_line_id, 'kirja', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'kirja', 3, 'todella', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'kirja', 4, 'hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'kirja', 5, 'Kuka', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka')),
    (v_line_id, 'kirja', 6, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'kirja', 7, 'teki', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki')),
    (v_line_id, 'puhe', 1, 'Ruoka', (select id from public.forms where lemma = 'ruoka' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'ruoka' and surface_puhe = 'ruoka')),
    (v_line_id, 'puhe', 2, 'oli', (select id from public.forms where lemma = 'olla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'oli' and surface_puhe = 'oli')),
    (v_line_id, 'puhe', 3, 'tosi', (select id from public.forms where lemma = 'todella' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'todella' and surface_puhe = 'tosi')),
    (v_line_id, 'puhe', 4, 'hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'puhe', 5, 'Kuka', (select id from public.forms where lemma = 'kuka' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kuka' and surface_puhe = 'kuka')),
    (v_line_id, 'puhe', 6, 'sen', (select id from public.forms where lemma = 'se' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'sen' and surface_puhe = 'sen')),
    (v_line_id, 'puhe', 7, 'teki', (select id from public.forms where lemma = 'tehdä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'teki' and surface_puhe = 'teki'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-3'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 4, 'Ahmed', 'Mun äiti. Se tuli Somaliast käymään.',
    'Minun äitini. Hän tuli Somaliasta käymään.', 'My mother. She''s visiting from Somalia.',
    'leaving-the-party/4-puhe-c270907fd9ad.mp3', 'leaving-the-party/4-kirja-080e095739e4.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'kirja', 2, 'äitini', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti')),
    (v_line_id, 'kirja', 3, 'Hän', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'kirja', 4, 'tuli', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli')),
    (v_line_id, 'kirja', 5, 'Somaliasta', null),
    (v_line_id, 'kirja', 6, 'käymään', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään')),
    (v_line_id, 'puhe', 1, 'Mun', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=omanto;NUMBER=singular' and surface_kirja = 'minun' and surface_puhe = 'mun')),
    (v_line_id, 'puhe', 2, 'äiti', (select id from public.forms where lemma = 'äiti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular;POSSESSIVE=1s' and surface_kirja = 'äitini' and surface_puhe = 'äiti')),
    (v_line_id, 'puhe', 3, 'Se', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'hän' and surface_puhe = 'se')),
    (v_line_id, 'puhe', 4, 'tuli', (select id from public.forms where lemma = 'tulla' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=past_imperfective;NEGATIVE=false' and surface_kirja = 'tuli' and surface_puhe = 'tuli')),
    (v_line_id, 'puhe', 5, 'Somaliast', null),
    (v_line_id, 'puhe', 6, 'käymään', (select id from public.forms where lemma = 'käydä' and form_tag = 'CLASS=teonsana;SIJAMUOTO=sisatulento;NUMBER=singular;MOOD=MA-infinitive' and surface_kirja = 'käymään' and surface_puhe = 'käymään'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-4'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 5, 'Maria', 'Sano sille kiitos multa.',
    'Sano hänelle kiitos minulta.', 'Tell her thanks from me.',
    'leaving-the-party/5-puhe-5c59ae475214.mp3', 'leaving-the-party/5-kirja-d708789e273a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Sano', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano')),
    (v_line_id, 'kirja', 2, 'hänelle', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille')),
    (v_line_id, 'kirja', 3, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'kirja', 4, 'minulta', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa')),
    (v_line_id, 'puhe', 1, 'Sano', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=imperative;TENSE=present_simple;NEGATIVE=both' and surface_kirja = 'sano' and surface_puhe = 'sano')),
    (v_line_id, 'puhe', 2, 'sille', (select id from public.forms where lemma = 'hän' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkotulento;NUMBER=singular' and surface_kirja = 'hänelle' and surface_puhe = 'sille')),
    (v_line_id, 'puhe', 3, 'kiitos', (select id from public.forms where lemma = 'kiitos' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'kiitos' and surface_puhe = 'kiitos')),
    (v_line_id, 'puhe', 4, 'multa', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=ulkoeronto;NUMBER=singular' and surface_kirja = 'minulta' and surface_puhe = 'multa'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-5'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 6, 'Ahmed', 'Mä sanon. Pääseksä kotiin hyvin?',
    'Minä sanon. Pääsetkö sinä kotiin hyvin?', 'I will. Can you get home OK?',
    'leaving-the-party/6-puhe-1293a22f21e8.mp3', 'leaving-the-party/6-kirja-af312739214a.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Minä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'kirja', 2, 'sanon', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon')),
    (v_line_id, 'kirja', 3, 'Pääsetkö', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek')),
    (v_line_id, 'kirja', 4, 'sinä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'kirja', 5, 'kotiin', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin')),
    (v_line_id, 'kirja', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin')),
    (v_line_id, 'puhe', 1, 'Mä', (select id from public.forms where lemma = 'minä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'minä' and surface_puhe = 'mä')),
    (v_line_id, 'puhe', 2, 'sanon', (select id from public.forms where lemma = 'sanoa' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'sanon' and surface_puhe = 'sanon')),
    (v_line_id, 'puhe', 3, 'Pääsek', (select id from public.forms where lemma = 'päästä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=2;MOOD=indicative;TENSE=present_simple;NEGATIVE=false;KYSYMYSLIITE=true' and surface_kirja = 'pääsetkö' and surface_puhe = 'pääsek')),
    (v_line_id, 'puhe', 4, 'sä', (select id from public.forms where lemma = 'sinä' and form_tag = 'CLASS=asemosana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'sinä' and surface_puhe = 'sä')),
    (v_line_id, 'puhe', 5, 'kotiin', (select id from public.forms where lemma = 'koti' and form_tag = 'CLASS=nimisana;SIJAMUOTO=sisatulento;NUMBER=singular' and surface_kirja = 'kotiin' and surface_puhe = 'kotiin')),
    (v_line_id, 'puhe', 6, 'hyvin', (select id from public.forms where lemma = 'hyvin' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'hyvin' and surface_puhe = 'hyvin'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-6'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 7, 'Maria', 'Joo, ratikka menee ihan tosta.',
    'Kyllä, raitiovaunu menee aivan tuosta.', 'Yes, the tram goes from right there.',
    'leaving-the-party/7-puhe-954a407db7dd.mp3', 'leaving-the-party/7-kirja-d72dc3fee906.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Kyllä', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'kirja', 2, 'raitiovaunu', (select id from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka')),
    (v_line_id, 'kirja', 3, 'menee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee')),
    (v_line_id, 'kirja', 4, 'aivan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'kirja', 5, 'tuosta', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta')),
    (v_line_id, 'puhe', 1, 'Joo', (select id from public.forms where lemma = 'kyllä' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'kyllä' and surface_puhe = 'joo')),
    (v_line_id, 'puhe', 2, 'ratikka', (select id from public.forms where lemma = 'raitiovaunu' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'raitiovaunu' and surface_puhe = 'ratikka')),
    (v_line_id, 'puhe', 3, 'menee', (select id from public.forms where lemma = 'mennä' and form_tag = 'CLASS=teonsana;NUMBER=singular;PERSON=3;MOOD=indicative;TENSE=present_simple;NEGATIVE=false' and surface_kirja = 'menee' and surface_puhe = 'menee')),
    (v_line_id, 'puhe', 4, 'ihan', (select id from public.forms where lemma = 'aivan' and form_tag = 'CLASS=seikkasana' and surface_kirja = 'aivan' and surface_puhe = 'ihan')),
    (v_line_id, 'puhe', 5, 'tosta', (select id from public.forms where lemma = 'tuo' and form_tag = 'CLASS=asemosana;SIJAMUOTO=sisaeronto;NUMBER=singular' and surface_kirja = 'tuosta' and surface_puhe = 'tosta'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-7'
  where id = v_line_id;
  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,
    gloss_en, audio_puhe_key, audio_kirja_key)
  values (v_dialogue_id, 8, 'Ahmed', 'Hyvä. Hyvää yötä!',
    'Hyvä. Hyvää yötä!', 'Good. Good night!',
    'leaving-the-party/8-puhe-50981e2df928.mp3', 'leaving-the-party/8-kirja-888674ee50b5.mp3')
  returning id into v_line_id;
  insert into public.tokens (line_id, register, position, surface, form_id)
  values
    (v_line_id, 'kirja', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'kirja', 2, 'Hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'kirja', 3, 'yötä', (select id from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä')),
    (v_line_id, 'puhe', 1, 'Hyvä', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=nimento;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvä' and surface_puhe = 'hyvä')),
    (v_line_id, 'puhe', 2, 'Hyvää', (select id from public.forms where lemma = 'hyvä' and form_tag = 'CLASS=laatusana;SIJAMUOTO=osanto;NUMBER=singular;COMPARISON=positive' and surface_kirja = 'hyvää' and surface_puhe = 'hyvää')),
    (v_line_id, 'puhe', 3, 'yötä', (select id from public.forms where lemma = 'yö' and form_tag = 'CLASS=nimisana;SIJAMUOTO=osanto;NUMBER=singular' and surface_kirja = 'yötä' and surface_puhe = 'yötä'));
  update public.dialogue_lines set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/line-8'
  where id = v_line_id;

  -- 3. The dialogue, now that every line is approved.
  update public.dialogues set status = 'approved', approved_at = now(),
    approval_ref = 'content/approvals/part-5.json#leaving-the-party/dialogue'
  where id = v_dialogue_id;

  -- 4. The stop, now that this is its last dialogue.
  if v_status = 'draft' then
    update public.units set status = 'approved', approved_at = now(),
      approval_ref = 'content/approvals/part-5.json#leaving-the-party/dialogue'
    where id = v_unit_id;
  end if;
end
$publish$;
