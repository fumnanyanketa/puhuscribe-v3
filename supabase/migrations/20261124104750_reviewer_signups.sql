-- Fast route reviewers: native Finnish speakers sign up at meetaleksi.com/reviewers
-- to help check the Finnish in Aleksi. Spec: factory/jobs/reviewers/spec.md,
-- "Done when" 2 to 5. Plain English description: docs/data-model.md.
--
-- What is new:
--   private.reviewer_signups                  one row per sign up: name, email, optional thank-you name, time
--   public.sign_up_reviewer(text, text, text) the one door that adds a row (anon only, from the Worker)
--   public.owner_reviewer_signups()           every sign up, newest first, for the owner only
--   public.owner_delete_reviewer_signup(uuid) deletes one sign up, for the owner only
--
-- The people who sign up have no account, so no row links to auth.users and
-- nothing here goes into public.export_my_data(). Rows are kept until the owner
-- deletes them (owner's call of 24 November 2026); there is no automatic deletion.
--
-- The table is in the private schema, which the API roles cannot reach, and
-- every API role's rights on it are revoked in writing. The browser roles (anon,
-- authenticated) get nothing on the table. The Worker holds only the publishable
-- key, so it writes as anon, through sign_up_reviewer, which checks every field
-- and the daily limits before it adds a row. The owner reads and deletes through
-- two functions that answer only an account on private.owners with a live sign in.
-- Postgres lets everyone (PUBLIC) run a new function; each one below has that
-- revoked in writing too.

-- The table ------------------------------------------------------------------------------

create table private.reviewer_signups (
  id uuid primary key default gen_random_uuid(),
  name text not null
    check (char_length(name) between 1 and 100 and name = btrim(name) and name !~ '[[:cntrl:]]'),
  email text not null
    check (char_length(email) <= 254 and email = lower(email)
           and email ~ '^[^[:space:]@[:cntrl:]]+@[^[:space:]@[:cntrl:]]+\.[^[:space:]@[:cntrl:].]+$'),
  thanks_name text
    check (thanks_name is null
           or (char_length(thanks_name) between 1 and 100 and thanks_name = btrim(thanks_name)
               and thanks_name !~ '[[:cntrl:]]')),
  created_at timestamptz not null default now()
);

comment on table private.reviewer_signups is
  'Fast route reviewers: people with no account who offered to check the Finnish. Kept until the owner deletes them.';

-- The owner's list is read newest first, and the daily limits count by day and by email.
create index reviewer_signups_created_at_idx on private.reviewer_signups (created_at);
create index reviewer_signups_email_created_at_idx on private.reviewer_signups (email, created_at);

revoke all on table private.reviewer_signups from public, anon, authenticated, service_role;
alter table private.reviewer_signups enable row level security;
-- No rule is made: no API role may read or write the rows directly.

-- The one door in -------------------------------------------------------------------------
-- Checks every field the way the Worker does (src/lib/reviewer-signup.ts) and
-- refuses, writing nothing, any that is wrong. Returns true when the row is
-- added, false when a daily limit is reached: at most 3 sign ups from one email
-- address and 200 in all on one Helsinki day, as the database clock says. The
-- counting waits for any other sign up being stored (an advisory lock held to
-- the end of the transaction), so parallel calls cannot beat the limits.

create function public.sign_up_reviewer(p_name text, p_email text, p_thanks_name text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text := btrim(p_name);
  v_email text := lower(btrim(p_email));
  v_thanks text := nullif(btrim(p_thanks_name), '');
  v_day_start timestamptz :=
    ((now() at time zone 'Europe/Helsinki')::date::timestamp at time zone 'Europe/Helsinki');
begin
  if v_name is null or char_length(v_name) not between 1 and 100 or v_name ~ '[[:cntrl:]]' then
    raise exception 'bad name' using errcode = '22023';
  end if;
  if v_email is null or char_length(v_email) > 254
     or v_email !~ '^[^[:space:]@[:cntrl:]]+@[^[:space:]@[:cntrl:]]+\.[^[:space:]@[:cntrl:].]+$' then
    raise exception 'bad email' using errcode = '22023';
  end if;
  if v_thanks is not null and (char_length(v_thanks) > 100 or v_thanks ~ '[[:cntrl:]]') then
    raise exception 'bad thank-you name' using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('aleksi.sign_up_reviewer', 0));
  if (select count(*) from private.reviewer_signups r where r.created_at >= v_day_start) >= 200 then
    return false;
  end if;
  if (select count(*) from private.reviewer_signups r
       where r.email = v_email and r.created_at >= v_day_start) >= 3 then
    return false;
  end if;
  insert into private.reviewer_signups (name, email, thanks_name) values (v_name, v_email, v_thanks);
  return true;
end;
$$;

comment on function public.sign_up_reviewer(text, text, text) is
  'Fast route reviewers: adds one reviewer sign up after checking every field, at most 3 per email and 200 in all a Helsinki day. Called by the Worker as anon, after its Turnstile check.';

revoke all on function public.sign_up_reviewer(text, text, text) from public, anon, authenticated, service_role;
grant execute on function public.sign_up_reviewer(text, text, text) to anon;

-- The owner's two functions ---------------------------------------------------------------
-- Both answer only an account on the owner list whose sign in is still live
-- (the same two conditions as public.owner_dashboard()); anyone else gets null.

create function public.owner_reviewer_signups()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  if not private.sign_in_is_live() then
    return null;
  end if;
  return coalesce(
    (select jsonb_agg(jsonb_build_object(
              'id', r.id,
              'name', r.name,
              'email', r.email,
              'thanks_name', r.thanks_name,
              'created_at', r.created_at)
            order by r.created_at desc, r.id)
       from private.reviewer_signups r),
    '[]'::jsonb);
end;
$$;

comment on function public.owner_reviewer_signups() is
  'Fast route reviewers: every reviewer sign up, newest first, for the owner with a live sign in; null for anyone else.';

revoke all on function public.owner_reviewer_signups() from public, anon, authenticated, service_role;
grant execute on function public.owner_reviewer_signups() to authenticated;

create function public.owner_delete_reviewer_signup(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count bigint;
begin
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  if not private.sign_in_is_live() then
    return null;
  end if;
  delete from private.reviewer_signups r where r.id = p_id;
  get diagnostics v_count = row_count;
  return v_count > 0;
end;
$$;

comment on function public.owner_delete_reviewer_signup(uuid) is
  'Fast route reviewers: deletes one reviewer sign up for the owner with a live sign in. True when deleted, false when there was none, null for anyone else.';

revoke all on function public.owner_delete_reviewer_signup(uuid) from public, anon, authenticated, service_role;
grant execute on function public.owner_delete_reviewer_signup(uuid) to authenticated;
