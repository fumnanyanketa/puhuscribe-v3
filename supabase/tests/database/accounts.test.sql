-- Accounts and personal data: my_account, export_my_data, delete_my_account
-- and the daily clean up of unused accounts (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/11-accounts/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.
--
-- Test learners, made inside this transaction (ids end in a1, b1 ...):
--   A  = ...0000000011a1  a guest with a row in every user table
--   B  = ...0000000011b1  an email account with a row in every user table
--   C  = ...0000000011c1  a guest whose sign in was ended (no auth.sessions row)
--   D  = ...0000000011d1  a guest who deletes their own account
-- and the backdated accounts of the clean up tests further down.
-- Acting as a learner means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(70);

-- The user tables, read from the database catalogue ------------------------------
-- Every table, in any schema this project creates, with a column named user_id
-- or a foreign key to auth.users. Supabase's own schemas are skipped by name,
-- so a table in a new project schema is caught too. Names outside public carry
-- their schema ("private.x").

create function pg_temp.user_tables()
returns setof text
language sql
stable
as $$
  select case when n.nspname = 'public' then c.relname::text else n.nspname || '.' || c.relname end
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where c.relkind in ('r', 'p')
     and not c.relispartition
     and n.nspname not in (
       'pg_catalog', 'information_schema', 'auth', 'storage', 'realtime', '_realtime', 'extensions',
       'graphql', 'graphql_public', 'pgsodium', 'pgsodium_masks', 'vault', 'supabase_functions',
       'supabase_migrations', 'net', 'cron', 'pgbouncer', '_analytics', 'pgtle', 'pgmq', '_supavisor',
       'topology', 'tiger', 'tiger_data')
     and n.nspname not like 'pg\_toast%'
     and n.nspname not like 'pg\_temp%'
     and (
       exists (select 1 from pg_attribute a
                where a.attrelid = c.oid and a.attname = 'user_id' and a.attnum > 0 and not a.attisdropped)
       or exists (select 1 from pg_constraint k
                   where k.conrelid = c.oid and k.contype = 'f' and k.confrelid = 'auth.users'::regclass)
     );
$$;

-- How many rows each user table holds for one user: every user_id column and
-- every column that links to auth.users is looked at.
create function pg_temp.rows_of(uid uuid)
returns table (tbl text, n bigint)
language plpgsql
as $$
declare
  t record;
  col text;
  one_column bigint;
  total bigint;
begin
  for t in
    select c.oid, n.nspname, c.relname
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where (case when n.nspname = 'public' then c.relname::text else n.nspname || '.' || c.relname end)
           in (select pg_temp.user_tables())
  loop
    total := 0;
    for col in
      select a.attname from pg_attribute a
       where a.attrelid = t.oid and a.attnum > 0 and not a.attisdropped
         and (a.attname = 'user_id'
              or exists (select 1 from pg_constraint k
                          where k.conrelid = t.oid and k.contype = 'f'
                            and k.confrelid = 'auth.users'::regclass and a.attnum = any (k.conkey)))
    loop
      execute format('select count(*) from %I.%I where %I = $1', t.nspname, t.relname, col)
        into strict one_column using uid;
      total := total + one_column;
    end loop;
    tbl := case when t.nspname = 'public' then t.relname::text else t.nspname || '.' || t.relname end;
    n := total;
    return next;
  end loop;
end;
$$;

-- The columns of one user table, in order.
create function pg_temp.columns_of(tbl text)
returns text[]
language sql
stable
as $$
  select array_agg(a.attname::text collate "C" order by a.attname::text collate "C")
    from pg_attribute a
   where a.attrelid = (case when tbl like '%.%' then tbl else 'public.' || tbl end)::regclass
     and a.attnum > 0 and not a.attisdropped;
$$;

select isnt_empty($$ select pg_temp.user_tables() $$,
  '[accounts 19] the catalogue query finds user tables to check');
select ok('sessions' in (select pg_temp.user_tables()) and 'usage_events' in (select pg_temp.user_tables()),
  '[accounts 19] the catalogue query finds job 3''s and job 8''s user tables');

-- [accounts 3] [accounts 19] [accounts 21] The functions, their settings and who may call them --

select ok((select prosecdef from pg_proc where oid = 'public.my_account()'::regprocedure),
  '[accounts 3] my_account is security definer');
select ok((select prosecdef from pg_proc where oid = 'public.delete_my_account()'::regprocedure),
  '[accounts 21] delete_my_account is security definer');
select ok(not (select prosecdef from pg_proc where oid = 'public.export_my_data()'::regprocedure),
  '[accounts 19] export_my_data is security invoker, so the read rules apply');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = f::regprocedure),
  format('[accounts 3] [accounts 19] [accounts 21] %s runs with an empty search_path', f))
  from unnest(array['public.my_account()', 'public.export_my_data()', 'public.delete_my_account()']) as f;
select ok(has_function_privilege('authenticated', f, 'EXECUTE'),
  format('[accounts 3] [accounts 19] [accounts 21] a learner may call %s', f))
  from unnest(array['public.my_account()', 'public.export_my_data()', 'public.delete_my_account()']) as f;
select ok(not has_function_privilege(r, f, 'EXECUTE'),
  format('[accounts 3] [accounts 19] [accounts 21] %s may not call %s', r, f))
  from unnest(array['public.my_account()', 'public.export_my_data()', 'public.delete_my_account()']) as f,
       unnest(array['anon', 'service_role']) as r;
select is_empty(
  $$ select p.proname from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid in ('public.my_account()'::regprocedure, 'public.export_my_data()'::regprocedure,
                      'public.delete_my_account()'::regprocedure)
        and x.grantee = 0 $$,
  '[accounts 3] [accounts 19] [accounts 21] PUBLIC may call none of the three');
select ok(not has_function_privilege(r, 'private.delete_inactive_guests()', 'EXECUTE'),
  format('[accounts 24] %s may not run the clean up', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;
select ok(not has_function_privilege(r, f, 'EXECUTE'),
  format('[accounts 3] [accounts 23] %s may not call %s', r, f))
  from unnest(array['private.sign_in_is_live()', 'private.user_has_stored_files(uuid)']) as f,
       unnest(array['anon', 'authenticated', 'service_role']) as r;

-- Test content and learners, written as the database owner --------------------------

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values ('pgtap-accounts-unit', 901101, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review');
insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, 'pgtap-accounts-1', 1, 'pgtap dialogue' from public.units u where u.slug = 'pgtap-accounts-unit';
insert into public.forms (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
values ('pgtap-accounts', 'f-1', 'pgtap-k', 'pgtap-p', 'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review');

insert into auth.users (id, is_anonymous, email, created_at) values
  ('00000000-0000-4000-8000-0000000011a1', true, null, now() - interval '1 day'),
  ('00000000-0000-4000-8000-0000000011b1', false, 'learner-b@example.com', now() - interval '1 day'),
  ('00000000-0000-4000-8000-0000000011c1', true, null, now() - interval '1 day'),
  ('00000000-0000-4000-8000-0000000011d1', true, null, now() - interval '1 day');

-- Live sign ins for A, B and D. C has none (signed out).
insert into auth.sessions (id, user_id) values
  ('00000000-0000-4000-8000-0000000051a1', '00000000-0000-4000-8000-0000000011a1'),
  ('00000000-0000-4000-8000-0000000051b1', '00000000-0000-4000-8000-0000000011b1'),
  ('00000000-0000-4000-8000-0000000051d1', '00000000-0000-4000-8000-0000000011d1');

-- One row in every user table for A, B and D.
insert into public.sessions (id, user_id, dialogue_id, step_reached, started_at, ended_at)
select s.id::uuid, s.user_id::uuid, d.id, 'understand', now() - interval '2 hours', now() - interval '1 hour'
  from (values ('00000000-0000-4000-8000-0000000061a1', '00000000-0000-4000-8000-0000000011a1'),
               ('00000000-0000-4000-8000-0000000061b1', '00000000-0000-4000-8000-0000000011b1'),
               ('00000000-0000-4000-8000-0000000061d1', '00000000-0000-4000-8000-0000000011d1')) as s(id, user_id)
  cross join public.dialogues d where d.slug = 'pgtap-accounts-1';
insert into public.cards (user_id, form_id)
select u::uuid, f.id from unnest(array['00000000-0000-4000-8000-0000000011a1', '00000000-0000-4000-8000-0000000011b1',
                                        '00000000-0000-4000-8000-0000000011d1']) as u
  cross join public.forms f where f.lemma = 'pgtap-accounts';
insert into public.review_logs (user_id, form_id, rating, mode, state, due, stability, difficulty, elapsed_days,
                                last_elapsed_days, scheduled_days, review_time)
select u::uuid, f.id, 3, 'typed', 'new', now(), 1, 5, 0, 0, 1, now() - interval '30 minutes'
  from unnest(array['00000000-0000-4000-8000-0000000011a1', '00000000-0000-4000-8000-0000000011b1',
                    '00000000-0000-4000-8000-0000000011d1']) as u
  cross join public.forms f where f.lemma = 'pgtap-accounts';
insert into public.consents (user_id, kind, granted, notice_version)
select u::uuid, 'voice_processing', true, 'v1'
  from unnest(array['00000000-0000-4000-8000-0000000011a1', '00000000-0000-4000-8000-0000000011b1',
                    '00000000-0000-4000-8000-0000000011d1']) as u;
insert into public.usage_events (user_id, name, session_id)
select s.user_id, 'first_session_completed', s.id
  from public.sessions s
 where s.id in ('00000000-0000-4000-8000-0000000061a1', '00000000-0000-4000-8000-0000000061b1',
                '00000000-0000-4000-8000-0000000061d1');

select is_empty(
  $$ select tbl from pg_temp.rows_of('00000000-0000-4000-8000-0000000011a1') where n = 0 $$,
  '[accounts 19] A has a row in every user table, so the export check below covers every table');

-- [accounts 3] anon cannot call any of the three -----------------------------------------

set local role anon;
select throws_ok($$ select * from public.my_account() $$, '42501', null, '[accounts 3] anon cannot call my_account');
select throws_ok($$ select public.export_my_data() $$, '42501', null, '[accounts 19] anon cannot call export_my_data');
select throws_ok($$ select public.delete_my_account() $$, '42501', null, '[accounts 21] anon cannot call delete_my_account');
reset role;

-- [accounts 3] my_account: only the caller's own row, only while the sign in is live --------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011a1", "role": "authenticated", "is_anonymous": true, "session_id": "00000000-0000-4000-8000-0000000051a1"}', true);
set local role authenticated;
select results_eq(
  $$ select id::text, coalesce(email, ''), is_anonymous from public.my_account() $$,
  $$ values ('00000000-0000-4000-8000-0000000011a1', '', true) $$,
  '[accounts 3] A gets exactly A''s own row, as a guest with no email');
reset role;

select is(
  (select array_agg(p.parameter_name::text order by p.ordinal_position)
     from information_schema.parameters p
     join information_schema.routines r on r.specific_name = p.specific_name
    where r.routine_schema = 'public' and r.routine_name = 'my_account' and p.parameter_mode = 'OUT'),
  array['id', 'email', 'is_anonymous', 'created_at', 'last_sign_in_at', 'email_confirmed_at'],
  '[accounts 3] my_account returns id, email, is_anonymous, created_at, last_sign_in_at and email_confirmed_at, nothing else');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011b1", "role": "authenticated", "is_anonymous": false, "session_id": "00000000-0000-4000-8000-0000000051b1"}', true);
set local role authenticated;
select results_eq(
  $$ select id::text, email, is_anonymous from public.my_account() $$,
  $$ values ('00000000-0000-4000-8000-0000000011b1', 'learner-b@example.com', false) $$,
  '[accounts 3] B gets exactly B''s own row, with the email');
reset role;

-- A token naming B's sign in but A's id gets nothing.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000051b1"}', true);
set local role authenticated;
select is_empty($$ select * from public.my_account() $$,
  '[accounts 3] a token whose sign in belongs to another user gets no row');
reset role;

-- A token with no sign in id gets nothing.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011a1", "role": "authenticated"}', true);
set local role authenticated;
select is_empty($$ select * from public.my_account() $$,
  '[accounts 3] a token without a sign in id gets no row');
reset role;

-- C was signed out: the token is still valid, but its sign in row is gone.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011c1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000051c1"}', true);
set local role authenticated;
select is_empty($$ select * from public.my_account() $$,
  '[accounts 3] a signed out token gets no row');
reset role;

-- A's sign in row is removed (signed out): A then gets nothing too.
savepoint a_signed_out;
delete from auth.sessions where id = '00000000-0000-4000-8000-0000000051a1';
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000051a1"}', true);
set local role authenticated;
select is_empty($$ select * from public.my_account() $$,
  '[accounts 3] after A''s sign in row is removed, A gets no row');
reset role;
rollback to savepoint a_signed_out;

-- [accounts 19] export_my_data: every user table, every column, only the caller's rows --------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011a1", "role": "authenticated", "is_anonymous": true, "session_id": "00000000-0000-4000-8000-0000000051a1"}', true);
set local role authenticated;
select set_config('pgtap.export_a', (select public.export_my_data())::text, true);
reset role;

select set_eq(
  $$ select jsonb_object_keys(current_setting('pgtap.export_a')::jsonb -> 'tables') $$,
  $$ select pg_temp.user_tables() $$,
  '[accounts 19] the export has exactly one list per user table found in the catalogue');

select is_empty(
  $$ select r.tbl || ' has ' || r.n || ' rows of A, the export has '
            || jsonb_array_length(coalesce(current_setting('pgtap.export_a')::jsonb -> 'tables' -> r.tbl, '[]'))
       from pg_temp.rows_of('00000000-0000-4000-8000-0000000011a1') r
      where r.n <> jsonb_array_length(coalesce(current_setting('pgtap.export_a')::jsonb -> 'tables' -> r.tbl, '[]')) $$,
  '[accounts 19] for every user table, the export holds every one of A''s rows');

select is_empty(
  $$ select t.key || ': ' || (select string_agg(k, ',' order by k) from jsonb_object_keys(row_data) as k)
       from jsonb_each(current_setting('pgtap.export_a')::jsonb -> 'tables') as t(key, rows)
       cross join lateral jsonb_array_elements(t.rows) as row_data
      where (select array_agg(k collate "C" order by k collate "C") from jsonb_object_keys(row_data) as k)
            is distinct from pg_temp.columns_of(t.key) $$,
  '[accounts 19] every exported row has every column of its table, and nothing else');

select is_empty(
  $$ select t.key from jsonb_each(current_setting('pgtap.export_a')::jsonb -> 'tables') as t(key, rows)
       cross join lateral jsonb_array_elements(t.rows) as row_data
      where row_data::text like '%00000000-0000-4000-8000-0000000011b1%'
         or row_data::text like '%00000000-0000-4000-8000-0000000011d1%'
         or row_data::text like '%00000000-0000-4000-8000-0000000061b1%' $$,
  '[accounts 19] none of B''s or D''s rows appear in A''s export');

select ok(
  (current_setting('pgtap.export_a')::jsonb -> 'tables' -> 'sessions' -> 0 ->> 'id') = '00000000-0000-4000-8000-0000000061a1',
  '[accounts 19] A''s seeded session appears in the export');

-- [accounts 21] delete_my_account: only from a live sign in, only the caller ------------------

-- C's sign in is not live: refused, nothing written.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011c1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000051c1"}', true);
set local role authenticated;
select throws_ok($$ select public.delete_my_account() $$, '28000', null,
  '[accounts 21] a signed out token is refused');
reset role;
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011c1'), 1::bigint,
  '[accounts 21] the signed out user still exists');

-- A token naming D's live sign in but C's id is refused too.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011c1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000051d1"}', true);
set local role authenticated;
select throws_ok($$ select public.delete_my_account() $$, '28000', null,
  '[accounts 21] a token carrying another user''s sign in is refused');
reset role;
select is((select count(*) from auth.users where id in ('00000000-0000-4000-8000-0000000011c1',
                                                         '00000000-0000-4000-8000-0000000011d1')),
  2::bigint, '[accounts 21] after that refusal C and D both still exist');

-- No user id at all.
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.delete_my_account() $$, '28000', null,
  '[accounts 21] a token with no user id is refused');
reset role;

-- D deletes D.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000011d1", "role": "authenticated", "is_anonymous": true, "session_id": "00000000-0000-4000-8000-0000000051d1"}', true);
set local role authenticated;
select lives_ok($$ select public.delete_my_account() $$, '[accounts 21] D can delete D''s own account');
reset role;

select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011d1'), 0::bigint,
  '[accounts 21] D''s auth.users row is gone');
select is_empty(
  $$ select tbl from pg_temp.rows_of('00000000-0000-4000-8000-0000000011d1') where n > 0 $$,
  '[accounts 20] [accounts 21] D has zero rows left in every user table');
select is((select count(*) from auth.sessions where user_id = '00000000-0000-4000-8000-0000000011d1'), 0::bigint,
  '[accounts 21] D''s sign ins are gone');
select is_empty(
  $$ select tbl from pg_temp.rows_of('00000000-0000-4000-8000-0000000011a1') where n = 0
     union all
     select tbl from pg_temp.rows_of('00000000-0000-4000-8000-0000000011b1') where n = 0 $$,
  '[accounts 21] A''s and B''s rows in every user table stay');
select is((select count(*) from auth.users where id in ('00000000-0000-4000-8000-0000000011a1',
                                                         '00000000-0000-4000-8000-0000000011b1',
                                                         '00000000-0000-4000-8000-0000000011c1')),
  3::bigint, '[accounts 21] A, B and C still exist');

-- [accounts 23] Files stored outside the database ----------------------------------------------

select is(private.user_has_stored_files('00000000-0000-4000-8000-0000000011a1'), false,
  '[accounts 23] no learner has stored files today');

-- [accounts 24] [accounts 25] The daily clean up --------------------------------------------------
-- Backdated accounts (ids end in e0..e9):
--   e1 guest, created 91 days ago, a session 95 days ago      -> deleted with its rows
--   e2 guest, created 89 days ago                             -> stays
--   e3 guest, created 200 days ago, a session 10 days ago     -> stays
--   e4 guest, created 200 days ago, a session that started 100 days ago and ended 10 days ago -> stays
--   e5 guest, created 200 days ago, a review 10 days ago      -> stays
--   e6 email account, created 400 days ago                    -> stays
--   e7 email account, created 25 months ago                   -> deleted
--   e8 email account, created 23 months ago                   -> stays
--   e9 guest, inactive 91 days, but with stored files         -> stays

insert into auth.users (id, is_anonymous, email, created_at) values
  ('00000000-0000-4000-8000-0000000011e1', true, null, now() - interval '91 days'),
  ('00000000-0000-4000-8000-0000000011e2', true, null, now() - interval '89 days'),
  ('00000000-0000-4000-8000-0000000011e3', true, null, now() - interval '200 days'),
  ('00000000-0000-4000-8000-0000000011e4', true, null, now() - interval '200 days'),
  ('00000000-0000-4000-8000-0000000011e5', true, null, now() - interval '200 days'),
  ('00000000-0000-4000-8000-0000000011e6', false, 'learner-e6@example.com', now() - interval '400 days'),
  ('00000000-0000-4000-8000-0000000011e7', false, 'learner-e7@example.com', now() - interval '25 months'),
  ('00000000-0000-4000-8000-0000000011e8', false, 'learner-e8@example.com', now() - interval '23 months'),
  ('00000000-0000-4000-8000-0000000011e9', true, null, now() - interval '91 days');

insert into public.sessions (user_id, dialogue_id, step_reached, started_at, ended_at)
select s.user_id::uuid, d.id, 'understand', s.started_at, s.ended_at
  from (values
    ('00000000-0000-4000-8000-0000000011e1', now() - interval '95 days', now() - interval '95 days'),
    ('00000000-0000-4000-8000-0000000011e3', now() - interval '10 days', null),
    ('00000000-0000-4000-8000-0000000011e4', now() - interval '100 days', now() - interval '10 days')
  ) as s(user_id, started_at, ended_at)
  cross join public.dialogues d where d.slug = 'pgtap-accounts-1';
insert into public.cards (user_id, form_id)
select u::uuid, f.id from unnest(array['00000000-0000-4000-8000-0000000011e1', '00000000-0000-4000-8000-0000000011e5']) as u
  cross join public.forms f where f.lemma = 'pgtap-accounts';
insert into public.review_logs (user_id, form_id, rating, mode, state, due, stability, difficulty, elapsed_days,
                                last_elapsed_days, scheduled_days, review_time)
select '00000000-0000-4000-8000-0000000011e5', f.id, 3, 'typed', 'new', now(), 1, 5, 0, 0, 1, now() - interval '10 days'
  from public.forms f where f.lemma = 'pgtap-accounts';

-- e9 has files stored outside the database (a stand in, replaced inside this
-- rolled back transaction only).
create or replace function private.user_has_stored_files(user_id uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  select user_has_stored_files.user_id = '00000000-0000-4000-8000-0000000011e9'::uuid;
$$;

select lives_ok($$ select private.delete_inactive_guests() $$, '[accounts 24] the clean up runs');

select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e1'), 0::bigint,
  '[accounts 24] a guest inactive for 91 days is deleted');
select is_empty(
  $$ select tbl from pg_temp.rows_of('00000000-0000-4000-8000-0000000011e1') where n > 0 $$,
  '[accounts 24] with all its rows in every user table');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e2'), 1::bigint,
  '[accounts 24] a guest inactive for 89 days stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e3'), 1::bigint,
  '[accounts 24] a guest with a session 10 days ago stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e4'), 1::bigint,
  '[accounts 24] a guest whose session ended 10 days ago stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e5'), 1::bigint,
  '[accounts 24] a guest with a review 10 days ago stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e6'), 1::bigint,
  '[accounts 24] [accounts 25] an email account inactive for 400 days stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e7'), 0::bigint,
  '[accounts 25] an email account inactive for 25 months is deleted');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e8'), 1::bigint,
  '[accounts 25] an email account inactive for 23 months stays');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e9'), 1::bigint,
  '[accounts 23] [accounts 24] a guest with stored files is skipped by the clean up');
select is((select count(*) from auth.users where id in ('00000000-0000-4000-8000-0000000011a1',
                                                         '00000000-0000-4000-8000-0000000011b1',
                                                         '00000000-0000-4000-8000-0000000011c1')),
  3::bigint, '[accounts 24] recent accounts stay');

-- With the stand in back to false, e9 is deleted on the next run.
create or replace function private.user_has_stored_files(user_id uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  select false;
$$;
select lives_ok($$ select private.delete_inactive_guests() $$, '[accounts 23] the clean up runs again');
select is((select count(*) from auth.users where id = '00000000-0000-4000-8000-0000000011e9'), 0::bigint,
  '[accounts 23] [accounts 24] without stored files that guest is deleted');

select is(
  (select count(*) from cron.job
    where jobname = 'delete-inactive-accounts' and schedule = '17 3 * * *'
      and command = 'select private.delete_inactive_guests()' and active),
  1::bigint, '[accounts 24] pg_cron runs the clean up once a day');

select * from finish();

rollback;
