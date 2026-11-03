-- Language islands (fast route "islands", 3 November 2026): the learner's own island lines.
-- The lines and lists are content/islands/islands.md, approved by the owner; the app reads them from
-- src/lib/islands-data.json. This table keeps only what the learner chose, so the island follows the
-- learner to a new phone (owner: "people change devices").
--
-- One row per learner per stop: the number of the choice they picked from that stop's list, and, at
-- stop 1 only, the first name they typed. No other free text. The lock is the one of the learner
-- tables (supabase/migrations/20261020090100_learner_model.sql): everything revoked from the API roles,
-- a learner may read, add and change only their own rows, and the rows go with the account (on delete
-- cascade). The Worker reads and writes them with the learner's own token (worker/island.ts).
--
-- public.export_my_data() lists the table (rule of job 11-accounts: a new user table goes into the
-- export and into src/privacy/data-inventory.ts in the same job).

create table public.island_lines (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  -- The stops that have a line in islands.md. 10, 13 and 32 have none on purpose.
  stop_number smallint not null check (
    stop_number in (1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
                    26, 27, 28, 29, 30, 31, 33, 34, 35, 36)
  ),
  -- The number of the choice in the stop's list, from 0. Empty for the four lines with no list.
  choice smallint,
  -- Stop 1 only: the first name the learner typed, as typed, at most 30 characters.
  first_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, stop_number),
  -- Each list's size, from src/lib/islands-data.json. A changed list needs a new migration.
  constraint island_lines_choice_in_list check (
    coalesce(
      case stop_number
        when 1 then choice between 0 and 29
        when 2 then choice between 0 and 4
        when 3 then choice between 0 and 3
        when 4 then choice between 0 and 2
        when 5 then choice between 0 and 5
        when 6 then choice between 0 and 4
        when 7 then choice between 0 and 11
        when 8 then choice between 0 and 3
        when 9 then choice between 0 and 3
        when 11 then choice between 0 and 14
        when 12 then choice between 0 and 6
        when 14 then choice between 0 and 5
        when 15 then choice is null
        when 16 then choice between 0 and 2
        when 17 then choice between 0 and 5
        when 18 then choice between 0 and 3
        when 19 then choice between 0 and 6
        when 20 then choice between 0 and 5
        when 21 then choice between 0 and 2
        when 22 then choice between 0 and 6
        when 23 then choice between 0 and 4
        when 24 then choice between 0 and 3
        when 25 then choice between 0 and 2
        when 26 then choice between 0 and 3
        when 27 then choice between 0 and 3
        when 28 then choice between 0 and 3
        when 29 then choice between 0 and 2
        when 30 then choice is null
        when 31 then choice is null
        when 33 then choice between 0 and 29
        when 34 then choice between 0 and 3
        when 35 then choice between 0 and 5
        when 36 then choice is null
      end,
      false
    )
  ),
  -- A first name at stop 1 and nowhere else.
  constraint island_lines_name_only_at_stop_1 check ((stop_number = 1) = (first_name is not null)),
  -- The name's shape: 1 to 30 characters, no space at either end or twice in a row, and no digit,
  -- control character or punctuation other than a hyphen or an apostrophe. The Worker also allows
  -- only letters (worker/island.ts); this is the floor the database keeps whatever calls it.
  constraint island_lines_name_shape check (
    first_name is null
    or (
      char_length(first_name) between 1 and 30
      and first_name = btrim(first_name)
      and position('  ' in first_name) = 0
      and first_name !~ '[0-9[:cntrl:]]'
      and first_name !~ '[][!"#$%&()*+,./:;<=>?@\\^_`{|}~]'
    )
  )
);

comment on table public.island_lines is
  'Learner data (fast route islands, 3 November 2026): the choice the learner picked for each stop''s island line, and the first name typed at stop 1. Deleted with the account.';

-- The time of the last change, set by the database, never by the caller.
create function private.island_lines_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger island_lines_touch before update on public.island_lines
  for each row execute function private.island_lines_touch();

revoke all on function private.island_lines_touch() from public, anon, authenticated, service_role;

-- Permissions -------------------------------------------------------------------
-- Remove everything, then a learner may read their own rows, add one per stop, and change the choice
-- or the name of their own row. The user id, the stop and the times cannot be changed. No deletes for
-- anyone: rows go only when the user is deleted.

revoke all on table public.island_lines from anon, authenticated, service_role;
grant select on table public.island_lines to authenticated;
grant insert (user_id, stop_number, choice, first_name) on table public.island_lines to authenticated;
grant update (choice, first_name) on table public.island_lines to authenticated;

alter table public.island_lines enable row level security;

create policy "learners read their own island lines"
  on public.island_lines
  for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "learners add their own island lines"
  on public.island_lines
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy "learners change their own island lines"
  on public.island_lines
  for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- The export: every user table, now with the island -------------------------------------------

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
    'island_lines', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.stop_number)
        from public.island_lines t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'private.owners', coalesce(public.my_owner_rows(), '[]'::jsonb)
  ));
$$;

comment on function public.export_my_data() is
  'Job 11-accounts, extended in job 14-analytics and the islands fast route: every row of the caller''s in every user table, read as the caller. A new user table must be added here in the same job.';

revoke all on function public.export_my_data() from public, anon, authenticated, service_role;
grant execute on function public.export_my_data() to authenticated;
