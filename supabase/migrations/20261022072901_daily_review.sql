-- Job 9-daily-review: the three database functions of the Keep it step.
-- Spec: factory/jobs/9-daily-review/spec.md, "Done when" 1, 2, 11 and 18.
-- Plain English description: docs/data-model.md.
--
-- No table, column or enum value is added or changed here. Each function runs
-- with the learner's own rights (security invoker), so the access rules of jobs
-- 3 and 8 still decide every row it sees or writes: a learner reaches only
-- their own cards and review logs, and only approved forms.
--
-- "Today" is the calendar date in Europe/Helsinki, worked out here in Postgres
-- and never from the learner's device clock (Decision 7).

-- Which cards come up now ------------------------------------------------------

-- A card is reviewable now when its form is readable by the learner (approved,
-- through the forms read rule), its due time has passed, and the Helsinki day
-- it was last touched (last_review, or created_at when never reviewed) is
-- before today. Oldest due first, then lowest form id, at most 15 per run.
create function public.review_queue(p_limit integer)
returns table (form_id bigint, reps integer, due timestamptz)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.form_id, c.reps, c.due
    from public.cards c
    join public.forms f on f.id = c.form_id
   where c.user_id = (select auth.uid())
     and c.due <= now()
     and (coalesce(c.last_review, c.created_at) at time zone 'Europe/Helsinki')::date
         < (now() at time zone 'Europe/Helsinki')::date
   order by c.due, c.form_id
   limit least(greatest(coalesce(p_limit, 0), 0), 15);
$$;

comment on function public.review_queue(integer) is
  'Job 9-daily-review: the learner''s own reviewable cards (readable form, due, last touched before today in Helsinki), oldest due first, at most 15.';

-- When the next review is ------------------------------------------------------

-- One row: today's Helsinki date, and the earliest Helsinki day on which one
-- of the learner's cards becomes reviewable by the rule above (never before
-- today), or no day when the learner has no card with a readable form.
create function public.next_review_day()
returns table (today date, next_day date)
language sql
stable
security invoker
set search_path = ''
as $$
  with now_here as (
    select (now() at time zone 'Europe/Helsinki')::date as today
  )
  select n.today,
         -- min() over no rows is empty, so a learner without cards gets no day.
         (select min(greatest(
                   n.today,
                   (c.due at time zone 'Europe/Helsinki')::date,
                   (coalesce(c.last_review, c.created_at) at time zone 'Europe/Helsinki')::date + 1
                 ))
            from public.cards c
            join public.forms f on f.id = c.form_id
           where c.user_id = (select auth.uid()))
    from now_here n;
$$;

comment on function public.next_review_day() is
  'Job 9-daily-review: today''s Helsinki date and the earliest Helsinki day one of the learner''s cards becomes reviewable, or no day.';

-- Saving one review --------------------------------------------------------------

-- In one transaction: updates the card to the values the Worker's scheduler
-- worked out, and adds one review_logs row with the grader's rating. Only while
-- the card's reps still equals the value the Worker read; otherwise it writes
-- nothing and returns false (the Worker answers 409).
--
-- The card is found by its form alone. Which learner's card that is, is left to
-- the cards rules (security invoker), on purpose: the pgTAP test "A cannot
-- record a review on B's card" then proves those rules protect it, and turns
-- red if this function is ever made security definer (statement 18). The log
-- row carries the user id of the card that was changed.
create function public.record_review(
  p_form_id bigint,
  p_expected_reps integer,
  p_due timestamptz,
  p_stability double precision,
  p_difficulty double precision,
  p_elapsed_days integer,
  p_scheduled_days integer,
  p_reps integer,
  p_lapses integer,
  p_state public.card_state,
  p_last_review timestamptz,
  p_rating smallint,
  p_mode public.review_mode,
  p_log_state public.card_state,
  p_log_due timestamptz,
  p_log_stability double precision,
  p_log_difficulty double precision,
  p_log_elapsed_days integer,
  p_log_last_elapsed_days integer,
  p_log_scheduled_days integer,
  p_review_time timestamptz
)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  card_owner uuid;
begin
  update public.cards c
     set due = p_due,
         stability = p_stability,
         difficulty = p_difficulty,
         elapsed_days = p_elapsed_days,
         scheduled_days = p_scheduled_days,
         reps = p_reps,
         lapses = p_lapses,
         state = p_state,
         last_review = p_last_review
   where c.form_id = p_form_id
     and c.reps = p_expected_reps
  returning c.user_id into card_owner;

  if card_owner is null then
    return false;
  end if;

  -- A row that fails a check (such as a rating outside 1 to 4) raises an
  -- error, which undoes the card update above as well.
  insert into public.review_logs (
    user_id, form_id, rating, mode, state, due, stability, difficulty,
    elapsed_days, last_elapsed_days, scheduled_days, review_time
  ) values (
    card_owner, p_form_id, p_rating, p_mode, p_log_state, p_log_due, p_log_stability,
    p_log_difficulty, p_log_elapsed_days, p_log_last_elapsed_days, p_log_scheduled_days, p_review_time
  );
  return true;
end;
$$;

comment on function public.record_review(
  bigint, integer, timestamptz, double precision, double precision, integer, integer, integer,
  integer, public.card_state, timestamptz, smallint, public.review_mode, public.card_state,
  timestamptz, double precision, double precision, integer, integer, integer, timestamptz
) is
  'Job 9-daily-review: saves one review as the learner, in one transaction: the new card values and one review log, only while reps is unchanged.';

-- Permissions -------------------------------------------------------------------
-- Learners only. Nobody else may call these.

revoke all on function public.review_queue(integer) from public, anon, authenticated, service_role;
grant execute on function public.review_queue(integer) to authenticated;

revoke all on function public.next_review_day() from public, anon, authenticated, service_role;
grant execute on function public.next_review_day() to authenticated;

revoke all on function public.record_review(
  bigint, integer, timestamptz, double precision, double precision, integer, integer, integer,
  integer, public.card_state, timestamptz, smallint, public.review_mode, public.card_state,
  timestamptz, double precision, double precision, integer, integer, integer, timestamptz
) from public, anon, authenticated, service_role;
grant execute on function public.record_review(
  bigint, integer, timestamptz, double precision, double precision, integer, integer, integer,
  integer, public.card_state, timestamptz, smallint, public.review_mode, public.card_state,
  timestamptz, double precision, double precision, integer, integer, integer, timestamptz
) to authenticated;
