-- Reviewer sign ups: the table, its one door in and the owner's two functions (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/reviewers/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project. It first removes every sign up it
-- can see, so the daily limits count only its own; the rollback puts them back.
--
-- Test accounts (ids end in 24..):
--   O  = ...0000000024f1  on the owner list, with a live sign in
--   O2 = ...0000000024f2  on the owner list, sign in ended (no auth.sessions row)
--   A  = ...0000000024a1  a guest learner with a live sign in
-- Acting as someone means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated (or anon) role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(62);

delete from private.reviewer_signups;

insert into auth.users (id, is_anonymous, email, created_at) values
  ('00000000-0000-4000-8000-0000000024f1', false, 'owner-24@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000024f2', false, 'owner-24-ended@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000024a1', true, null, now() - interval '60 days');

insert into auth.sessions (id, user_id) values
  ('00000000-0000-4000-8000-0000000064f1', '00000000-0000-4000-8000-0000000024f1'),
  ('00000000-0000-4000-8000-0000000064a1', '00000000-0000-4000-8000-0000000024a1');

insert into private.owners (user_id) values
  ('00000000-0000-4000-8000-0000000024f1'),
  ('00000000-0000-4000-8000-0000000024f2');

-- =====================================================================================
-- [reviewers 2] The table holds a name, an email, an optional thank-you name and a time
-- =====================================================================================

select columns_are('private', 'reviewer_signups', array['id', 'name', 'email', 'thanks_name', 'created_at'],
  '[reviewers 2] reviewer_signups has exactly id, name, email, thanks_name and created_at');
select col_not_null('private', 'reviewer_signups', 'name', '[reviewers 2] the name is required');
select col_not_null('private', 'reviewer_signups', 'email', '[reviewers 2] the email is required');
select col_is_null('private', 'reviewer_signups', 'thanks_name', '[reviewers 2] the thank-you name is optional');
select hasnt_fk('private', 'reviewer_signups', '[reviewers 2] a sign up links to no account');

-- =====================================================================================
-- [reviewers 4] The browser roles get nothing on the table
-- =====================================================================================

select ok((select relrowsecurity from pg_class where oid = 'private.reviewer_signups'::regclass),
  '[reviewers 4] row level security is on for reviewer_signups');
select is_empty($$ select policyname from pg_policies where schemaname = 'private' and tablename = 'reviewer_signups' $$,
  '[reviewers 4] reviewer_signups has no rule, so no API role may read or write a row directly');
select table_privs_are('private', 'reviewer_signups', r, array[]::text[],
  format('[reviewers 4] %s has no permission on reviewer_signups', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;
select is_empty(
  $$ select 1 from pg_class c cross join lateral aclexplode(c.relacl) x
      where c.oid = 'private.reviewer_signups'::regclass and x.grantee = 0 $$,
  '[reviewers 4] PUBLIC has no permission on reviewer_signups');
select is_empty(
  $$ select 1 from pg_attribute a cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
      where a.attrelid = 'private.reviewer_signups'::regclass and a.attnum > 0
        and (x.grantee = 0 or r.rolname in ('anon', 'authenticated', 'service_role')) $$,
  '[reviewers 4] no API role has a column permission on reviewer_signups');

-- =====================================================================================
-- [reviewers 4] Only anon (the Worker) may run the one door in
-- =====================================================================================

select ok((select prosecdef from pg_proc where oid = 'public.sign_up_reviewer(text, text, text)'::regprocedure),
  '[reviewers 4] sign_up_reviewer is security definer');
select ok((select proconfig @> array['search_path=""'] from pg_proc
            where oid = 'public.sign_up_reviewer(text, text, text)'::regprocedure),
  '[reviewers 4] sign_up_reviewer runs with an empty search_path');
select ok(has_function_privilege('anon', 'public.sign_up_reviewer(text, text, text)', 'EXECUTE'),
  '[reviewers 4] anon may call sign_up_reviewer');
select ok(not has_function_privilege(r, 'public.sign_up_reviewer(text, text, text)', 'EXECUTE'),
  format('[reviewers 4] %s may not call sign_up_reviewer', r))
  from unnest(array['authenticated', 'service_role']) as r;
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.sign_up_reviewer(text, text, text)'::regprocedure and x.grantee = 0 $$,
  '[reviewers 4] PUBLIC may not call sign_up_reviewer');

set local role anon;
select is(public.sign_up_reviewer('  Aino Virtanen ', ' Aino@Example.FI ', ''), true,
  '[reviewers 2] anon saves one sign up');
select throws_ok($$ select * from private.reviewer_signups $$, '42501', null,
  '[reviewers 4] anon cannot read reviewer_signups');
select throws_ok($$ insert into private.reviewer_signups (name, email) values ('x', 'x@example.fi') $$, '42501', null,
  '[reviewers 4] anon cannot add a row directly');
select throws_ok($$ delete from private.reviewer_signups $$, '42501', null,
  '[reviewers 4] anon cannot delete rows');
reset role;

select results_eq(
  $$ select name, email, thanks_name from private.reviewer_signups $$,
  $$ values ('Aino Virtanen'::text, 'aino@example.fi'::text, null::text) $$,
  '[reviewers 2] one row: the name and email trimmed, the email in lower case, an empty thank-you name stored as none');
select ok((select created_at between now() - interval '1 minute' and now() from private.reviewer_signups),
  '[reviewers 2] the row has the time from the database clock');

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000064a1"}', true);
set local role authenticated;
select throws_ok($$ select public.sign_up_reviewer('Learner', 'learner@example.fi', null) $$, '42501', null,
  '[reviewers 4] a signed in learner cannot call sign_up_reviewer');
select throws_ok($$ select * from private.reviewer_signups $$, '42501', null,
  '[reviewers 4] a signed in learner cannot read reviewer_signups');
select throws_ok($$ update private.reviewer_signups set name = 'x' $$, '42501', null,
  '[reviewers 4] a signed in learner cannot change reviewer_signups');
reset role;

-- =====================================================================================
-- [reviewers 3] The database refuses anything outside the limits, writing nothing
-- =====================================================================================

set local role anon;
select throws_ok($$ select public.sign_up_reviewer('', 'a@example.fi', null) $$, '22023', null,
  '[reviewers 3] an empty name is refused');
select throws_ok($$ select public.sign_up_reviewer('   ', 'a@example.fi', null) $$, '22023', null,
  '[reviewers 3] a name of spaces only is refused');
select throws_ok($$ select public.sign_up_reviewer(null, 'a@example.fi', null) $$, '22023', null,
  '[reviewers 3] no name is refused');
select throws_ok($$ select public.sign_up_reviewer(repeat('a', 101), 'a@example.fi', null) $$, '22023', null,
  '[reviewers 3] a name of 101 characters is refused');
select is(public.sign_up_reviewer(repeat('ä', 100), 'long-name@example.fi', null), true,
  '[reviewers 3] a name of exactly 100 characters (letters with marks count once) is saved');
select throws_ok($$ select public.sign_up_reviewer(E'Ai\nno', 'a@example.fi', null) $$, '22023', null,
  '[reviewers 3] a name with a control character is refused');
select throws_ok($$ select public.sign_up_reviewer('Aino', 'not an email', null) $$, '22023', null,
  '[reviewers 3] an address that is not an email is refused');
select throws_ok($$ select public.sign_up_reviewer('Aino', 'aino@localhost', null) $$, '22023', null,
  '[reviewers 3] an address with no dot after the @ is refused');
select throws_ok($$ select public.sign_up_reviewer('Aino', null, null) $$, '22023', null,
  '[reviewers 3] no email is refused');
select throws_ok($$ select public.sign_up_reviewer('Aino', repeat('a', 244) || '@example.fi', null) $$, '22023', null,
  '[reviewers 3] an email of 255 characters is refused');
select is(public.sign_up_reviewer('Aino', repeat('a', 243) || '@example.fi', null), true,
  '[reviewers 3] an email of exactly 254 characters is saved');
select throws_ok($$ select public.sign_up_reviewer('Aino', 'thanks@example.fi', repeat('b', 101)) $$, '22023', null,
  '[reviewers 3] a thank-you name of 101 characters is refused');
select is(public.sign_up_reviewer('Aino', 'thanks@example.fi', repeat('b', 100)), true,
  '[reviewers 3] a thank-you name of exactly 100 characters is saved');
reset role;
select is((select count(*) from private.reviewer_signups), 4::bigint,
  '[reviewers 3] the refused calls wrote nothing: only the four saved sign ups are there');

-- At most 3 sign ups from one email address a Helsinki day.
set local role anon;
select is(public.sign_up_reviewer('Eero', 'eero@example.fi', null), true, '[reviewers 3] a first sign up from one email is saved');
select is(public.sign_up_reviewer('Eero', 'EERO@example.fi', 'Eero K'), true, '[reviewers 3] a second is saved');
select is(public.sign_up_reviewer('Eero', 'eero@example.fi', null), true, '[reviewers 3] a third is saved');
select is(public.sign_up_reviewer('Eero', ' eero@example.fi ', null), false,
  '[reviewers 3] a fourth from the same email on the same day is refused, whatever its case or spaces');
select is(public.sign_up_reviewer('Ella', 'ella@example.fi', null), true,
  '[reviewers 3] another email can still sign up');
reset role;
-- Yesterday's sign ups do not count towards today.
update private.reviewer_signups set created_at = created_at - interval '2 days' where email = 'eero@example.fi';
set local role anon;
select is(public.sign_up_reviewer('Eero', 'eero@example.fi', null), true,
  '[reviewers 3] sign ups from earlier days do not count towards today');
reset role;

-- At most 200 sign ups in all on one Helsinki day.
insert into private.reviewer_signups (name, email)
  select 'Filler', format('filler-%s@example.fi', n) from generate_series(1, 200 - (
    select count(*) from private.reviewer_signups where created_at >= ((now() at time zone 'Europe/Helsinki')::date::timestamp at time zone 'Europe/Helsinki'))) as n;
set local role anon;
select is(public.sign_up_reviewer('Late', 'late@example.fi', null), false,
  '[reviewers 3] the 201st sign up of the day is refused');
reset role;
delete from private.reviewer_signups where name = 'Filler';

-- =====================================================================================
-- [reviewers 5] Only the owner, with a live sign in, reads and deletes the sign ups
-- =====================================================================================

select ok(not has_function_privilege(r, 'public.owner_reviewer_signups()', 'EXECUTE'),
  format('[reviewers 4] [reviewers 5] %s may not call owner_reviewer_signups', r))
  from unnest(array['anon', 'service_role']) as r;
select ok(not has_function_privilege(r, 'public.owner_delete_reviewer_signup(uuid)', 'EXECUTE'),
  format('[reviewers 4] [reviewers 5] %s may not call owner_delete_reviewer_signup', r))
  from unnest(array['anon', 'service_role']) as r;
select is((select provolatile::text from pg_proc where oid = 'public.owner_reviewer_signups()'::regprocedure), 's',
  '[reviewers 5] owner_reviewer_signups is stable, so it can write nothing');

-- A learner who is not on the owner list.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000064a1"}', true);
set local role authenticated;
select is(public.owner_reviewer_signups(), null, '[reviewers 5] a learner not on the owner list gets nothing');
select is(public.owner_delete_reviewer_signup((select gen_random_uuid())), null,
  '[reviewers 5] a learner not on the owner list cannot delete');
reset role;

-- An account on the owner list whose sign in was ended.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024f2", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000064f2"}', true);
set local role authenticated;
select is(public.owner_reviewer_signups(), null, '[reviewers 5] an owner whose sign in was ended gets nothing');
reset role;

-- The owner, with a live sign in.
update private.reviewer_signups set created_at = now() - interval '3 hours' where name = 'Ella';
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000024f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000064f1"}', true);
set local role authenticated;
select is(jsonb_array_length(public.owner_reviewer_signups()), 9,
  '[reviewers 5] the owner sees every sign up');
select is(public.owner_reviewer_signups() -> -1 ->> 'name', 'Eero',
  '[reviewers 5] newest first: the oldest (two days ago) is last');
select is((select array_agg(k order by k) from jsonb_object_keys(public.owner_reviewer_signups() -> 0) as k),
  array['created_at', 'email', 'id', 'name', 'thanks_name'],
  '[reviewers 5] each sign up has its id, name, email, thank-you name and date');
select is(public.owner_delete_reviewer_signup((select (r ->> 'id')::uuid from jsonb_array_elements(public.owner_reviewer_signups()) r
                                                where r ->> 'name' = 'Ella')), true,
  '[reviewers 5] the owner deletes one sign up');
select is(public.owner_delete_reviewer_signup('00000000-0000-4000-8000-000000000000'), false,
  '[reviewers 5] deleting a sign up that is not there says so');
select is(jsonb_array_length(public.owner_reviewer_signups()), 8,
  '[reviewers 5] the deleted sign up is gone, and only that one');
reset role;

select * from finish();

rollback;
