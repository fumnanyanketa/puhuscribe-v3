-- Job 3-data-model, part 2: the learner tables.
-- Spec: factory/jobs/3-data-model/spec.md, "Done when" 1 to 3 and 8 to 14.
-- Plain English description of every table: docs/data-model.md.
--
-- A learner is the `authenticated` role with a user id in its token. A guest
-- (Supabase anonymous sign in) and an email account reach the database the same
-- way, and a guest keeps the same user id when they add an email, so every
-- table links straight to auth.users(id). No rule looks at whether the learner
-- is a guest. Deleting a user from auth.users deletes all their rows here.
--
-- No table here stores audio, a recording or a transcript of the learner.

-- Enums ----------------------------------------------------------------------

-- The same strings as State in src/lib/fsrs/types.ts (imported from v2).
create type public.card_state as enum ('new', 'learning', 'review', 'relearning');
create type public.review_mode as enum ('typed', 'spoken');
-- The five steps of the loop, in order, so "at least understand" is a plain
-- comparison.
create type public.loop_step as enum ('hear', 'understand', 'say', 'keep', 'use');
create type public.consent_kind as enum ('voice_processing', 'voice_recording_retention');

-- Tables ---------------------------------------------------------------------

-- One sitting of the loop. dialogue_id is empty for a review only session.
-- step_reached is empty until the learner finishes the first step.
create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  dialogue_id bigint references public.dialogues (id) on delete restrict,
  step_reached public.loop_step,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  constraint sessions_end_after_start check (ended_at is null or ended_at >= started_at)
);

-- Review state per learner per form. The columns and their defaults match the
-- Card type and createEmptyCard() in src/lib/fsrs/ one to one.
create table public.cards (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  form_id bigint not null references public.forms (id) on delete restrict,
  due timestamptz not null default now(),
  stability double precision not null default 0,
  difficulty double precision not null default 0,
  elapsed_days integer not null default 0,
  scheduled_days integer not null default 0,
  reps integer not null default 0 check (reps >= 0),
  lapses integer not null default 0 check (lapses >= 0),
  state public.card_state not null default 'new',
  last_review timestamptz,
  created_at timestamptz not null default now(),
  primary key (user_id, form_id)
);

-- One row per review, never changed. The columns match the ReviewLog type in
-- src/lib/fsrs/types.ts, plus who, which form and how it was answered. The
-- rating is the grader's (src/lib/grade.ts), never the learner's own.
create table public.review_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  form_id bigint not null references public.forms (id) on delete restrict,
  rating smallint not null check (rating between 1 and 4),
  mode public.review_mode not null,
  state public.card_state not null,
  due timestamptz not null,
  stability double precision not null,
  difficulty double precision not null,
  elapsed_days integer not null,
  last_elapsed_days integer not null,
  scheduled_days integer not null,
  review_time timestamptz not null,
  foreign key (user_id, form_id) references public.cards (user_id, form_id) on delete cascade
);

-- Voice consent history: one row per choice, never changed. The learner's
-- current choice is the newest row of each kind. created_at is the clock time
-- of the insert (not the transaction's start), so two choices are never tied.
create table public.consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind public.consent_kind not null,
  granted boolean not null,
  -- A short label for the version of the consent text shown, such as "v1" or
  -- "2026-10.1". Learners write this column, so it is kept short and holds
  -- nothing but a label (security review, round 1).
  notice_version text not null check (notice_version ~ '^[A-Za-z0-9._-]{1,32}$'),
  created_at timestamptz not null default clock_timestamp()
);

comment on table public.sessions is
  'Learner data (job 3-data-model): one sitting of the loop and the step reached.';
comment on table public.cards is
  'Learner data (job 3-data-model): review state per learner per form (FSRS card).';
comment on table public.review_logs is
  'Learner data (job 3-data-model): one row per review, append only. Rating from the grader.';
comment on table public.consents is
  'Learner data (job 3-data-model): voice consent history, append only.';

-- Indexes for the columns the access rules and the "due today" query use, and
-- for the links that restrict deletes.
create index sessions_user_id_dialogue_id_idx on public.sessions (user_id, dialogue_id);
create index sessions_dialogue_id_idx on public.sessions (dialogue_id);
create index cards_user_id_due_idx on public.cards (user_id, due);
create index cards_form_id_idx on public.cards (form_id);
create index review_logs_user_id_form_id_idx on public.review_logs (user_id, form_id);
create index review_logs_form_id_idx on public.review_logs (form_id);
create index consents_user_id_kind_created_at_idx on public.consents (user_id, kind, created_at);

-- A session's step only moves forward ------------------------------------------

create function private.session_step_moves_forward()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.step_reached is not null
     and (new.step_reached is null or new.step_reached < old.step_reached) then
    raise exception 'a session step only moves forward (from % to %)',
      old.step_reached, coalesce(new.step_reached::text, 'empty');
  end if;
  return new;
end;
$$;

create trigger step_moves_forward before update on public.sessions
  for each row execute function private.session_step_moves_forward();

revoke all on function private.session_step_moves_forward() from public, anon, authenticated, service_role;

-- Permissions -------------------------------------------------------------------
-- Remove everything, then grant learners exactly what the spec's "Who can do
-- what" table says. Column lists keep the keys and the times the database sets
-- out of a learner's reach: a card cannot be moved to another form, a session
-- cannot be moved to another dialogue, and nobody chooses created_at.
-- No deletes for anyone: rows go only when the user is deleted.

revoke all on table public.sessions, public.cards, public.review_logs, public.consents
  from anon, authenticated, service_role;

grant select on table public.sessions, public.cards, public.review_logs, public.consents
  to authenticated;

grant insert (user_id, dialogue_id) on table public.sessions to authenticated;
grant update (step_reached, ended_at) on table public.sessions to authenticated;

grant insert (
  user_id, form_id, due, stability, difficulty, elapsed_days, scheduled_days,
  reps, lapses, state, last_review
) on table public.cards to authenticated;
grant update (
  due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review
) on table public.cards to authenticated;

grant insert (
  user_id, form_id, rating, mode, state, due, stability, difficulty, elapsed_days,
  last_elapsed_days, scheduled_days, review_time
) on table public.review_logs to authenticated;

grant insert (user_id, kind, granted, notice_version) on table public.consents to authenticated;

-- Row level security: each learner reaches only rows carrying their own id.

alter table public.sessions enable row level security;
alter table public.cards enable row level security;
alter table public.review_logs enable row level security;
alter table public.consents enable row level security;

create policy "learners read their own sessions"
  on public.sessions
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- A session is for an approved dialogue (in an approved unit, through the
-- dialogues read rule), or for review only.
create policy "learners start their own sessions"
  on public.sessions
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and (
      dialogue_id is null
      or exists (
        select 1 from public.dialogues d
        where d.id = sessions.dialogue_id and d.status = 'approved'
      )
    )
  );

create policy "learners move their own sessions forward"
  on public.sessions
  for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "learners read their own cards"
  on public.cards
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- Nothing unmet is reviewed: a card for a form can be created only after the
-- learner reached at least "understand" in a session of an approved dialogue
-- that contains the form. The lines and tokens read rules make sure the line
-- and everything above it are approved; the form must be approved too.
create policy "learners add cards only for forms they met"
  on public.cards
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.forms f
      where f.id = cards.form_id and f.status = 'approved'
    )
    and exists (
      select 1
      from public.sessions s
      join public.dialogue_lines l on l.dialogue_id = s.dialogue_id
      join public.tokens t on t.line_id = l.id
      where s.user_id = (select auth.uid())
        and s.step_reached >= 'understand'
        and t.form_id = cards.form_id
    )
  );

create policy "learners update their own cards"
  on public.cards
  for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "learners read their own review logs"
  on public.review_logs
  for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "learners add their own review logs"
  on public.review_logs
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy "learners read their own consents"
  on public.consents
  for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "learners add their own consents"
  on public.consents
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));
