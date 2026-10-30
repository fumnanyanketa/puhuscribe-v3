-- Job 14-analytics: the visit count, feedback, crash reports, the owner list
-- and the one function that works out the owner page's numbers.
-- Spec: factory/jobs/14-analytics/spec.md, "Done when" 5, 6, 8 to 11, 16 and
-- 21 to 23 and 26. Plain English description: docs/data-model.md.
--
-- What is new:
--   private.visit_tallies       one number per Helsinki day and country, nothing else
--   public.count_visit(text)    the one door that adds to it (anon only, from the Worker)
--   public.feedback             a learner's short messages, at most 5 a Helsinki day
--   private.owners              which accounts may open the owner page
--   public.my_owner_rows()      the caller's own owner row, for the data download
--   private.crash_reports       error reports with no user, address or user agent
--   public.report_crash(...)    the one door that adds one (anon only, from the Worker)
--   public.owner_dashboard()    every owner page number, for the owner only
--   public.export_my_data()     now also lists feedback and the owner row
--
-- Postgres lets everyone (PUBLIC) run a new function. Every function below has
-- that revoked in writing, and each API role gets only what the spec allows.

create extension if not exists pg_cron with schema pg_catalog;

-- The visit count -------------------------------------------------------------------
-- A day, a country and a number. No address, time of day, user agent or user.

create table private.visit_tallies (
  day date not null,
  -- Two capital letters, or T1, Cloudflare's code for the Tor network.
  country text not null check (country ~ '^([A-Z]{2}|T1)$'),
  visits bigint not null default 0 check (visits >= 0),
  primary key (day, country)
);

comment on table private.visit_tallies is
  'Job 14-analytics: visits per Helsinki day and country. Exactly three columns: day, country, visits. No personal data.';

revoke all on table private.visit_tallies from public, anon, authenticated, service_role;
alter table private.visit_tallies enable row level security;

-- Adds one visit for a country, on today's Helsinki day as the database clock
-- says (never the caller). Two calls at the same moment both count: the second
-- waits for the first one's row and then adds to it.
create function public.count_visit(p_country text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_country is null or p_country !~ '^([A-Z]{2}|T1)$' then
    raise exception 'a country is two capital letters (or T1, the Tor network)' using errcode = '22023';
  end if;
  insert into private.visit_tallies as t (day, country, visits)
  values ((now() at time zone 'Europe/Helsinki')::date, p_country, 1)
  on conflict (day, country) do update set visits = t.visits + 1;
end;
$$;

comment on function public.count_visit(text) is
  'Job 14-analytics: adds one visit for a two letter country (or T1, the Tor network) on today''s Helsinki day. Called by the Worker as anon.';

revoke all on function public.count_visit(text) from public, anon, authenticated, service_role;
grant execute on function public.count_visit(text) to anon;

-- Feedback ----------------------------------------------------------------------------

create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  screen text not null check (screen in ('front_door', 'account', 'finish')),
  message text not null check (char_length(message) between 1 and 1000 and message ~ '[^[:space:]]')
);

comment on table public.feedback is
  'Learner data (job 14-analytics): a short message from the learner, the screen it came from and when. Deleted with the account.';

create index feedback_user_id_created_at_idx on public.feedback (user_id, created_at);
create index feedback_created_at_idx on public.feedback (created_at);

revoke all on table public.feedback from anon, authenticated, service_role;
grant select on table public.feedback to authenticated;
grant insert (user_id, screen, message) on table public.feedback to authenticated;

alter table public.feedback enable row level security;

create policy "learners read their own feedback"
  on public.feedback
  for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "learners send their own feedback"
  on public.feedback
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));

-- At most 5 messages per learner per Helsinki day. The check waits for any
-- other message of the same learner that is being saved (an advisory lock
-- held to the end of the transaction), then counts, so parallel requests
-- cannot beat the limit. Runs with the learner's own rights.
create function private.limit_feedback_per_day()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  perform pg_advisory_xact_lock(hashtextextended('puhuscribe.feedback:' || new.user_id::text, 14));
  if (
    select count(*)
      from public.feedback f
     where f.user_id = new.user_id
       and (f.created_at at time zone 'Europe/Helsinki')::date = (now() at time zone 'Europe/Helsinki')::date
  ) >= 5 then
    raise exception 'feedback_daily_limit' using errcode = 'P0001', hint = 'At most 5 messages a day.';
  end if;
  return new;
end;
$$;

revoke all on function private.limit_feedback_per_day() from public, anon, authenticated, service_role;

create trigger feedback_daily_limit before insert on public.feedback
  for each row execute function private.limit_feedback_per_day();

-- The owner list ------------------------------------------------------------------------
-- Created empty. The owner adds their own account with one SQL line in the
-- Supabase SQL editor (README, "Owner page setup"). No API role can write it.

create table private.owners (
  user_id uuid primary key references auth.users (id) on delete cascade,
  added_at timestamptz not null default now()
);

comment on table private.owners is
  'Job 14-analytics: the accounts that may open the owner page. Written only in the SQL editor.';

revoke all on table private.owners from public, anon, authenticated, service_role;
alter table private.owners enable row level security;

-- The caller's own owner row, for the data download. The private schema stays
-- closed to the API roles (job 3), so the download reads it through this
-- function, which can only ever return the caller's own row.
create function public.my_owner_rows()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(to_jsonb(o) order by o.added_at), '[]'::jsonb)
    from private.owners o
   where o.user_id = (select auth.uid());
$$;

comment on function public.my_owner_rows() is
  'Job 14-analytics: the caller''s own row of private.owners, as a list (empty for every learner).';

revoke all on function public.my_owner_rows() from public, anon, authenticated, service_role;
grant execute on function public.my_owner_rows() to authenticated;

-- Crash reports ---------------------------------------------------------------------------
-- What broke, where and in which browser. No user, address, user agent,
-- cookie or anything the learner typed. Deleted after 30 days.

create table private.crash_reports (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  source text not null check (source in ('browser', 'worker')),
  group_key text not null check (group_key ~ '^[0-9a-f]{32}$'),
  error_name text not null check (error_name ~ '^[A-Za-z_$][A-Za-z0-9_$.]{0,79}$'),
  message text not null check (char_length(message) <= 300),
  frames jsonb not null check (jsonb_typeof(frames) = 'array' and jsonb_array_length(frames) <= 10),
  path text not null check (char_length(path) <= 200 and path ~ '^/'),
  app_version text not null check (app_version ~ '^([0-9a-f]{7,40}|local)$'),
  browser text not null check (browser ~ '^[A-Za-z0-9 .,()/-]{1,40}$')
);

comment on table private.crash_reports is
  'Job 14-analytics: error reports from the browser and the Worker. No column for a user, address or user agent. Deleted after 30 days.';

create index crash_reports_created_at_idx on private.crash_reports (created_at);
create index crash_reports_group_key_created_at_idx on private.crash_reports (group_key, created_at);

revoke all on table private.crash_reports from public, anon, authenticated, service_role;
alter table private.crash_reports enable row level security;

-- True when a text holds something that could identify a person or carry a
-- secret: an email address, a long digit run, an id, a token shaped string, a
-- web address with a query string or fragment, or a control character. The
-- Worker removes these before it calls report_crash; a caller that skips the
-- Worker is refused here.
create function private.crash_text_is_unsafe(value text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select value ~ '[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+'
      or value ~ '[0-9]{6,}'
      or value ~* '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
      or value ~ '[A-Za-z0-9_-]{32,}'
      or value ~ 'eyJ[A-Za-z0-9_-]{8,}'
      or value ~* 'https?://[^[:space:]]*[?#]'
      or value ~ '[[:cntrl:]]';
$$;

revoke all on function private.crash_text_is_unsafe(text) from public, anon, authenticated, service_role;

-- True when frames is a list of at most 10 frames, each exactly
-- {file, line, column, fn} with safe values.
create function private.crash_frames_are_valid(frames jsonb)
returns boolean
language plpgsql
immutable
set search_path = ''
as $$
declare
  f jsonb;
begin
  if jsonb_typeof(frames) is distinct from 'array' then
    return false;
  end if;
  if jsonb_array_length(frames) > 10 then
    return false;
  end if;
  for f in select x from jsonb_array_elements(frames) as x loop
    if jsonb_typeof(f) <> 'object' then
      return false;
    end if;
    if (select array_agg(k collate "C" order by k collate "C") from jsonb_object_keys(f) as k)
       is distinct from array['column', 'file', 'fn', 'line'] then
      return false;
    end if;
    if jsonb_typeof(f -> 'file') <> 'string'
       or (f ->> 'file') !~ '^[A-Za-z0-9_./-]{1,120}$'
       or (f ->> 'file') ~ '(\.\.|//)'
       or jsonb_typeof(f -> 'line') <> 'number'
       or (f ->> 'line') !~ '^[0-9]{1,7}$'
       or jsonb_typeof(f -> 'column') <> 'number'
       or (f ->> 'column') !~ '^[0-9]{1,7}$'
       or jsonb_typeof(f -> 'fn') <> 'string'
       or (f ->> 'fn') !~ '^[A-Za-z0-9_$.<> -]{0,100}$'
       or private.crash_text_is_unsafe(f ->> 'fn') then
      return false;
    end if;
  end loop;
  return true;
end;
$$;

revoke all on function private.crash_frames_are_valid(jsonb) from public, anon, authenticated, service_role;

-- Stores one report, or drops it when 300 were stored in the last hour, or 30
-- of the same group. The counting waits for any other report being stored (an
-- advisory lock held to the end of the transaction), so parallel calls cannot
-- beat the caps. Returns true when stored, false when dropped. Refuses
-- (writing nothing) any field with the wrong length or shape. The group is
-- the source, the error name and the first frame.
create function public.report_crash(
  p_source text,
  p_name text,
  p_message text,
  p_frames jsonb,
  p_path text,
  p_app_version text,
  p_browser text
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  first_frame jsonb;
  key text;
begin
  if p_source is null or p_source not in ('browser', 'worker') then
    raise exception 'bad source' using errcode = '22023';
  end if;
  if p_name is null or p_name !~ '^[A-Za-z_$][A-Za-z0-9_$.]{0,79}$' then
    raise exception 'bad error name' using errcode = '22023';
  end if;
  if p_message is null or char_length(p_message) > 300 or private.crash_text_is_unsafe(p_message) then
    raise exception 'bad message' using errcode = '22023';
  end if;
  if p_frames is null or not private.crash_frames_are_valid(p_frames) then
    raise exception 'bad frames' using errcode = '22023';
  end if;
  if p_path is null or char_length(p_path) > 200
     or p_path !~ '^/([A-Za-z0-9_-]+|:id)?(/([A-Za-z0-9_-]+|:id))*$'
     or private.crash_text_is_unsafe(p_path) then
    raise exception 'bad path' using errcode = '22023';
  end if;
  if p_app_version is null or p_app_version !~ '^([0-9a-f]{7,40}|local)$' then
    raise exception 'bad app version' using errcode = '22023';
  end if;
  if p_browser is null or p_browser !~ '^[A-Za-z0-9 .,()/-]{1,40}$' then
    raise exception 'bad browser label' using errcode = '22023';
  end if;

  first_frame := p_frames -> 0;
  key := md5(concat_ws('|', p_source, p_name,
                       first_frame ->> 'file', first_frame ->> 'line', first_frame ->> 'column', first_frame ->> 'fn'));

  perform pg_advisory_xact_lock(hashtextextended('puhuscribe.report_crash', 14));
  if (select count(*) from private.crash_reports c where c.created_at > now() - interval '1 hour') >= 300 then
    return false;
  end if;
  if (select count(*) from private.crash_reports c
       where c.group_key = key and c.created_at > now() - interval '1 hour') >= 30 then
    return false;
  end if;
  insert into private.crash_reports (source, group_key, error_name, message, frames, path, app_version, browser)
  values (p_source, key, p_name, p_message, p_frames, p_path, p_app_version, p_browser);
  return true;
end;
$$;

comment on function public.report_crash(text, text, text, jsonb, text, text, text) is
  'Job 14-analytics: stores one crash report after checking every field, at most 300 an hour and 30 per group. Called by the Worker as anon.';

revoke all on function public.report_crash(text, text, text, jsonb, text, text, text)
  from public, anon, authenticated, service_role;
grant execute on function public.report_crash(text, text, text, jsonb, text, text, text) to anon;

-- Thirty days, then gone. Run daily by pg_cron as the database owner.
create function private.forget_old_crash_reports()
returns void
language plpgsql
set search_path = ''
as $$
begin
  delete from private.crash_reports c where c.created_at < now() - interval '30 days';
end;
$$;

revoke all on function private.forget_old_crash_reports() from public, anon, authenticated, service_role;

select cron.schedule('forget-old-crash-reports', '17 3 * * *', 'select private.forget_old_crash_reports()');

-- The owner page's numbers --------------------------------------------------------------
-- Everything the owner page shows, as one JSON object. Returns null (and
-- writes nothing) unless the caller is on the owner list and the token's sign
-- in is still live. Accounts on the owner list are left out of every learner
-- number. Definitions: docs/data-model.md, "The owner page numbers".

create function public.owner_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_today date := (now() at time zone 'Europe/Helsinki')::date;
  v_first date := (now() at time zone 'Europe/Helsinki')::date - 29;
  v_start timestamptz := (((now() at time zone 'Europe/Helsinki')::date - 29)::timestamp at time zone 'Europe/Helsinki');
  v_active bigint;
  v_cohort bigint;
  v_retained bigint;
  v_minutes numeric;
  v_used bigint;
  v_left_out bigint;
  v_spoke bigint;
  v_cost numeric := 0;
  v_part numeric;
  t record;
begin
  -- Condition 1: the caller is on the owner list.
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  -- Condition 2: the token's sign in is still live (job 11).
  if not private.sign_in_is_live() then
    return null;
  end if;

  -- Active learners: a session started in the window.
  select count(distinct s.user_id) into v_active
    from public.sessions s
   where s.started_at >= v_start
     and not exists (select 1 from private.owners o where o.user_id = s.user_id);

  -- Day 7 retention: the first ever session on day D, with D + 7 between the
  -- window's first day and yesterday; retained when a session started on D + 7.
  with learner_days as (
    select s.user_id, (s.started_at at time zone 'Europe/Helsinki')::date as d
      from public.sessions s
     where not exists (select 1 from private.owners o where o.user_id = s.user_id)
  ),
  firsts as (
    select l.user_id, min(l.d) as d0 from learner_days l group by l.user_id
  ),
  cohort as (
    select f.user_id, f.d0 from firsts f where f.d0 + 7 between v_first and v_today - 1
  )
  select count(*),
         count(*) filter (where exists (select 1 from learner_days l where l.user_id = c.user_id and l.d = c.d0 + 7))
    into v_cohort, v_retained
    from cohort c;

  -- Median session length: sessions started in the window that have an end
  -- and lasted from 0 to 2 hours. The others are counted as left out.
  select round((percentile_cont(0.5) within group (order by extract(epoch from (s.ended_at - s.started_at)))
                  filter (where s.ended_at is not null
                            and s.ended_at >= s.started_at
                            and s.ended_at - s.started_at <= interval '2 hours'))::numeric / 60, 1),
         count(*) filter (where s.ended_at is not null
                            and s.ended_at >= s.started_at
                            and s.ended_at - s.started_at <= interval '2 hours'),
         count(*) filter (where s.ended_at is null
                            or s.ended_at < s.started_at
                            or s.ended_at - s.started_at > interval '2 hours')
    into v_minutes, v_used, v_left_out
    from public.sessions s
   where s.started_at >= v_start
     and not exists (select 1 from private.owners o where o.user_id = s.user_id);

  -- Speak back: active learners with a speaking attempt made in the window.
  select count(*) into v_spoke
    from (select distinct s.user_id
            from public.sessions s
           where s.started_at >= v_start
             and not exists (select 1 from private.owners o where o.user_id = s.user_id)) a
   where exists (select 1 from public.speaking_attempts p
                  where p.user_id = a.user_id and p.created_at >= v_start);

  -- AI and speech cost: every cost_usd column in the project's tables, read
  -- from the catalogue, so a table added later is counted without a change
  -- here (statement 10). Each such table has user_id and created_at.
  for t in
    select n.nspname, c.relname
      from pg_attribute a
      join pg_class c on c.oid = a.attrelid
      join pg_namespace n on n.oid = c.relnamespace
     where a.attname = 'cost_usd' and a.attnum > 0 and not a.attisdropped
       and c.relkind in ('r', 'p') and not c.relispartition
       and n.nspname not in (
         'pg_catalog', 'information_schema', 'auth', 'storage', 'realtime', '_realtime', 'extensions',
         'graphql', 'graphql_public', 'pgsodium', 'pgsodium_masks', 'vault', 'supabase_functions',
         'supabase_migrations', 'net', 'cron', 'pgbouncer', '_analytics', 'pgtle', 'pgmq', '_supavisor',
         'topology', 'tiger', 'tiger_data')
       and n.nspname not like 'pg\_toast%'
       and n.nspname not like 'pg\_temp%'
     order by n.nspname, c.relname
  loop
    execute format(
      'select coalesce(sum(x.cost_usd), 0) from %I.%I x
        where x.created_at >= $1
          and not exists (select 1 from private.owners o where o.user_id = x.user_id)',
      t.nspname, t.relname)
      into v_part
      using v_start;
    v_cost := v_cost + v_part;
  end loop;

  return jsonb_build_object(
    'visits_by_day', (
      select jsonb_agg(jsonb_build_object(
               'day', d.day,
               'visits', coalesce((select sum(v.visits) from private.visit_tallies v where v.day = d.day), 0),
               'fi', coalesce((select sum(v.visits) from private.visit_tallies v
                                where v.day = d.day and v.country = 'FI'), 0))
             order by d.day desc)
        from (select g::date as day
                from generate_series(v_first::timestamp, v_today::timestamp, interval '1 day') as g) d),
    'visits_by_country', (
      select coalesce(jsonb_agg(jsonb_build_object('country', x.country, 'visits', x.visits)
                                order by x.visits desc, x.country), '[]'::jsonb)
        from (select v.country, sum(v.visits) as visits
                from private.visit_tallies v
               where v.day between v_first and v_today
               group by v.country
              having sum(v.visits) > 0) x),
    'active_learners', v_active,
    'day7_retention', jsonb_build_object(
      'retained', v_retained,
      'cohort', v_cohort,
      'percent', case when v_cohort > 0 then round(100.0 * v_retained / v_cohort) end),
    'median_session_minutes', jsonb_build_object(
      'minutes', v_minutes,
      'used', v_used,
      'left_out', v_left_out),
    'speak_back', jsonb_build_object(
      'count', v_spoke,
      'base', v_active,
      'percent', case when v_active > 0 then round(100.0 * v_spoke / v_active) end),
    'ai_cost_usd', jsonb_build_object(
      'total', v_cost,
      'per_active_learner', case when v_active > 0 then round(v_cost / v_active, 8) end),
    'feedback', (
      select coalesce(jsonb_agg(jsonb_build_object(
                        'created_at', f.created_at,
                        'screen', f.screen,
                        'account', case when u.is_anonymous or u.email is null then 'guest' else 'email' end,
                        'message', f.message)
                      order by f.created_at desc, f.id), '[]'::jsonb)
        from (select fb.* from public.feedback fb order by fb.created_at desc, fb.id limit 50) f
        join auth.users u on u.id = f.user_id),
    'crashes', (
      select coalesce(jsonb_agg(jsonb_build_object(
                        'name', l.error_name,
                        'message', l.message,
                        'count', g.n,
                        'first_seen', g.first_seen,
                        'last_seen', g.last_seen,
                        'source', l.source,
                        'path', l.path,
                        'browser', l.browser,
                        'app_version', l.app_version,
                        'frames', l.frames)
                      order by g.last_seen desc, g.group_key), '[]'::jsonb)
        from (select c.group_key, count(*) as n, min(c.created_at) as first_seen, max(c.created_at) as last_seen
                from private.crash_reports c
               where c.created_at >= now() - interval '30 days'
               group by c.group_key
               order by max(c.created_at) desc, c.group_key
               limit 20) g
        join lateral (select r.* from private.crash_reports r
                       where r.group_key = g.group_key and r.created_at >= now() - interval '30 days'
                       order by r.created_at desc, r.id desc
                       limit 1) l on true),
    'computed_at', now()
  );
end;
$$;

comment on function public.owner_dashboard() is
  'Job 14-analytics: every number of the owner page as one JSON object, only for an account on the owner list with a live sign in.';

revoke all on function public.owner_dashboard() from public, anon, authenticated, service_role;
grant execute on function public.owner_dashboard() to authenticated;

-- The data download now lists feedback and the owner row ---------------------------------
-- Same function as job 11 (security invoker, so the read rules apply), with
-- two more lists. The owner row is read through public.my_owner_rows().

create or replace function public.export_my_data()
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
        from public.kept_recordings t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'feedback', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.feedback t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'private.owners', coalesce(public.my_owner_rows(), '[]'::jsonb)
  ));
$$;

comment on function public.export_my_data() is
  'Job 11-accounts, extended in job 14-analytics: every row of the caller''s in every user table, read as the caller. A new user table must be added here in the same job.';

revoke all on function public.export_my_data() from public, anon, authenticated, service_role;
grant execute on function public.export_my_data() to authenticated;
