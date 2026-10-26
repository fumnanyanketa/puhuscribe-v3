-- Job 11-accounts: accounts and personal data.
-- Spec: factory/jobs/11-accounts/spec.md, "Done when" 3, 19, 21, 23, 24 and 25.
-- Plain English description: docs/data-model.md.
--
-- Three functions a learner may call, all with no argument, so nobody can
-- name another learner:
--   public.my_account()        the caller's own account, only while the sign
--                              in is live (security definer, reads auth.users)
--   public.export_my_data()    every row of the caller's in every user table
--                              (security invoker, so the read rules apply)
--   public.delete_my_account() deletes the caller's own auth.users row, only
--                              from a live sign in (security definer); the
--                              cascades of jobs 3 and 8 remove every user
--                              table row with it
-- And the daily clean up of accounts nobody uses, run by pg_cron:
--   private.delete_inactive_guests()  guests after 90 days and email
--                              accounts after 24 months with no learning
--                              activity (owner's decisions of 20 and 21
--                              October 2026)
--   private.user_has_stored_files(uuid)  false today; a job that stores files
--                              outside the database replaces it, so the clean
--                              up skips (and never orphans) those files.
--
-- Rule for every later job: a new user table goes into export_my_data() and
-- src/privacy/data-inventory.ts in the same job. The pgTAP test in
-- supabase/tests/database/accounts.test.sql compares the export with the
-- database catalogue and fails when a table is missing.

-- A live sign in ---------------------------------------------------------------

-- True when the token's sign in (its session_id) still exists in auth.sessions
-- for the token's user and has not run out. Signing out or deleting the
-- account removes that row, while the access token itself stays valid until it
-- expires, so this is what tells a signed out token from a live one.
create function private.sign_in_is_live()
returns boolean
language sql
stable
set search_path = ''
as $$
  select exists (
    select 1
      from auth.sessions s
     where s.id = nullif(auth.jwt() ->> 'session_id', '')::uuid
       and s.user_id = (select auth.uid())
       and (s.not_after is null or s.not_after > now())
  );
$$;

comment on function private.sign_in_is_live() is
  'Job 11-accounts: true when the caller''s token belongs to a sign in that still exists in auth.sessions.';

-- The caller's own account -------------------------------------------------------

-- No row when there is no user id in the token or the sign in is no longer live.
create function public.my_account()
returns table (
  id uuid,
  email text,
  is_anonymous boolean,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  email_confirmed_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select u.id, u.email::text, u.is_anonymous, u.created_at, u.last_sign_in_at, u.email_confirmed_at
    from auth.users u
   where u.id = (select auth.uid())
     and private.sign_in_is_live();
$$;

comment on function public.my_account() is
  'Job 11-accounts: the caller''s own account (id, email, guest or not, times), only while the sign in is live.';

-- Everything the caller has in the user tables -----------------------------------

-- One list of rows per user table, each row with every column (to_jsonb). It
-- runs as the learner, so the read rules of each table decide what is seen,
-- and it also names the learner's own id in every query.
create function public.export_my_data()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object('tables', jsonb_build_object(
    'sessions', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.started_at, t.id)
        from public.sessions t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'cards', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.form_id)
        from public.cards t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'review_logs', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.review_time, t.id)
        from public.review_logs t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'consents', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.consents t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'usage_events', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.usage_events t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'speaking_attempts', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.speaking_attempts t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'speech_checks', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.speech_checks t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'kept_recordings', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.kept_recordings t where t.user_id = (select auth.uid())), '[]'::jsonb)
  ));
$$;

comment on function public.export_my_data() is
  'Job 11-accounts: every row of the caller''s in every user table, read as the caller. A new user table must be added here in the same job.';

-- Deleting the caller's own account ------------------------------------------------

-- Refuses, writing nothing, when the token has no user id or its sign in is no
-- longer live (signed out, or the account was already deleted).
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if me is null or not private.sign_in_is_live() then
    raise exception 'there is no live sign in for this token' using errcode = '28000';
  end if;
  delete from auth.users u where u.id = me;
end;
$$;

comment on function public.delete_my_account() is
  'Job 11-accounts: deletes the caller''s own account and, through the cascades, every user table row, only from a live sign in.';

-- Files stored outside the database -------------------------------------------------

-- False today: no job stores a learner's files outside the database. A job that
-- does replaces this function, so the daily clean up skips those learners
-- instead of deleting the account and leaving the files behind (their files
-- are deleted by the Worker's file stores, worker/personal-data/file-stores.ts,
-- when the learner deletes the account).
create function private.user_has_stored_files(user_id uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  select false;
$$;

comment on function private.user_has_stored_files(uuid) is
  'Job 11-accounts: true when the user has files stored outside the database. False until a job stores such files.';

-- The daily clean up ---------------------------------------------------------------

-- Newest activity = the latest of the account's creation, its sessions' start
-- and end and its reviews. Guests go after 90 days without activity, email
-- accounts after 24 months. Returns how many accounts were deleted.
create function private.delete_inactive_guests()
returns integer
language plpgsql
set search_path = ''
as $$
declare
  deleted integer;
begin
  with activity as (
    select u.id,
           u.is_anonymous,
           greatest(
             u.created_at,
             (select max(greatest(s.started_at, s.ended_at)) from public.sessions s where s.user_id = u.id),
             (select max(r.review_time) from public.review_logs r where r.user_id = u.id)
           ) as last_active
      from auth.users u
  ),
  gone as (
    delete from auth.users u
     using activity a
     where u.id = a.id
       and (
         (a.is_anonymous and a.last_active < now() - interval '90 days')
         or (not a.is_anonymous and a.last_active < now() - interval '24 months')
       )
       and not private.user_has_stored_files(u.id)
    returning 1
  )
  select count(*) into deleted from gone;
  return deleted;
end;
$$;

comment on function private.delete_inactive_guests() is
  'Job 11-accounts: deletes guests with no learning activity for 90 days and email accounts with none for 24 months, skipping users with stored files. Run daily by pg_cron.';

-- Permissions -------------------------------------------------------------------------

revoke all on function private.sign_in_is_live() from public, anon, authenticated, service_role;
revoke all on function private.user_has_stored_files(uuid) from public, anon, authenticated, service_role;
revoke all on function private.delete_inactive_guests() from public, anon, authenticated, service_role;

revoke all on function public.my_account() from public, anon, authenticated, service_role;
revoke all on function public.export_my_data() from public, anon, authenticated, service_role;
revoke all on function public.delete_my_account() from public, anon, authenticated, service_role;
grant execute on function public.my_account() to authenticated;
grant execute on function public.export_my_data() to authenticated;
grant execute on function public.delete_my_account() to authenticated;

-- Supabase Cron runs the clean up once a day ---------------------------------------------

create extension if not exists pg_cron with schema pg_catalog;

-- Scheduling under the same name again replaces the job, so this line is safe
-- to run twice. 03:17 UTC, a quiet hour in Finland.
select cron.schedule('delete-inactive-accounts', '17 3 * * *', 'select private.delete_inactive_guests()');
