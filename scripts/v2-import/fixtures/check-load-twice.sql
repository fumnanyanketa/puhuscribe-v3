-- Job 3-data-model ("Done when" 15): the starter sentence loader, run on
-- made-up fixture data, loads twice without duplicates. Run by the database
-- check with psql on the throwaway local database, from the repository root.
-- Everything happens in one transaction that is rolled back.
-- The expected count and fingerprint are checked against the fixture files by
-- scripts/v2-import/generate.test.ts.

\set ON_ERROR_STOP on

begin;

\i scripts/v2-import/fixtures/load.fixture.sql
\i scripts/v2-import/fixtures/load.fixture.sql

do $$
declare
  loaded bigint;
  fingerprint text;
begin
  select count(*),
         md5(string_agg(source_ref || E'\t' || text_kirja || E'\t' || text_puhe || E'\t' || gloss_en,
                        E'\n' order by source_ref::int))
    into loaded, fingerprint
    from public.source_sentences
   where source = 'fixture-v2-starter';
  if loaded <> 3 then
    raise exception 'expected 3 fixture sentences after loading twice, found %', loaded;
  end if;
  if fingerprint <> '20c532a48f9fff0844349f492e6ca4c7' then
    raise exception 'the fixture sentences differ from the fixture plus its corrections (fingerprint %)', fingerprint;
  end if;
  raise notice 'Loaded the fixture sentences twice: % rows, fingerprint %', loaded, fingerprint;
end
$$;

rollback;
