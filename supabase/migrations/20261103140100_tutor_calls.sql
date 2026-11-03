-- Job 16-tutor-step (the tutor, Otso): one cost row per AI call, the limits, and the reservation
-- that enforces them before every call.
-- Spec: factory/jobs/16-tutor-step/spec.md, "Done when" 19, 22 and 24, with the owner's answers of
-- 3 November 2026 (2 chats a day, email accounts only, a 10 euro monthly cap).
--
-- Nothing the learner typed or said and nothing Otso said is stored anywhere: tutor_calls has no
-- text column. A row is added only by public.reserve_tutor_call(), before the AI is called, and the
-- Worker then fills in the outcome, the model, the token counts and the cost, with the learner's own
-- token. The caps count the reserved cost, which the learner cannot change, and a slot is never given
-- back, even when the call fails (job 10's lesson).

-- The outcome of one call ----------------------------------------------------------------------------

create type public.tutor_call_outcome as enum ('reserved', 'served', 'failed_check', 'provider_error');

-- One row per AI call ------------------------------------------------------------------------------------
-- No column for text, an address or a device. cost_usd is named so job 14's owner page counts it.

create table public.tutor_calls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  session_id uuid not null references public.sessions (id) on delete cascade,
  turn smallint not null check (turn between 1 and 3),
  attempt smallint not null check (attempt between 1 and 3),
  created_at timestamptz not null default now(),
  -- Short labels such as "anthropic" and "claude-haiku-5-5", never free text.
  provider text check (provider is null or provider ~ '^[a-z0-9_-]{1,32}$'),
  model text check (model is null or model ~ '^[a-z0-9._-]{1,64}$'),
  outcome public.tutor_call_outcome not null default 'reserved',
  input_tokens integer not null default 0 check (input_tokens between 0 and 1000000),
  output_tokens integer not null default 0 check (output_tokens between 0 and 100000),
  cost_usd numeric(12, 8) not null default 0 check (cost_usd between 0 and 1),
  reserved_usd numeric(12, 8) not null check (reserved_usd >= 0)
);

comment on table public.tutor_calls is
  'Learner data (job 16-tutor-step): one row per AI call of the tutor, Otso, with its model, token counts and cost. No text. Deleted with the account.';

create index tutor_calls_user_id_created_at_idx on public.tutor_calls (user_id, created_at);
create index tutor_calls_session_id_idx on public.tutor_calls (session_id);
create index tutor_calls_created_at_idx on public.tutor_calls (created_at);

-- Permissions -------------------------------------------------------------------------------------------
-- Remove everything. A learner may read their own rows and, only while a row is reserved, fill in its
-- outcome, provider, model, token counts and cost. Rows arrive only through reserve_tutor_call().
-- reserved_usd, the ids and the time cannot be changed. Nothing can be deleted through the API.

revoke all on table public.tutor_calls from anon, authenticated, service_role;
grant select on table public.tutor_calls to authenticated;
grant update (outcome, provider, model, input_tokens, output_tokens, cost_usd)
  on table public.tutor_calls to authenticated;

alter table public.tutor_calls enable row level security;

create policy "learners read their own tutor calls"
  on public.tutor_calls
  for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "learners finish their own reserved tutor calls"
  on public.tutor_calls
  for update
  to authenticated
  using (user_id = (select auth.uid()) and outcome = 'reserved')
  with check (user_id = (select auth.uid()) and outcome <> 'reserved');

-- The limits ------------------------------------------------------------------------------------------------
-- One row, no API role. Defaults from the owner's answers of 3 November 2026: 2 chats a day, email
-- accounts only, a monthly cap of 10 (dollars counted as euros, which overstates the euro figure),
-- and a daily cap of a thirtieth of it. reserved_usd_per_call is the worst case of one Claude Haiku
-- 5.5 call (statement 19): about 8,000 tokens in and 300 out cost 0.00095 dollars, doubled for safety.
-- The owner changes a limit with one line, for example:
--   update private.tutor_limits set monthly_usd = 50, daily_usd = 1.6667;

create table private.tutor_limits (
  id boolean primary key default true check (id),
  max_exchanges_per_day integer not null check (max_exchanges_per_day between 0 and 50),
  daily_usd numeric(10, 4) not null check (daily_usd >= 0),
  monthly_usd numeric(10, 4) not null check (monthly_usd >= 0),
  reserved_usd_per_call numeric(12, 8) not null check (reserved_usd_per_call > 0),
  require_email boolean not null
);

insert into private.tutor_limits (max_exchanges_per_day, daily_usd, monthly_usd, reserved_usd_per_call, require_email)
values (2, 0.3333, 10, 0.002, true);

revoke all on table private.tutor_limits from public, anon, authenticated, service_role;
alter table private.tutor_limits enable row level security;

-- Reserving a call ------------------------------------------------------------------------------------------
-- Takes one slot before an AI call, or returns null and writes nothing. Locks per learner and for the
-- shared money cap, so parallel requests cannot beat a limit. Security definer, because the money cap
-- adds up every learner's reserved cost; it returns no one's data. Takes no argument that carries a
-- limit: every limit comes from private.tutor_limits.

create function public.reserve_tutor_call(p_session_id uuid, p_turn integer, p_attempt integer)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  lim private.tutor_limits%rowtype;
  day_start timestamptz := date_trunc('day', now() at time zone 'Europe/Helsinki') at time zone 'Europe/Helsinki';
  reserved uuid;
begin
  if me is null or p_session_id is null or p_turn is null or p_attempt is null then
    return null;
  end if;
  if p_turn not between 1 and 3 or p_attempt not between 1 and 3 then
    return null;
  end if;
  select * into lim from private.tutor_limits l where l.id;
  if not found then
    return null;
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tutor:' || me::text, 16));
  perform pg_advisory_xact_lock(hashtextextended('tutor:all', 16));

  -- The learner's newest ai_tutor consent is a grant.
  if not coalesce((
    select c.granted from public.consents c
     where c.user_id = me and c.kind = 'ai_tutor'
     order by c.created_at desc
     limit 1
  ), false) then
    return null;
  end if;

  -- The session is the learner's, not ended, at Understand it or later, in a stop of 4 or more.
  if not exists (
    select 1
      from public.sessions s
      join public.dialogues d on d.id = s.dialogue_id
      join public.units u on u.id = d.unit_id
     where s.id = p_session_id
       and s.user_id = me
       and s.ended_at is null
       and s.step_reached >= 'understand'
       and u.stop_number >= 4
  ) then
    return null;
  end if;

  -- Email accounts only, while require_email is set.
  if lim.require_email and coalesce((select u.is_anonymous from auth.users u where u.id = me), true) then
    return null;
  end if;

  -- One call at a time: no earlier call of this learner still reserved and under 30 seconds old.
  if exists (
    select 1 from public.tutor_calls t
     where t.user_id = me and t.outcome = 'reserved' and t.created_at > now() - interval '30 seconds'
  ) then
    return null;
  end if;

  -- A later turn needs the turn before it, in the same session, today.
  if p_turn > 1 and not exists (
    select 1 from public.tutor_calls t
     where t.user_id = me and t.session_id = p_session_id and t.turn = p_turn - 1 and t.created_at >= day_start
  ) then
    return null;
  end if;

  -- Exchanges today (each starts with turn 1, attempt 1), and calls today.
  if p_turn = 1 and p_attempt = 1 and (
    select count(*) from public.tutor_calls t
     where t.user_id = me and t.turn = 1 and t.attempt = 1 and t.created_at >= day_start
  ) >= lim.max_exchanges_per_day then
    return null;
  end if;
  if (
    select count(*) from public.tutor_calls t where t.user_id = me and t.created_at >= day_start
  ) >= lim.max_exchanges_per_day * 9 then
    return null;
  end if;

  -- The money caps, for all learners together: today, and the last 30 days.
  if (
    select coalesce(sum(t.reserved_usd), 0) from public.tutor_calls t where t.created_at >= day_start
  ) + lim.reserved_usd_per_call > lim.daily_usd then
    return null;
  end if;
  if (
    select coalesce(sum(t.reserved_usd), 0) from public.tutor_calls t where t.created_at > now() - interval '30 days'
  ) + lim.reserved_usd_per_call > lim.monthly_usd then
    return null;
  end if;

  insert into public.tutor_calls (user_id, session_id, turn, attempt, outcome, reserved_usd)
  values (me, p_session_id, p_turn, p_attempt, 'reserved', lim.reserved_usd_per_call)
  returning id into reserved;
  return reserved;
end;
$$;

comment on function public.reserve_tutor_call(uuid, integer, integer) is
  'Job 16-tutor-step: takes one AI call slot for the caller''s session turn and attempt, or null when a rule or cap refuses. Never given back.';

revoke all on function public.reserve_tutor_call(uuid, integer, integer) from public, anon, authenticated, service_role;
grant execute on function public.reserve_tutor_call(uuid, integer, integer) to authenticated;

-- Whether a new exchange could start now ----------------------------------------------------------------
-- Read only: true when the caller has an exchange left today and the money caps have room for at
-- least three calls. The session screen asks it as it loads, so a learner at a cap does not get the
-- step (statement 1). It returns only true or false.

create function public.tutor_allowance()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select (select auth.uid()) is not null
       and (select count(*) from public.tutor_calls t
             where t.user_id = (select auth.uid()) and t.turn = 1 and t.attempt = 1
               and t.created_at >= date_trunc('day', now() at time zone 'Europe/Helsinki') at time zone 'Europe/Helsinki')
           < l.max_exchanges_per_day
       and (select coalesce(sum(t.reserved_usd), 0) from public.tutor_calls t
             where t.created_at >= date_trunc('day', now() at time zone 'Europe/Helsinki') at time zone 'Europe/Helsinki')
           + 3 * l.reserved_usd_per_call <= l.daily_usd
       and (select coalesce(sum(t.reserved_usd), 0) from public.tutor_calls t
             where t.created_at > now() - interval '30 days')
           + 3 * l.reserved_usd_per_call <= l.monthly_usd
      from private.tutor_limits l
     where l.id
  ), false);
$$;

comment on function public.tutor_allowance() is
  'Job 16-tutor-step: true when the caller may start an exchange with Otso now (daily exchanges and the money caps). Writes nothing.';

revoke all on function public.tutor_allowance() from public, anon, authenticated, service_role;
grant execute on function public.tutor_allowance() to authenticated;

-- Job 10's withdrawal trigger acts on voice consents only ----------------------------------------------
-- Before this job every consent kind was a voice kind. A withdrawn ai_tutor row must not delete kept
-- recordings or clear transcripts.

drop trigger voice_withdrawal on public.consents;
create trigger voice_withdrawal after insert on public.consents
  for each row
  when (not new.granted and new.kind in ('voice_processing', 'voice_recording_retention'))
  execute function private.apply_voice_withdrawal();

comment on table public.consents is
  'Learner data (job 3-data-model): consent history (voice, and the tutor from job 16-tutor-step), append only.';

-- The export: every user table, now with the tutor calls ------------------------------------------------

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
    'tutor_calls', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.created_at, t.id)
        from public.tutor_calls t where t.user_id = (select auth.uid())), '[]'::jsonb),
    'private.owners', coalesce(public.my_owner_rows(), '[]'::jsonb)
  ));
$$;

comment on function public.export_my_data() is
  'Job 11-accounts, extended in job 14-analytics, the islands fast route and job 16-tutor-step: every row of the caller''s in every user table, read as the caller. A new user table must be added here in the same job.';

revoke all on function public.export_my_data() from public, anon, authenticated, service_role;
grant execute on function public.export_my_data() to authenticated;
