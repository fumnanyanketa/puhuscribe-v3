-- The tutor, Otso: the cost rows of its AI calls, public.tutor_calls, and the reservation that
-- guards every call (pgTAP). Labels in brackets are "Done when" numbers from
-- factory/jobs/16-tutor-step/spec.md:
--   [tutor 19] the caps and rules of reserve_tutor_call
--   [tutor 22] only the owner of a row reads it, and only while it is reserved may they finish it
--   [tutor 24] the rows go with the account
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind, also when it runs
-- against the test project. It uses a published dialogue of stop 4 (the A1 road).
--
-- Test learners, made inside this transaction. Acting as a learner means what PostgREST does: put the
-- token's claims in request.jwt.claims and switch to the authenticated role.
--   A = ...16a1  an email account with tutor consent, the owner of the rows under test
--   B = ...16b1  another email account, with no tutor consent
--   G = ...16c1  a guest with tutor consent

begin;

create extension if not exists pgtap with schema extensions;

select plan(37);

-- [tutor 22] The table and its lock ---------------------------------------------------------------------

select has_table('public', 'tutor_calls', '[tutor 22] public.tutor_calls exists');
select columns_are('public', 'tutor_calls',
  array['id', 'user_id', 'session_id', 'turn', 'attempt', 'created_at', 'provider', 'model', 'outcome',
        'input_tokens', 'output_tokens', 'cost_usd', 'reserved_usd'],
  '[tutor 22] tutor_calls has no column for text, an address or a device');
select ok((select relrowsecurity from pg_class where oid = 'public.tutor_calls'::regclass),
  '[tutor 22] row level security is on');
select table_privs_are('public', 'tutor_calls', 'anon', array[]::text[],
  '[tutor 22] anon has no permission on tutor_calls');
select table_privs_are('public', 'tutor_calls', 'service_role', array[]::text[],
  '[tutor 22] service_role has no permission on tutor_calls');
select table_privs_are('public', 'tutor_calls', 'authenticated', array['SELECT'],
  '[tutor 22] a learner has only SELECT on the whole table: no insert and no delete');
select results_eq(
  $$select (a.attname::text || ' ' || coalesce(r.rolname::text, 'PUBLIC') || ' ' || x.privilege_type::text)
             collate "C"
      from pg_attribute a
      cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
     where a.attrelid = 'public.tutor_calls'::regclass and a.attnum > 0 and not a.attisdropped
     order by 1$$,
  $$select g collate "C" from unnest(array[
      'cost_usd authenticated UPDATE', 'input_tokens authenticated UPDATE', 'model authenticated UPDATE',
      'outcome authenticated UPDATE', 'output_tokens authenticated UPDATE', 'provider authenticated UPDATE'
    ]) as x(g) order by 1$$,
  '[tutor 22] the column grants are exactly: update the outcome, provider, model, tokens and cost');
select is((select confdeltype::text from pg_constraint
            where conrelid = 'public.tutor_calls'::regclass and contype = 'f'
              and conkey = array[(select attnum from pg_attribute
                                   where attrelid = 'public.tutor_calls'::regclass and attname = 'user_id')]),
  'c', '[tutor 24] tutor calls are deleted with the account (on delete cascade)');
select ok(not has_table_privilege('authenticated', 'private.tutor_limits', 'SELECT')
          and not has_table_privilege('anon', 'private.tutor_limits', 'SELECT'),
  '[tutor 19] no API role can read the limits');
select ok((select prosecdef and proconfig @> array['search_path=""'] from pg_proc
            where oid = 'public.reserve_tutor_call(uuid, integer, integer)'::regprocedure),
  '[tutor 19] reserve_tutor_call is security definer with an empty search_path');
select ok(has_function_privilege('authenticated', 'public.reserve_tutor_call(uuid, integer, integer)', 'EXECUTE')
          and not has_function_privilege('anon', 'public.reserve_tutor_call(uuid, integer, integer)', 'EXECUTE')
          and not has_function_privilege('service_role', 'public.reserve_tutor_call(uuid, integer, integer)', 'EXECUTE'),
  '[tutor 19] only authenticated may call reserve_tutor_call');

-- Test learners, sessions and consents, written as the database owner -------------------------------

insert into auth.users (id, is_anonymous) values
  ('00000000-0000-4000-8000-0000000016a1', false),
  ('00000000-0000-4000-8000-0000000016b1', false),
  ('00000000-0000-4000-8000-0000000016c1', true);

insert into public.sessions (id, user_id, dialogue_id, step_reached)
select x.s, x.u, (select d.id from public.dialogues d join public.units u on u.id = d.unit_id
                   where u.stop_number = 4 order by d.id limit 1), 'understand'
  from (values ('00000000-0000-4000-8000-0000000016a2'::uuid, '00000000-0000-4000-8000-0000000016a1'::uuid),
               ('00000000-0000-4000-8000-0000000016b2'::uuid, '00000000-0000-4000-8000-0000000016b1'::uuid),
               ('00000000-0000-4000-8000-0000000016c2'::uuid, '00000000-0000-4000-8000-0000000016c1'::uuid)) as x(s, u);

insert into public.consents (user_id, kind, granted, notice_version) values
  ('00000000-0000-4000-8000-0000000016a1', 'ai_tutor', true, 'tutor-2026-11.1'),
  ('00000000-0000-4000-8000-0000000016c1', 'ai_tutor', true, 'tutor-2026-11.1');

-- B's own row, written as the owner.
insert into public.tutor_calls (id, user_id, session_id, turn, attempt, outcome, reserved_usd) values
  ('00000000-0000-4000-8000-0000000016b3', '00000000-0000-4000-8000-0000000016b1',
   '00000000-0000-4000-8000-0000000016b2', 1, 1, 'reserved', 0.002);

-- Learner A ----------------------------------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000016a1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;

select isnt(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 1, 1), null,
  '[tutor 19] a learner with consent reserves turn 1 of their own session');
select is((select count(*)::int from public.tutor_calls), 1,
  '[tutor 22] the learner sees exactly their own one row');
select is((select outcome::text from public.tutor_calls), 'reserved', '[tutor 19] the new row is reserved');
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 1, 2), null,
  '[tutor 19] one call at a time: a second reservation while the first is reserved is refused');
select throws_ok(
  $$insert into public.tutor_calls (session_id, turn, attempt, reserved_usd)
    values ('00000000-0000-4000-8000-0000000016a2', 1, 1, 0)$$,
  '42501', null, '[tutor 22] a learner cannot add a row directly');
select throws_ok($$update public.tutor_calls set reserved_usd = 0$$, '42501', null,
  '[tutor 22] a learner cannot change reserved_usd');
select lives_ok(
  $$update public.tutor_calls set outcome = 'served', provider = 'anthropic', model = 'claude-haiku-5-5',
      input_tokens = 4000, output_tokens = 40, cost_usd = 0.00042$$,
  '[tutor 22] a learner finishes their own reserved row');
select is((select outcome::text from public.tutor_calls), 'served', '[tutor 22] the row is served');
update public.tutor_calls set outcome = 'failed_check', cost_usd = 0;
select is((select outcome::text || ' ' || cost_usd::text from public.tutor_calls), 'served 0.00042000',
  '[tutor 22] a finished row cannot be changed again');
select throws_ok($$delete from public.tutor_calls$$, '42501', null, '[tutor 22] a learner cannot delete a row');
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016b2', 1, 1), null,
  '[tutor 19] a learner cannot reserve on another learner''s session');
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 4, 1), null,
  '[tutor 19] a fourth turn is refused');
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 3, 1), null,
  '[tutor 19] a turn cannot skip the turn before it');
update public.tutor_calls set outcome = 'served' where id = '00000000-0000-4000-8000-0000000016b3';

-- The second exchange today is allowed, the third is not (max_exchanges_per_day = 2).
select isnt(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 1, 1), null,
  '[tutor 19] a second exchange today is allowed');
update public.tutor_calls set outcome = 'served' where outcome = 'reserved';
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 1, 1), null,
  '[tutor 19] a third exchange today is refused');
select is(public.tutor_allowance(), false, '[tutor 19] tutor_allowance says no exchange is left today');
select isnt(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 2, 1), null,
  '[tutor 19] the next turn of an exchange already started is allowed');
update public.tutor_calls set outcome = 'served' where outcome = 'reserved';

reset role;
select is((select outcome::text from public.tutor_calls where id = '00000000-0000-4000-8000-0000000016b3'),
  'reserved', '[tutor 22] a learner cannot finish another learner''s row');

-- The money cap stops every call.
update private.tutor_limits set monthly_usd = 0;
set local role authenticated;
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016a2', 3, 1), null,
  '[tutor 19] a reached monthly cap refuses the call');
reset role;
update private.tutor_limits set monthly_usd = 10;

-- B's own row is no longer reserved, so only the missing consent refuses B below.
update public.tutor_calls set outcome = 'served' where id = '00000000-0000-4000-8000-0000000016b3';

-- Learner B: sees nothing of A's, and has no consent -------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000016b1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;
select is((select count(*)::int from public.tutor_calls where user_id = '00000000-0000-4000-8000-0000000016a1'), 0,
  '[tutor 22] another learner cannot read the rows');
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016b2', 1, 2), null,
  '[tutor 19] without ai_tutor consent no call is reserved');
reset role;

-- Guest G, with consent: email accounts only ------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000016c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is(public.reserve_tutor_call('00000000-0000-4000-8000-0000000016c2', 1, 1), null,
  '[tutor 19] a guest gets no call while require_email is set');
reset role;

-- anon reaches nothing ----------------------------------------------------------------------------------------

set local role anon;
select throws_ok($$select count(*) from public.tutor_calls$$, '42501', null, '[tutor 22] anon cannot read tutor_calls');
select throws_ok(
  $$select public.reserve_tutor_call('00000000-0000-4000-8000-000000000000', 1, 1)$$,
  '42501', null, '[tutor 22] anon cannot reserve a call');
reset role;

-- A withdrawn ai_tutor consent leaves job 10's voice data alone -----------------------------------------------

insert into public.kept_recordings (user_id, line_id, slot, audio)
select '00000000-0000-4000-8000-0000000016a1', l.id, 'first', decode(repeat('00', 44), 'hex')
  from public.dialogue_lines l order by l.id limit 1;
insert into public.consents (user_id, kind, granted, notice_version) values
  ('00000000-0000-4000-8000-0000000016a1', 'ai_tutor', false, 'tutor-2026-11.1');
select is((select count(*)::int from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000016a1'), 1,
  '[tutor 22] withdrawing the tutor consent does not delete kept recordings (the voice trigger acts on voice values only)');

-- [tutor 24] The rows go with the account ---------------------------------------------------------------------

delete from auth.users where id = '00000000-0000-4000-8000-0000000016a1';
select is((select count(*)::int from public.tutor_calls where user_id = '00000000-0000-4000-8000-0000000016a1'), 0,
  '[tutor 24] deleting the account deletes its tutor calls');

select * from finish();
rollback;
