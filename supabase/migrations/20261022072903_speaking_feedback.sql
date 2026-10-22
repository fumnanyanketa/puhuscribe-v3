-- Job 10-speaking-feedback: speaking attempts, kept recordings, what voice
-- consent withdrawal does, and the 90 day clean up.
-- Spec: factory/jobs/10-speaking-feedback/spec.md, "Done when" 4, 16, 18 and 19.
-- Plain English description: docs/data-model.md.
--
-- The Worker writes every row here with the learner's own token, so these
-- rules decide what is allowed. Audio is kept only for learners whose newest
-- voice_recording_retention consent is granted, at most a first and a latest
-- try per line, for 90 days. Transcripts are cleared after 90 days, and at
-- once when the learner turns speaking feedback off.

-- The daily clean up runs with pg_cron (Supabase Cron). It creates its own
-- cron schema; nothing in it is exposed to the API roles.
create extension if not exists pg_cron with schema pg_catalog;

-- Enum -------------------------------------------------------------------------

create type public.speech_feedback_class as enum ('clear', 'close', 'try_again', 'not_heard');

-- Tables -----------------------------------------------------------------------

-- One row per check that reached the speech service: a line in Say it (with
-- its session) or a form in spoken review (no session). It holds the text the
-- service heard (cleared after 90 days), the feedback class, and what the call
-- cost. No audio, device, address or free text column.
create table public.speaking_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  session_id uuid references public.sessions (id) on delete cascade,
  line_id bigint references public.dialogue_lines (id) on delete restrict,
  form_id bigint references public.forms (id) on delete restrict,
  transcript text not null default '' check (char_length(transcript) <= 300),
  feedback_class public.speech_feedback_class not null,
  -- A short label such as "azure" or "fake", never free text.
  provider text not null check (provider ~ '^[a-z0-9_-]{1,32}$'),
  audio_ms integer not null check (audio_ms between 0 and 10000),
  cost_usd numeric(12, 8) not null check (cost_usd >= 0),
  created_at timestamptz not null default now(),
  -- Exactly one of a line (with its session) or a form (review, no session).
  constraint speaking_attempts_line_or_form check (
    (line_id is not null and session_id is not null and form_id is null)
    or (form_id is not null and line_id is null and session_id is null)
  )
);

-- Recordings kept only for learners who opted in: the first and the latest
-- try of each line, as 16 kHz mono 16 bit WAV (10 seconds is 320,044 bytes).
create table public.kept_recordings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  line_id bigint not null references public.dialogue_lines (id) on delete restrict,
  slot text not null check (slot in ('first', 'latest')),
  audio bytea not null check (octet_length(audio) between 44 and 330000),
  created_at timestamptz not null default now(),
  constraint kept_recordings_one_per_slot unique (user_id, line_id, slot)
);

comment on table public.speaking_attempts is
  'Learner data (job 10-speaking-feedback): one row per speech check, with the transcript (cleared after 90 days), the feedback class and the cost. No audio.';
comment on table public.kept_recordings is
  'Learner data (job 10-speaking-feedback): recordings kept only with retention consent, first and latest per line, deleted after 90 days.';

-- Indexes for the columns the rules, the rate limit, the clean up and the
-- restricting links use.
create index speaking_attempts_user_id_created_at_idx on public.speaking_attempts (user_id, created_at);
create index speaking_attempts_user_id_line_id_idx on public.speaking_attempts (user_id, line_id);
create index speaking_attempts_session_id_idx on public.speaking_attempts (session_id);
create index speaking_attempts_line_id_idx on public.speaking_attempts (line_id);
create index speaking_attempts_form_id_idx on public.speaking_attempts (form_id);
create index speaking_attempts_created_at_idx on public.speaking_attempts (created_at);
create index kept_recordings_line_id_idx on public.kept_recordings (line_id);
create index kept_recordings_created_at_idx on public.kept_recordings (created_at);

-- Permissions -------------------------------------------------------------------
-- Remove everything, then a learner may read their own rows of both tables,
-- add their own rows, delete their own kept recordings, and change a
-- transcript only to empty. The ids and times are set by the database.

revoke all on table public.speaking_attempts, public.kept_recordings from anon, authenticated, service_role;

grant select on table public.speaking_attempts, public.kept_recordings to authenticated;
grant insert (user_id, session_id, line_id, form_id, transcript, feedback_class, provider, audio_ms, cost_usd)
  on table public.speaking_attempts to authenticated;
grant update (transcript) on table public.speaking_attempts to authenticated;
grant insert (user_id, line_id, slot, audio) on table public.kept_recordings to authenticated;
grant delete on table public.kept_recordings to authenticated;

alter table public.speaking_attempts enable row level security;
alter table public.kept_recordings enable row level security;

create policy "learners read their own attempts"
  on public.speaking_attempts
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- An attempt needs the learner's newest voice_processing consent to be a
-- grant, and either a line of their own session at Understand it or later
-- (the lines read rule hides anything not approved), or a form they hold a
-- card for.
create policy "learners add attempts with voice consent"
  on public.speaking_attempts
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and coalesce((
      select c.granted from public.consents c
       where c.user_id = (select auth.uid()) and c.kind = 'voice_processing'
       order by c.created_at desc
       limit 1
    ), false)
    and (
      (
        speaking_attempts.line_id is not null
        and exists (
          select 1
            from public.sessions s
            join public.dialogue_lines l on l.dialogue_id = s.dialogue_id
           where s.id = speaking_attempts.session_id
             and s.user_id = (select auth.uid())
             and s.step_reached >= 'understand'
             and l.id = speaking_attempts.line_id
        )
      )
      or (
        speaking_attempts.form_id is not null
        and exists (
          select 1 from public.cards k
           where k.user_id = (select auth.uid()) and k.form_id = speaking_attempts.form_id
        )
      )
    )
  );

-- The only change a learner can make: clear a transcript.
create policy "learners clear their own transcripts"
  on public.speaking_attempts
  for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and transcript = '');

create policy "learners read their own kept recordings"
  on public.kept_recordings
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- A recording is kept only while the learner's newest
-- voice_recording_retention consent is a grant, and only for a line they have
-- an attempt on. The unique (user_id, line_id, slot) and the two slot values
-- allow at most two per line.
create policy "learners keep recordings with retention consent"
  on public.kept_recordings
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and coalesce((
      select c.granted from public.consents c
       where c.user_id = (select auth.uid()) and c.kind = 'voice_recording_retention'
       order by c.created_at desc
       limit 1
    ), false)
    and exists (
      select 1 from public.speaking_attempts a
       where a.user_id = (select auth.uid()) and a.line_id = kept_recordings.line_id
    )
  );

create policy "learners delete their own kept recordings"
  on public.kept_recordings
  for delete
  to authenticated
  using (user_id = (select auth.uid()));

-- What withdrawing consent does, in the same transaction ---------------------------
-- A withdrawn voice_recording_retention row deletes every kept recording of
-- that learner. A withdrawn voice_processing row also deletes them and clears
-- every stored transcript. Feedback classes stay: they hold no voice and are
-- learning progress. Runs with the learner's own rights, so it reaches only
-- their own rows.

create function private.apply_voice_withdrawal()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  delete from public.kept_recordings k where k.user_id = new.user_id;
  if new.kind = 'voice_processing' then
    update public.speaking_attempts a
       set transcript = ''
     where a.user_id = new.user_id and a.transcript <> '';
  end if;
  return null;
end;
$$;

create trigger voice_withdrawal after insert on public.consents
  for each row when (not new.granted) execute function private.apply_voice_withdrawal();

revoke all on function private.apply_voice_withdrawal() from public, anon, authenticated, service_role;

-- Keeping a recording -------------------------------------------------------------
-- Stores the WAV as the line's first try if none exists, otherwise replaces
-- the latest, in one transaction. Runs with the learner's own rights, so the
-- rules above decide.

create function public.keep_recording(line_id bigint, audio_base64 text)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  wav bytea := decode(keep_recording.audio_base64, 'base64');
  kept uuid;
begin
  insert into public.kept_recordings (line_id, slot, audio)
  values (keep_recording.line_id, 'first', wav)
  on conflict on constraint kept_recordings_one_per_slot do nothing
  returning id into kept;
  if kept is null then
    delete from public.kept_recordings k
     where k.user_id = (select auth.uid())
       and k.line_id = keep_recording.line_id
       and k.slot = 'latest';
    insert into public.kept_recordings (line_id, slot, audio)
    values (keep_recording.line_id, 'latest', wav)
    returning id into kept;
  end if;
  return kept;
end;
$$;

comment on function public.keep_recording(bigint, text) is
  'Job 10-speaking-feedback: keeps a WAV as the line''s first try, or replaces its latest, as the learner.';

revoke all on function public.keep_recording(bigint, text) from public, anon, authenticated, service_role;
grant execute on function public.keep_recording(bigint, text) to authenticated;

-- Ninety days, then gone ----------------------------------------------------------
-- Deletes kept recordings and clears transcripts older than 90 days. Run
-- daily by pg_cron as the database owner, never by an API role.

create function private.forget_old_voice_data()
returns void
language plpgsql
set search_path = ''
as $$
begin
  delete from public.kept_recordings k where k.created_at < now() - interval '90 days';
  update public.speaking_attempts a
     set transcript = ''
   where a.transcript <> '' and a.created_at < now() - interval '90 days';
end;
$$;

revoke all on function private.forget_old_voice_data() from public, anon, authenticated, service_role;

select cron.schedule('forget-old-voice-data', '17 3 * * *', 'select private.forget_old_voice_data()');
