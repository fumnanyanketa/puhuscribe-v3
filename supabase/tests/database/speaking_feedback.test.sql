-- Speaking feedback: speaking_attempts, kept_recordings, what withdrawing voice
-- consent does, and the 90 day clean up (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/10-speaking-feedback/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.
--
-- Two test learners, made inside this transaction:
--   A = 00000000-0000-4000-8000-0000000010a1 (a guest)
--   B = 00000000-0000-4000-8000-0000000010b1 (a guest)
-- Acting as a learner means what PostgREST does: put the token's claims in
-- request.jwt.claims and switch to the authenticated role.

begin;

create extension if not exists pgtap with schema extensions;

select plan(87);

-- [speak 16] The tables, their permissions and their rules ------------------------

select has_table('public', 'speaking_attempts', '[speak 16] public.speaking_attempts exists');
select has_table('public', 'kept_recordings', '[speak 16] public.kept_recordings exists');
select columns_are('public', 'speaking_attempts',
  array['id', 'user_id', 'session_id', 'line_id', 'form_id', 'transcript', 'feedback_class', 'provider',
        'audio_ms', 'cost_usd', 'created_at'],
  '[speak 16] speaking_attempts has exactly its listed columns: no audio, device, address or free text');
select columns_are('public', 'kept_recordings',
  array['id', 'user_id', 'line_id', 'slot', 'audio', 'created_at'],
  '[speak 16] kept_recordings has exactly its listed columns');
select enum_has_labels('public', 'speech_feedback_class', array['clear', 'close', 'try_again', 'not_heard'],
  '[speak 16] speech_feedback_class is clear, close, try_again, not_heard');
select col_type_is('public', 'speaking_attempts', 'feedback_class', 'speech_feedback_class',
  '[speak 16] speaking_attempts.feedback_class is a speech_feedback_class');
select col_type_is('public', 'kept_recordings', 'audio', 'bytea', '[speak 16] kept_recordings.audio holds bytes');
select col_default_is('public', 'speaking_attempts', 'user_id', 'auth.uid()',
  '[speak 16] speaking_attempts.user_id defaults to the learner''s own id');
select col_default_is('public', 'kept_recordings', 'user_id', 'auth.uid()',
  '[speak 16] kept_recordings.user_id defaults to the learner''s own id');
select col_default_is('public', 'speaking_attempts', 'created_at', 'now()',
  '[speak 16] speaking_attempts.created_at is set by the database');
select col_default_is('public', 'kept_recordings', 'created_at', 'now()',
  '[speak 16] kept_recordings.created_at is set by the database');
select is(
  (select array_agg(a.attname::text || ' ' || k.confrelid::regclass::text || ' ' || k.confdeltype::text
                    order by a.attname)
     from pg_constraint k
     join pg_attribute a on a.attrelid = k.conrelid and a.attnum = k.conkey[1]
    where k.conrelid = 'public.speaking_attempts'::regclass and k.contype = 'f'),
  array['form_id forms r', 'line_id dialogue_lines r', 'session_id sessions c', 'user_id auth.users c'],
  '[speak 16] an attempt goes with its user and its session, and holds on to its line or form');
select ok((select relrowsecurity from pg_class where oid = 'public.speaking_attempts'::regclass),
  '[speak 16] row level security is on for speaking_attempts');
select ok((select relrowsecurity from pg_class where oid = 'public.kept_recordings'::regclass),
  '[speak 16] row level security is on for kept_recordings');
select table_privs_are('public', 'speaking_attempts', 'anon', array[]::text[],
  '[speak 16] anon has no permission on speaking_attempts');
select table_privs_are('public', 'kept_recordings', 'anon', array[]::text[],
  '[speak 16] anon has no permission on kept_recordings');
select table_privs_are('public', 'speaking_attempts', 'service_role', array[]::text[],
  '[speak 16] service_role has no permission on speaking_attempts');
select table_privs_are('public', 'kept_recordings', 'service_role', array[]::text[],
  '[speak 16] service_role has no permission on kept_recordings');
select table_privs_are('public', 'speaking_attempts', 'authenticated', array['SELECT'],
  '[speak 16] a learner may read speaking_attempts (whole table permission)');
select table_privs_are('public', 'kept_recordings', 'authenticated', array['DELETE', 'SELECT'],
  '[speak 16] a learner may read and delete kept_recordings (whole table permission)');
select results_eq(
  $$select (c.relname::text || '.' || a.attname::text || ' ' || coalesce(r.rolname::text, 'PUBLIC') || ' '
           || x.privilege_type::text) collate "C" as g
      from pg_attribute a
      join pg_class c on c.oid = a.attrelid
      cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
     where c.oid in ('public.speaking_attempts'::regclass, 'public.kept_recordings'::regclass)
       and a.attnum > 0 and not a.attisdropped
     order by g$$,
  $$select g collate "C" from unnest(array[
      'kept_recordings.audio authenticated INSERT',
      'kept_recordings.line_id authenticated INSERT',
      'kept_recordings.slot authenticated INSERT',
      'kept_recordings.user_id authenticated INSERT',
      'speaking_attempts.audio_ms authenticated INSERT',
      'speaking_attempts.cost_usd authenticated INSERT',
      'speaking_attempts.feedback_class authenticated INSERT',
      'speaking_attempts.form_id authenticated INSERT',
      'speaking_attempts.line_id authenticated INSERT',
      'speaking_attempts.provider authenticated INSERT',
      'speaking_attempts.session_id authenticated INSERT',
      'speaking_attempts.transcript authenticated INSERT',
      'speaking_attempts.transcript authenticated UPDATE',
      'speaking_attempts.user_id authenticated INSERT'
    ]) as x(g) order by g collate "C"$$,
  '[speak 16] the column grants: a learner adds rows and may change only the transcript; no id or time'
);
select policies_are('public', 'speaking_attempts',
  array['learners read their own attempts', 'learners add attempts with voice consent',
        'learners clear their own transcripts'],
  '[speak 16] speaking_attempts has exactly its three rules');
select policies_are('public', 'kept_recordings',
  array['learners read their own kept recordings', 'learners keep recordings with retention consent',
        'learners delete their own kept recordings'],
  '[speak 16] kept_recordings has exactly its three rules');

-- [speak 19] keep_recording runs as the learner, for learners only.
select ok(not (select prosecdef from pg_proc where oid = 'public.keep_recording(bigint, text)'::regprocedure),
  '[speak 19] keep_recording is security invoker');
select ok((select proconfig @> array['search_path=""'] from pg_proc
            where oid = 'public.keep_recording(bigint, text)'::regprocedure),
  '[speak 19] keep_recording runs with an empty search_path');
select ok(has_function_privilege('authenticated', 'public.keep_recording(bigint, text)', 'EXECUTE'),
  '[speak 19] a learner may call keep_recording');
select ok(not has_function_privilege('anon', 'public.keep_recording(bigint, text)', 'EXECUTE'),
  '[speak 19] anon may not call keep_recording');
select ok(not has_function_privilege('service_role', 'public.keep_recording(bigint, text)', 'EXECUTE'),
  '[speak 19] service_role may not call keep_recording');

-- [speak 18] The clean up is closed to the API roles and runs daily.
select ok(not has_function_privilege('authenticated', 'private.forget_old_voice_data()', 'EXECUTE'),
  '[speak 18] a learner may not run the clean up');
select results_eq(
  $$select schedule, command from cron.job where jobname = 'forget-old-voice-data'$$,
  $$values ('17 3 * * *'::text, 'select private.forget_old_voice_data()'::text)$$,
  '[speak 18] pg_cron runs the clean up once a day'
);
select has_trigger('public', 'consents', 'voice_withdrawal',
  '[speak 4] withdrawing a voice consent runs the withdrawal trigger');

-- Test content and learners, written as the database owner ------------------------
-- Dialogue 1 has lines one (910030001) and two (910030002), approved, and a
-- retired line (910030003). Dialogue 2 has line three (910030004). A holds a card for
-- form held (910030011), not for form not-held (910030012). The ids are fixed and
-- far above any real content id, so the tests can name a retired line that a
-- learner cannot read. A WAV stands in as 102 bytes of silence, written as
-- base64: repeat('A', 136).

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values ('pgtap-speak-unit', 900301, 'pgtap unit', 'pgtap can do', 'approved', now(), 'pgtap review');

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, 'pgtap dialogue'
  from (values ('pgtap-speak-1', 1), ('pgtap-speak-2', 2)) as d(slug, position)
  cross join public.units u
 where u.slug = 'pgtap-speak-unit';

insert into public.forms
  (id, lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
overriding system value
select f.id, 'pgtap-speak', f.tag, 'pgtap-k-' || f.tag, 'pgtap-p-' || f.tag, 'pgtap form', 'pgtap why',
       'approved', now(), 'pgtap review'
  from (values (910030011, 'held'), (910030012, 'not-held')) as f(id, tag);

insert into public.dialogue_lines
  (id, dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
overriding system value
select l.id, d.id, l.position, 'pgtap speaker', 'pgtap puhe', 'pgtap kirja', l.gloss, 'pgtap/p.mp3', 'pgtap/k.mp3'
  from (values (910030001, 'pgtap-speak-1', 1, 'pgtap speak line one'),
               (910030002, 'pgtap-speak-1', 2, 'pgtap speak line two'),
               (910030003, 'pgtap-speak-1', 3, 'pgtap speak line draft'),
               (910030004, 'pgtap-speak-2', 1, 'pgtap speak line three')) as l(id, dialogue_slug, position, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

update public.dialogue_lines set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where gloss_en in ('pgtap speak line one', 'pgtap speak line two', 'pgtap speak line three');
-- A dialogue with a draft line cannot be approved, so the unreadable line is
-- retired (taken out on purpose), which hides it from learners the same way.
update public.dialogue_lines set status = 'retired' where gloss_en = 'pgtap speak line draft';
update public.dialogues set status = 'approved', approved_at = now(), approval_ref = 'pgtap review'
 where slug in ('pgtap-speak-1', 'pgtap-speak-2');

insert into auth.users (id) values
  ('00000000-0000-4000-8000-0000000010a1'),
  ('00000000-0000-4000-8000-0000000010b1');

insert into public.sessions (id, user_id, dialogue_id, step_reached, started_at)
select s.id::uuid, s.user_id::uuid, d.id, s.step::public.loop_step, now() - interval '1 hour'
  from (values
    ('00000000-0000-4000-8000-00000010a001', '00000000-0000-4000-8000-0000000010a1', 'pgtap-speak-1', 'understand'),
    ('00000000-0000-4000-8000-00000010a002', '00000000-0000-4000-8000-0000000010a1', 'pgtap-speak-1', 'hear'),
    ('00000000-0000-4000-8000-00000010b001', '00000000-0000-4000-8000-0000000010b1', 'pgtap-speak-1', 'understand')
  ) as s(id, user_id, dialogue_slug, step)
  join public.dialogues d on d.slug = s.dialogue_slug;

insert into public.cards (user_id, form_id) values ('00000000-0000-4000-8000-0000000010a1', 910030011);

-- B, with consent, an attempt with a transcript and a kept recording, written
-- as the owner. A must not be able to reach any of it.
insert into public.consents (user_id, kind, granted, notice_version) values
  ('00000000-0000-4000-8000-0000000010b1', 'voice_processing', true, 'pgtap'),
  ('00000000-0000-4000-8000-0000000010b1', 'voice_recording_retention', true, 'pgtap');
insert into public.speaking_attempts
  (user_id, session_id, line_id, transcript, feedback_class, provider, audio_ms, cost_usd)
select '00000000-0000-4000-8000-0000000010b1', '00000000-0000-4000-8000-00000010b001', 910030001,
       'b heard', 'clear', 'fake', 1500, 0;
insert into public.kept_recordings (user_id, line_id, slot, audio)
select '00000000-0000-4000-8000-0000000010b1', 910030001, 'first', decode(repeat('A', 136), 'base64');

-- [speak 16] anon reaches nothing -------------------------------------------------

set local role anon;
select throws_ok($$select * from public.speaking_attempts$$, '42501', null,
  '[speak 16] anon cannot read speaking_attempts');
select throws_ok($$select * from public.kept_recordings$$, '42501', null,
  '[speak 16] anon cannot read kept_recordings');
select throws_ok($$select public.keep_recording(1, 'AAAA')$$, '42501', null,
  '[speak 16] anon cannot call keep_recording');
reset role;

-- Learner A ----------------------------------------------------------------------

select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000010a1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;

select is_empty($$select 1 from public.speaking_attempts$$, '[speak 16] A cannot read B''s attempts');
select is_empty($$select 1 from public.kept_recordings$$, '[speak 16] A cannot read B''s kept recordings');

-- [speak 16] No attempt before consent. Every other part of the rule passes
-- (own id, own session at understand, a line of its dialogue), so only the
-- consent part can refuse it.
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030001, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt without voice consent');

insert into public.consents (kind, granted, notice_version) values ('voice_processing', true, 'voice-2026-10.1');

select lives_ok(
  $$insert into public.speaking_attempts
      (session_id, line_id, transcript, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030001, 'a heard one', 'close', 'fake', 2000, 0.00055556$$,
  '[speak 16] with consent, A can add an attempt for a line of A''s own session at understand');
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a002', 910030001, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt for a line from a session not at understand');
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010b001', 910030001, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt through B''s session');
select throws_ok(
  $$insert into public.speaking_attempts
      (user_id, session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-0000000010b1', '00000000-0000-4000-8000-00000010a001', 910030001,
           'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt carrying B''s id');
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030003, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt for a line A cannot read (retired)');
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030004, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot add an attempt for a line of another dialogue');
select lives_ok(
  $$insert into public.speaking_attempts (form_id, transcript, feedback_class, provider, audio_ms, cost_usd)
    select 910030011, 'a heard form', 'clear', 'fake', 900, 0$$,
  '[speak 16] [speak 21] A can add a review attempt for a form A holds a card for');
select throws_ok(
  $$insert into public.speaking_attempts (form_id, feedback_class, provider, audio_ms, cost_usd)
    select 910030012, 'clear', 'fake', 900, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] [speak 21] A cannot add a review attempt for a form A holds no card for');
select throws_ok(
  $$insert into public.speaking_attempts
      (session_id, line_id, form_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030001, 910030011, 'clear', 'fake', 900, 0$$,
  '23514', null,
  '[speak 16] an attempt names a line or a form, never both');
select throws_ok(
  $$insert into public.speaking_attempts
      (session_id, line_id, transcript, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030001, repeat('a', 301), 'clear', 'fake', 900, 0$$,
  '23514', null,
  '[speak 16] a transcript holds at most 300 characters');
select throws_ok(
  $$insert into public.speaking_attempts
      (session_id, line_id, feedback_class, provider, audio_ms, cost_usd, created_at)
    select '00000000-0000-4000-8000-00000010a001', 910030001, 'clear', 'fake', 900, 0, now() - interval '100 days'$$,
  '42501', null,
  '[speak 16] [speak 18] A cannot choose an attempt''s time');
select throws_ok(
  $$update public.speaking_attempts set transcript = 'something else' where line_id is not null$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 16] A cannot change a transcript to anything but empty');
select throws_ok($$update public.speaking_attempts set feedback_class = 'clear'$$, '42501', null,
  '[speak 16] A cannot change a feedback class');
select throws_ok($$delete from public.speaking_attempts$$, '42501', null,
  '[speak 16] A cannot delete an attempt');

-- [speak 16] [speak 19] Kept recordings need retention consent and an attempt.
select throws_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '42501', 'new row violates row-level security policy for table "kept_recordings"',
  '[speak 16] [speak 19] A cannot keep a recording without retention consent');

insert into public.consents (kind, granted, notice_version)
values ('voice_recording_retention', true, 'voice-2026-10.1');

select lives_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '[speak 19] with retention consent, A''s first try of a line is kept');
select lives_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '[speak 19] the next try is kept as the latest');
select lives_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '[speak 19] a third try replaces the latest');
select results_eq(
  $$select slot from public.kept_recordings order by slot$$,
  $$values ('first'::text), ('latest'::text)$$,
  '[speak 16] [speak 19] after three tries A has exactly a first and a latest recording of the line');
select throws_ok(
  $$insert into public.kept_recordings (line_id, slot, audio) select 910030001, 'first', decode(repeat('A', 136), 'base64')$$,
  '23505', null,
  '[speak 16] A cannot add a third recording for one line');
select throws_ok(
  $$insert into public.kept_recordings (line_id, slot, audio) select 910030001, 'middle', decode(repeat('A', 136), 'base64')$$,
  '23514', null,
  '[speak 16] a recording''s slot is first or latest, nothing else');
select throws_ok($$select public.keep_recording(910030002, repeat('A', 136))$$,
  '42501', 'new row violates row-level security policy for table "kept_recordings"',
  '[speak 16] A cannot keep a recording of a line A has no attempt on');
select throws_ok(
  $$insert into public.kept_recordings (user_id, line_id, slot, audio)
    select '00000000-0000-4000-8000-0000000010b1', 910030001, 'latest', decode(repeat('A', 136), 'base64')$$,
  '42501', 'new row violates row-level security policy for table "kept_recordings"',
  '[speak 16] A cannot add a recording carrying B''s id');
select throws_ok(
  $$insert into public.kept_recordings (line_id, slot, audio) select 910030002, 'first', decode('00', 'hex')$$,
  '23514', null,
  '[speak 16] a kept recording is at least a WAV header long');
select throws_ok(
  $$insert into public.kept_recordings (line_id, slot, audio)
    select 910030001, 'latest', decode(repeat('00', 330001), 'hex')$$,
  '23514', null,
  '[speak 16] a kept recording holds at most 330,000 bytes');

-- A's attempts on B's rows change nothing (checked as the owner below).
select lives_ok($$delete from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000010b1'$$,
  '[speak 19] a delete aimed at B''s recordings runs without error');
select lives_ok(
  $$update public.speaking_attempts set transcript = '' where user_id = '00000000-0000-4000-8000-0000000010b1'$$,
  '[speak 16] an update aimed at B''s transcripts runs without error');

-- [speak 4] Withdrawing retention deletes every kept recording of A, in the same
-- transaction, and nothing else.
insert into public.consents (kind, granted, notice_version)
values ('voice_recording_retention', false, 'voice-2026-10.1');
select is_empty($$select 1 from public.kept_recordings$$,
  '[speak 4] turning off "keep my recordings" deleted every kept recording of A');
select is((select count(*) from public.speaking_attempts where transcript <> ''), 2::bigint,
  '[speak 4] turning off "keep my recordings" left the transcripts');
select throws_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '42501', 'new row violates row-level security policy for table "kept_recordings"',
  '[speak 4] after withdrawing retention, A cannot keep a recording');

-- [speak 4] Withdrawing speaking feedback deletes kept recordings and clears
-- every transcript; feedback classes stay.
insert into public.consents (kind, granted, notice_version)
values ('voice_recording_retention', true, 'voice-2026-10.1');
select lives_ok($$select public.keep_recording(910030001, repeat('A', 136))$$,
  '[speak 4] with retention granted again, A can keep a recording');
insert into public.consents (kind, granted, notice_version)
values ('voice_processing', false, 'voice-2026-10.1');
select is_empty($$select 1 from public.kept_recordings$$,
  '[speak 4] turning off speaking feedback deleted every kept recording of A');
select is_empty($$select 1 from public.speaking_attempts where transcript <> ''$$,
  '[speak 4] turning off speaking feedback cleared every transcript of A');
select results_eq(
  $$select feedback_class::text from public.speaking_attempts order by feedback_class$$,
  $$values ('clear'::text), ('close'::text)$$,
  '[speak 4] the feedback classes stay, because they hold no voice');
select throws_ok(
  $$insert into public.speaking_attempts (session_id, line_id, feedback_class, provider, audio_ms, cost_usd)
    select '00000000-0000-4000-8000-00000010a001', 910030001, 'clear', 'fake', 1500, 0$$,
  '42501', 'new row violates row-level security policy for table "speaking_attempts"',
  '[speak 4] [speak 16] after withdrawing speaking feedback, A cannot add an attempt');
reset role;

-- As the owner: B's rows were not touched by A -------------------------------------

select is((select transcript from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010b1'),
  'b heard', '[speak 4] [speak 16] B''s transcript is unchanged after everything A did');
select is((select count(*) from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000010b1'),
  1::bigint, '[speak 4] [speak 19] B''s kept recording is still there after everything A did');

-- [speak 4] Learner B: the same withdrawal also works when only speaking feedback
-- is turned off, with B's own recording.
select set_config('request.jwt.claims',
  '{"sub": "00000000-0000-4000-8000-0000000010b1", "role": "authenticated", "is_anonymous": true}', true);
set local role authenticated;
select is((select count(*) from public.kept_recordings), 1::bigint, '[speak 19] B can read B''s own recording');
select lives_ok($$delete from public.kept_recordings$$, '[speak 19] B can delete B''s own recordings');
select is_empty($$select 1 from public.kept_recordings$$, '[speak 19] B''s recordings are gone');
select is((select count(*) from public.speaking_attempts), 1::bigint,
  '[speak 16] B sees only B''s own attempt');
reset role;

-- [speak 18] Ninety days, then gone ----------------------------------------------
-- Written as the owner: two attempts and two recordings of B, one of each
-- 91 days old and one 89 days old.

delete from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010b1';
insert into public.speaking_attempts
  (user_id, session_id, line_id, transcript, feedback_class, provider, audio_ms, cost_usd, created_at)
select '00000000-0000-4000-8000-0000000010b1', '00000000-0000-4000-8000-00000010b001', 910030001, x.t,
       'clear', 'fake', 1500, 0, now() - x.age
  from (values ('old heard', interval '91 days'), ('new heard', interval '89 days')) as x(t, age);
insert into public.kept_recordings (user_id, line_id, slot, audio, created_at)
select '00000000-0000-4000-8000-0000000010b1', 910030001, x.slot, decode(repeat('A', 136), 'base64'), now() - x.age
  from (values ('first', interval '91 days'), ('latest', interval '89 days')) as x(slot, age);

select lives_ok($$select private.forget_old_voice_data()$$, '[speak 18] the clean up runs');
select results_eq(
  $$select transcript from public.speaking_attempts
     where user_id = '00000000-0000-4000-8000-0000000010b1' order by created_at$$,
  $$values (''::text), ('new heard'::text)$$,
  '[speak 18] the clean up cleared exactly the transcript older than 90 days');
select is((select count(*) from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010b1'),
  2::bigint, '[speak 18] the attempts themselves stay');
select results_eq(
  $$select slot from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000010b1'$$,
  $$values ('latest'::text)$$,
  '[speak 18] the clean up deleted exactly the recording older than 90 days');

-- [speak 16] Deleting a user removes both tables' rows -----------------------------

insert into public.kept_recordings (user_id, line_id, slot, audio)
select '00000000-0000-4000-8000-0000000010a1', 910030001, 'first', decode(repeat('A', 136), 'base64');
delete from auth.users where id = '00000000-0000-4000-8000-0000000010a1';
select is_empty($$select 1 from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010a1'$$,
  '[speak 16] deleting A removed A''s attempts');
select is_empty($$select 1 from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000010a1'$$,
  '[speak 16] deleting A removed A''s kept recordings');
select is((select count(*) from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010b1'),
  2::bigint, '[speak 16] B''s attempts stay');
delete from auth.users where id = '00000000-0000-4000-8000-0000000010b1';
select is_empty($$select 1 from public.speaking_attempts where user_id = '00000000-0000-4000-8000-0000000010b1'$$,
  '[speak 16] deleting B removed B''s attempts');
select is_empty($$select 1 from public.kept_recordings where user_id = '00000000-0000-4000-8000-0000000010b1'$$,
  '[speak 16] deleting B removed B''s kept recordings');

select * from finish();

rollback;
