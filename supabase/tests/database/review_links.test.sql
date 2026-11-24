-- Review links: the two tables, the batches, the reviewer's three doors and the owner's three
-- functions (pgTAP). Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/review-links/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind, also when it runs
-- against the test project. It first removes every sign up it can see (and with them every link and
-- answer); the rollback puts them back. It uses the published road content the migrations load.
--
-- Test accounts (ids end in 25..):
--   O  = ...0000000025f1  on the owner list, with a live sign in
--   O2 = ...0000000025f2  on the owner list, sign in ended (no auth.sessions row)
--   A  = ...0000000025a1  a guest learner with a live sign in
-- Link secrets are 43 characters, as the Worker makes them: repeat('a', 43) and so on.

begin;

create extension if not exists pgtap with schema extensions;

select plan(142);

delete from private.reviewer_signups;

insert into auth.users (id, is_anonymous, email, created_at) values
  ('00000000-0000-4000-8000-0000000025f1', false, 'owner-25@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000025f2', false, 'owner-25-ended@example.com', now() - interval '60 days'),
  ('00000000-0000-4000-8000-0000000025a1', true, null, now() - interval '60 days');

insert into auth.sessions (id, user_id) values
  ('00000000-0000-4000-8000-0000000065f1', '00000000-0000-4000-8000-0000000025f1'),
  ('00000000-0000-4000-8000-0000000065a1', '00000000-0000-4000-8000-0000000025a1');

insert into private.owners (user_id) values
  ('00000000-0000-4000-8000-0000000025f1'),
  ('00000000-0000-4000-8000-0000000025f2');

insert into private.reviewer_signups (id, name, email) values
  ('00000000-0000-4000-8000-00000000a001', 'Aino Virtanen', 'aino@example.fi'),
  ('00000000-0000-4000-8000-00000000a002', 'Eero Laine', 'eero@example.fi');

-- =====================================================================================
-- [review-links 5] The browser roles get nothing on the two tables
-- =====================================================================================

select columns_are('private', 'review_links',
  array['id', 'signup_id', 'batch', 'token_hash', 'sent_at', 'minute_start', 'minute_count'],
  '[review-links 1] [review-links 2] review_links holds the sign up, the batch, the hash of the secret, the time and the minute count, and no secret');
select columns_are('private', 'review_answers',
  array['link_id', 'line_id', 'answer', 'note', 'answered_at'],
  '[review-links 4] review_answers holds the link, the line, the answer, the note and the time');
select fk_ok('private', 'review_answers', 'line_id', 'public', 'dialogue_lines', 'id',
  '[review-links 4] an answer references the line id');

select ok((select relrowsecurity from pg_class where oid = format('private.%I', t)::regclass),
  format('[review-links 5] row level security is on for %s', t))
  from unnest(array['review_links', 'review_answers']) as t;
select is_empty(
  $$ select policyname from pg_policies where schemaname = 'private' and tablename in ('review_links', 'review_answers') $$,
  '[review-links 5] the two tables have no rule, so no API role may read or write a row directly');
select table_privs_are('private', t, r, array[]::text[],
  format('[review-links 5] %s has no permission on %s', r, t))
  from unnest(array['anon', 'authenticated', 'service_role']) as r,
       unnest(array['review_links', 'review_answers']) as t;
select is_empty(
  $$ select 1 from pg_class c cross join lateral aclexplode(c.relacl) x
      where c.oid in ('private.review_links'::regclass, 'private.review_answers'::regclass) and x.grantee = 0 $$,
  '[review-links 5] PUBLIC has no permission on the two tables');
select is_empty(
  $$ select 1 from pg_attribute a cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
      where a.attrelid in ('private.review_links'::regclass, 'private.review_answers'::regclass) and a.attnum > 0
        and (x.grantee = 0 or r.rolname in ('anon', 'authenticated', 'service_role')) $$,
  '[review-links 5] no API role has a column permission on the two tables');

-- =====================================================================================
-- [review-links 5] Who may run each function
-- =====================================================================================

select ok((select prosecdef from pg_proc where oid = f::regprocedure), format('[review-links 5] %s is security definer', f))
  from unnest(array[
    'public.review_link_overview(text)', 'public.review_link_dialogue(text, bigint)',
    'public.review_link_answer(text, bigint, text, text)',
    'public.owner_create_review_link(uuid, integer, text)', 'public.owner_delete_review_link(uuid)',
    'public.owner_review_overview()']) as f;
select ok((select proconfig @> array['search_path=""'] from pg_proc where oid = f::regprocedure),
  format('[review-links 5] %s runs with an empty search_path', f))
  from unnest(array[
    'public.review_link_overview(text)', 'public.review_link_dialogue(text, bigint)',
    'public.review_link_answer(text, bigint, text, text)',
    'public.owner_create_review_link(uuid, integer, text)', 'public.owner_delete_review_link(uuid)',
    'public.owner_review_overview()']) as f;

-- The reviewer's doors: anon (the Worker) only.
select ok(has_function_privilege('anon', f, 'EXECUTE'), format('[review-links 5] anon may call %s', f))
  from unnest(array['public.review_link_overview(text)', 'public.review_link_dialogue(text, bigint)',
    'public.review_link_answer(text, bigint, text, text)']) as f;
select ok(not has_function_privilege(r, f, 'EXECUTE'), format('[review-links 5] %s may not call %s', r, f))
  from unnest(array['authenticated', 'service_role']) as r,
       unnest(array['public.review_link_overview(text)', 'public.review_link_dialogue(text, bigint)',
         'public.review_link_answer(text, bigint, text, text)']) as f;
-- The owner's functions: authenticated only, and then only the owner gets an answer.
select ok(has_function_privilege('authenticated', f, 'EXECUTE'), format('[review-links 5] authenticated may call %s', f))
  from unnest(array['public.owner_create_review_link(uuid, integer, text)', 'public.owner_delete_review_link(uuid)',
    'public.owner_review_overview()']) as f;
select ok(not has_function_privilege(r, f, 'EXECUTE'), format('[review-links 5] %s may not call %s', r, f))
  from unnest(array['anon', 'service_role']) as r,
       unnest(array['public.owner_create_review_link(uuid, integer, text)', 'public.owner_delete_review_link(uuid)',
         'public.owner_review_overview()']) as f;
select is_empty(
  $$ select p.oid::regprocedure from pg_proc p cross join lateral aclexplode(p.proacl) x
      where p.proname in ('review_link_overview', 'review_link_dialogue', 'review_link_answer',
                          'owner_create_review_link', 'owner_delete_review_link', 'owner_review_overview',
                          'review_batch_dialogues', 'review_token_hash')
        and x.grantee = 0 $$,
  '[review-links 5] PUBLIC may run none of the new functions');
select ok(not has_function_privilege(r, f, 'EXECUTE'), format('[review-links 5] %s may not call %s', r, f))
  from unnest(array['anon', 'authenticated', 'service_role']) as r,
       unnest(array['private.review_batch_dialogues()', 'private.review_token_hash(text)']) as f;

-- =====================================================================================
-- [review-links 3] The batches: the published road dialogues in road order, 27 to a batch
-- =====================================================================================

select is((select count(*) from private.review_batch_dialogues()),
  (select count(*) from public.dialogues d join public.units u on u.id = d.unit_id and u.status = 'approved'
    where d.status = 'approved' and u.stop_number is not null),
  '[review-links 3] every published road dialogue is in exactly one batch');
select is((select count(*) from private.review_batch_dialogues() where batch = b), 27::bigint,
  format('[review-links 3] batch %s has 27 dialogues', b))
  from unnest(array[1, 2, 3]) as b;
select is((select count(*) from private.review_batch_dialogues() where batch = 4),
  (select count(*) from private.review_batch_dialogues()) - 81,
  '[review-links 3] batch 4 takes the rest');
select is((select count(*) from private.review_batch_dialogues() where batch = 4), 27::bigint,
  '[review-links 3] with the 108 published dialogues, batch 4 also has 27');
select is(
  (select array_agg(b.dialogue_id order by b.batch, b.batch_position) from private.review_batch_dialogues() b),
  (select array_agg(d.id order by u.stop_number, d.position)
     from public.dialogues d join public.units u on u.id = d.unit_id and u.status = 'approved'
    where d.status = 'approved' and u.stop_number is not null),
  '[review-links 3] batch by batch, the dialogues come in road order: by stop, then by place in the stop');
select is(
  (select array_agg(batch_position order by batch_position) from private.review_batch_dialogues() where batch = 2),
  (select array_agg(n) from generate_series(1, 27) as n),
  '[review-links 3] each batch numbers its dialogues 1 to 27');
select is_empty(
  $$ select 1 from private.review_batch_dialogues() b join public.dialogues d on d.id = b.dialogue_id
      join public.units u on u.id = d.unit_id where u.stop_number is null $$,
  '[review-links 3] no test fixture unit (off the road) is in a batch');

-- =====================================================================================
-- [review-links 1] [review-links 2] The owner records a link; only its hash is kept
-- =====================================================================================

-- A learner who is not on the owner list.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000025a1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000065a1"}', true);
set local role authenticated;
select is(public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 1, repeat('a', 43)), null,
  '[review-links 1] a learner not on the owner list cannot record a link');
select is(public.owner_review_overview(), null, '[review-links 6] a learner not on the owner list sees no answers');
select is(public.owner_delete_review_link(gen_random_uuid()), null,
  '[review-links 1] a learner not on the owner list cannot delete a link');
select throws_ok($$ select public.review_link_overview(repeat('a', 43)) $$, '42501', null,
  '[review-links 5] a signed in learner cannot call the reviewer doors');
select throws_ok($$ select * from private.review_answers $$, '42501', null,
  '[review-links 5] a signed in learner cannot read review_answers');
reset role;
select is((select count(*) from private.review_links), 0::bigint, '[review-links 1] the learner recorded nothing');

-- An account on the owner list whose sign in was ended.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000025f2", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000065f2"}', true);
set local role authenticated;
select is(public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 1, repeat('a', 43)), null,
  '[review-links 1] an owner whose sign in was ended cannot record a link');
select is(public.owner_review_overview(), null, '[review-links 6] an owner whose sign in was ended sees nothing');
reset role;

-- The owner, with a live sign in.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000025f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000065f1"}', true);
set local role authenticated;
select throws_ok($$ select public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 5, repeat('a', 43)) $$,
  '22023', null, '[review-links 1] a batch outside 1 to 4 is refused');
select throws_ok($$ select public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 0, repeat('a', 43)) $$,
  '22023', null, '[review-links 1] batch 0 is refused');
select throws_ok($$ select public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 1, repeat('a', 42)) $$,
  '22023', null, '[review-links 2] a secret shorter than 43 characters (under 256 bits) is refused');
select throws_ok($$ select public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 1, repeat('a', 42) || '=') $$,
  '22023', null, '[review-links 2] a secret with a character outside base64url is refused');
select is(public.owner_create_review_link('00000000-0000-4000-8000-00000000ffff', 1, repeat('a', 43)),
  '{"found": false}'::jsonb, '[review-links 1] a sign up that is not there says so');
select is(public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 1, repeat('a', 43)) - 'id' - 'sent_at',
  '{"found": true, "batch": 1, "name": "Aino Virtanen", "email": "aino@example.fi"}'::jsonb,
  '[review-links 1] the owner records batch 1 for Aino, and gets the name and email to send it to');
select ok((public.owner_create_review_link('00000000-0000-4000-8000-00000000a001', 4, repeat('b', 43)) ->> 'sent_at') is not null,
  '[review-links 1] a second link (batch 4) for the same person, with its time');
select is(public.owner_create_review_link('00000000-0000-4000-8000-00000000a002', 2, repeat('c', 43)) ->> 'batch', '2',
  '[review-links 1] a link for another person');
select throws_ok($$ select public.owner_create_review_link('00000000-0000-4000-8000-00000000a002', 2, repeat('c', 43)) $$,
  '23505', null, '[review-links 2] the same secret cannot be recorded twice');
reset role;

select results_eq(
  $$ select token_hash from private.review_links where batch = 1 $$,
  $$ values (encode(sha256(convert_to(repeat('a', 43), 'UTF8')), 'hex')) $$,
  '[review-links 2] the stored value is the sha256 hash of the secret');
select is_empty(
  $$ select 1 from private.review_links r where r::text like '%' || repeat('a', 43) || '%'
                                              or r::text like '%' || repeat('b', 43) || '%' $$,
  '[review-links 2] no row holds the secret itself');
select ok((select sent_at between now() - interval '1 minute' and now() from private.review_links where batch = 1),
  '[review-links 1] the link has the time from the database clock');

-- =====================================================================================
-- [review-links 2] [review-links 3] What a link opens
-- =====================================================================================

-- The batches as the owner sees them, readable by the test roles (they have no access to private).
create temp table review_batches_seen as select * from private.review_batch_dialogues();
grant select on review_batches_seen to anon, authenticated;
set local role anon;
select is(public.review_link_overview(repeat('z', 43)), null, '[review-links 2] a wrong secret gets nothing');
select is(public.review_link_overview('short'), null, '[review-links 2] a malformed secret gets nothing');
select is(public.review_link_overview(null), null, '[review-links 2] no secret gets nothing');
select is(public.review_link_overview(encode(sha256(convert_to(repeat('a', 43), 'UTF8')), 'hex')), null,
  '[review-links 2] the stored hash does not open the link');
select is((public.review_link_overview(repeat('a', 43)) ->> 'batch')::integer, 1, '[review-links 3] the link opens batch 1');
select is(jsonb_array_length(public.review_link_overview(repeat('a', 43)) -> 'dialogues'), 27,
  '[review-links 3] batch 1 lists 27 dialogues');
select is(
  (select array_agg((x ->> 'id')::bigint order by (x ->> 'position')::integer)
     from jsonb_array_elements(public.review_link_overview(repeat('a', 43)) -> 'dialogues') x),
  (select array_agg(dialogue_id order by batch_position) from review_batches_seen where batch = 1),
  '[review-links 3] exactly the dialogues of batch 1, in road order');
select is(jsonb_array_length(public.review_link_overview(repeat('b', 43)) -> 'dialogues'),
  (select count(*)::integer from review_batches_seen where batch = 4),
  '[review-links 3] the batch 4 link lists the rest');
select is(
  (select array_agg(k order by k) from jsonb_object_keys(public.review_link_overview(repeat('a', 43)) -> 'dialogues' -> 0) as k),
  array['answered', 'id', 'lines', 'position', 'stop', 'title'],
  '[review-links 3] each dialogue has its id, place, title, stop, line count and answer count');
select is((public.review_link_overview(repeat('a', 43)) -> 'dialogues' -> 0 ->> 'answered')::integer, 0,
  '[review-links 3] nothing answered yet');

select is(public.review_link_dialogue(repeat('a', 43),
    (select dialogue_id from review_batches_seen where batch = 2 and batch_position = 1)), null,
  '[review-links 3] a dialogue of another batch is not shown');
select is(public.review_link_dialogue(repeat('z', 43),
    (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)), null,
  '[review-links 2] a wrong secret opens no dialogue');
select is(
  jsonb_array_length(public.review_link_dialogue(repeat('a', 43),
    (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)) -> 'lines'),
  (select count(*)::integer from public.dialogue_lines l where l.status = 'approved'
     and l.dialogue_id = (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)),
  '[review-links 3] the dialogue shows every approved line');
select is(
  (select array_agg(k order by k) from jsonb_object_keys(public.review_link_dialogue(repeat('a', 43),
    (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)) -> 'lines' -> 0) as k),
  array['answer', 'english', 'id', 'note', 'position', 'speaker', 'spoken', 'spoken_audio', 'written', 'written_audio'],
  '[review-links 3] each line has spoken, written, English and both audio keys from the live content');
select is(
  (select (x ->> 'spoken', x ->> 'written', x ->> 'english', x ->> 'spoken_audio')
     from jsonb_array_elements(public.review_link_dialogue(repeat('a', 43),
       (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)) -> 'lines') x
    where (x ->> 'position')::integer = 1),
  (select (l.text_puhe, l.text_kirja, l.gloss_en, l.audio_puhe_key) from public.dialogue_lines l
    where l.position = 1
      and l.dialogue_id = (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 1)),
  '[review-links 3] the line texts and audio key are the ones the app plays');
select is(
  public.review_link_dialogue(repeat('a', 43),
    (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 2)) ->> 'previous',
  (select dialogue_id::text from review_batches_seen where batch = 1 and batch_position = 1),
  '[review-links 3] a dialogue names the one before it in the batch');
select is(
  public.review_link_dialogue(repeat('a', 43),
    (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 27)) ->> 'next',
  null, '[review-links 3] the last dialogue of the batch has no next one');
select throws_ok($$ select * from private.review_links $$, '42501', null, '[review-links 5] anon cannot read review_links');
select throws_ok($$ insert into private.review_answers (link_id, line_id, answer) values (gen_random_uuid(), 1, 'correct') $$,
  '42501', null, '[review-links 5] anon cannot add an answer directly');
select throws_ok($$ delete from private.review_answers $$, '42501', null, '[review-links 5] anon cannot delete answers');
reset role;

-- =====================================================================================
-- [review-links 4] Saving answers
-- =====================================================================================

-- The line ids used below, kept as settings of this transaction (rl.b<batch>d<place>l<line>), so
-- every role can read them: lines 1 to 3 of the first dialogue of batch 1, lines 1 and 2 of its
-- second dialogue, and line 1 of the first dialogue of batch 2.
select set_config(format('rl.b%sd%sl%s', b.batch, b.batch_position, l.position), l.id::text, true)
  from public.dialogue_lines l
  join review_batches_seen b on b.dialogue_id = l.dialogue_id
 where l.status = 'approved'
   and ((b.batch = 1 and b.batch_position = 1 and l.position <= 3)
     or (b.batch = 1 and b.batch_position = 2 and l.position <= 2)
     or (b.batch = 2 and b.batch_position = 1 and l.position = 1));

set local role anon;
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l1')::bigint, 'correct', null), 'saved',
  '[review-links 4] Correct is saved');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l2')::bigint, 'needs_fix', '  Use "sä" here.  '), 'saved',
  '[review-links 4] Needs a fix is saved with its note');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l3')::bigint, 'not_sure', 'ignored'), 'saved',
  '[review-links 4] Not sure is saved');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d2l1')::bigint, 'needs_fix', repeat('ä', 500)), 'saved',
  '[review-links 4] a note of exactly 500 characters (letters with marks count once) is saved');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d2l2')::bigint, 'needs_fix', E'Two\nlines'), 'saved',
  '[review-links 4] a note with a line break is saved');
select throws_ok(format($$ select public.review_link_answer(%L, %s, 'needs_fix', %L) $$, repeat('a', 43),
    current_setting('rl.b1d2l1')::bigint, repeat('ä', 501)),
  '22023', null, '[review-links 4] a note of 501 characters is refused');
select throws_ok(format($$ select public.review_link_answer(%L, %s, 'needs_fix', E'Tab\there') $$, repeat('a', 43),
    current_setting('rl.b1d2l1')::bigint),
  '22023', null, '[review-links 4] a note with a control character other than a line break is refused');
select throws_ok(format($$ select public.review_link_answer(%L, %s, 'wrong', null) $$, repeat('a', 43),
    current_setting('rl.b1d2l1')::bigint),
  '22023', null, '[review-links 4] an answer that is not one of the three is refused');
select throws_ok(format($$ select public.review_link_answer(%L, %s, null, null) $$, repeat('a', 43),
    current_setting('rl.b1d2l1')::bigint),
  '22023', null, '[review-links 4] no answer is refused');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b2d1l1')::bigint, 'correct', null), 'not_in_batch',
  '[review-links 4] a line of another batch is refused');
select is(public.review_link_answer(repeat('a', 43), -1, 'correct', null), 'not_in_batch',
  '[review-links 4] a line that does not exist is refused');
select is(public.review_link_answer(repeat('z', 43),
    current_setting('rl.b1d1l1')::bigint, 'correct', null), 'no_link',
  '[review-links 2] [review-links 4] a wrong secret saves nothing');
select is(public.review_link_answer('short',
    current_setting('rl.b1d1l1')::bigint, 'correct', null), 'no_link',
  '[review-links 2] [review-links 4] a malformed secret saves nothing');
reset role;

select results_eq(
  $$ select a.answer, a.note from private.review_answers a join public.dialogue_lines l on l.id = a.line_id
      where a.line_id in (current_setting('rl.b1d1l1')::bigint, current_setting('rl.b1d1l2')::bigint,
                          current_setting('rl.b1d1l3')::bigint)
      order by l.position $$,
  $$ values ('correct'::text, null::text), ('needs_fix', 'Use "sä" here.'), ('not_sure', null) $$,
  '[review-links 4] the three answers are stored; the note is trimmed and kept only with Needs a fix');
select is((select count(*) from private.review_answers), 5::bigint,
  '[review-links 4] the refused calls wrote nothing: only the five saved answers are there');

-- Changing an answer replaces the old one.
set local role anon;
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l2')::bigint, 'correct', 'still here?'), 'saved',
  '[review-links 4] changing Needs a fix to Correct is saved');
reset role;
select results_eq(
  $$ select a.answer, a.note from private.review_answers a
      where a.line_id = current_setting('rl.b1d1l2')::bigint $$,
  $$ values ('correct'::text, null::text) $$,
  '[review-links 4] the new answer replaced the old one, and its note went with it');
select is((select count(*) from private.review_answers), 5::bigint, '[review-links 4] still one answer per line');

set local role anon;
select is((public.review_link_overview(repeat('a', 43)) -> 'dialogues' -> 0 ->> 'answered')::integer, 3,
  '[review-links 3] the list counts the answered lines of the first dialogue');
select is(
  (select x ->> 'note' from jsonb_array_elements(public.review_link_dialogue(repeat('a', 43),
     (select dialogue_id from review_batches_seen where batch = 1 and batch_position = 2)) -> 'lines') x
    where (x ->> 'position')::integer = 2),
  E'Two\nlines', '[review-links 4] the dialogue gives back the saved answer and note, so the reviewer can come back');
select is(
  (select count(*)::integer from jsonb_array_elements(public.review_link_dialogue(repeat('b', 43),
     (select dialogue_id from review_batches_seen where batch = 4 and batch_position = 1)) -> 'lines') x
    where x ->> 'answer' is not null), 0,
  '[review-links 4] another link of the same person does not see these answers');
reset role;

-- =====================================================================================
-- [review-links 9] At most 60 answers a minute through one link
-- =====================================================================================

set local role anon;
select is(
  (select count(*) from generate_series(1, 60) as n
    where public.review_link_answer(repeat('c', 43),
      current_setting('rl.b2d1l1')::bigint, 'correct', null) = 'saved'),
  60::bigint, '[review-links 9] 60 answers in one minute are saved');
select is(public.review_link_answer(repeat('c', 43),
    current_setting('rl.b2d1l1')::bigint, 'not_sure', null), 'limit',
  '[review-links 9] the 61st in the same minute is refused');
reset role;
select is((select answer from private.review_answers
            where line_id = current_setting('rl.b2d1l1')::bigint), 'correct',
  '[review-links 9] the refused answer changed nothing');
update private.review_links set minute_start = now() - interval '61 seconds' where batch = 2;
set local role anon;
select is(public.review_link_answer(repeat('c', 43),
    current_setting('rl.b2d1l1')::bigint, 'not_sure', null), 'saved',
  '[review-links 9] a new minute starts a new count');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l1')::bigint, 'correct', null), 'saved',
  '[review-links 9] the limit of one link does not stop another');
reset role;

-- =====================================================================================
-- [review-links 6] The owner sees each link's progress and the answers to look at
-- =====================================================================================

-- Known times, so "newest first" has one right order: Eero's Not sure now, then Aino's Needs a fix
-- 10 minutes ago, her Not sure 20 minutes ago and her 500 character note an hour ago.
update private.review_answers set answered_at = now() - interval '10 minutes'
 where line_id = current_setting('rl.b1d2l2')::bigint;
update private.review_answers set answered_at = now() - interval '20 minutes'
 where line_id = current_setting('rl.b1d1l3')::bigint;
update private.review_answers set answered_at = now() - interval '1 hour'
 where line_id = current_setting('rl.b1d2l1')::bigint;

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000025f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000065f1"}', true);
set local role authenticated;
select is(jsonb_array_length(public.owner_review_overview() -> 'links'), 3, '[review-links 6] the owner sees the three links');
select is(
  (select array_agg(k order by k) from jsonb_object_keys(public.owner_review_overview() -> 'links' -> 0) as k),
  array['answered', 'batch', 'id', 'lines', 'sent_at', 'signup_id'],
  '[review-links 6] each link has its sign up, batch, time, line count and answer count, and no secret');
select is(
  (select (x ->> 'answered')::integer from jsonb_array_elements(public.owner_review_overview() -> 'links') x
    where (x ->> 'batch')::integer = 1), 5,
  '[review-links 6] the batch 1 link has 5 lines answered');
select is(
  (select (x ->> 'lines')::bigint from jsonb_array_elements(public.owner_review_overview() -> 'links') x
    where (x ->> 'batch')::integer = 1),
  (select count(*) from public.dialogue_lines l join review_batches_seen b on b.dialogue_id = l.dialogue_id
    where b.batch = 1 and l.status = 'approved'),
  '[review-links 6] and knows how many lines batch 1 has');
select is(
  (select array_agg(x ->> 'answer') from jsonb_array_elements(public.owner_review_overview() -> 'answers') x),
  array['not_sure', 'needs_fix', 'not_sure', 'needs_fix'],
  '[review-links 6] only Needs a fix and Not sure answers are listed, newest first');
select is(public.owner_review_overview() -> 'answers' -> -1 ->> 'note', repeat('ä', 500),
  '[review-links 6] the oldest (an hour ago) is last, with its note');
select is(
  (select array_agg(k order by k) from jsonb_object_keys(public.owner_review_overview() -> 'answers' -> 0) as k),
  array['answer', 'answered_at', 'dialogue', 'english', 'line_id', 'link_id', 'name', 'note', 'position', 'speaker',
        'spoken', 'written'],
  '[review-links 6] each answer has the dialogue, the line, the note and the reviewer name');
select is(public.owner_review_overview() -> 'answers' -> 0 ->> 'name', 'Eero Laine',
  '[review-links 6] the newest answer names its reviewer');
reset role;

-- =====================================================================================
-- [review-links 5] Deleting removes the links and the answers
-- =====================================================================================

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000025f1", "role": "authenticated", "session_id": "00000000-0000-4000-8000-0000000065f1"}', true);
set local role authenticated;
select is(public.owner_delete_review_link((select (x ->> 'id')::uuid
    from jsonb_array_elements(public.owner_review_overview() -> 'links') x where (x ->> 'batch')::integer = 4)), true,
  '[review-links 1] the owner deletes one link (its email was not sent)');
select is(public.owner_delete_review_link('00000000-0000-4000-8000-000000000000'), false,
  '[review-links 1] deleting a link that is not there says so');
select is(public.owner_delete_reviewer_signup('00000000-0000-4000-8000-00000000a001'), true,
  '[review-links 5] the owner deletes the sign up from Aino');
reset role;

select is((select count(*) from private.review_links where signup_id = '00000000-0000-4000-8000-00000000a001'), 0::bigint,
  '[review-links 5] deleting the sign up removed its links');
select is((select count(*) from private.review_answers a join private.review_links r on r.id = a.link_id
            where r.batch = 1), 0::bigint, '[review-links 5] and its answers');
select is((select count(*) from private.review_answers), 1::bigint,
  '[review-links 5] the other reviewer''s answer is still there');
set local role anon;
select is(public.review_link_overview(repeat('a', 43)), null, '[review-links 2] [review-links 5] the deleted link no longer opens');
select is(public.review_link_answer(repeat('a', 43),
    current_setting('rl.b1d1l1')::bigint, 'correct', null), 'no_link',
  '[review-links 2] [review-links 5] and saves nothing');
reset role;

select * from finish();

rollback;
