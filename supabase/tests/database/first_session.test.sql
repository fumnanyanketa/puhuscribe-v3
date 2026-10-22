-- First session: the usage event table and public.complete_session (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/8-first-session/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.
--
-- Two test learners, made inside this transaction:
--   A = 00000000-0000-4000-8000-0000000008a1 (a guest)
--   B = 00000000-0000-4000-8000-0000000008b1 (a guest)
--   C = 00000000-0000-4000-8000-0000000008c1 (a guest with no session and no event)
-- Acting as a learner means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(62);

-- [session 17] The table, its permissions and its rules -------------------------

select has_table('public', 'usage_events', '[session 17] public.usage_events exists');
select columns_are('public', 'usage_events', array['id', 'user_id', 'name', 'session_id', 'created_at'],
  '[session 17] usage_events has exactly id, user_id, name, session_id and created_at: no address, device, browser or free text');
select col_type_is('public', 'usage_events', 'id', 'uuid', '[session 17] usage_events.id is a uuid');
select col_type_is('public', 'usage_events', 'name', 'usage_event_name', '[session 17] usage_events.name is a usage_event_name');
select col_type_is('public', 'usage_events', 'created_at', 'timestamp with time zone',
  '[session 17] usage_events.created_at is a time');
select col_default_is('public', 'usage_events', 'user_id', 'auth.uid()', '[session 17] user_id defaults to the learner''s own id');
select col_default_is('public', 'usage_events', 'created_at', 'now()', '[session 17] created_at is set by the database');
select enum_has_labels('public', 'usage_event_name', array['first_session_completed'],
  '[session 17] usage_event_name has the single value first_session_completed');
select fk_ok('public', 'usage_events', 'session_id', 'public', 'sessions', 'id',
  '[session 17] usage_events.session_id links to sessions');
select is(
  (select confdeltype::text from pg_constraint
    where conrelid = 'public.usage_events'::regclass and contype = 'f'
      and confrelid = 'public.sessions'::regclass),
  'c', '[session 17] deleting a session deletes its events');
select ok((select relrowsecurity from pg_class where oid = 'public.usage_events'::regclass),
  '[session 17] row level security is on for usage_events');
select table_privs_are('public', 'usage_events', 'anon', array[]::text[], '[session 17] anon has no permission on usage_events');
select table_privs_are('public', 'usage_events', 'service_role', array[]::text[],
  '[session 17] service_role has no permission on usage_events');
select table_privs_are('public', 'usage_events', 'authenticated', array['SELECT'],
  '[session 17] a learner may only read usage_events (whole table permission)');
select column_privs_are('public', 'usage_events', c, 'authenticated', p,
  format('[session 17] usage_events.%s: a learner may %s', c, array_to_string(p, ', ')))
  from (values
    ('id', array['SELECT']),
    ('user_id', array['INSERT', 'SELECT']),
    ('name', array['INSERT', 'SELECT']),
    ('session_id', array['INSERT', 'SELECT']),
    ('created_at', array['SELECT'])
  ) as x(c, p);
select policies_are('public', 'usage_events',
  array['learners read their own events', 'learners add events for their own finished sessions'],
  '[session 17] usage_events has exactly its two rules');
select matches(
  (select indexdef from pg_indexes where schemaname = 'public' and indexname = 'usage_events_one_first_session_idx'),
  '^CREATE UNIQUE INDEX usage_events_one_first_session_idx ON public\.usage_events USING btree \(user_id\) WHERE \(name = ''first_session_completed''::(public\.)?usage_event_name\)$',
  '[session 17] a unique index allows one first_session_completed per learner');

-- [session 17] The function runs as the learner, with an empty search path, for learners only.
select ok(not (select prosecdef from pg_proc where oid = 'public.complete_session(uuid)'::regprocedure),
  '[session 17] complete_session is security invoker');
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = 'public.complete_session(uuid)'::regprocedure),
  '[session 17] complete_session runs with an empty search_path');
select ok(has_function_privilege('authenticated', 'public.complete_session(uuid)', 'EXECUTE'),
  '[session 17] a learner may call complete_session');
select ok(not has_function_privilege('anon', 'public.complete_session(uuid)', 'EXECUTE'),
  '[session 17] anon may not call complete_session');
select ok(not has_function_privilege('service_role', 'public.complete_session(uuid)', 'EXECUTE'),
  '[session 17] service_role may not call complete_session');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.oid = 'public.complete_session(uuid)'::regprocedure and x.grantee = 0 $$,
  '[session 17] PUBLIC may not call complete_session');

-- [session 21] The smoke test table is gone.
select hasnt_table('public', 'visits', '[session 21] public.visits was dropped');

-- Test content and learners, written as the database owner ------------------------
-- Dialogue 1 links forms in-1, in-2 and in-3 (approved) and withdrawn (set back
-- to draft after its line was approved), plus one word with no form.
-- Dialogue 2 links in-1 and only-in-2.

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values ('pgtap-first-session-unit', 900201, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review');

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, 'pgtap dialogue'
  from (values ('pgtap-first-session-1', 1), ('pgtap-first-session-2', 2)) as d(slug, position)
  cross join public.units u
 where u.slug = 'pgtap-first-session-unit';

insert into public.forms (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
select 'pgtap-first-session', tag, 'pgtap-k-' || tag, 'pgtap-p-' || tag, 'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review'
  from unnest(array['in-1', 'in-2', 'in-3', 'withdrawn', 'only-in-2']) as tag;

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, 1, 'pgtap speaker', 'pgtap puhe', 'pgtap kirja', l.gloss, 'pgtap/p.mp3', 'pgtap/k.mp3'
  from (values ('pgtap-first-session-1', 'pgtap first session line 1'),
               ('pgtap-first-session-2', 'pgtap first session line 2')) as l(dialogue_slug, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, t.register::public.finnish_register, t.position, 'pgtap-token', f.id
  from (values
    ('pgtap first session line 1', 'puhe', 1, 'in-1'),
    ('pgtap first session line 1', 'puhe', 2, 'in-2'),
    ('pgtap first session line 1', 'puhe', 3, 'withdrawn'),
    ('pgtap first session line 1', 'puhe', 4, null),
    ('pgtap first session line 1', 'kirja', 1, 'in-1'),
    ('pgtap first session line 1', 'kirja', 2, 'in-3'),
    ('pgtap first session line 2', 'puhe', 1, 'in-1'),
    ('pgtap first session line 2', 'kirja', 1, 'only-in-2')
  ) as t(gloss, register, position, form_tag)
  join public.dialogue_lines l on l.gloss_en = t.gloss
  left join public.forms f on f.lemma = 'pgtap-first-session' and f.form_tag = t.form_tag;

update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where gloss_en in ('pgtap first session line 1', 'pgtap first session line 2');
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where slug in ('pgtap-first-session-1', 'pgtap-first-session-2');
update public.forms set status = 'draft' where lemma = 'pgtap-first-session' and form_tag = 'withdrawn';

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000008a1'),
  ('00000000-0000-4000-8000-0000000008b1'),
  ('00000000-0000-4000-8000-0000000008c1');

-- Sessions, written as the owner so each starts at the step a test needs.
insert into public.sessions (id, user_id, dialogue_id, step_reached, started_at)
select s.id::uuid, s.user_id::uuid, d.id, s.step::public.loop_step, now() - interval '1 hour'
  from (values
    ('00000000-0000-4000-8000-00000000a001', '00000000-0000-4000-8000-0000000008a1', 'pgtap-first-session-1', 'understand'),
    ('00000000-0000-4000-8000-00000000a002', '00000000-0000-4000-8000-0000000008a1', 'pgtap-first-session-1', 'hear'),
    ('00000000-0000-4000-8000-00000000a003', '00000000-0000-4000-8000-0000000008a1', 'pgtap-first-session-1', null),
    ('00000000-0000-4000-8000-00000000a004', '00000000-0000-4000-8000-0000000008a1', 'pgtap-first-session-2', 'understand'),
    ('00000000-0000-4000-8000-00000000b001', '00000000-0000-4000-8000-0000000008b1', 'pgtap-first-session-1', 'understand')
  ) as s(id, user_id, dialogue_slug, step)
  join public.dialogues d on d.slug = s.dialogue_slug;

-- [session 17] anon can neither read the events nor call the function ------------

set local role anon;
select throws_ok($$select * from public.usage_events$$, '42501', null,
  '[session 17] anon cannot read usage_events');
select throws_ok($$select public.complete_session('00000000-0000-4000-8000-00000000b001')$$, '42501', null,
  '[session 17] anon cannot call complete_session');
reset role;

-- Learner B finishes their session first ------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000008b1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select lives_ok($$select public.complete_session('00000000-0000-4000-8000-00000000b001')$$,
  '[session 15] B can complete their own session');
reset role;

-- Learner A ----------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000008a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is_empty($$select 1 from public.usage_events$$,
  '[session 17] A cannot read B''s events');

-- [session 16] Nothing unmet enters review.
select throws_ok($$select public.complete_session('00000000-0000-4000-8000-00000000a003')$$, '22023', null,
  '[session 16] complete_session refuses a session whose step is empty');
select throws_ok($$select public.complete_session('00000000-0000-4000-8000-00000000a002')$$, '22023', null,
  '[session 16] complete_session refuses a session whose step is hear');
select throws_ok($$select public.complete_session('00000000-0000-4000-8000-00000000b001')$$, 'P0002', null,
  '[session 16] [session 17] complete_session refuses another learner''s session, so A cannot make cards through B''s session');
select is_empty($$select 1 from public.cards$$,
  '[session 16] after the three refusals A has no card');
select is_empty($$select 1 from public.usage_events$$,
  '[session 16] after the three refusals A has no event');
select is_empty(
  $$select 1 from public.sessions
     where id in ('00000000-0000-4000-8000-00000000a002', '00000000-0000-4000-8000-00000000a003')
       and ended_at is not null$$,
  '[session 16] the refused sessions were not ended');

-- [session 17] A cannot add an event for someone else, or before finishing.
select throws_ok(
  $$insert into public.usage_events (name, session_id)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000b001')$$,
  '42501', 'new row violates row-level security policy for table "usage_events"',
  '[session 17] A cannot add an event carrying B''s session');
select throws_ok(
  $$insert into public.usage_events (name, session_id)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000a002')$$,
  '42501', 'new row violates row-level security policy for table "usage_events"',
  '[session 17] A cannot add an event for a session at step hear');
select throws_ok(
  $$insert into public.usage_events (name, session_id)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000a004')$$,
  '42501', 'new row violates row-level security policy for table "usage_events"',
  '[session 17] A cannot add an event for a session at understand that has not ended');
select throws_ok(
  $$insert into public.usage_events (name, session_id, created_at)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000a001', now() - interval '1 day')$$,
  '42501', null,
  '[session 17] A cannot choose an event''s time');

-- [session 17] The step part of the rule on its own: a learner can set their own
-- end time through job 3's update grant, so a session can be ended while still
-- at hear. Every other part of the rule passes here (own id, own session, ended,
-- and A has no event yet), so only the step part can refuse it.
select lives_ok(
  $$update public.sessions set ended_at = now() where id = '00000000-0000-4000-8000-00000000a002'$$,
  '[session 17] A can end their own session at hear through the job 3 update grant');
select throws_ok(
  $$insert into public.usage_events (name, session_id)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000a002')$$,
  '42501', 'new row violates row-level security policy for table "usage_events"',
  '[session 17] A cannot add an event for an ended session that only reached hear');

-- [session 15] Completing A's session: one transaction, cards and one event.
select lives_ok($$select public.complete_session('00000000-0000-4000-8000-00000000a001')$$,
  '[session 15] A can complete their own session at understand');
select is(
  (select ended_at from public.sessions where id = '00000000-0000-4000-8000-00000000a001'),
  now(), '[session 15] the session has its end time');
select set_eq(
  $$select form_id from public.cards$$,
  $$select id from public.forms where lemma = 'pgtap-first-session' and form_tag in ('in-1', 'in-2', 'in-3')$$,
  '[session 15] [session 16] A has one card per distinct approved form in the dialogue: none for the withdrawn form, none for a form only in the second dialogue'
);
select is_empty(
  $$select 1 from public.cards c join public.forms f on f.id = c.form_id
     where f.lemma = 'pgtap-first-session' and f.form_tag = 'only-in-2'$$,
  '[session 16] no card for a form that appears only in the second dialogue');
select results_eq(
  $$select distinct due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review
      from public.cards$$,
  $$values (now(), 0::double precision, 0::double precision, 0, 0, 0, 0, 'new'::public.card_state, null::timestamptz)$$,
  '[session 15] every new card has the default values, equal to createEmptyCard()'
);
select results_eq(
  $$select name::text, session_id from public.usage_events$$,
  $$values ('first_session_completed', '00000000-0000-4000-8000-00000000a001'::uuid)$$,
  '[session 15] A has exactly one first_session_completed event, for this session'
);
reset role;

-- Calling it again changes nothing. The end time is moved back first, so a
-- second end time would show.
update public.sessions set ended_at = now() - interval '30 minutes'
 where id = '00000000-0000-4000-8000-00000000a001';
set local role authenticated;
select lives_ok($$select public.complete_session('00000000-0000-4000-8000-00000000a001')$$,
  '[session 15] calling complete_session again succeeds');
select is(
  (select ended_at from public.sessions where id = '00000000-0000-4000-8000-00000000a001'),
  now() - interval '30 minutes', '[session 15] the second call keeps the first end time');
select is((select count(*) from public.cards), 3::bigint, '[session 15] the second call adds no second card');
select is((select count(*) from public.usage_events), 1::bigint, '[session 15] the second call adds no second event');

-- [session 17] The id part of the rule on its own: A001 is A's own session,
-- at understand and ended, and C has no event, so only the user id part can
-- refuse an event carrying C's id (evaluation, round 1).
select throws_ok(
  $$insert into public.usage_events (user_id, name, session_id)
    values ('00000000-0000-4000-8000-0000000008c1', 'first_session_completed', '00000000-0000-4000-8000-00000000a001')$$,
  '42501', 'new row violates row-level security policy for table "usage_events"',
  '[session 17] A cannot add an event carrying another learner''s id, even for A''s own finished session');
select throws_ok(
  $$insert into public.usage_events (name, session_id)
    values ('first_session_completed', '00000000-0000-4000-8000-00000000a001')$$,
  '23505', null,
  '[session 17] A cannot add a second first_session_completed, even for a finished session');
select throws_ok($$update public.usage_events set name = 'first_session_completed'$$, '42501', null,
  '[session 17] A cannot change an event');
select throws_ok($$delete from public.usage_events$$, '42501', null,
  '[session 17] A cannot delete an event');
reset role;

-- As the owner: B's own rows were not touched by A ----------------------------------

select is(
  (select count(*) from public.usage_events where user_id = '00000000-0000-4000-8000-0000000008b1'),
  1::bigint, '[session 17] B still has exactly one event');
select is(
  (select count(*) from public.cards where user_id = '00000000-0000-4000-8000-0000000008b1'),
  3::bigint, '[session 15] B''s completed session also gave B one card per approved form');

-- [session 17] Deleting a user removes their events -------------------------------

delete from auth.users where id = '00000000-0000-4000-8000-0000000008a1';
select is_empty(
  $$select 1 from public.usage_events where user_id = '00000000-0000-4000-8000-0000000008a1'$$,
  '[session 17] deleting A from auth.users removed A''s events');
select is(
  (select count(*) from public.usage_events where user_id = '00000000-0000-4000-8000-0000000008b1'),
  1::bigint, '[session 17] B''s event stays');

select * from finish();

rollback;
