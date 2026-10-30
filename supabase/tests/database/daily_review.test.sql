-- Daily review: public.review_queue, public.next_review_day and
-- public.record_review (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/9-daily-review/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.
--
-- Three test learners, made inside this transaction:
--   A = 00000000-0000-4000-8000-0000000009a1 (cards of every kind)
--   B = 00000000-0000-4000-8000-0000000009b1 (one reviewable card, on a form A has no card for)
--   C = 00000000-0000-4000-8000-0000000009c1 (no card at first)
-- Acting as a learner means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated role.
--
-- The test forms get fixed ids (9000901 and up), so every check can name them
-- whatever role it runs as. Card times are set at noon Helsinki time on the
-- Helsinki day a case needs (or to now()), so the tests do not depend on the
-- hour they run at.
--
-- Form ids:
--   9000901 made today            9000907 older due (reviewable)
--   9000902 made yesterday        9000908 same due, lower id (reviewable)
--   9000903 reviewed today        9000909 same due, higher id (reviewable)
--   9000904 due tomorrow          9000910 only B has a card
--   9000905 withdrawn (draft)     9000911 stale reps case (reviewable)
--   9000906 old due (reviewable)  9000912 bad log case (reviewable)

begin;

create extension if not exists pgtap with schema extensions;

select plan(52);

-- Noon, Helsinki time, a number of Helsinki days from today; and today's Helsinki date.
create function pg_temp.helsinki_noon(days integer) returns timestamptz
language sql stable as $$
  select (((now() at time zone 'Europe/Helsinki')::date + days) + time '12:00') at time zone 'Europe/Helsinki'
$$;
create function pg_temp.helsinki_today() returns date
language sql stable as $$ select (now() at time zone 'Europe/Helsinki')::date $$;
grant execute on function pg_temp.helsinki_noon(integer), pg_temp.helsinki_today() to authenticated, anon;

-- [review 18] Three functions, each run as the learner, for learners only ---------

select ok(not (select prosecdef from pg_proc where oid = 'public.review_queue(integer)'::regprocedure),
  '[review 18] review_queue is security invoker');
select ok(not (select prosecdef from pg_proc where oid = 'public.next_review_day()'::regprocedure),
  '[review 18] next_review_day is security invoker');
select ok(not (select prosecdef from pg_proc where proname = 'record_review' and pronamespace = 'public'::regnamespace),
  '[review 18] record_review is security invoker');
select is(
  (select count(*) from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname in ('review_queue', 'next_review_day', 'record_review')
      and proconfig @> array['search_path=""']),
  3::bigint, '[review 18] all three run with an empty search_path');
select is((select count(*) from pg_proc where pronamespace = 'public'::regnamespace and proname = 'record_review'),
  1::bigint, '[review 18] there is exactly one record_review');

select ok(has_function_privilege('authenticated', 'public.review_queue(integer)', 'EXECUTE'),
  '[review 18] a learner may call review_queue');
select ok(has_function_privilege('authenticated', 'public.next_review_day()', 'EXECUTE'),
  '[review 18] a learner may call next_review_day');
select ok(has_function_privilege('authenticated',
  (select oid from pg_proc where proname = 'record_review' and pronamespace = 'public'::regnamespace), 'EXECUTE'),
  '[review 18] a learner may call record_review');
select is(
  (select count(*) from pg_proc p
    where p.pronamespace = 'public'::regnamespace
      and p.proname in ('review_queue', 'next_review_day', 'record_review')
      and (has_function_privilege('anon', p.oid, 'EXECUTE')
           or has_function_privilege('service_role', p.oid, 'EXECUTE'))),
  0::bigint, '[review 18] neither anon nor service_role may call any of the three');
select is_empty(
  $$ select 1 from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.pronamespace = 'public'::regnamespace
        and p.proname in ('review_queue', 'next_review_day', 'record_review')
        and x.grantee = 0 $$,
  '[review 18] PUBLIC may call none of the three');

-- [review 18] Nothing else changed: the tables, enums and job 8's function stay.
select tables_are('public',
  array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms', 'cards', 'review_logs', 'sessions',
        'consents', 'source_sentences', 'lemma_ipa', 'usage_events',
        'speaking_attempts', 'kept_recordings', 'speech_checks', 'feedback'],
  '[review 18] [speak 16] [analytics 21] job 9 added no table; the only others are job 10''s three speaking tables and job 14''s feedback');
select enum_has_labels('public', 'review_mode', array['typed', 'spoken'],
  '[review 18] review_mode is still typed, spoken');
select enum_has_labels('public', 'usage_event_name', array['first_session_completed'],
  '[review 18] usage_event_name is unchanged');
select has_function('public', 'complete_session', array['uuid'], '[review 18] complete_session is still there');

-- Test content and learners, written as the database owner ------------------------
-- Approved forms, one per test case. Cards point at forms only, so no dialogue
-- is needed here.

insert into public.forms
  (id, lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
overriding system value
select 9000900 + n, 'pgtap-daily-review', 'case-' || n, 'pgtap-k-' || n, 'pgtap-p-' || n,
       'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review'
  from generate_series(1, 12) as n;

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000009a1'),
  ('00000000-0000-4000-8000-0000000009b1'),
  ('00000000-0000-4000-8000-0000000009c1');

-- Learner A's cards. created_at, due and last_review are set as each case needs.
insert into public.cards (user_id, form_id, due, created_at, last_review, reps, state)
select '00000000-0000-4000-8000-0000000009a1', x.form_id, x.due, x.created, x.reviewed, x.reps,
       x.state::public.card_state
  from (values
    (9000901, now(),                        now(),                     null::timestamptz,            0, 'new'),
    (9000902, pg_temp.helsinki_noon(-1),    pg_temp.helsinki_noon(-1), null,                         0, 'new'),
    (9000903, now(),                        pg_temp.helsinki_noon(-3), now(),                        1, 'learning'),
    (9000904, pg_temp.helsinki_noon(1),     pg_temp.helsinki_noon(-3), pg_temp.helsinki_noon(-2),    2, 'review'),
    (9000905, pg_temp.helsinki_noon(-2),    pg_temp.helsinki_noon(-2), null,                         0, 'new'),
    (9000906, pg_temp.helsinki_noon(-5),    pg_temp.helsinki_noon(-9), pg_temp.helsinki_noon(-8),    3, 'review'),
    (9000907, pg_temp.helsinki_noon(-6),    pg_temp.helsinki_noon(-9), pg_temp.helsinki_noon(-8),    3, 'review'),
    (9000908, pg_temp.helsinki_noon(-4),    pg_temp.helsinki_noon(-9), null,                         0, 'new'),
    (9000909, pg_temp.helsinki_noon(-4),    pg_temp.helsinki_noon(-9), null,                         0, 'new'),
    (9000911, pg_temp.helsinki_noon(-1),    pg_temp.helsinki_noon(-9), pg_temp.helsinki_noon(-3),    4, 'review'),
    (9000912, pg_temp.helsinki_noon(-1),    pg_temp.helsinki_noon(-9), pg_temp.helsinki_noon(-3),    4, 'review')
  ) as x(form_id, due, created, reviewed, reps, state);

-- Learner B: one reviewable card, on a form A has no card for.
insert into public.cards (user_id, form_id, due, created_at, reps, state)
values ('00000000-0000-4000-8000-0000000009b1', 9000910, pg_temp.helsinki_noon(-1), pg_temp.helsinki_noon(-1), 0, 'new');

-- The withdrawn form goes back to draft after its card was made.
update public.forms set status = 'draft' where id = 9000905;

-- [review 1] [review 2] [review 11] anon can call none of them ------------------------

set local role anon;
select throws_ok($$select * from public.review_queue(15)$$, '42501', null,
  '[review 1] anon cannot call review_queue');
select throws_ok($$select * from public.next_review_day()$$, '42501', null,
  '[review 2] anon cannot call next_review_day');
select throws_ok(
  $$select public.record_review(9000910, 0, now(), 1, 1, 0, 0, 1, 0,
      'learning', now(), 3::smallint, 'typed', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '42501', null, '[review 11] anon cannot call record_review');
reset role;

-- [review 1] Which cards come up, for A ----------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000009a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select ok(9000901 not in (select form_id from public.review_queue(15)),
  '[review 1] a card made today is not returned');
select ok(9000902 in (select form_id from public.review_queue(15)),
  '[review 1] a card made yesterday is returned');
select ok(9000903 not in (select form_id from public.review_queue(15)),
  '[review 1] a card reviewed today is not returned, although its due time has passed');
select ok(9000904 not in (select form_id from public.review_queue(15)),
  '[review 1] a card due tomorrow is not returned');
select ok(9000905 not in (select form_id from public.review_queue(15)),
  '[review 1] a card whose form was set back to draft is not returned');
select ok(9000910 not in (select form_id from public.review_queue(15)),
  '[review 1] B''s card never reaches A');
select results_eq(
  $$select form_id from public.review_queue(15)$$,
  $$values (9000907::bigint), (9000906), (9000908), (9000909), (9000902), (9000911), (9000912)$$,
  '[review 1] A''s reviewable cards come back oldest due first, ties by lowest form id');
select results_eq(
  $$select reps, due from public.review_queue(15) where form_id = 9000906$$,
  $$values (3, pg_temp.helsinki_noon(-5))$$,
  '[review 1] each row gives the form id, reps and due');
select results_eq(
  $$select form_id from public.review_queue(2)$$,
  $$values (9000907::bigint), (9000906)$$,
  '[review 1] the limit holds and keeps the order');
select is((select count(*) from public.review_queue(0)), 0::bigint, '[review 1] a limit of 0 returns nothing');
select is((select count(*) from public.review_queue(-3)), 0::bigint, '[review 1] a negative limit returns nothing');
select is((select count(*) from public.review_queue(null)), 0::bigint, '[review 1] no limit returns nothing');
reset role;

-- [review 1] At most 15, whatever the limit asked for.
insert into public.forms
  (id, lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
overriding system value
select 9000920 + n, 'pgtap-daily-review', 'many-' || n, 'pgtap-k-many', 'pgtap-p-many',
       'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review'
  from generate_series(1, 20) as n;
insert into public.cards (user_id, form_id, due, created_at)
select '00000000-0000-4000-8000-0000000009c1', 9000920 + n, pg_temp.helsinki_noon(-1), pg_temp.helsinki_noon(-1)
  from generate_series(1, 20) as n;
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000009c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select count(*) from public.review_queue(100)), 15::bigint,
  '[review 1] at most 15 cards come back, even when more are reviewable and more are asked for');
reset role;
delete from public.cards where user_id = '00000000-0000-4000-8000-0000000009c1';

-- [review 2] The next review day -------------------------------------------------------

set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), null::date)$$,
  '[review 2] a learner with no cards gets today''s date and no day');
reset role;

-- A card made today: tomorrow.
insert into public.cards (user_id, form_id, due, created_at)
values ('00000000-0000-4000-8000-0000000009c1', 9000901, now(), now());
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), pg_temp.helsinki_today() + 1)$$,
  '[review 2] a card made today becomes reviewable tomorrow');
reset role;

-- Reviewed yesterday and due in five days: that later date.
update public.cards set due = pg_temp.helsinki_noon(5), last_review = pg_temp.helsinki_noon(-1),
       created_at = pg_temp.helsinki_noon(-2)
 where user_id = '00000000-0000-4000-8000-0000000009c1';
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), pg_temp.helsinki_today() + 5)$$,
  '[review 2] a card due in five days becomes reviewable on that later date');
reset role;

-- Reviewed today and due in ten minutes: tomorrow, not later today.
update public.cards set due = now() + interval '10 minutes', last_review = now()
 where user_id = '00000000-0000-4000-8000-0000000009c1';
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), pg_temp.helsinki_today() + 1)$$,
  '[review 2] a card reviewed today comes back tomorrow at the earliest');
reset role;

-- Last touched yesterday, due late tonight: later today.
update public.cards set due = pg_temp.helsinki_noon(0) + interval '11 hours 59 minutes',
       last_review = pg_temp.helsinki_noon(-1)
 where user_id = '00000000-0000-4000-8000-0000000009c1';
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), pg_temp.helsinki_today())$$,
  '[review 2] a card due later today, last touched before today, gives today');
reset role;

-- Only a card whose form went back to draft: no day.
update public.cards set form_id = 9000905 where user_id = '00000000-0000-4000-8000-0000000009c1';
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), null::date)$$,
  '[review 2] a card whose form is not readable gives no day');
select is((select count(*) from public.next_review_day()), 1::bigint, '[review 2] always exactly one row');
reset role;

-- A, with cards reviewable now: today.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000009a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select results_eq(
  $$select today, next_day from public.next_review_day()$$,
  $$values (pg_temp.helsinki_today(), pg_temp.helsinki_today())$$,
  '[review 2] with a card reviewable now, the next review day is today');

-- [review 11] Saving one review ---------------------------------------------------------

-- A records a review on their own card.
select is(
  public.record_review(9000902, 0,
    now() + interval '10 minutes', 3.17, 5.3, 0, 0, 1, 0, 'learning', now(),
    3::smallint, 'typed', 'new', pg_temp.helsinki_noon(-1), 0, 0, 0, 0, 0, now()),
  true, '[review 11] A can record a review on their own card');
select results_eq(
  $$select due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review
      from public.cards where form_id = 9000902$$,
  $$values (now() + interval '10 minutes', 3.17::double precision, 5.3::double precision, 0, 0, 1, 0,
            'learning'::public.card_state, now())$$,
  '[review 11] the card now holds the new values');
select results_eq(
  $$select rating, mode, state, due, stability, difficulty, elapsed_days, last_elapsed_days,
           scheduled_days, review_time, user_id
      from public.review_logs where form_id = 9000902$$,
  $$values (3::smallint, 'typed'::public.review_mode, 'new'::public.card_state, pg_temp.helsinki_noon(-1),
            0::double precision, 0::double precision, 0, 0, 0, now(),
            '00000000-0000-4000-8000-0000000009a1'::uuid)$$,
  '[review 11] one review log row holds the grader''s rating, mode typed and the log values');

-- A stale reps writes nothing.
select is(
  public.record_review(9000911, 3,
    now() + interval '3 days', 9, 4, 2, 3, 4, 0, 'review', now(),
    3::smallint, 'typed', 'review', pg_temp.helsinki_noon(-1), 5, 4, 2, 3, 3, now()),
  false, '[review 11] a stale reps (3, while the card holds 4) returns false');
select results_eq(
  $$select reps, due, last_review from public.cards where form_id = 9000911$$,
  $$values (4, pg_temp.helsinki_noon(-1), pg_temp.helsinki_noon(-3))$$,
  '[review 11] a stale reps leaves the card unchanged');
select is_empty($$select 1 from public.review_logs where form_id = 9000911$$,
  '[review 11] a stale reps adds no review log');

-- A log row that fails its checks leaves the card unchanged.
select throws_ok(
  $$select public.record_review(9000912, 4,
      now() + interval '3 days', 9, 4, 2, 3, 5, 0, 'review', now(),
      5::smallint, 'typed', 'review', pg_temp.helsinki_noon(-1), 5, 4, 2, 3, 3, now())$$,
  '23514', null, '[review 11] a log row with a rating outside 1 to 4 is refused');
select results_eq(
  $$select reps, due, last_review from public.cards where form_id = 9000912$$,
  $$values (4, pg_temp.helsinki_noon(-1), pg_temp.helsinki_noon(-3))$$,
  '[review 11] when the log row fails its checks, the card is unchanged');

-- A cannot record a review on B's card.
select is(
  public.record_review(9000910, 0,
    now() + interval '10 minutes', 3.17, 5.3, 0, 0, 1, 0, 'learning', now(),
    3::smallint, 'typed', 'new', pg_temp.helsinki_noon(-1), 0, 0, 0, 0, 0, now()),
  false, '[review 11] A cannot record a review on B''s card: nothing is found');
reset role;

select results_eq(
  $$select reps, state, last_review from public.cards where user_id = '00000000-0000-4000-8000-0000000009b1'$$,
  $$values (0, 'new'::public.card_state, null::timestamptz)$$,
  '[review 11] B''s card is unchanged after A''s attempt');
select is_empty(
  $$select 1 from public.review_logs where user_id = '00000000-0000-4000-8000-0000000009b1'$$,
  '[review 11] B has no review log after A''s attempt');
select is(
  (select count(*) from public.review_logs where user_id = '00000000-0000-4000-8000-0000000009a1'),
  1::bigint, '[review 11] A has exactly the one review log of their own review');

-- The same call made by B on B's own card succeeds, so A's refusal came from
-- whose card it is, and from nothing else.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000009b1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is(
  public.record_review(9000910, 0,
    now() + interval '10 minutes', 3.17, 5.3, 0, 0, 1, 0, 'learning', now(),
    3::smallint, 'typed', 'new', pg_temp.helsinki_noon(-1), 0, 0, 0, 0, 0, now()),
  true, '[review 11] the same call made by B on B''s own card succeeds');
select is((select count(*) from public.review_logs), 1::bigint, '[review 11] B sees only B''s own review log');
reset role;

select * from finish();

rollback;
