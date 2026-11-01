-- Save progress note: public.save_progress_note (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/18-save-progress/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.
--
-- Test learners, made inside this transaction (all guests unless a test sets
-- the token's claim otherwise). Acting as a learner means what PostgREST does:
-- put the token's claims in request.jwt.claims and switch to the authenticated
-- role.
--   A = ...0018a1  six sessions: a1 first finished (the event names it), ar a
--                  review only session finished between a1 and a2, a2, a3 and
--                  a4 finished, ao open
--   B = ...0018b1  one finished session b1, the event names it
--   C = ...0018c1  an event that names B's session b1 (written as the owner,
--                  because no learner can do it): only the owner condition can
--                  refuse C
--   D = ...0018d1  an event that names an open session: only the ended
--                  condition can refuse D
--   E = ...0018e1  an event that names a review only session: only the dialogue
--                  condition can refuse E
--   F = ...0018f1  three finished sessions and the event names the third: the
--                  first note wins over the reminder
--   G = ...0018a2  a first session, then two sessions that ended at the same
--                  moment: the session id breaks the tie

begin;

create extension if not exists pgtap with schema extensions;

select plan(33);

-- [save-progress 4] The function, its kind and its permissions --------------------

select has_function('public', 'save_progress_note', array['uuid'],
  '[save-progress 4] public.save_progress_note(uuid) exists');
select is(
  (select prorettype::regtype::text from pg_proc where oid = 'public.save_progress_note(uuid)'::regprocedure),
  'text', '[save-progress 4] it returns text, so no type was created');
select ok(not (select prosecdef from pg_proc where oid = 'public.save_progress_note(uuid)'::regprocedure),
  '[save-progress 4] it is security invoker, so the learner''s own read rules apply');
select is(
  (select provolatile::text from pg_proc where oid = 'public.save_progress_note(uuid)'::regprocedure),
  's', '[save-progress 4] it is stable, so Postgres refuses any write inside it');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.save_progress_note(uuid)'::regprocedure),
  '[save-progress 4] it runs with an empty search_path');
select ok(has_function_privilege('authenticated', 'public.save_progress_note(uuid)', 'EXECUTE'),
  '[save-progress 4] a learner may call it');
select ok(not has_function_privilege('anon', 'public.save_progress_note(uuid)', 'EXECUTE'),
  '[save-progress 4] anon may not call it');
select ok(not has_function_privilege('service_role', 'public.save_progress_note(uuid)', 'EXECUTE'),
  '[save-progress 4] service_role may not call it');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.save_progress_note(uuid)'::regprocedure and x.grantee = 0 $$,
  '[save-progress 4] PUBLIC may not call it');

-- Test content and learners, written as the database owner ------------------------

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values ('pgtap-save-progress-unit', 900301, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review');

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, 'pgtap dialogue'
  from (values
    ('pgtap-save-progress-1', 1), ('pgtap-save-progress-2', 2),
    ('pgtap-save-progress-3', 3), ('pgtap-save-progress-4', 4)
  ) as d(slug, position)
  cross join public.units u
 where u.slug = 'pgtap-save-progress-unit';

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000018a1'),
  ('00000000-0000-4000-8000-0000000018a2'),
  ('00000000-0000-4000-8000-0000000018b1'),
  ('00000000-0000-4000-8000-0000000018c1'),
  ('00000000-0000-4000-8000-0000000018d1'),
  ('00000000-0000-4000-8000-0000000018e1'),
  ('00000000-0000-4000-8000-0000000018f1');

-- Sessions: id, learner, dialogue slug (empty for review only), how long ago it ended (empty: still open).
insert into public.sessions (id, user_id, dialogue_id, step_reached, started_at, ended_at)
select s.id::uuid, s.user_id::uuid, d.id, 'understand'::public.loop_step,
       now() - interval '1 day',
       case when s.ended_ago is null then null else now() - s.ended_ago::interval end
  from (values
    ('00000000-0000-4000-8000-00000000c001', '00000000-0000-4000-8000-0000000018a1', 'pgtap-save-progress-1', '5 hours'),
    ('00000000-0000-4000-8000-00000000c002', '00000000-0000-4000-8000-0000000018a1', null, '4 hours 30 minutes'),
    ('00000000-0000-4000-8000-00000000c003', '00000000-0000-4000-8000-0000000018a1', 'pgtap-save-progress-2', '4 hours'),
    ('00000000-0000-4000-8000-00000000c004', '00000000-0000-4000-8000-0000000018a1', 'pgtap-save-progress-3', '3 hours'),
    ('00000000-0000-4000-8000-00000000c005', '00000000-0000-4000-8000-0000000018a1', 'pgtap-save-progress-4', '2 hours'),
    ('00000000-0000-4000-8000-00000000c006', '00000000-0000-4000-8000-0000000018a1', 'pgtap-save-progress-1', null),
    ('00000000-0000-4000-8000-00000000d001', '00000000-0000-4000-8000-0000000018b1', 'pgtap-save-progress-1', '5 hours'),
    ('00000000-0000-4000-8000-00000000d101', '00000000-0000-4000-8000-0000000018d1', 'pgtap-save-progress-1', null),
    ('00000000-0000-4000-8000-00000000d201', '00000000-0000-4000-8000-0000000018e1', null, '5 hours'),
    ('00000000-0000-4000-8000-00000000f001', '00000000-0000-4000-8000-0000000018f1', 'pgtap-save-progress-1', '5 hours'),
    ('00000000-0000-4000-8000-00000000f002', '00000000-0000-4000-8000-0000000018f1', 'pgtap-save-progress-2', '4 hours'),
    ('00000000-0000-4000-8000-00000000f003', '00000000-0000-4000-8000-0000000018f1', 'pgtap-save-progress-3', '3 hours'),
    ('00000000-0000-4000-8000-00000000a001', '00000000-0000-4000-8000-0000000018a2', 'pgtap-save-progress-1', '5 hours'),
    ('00000000-0000-4000-8000-00000000a002', '00000000-0000-4000-8000-0000000018a2', 'pgtap-save-progress-2', '3 hours'),
    ('00000000-0000-4000-8000-00000000a003', '00000000-0000-4000-8000-0000000018a2', 'pgtap-save-progress-3', '3 hours')
  ) as s(id, user_id, dialogue_slug, ended_ago)
  left join public.dialogues d on d.slug = s.dialogue_slug;

-- The first_session_completed events job 8 would have written.
insert into public.usage_events (user_id, name, session_id) values
  ('00000000-0000-4000-8000-0000000018a1', 'first_session_completed', '00000000-0000-4000-8000-00000000c001'),
  ('00000000-0000-4000-8000-0000000018b1', 'first_session_completed', '00000000-0000-4000-8000-00000000d001'),
  ('00000000-0000-4000-8000-0000000018c1', 'first_session_completed', '00000000-0000-4000-8000-00000000d001'),
  ('00000000-0000-4000-8000-0000000018d1', 'first_session_completed', '00000000-0000-4000-8000-00000000d101'),
  ('00000000-0000-4000-8000-0000000018e1', 'first_session_completed', '00000000-0000-4000-8000-00000000d201'),
  ('00000000-0000-4000-8000-0000000018f1', 'first_session_completed', '00000000-0000-4000-8000-00000000f003'),
  ('00000000-0000-4000-8000-0000000018a2', 'first_session_completed', '00000000-0000-4000-8000-00000000a001');

-- [save-progress 4] anon is refused ------------------------------------------------

set local role anon;
select throws_ok($$select public.save_progress_note('00000000-0000-4000-8000-00000000c001')$$, '42501', null,
  '[save-progress 4] anon cannot call save_progress_note');
reset role;

-- Learner A, a guest ---------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c001')), 'first',
  '[save-progress 4] a guest''s first finished session returns first');
-- Only the "is this the event''s session" condition can refuse these: A is a guest, the
-- sessions are A''s own, dialogue sessions, and ended.
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c003')), 'none',
  '[save-progress 4] [save-progress 7] the caller''s second finished session returns none (only the first session condition refuses it)');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c005')), 'none',
  '[save-progress 4] [save-progress 8] the fourth finished session returns none');
-- The outcome tests: two conditions refuse together, so these prove the result and not one rule.
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c006')), 'none',
  '[save-progress 4] an open session returns none (outcome test for never mid session: the ended condition and the first session condition both refuse it)');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c002')), 'none',
  '[save-progress 4] [save-progress 8] a review only session returns none and is not counted');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000ffff')), 'none',
  '[save-progress 4] a session id that does not exist returns none and raises no error');
select is((select public.save_progress_note(null)), 'none',
  '[save-progress 4] no session id returns none and raises no error');

-- [save-progress 8] The reminder. The review only session is not counted, so a3 is the third.
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c004')), 'reminder',
  '[save-progress 8] a guest''s third finished dialogue session returns reminder, with the review only session not counted');

-- The token's claim, on its own: the same sessions, the same learner, a token that is not a guest.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018a1", "role": "authenticated", "is_anonymous": false}', true);
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c001')), 'none',
  '[save-progress 4] [save-progress 5] a token with is_anonymous false on an otherwise valid first session returns none (only the guest condition refuses it)');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c004')), 'none',
  '[save-progress 8] a token with is_anonymous false returns none on the third session too');
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018a1", "role": "authenticated"}', true);
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c001')), 'none',
  '[save-progress 4] a token with no is_anonymous claim counts as not a guest');
reset role;

-- Learner B, a guest with one finished session --------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018b1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000d001')), 'first',
  '[save-progress 4] B gets first for B''s own first finished session');
reset role;

-- Learner C: the event names B's session --------------------------------------------
-- C is a guest, the event is C's, the session is finished and has a dialogue. Only
-- the condition that the session is the caller's own can refuse C. Two things
-- enforce it, the check in the function and B's read rule, so a test that removes
-- one of them stays green; the scratch run removes both.

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000d001')), 'none',
  '[save-progress 4] [save-progress 7] a session id that belongs to another learner returns none, even when the caller''s event names it');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000c004')), 'none',
  '[save-progress 4] [save-progress 8] another learner''s third finished session returns none for the caller');
reset role;

-- Learner D: the event names an open session -----------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018d1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000d101')), 'none',
  '[save-progress 4] a session that has not ended returns none, even when the caller''s event names it (only the ended condition refuses it)');
reset role;

-- Learner E: the event names a review only session -----------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018e1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000d201')), 'none',
  '[save-progress 4] a session with no dialogue returns none, even when the caller''s event names it (only the dialogue condition refuses it)');
reset role;

-- Learner F: the event names the third finished session ------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018f1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000f003')), 'first',
  '[save-progress 8] first still wins when the first session is also the third finished one');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000f002')), 'none',
  '[save-progress 4] F''s second finished session returns none');
reset role;

-- Learner G: two sessions ended at the same moment -----------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000018a2", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000a003')), 'reminder',
  '[save-progress 8] with two sessions ended at the same moment, the larger session id is the third');
select is((select public.save_progress_note('00000000-0000-4000-8000-00000000a002')), 'none',
  '[save-progress 8] and the smaller session id is the second');
reset role;

-- [save-progress 4] It writes nothing. Calling it, as the learner, changed no row. ------

select is((select count(*) from public.usage_events), 7::bigint,
  '[save-progress 4] after all the calls there are still exactly the seven events written above');
select is((select count(*) from public.sessions where ended_at is null), 2::bigint,
  '[save-progress 4] after all the calls the two open sessions are still open');

-- [save-progress 13] Nothing new is stored: the job adds one function and nothing else.
select is(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'save_progress_note'),
  1::bigint, '[save-progress 13] there is exactly one save_progress_note function');

select * from finish();

rollback;
