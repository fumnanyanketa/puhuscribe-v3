-- Data model: learner data rules (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/3-data-model/spec.md that each test protects.
--
-- Two test learners, made inside this transaction and rolled back with it:
--   A = 00000000-0000-4000-8000-0000000000a1, a guest (token claim is_anonymous: true)
--   B = 00000000-0000-4000-8000-0000000000b1, an email account (is_anonymous: false)
--   C = 00000000-0000-4000-8000-0000000000c1, a guest used only for the card rule tests
-- Acting as a learner means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(108);

-- Test content and users, written as the database owner -----------------------------
-- Everything starts as a draft and is approved in the order the pipeline must use:
-- forms, then lines (with their words), then dialogues.

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values ('pgtap-learners-unit', 900101, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review');

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, 'pgtap dialogue'
  from (values
    ('pgtap-learners-dialogue', 1),
    ('pgtap-learners-dialogue-second', 2),
    ('pgtap-learners-dialogue-draft', 3),
    ('pgtap-learners-dialogue-with-draft-line', 4),
    ('pgtap-learners-dialogue-retired-later', 5)
  ) as d(slug, position)
  cross join public.units u
 where u.slug = 'pgtap-learners-unit';

insert into public.forms (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
select 'pgtap-learners', tag, 'pgtap-k-' || tag, 'pgtap-p-' || tag, 'pgtap form', 'pgtap why', 'approved', now(), 'pgtap review'
  from unnest(array['in-dialogue', 'met-but-no-card', 'not-in-dialogue', 'only-on-a-card', 'set-to-draft-later',
                    'only-on-a-retired-line', 'only-on-a-draft-line', 'only-in-a-dialogue-retired-later']) as tag;

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, l.position, 'pgtap speaker', 'pgtap puhe', 'pgtap kirja', l.gloss, 'pgtap/p.mp3', 'pgtap/k.mp3'
  from (values
    ('pgtap-learners-dialogue', 1, 'pgtap learners line'),
    ('pgtap-learners-dialogue', 2, 'pgtap learners retired line'),
    ('pgtap-learners-dialogue-second', 1, 'pgtap learners second line'),
    ('pgtap-learners-dialogue-with-draft-line', 1, 'pgtap learners line beside a draft line'),
    ('pgtap-learners-dialogue-with-draft-line', 2, 'pgtap learners draft line'),
    ('pgtap-learners-dialogue-retired-later', 1, 'pgtap learners line of a dialogue retired later')
  ) as l(dialogue_slug, position, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, t.register::public.finnish_register, t.position, 'pgtap-learners-token', f.id
  from (values
    ('pgtap learners line', 'puhe', 1, 'in-dialogue'),
    ('pgtap learners line', 'puhe', 2, 'set-to-draft-later'),
    ('pgtap learners line', 'kirja', 1, 'met-but-no-card'),
    ('pgtap learners retired line', 'puhe', 1, 'only-on-a-retired-line'),
    ('pgtap learners draft line', 'puhe', 1, 'only-on-a-draft-line'),
    ('pgtap learners line of a dialogue retired later', 'puhe', 1, 'only-in-a-dialogue-retired-later')
  ) as t(gloss, register, position, form_tag)
  join public.dialogue_lines l on l.gloss_en = t.gloss
  join public.forms f on f.lemma = 'pgtap-learners' and f.form_tag = t.form_tag;

update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where gloss_en in ('pgtap learners line', 'pgtap learners second line', 'pgtap learners line beside a draft line',
                    'pgtap learners line of a dialogue retired later');
update public.dialogue_lines set status = 'retired' where gloss_en = 'pgtap learners retired line';
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where slug in ('pgtap-learners-dialogue', 'pgtap-learners-dialogue-second', 'pgtap-learners-dialogue-retired-later');

-- The card rule is tested on its own, so it is also tested with a draft line inside
-- an approved dialogue. The database never allows that (an approved dialogue has no
-- draft line), so that check is switched off for this one step, inside this rolled
-- back transaction.
alter table public.dialogues disable trigger approved_dialogue_is_whole;
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where slug = 'pgtap-learners-dialogue-with-draft-line';
alter table public.dialogues enable trigger approved_dialogue_is_whole;

-- A form used by an approved line, set back to draft afterwards.
update public.forms set status = 'draft' where lemma = 'pgtap-learners' and form_tag = 'set-to-draft-later';

select set_config('test.dialogue', (select id::text from public.dialogues where slug = 'pgtap-learners-dialogue'), true);
select set_config('test.dialogue_second', (select id::text from public.dialogues where slug = 'pgtap-learners-dialogue-second'), true);
select set_config('test.dialogue_draft', (select id::text from public.dialogues where slug = 'pgtap-learners-dialogue-draft'), true);
select set_config('test.form_met', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'in-dialogue'), true);
select set_config('test.form_unmet', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'not-in-dialogue'), true);
-- A form both A and B meet in the main dialogue and neither ever gets a card for,
-- so in the tests that add a card carrying the other learner's id only the user
-- id check can refuse it (evaluation, round 1).
select set_config('test.form_met_no_card', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'met-but-no-card'), true);
select set_config('test.form_card_only', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'only-on-a-card'), true);

-- No email address: a guest has none, and the email account's address is not
-- needed by any rule. C is a third learner for the card rule tests below.
insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000000a1'),
  ('00000000-0000-4000-8000-0000000000b1'),
  ('00000000-0000-4000-8000-0000000000c1');

-- [data 3] A new card has the same values as createEmptyCard() -----------------------------

insert into public.cards (user_id, form_id)
values ('00000000-0000-4000-8000-0000000000b1', current_setting('test.form_card_only')::bigint);
select row_eq(
  $$select due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review
      from public.cards
     where user_id = '00000000-0000-4000-8000-0000000000b1'
       and form_id = current_setting('test.form_card_only')::bigint$$,
  row(now(), 0::double precision, 0::double precision, 0, 0, 0, 0, 'new'::public.card_state, null::timestamptz),
  '[data 3] a card''s defaults match createEmptyCard(): due now, all numbers 0, state new, never reviewed'
);

-- Learner A, a guest ---------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

-- [data 9] Nothing unmet is reviewed.
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_met')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] before any session, a learner cannot create a card'
);

-- [data 10] A learner starts a session and moves its step forward.
select lives_ok(
  $$insert into public.sessions (dialogue_id) values (current_setting('test.dialogue')::bigint)$$,
  '[data 10] a learner can start a session for an approved dialogue'
);
select row_eq(
  $$select user_id, step_reached, started_at, ended_at from public.sessions$$,
  row('00000000-0000-4000-8000-0000000000a1'::uuid, null::public.loop_step, now(), null::timestamptz),
  '[data 10] the new session stores the learner and the start time, with no step yet'
);
select lives_ok(
  $$update public.sessions set step_reached = 'hear'$$,
  '[data 10] the learner can record the first step, hear'
);
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_met')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] at step hear, the learner still cannot create a card for a form in the dialogue'
);
select lives_ok(
  $$update public.sessions set step_reached = 'understand'$$,
  '[data 10] the learner can move the step forward to understand'
);
select lives_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_met')::bigint)$$,
  '[data 9] at step understand, the learner can create a card for a form in the dialogue'
);
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_unmet')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] the learner still cannot create a card for an approved form that is not in the dialogue'
);
select throws_like(
  $$update public.sessions set step_reached = 'hear'$$,
  '%only moves forward%',
  '[data 10] the step cannot move backward'
);
select throws_like(
  $$update public.sessions set step_reached = null$$,
  '%only moves forward%',
  '[data 10] the step cannot be emptied again'
);
select throws_ok(
  $$update public.sessions set started_at = now() - interval '1 day'$$,
  '42501', null,
  '[data 10] a learner cannot change the start time'
);
select throws_ok(
  $$update public.sessions set dialogue_id = current_setting('test.dialogue_second')::bigint$$,
  '42501', null,
  '[data 10] a learner cannot move a session to another dialogue'
);
select throws_ok(
  $$insert into public.sessions (dialogue_id, step_reached) values (current_setting('test.dialogue')::bigint, 'use')$$,
  '42501', null,
  '[data 10] a learner cannot start a session at a later step'
);
select throws_ok(
  $$insert into public.sessions (dialogue_id) values (current_setting('test.dialogue_draft')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "sessions"',
  '[data 10] a learner cannot start a session for a draft dialogue'
);
select lives_ok(
  $$update public.sessions set ended_at = now() where dialogue_id = current_setting('test.dialogue')::bigint$$,
  '[data 10] the learner can record the end time'
);
select row_eq(
  $$select dialogue_id, step_reached, ended_at from public.sessions$$,
  row(current_setting('test.dialogue')::bigint, 'understand'::public.loop_step, now()),
  '[data 10] the session stores the dialogue, the step reached and the end time'
);
select lives_ok(
  $$insert into public.sessions (dialogue_id) values (null)$$,
  '[data 10] a learner can start a review only session, with no dialogue'
);
select lives_ok(
  $$insert into public.sessions (dialogue_id) values (current_setting('test.dialogue_second')::bigint)$$,
  '[data 10] a learner can start a session for a second approved dialogue'
);

-- Cards and review logs.
select lives_ok(
  $$update public.cards set reps = 1, state = 'learning', last_review = now(), due = now() + interval '10 minutes'
    where form_id = current_setting('test.form_met')::bigint$$,
  '[data 8] the learner can change the review state of their own card'
);
select throws_ok(
  $$update public.cards set form_id = current_setting('test.form_unmet')::bigint$$,
  '42501', null,
  '[data 9] a learner cannot move a card to another form'
);
select lives_ok(
  $$insert into public.review_logs (form_id, rating, mode, state, due, stability, difficulty,
      elapsed_days, last_elapsed_days, scheduled_days, review_time)
    values (current_setting('test.form_met')::bigint, 3, 'typed', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '[data 8] the learner can add a review log for their own card'
);
select throws_ok(
  $$insert into public.review_logs (form_id, rating, mode, state, due, stability, difficulty,
      elapsed_days, last_elapsed_days, scheduled_days, review_time)
    values (current_setting('test.form_met')::bigint, 5, 'typed', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '23514', null,
  '[data 3] a review rating is 1 to 4'
);

-- [data 11] Voice consent is a history the learner adds to and cannot rewrite.
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_processing', true, 'pgtap-v1')$$,
  '[data 11] the learner can record that they gave voice processing consent'
);
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_processing', false, 'pgtap-v1')$$,
  '[data 11] the learner can record that they withdrew it'
);
select results_eq(
  $$select granted from public.consents where kind = 'voice_processing' order by created_at$$,
  array[true, false],
  '[data 11] the learner reads both choices, oldest first'
);
select results_eq(
  $$select granted from public.consents where kind = 'voice_processing' order by created_at desc limit 1$$,
  array[false],
  '[data 11] the current choice is the newest row of its kind: withdrawn'
);
select throws_ok(
  $$update public.consents set granted = true$$,
  '42501', null,
  '[data 11] the learner cannot change a consent row'
);
select throws_ok(
  $$delete from public.consents$$,
  '42501', null,
  '[data 11] the learner cannot delete a consent row'
);
select throws_ok(
  $$insert into public.consents (kind, granted, notice_version, created_at)
    values ('voice_recording_retention', true, 'pgtap-v1', now() - interval '1 year')$$,
  '42501', null,
  '[data 11] the learner cannot back-date a consent'
);

-- [data 11] The consent text version is a short label, nothing else (security review 2)
select throws_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_processing', true, repeat('v', 33))$$,
  '23514', null,
  '[data 11] a consent text version longer than 32 characters is refused'
);
select throws_ok(
  format($$insert into public.consents (kind, granted, notice_version) values ('voice_processing', true, %L)$$, v),
  '23514', null,
  format('[data 11] a consent text version with %s is refused', label)
) from (values
  ('v1 with spaces', 'a space'),
  ('v1' || chr(10) || 'v2', 'a line break'),
  ('', 'nothing in it'),
  ('v1;drop', 'a semicolon')
) as x(v, label);
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_recording_retention', false, repeat('v', 32))$$,
  '[data 11] a consent text version of 32 letters is accepted'
);
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_recording_retention', false, '2026-10.1_b')$$,
  '[data 11] a consent text version made of letters, digits, dots, dashes and underscores is accepted'
);

reset role;

-- [data 9] The card rule refuses every form the learner has not met in approved content
-- (security review 3). Learner C reaches "understand" in three approved dialogues:
--   the main dialogue, whose retired line uses one form and whose approved line uses
--   a form that was set back to draft afterwards;
--   a dialogue that holds a draft line (made with the check switched off above);
--   a dialogue that is retired after C's session started.

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select lives_ok(
  $$insert into public.sessions (dialogue_id)
    select id from public.dialogues
     where slug in ('pgtap-learners-dialogue', 'pgtap-learners-dialogue-with-draft-line',
                    'pgtap-learners-dialogue-retired-later')$$,
  '[data 9] learner C starts a session in each of three approved dialogues'
);
select lives_ok(
  $$update public.sessions set step_reached = 'understand'$$,
  '[data 9] and reaches understand in each'
);
select lives_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_met')::bigint)$$,
  '[data 9] C can create a card for the approved form on the approved line'
);
reset role;

-- The ids of forms a learner cannot read are passed in from the owner's side.
select set_config('test.form_set_to_draft', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'set-to-draft-later'), true);
select set_config('test.form_on_draft_line', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'only-on-a-draft-line'), true);
select set_config('test.form_retired_dialogue', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'only-in-a-dialogue-retired-later'), true);
select set_config('test.form_retired_line', (select id::text from public.forms where lemma = 'pgtap-learners' and form_tag = 'only-on-a-retired-line'), true);

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_retired_line')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] at understand, C cannot create a card for a form found only on a retired line'
);
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_set_to_draft')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] at understand, C cannot create a card for a draft form, even though an approved line of the dialogue uses it'
);
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_on_draft_line')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] at understand, C cannot create a card for a form found only on a draft line'
);
reset role;

update public.dialogues set status = 'retired' where slug = 'pgtap-learners-dialogue-retired-later';

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000c1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select throws_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_retired_dialogue')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 9] at understand, C cannot create a card for a form of a dialogue that was retired after the session started'
);
reset role;

-- Learner B, an email account ------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000b1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;

select lives_ok(
  $$insert into public.sessions (dialogue_id) values (current_setting('test.dialogue')::bigint)$$,
  '[data 8] learner B can start their own session'
);
select lives_ok(
  $$update public.sessions set step_reached = 'understand'$$,
  '[data 8] learner B can move their own session forward'
);
select lives_ok(
  $$insert into public.cards (form_id) values (current_setting('test.form_met')::bigint)$$,
  '[data 8] learner B can create their own card for the same form'
);
select lives_ok(
  $$insert into public.review_logs (form_id, rating, mode, state, due, stability, difficulty,
      elapsed_days, last_elapsed_days, scheduled_days, review_time)
    values (current_setting('test.form_met')::bigint, 1, 'spoken', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '[data 8] learner B can add their own review log'
);
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_recording_retention', true, 'pgtap-v1')$$,
  '[data 8] learner B can add their own consent'
);

reset role;

-- [data 8] Each learner reaches only their own rows, both ways round ---------------------

-- For each of A and B: read own rows, not the other's; change and delete nothing of
-- the other's; add no row carrying the other's id.
create temporary table pgtap_pairs (me uuid, other uuid, claims text, label text) on commit drop;
insert into pgtap_pairs values
  ('00000000-0000-4000-8000-0000000000a1', '00000000-0000-4000-8000-0000000000b1',
   '{"sub": "00000000-0000-4000-8000-0000000000a1", "role": "authenticated", "is_anonymous": true}', 'A (guest)'),
  ('00000000-0000-4000-8000-0000000000b1', '00000000-0000-4000-8000-0000000000a1',
   '{"sub": "00000000-0000-4000-8000-0000000000b1", "role": "authenticated", "is_anonymous": false}', 'B (email)');

-- A first.
select set_config('request.jwt.claims', (select claims from pgtap_pairs where label = 'A (guest)'), true);
set local role authenticated;

select results_eq(
  format('select count(*) from public.%I', t),
  format('select %s::bigint', n),
  format('[data 8] A (guest) reads exactly their own %s rows in %s', n, t))
  from (values ('sessions', 3), ('cards', 1), ('review_logs', 1), ('consents', 4)) as x(t, n);
select is_empty(
  format($$select 1 from public.%I where user_id = '00000000-0000-4000-8000-0000000000b1'$$, t),
  format('[data 8] A (guest) cannot read B''s rows in %s', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select lives_ok(
  $$update public.cards set reps = 99 where user_id = '00000000-0000-4000-8000-0000000000b1'$$,
  '[data 8] A''s update aimed at B''s card runs (and must change nothing, checked below)'
);
select lives_ok(
  $$update public.sessions set ended_at = now() where user_id = '00000000-0000-4000-8000-0000000000b1'$$,
  '[data 8] A''s update aimed at B''s session runs (and must change nothing, checked below)'
);
select throws_ok(
  format($$update public.%I set user_id = user_id where user_id = '00000000-0000-4000-8000-0000000000b1'$$, t),
  '42501', null,
  format('[data 8] A (guest) cannot change rows in %s', t))
  from unnest(array['review_logs', 'consents']) as t;
select throws_ok(
  format($$delete from public.%I where user_id = '00000000-0000-4000-8000-0000000000b1'$$, t),
  '42501', null,
  format('[data 8] A (guest) cannot delete B''s rows in %s', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select throws_ok(
  format('delete from public.%I', t),
  '42501', null,
  format('[data 8] A (guest) cannot delete their own rows in %s either', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select throws_ok(
  $$insert into public.sessions (user_id, dialogue_id)
    values ('00000000-0000-4000-8000-0000000000b1', current_setting('test.dialogue')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "sessions"',
  '[data 8] A (guest) cannot add a session carrying B''s user id'
);
select throws_ok(
  $$insert into public.cards (user_id, form_id)
    values ('00000000-0000-4000-8000-0000000000b1', current_setting('test.form_met_no_card')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 8] A (guest) cannot add a card carrying B''s user id, even for a form A has met'
);
select throws_ok(
  $$insert into public.review_logs (user_id, form_id, rating, mode, state, due, stability, difficulty,
      elapsed_days, last_elapsed_days, scheduled_days, review_time)
    values ('00000000-0000-4000-8000-0000000000b1', current_setting('test.form_met')::bigint,
            4, 'typed', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '42501', 'new row violates row-level security policy for table "review_logs"',
  '[data 8] A (guest) cannot add a review log carrying B''s user id'
);
select throws_ok(
  $$insert into public.consents (user_id, kind, granted, notice_version)
    values ('00000000-0000-4000-8000-0000000000b1', 'voice_processing', true, 'pgtap-v1')$$,
  '42501', 'new row violates row-level security policy for table "consents"',
  '[data 8] A (guest) cannot add a consent carrying B''s user id'
);

reset role;

select results_eq(
  $$select reps from public.cards
     where user_id = '00000000-0000-4000-8000-0000000000b1' and form_id = current_setting('test.form_met')::bigint$$,
  array[0],
  '[data 8] B''s card is unchanged after A''s update'
);
select is_empty(
  $$select 1 from public.sessions
     where user_id = '00000000-0000-4000-8000-0000000000b1' and ended_at is not null$$,
  '[data 8] B''s session is unchanged after A''s update'
);

-- Then B, the other way round.
select set_config('request.jwt.claims', (select claims from pgtap_pairs where label = 'B (email)'), true);
set local role authenticated;

select results_eq(
  format('select count(*) from public.%I', t),
  format('select %s::bigint', n),
  format('[data 8] B (email) reads exactly their own %s rows in %s', n, t))
  from (values ('sessions', 1), ('cards', 2), ('review_logs', 1), ('consents', 1)) as x(t, n);
select is_empty(
  format($$select 1 from public.%I where user_id = '00000000-0000-4000-8000-0000000000a1'$$, t),
  format('[data 8] B (email) cannot read A''s rows in %s', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select lives_ok(
  $$update public.cards set reps = 99 where user_id = '00000000-0000-4000-8000-0000000000a1'$$,
  '[data 8] B''s update aimed at A''s card runs (and must change nothing, checked below)'
);
select lives_ok(
  $$update public.sessions set step_reached = 'use' where user_id = '00000000-0000-4000-8000-0000000000a1'$$,
  '[data 8] B''s update aimed at A''s sessions runs (and must change nothing, checked below)'
);
select throws_ok(
  format($$update public.%I set user_id = user_id where user_id = '00000000-0000-4000-8000-0000000000a1'$$, t),
  '42501', null,
  format('[data 8] B (email) cannot change rows in %s', t))
  from unnest(array['review_logs', 'consents']) as t;
select throws_ok(
  format($$delete from public.%I where user_id = '00000000-0000-4000-8000-0000000000a1'$$, t),
  '42501', null,
  format('[data 8] B (email) cannot delete A''s rows in %s', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select throws_ok(
  $$insert into public.sessions (user_id, dialogue_id)
    values ('00000000-0000-4000-8000-0000000000a1', current_setting('test.dialogue')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "sessions"',
  '[data 8] B (email) cannot add a session carrying A''s user id'
);
select throws_ok(
  $$insert into public.cards (user_id, form_id)
    values ('00000000-0000-4000-8000-0000000000a1', current_setting('test.form_met_no_card')::bigint)$$,
  '42501', 'new row violates row-level security policy for table "cards"',
  '[data 8] B (email) cannot add a card carrying A''s user id, even for a form B has met'
);
select throws_ok(
  $$insert into public.review_logs (user_id, form_id, rating, mode, state, due, stability, difficulty,
      elapsed_days, last_elapsed_days, scheduled_days, review_time)
    values ('00000000-0000-4000-8000-0000000000a1', current_setting('test.form_met')::bigint,
            4, 'typed', 'new', now(), 0, 0, 0, 0, 0, now())$$,
  '42501', 'new row violates row-level security policy for table "review_logs"',
  '[data 8] B (email) cannot add a review log carrying A''s user id'
);
select throws_ok(
  $$insert into public.consents (user_id, kind, granted, notice_version)
    values ('00000000-0000-4000-8000-0000000000a1', 'voice_processing', true, 'pgtap-v1')$$,
  '42501', 'new row violates row-level security policy for table "consents"',
  '[data 8] B (email) cannot add a consent carrying A''s user id'
);

reset role;

select results_eq(
  $$select reps from public.cards where user_id = '00000000-0000-4000-8000-0000000000a1'$$,
  array[1],
  '[data 8] A''s card is unchanged after B''s update'
);
select is_empty(
  $$select 1 from public.sessions
     where user_id = '00000000-0000-4000-8000-0000000000a1' and step_reached = 'use'$$,
  '[data 8] A''s sessions are unchanged after B''s update'
);

-- [data 12] The same learner id reads the same rows as a guest and as an email account -----

create function pg_temp.my_rows() returns text language sql as $$
  select string_agg(x, ',' order by x) from (
    select 'card:' || form_id from public.cards
    union all select 'session:' || id from public.sessions
    union all select 'log:' || id from public.review_logs
    union all select 'consent:' || id from public.consents
  ) as rows(x)
$$;
grant execute on function pg_temp.my_rows() to authenticated;

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select set_config('test.rows_as_guest', pg_temp.my_rows(), true);
reset role;

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000000a1", "role": "authenticated", "is_anonymous": false}', true);
set local role authenticated;
select set_config('test.rows_as_email', pg_temp.my_rows(), true);
select lives_ok(
  $$insert into public.consents (kind, granted, notice_version) values ('voice_processing', true, 'pgtap-v2')$$,
  '[data 12] after adding an email, the same learner keeps writing to their own rows'
);
reset role;

select is(
  array_length(string_to_array(current_setting('test.rows_as_guest'), ','), 1),
  9,
  '[data 12] as a guest, A reads their 9 rows (3 sessions, 1 card, 1 review log, 4 consents)'
);
select is(
  current_setting('test.rows_as_email'),
  current_setting('test.rows_as_guest'),
  '[data 12] with is_anonymous false, the same user id reads exactly the same rows'
);

-- [data 14] Content in use cannot be deleted ------------------------------------------------

-- The second dialogue is retired and its one line taken out first, so only the
-- session still points to it.
update public.dialogues set status = 'retired' where slug = 'pgtap-learners-dialogue-second';
update public.dialogue_lines set status = 'retired' where gloss_en = 'pgtap learners second line';
delete from public.dialogue_lines where gloss_en = 'pgtap learners second line';
select throws_like(
  $$delete from public.dialogues where slug = 'pgtap-learners-dialogue-second'$$,
  '%"sessions_dialogue_id_fkey"%',
  '[data 14] a dialogue that a session points to cannot be deleted'
);
update public.forms set status = 'retired' where form_tag = 'only-on-a-card' and lemma = 'pgtap-learners';
select throws_like(
  $$delete from public.forms where form_tag = 'only-on-a-card' and lemma = 'pgtap-learners'$$,
  '%"cards_form_id_fkey"%',
  '[data 14] a form that a card points to cannot be deleted'
);

-- [data 13] Deleting a user removes all their rows from every learner table ---------------

select results_eq(
  $$select count(*) from (
      select user_id from public.sessions union all select user_id from public.cards
      union all select user_id from public.review_logs union all select user_id from public.consents
    ) as rows where user_id = '00000000-0000-4000-8000-0000000000a1'$$,
  array[10::bigint],
  '[data 13] before the delete, A has 10 rows across the learner tables'
);
delete from auth.users where id = '00000000-0000-4000-8000-0000000000a1';
select is_empty(
  format($$select 1 from public.%I where user_id = '00000000-0000-4000-8000-0000000000a1'$$, t),
  format('[data 13] deleting A from auth.users removed all of A''s rows from %s', t))
  from unnest(array['sessions', 'cards', 'review_logs', 'consents']) as t;
select results_eq(
  $$select count(*) from (
      select user_id from public.sessions union all select user_id from public.cards
      union all select user_id from public.review_logs union all select user_id from public.consents
    ) as rows where user_id = '00000000-0000-4000-8000-0000000000b1'$$,
  array[5::bigint],
  '[data 13] B''s 5 rows are untouched'
);

select * from finish();

rollback;
