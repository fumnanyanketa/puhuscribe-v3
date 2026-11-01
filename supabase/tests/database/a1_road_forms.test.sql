-- How a road publish migration puts in a form (job 20-a1-road, "Done when" 17 as amended, pgTAP).
-- Made by scripts/generate/road_forms_pgtap.py from publish.road_form_lines(): do not edit by hand.
-- The lines are the ones every publish migration holds. One rolled back transaction.

begin;

create extension if not exists pgtap with schema extensions;

select plan(7);

select lives_ok($q$
do $check$
begin
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pgtap-road-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,
      'pgtap-road-form', 'pgtap-road-form',
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning', 'approved', now(), 'pgtap-ref-1');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pgtap-road-form', 'pgtap-road-form';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pgtap-road-form', 'pgtap-road-form',
      (select form_name_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select why_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select lemma_meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning';
  end if;
end
$check$;
$q$, '[a1-road 17] a form that does not exist is inserted');
select is((select count(*) from public.forms where lemma = 'pgtap-road-form' and status = 'approved'),
  1::bigint, '[a1-road 17] it is there once, approved');

select lives_ok($q$
do $check$
begin
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pgtap-road-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,
      'pgtap-road-form', 'pgtap-road-form',
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning', 'approved', now(), 'pgtap-ref-2');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pgtap-road-form', 'pgtap-road-form';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pgtap-road-form', 'pgtap-road-form',
      (select form_name_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select why_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select lemma_meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning';
  end if;
end
$check$;
$q$, '[a1-road 17] the same form with the same texts goes through again');
select is((select count(*) from public.forms where lemma = 'pgtap-road-form'),
  1::bigint, '[a1-road 17] and still there is one row');

select throws_ilike($q$
do $check$
begin
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pgtap-road-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,
      'pgtap-road-form', 'pgtap-road-form',
      'nominative singular', 'pgtap new why', 'pgtap old meaning', 'pgtap old dictionary meaning', 'approved', now(), 'pgtap-ref-3');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pgtap-road-form', 'pgtap-road-form';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'pgtap new why', 'pgtap old meaning', 'pgtap old dictionary meaning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pgtap-road-form', 'pgtap-road-form',
      (select form_name_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select why_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      (select lemma_meaning_en from public.forms where lemma = 'pgtap-road-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-form' and surface_puhe = 'pgtap-road-form'),
      'nominative singular', 'pgtap new why', 'pgtap old meaning', 'pgtap old dictionary meaning';
  end if;
end
$check$;
$q$, '%form pgtap-road-form (pgtap-road-form) already exists with different texts. Existing:%why pgtap old why%New:%why pgtap new why%',
  '[a1-road 17] the same form with another why is refused, naming the form and both texts');
select is((select why_en from public.forms where lemma = 'pgtap-road-form'), 'pgtap old why',
  '[a1-road 17] the stored text stays as it was');

insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe, form_name_en, why_en)
  values ('pgtap-road-draft-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,
    'pgtap-road-draft-form', 'pgtap-road-draft-form', 'nominative singular', 'pgtap why');
select throws_ilike($q$
do $check$
begin
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form') then
    insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,
      form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)
    values ('pgtap-road-draft-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,
      'pgtap-road-draft-form', 'pgtap-road-draft-form',
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning', 'approved', now(), 'pgtap-ref-4');
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form' and status = 'approved') then
    raise exception 'form % (%) exists but is not approved',
      'pgtap-road-draft-form', 'pgtap-road-draft-form';
  end if;
  if not exists (select 1 from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form' and (form_name_en, why_en, meaning_en, lemma_meaning_en) is not distinct from ('nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning')) then
    raise exception 'form % (%) already exists with different texts. Existing: name %, why %, meaning %, dictionary meaning %. New: name %, why %, meaning %, dictionary meaning %',
      'pgtap-road-draft-form', 'pgtap-road-draft-form',
      (select form_name_en from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form'),
      (select why_en from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form'),
      (select meaning_en from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form'),
      (select lemma_meaning_en from public.forms where lemma = 'pgtap-road-draft-form' and form_tag = 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular' and surface_kirja = 'pgtap-road-draft-form' and surface_puhe = 'pgtap-road-draft-form'),
      'nominative singular', 'pgtap old why', 'pgtap old meaning', 'pgtap old dictionary meaning';
  end if;
end
$check$;
$q$, '%exists but is not approved%',
  '[a1-road 17] an existing form that is not approved is refused');

select * from finish();

rollback;
