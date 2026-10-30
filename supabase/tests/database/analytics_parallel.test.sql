-- Analytics: the rules that must hold when two requests arrive at the same
-- moment, tested from two database connections at once (pgTAP with dblink).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/14-analytics/spec.md that each test protects.
--
-- Two more connections (A and B) are opened to this same database with
-- dblink, plus a third (C) that sets up and cleans up. A opens a transaction
-- and makes its call; B makes the same call while A is still open, and the
-- test checks B is waiting; then A commits and B's answer is checked.
--
-- A second connection needs the database password. Only the step "Parallel
-- database tests" of the GitHub check "Database tests (local Supabase,
-- pgTAP)" gives it, as the session setting puhuscribe.parallel_test_password
-- (the throwaway database's fixed local password, not a secret;
-- .github/workflows/checks.yml). That step fails unless all nine pass. Run
-- anywhere else (supabase test db, the test project after a merge), the nine
-- tests are skipped and say why.
--
-- Rows written through the extra connections are committed, so every one is
-- deleted again at the end, and anything left by an earlier failed run is
-- deleted at the start: the country QZ (a code no country uses), the crash
-- reports named ParallelFill and ParallelCap, and the one test learner.

begin;

create extension if not exists pgtap with schema extensions;
create extension if not exists dblink with schema extensions;

select plan(9);

create function pg_temp.parallel_tests()
returns setof text
language plpgsql
as $$
declare
  v_password text := current_setting('puhuscribe.parallel_test_password', true);
  dsn text;
  v_learner uuid := gen_random_uuid();
  v_claims text;
  v_in_last_hour bigint;
  v_stored boolean;
begin
  if coalesce(v_password, '') = '' then
    return next skip(
      'a second connection needs the local database password, given only in the step "Parallel database tests" of the database check',
      9);
    return;
  end if;

  dsn := format('host=%s port=%s dbname=%s user=postgres password=%s',
                host(inet_server_addr()), inet_server_port(), current_database(), v_password);
  perform dblink_connect('analytics_c', dsn);
  perform dblink_connect('analytics_a', dsn);
  perform dblink_connect('analytics_b', dsn);

  -- Leftovers of an earlier failed run.
  perform dblink_exec('analytics_c', $q$delete from private.visit_tallies where country = 'QZ'$q$);
  perform dblink_exec('analytics_c',
    $q$delete from private.crash_reports where error_name in ('ParallelFill', 'ParallelCap')$q$);

  -- [analytics 6] Two visits at the same moment both count -------------------------
  perform dblink_exec('analytics_a', 'begin');
  perform dblink_exec('analytics_a', 'set local role anon');
  perform dblink_exec('analytics_b', 'begin');
  perform dblink_exec('analytics_b', 'set local role anon');
  perform * from dblink('analytics_a', $q$select public.count_visit('QZ')::text$q$) as t(x text);
  perform dblink_send_query('analytics_b', $q$select public.count_visit('QZ')$q$);
  perform pg_sleep(0.5);
  return next is(dblink_is_busy('analytics_b'), 1,
    '[analytics 6] the second visit waits while the first one is still open');
  perform dblink_exec('analytics_a', 'commit');
  perform * from dblink_get_result('analytics_b') as r(x text);
  perform * from dblink_get_result('analytics_b') as r(x text);
  perform dblink_exec('analytics_b', 'commit');
  return next is(
    (select t.visits from private.visit_tallies t
      where t.country = 'QZ' and t.day = (now() at time zone 'Europe/Helsinki')::date),
    2::bigint, '[analytics 6] two calls from two connections at once make a count of 2');

  -- [analytics 22] Two messages at the same moment cannot beat the daily limit -----
  perform dblink_exec('analytics_c', format($q$insert into auth.users (id, is_anonymous) values (%L, true)$q$, v_learner));
  perform dblink_exec('analytics_c', format(
    $q$insert into public.feedback (user_id, screen, message)
       select %L, 'account', 'parallel test ' || n from generate_series(1, 4) as n$q$, v_learner));
  v_claims := json_build_object('sub', v_learner, 'role', 'authenticated')::text;
  perform dblink_exec('analytics_a', 'begin');
  perform dblink_exec('analytics_a', 'set local role authenticated');
  perform * from dblink('analytics_a', format($q$select set_config('request.jwt.claims', %L, true)$q$, v_claims)) as t(x text);
  perform dblink_exec('analytics_b', 'begin');
  perform dblink_exec('analytics_b', 'set local role authenticated');
  perform * from dblink('analytics_b', format($q$select set_config('request.jwt.claims', %L, true)$q$, v_claims)) as t(x text);
  perform dblink_exec('analytics_a', $q$insert into public.feedback (screen, message) values ('account', 'fifth, from A')$q$);
  perform dblink_send_query('analytics_b',
    $q$insert into public.feedback (screen, message) values ('account', 'fifth, from B')$q$);
  perform pg_sleep(0.5);
  return next is(dblink_is_busy('analytics_b'), 1,
    '[analytics 22] the second message waits for the first one''s lock on the learner');
  perform dblink_exec('analytics_a', 'commit');
  perform * from dblink_get_result('analytics_b', false) as r(x text);
  return next ok(dblink_error_message('analytics_b') like '%feedback_daily_limit%',
    '[analytics 22] once the first message is saved, the second one is refused as the 6th of the day');
  perform * from dblink_get_result('analytics_b', false) as r(x text);
  perform dblink_exec('analytics_b', 'rollback');
  return next is((select count(*) from public.feedback f where f.user_id = v_learner), 5::bigint,
    '[analytics 22] parallel requests cannot beat the limit: the learner has exactly 5 messages');

  -- [analytics 26] Two crash reports at the same moment cannot beat the hourly cap --
  select t.n into v_in_last_hour
    from dblink('analytics_c',
                $q$select count(*) from private.crash_reports where created_at > now() - interval '1 hour'$q$)
      as t(n bigint);
  perform dblink_exec('analytics_c', format(
    $q$insert into private.crash_reports (source, group_key, error_name, message, frames, path, app_version, browser)
       select 'browser', md5('parallel fill ' || n), 'ParallelFill', 'fill', '[]', '/', 'local', 'Chrome 130, Android'
         from generate_series(1, %s) as n$q$, greatest(299 - v_in_last_hour, 0)));
  perform dblink_exec('analytics_a', 'begin');
  perform dblink_exec('analytics_a', 'set local role anon');
  perform dblink_exec('analytics_b', 'begin');
  perform dblink_exec('analytics_b', 'set local role anon');
  select t.stored into v_stored
    from dblink('analytics_a',
                $q$select public.report_crash('browser', 'ParallelCap', 'first', '[]', '/', 'local', 'Chrome 130, Android')$q$)
      as t(stored boolean);
  return next is(v_stored, true, '[analytics 26] the 300th report of the hour is stored');
  perform dblink_send_query('analytics_b',
    $q$select public.report_crash('browser', 'ParallelCap', 'second', '[]', '/', 'local', 'Chrome 130, Android')$q$);
  perform pg_sleep(0.5);
  return next is(dblink_is_busy('analytics_b'), 1,
    '[analytics 26] the second report waits while the first one is being counted');
  perform dblink_exec('analytics_a', 'commit');
  select t.stored into v_stored from dblink_get_result('analytics_b') as t(stored boolean);
  perform * from dblink_get_result('analytics_b') as r(x text);
  perform dblink_exec('analytics_b', 'commit');
  return next is(v_stored, false, '[analytics 26] once the first is stored, the second is dropped as the 301st');
  return next is(
    (select n from dblink('analytics_c',
                          $q$select count(*) from private.crash_reports where created_at > now() - interval '1 hour'$q$)
       as t(n bigint)),
    300::bigint, '[analytics 26] parallel reports cannot beat the cap: the hour holds exactly 300');

  -- Clean up everything written through the extra connections.
  perform dblink_exec('analytics_c',
    $q$delete from private.crash_reports where error_name in ('ParallelFill', 'ParallelCap')$q$);
  perform dblink_exec('analytics_c', $q$delete from private.visit_tallies where country = 'QZ'$q$);
  perform dblink_exec('analytics_c', format($q$delete from auth.users where id = %L$q$, v_learner));
  perform dblink_disconnect('analytics_a');
  perform dblink_disconnect('analytics_b');
  perform dblink_disconnect('analytics_c');
end;
$$;

select * from pg_temp.parallel_tests();

select * from finish();

rollback;
