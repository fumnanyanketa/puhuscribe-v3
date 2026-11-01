-- Job 18-save-progress: when the finish screen may ask a guest to add an email.
-- Spec: factory/jobs/18-save-progress/spec.md, "Done when" 4 and 8.
-- Plain English description: docs/data-model.md.
--
-- public.save_progress_note(session id) answers one word:
--   'first'    the session is the guest's first finished session
--   'reminder' the session is the guest's third finished dialogue session
--   'none'     anything else
--
-- It reads only what already exists (the learner's sessions, their
-- first_session_completed event and a claim in their own token) and writes
-- nothing. Nothing is stored about the note: not that it was shown, not that
-- the learner pressed Not now. It runs with the learner's own rights (security
-- invoker), and it is stable, so Postgres refuses any write inside it. It takes
-- no learner id: it looks only at the caller's own rows.

create function public.save_progress_note(p_session_id uuid)
returns text
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  first_session uuid;
  place bigint;
begin
  -- A guest only. The token's own claim says so (PostgREST has already
  -- checked the token's signature). A missing claim counts as not a guest, so
  -- an email account never gets the note.
  if coalesce(auth.jwt() ->> 'is_anonymous', 'false') <> 'true' then
    return 'none';
  end if;
  if caller is null or p_session_id is null then
    return 'none';
  end if;

  -- The learner's first finished session is the one on their
  -- first_session_completed event (job 8). There is at most one per learner.
  select e.session_id into first_session
    from public.usage_events e
   where e.user_id = caller
     and e.name = 'first_session_completed';

  -- 'first': that very session, which must be the caller's own dialogue
  -- session and must have ended.
  if first_session = p_session_id and exists (
    select 1
      from public.sessions s
     where s.id = p_session_id
       and s.user_id = caller
       and s.dialogue_id is not null
       and s.ended_at is not null
  ) then
    return 'first';
  end if;

  -- 'reminder': the caller's third finished dialogue session, counted by end
  -- time with the session id as tie breaker. Review only sessions have no
  -- dialogue and are not counted.
  select r.finished_number into place
    from (
      select s.id, row_number() over (order by s.ended_at, s.id) as finished_number
        from public.sessions s
       where s.user_id = caller
         and s.dialogue_id is not null
         and s.ended_at is not null
    ) r
   where r.id = p_session_id;
  if place = 3 then
    return 'reminder';
  end if;

  return 'none';
end;
$$;

comment on function public.save_progress_note(uuid) is
  'Job 18-save-progress: first, reminder or none, for the finish screen''s note asking a guest to add an email. Reads the caller''s own sessions, event and token claim. Writes nothing.';

-- Postgres lets everyone run a new function, so the right to run it is taken
-- away from every role first, then given to signed in learners only.
revoke all on function public.save_progress_note(uuid) from public, anon, authenticated, service_role;
grant execute on function public.save_progress_note(uuid) to authenticated;
