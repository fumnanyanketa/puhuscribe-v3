-- Job 8-first-session: the usage event table and the end of a session.
-- Spec: factory/jobs/8-first-session/spec.md, "Done when" 15, 16 and 17.
-- Plain English description: docs/data-model.md.
--
-- When a learner reaches the finish screen, the Worker calls
-- public.complete_session(session_id) once, as the learner. In one transaction
-- it ends the session, adds a new review card for every approved form the
-- dialogue's lines link to, and records one first_session_completed event.
-- It runs with the learner's own rights (security invoker), so every existing
-- access rule still applies: it can only end the learner's own session, only
-- see approved content, and only make cards the card rule allows.

-- Enum -------------------------------------------------------------------------

-- One value today. Later jobs add more kinds of event (job 14).
create type public.usage_event_name as enum ('first_session_completed');

-- Table ------------------------------------------------------------------------

-- One row per event. Nothing else about the learner or their device is kept:
-- no IP address, browser, device or free text.
create table public.usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name public.usage_event_name not null,
  session_id uuid not null references public.sessions (id) on delete cascade,
  created_at timestamptz not null default now()
);

comment on table public.usage_events is
  'Learner data (job 8-first-session): one row per product event, such as the first finished session. No device or address data.';

-- At most one first_session_completed per learner.
create unique index usage_events_one_first_session_idx
  on public.usage_events (user_id)
  where name = 'first_session_completed';
-- For the link that deletes a session's events with it.
create index usage_events_session_id_idx on public.usage_events (session_id);

-- Permissions -------------------------------------------------------------------
-- Remove everything, then a learner may read their own events and add one,
-- writing only user_id, name and session_id. The id and the time are set by
-- the database. Nobody changes or deletes an event: rows go with the user.

revoke all on table public.usage_events from anon, authenticated, service_role;
grant select on table public.usage_events to authenticated;
grant insert (user_id, name, session_id) on table public.usage_events to authenticated;

alter table public.usage_events enable row level security;

create policy "learners read their own events"
  on public.usage_events
  for select
  to authenticated
  using (user_id = (select auth.uid()));

-- An event carries the learner's own id and their own session, and only a
-- session that reached at least Understand it and has ended.
create policy "learners add events for their own finished sessions"
  on public.usage_events
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.sessions s
      where s.id = usage_events.session_id
        and s.user_id = (select auth.uid())
        and s.step_reached >= 'understand'
        and s.ended_at is not null
    )
  );

-- The end of a session ------------------------------------------------------------

-- Refuses (and writes nothing) when the session is not the learner's own, has
-- no dialogue, or has not reached Understand it. Calling it again changes
-- nothing: the end time stays, no second card, no second event.
create function public.complete_session(session_id uuid)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  found_session public.sessions%rowtype;
begin
  select s.* into found_session
    from public.sessions s
   where s.id = complete_session.session_id
     and s.user_id = (select auth.uid());
  if not found then
    raise exception 'no such session for this learner' using errcode = 'P0002';
  end if;
  if found_session.dialogue_id is null
     or found_session.step_reached is null
     or found_session.step_reached < 'understand' then
    raise exception 'this session has not reached Understand it' using errcode = '22023';
  end if;

  if found_session.ended_at is null then
    update public.sessions s set ended_at = now() where s.id = found_session.id;
  end if;

  -- The read rules decide what is seen here: only approved lines in an
  -- approved dialogue and unit, their words, and approved forms.
  insert into public.cards (user_id, form_id)
  select distinct found_session.user_id, f.id
    from public.dialogue_lines l
    join public.tokens t on t.line_id = l.id
    join public.forms f on f.id = t.form_id
   where l.dialogue_id = found_session.dialogue_id
  on conflict (user_id, form_id) do nothing;

  insert into public.usage_events (user_id, name, session_id)
  values (found_session.user_id, 'first_session_completed', found_session.id)
  on conflict do nothing;
end;
$$;

comment on function public.complete_session(uuid) is
  'Job 8-first-session: ends the learner''s own session and adds its cards and the first_session_completed event, in one transaction, as the learner.';

revoke all on function public.complete_session(uuid) from public, anon, authenticated, service_role;
grant execute on function public.complete_session(uuid) to authenticated;
