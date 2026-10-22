-- Job 2-smoke (factory smoke test): one table that records page visits.
-- Spec: factory/jobs/2-smoke/spec.md, "Done when" statements 5 and 7.
--
-- A visit is a number and a time, both set by the database. Nothing about the
-- visitor is stored. The Worker adds visits with the test project's publishable
-- key, which runs as the `anon` role. `anon` may add a visit stamped with the
-- database's own current time, and do nothing else.

create table public.visits (
  id bigint generated always as identity primary key,
  visited_at timestamptz not null default now()
);

comment on table public.visits is
  'Factory smoke test (job 2-smoke): one row per page load. No personal data.';

-- Remove every default permission the API roles could get on the new table
-- (and on its id sequence), whatever the project's "expose new tables"
-- setting is. Then give anon permission to insert and nothing else.
revoke all on table public.visits from anon, authenticated, service_role;
revoke all on sequence public.visits_id_seq from anon, authenticated, service_role;
grant insert on table public.visits to anon;

-- Row level security: with it on, a role can only touch rows a policy allows.
alter table public.visits enable row level security;

-- The one rule. A new row is accepted only when visited_at is the database's
-- current time, so nobody can back-date or invent visits.
create policy "anon adds a visit stamped now"
  on public.visits
  for insert
  to anon
  with check (visited_at = now());
