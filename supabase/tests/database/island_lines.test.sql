-- Language islands: the learner's own island lines, public.island_lines (pgTAP).
-- Labels in brackets name what each test protects, from the islands fast route (3 November 2026,
-- factory/run-plan.md, "Language islands in the MVP"):
--   [islands lock]    only the learner can read and write their own island
--   [islands shape]   one choice from the stop's list, a first name only at stop 1, no other free text
--   [islands account] the island is in the data export and goes with the account
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind, also when it runs
-- against the test project.
--
-- Test learners, made inside this transaction. Acting as a learner means what PostgREST does: put the
-- token's claims in request.jwt.claims and switch to the authenticated role.
--   A = ...00a1  the owner of the rows under test (a guest)
--   B = ...00b1  another learner
--   C = ...00c1  a learner whose account is deleted at the end

begin;

create extension if not exists pgtap with schema extensions;

select plan(41);

-- [islands lock] The table, its link to the account and its lock ---------------------------------

select has_table('public', 'island_lines', '[islands lock] public.island_lines exists');
select columns_are('public', 'island_lines',
  array['user_id', 'stop_number', 'choice', 'first_name', 'created_at', 'updated_at'],
  '[islands shape] island_lines has exactly user_id, stop_number, choice, first_name and the two times');
select col_is_pk('public', 'island_lines', array['user_id', 'stop_number'],
  '[islands shape] one row per learner per stop');
select fk_ok('public', 'island_lines', 'user_id', 'auth', 'users', 'id',
  '[islands account] island_lines.user_id links to auth.users');
select is((select confdeltype::text from pg_constraint
            where conrelid = 'public.island_lines'::regclass and contype = 'f'), 'c',
  '[islands account] island lines are deleted with the account (on delete cascade)');
select ok((select relrowsecurity from pg_class where oid = 'public.island_lines'::regclass),
  '[islands lock] row level security is on');
select table_privs_are('public', 'island_lines', 'anon', array[]::text[],
  '[islands lock] anon has no permission on island_lines');
select table_privs_are('public', 'island_lines', 'service_role', array[]::text[],
  '[islands lock] service_role has no permission on island_lines');
select table_privs_are('public', 'island_lines', 'authenticated', array['SELECT'],
  '[islands lock] a learner has only SELECT as a whole table permission (inserts and updates are by column)');
select results_eq(
  $$select (a.attname::text || ' ' || coalesce(r.rolname::text, 'PUBLIC') || ' ' || x.privilege_type::text)
             collate "C"
      from pg_attribute a
      cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
     where a.attrelid = 'public.island_lines'::regclass and a.attnum > 0 and not a.attisdropped
     order by 1$$,
  $$select g collate "C" from unnest(array[
      'choice authenticated INSERT', 'choice authenticated UPDATE',
      'first_name authenticated INSERT', 'first_name authenticated UPDATE',
      'stop_number authenticated INSERT',
      'user_id authenticated INSERT'
    ]) as x(g) order by 1$$,
  '[islands lock] the column grants are exactly: insert user, stop, choice and name; update choice and name; to authenticated only');

-- Test learners, written as the database owner ------------------------------------------------------

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000000a1'),
  ('00000000-0000-4000-8000-0000000000b1'),
  ('00000000-0000-4000-8000-0000000000c1');

-- B's own line and C's own line, written as the owner.
insert into public.island_lines (user_id, stop_number, choice) values
  ('00000000-0000-4000-8000-0000000000b1', 2, 3),
  ('00000000-0000-4000-8000-0000000000c1', 2, 1);

-- Learner A, the owner of the rows under test --------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select lives_ok(
  $$insert into public.island_lines (stop_number, choice, first_name) values (1, 0, 'Ada')$$,
  '[islands lock] a learner adds their own stop 1 line with a first name');
select lives_ok(
  $$insert into public.island_lines (user_id, stop_number, choice)
    values ('00000000-0000-4000-8000-0000000000a1', 2, 1)$$,
  '[islands lock] a learner adds their own stop 2 line, naming their own id');
select lives_ok(
  $$insert into public.island_lines (stop_number, choice) values (15, null)$$,
  '[islands shape] a line with no list (stop 15) is added with no choice');
select results_eq(
  $$select stop_number::int, choice::int, first_name from public.island_lines order by stop_number$$,
  $$values (1, 0, 'Ada'::text), (2, 1, null::text), (15, null::int, null::text)$$,
  '[islands lock] a learner reads exactly their own three lines, and none of B''s or C''s');
select lives_ok(
  $$update public.island_lines set choice = 4 where stop_number = 2$$,
  '[islands lock] a learner changes the choice of their own line');
select lives_ok(
  $$update public.island_lines set first_name = 'Ada-Maria' where stop_number = 1$$,
  '[islands lock] a learner changes their own first name');
select results_eq(
  $$select stop_number::int, choice::int, first_name from public.island_lines order by stop_number$$,
  $$values (1, 0, 'Ada-Maria'::text), (2, 4, null::text), (15, null::int, null::text)$$,
  '[islands lock] the learner''s own changes are kept');
select throws_ok(
  $$insert into public.island_lines (user_id, stop_number, choice)
    values ('00000000-0000-4000-8000-0000000000b1', 3, 0)$$,
  '42501', null,
  '[islands lock] a learner cannot add a line in another learner''s name');
select throws_ok(
  $$update public.island_lines set user_id = '00000000-0000-4000-8000-0000000000b1' where stop_number = 2$$,
  '42501', null,
  '[islands lock] a learner cannot move their own line to another learner');
select throws_ok(
  $$update public.island_lines set stop_number = 3 where stop_number = 2$$,
  '42501', null,
  '[islands shape] a learner cannot move a line to another stop');
select throws_ok(
  $$delete from public.island_lines where stop_number = 2$$,
  '42501', null,
  '[islands lock] nobody deletes a line: rows go with the account');

-- [islands shape] Each rule refuses on its own: every other part of these rows is valid.
select throws_ok(
  $$insert into public.island_lines (stop_number, choice) values (10, null)$$,
  '23514', null,
  '[islands shape] a stop with no line (10) is refused');
select throws_ok(
  $$insert into public.island_lines (stop_number, choice) values (3, 4)$$,
  '23514', null,
  '[islands shape] a choice past the end of the stop''s list (stop 3 has four) is refused');
select throws_ok(
  $$insert into public.island_lines (stop_number, choice) values (3, null)$$,
  '23514', null,
  '[islands shape] a stop with a list needs a choice');
select throws_ok(
  $$insert into public.island_lines (stop_number, choice) values (30, 0)$$,
  '23514', null,
  '[islands shape] a line with no list (stop 30) takes no choice');
select throws_ok(
  $$insert into public.island_lines (stop_number, choice, first_name) values (4, 0, 'Ada')$$,
  '23514', null,
  '[islands shape] a first name anywhere but stop 1 is refused (no other free text)');
select throws_ok(
  $$update public.island_lines set first_name = null where stop_number = 1$$,
  '23514', null,
  '[islands shape] stop 1 keeps a first name');
select throws_ok(
  $$update public.island_lines set first_name = repeat('a', 31) where stop_number = 1$$,
  '23514', null,
  '[islands shape] a first name of 31 characters is refused');
select throws_ok(
  $$update public.island_lines set first_name = 'Ada2' where stop_number = 1$$,
  '23514', null,
  '[islands shape] a first name with a digit is refused');
select throws_ok(
  $$update public.island_lines set first_name = 'Ada <b>' where stop_number = 1$$,
  '23514', null,
  '[islands shape] a first name with markup characters is refused');
select throws_ok(
  $$update public.island_lines set first_name = ' Ada' where stop_number = 1$$,
  '23514', null,
  '[islands shape] a first name with a space at its start is refused');

-- [islands account] The export lists the learner's own island, and only theirs.
select is(
  (select jsonb_array_length(public.export_my_data() -> 'tables' -> 'island_lines')), 3,
  '[islands account] the export lists the learner''s three island lines');
select ok(
  (select bool_and(r ->> 'user_id' = '00000000-0000-4000-8000-0000000000a1')
     from jsonb_array_elements(public.export_my_data() -> 'tables' -> 'island_lines') r),
  '[islands account] every exported island line is the learner''s own');

reset role;

-- Learner B, another learner ----------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000b1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;

select results_eq(
  $$select stop_number::int, choice::int from public.island_lines order by stop_number$$,
  $$values (2, 3)$$,
  '[islands lock] another learner reads only their own line, never A''s');
-- B may change B's own choices, so this update runs, but row level security hides A's rows from it.
-- The owner's read at the end shows A's lines unchanged.
select lives_ok(
  $$update public.island_lines set choice = 0 where user_id = '00000000-0000-4000-8000-0000000000a1'$$,
  '[islands lock] another learner''s update of A''s lines reaches no row (checked below as the owner)');
select throws_ok(
  $$insert into public.island_lines (user_id, stop_number, choice, first_name)
    values ('00000000-0000-4000-8000-0000000000a1', 3, 0, null)$$,
  '42501', null,
  '[islands lock] another learner cannot add a line to A''s island');

reset role;

-- An anonymous visitor -----------------------------------------------------------------------------

select set_config('request.jwt.claims', '{"role": "anon"}', true);
set local role anon;

select throws_ok($$select * from public.island_lines$$, '42501', null,
  '[islands lock] an anonymous visitor cannot read any island line');
select throws_ok(
  $$insert into public.island_lines (user_id, stop_number, choice)
    values ('00000000-0000-4000-8000-0000000000a1', 3, 0)$$,
  '42501', null,
  '[islands lock] an anonymous visitor cannot add an island line');
select throws_ok(
  $$update public.island_lines set choice = 0 where stop_number = 2$$,
  '42501', null,
  '[islands lock] an anonymous visitor cannot change an island line');

reset role;

-- As the owner: A's rows are as A left them, B's change reached nothing --------------------------

select results_eq(
  $$select stop_number::int, choice::int, first_name from public.island_lines
     where user_id = '00000000-0000-4000-8000-0000000000a1' order by stop_number$$,
  $$values (1, 0, 'Ada-Maria'::text), (2, 4, null::text), (15, null::int, null::text)$$,
  '[islands lock] A''s lines hold A''s own changes only: B''s update reached none of them');

-- [islands account] Deleting the account deletes the island.
delete from auth.users where id = '00000000-0000-4000-8000-0000000000c1';
select is_empty(
  $$select 1 from public.island_lines where user_id = '00000000-0000-4000-8000-0000000000c1'$$,
  '[islands account] deleting an account deletes its island lines');

select * from finish();
rollback;
