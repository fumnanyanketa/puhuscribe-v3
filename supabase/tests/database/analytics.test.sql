-- Analytics: the visit count, feedback, the owner list, crash reports and the
-- owner page's numbers (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/14-analytics/spec.md that each test protects. The tests that
-- need two connections at once are in analytics_parallel.test.sql.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project. To check each number against a
-- hand worked answer, the transaction first removes every account, visit and
-- crash report it can see; the rollback puts them all back.
--
-- Test accounts (ids end in 14..):
--   O  = ...0000000014f1  on the owner list, with a live sign in
--   O2 = ...0000000014f2  on the owner list, sign in ended (no auth.sessions row)
--   A  = ...0000000014a1  a guest learner with a live sign in
--   B  = ...0000000014b1  an email learner with a live sign in
--   L1 to L6 = ...0000000014c1 to 14c6, backdated learners for the numbers
-- Acting as someone means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated (or anon) role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(196);

-- A clean slate inside this transaction -----------------------------------------------

delete from auth.users;
delete from private.visit_tallies;
delete from private.crash_reports;

-- Helsinki noon, some days ago, plus some minutes.
create function pg_temp.noon(days_ago integer, plus_minutes integer default 0)
returns timestamptz
language sql
stable
as $$
  select ((((now() at time zone 'Europe/Helsinki')::date - days_ago)::timestamp
           + interval '12 hours' + make_interval(mins => plus_minutes)) at time zone 'Europe/Helsinki');
$$;

-- Today in Helsinki, as the database clock says.
create function pg_temp.today()
returns date
language sql
stable
as $$
  select (now() at time zone 'Europe/Helsinki')::date;
$$;

insert into auth.users (id, is_anonymous, email, created_at) values
  ('00000000-0000-4000-8000-0000000014f1', false, 'owner-14@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014f2', false, 'owner-14-ended@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014a1', true, null, now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014b1', false, 'learner-14b@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c1', true, null, now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c2', false, 'learner-14c2@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c3', true, null, now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c4', true, null, now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c5', true, null, now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000014c6', true, null, now() - interval '60 days');

insert into auth.sessions (id, user_id) values
  ('00000000-0000-4000-8000-0000000054f1', '00000000-0000-4000-8000-0000000014f1'),
  ('00000000-0000-4000-8000-0000000054a1', '00000000-0000-4000-8000-0000000014a1'),
  ('00000000-0000-4000-8000-0000000054b1', '00000000-0000-4000-8000-0000000014b1');

insert into private.owners (user_id) values
  ('00000000-0000-4000-8000-0000000014f1'),
  ('00000000-0000-4000-8000-0000000014f2');

-- =====================================================================================
-- [analytics 5] The tally table holds a day, a country and a number
-- =====================================================================================

select columns_are('private', 'visit_tallies', array['day', 'country', 'visits'],
  '[analytics 5] private.visit_tallies has exactly day, country and visits: no address, time, user agent or user');
select col_type_is('private', 'visit_tallies', 'day', 'date', '[analytics 5] visit_tallies.day is a date');
select col_type_is('private', 'visit_tallies', 'country', 'text', '[analytics 5] visit_tallies.country is text');
select col_type_is('private', 'visit_tallies', 'visits', 'bigint', '[analytics 5] visit_tallies.visits is a bigint');
select col_is_pk('private', 'visit_tallies', array['day', 'country'],
  '[analytics 5] a tally is one row per day and country');
select table_privs_are('private', 'visit_tallies', r, array[]::text[],
  format('[analytics 5] %s has no permission on private.visit_tallies', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;
select throws_ok($$ insert into private.visit_tallies (day, country, visits) values (current_date, 'fi', 1) $$,
  '23514', null, '[analytics 5] a country that is not two capital letters cannot be stored');

-- =====================================================================================
-- [analytics 6] One narrow door adds to the tally
-- =====================================================================================

select ok((select prosecdef from pg_proc where oid = 'public.count_visit(text)'::regprocedure),
  '[analytics 6] count_visit is security definer');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.count_visit(text)'::regprocedure),
  '[analytics 6] count_visit runs with an empty search_path');
select function_returns('public', 'count_visit', array['text'], 'void', '[analytics 6] count_visit returns nothing');
select is((select count(*) from pg_proc where proname = 'count_visit'), 1::bigint,
  '[analytics 6] there is one count_visit, with the country as its only argument (the day is never the caller''s)');
select ok(has_function_privilege('anon', 'public.count_visit(text)', 'EXECUTE'), '[analytics 6] anon may call count_visit');
select ok(not has_function_privilege(r, 'public.count_visit(text)', 'EXECUTE'),
  format('[analytics 6] %s may not call count_visit', r))
  from unnest(array['authenticated', 'service_role']) as r;
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.count_visit(text)'::regprocedure and x.grantee = 0 $$,
  '[analytics 6] PUBLIC may not call count_visit');

set local role anon;
select lives_ok($$ select public.count_visit('QZ') $$, '[analytics 6] anon adds one visit');
select lives_ok($$ select public.count_visit('QZ') $$, '[analytics 6] anon adds a second visit');
reset role;
select is((select visits from private.visit_tallies where day = pg_temp.today() and country = 'QZ'), 2::bigint,
  '[analytics 6] two calls make a count of 2, on today''s Helsinki day from the database clock');
select is((select count(*) from private.visit_tallies), 1::bigint,
  '[analytics 6] the two calls share one row');

set local role anon;
select throws_ok($$ select public.count_visit('fi') $$, '22023', null, '[analytics 6] fi (lower case) is refused');
select throws_ok($$ select public.count_visit('FIN') $$, '22023', null, '[analytics 6] FIN (three letters) is refused');
select throws_ok($$ select public.count_visit('F1') $$, '22023', null, '[analytics 6] F1 (a digit) is refused');
select throws_ok($$ select public.count_visit('') $$, '22023', null, '[analytics 6] an empty value is refused');
select throws_ok($$ select public.count_visit(null) $$, '22023', null, '[analytics 6] no value is refused');
reset role;
select results_eq($$ select country, visits from private.visit_tallies $$, $$ values ('QZ'::text, 2::bigint) $$,
  '[analytics 6] the refused calls wrote nothing');

set local role anon;
select lives_ok($$ select public.count_visit('T1') $$,
  '[analytics 2] [analytics 6] T1, Cloudflare''s code for the Tor network, is stored as T1');
select throws_ok($$ select * from private.visit_tallies $$, '42501', null, '[analytics 6] anon cannot read the tallies');
reset role;
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select throws_ok($$ select public.count_visit('FI') $$, '42501', null, '[analytics 6] a signed in learner cannot call count_visit');
select throws_ok($$ select * from private.visit_tallies $$, '42501', null, '[analytics 5] a learner cannot read the tallies');
reset role;

delete from private.visit_tallies;

-- =====================================================================================
-- [analytics 21] [analytics 22] Feedback
-- =====================================================================================

select columns_are('public', 'feedback', array['id', 'user_id', 'created_at', 'screen', 'message'],
  '[analytics 21] feedback has exactly id, user_id, created_at, screen and message');
select fk_ok('public', 'feedback', 'user_id', 'auth', 'users', 'id', '[analytics 21] feedback.user_id links to auth.users');
select is((select confdeltype::text from pg_constraint
            where conrelid = 'public.feedback'::regclass and contype = 'f'), 'c',
  '[analytics 21] [analytics 23] feedback is deleted with the account');
select ok((select relrowsecurity from pg_class where oid = 'public.feedback'::regclass),
  '[analytics 21] row level security is on for feedback');
select table_privs_are('public', 'feedback', r, array[]::text[], format('[analytics 21] %s has no permission on feedback', r))
  from unnest(array['anon', 'service_role']) as r;
select table_privs_are('public', 'feedback', 'authenticated', array['SELECT'],
  '[analytics 21] a learner may read feedback as a whole table, and nothing else at table level');
select results_eq(
  $$ select (a.attname::text || ' ' || coalesce(r.rolname::text, 'PUBLIC') || ' ' || x.privilege_type::text) collate "C"
       from pg_attribute a
       cross join lateral aclexplode(a.attacl) x
       left join pg_roles r on r.oid = x.grantee
      where a.attrelid = 'public.feedback'::regclass and a.attnum > 0 and not a.attisdropped
        and (x.grantee = 0 or r.rolname in ('anon', 'authenticated', 'service_role'))
      order by 1 $$,
  $$ values ('message authenticated INSERT' collate "C"), ('screen authenticated INSERT'), ('user_id authenticated INSERT') $$,
  '[analytics 21] a learner may add only user_id, screen and message; nobody may change or delete');
select policies_are('public', 'feedback', array['learners read their own feedback', 'learners send their own feedback'],
  '[analytics 21] feedback has exactly its two rules');

-- A sends one message as a learner.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select lives_ok($$ insert into public.feedback (screen, message) values ('account', 'pgtap message from a') $$,
  '[analytics 21] a learner sends a message');
select throws_ok(
  $$ insert into public.feedback (user_id, screen, message) values ('00000000-0000-4000-8000-0000000014b1', 'account', 'for b') $$,
  '42501', null, '[analytics 21] a learner cannot add a message for another learner');
select throws_ok(
  $$ insert into public.feedback (screen, message, created_at) values ('account', 'backdated', now() - interval '2 days') $$,
  '42501', null, '[analytics 21] a learner cannot set created_at');
select throws_ok($$ update public.feedback set message = 'changed' $$, '42501', null,
  '[analytics 21] a learner cannot change a message');
select throws_ok($$ delete from public.feedback $$, '42501', null, '[analytics 21] a learner cannot delete a message');
reset role;

-- B sends one message.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014b1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054b1"}', true);
set local role authenticated;
select lives_ok($$ insert into public.feedback (screen, message) values ('finish', 'pgtap message from b') $$,
  '[analytics 21] a second learner sends a message');
reset role;

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select results_eq($$ select message from public.feedback $$, $$ values ('pgtap message from a') $$,
  '[analytics 21] a learner reads only their own messages, never another learner''s');
select throws_ok($$ insert into public.feedback (screen, message) values ('settings', 'x') $$, '23514', null,
  '[analytics 21] the screen must be front_door, account or finish');
select throws_ok($$ insert into public.feedback (screen, message) values ('account', '') $$, '23514', null,
  '[analytics 21] [analytics 22] an empty message is refused');
select throws_ok($$ insert into public.feedback (screen, message) values ('account', '   ') $$, '23514', null,
  '[analytics 21] [analytics 22] a message of spaces only is refused');
select throws_ok($$ insert into public.feedback (screen, message) values ('account', repeat('a', 1001)) $$, '23514', null,
  '[analytics 21] [analytics 22] a message of 1,001 characters is refused');
select lives_ok($$ insert into public.feedback (screen, message) values ('front_door', repeat('ä', 1000)) $$,
  '[analytics 21] a message of 1,000 characters is accepted');
reset role;

select is((select count(*) from public.feedback where screen = 'front_door'), 1::bigint,
  '[analytics 21] the 1,000 character message was stored');

-- [analytics 22] Five a day. A has sent 2 today; 3 more are allowed, the 6th is refused.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select lives_ok($$ insert into public.feedback (screen, message) values ('finish', 'three'), ('finish', 'four'), ('finish', 'five') $$,
  '[analytics 22] a learner sends a 3rd, 4th and 5th message today');
select throws_ok($$ insert into public.feedback (screen, message) values ('finish', 'six') $$, 'P0001', 'feedback_daily_limit',
  '[analytics 22] the 6th message on the same Helsinki day is refused');
select is((select count(*) from public.feedback), 5::bigint, '[analytics 22] the learner has exactly 5 messages');
reset role;

-- One of A's messages moved to yesterday (Helsinki) frees one place today.
update public.feedback set created_at = pg_temp.noon(1)
 where id = (select id from public.feedback where message = 'three');
set local role authenticated;
select lives_ok($$ insert into public.feedback (screen, message) values ('finish', 'six again') $$,
  '[analytics 22] the limit counts the Helsinki day: a message from yesterday does not count today');
reset role;
select is((select count(*) from public.feedback where user_id = '00000000-0000-4000-8000-0000000014b1'), 1::bigint,
  '[analytics 22] the other learner''s message was never counted for A');

set local role anon;
select throws_ok($$ select * from public.feedback $$, '42501', null, '[analytics 21] anon cannot read feedback');
select throws_ok($$ insert into public.feedback (screen, message) values ('account', 'x') $$, '42501', null,
  '[analytics 21] anon cannot send feedback');
reset role;

-- =====================================================================================
-- [analytics 16] The owner list
-- =====================================================================================

select columns_are('private', 'owners', array['user_id', 'added_at'],
  '[analytics 16] private.owners holds only user_id and added_at');
select col_is_pk('private', 'owners', 'user_id', '[analytics 16] one row per account');
select fk_ok('private', 'owners', 'user_id', 'auth', 'users', 'id', '[analytics 16] owners.user_id links to auth.users');
select is((select confdeltype::text from pg_constraint where conrelid = 'private.owners'::regclass and contype = 'f'), 'c',
  '[analytics 16] an owner row is deleted with the account');
select table_privs_are('private', 'owners', r, array[]::text[], format('[analytics 16] %s has no permission on private.owners', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;
select ok((select prosecdef from pg_proc where oid = 'public.my_owner_rows()'::regprocedure),
  '[analytics 16] my_owner_rows is security definer');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.my_owner_rows()'::regprocedure),
  '[analytics 16] my_owner_rows runs with an empty search_path');
select ok(has_function_privilege('authenticated', 'public.my_owner_rows()', 'EXECUTE'),
  '[analytics 16] a learner may call my_owner_rows');
select ok(not has_function_privilege(r, 'public.my_owner_rows()', 'EXECUTE'),
  format('[analytics 16] %s may not call my_owner_rows', r))
  from unnest(array['anon', 'service_role']) as r;

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select throws_ok($$ insert into private.owners (user_id) values ('00000000-0000-4000-8000-0000000014a1') $$, '42501', null,
  '[analytics 16] a learner cannot add themselves to the owner list');
select throws_ok($$ select * from private.owners $$, '42501', null,
  '[analytics 16] a learner cannot read the owner list');
select is(public.my_owner_rows(), '[]'::jsonb,
  '[analytics 16] a learner reads only their own owner row, so another account''s row is never seen');
select set_config('pgtap.export_a', (select public.export_my_data())::text, true);
reset role;

select is(current_setting('pgtap.export_a')::jsonb -> 'tables' -> 'private.owners', '[]'::jsonb,
  '[analytics 16] a learner''s download shows an empty owner list');
select is(jsonb_array_length(current_setting('pgtap.export_a')::jsonb -> 'tables' -> 'feedback'), 6,
  '[analytics 23] a learner''s download lists their own feedback');
select is_empty(
  $$ select 1 from jsonb_array_elements(current_setting('pgtap.export_a')::jsonb -> 'tables' -> 'feedback') as r
      where r ->> 'user_id' <> '00000000-0000-4000-8000-0000000014a1' $$,
  '[analytics 23] the download holds no other learner''s feedback');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054f1"}', true);
set local role authenticated;
select is(jsonb_array_length(public.my_owner_rows()), 1, '[analytics 16] the owner reads their own owner row');
reset role;

-- =====================================================================================
-- [analytics 9] Only the owner can run owner_dashboard, from a live sign in
-- =====================================================================================

select has_function('public', 'owner_dashboard', array[]::name[], '[analytics 9] owner_dashboard takes no argument');
select is((select count(*) from pg_proc where proname = 'owner_dashboard'), 1::bigint, '[analytics 9] there is one owner_dashboard');
select ok((select prosecdef from pg_proc where oid = 'public.owner_dashboard()'::regprocedure),
  '[analytics 9] owner_dashboard is security definer');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.owner_dashboard()'::regprocedure),
  '[analytics 9] owner_dashboard runs with an empty search_path');
select is((select provolatile::text from pg_proc where oid = 'public.owner_dashboard()'::regprocedure), 's',
  '[analytics 9] owner_dashboard is stable, so it can write nothing');
select ok(has_function_privilege('authenticated', 'public.owner_dashboard()', 'EXECUTE'),
  '[analytics 9] the authenticated role may call owner_dashboard');
select ok(not has_function_privilege('service_role', 'public.owner_dashboard()', 'EXECUTE'),
  '[analytics 9] service_role may not call owner_dashboard');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.owner_dashboard()'::regprocedure and x.grantee = 0 $$,
  '[analytics 9] PUBLIC may not call owner_dashboard');

-- Condition 3: anon.
set local role anon;
select throws_ok($$ select public.owner_dashboard() $$, '42501', null, '[analytics 9] anon cannot run owner_dashboard');
reset role;

-- Condition 1: a learner with a live sign in who is not on the owner list.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select is(public.owner_dashboard(), null, '[analytics 9] a learner not on the owner list gets nothing');
reset role;

-- Condition 2: an account on the owner list whose sign in was ended.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014f2", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054f2"}', true);
set local role authenticated;
select is(public.owner_dashboard(), null, '[analytics 9] an owner whose sign in was ended gets nothing');
reset role;

-- The owner, with a live sign in.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054f1"}', true);
set local role authenticated;
select isnt(public.owner_dashboard(), null, '[analytics 9] the owner with a live sign in gets the numbers');
reset role;

-- =====================================================================================
-- [analytics 8] [analytics 10] [analytics 11] The numbers, against hand worked answers
-- =====================================================================================
-- T = today in Helsinki. Every session starts at Helsinki noon of its day.
--   L1 guest: sessions on T-10 (5 min) and T-3 (9 min). First day T-10, T-3 = D+7: in the cohort, retained.
--   L2 email: sessions on T-9 (no end) and T (12 min). First day T-9, D+7 = T-2 has no session: in the cohort.
--   L3 guest: sessions on T-40 (outside the window) and T-5 (3 hours: left out of the median).
--   L4 guest: one session today (7 min). D+7 is in the future: not in the cohort.
--   L5 guest: sessions on T-7 (20 min) and T-6 (exactly 2 hours, counted). D+7 = T is not yesterday or before.
--   L6 guest: one session on T-40 only: not active, not in the cohort.
--   O (owner): sessions on T-15 and T-8 and an attempt costing $1. Left out of every number.
-- Active learners: L1 to L5 = 5. Cohort: L1, L2 = 2, retained 1 = 50 percent.
-- Median: 5, 7, 9, 12, 20, 120 minutes -> (9 + 12) / 2 = 10.5 minutes from 6; left out 2 (L2 no end, L3 3 hours).
-- Speak back: L1 (attempt T-3) and L4 (attempt T) = 2 of 5 = 40 percent. L3's attempt on T-40 is outside.
-- Cost: L1 $0.002 + L4 $0.003 = $0.005, $0.001 per active learner. L3 (T-40), L6 (T-35) and O do not count.
-- Visits: T FI 3, T SE 2, T T1 1; T-1 FI 4; T-29 XX 1; T-30 FI 100 (outside the window).

delete from public.feedback;

insert into public.forms (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
values ('pgtap-analytics', 'f-1', 'pgtap-k', 'pgtap-p', 'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review');

insert into public.sessions (user_id, started_at, ended_at)
select s.user_id::uuid, pg_temp.noon(s.days_ago), case when s.minutes is null then null else pg_temp.noon(s.days_ago, s.minutes) end
  from (values
    ('00000000-0000-4000-8000-0000000014c1', 10, 5),
    ('00000000-0000-4000-8000-0000000014c1', 3, 9),
    ('00000000-0000-4000-8000-0000000014c2', 9, null),
    ('00000000-0000-4000-8000-0000000014c2', 0, 12),
    ('00000000-0000-4000-8000-0000000014c3', 40, 15),
    ('00000000-0000-4000-8000-0000000014c3', 5, 180),
    ('00000000-0000-4000-8000-0000000014c4', 0, 7),
    ('00000000-0000-4000-8000-0000000014c5', 7, 20),
    ('00000000-0000-4000-8000-0000000014c5', 6, 120),
    ('00000000-0000-4000-8000-0000000014c6', 40, 10),
    ('00000000-0000-4000-8000-0000000014f1', 15, 1),
    ('00000000-0000-4000-8000-0000000014f1', 8, 1)
  ) as s(user_id, days_ago, minutes);

insert into public.speaking_attempts (user_id, form_id, transcript, feedback_class, provider, audio_ms, cost_usd, created_at)
select a.user_id::uuid, f.id, '', 'clear', 'fake', 1000, a.cost, pg_temp.noon(a.days_ago, 1)
  from (values
    ('00000000-0000-4000-8000-0000000014c1', 3, 0.002),
    ('00000000-0000-4000-8000-0000000014c4', 0, 0.003),
    ('00000000-0000-4000-8000-0000000014c3', 40, 0.5),
    ('00000000-0000-4000-8000-0000000014c6', 35, 0.25),
    ('00000000-0000-4000-8000-0000000014f1', 8, 1.0)
  ) as a(user_id, days_ago, cost)
  cross join public.forms f where f.lemma = 'pgtap-analytics';

insert into private.visit_tallies (day, country, visits) values
  (pg_temp.today(), 'FI', 3),
  (pg_temp.today(), 'SE', 2),
  (pg_temp.today(), 'T1', 1),
  (pg_temp.today() - 1, 'FI', 4),
  (pg_temp.today() - 29, 'XX', 1),
  (pg_temp.today() - 30, 'FI', 100);

-- 52 messages over the last days (at most 5 a day per learner): only the newest 50 are listed.
insert into public.feedback (user_id, screen, message, created_at)
select case when n % 2 = 0 then '00000000-0000-4000-8000-0000000014c1'::uuid else '00000000-0000-4000-8000-0000000014c2'::uuid end,
       (array['front_door', 'account', 'finish'])[1 + n % 3],
       'pgtap feedback number ' || n,
       pg_temp.noon(1 + n / 4, -n)
  from generate_series(1, 52) as n;

-- Crash groups: 21 single groups, one group seen 3 times, and one report 31 days old.
insert into private.crash_reports (created_at, source, group_key, error_name, message, frames, path, app_version, browser)
select now() - make_interval(mins => 10 * n), 'browser', md5('pgtap group ' || n), 'PgtapError' || n, 'pgtap crash',
       '[{"file": "/assets/index.js", "line": 1, "column": 2, "fn": "f"}]', '/', 'local', 'Chrome 130, Android'
  from generate_series(1, 21) as n;
insert into private.crash_reports (created_at, source, group_key, error_name, message, frames, path, app_version, browser)
select now() - make_interval(mins => n), 'browser', md5('pgtap repeated'), 'PgtapRepeated', 'pgtap crash ' || n,
       '[{"file": "/assets/index.js", "line": 3, "column": 4, "fn": "g"}]', '/owner', 'abc1234', 'Safari 17, iOS'
  from generate_series(1, 3) as n;
insert into private.crash_reports (created_at, source, group_key, error_name, message, frames, path, app_version, browser)
values (now() - interval '31 days', 'browser', md5('pgtap old'), 'PgtapOld', 'old', '[]', '/', 'local', 'Chrome 130, Android');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054f1"}', true);
set local role authenticated;
select set_config('pgtap.dash', coalesce(public.owner_dashboard()::text, 'null'), true);
reset role;

create function pg_temp.dash()
returns jsonb
language sql
stable
as $$
  select current_setting('pgtap.dash')::jsonb;
$$;

-- [analytics 11] Exactly the listed keys.
select results_eq(
  $$ select k collate "C" from jsonb_object_keys(pg_temp.dash()) as k order by 1 $$,
  $$ select k collate "C" from unnest(array['active_learners', 'ai_cost_usd', 'computed_at', 'crashes',
       'day7_retention', 'feedback', 'median_session_minutes', 'speak_back', 'visits_by_country',
       'visits_by_day']) as k order by 1 $$,
  '[analytics 8] [analytics 11] the JSON has exactly the ten listed keys');

-- Visits.
select is(jsonb_array_length(pg_temp.dash() -> 'visits_by_day'), 30, '[analytics 8] visits_by_day has one entry for each of the 30 days');
select is(pg_temp.dash() -> 'visits_by_day' -> 0,
  jsonb_build_object('day', pg_temp.today(), 'visits', 6, 'fi', 3),
  '[analytics 8] today: 6 visits, 3 from Finland');
select is(pg_temp.dash() -> 'visits_by_day' -> 1,
  jsonb_build_object('day', pg_temp.today() - 1, 'visits', 4, 'fi', 4),
  '[analytics 8] yesterday: 4 visits, all from Finland');
select is(pg_temp.dash() -> 'visits_by_day' -> 29,
  jsonb_build_object('day', pg_temp.today() - 29, 'visits', 1, 'fi', 0),
  '[analytics 8] the window''s first day: 1 visit, none from Finland');
select is(pg_temp.dash() -> 'visits_by_day' -> 10,
  jsonb_build_object('day', pg_temp.today() - 10, 'visits', 0, 'fi', 0),
  '[analytics 8] a day with no visits shows 0');
select is(pg_temp.dash() -> 'visits_by_country',
  '[{"country": "FI", "visits": 7}, {"country": "SE", "visits": 2}, {"country": "T1", "visits": 1}, {"country": "XX", "visits": 1}]'::jsonb,
  '[analytics 8] countries over the window, largest first; the 100 visits from day T-30 are outside');

-- Learners.
select is(pg_temp.dash() -> 'active_learners', '5'::jsonb, '[analytics 8] 5 active learners; the owner and L6 are not counted');
select is(pg_temp.dash() -> 'day7_retention', '{"retained": 1, "cohort": 2, "percent": 50}'::jsonb,
  '[analytics 8] day 7 retention: 1 of 2, 50 percent');
select is(pg_temp.dash() -> 'median_session_minutes', '{"minutes": 10.5, "used": 6, "left_out": 2}'::jsonb,
  '[analytics 8] median session: 10.5 minutes from 6 sessions, 2 left out');
select is(pg_temp.dash() -> 'speak_back', '{"count": 2, "base": 5, "percent": 40}'::jsonb,
  '[analytics 8] speak back: 2 of 5, 40 percent');
select is((pg_temp.dash() -> 'ai_cost_usd' ->> 'total')::numeric, 0.005::numeric,
  '[analytics 8] [analytics 10] cost: $0.005 in total');
select is((pg_temp.dash() -> 'ai_cost_usd' ->> 'per_active_learner')::numeric, 0.001::numeric,
  '[analytics 8] cost: $0.001 per active learner');

-- Feedback.
select is(jsonb_array_length(pg_temp.dash() -> 'feedback'), 50, '[analytics 8] [analytics 20] the newest 50 messages, no more');
select is(pg_temp.dash() -> 'feedback' -> 0 ->> 'message', 'pgtap feedback number 1',
  '[analytics 8] [analytics 20] the newest message comes first');
select is_empty(
  $$ select 1 from jsonb_array_elements(pg_temp.dash() -> 'feedback') as f
      where (select array_agg(k collate "C" order by k collate "C") from jsonb_object_keys(f) as k)
            is distinct from array['account', 'created_at', 'message', 'screen'] $$,
  '[analytics 11] [analytics 20] each message has only its date, screen, account kind and text');
select results_eq(
  $$ select f ->> 'account' from jsonb_array_elements(pg_temp.dash() -> 'feedback') as f
      where f ->> 'message' in ('pgtap feedback number 1', 'pgtap feedback number 2') order by f ->> 'message' $$,
  $$ values ('email'), ('guest') $$,
  '[analytics 20] the account kind is email or guest');

-- Crashes.
select is(jsonb_array_length(pg_temp.dash() -> 'crashes'), 20, '[analytics 8] [analytics 27] the newest 20 crash groups, no more');
select is(pg_temp.dash() -> 'crashes' -> 0 ->> 'name', 'PgtapRepeated', '[analytics 27] the group seen last comes first');
select is((pg_temp.dash() -> 'crashes' -> 0 ->> 'count')::integer, 3, '[analytics 27] a group shows its count in the last 30 days');
select is(
  (select jsonb_build_object('path', c -> 'path', 'browser', c -> 'browser', 'app_version', c -> 'app_version',
                             'frames', c -> 'frames', 'message', c -> 'message')
     from jsonb_array_elements(pg_temp.dash() -> 'crashes') as c where c ->> 'name' = 'PgtapRepeated'),
  jsonb_build_object('path', '/owner', 'browser', 'Safari 17, iOS', 'app_version', 'abc1234',
                     'frames', '[{"file": "/assets/index.js", "line": 3, "column": 4, "fn": "g"}]'::jsonb,
                     'message', 'pgtap crash 1'),
  '[analytics 27] a group shows the latest report''s path, browser, app version, frames and message');
select is_empty(
  $$ select 1 from jsonb_array_elements(pg_temp.dash() -> 'crashes') as c where c ->> 'name' = 'PgtapOld' $$,
  '[analytics 27] a report older than 30 days is not listed');

-- [analytics 11] No id and no email in the text.
select is_empty(
  $$ select u.id from auth.users u where strpos(pg_temp.dash()::text, u.id::text) > 0
     union all
     select u.id from auth.users u where u.email is not null and strpos(pg_temp.dash()::text, u.email) > 0 $$,
  '[analytics 11] the JSON holds no learner''s user id and no email address');
select ok(strpos(pg_temp.dash()::text, '@') = 0, '[analytics 11] the JSON holds no @ at all');

-- [analytics 10] Every cost_usd column in the project's tables is counted.
select set_eq(
  $$ select n.nspname || '.' || c.relname
       from pg_attribute a join pg_class c on c.oid = a.attrelid join pg_namespace n on n.oid = c.relnamespace
      where a.attname = 'cost_usd' and a.attnum > 0 and not a.attisdropped and c.relkind in ('r', 'p')
        and n.nspname not in ('pg_catalog', 'information_schema', 'auth', 'storage', 'realtime', '_realtime',
          'extensions', 'graphql', 'graphql_public', 'pgsodium', 'pgsodium_masks', 'vault', 'supabase_functions',
          'supabase_migrations', 'net', 'cron', 'pgbouncer', '_analytics', 'pgtle', 'pgmq', '_supavisor',
          'topology', 'tiger', 'tiger_data')
        and n.nspname not like 'pg\_temp%' and n.nspname not like 'pg\_toast%' $$,
  $$ values ('public.speaking_attempts') $$,
  '[analytics 10] the catalogue finds every table with a cost_usd column; a new one must get a seeded row in this file');
select is((pg_temp.dash() -> 'ai_cost_usd' ->> 'total')::numeric,
  (select sum(a.cost_usd) from public.speaking_attempts a
    where a.created_at >= pg_temp.noon(29, -720) and a.user_id not in (select o.user_id from private.owners o)),
  '[analytics 10] the total equals every learner cost row in the window, in every cost table');

-- A new cost table is counted with no change to owner_dashboard (made inside this transaction only).
create table public.pgtap_cost_probe (
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  cost_usd numeric(12, 8) not null
);
insert into public.pgtap_cost_probe (user_id, cost_usd) values ('00000000-0000-4000-8000-0000000014c4', 0.01);
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054f1"}', true);
set local role authenticated;
select is((public.owner_dashboard() -> 'ai_cost_usd' ->> 'total')::numeric, 0.015::numeric,
  '[analytics 10] a cost table added later is counted without changing owner_dashboard');
reset role;
drop table public.pgtap_cost_probe;

-- [analytics 8] Empty data: no division by zero, percentages show as none.
savepoint empty_data;
delete from public.sessions;
delete from public.speaking_attempts;
delete from public.feedback;
delete from private.visit_tallies;
delete from private.crash_reports;
set local role authenticated;
select set_config('pgtap.empty', coalesce(public.owner_dashboard()::text, 'null'), true);
reset role;
select is(current_setting('pgtap.empty')::jsonb -> 'active_learners', '0'::jsonb, '[analytics 8] empty data: 0 active learners');
select is(current_setting('pgtap.empty')::jsonb -> 'day7_retention', '{"retained": 0, "cohort": 0, "percent": null}'::jsonb,
  '[analytics 8] empty data: retention has no percentage');
select is(current_setting('pgtap.empty')::jsonb -> 'median_session_minutes', '{"minutes": null, "used": 0, "left_out": 0}'::jsonb,
  '[analytics 8] empty data: no median');
select is(current_setting('pgtap.empty')::jsonb -> 'speak_back', '{"count": 0, "base": 0, "percent": null}'::jsonb,
  '[analytics 8] empty data: speak back has no percentage');
select is(current_setting('pgtap.empty')::jsonb -> 'ai_cost_usd', '{"total": 0, "per_active_learner": null}'::jsonb,
  '[analytics 8] empty data: no cost per learner');
select is(current_setting('pgtap.empty')::jsonb -> 'visits_by_country', '[]'::jsonb, '[analytics 8] empty data: no countries');
select is(
  (select count(*) from jsonb_array_elements(current_setting('pgtap.empty')::jsonb -> 'visits_by_day') as d
    where d -> 'visits' = '0'::jsonb and d -> 'fi' = '0'::jsonb), 30::bigint,
  '[analytics 8] empty data: 30 days of zero visits');
select is(current_setting('pgtap.empty')::jsonb -> 'feedback', '[]'::jsonb, '[analytics 8] empty data: no feedback');
select is(current_setting('pgtap.empty')::jsonb -> 'crashes', '[]'::jsonb, '[analytics 8] empty data: no crashes');
rollback to savepoint empty_data;

-- =====================================================================================
-- [analytics 26] Crash reports: a narrow door
-- =====================================================================================

delete from private.crash_reports;

select columns_are('private', 'crash_reports',
  array['id', 'created_at', 'source', 'group_key', 'error_name', 'message', 'frames', 'path', 'app_version', 'browser'],
  '[analytics 26] crash_reports has exactly its listed columns');
select is_empty(
  $$ select a.attname from pg_attribute a
      where a.attrelid = 'private.crash_reports'::regclass and a.attnum > 0 and not a.attisdropped
        and a.attname ~ '(user|addr|ip|agent|cookie|header|email|token)' $$,
  '[analytics 25] [analytics 26] no column for a user, address, user agent, cookie or token');
select table_privs_are('private', 'crash_reports', r, array[]::text[],
  format('[analytics 26] %s has no permission on private.crash_reports', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;
select ok((select prosecdef from pg_proc where proname = 'report_crash'), '[analytics 26] report_crash is security definer');
select ok((select proconfig @> array['search_path=""'] from pg_proc where proname = 'report_crash'),
  '[analytics 26] report_crash runs with an empty search_path');
select ok(has_function_privilege('anon', 'public.report_crash(text, text, text, jsonb, text, text, text)', 'EXECUTE'),
  '[analytics 26] anon may call report_crash');
select ok(not has_function_privilege(r, 'public.report_crash(text, text, text, jsonb, text, text, text)', 'EXECUTE'),
  format('[analytics 26] %s may not call report_crash', r))
  from unnest(array['authenticated', 'service_role']) as r;
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.proname = 'report_crash' and x.grantee = 0 $$,
  '[analytics 26] PUBLIC may not call report_crash');

-- One good report, from anon.
set local role anon;
select is(public.report_crash('browser', 'TypeError', 'x is not a function',
            '[{"file": "/assets/index-AbC12.js", "line": 10, "column": 5, "fn": "onClick"}]', '/session', 'abc1234',
            'Chrome 130, Android'),
  true, '[analytics 26] a good report is stored');
select is(public.report_crash('browser', 'TypeError', 'another message',
            '[{"file": "/assets/index-AbC12.js", "line": 10, "column": 5, "fn": "onClick"}]', '/account/:id', 'local',
            'Safari 17, iOS'),
  true, '[analytics 26] a second report of the same error is stored');
select is(public.report_crash('worker', 'TypeError', 'x is not a function',
            '[{"file": "index.js", "line": 1, "column": 2, "fn": "handleApi"}]', '/api/today', 'abc1234', 'Worker'),
  true, '[analytics 26] a Worker report is stored');
select throws_ok($$ select * from private.crash_reports $$, '42501', null, '[analytics 26] anon cannot read crash reports');
reset role;

select is((select count(distinct group_key) from private.crash_reports where source = 'browser'), 1::bigint,
  '[analytics 26] the group comes from the error name and the first frame, not the message or path');
select is((select count(distinct group_key) from private.crash_reports), 2::bigint,
  '[analytics 26] a different first frame (and source) makes a different group');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000014a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000054a1"}', true);
set local role authenticated;
select throws_ok($$ select * from private.crash_reports $$, '42501', null, '[analytics 26] a learner cannot read crash reports');
select throws_ok(
  $$ select public.report_crash('browser', 'Error', 'm', '[]', '/', 'local', 'Chrome 130, Android') $$,
  '42501', null, '[analytics 26] a signed in learner cannot call report_crash');
reset role;

-- Every field is checked again: a direct caller skips the Worker.
set local role anon;
select throws_ok(format($$ select public.report_crash(%L, 'Error', 'm', '[]', '/', 'local', 'Chrome 130, Android') $$, s),
  '22023', null, format('[analytics 26] the source %s is refused', s))
  from unnest(array['server', '']) as s;
select throws_ok(format($$ select public.report_crash('browser', %L, 'm', '[]', '/', 'local', 'Chrome 130, Android') $$, n),
  '22023', null, format('[analytics 26] the error name %s is refused', left(n, 20)))
  from unnest(array['bad name', '1Error', '<script>', repeat('E', 81)]) as n;
select throws_ok(format($$ select public.report_crash('browser', 'Error', %L, '[]', '/', 'local', 'Chrome 130, Android') $$, m),
  '22023', null, format('[analytics 25] [analytics 26] the message %s is refused', left(m, 40)))
  from unnest(array[
    repeat('m', 301),
    'failed for learner@example.com',
    'session 0f8e2b44-6a71-4c3e-9d55-1b2c3d4e5f60 broke',
    'code 123456 was wrong',
    'value AbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIj',
    'bad eyJhbGciOiJIUzI1NiJ9 token',
    'fetch https://puhuscribe.example/api?code=1 failed',
    'line one' || chr(10) || 'line two'
  ]) as m;
select throws_ok(format($$ select public.report_crash('browser', 'Error', 'm', %L::jsonb, '/', 'local', 'Chrome 130, Android') $$, f),
  '22023', null, format('[analytics 25] [analytics 26] the frames %s are refused', left(f, 60)))
  from unnest(array[
    (select jsonb_agg('{"file": "/assets/a.js", "line": 1, "column": 1, "fn": "f"}'::jsonb)::text from generate_series(1, 11)),
    '[{"file": "/assets/a.js", "line": 1, "column": 1, "fn": "f", "user": "x"}]',
    '[{"file": "/assets/../a.js", "line": 1, "column": 1, "fn": "f"}]',
    '[{"file": "https://other.example/a.js", "line": 1, "column": 1, "fn": "f"}]',
    '[{"file": "/assets/a.js", "line": -1, "column": 1, "fn": "f"}]',
    '[{"file": "/assets/a.js", "line": 1, "column": 1, "fn": "<img onerror=x>"}]',
    '{"file": "/assets/a.js"}'
  ]) as f;
select throws_ok(format($$ select public.report_crash('browser', 'Error', 'm', '[]', %L, 'local', 'Chrome 130, Android') $$, p),
  '22023', null, format('[analytics 25] [analytics 26] the path %s is refused', p))
  from unnest(array['/session?id=1', '/session#x', '/api/sessions/123456/step',
                    '/api/sessions/0f8e2b44-6a71-4c3e-9d55-1b2c3d4e5f60/step', 'session', '/a b']) as p;
select throws_ok(format($$ select public.report_crash('browser', 'Error', 'm', '[]', '/', %L, 'Chrome 130, Android') $$, v),
  '22023', null, format('[analytics 26] the app version %s is refused', v))
  from unnest(array['v1', 'ABC1234']) as v;
select throws_ok(format($$ select public.report_crash('browser', 'Error', 'm', '[]', '/', 'local', %L) $$, b),
  '22023', null, format('[analytics 25] [analytics 26] the browser label %s is refused', left(b, 30)))
  from unnest(array['', repeat('b', 41), 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit']) as b;
reset role;

select is((select count(*) from private.crash_reports), 3::bigint, '[analytics 26] the refused reports wrote nothing');

-- 30 an hour per group: 31 tries, 30 stored.
set local role anon;
select is(
  (select count(*) filter (where stored) from (
     select public.report_crash('browser', 'CapError', 'cap', '[]', '/', 'local', 'Chrome 130, Android') as stored
       from generate_series(1, 31)) x),
  30::bigint, '[analytics 26] of 31 reports of one group in an hour, 30 are stored');
reset role;
select is((select count(*) from private.crash_reports where error_name = 'CapError'), 30::bigint,
  '[analytics 26] the 31st report of the group was dropped');

-- An hour later the group may report again.
update private.crash_reports set created_at = now() - interval '61 minutes' where error_name = 'CapError';
set local role anon;
select is(public.report_crash('browser', 'CapError', 'cap', '[]', '/', 'local', 'Chrome 130, Android'), true,
  '[analytics 26] reports older than an hour do not count toward the group cap');
reset role;

-- 300 an hour in total: fill the hour up to 300 with other groups.
insert into private.crash_reports (source, group_key, error_name, message, frames, path, app_version, browser)
select 'browser', md5('pgtap fill ' || n), 'FillError', 'fill', '[]', '/', 'local', 'Chrome 130, Android'
  from generate_series(1, 300 - (select count(*) from private.crash_reports where created_at > now() - interval '1 hour')) as n;
select is((select count(*) from private.crash_reports where created_at > now() - interval '1 hour'), 300::bigint,
  '[analytics 26] the last hour now holds 300 reports');
set local role anon;
select is(public.report_crash('browser', 'NewError', 'new', '[]', '/', 'local', 'Chrome 130, Android'), false,
  '[analytics 26] the 301st report in an hour is dropped, whatever its group');
reset role;
select is((select count(*) from private.crash_reports where error_name = 'NewError'), 0::bigint,
  '[analytics 26] the dropped report was not stored');

-- Thirty days, then gone.
insert into private.crash_reports (created_at, source, group_key, error_name, message, frames, path, app_version, browser)
values (now() - interval '31 days', 'browser', md5('pgtap 31'), 'OldError', 'old', '[]', '/', 'local', 'Chrome 130, Android'),
       (now() - interval '29 days', 'browser', md5('pgtap 29'), 'RecentError', 'recent', '[]', '/', 'local', 'Chrome 130, Android');
select lives_ok($$ select private.forget_old_crash_reports() $$, '[analytics 26] the 30 day clean up runs');
select is((select count(*) from private.crash_reports where error_name = 'OldError'), 0::bigint,
  '[analytics 26] a report older than 30 days is deleted');
select is((select count(*) from private.crash_reports where error_name = 'RecentError'), 1::bigint,
  '[analytics 26] a report from 29 days ago stays');
select is(
  (select count(*) from cron.job
    where jobname = 'forget-old-crash-reports' and schedule = '17 3 * * *'
      and command = 'select private.forget_old_crash_reports()' and active),
  1::bigint, '[analytics 26] pg_cron runs the clean up once a day');
select ok(not has_function_privilege(r, 'private.forget_old_crash_reports()', 'EXECUTE'),
  format('[analytics 26] %s may not run the clean up', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;

-- =====================================================================================
-- [analytics 23] Feedback goes with the account
-- =====================================================================================

select lives_ok($$ delete from auth.users where id = '00000000-0000-4000-8000-0000000014c1' $$,
  '[analytics 23] a learner''s account is deleted');
select is((select count(*) from public.feedback where user_id = '00000000-0000-4000-8000-0000000014c1'), 0::bigint,
  '[analytics 23] their feedback is gone with it');
select lives_ok($$ delete from auth.users where id = '00000000-0000-4000-8000-0000000014f2' $$,
  '[analytics 16] an owner''s account is deleted');
select is((select count(*) from private.owners where user_id = '00000000-0000-4000-8000-0000000014f2'), 0::bigint,
  '[analytics 16] their owner row is gone with it');

select * from finish();

rollback;
