-- SCRATCH (job 11-accounts, do not merge): a new user table in a new project
-- schema, with the cascade and row level security, left out of
-- export_my_data(). The database check must turn red.
create schema scratch_probe;
create table scratch_probe.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  body text not null
);
alter table scratch_probe.notes enable row level security;
revoke all on table scratch_probe.notes from anon, authenticated, service_role;
