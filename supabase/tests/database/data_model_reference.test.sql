-- Data model: the reference tables (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/3-data-model/spec.md that each test protects.
--
-- In the database check this file runs twice: after the migrations, and again
-- after every load migration has been run a second time. Runs inside one
-- transaction that is rolled back.

begin;

create extension if not exists pgtap with schema extensions;

select plan(25);

-- [data 16] v2's pronunciation data: 514 rows, exactly as in v2 ---------------------
-- The fingerprint is md5 of every "lemma<tab>ipa" line in lemma order. The same
-- value is computed from the copy of v2's file by scripts/v2-import/generate.test.ts,
-- which fails if this file and v2 disagree.

select results_eq(
  $$select count(*) from public.lemma_ipa$$,
  array[514::bigint],
  '[data 16] lemma_ipa has exactly 514 rows, also after the load ran a second time'
);
select results_eq(
  $$select md5(string_agg(lemma || E'\t' || ipa, E'\n' order by lemma collate "C")) from public.lemma_ipa$$,
  array['cff0c76a84572a4f29966102200257ac'],
  '[data 16] every lemma and IPA matches v2 (fingerprint cff0c76a84572a4f29966102200257ac)'
);
select results_eq(
  $$select ipa from public.lemma_ipa where lemma = 'hei'$$,
  array['/ˈhei̯/'],
  '[data 16] hei is /ˈhei̯/, as in v2'
);
select is_empty(
  $$select lemma from public.lemma_ipa
     where source <> 'English Wiktionary via kaikki.org' or licence <> 'CC BY-SA 4.0'$$,
  '[data 16] every row records its source (English Wiktionary via kaikki.org) and licence (CC BY-SA 4.0)'
);

-- [data 7] [data 15] [data 16] No learner and no anon key can read or write reference data

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000d1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;

select throws_ok(format('select * from public.%I', t), '42501', null,
  format('[data 7] a learner cannot read %s', t))
  from unnest(array['source_sentences', 'lemma_ipa']) as t;
select throws_ok(
  $$insert into public.source_sentences (source, source_ref, text_kirja, text_puhe, gloss_en, note)
    values ('pgtap', '1', 'k', 'p', 'e', 'n')$$,
  '42501', null, '[data 7] a learner cannot add to source_sentences');
select throws_ok(
  $$insert into public.lemma_ipa (lemma, ipa, source, licence) values ('pgtap', 'x', 's', 'l')$$,
  '42501', null, '[data 7] a learner cannot add to lemma_ipa');
select throws_ok(format('update public.%I set %I = %I', t, c, c), '42501', null,
  format('[data 7] a learner cannot change %s', t))
  from (values ('source_sentences', 'note'), ('lemma_ipa', 'ipa')) as x(t, c);
select throws_ok(format('delete from public.%I', t), '42501', null,
  format('[data 7] a learner cannot delete from %s', t))
  from unnest(array['source_sentences', 'lemma_ipa']) as t;

reset role;

select set_config('request.jwt.claims', '{"role": "anon"}', true);
set local role anon;

select throws_ok(format('select * from public.%I', t), '42501', null,
  format('[data 7] anon cannot read %s', t))
  from unnest(array['source_sentences', 'lemma_ipa']) as t;
select throws_ok(
  $$insert into public.source_sentences (source, source_ref, text_kirja, text_puhe, gloss_en, note)
    values ('pgtap', '1', 'k', 'p', 'e', 'n')$$,
  '42501', null, '[data 7] anon cannot add to source_sentences');
select throws_ok(
  $$insert into public.lemma_ipa (lemma, ipa, source, licence) values ('pgtap', 'x', 's', 'l')$$,
  '42501', null, '[data 7] anon cannot add to lemma_ipa');
select throws_ok(format('update public.%I set %I = %I', t, c, c), '42501', null,
  format('[data 7] anon cannot change %s', t))
  from (values ('source_sentences', 'note'), ('lemma_ipa', 'ipa')) as x(t, c);
select throws_ok(format('delete from public.%I', t), '42501', null,
  format('[data 7] anon cannot delete from %s', t))
  from unnest(array['source_sentences', 'lemma_ipa']) as t;

reset role;

-- Row level security with no rule: even a role given a permission by mistake
-- would see no row. Proved with a temporary grant, rolled back with the rest.
grant select on public.source_sentences, public.lemma_ipa to authenticated;
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000d1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;
select is_empty($$select 1 from public.lemma_ipa$$,
  '[data 16] even with a mistaken read permission, a learner would see no lemma_ipa row');
select is_empty($$select 1 from public.source_sentences$$,
  '[data 15] even with a mistaken read permission, a learner would see no source_sentences row');
reset role;
revoke select on public.source_sentences, public.lemma_ipa from authenticated;

-- [data 15] The loads are keyed so a second run cannot add duplicates ------------------

select col_is_pk('public', 'lemma_ipa', 'lemma', '[data 16] a second IPA load updates rows keyed on the lemma');
select col_is_unique('public', 'source_sentences', array['source', 'source_ref'],
  '[data 15] a second sentence load updates rows keyed on (source, source_ref)');
select throws_ok(
  $$insert into public.source_sentences (source, source_ref, text_kirja, text_puhe, gloss_en, note)
    values ('pgtap', '1', 'k', 'p', 'e', 'n'), ('pgtap', '1', 'k2', 'p2', 'e2', 'n2')$$,
  '23505', null,
  '[data 15] the same (source, source_ref) cannot be stored twice'
);

select * from finish();

rollback;
