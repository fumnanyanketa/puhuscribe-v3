-- Data model: tables, columns, enums, permissions and catalogue rules (pgTAP).
-- Labels in brackets are the "Done when" statement numbers from
-- factory/jobs/3-data-model/spec.md that each test protects.
--
-- Runs inside one transaction that is rolled back, so it leaves nothing behind,
-- also when it runs against the test project.

begin;

create extension if not exists pgtap with schema extensions;

select plan(145);

-- [data 1] Only these tables ----------------------------------------------------

select tables_are(
  'public',
  array[
    'units', 'dialogues', 'dialogue_lines', 'tokens', 'forms',
    'cards', 'review_logs', 'sessions', 'consents',
    'source_sentences', 'lemma_ipa',
    'usage_events',
    'speaking_attempts', 'kept_recordings', 'speech_checks',
    'feedback'
  ],
  '[data 1] [session 17] [session 21] [speak 16] [analytics 21] public holds exactly the content, learner, reference and usage event tables, the speaking tables and feedback, and nothing else (visits dropped in job 8)'
);

select enums_are(
  'public',
  array['content_status', 'finnish_register', 'card_state', 'review_mode', 'loop_step', 'consent_kind',
        'usage_event_name', 'speech_feedback_class'],
  '[data 1] [session 17] [speak 16] public has exactly the six enum types of the data model plus usage_event_name and speech_feedback_class'
);
select enum_has_labels('public', 'content_status', array['draft', 'approved', 'retired'],
  '[data 1] content_status is draft, approved, retired');
select enum_has_labels('public', 'finnish_register', array['puhe', 'kirja'],
  '[data 1] finnish_register is puhe, kirja');
select enum_has_labels('public', 'card_state', array['new', 'learning', 'review', 'relearning'],
  '[data 3] card_state has the same strings as State in src/lib/fsrs/types.ts');
select enum_has_labels('public', 'review_mode', array['typed', 'spoken'],
  '[data 3] review_mode is typed, spoken');
select enum_has_labels('public', 'loop_step', array['hear', 'understand', 'say', 'keep', 'use'],
  '[data 10] loop_step is hear, understand, say, keep, use, in that order');
select enum_has_labels('public', 'consent_kind', array['voice_processing', 'voice_recording_retention'],
  '[data 11] consent_kind is voice_processing, voice_recording_retention');

-- [data 1] [data 13] Exact columns. No content or reference table has a column
-- that identifies a learner or the reviewer.

select columns_are('public', 'units',
  array['id', 'slug', 'position', 'title_en', 'can_do_en', 'status', 'approved_at', 'approval_ref'],
  '[data 1] [data 13] units has exactly its listed columns (English titles only; design review 2)');
select columns_are('public', 'dialogues',
  array['id', 'unit_id', 'slug', 'position', 'title_en', 'status', 'approved_at', 'approval_ref'],
  '[data 1] [data 13] dialogues has exactly its listed columns');
select columns_are('public', 'dialogue_lines',
  array['id', 'dialogue_id', 'position', 'speaker', 'text_puhe', 'text_kirja', 'gloss_en',
        'audio_puhe_key', 'audio_kirja_key', 'status', 'approved_at', 'approval_ref'],
  '[data 1] [data 4] [data 13] dialogue_lines has exactly its listed columns');
select columns_are('public', 'tokens',
  array['id', 'line_id', 'register', 'position', 'surface', 'form_id'],
  '[data 1] [data 13] tokens has exactly its listed columns');
select columns_are('public', 'forms',
  array['id', 'lemma', 'form_tag', 'analysis', 'surface_kirja', 'surface_puhe', 'form_name_en', 'why_en',
        'status', 'approved_at', 'approval_ref'],
  '[data 1] [data 13] forms has exactly its listed columns');
select columns_are('public', 'cards',
  array['user_id', 'form_id', 'due', 'stability', 'difficulty', 'elapsed_days', 'scheduled_days',
        'reps', 'lapses', 'state', 'last_review', 'created_at'],
  '[data 1] [data 3] cards has the Card fields plus user_id, form_id and created_at');
select columns_are('public', 'review_logs',
  array['id', 'user_id', 'form_id', 'rating', 'mode', 'state', 'due', 'stability', 'difficulty',
        'elapsed_days', 'last_elapsed_days', 'scheduled_days', 'review_time'],
  '[data 1] [data 3] review_logs has the ReviewLog fields plus id, user_id, form_id and mode');
select columns_are('public', 'sessions',
  array['id', 'user_id', 'dialogue_id', 'step_reached', 'started_at', 'ended_at'],
  '[data 1] [data 10] sessions has exactly its listed columns');
select columns_are('public', 'consents',
  array['id', 'user_id', 'kind', 'granted', 'notice_version', 'created_at'],
  '[data 1] [data 11] consents has exactly its listed columns');
select columns_are('public', 'source_sentences',
  array['id', 'source', 'source_ref', 'text_kirja', 'text_puhe', 'gloss_en', 'note'],
  '[data 1] [data 13] source_sentences has exactly its listed columns');
select columns_are('public', 'lemma_ipa',
  array['lemma', 'ipa', 'source', 'licence'],
  '[data 1] [data 13] lemma_ipa has exactly its listed columns');

-- [data 1] Keys and links

select col_is_pk('public', 'cards', array['user_id', 'form_id'],
  '[data 3] a card is one row per learner per form (primary key user_id, form_id)');
select col_is_pk('public', 'lemma_ipa', 'lemma', '[data 16] lemma_ipa is keyed on the lemma');
select col_is_unique('public', 'source_sentences', array['source', 'source_ref'],
  '[data 15] source_sentences is unique on (source, source_ref)');
select col_is_unique('public', 'forms', array['lemma', 'form_tag', 'surface_kirja', 'surface_puhe'],
  '[data 1] forms is unique on (lemma, form_tag, surface_kirja, surface_puhe)');
select col_is_unique('public', 'tokens', array['line_id', 'register', 'position'],
  '[data 1] tokens is unique on (line_id, register, position)');
select fk_ok('public', 'review_logs', array['user_id', 'form_id'], 'public', 'cards', array['user_id', 'form_id'],
  '[data 3] review_logs links to its card');
select col_type_is('public', 'cards', 'state', 'card_state', '[data 3] cards.state is a card_state');
select col_type_is('public', 'review_logs', 'state', 'card_state', '[data 3] review_logs.state is a card_state');
select col_type_is('public', 'review_logs', 'mode', 'review_mode', '[data 3] review_logs.mode is a review_mode');
select col_type_is('public', 'sessions', 'step_reached', 'loop_step', '[data 10] sessions.step_reached is a loop_step');
select col_type_is('public', 'tokens', 'register', 'finnish_register', '[data 1] tokens.register is a finnish_register');

-- [data 2] Row level security is on for every table -----------------------------

select is_empty(
  $$ select c.relname::text from pg_class c
     where c.relnamespace = 'public'::regnamespace and c.relkind in ('r', 'p') and not c.relrowsecurity $$,
  '[data 2] [data 13] row level security is on for every table in public'
);

-- [data 2] Exact table permissions of each API role --------------------------------

select table_privs_are('public', t, 'anon', array[]::text[], format('[data 2] anon has no permission on %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms', 'cards', 'review_logs',
                    'sessions', 'consents', 'source_sentences', 'lemma_ipa']) as t;
select table_privs_are('public', t, 'service_role', array[]::text[], format('[data 2] service_role has no permission on %s', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms', 'cards', 'review_logs',
                    'sessions', 'consents', 'source_sentences', 'lemma_ipa']) as t;
select table_privs_are('public', t, 'authenticated', array['SELECT'],
  format('[data 2] a learner may only read %s (whole table permission)', t))
  from unnest(array['units', 'dialogues', 'dialogue_lines', 'tokens', 'forms',
                    'cards', 'review_logs', 'sessions', 'consents']) as t;
select table_privs_are('public', t, 'authenticated', array[]::text[],
  format('[data 2] a learner has no permission on %s', t))
  from unnest(array['source_sentences', 'lemma_ipa']) as t;

-- [data 2] Column permissions: what a learner may write, column by column. ----------

select column_privs_are('public', 'cards', c, 'authenticated', p,
  format('[data 2] cards.%s: a learner may %s', c, array_to_string(p, ', ')))
  from (values
    ('user_id', array['INSERT', 'SELECT']),
    ('form_id', array['INSERT', 'SELECT']),
    ('due', array['INSERT', 'SELECT', 'UPDATE']),
    ('stability', array['INSERT', 'SELECT', 'UPDATE']),
    ('difficulty', array['INSERT', 'SELECT', 'UPDATE']),
    ('elapsed_days', array['INSERT', 'SELECT', 'UPDATE']),
    ('scheduled_days', array['INSERT', 'SELECT', 'UPDATE']),
    ('reps', array['INSERT', 'SELECT', 'UPDATE']),
    ('lapses', array['INSERT', 'SELECT', 'UPDATE']),
    ('state', array['INSERT', 'SELECT', 'UPDATE']),
    ('last_review', array['INSERT', 'SELECT', 'UPDATE']),
    ('created_at', array['SELECT'])
  ) as x(c, p);

select column_privs_are('public', 'review_logs', c, 'authenticated', p,
  format('[data 2] review_logs.%s: a learner may %s', c, array_to_string(p, ', ')))
  from (values
    ('id', array['SELECT']),
    ('user_id', array['INSERT', 'SELECT']),
    ('form_id', array['INSERT', 'SELECT']),
    ('rating', array['INSERT', 'SELECT']),
    ('mode', array['INSERT', 'SELECT']),
    ('state', array['INSERT', 'SELECT']),
    ('due', array['INSERT', 'SELECT']),
    ('stability', array['INSERT', 'SELECT']),
    ('difficulty', array['INSERT', 'SELECT']),
    ('elapsed_days', array['INSERT', 'SELECT']),
    ('last_elapsed_days', array['INSERT', 'SELECT']),
    ('scheduled_days', array['INSERT', 'SELECT']),
    ('review_time', array['INSERT', 'SELECT'])
  ) as x(c, p);

select column_privs_are('public', 'sessions', c, 'authenticated', p,
  format('[data 2] sessions.%s: a learner may %s', c, array_to_string(p, ', ')))
  from (values
    ('id', array['SELECT']),
    ('user_id', array['INSERT', 'SELECT']),
    ('dialogue_id', array['INSERT', 'SELECT']),
    ('step_reached', array['SELECT', 'UPDATE']),
    ('started_at', array['SELECT']),
    ('ended_at', array['SELECT', 'UPDATE'])
  ) as x(c, p);

select column_privs_are('public', 'consents', c, 'authenticated', p,
  format('[data 2] consents.%s: a learner may %s', c, array_to_string(p, ', ')))
  from (values
    ('id', array['SELECT']),
    ('user_id', array['INSERT', 'SELECT']),
    ('kind', array['INSERT', 'SELECT']),
    ('granted', array['INSERT', 'SELECT']),
    ('notice_version', array['INSERT', 'SELECT']),
    ('created_at', array['SELECT'])
  ) as x(c, p);

-- [data 2] Column permissions, exactly: every column-level grant in public, for
-- every role (the API roles and PUBLIC), read from the catalogue. Whole-table
-- grants are checked above; this catches a stray column grant on any table,
-- such as SELECT (slug) for anon on units (evaluation, round 1).

select results_eq(
  $$select (c.relname::text || '.' || a.attname::text || ' ' || coalesce(r.rolname::text, 'PUBLIC') || ' '
           || x.privilege_type::text) collate "C" as g
      from pg_attribute a
      join pg_class c on c.oid = a.attrelid
      cross join lateral aclexplode(a.attacl) x
      left join pg_roles r on r.oid = x.grantee
     where c.relnamespace = 'public'::regnamespace
       and a.attnum > 0
       and not a.attisdropped
       and (x.grantee = 0 or r.rolname in ('anon', 'authenticated', 'service_role'))
     order by g$$,
  $$select g collate "C" from unnest(array[
      'cards.difficulty authenticated INSERT', 'cards.difficulty authenticated UPDATE',
      'cards.due authenticated INSERT', 'cards.due authenticated UPDATE',
      'cards.elapsed_days authenticated INSERT', 'cards.elapsed_days authenticated UPDATE',
      'cards.form_id authenticated INSERT',
      'cards.lapses authenticated INSERT', 'cards.lapses authenticated UPDATE',
      'cards.last_review authenticated INSERT', 'cards.last_review authenticated UPDATE',
      'cards.reps authenticated INSERT', 'cards.reps authenticated UPDATE',
      'cards.scheduled_days authenticated INSERT', 'cards.scheduled_days authenticated UPDATE',
      'cards.stability authenticated INSERT', 'cards.stability authenticated UPDATE',
      'cards.state authenticated INSERT', 'cards.state authenticated UPDATE',
      'cards.user_id authenticated INSERT',
      'consents.granted authenticated INSERT',
      'consents.kind authenticated INSERT',
      'consents.notice_version authenticated INSERT',
      'consents.user_id authenticated INSERT',
      'feedback.message authenticated INSERT',
      'feedback.screen authenticated INSERT',
      'feedback.user_id authenticated INSERT',
      'kept_recordings.audio authenticated INSERT',
      'kept_recordings.line_id authenticated INSERT',
      'kept_recordings.slot authenticated INSERT',
      'kept_recordings.user_id authenticated INSERT',
      'review_logs.difficulty authenticated INSERT',
      'review_logs.due authenticated INSERT',
      'review_logs.elapsed_days authenticated INSERT',
      'review_logs.form_id authenticated INSERT',
      'review_logs.last_elapsed_days authenticated INSERT',
      'review_logs.mode authenticated INSERT',
      'review_logs.rating authenticated INSERT',
      'review_logs.review_time authenticated INSERT',
      'review_logs.scheduled_days authenticated INSERT',
      'review_logs.stability authenticated INSERT',
      'review_logs.state authenticated INSERT',
      'review_logs.user_id authenticated INSERT',
      'sessions.dialogue_id authenticated INSERT',
      'sessions.ended_at authenticated UPDATE',
      'sessions.step_reached authenticated UPDATE',
      'sessions.user_id authenticated INSERT',
      'speaking_attempts.audio_ms authenticated INSERT',
      'speaking_attempts.cost_usd authenticated INSERT',
      'speaking_attempts.feedback_class authenticated INSERT',
      'speaking_attempts.form_id authenticated INSERT',
      'speaking_attempts.line_id authenticated INSERT',
      'speaking_attempts.provider authenticated INSERT',
      'speaking_attempts.session_id authenticated INSERT',
      'speaking_attempts.transcript authenticated INSERT',
      'speaking_attempts.transcript authenticated UPDATE',
      'speaking_attempts.user_id authenticated INSERT',
      'speech_checks.user_id authenticated INSERT',
      'usage_events.name authenticated INSERT',
      'usage_events.session_id authenticated INSERT',
      'usage_events.user_id authenticated INSERT'
    ]) as x(g) order by g collate "C"$$,
  '[data 2] [session 17] [speak 16] [analytics 21] the only column-level grants in public are the 61 learner write grants (40 from job 3, 3 on usage_events, 15 on the speaking tables, 3 on feedback), all to authenticated; anon, service_role and PUBLIC have none'
);

-- [data 6] The history of withdrawn content approvals is closed to every API role.
select table_privs_are('private', 'approval_history', r, array[]::text[],
  format('[data 6] %s has no permission on private.approval_history', r))
  from unnest(array['anon', 'authenticated', 'service_role']) as r;

-- [data 2] The id counters of the new tables are closed to every API role.

select sequence_privs_are('public', s, r, array[]::text[], format('[data 2] %s has no permission on %s', r, s))
  from unnest(array['units_id_seq', 'dialogues_id_seq', 'dialogue_lines_id_seq', 'tokens_id_seq',
                    'forms_id_seq', 'source_sentences_id_seq']) as s,
       unnest(array['anon', 'authenticated', 'service_role']) as r;

-- [data 2] Exact access rules per table ------------------------------------------

select policies_are('public', 'units', array['learners read approved units'],
  '[data 2] units has exactly one rule');
select policies_are('public', 'dialogues', array['learners read approved dialogues in approved units'],
  '[data 2] dialogues has exactly one rule');
select policies_are('public', 'dialogue_lines', array['learners read approved lines in approved dialogues'],
  '[data 2] dialogue_lines has exactly one rule');
select policies_are('public', 'tokens', array['learners read the tokens of approved lines'],
  '[data 2] tokens has exactly one rule');
select policies_are('public', 'forms', array['learners read approved forms'],
  '[data 2] forms has exactly one rule');
select policies_are('public', 'cards',
  array['learners read their own cards', 'learners add cards only for forms they met', 'learners update their own cards'],
  '[data 2] cards has exactly its three rules');
select policies_are('public', 'review_logs',
  array['learners read their own review logs', 'learners add their own review logs'],
  '[data 2] review_logs has exactly its two rules');
select policies_are('public', 'sessions',
  array['learners read their own sessions', 'learners start their own sessions', 'learners move their own sessions forward'],
  '[data 2] sessions has exactly its three rules');
select policies_are('public', 'consents',
  array['learners read their own consents', 'learners add their own consents'],
  '[data 2] consents has exactly its two rules');
select is_empty(
  $$ select policyname::text from pg_policies
     where schemaname = 'public' and tablename in ('source_sentences', 'lemma_ipa') $$,
  '[data 7] the reference tables have no rule at all'
);
select is_empty(
  $$ select tablename || ': ' || policyname from pg_policies
     where schemaname = 'public' and tablename <> 'visits' and roles <> array['authenticated']::name[] $$,
  '[data 2] every rule on a new table names the authenticated role, and only it'
);

-- [data 12] No access rule looks at whether the learner is a guest ---------------

select is_empty(
  $$ select tablename || ': ' || policyname from pg_policies
     where coalesce(qual, '') ilike '%is_anonymous%' or coalesce(with_check, '') ilike '%is_anonymous%' $$,
  '[data 12] no access rule mentions is_anonymous'
);

-- [data 13] Every user_id links to auth.users(id) with on delete cascade --------------
-- Read from the catalogue, so a future table that forgets fails here.

select isnt_empty(
  $$ select c.relname from pg_attribute a join pg_class c on c.oid = a.attrelid
     where c.relnamespace = 'public'::regnamespace and c.relkind = 'r'
       and a.attname = 'user_id' and not a.attisdropped $$,
  '[data 13] the catalogue check below has user_id columns to look at'
);
select is_empty(
  $$ select c.relname::text from pg_attribute a join pg_class c on c.oid = a.attrelid
     where c.relnamespace = 'public'::regnamespace and c.relkind = 'r'
       and a.attname = 'user_id' and not a.attisdropped
       and not exists (
         select 1 from pg_constraint k
         where k.conrelid = c.oid and k.contype = 'f'
           and k.confrelid = 'auth.users'::regclass
           and k.conkey = array[a.attnum]
           and k.confkey = array[(select u.attnum from pg_attribute u
                                  where u.attrelid = 'auth.users'::regclass and u.attname = 'id')]
           and k.confdeltype = 'c'
       ) $$,
  '[data 13] every user_id column in public links to auth.users(id) with on delete cascade'
);
select is_empty(
  $$ select c.relname::text from pg_attribute a join pg_class c on c.oid = a.attrelid
     where c.relnamespace = 'public'::regnamespace and c.relkind = 'r'
       and a.attname = 'user_id' and not a.attisdropped and not c.relrowsecurity $$,
  '[data 13] every table with a user_id column has row level security on'
);
select is_empty(
  $$ select k.conrelid::regclass::text from pg_constraint k
     where k.contype = 'f' and k.confrelid = 'auth.users'::regclass
       and k.conrelid in ('public.units'::regclass, 'public.dialogues'::regclass, 'public.dialogue_lines'::regclass,
                          'public.tokens'::regclass, 'public.forms'::regclass,
                          'public.source_sentences'::regclass, 'public.lemma_ipa'::regclass) $$,
  '[data 13] no content or reference table links to a user'
);

-- [data 11] No table stores audio, a recording or a transcript of the learner ----------

select is_empty(
  $$ select table_name || '.' || column_name from information_schema.columns
     where table_schema = 'public'
       and table_name in ('cards', 'review_logs', 'sessions', 'consents')
       and column_name ~ '(audio|recording|transcript|voice|speech)' $$,
  '[data 11] no learner table has an audio, recording, transcript or voice column'
);
select results_eq(
  $$ select (table_name::text || '.' || column_name::text) collate "C" from information_schema.columns
     where table_schema = 'public' and data_type = 'bytea' $$,
  $$ values ('kept_recordings.audio'::text collate "C") $$,
  '[data 11] [speak 16] the only table in public that stores raw bytes is kept_recordings (audio kept only with retention consent, job 10)'
);

-- [data 14] Content links refuse deletes of rows in use -------------------------------

select is(
  (select array_agg(x order by x) from (
     select k.conrelid::regclass::text || '.' || a.attname || ' ' || k.confdeltype::text as x
     from pg_constraint k
     join pg_attribute a on a.attrelid = k.conrelid and a.attnum = k.conkey[1]
    where k.contype = 'f'
      and k.confrelid in ('public.units'::regclass, 'public.dialogues'::regclass,
                          'public.dialogue_lines'::regclass, 'public.forms'::regclass)) as links),
  array['cards.form_id r', 'dialogue_lines.dialogue_id r', 'dialogues.unit_id r', 'kept_recordings.line_id r',
        'review_logs.form_id r', 'sessions.dialogue_id r', 'speaking_attempts.form_id r',
        'speaking_attempts.line_id r', 'tokens.form_id r', 'tokens.line_id r'],
  '[data 14] [speak 16] every link to a unit, dialogue, line or form is on delete restrict'
);

-- Helper functions live in a schema the API does not expose ------------------------

select ok(not has_schema_privilege('anon', 'private', 'USAGE'), '[data 2] anon cannot use the private schema');
select ok(not has_schema_privilege('authenticated', 'private', 'USAGE'),
  '[data 2] a learner cannot use the private schema');
select is_empty(
  $$ select p.proname::text from pg_proc p
     where p.pronamespace = 'private'::regnamespace
       and not coalesce(p.proconfig @> array['search_path=""'], false) $$,
  '[data 2] every helper function in private runs with an empty search_path'
);

select * from finish();

rollback;
