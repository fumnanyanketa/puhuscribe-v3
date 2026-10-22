import { FSRS } from '../src/lib/fsrs/scheduler.ts'
import { State, type Card, type Rating } from '../src/lib/fsrs/types.ts'
import type { CardRow, RecordReviewArgs } from './learner-db.ts'

// The next review date, from v2's scheduler with its default settings
// (factory/jobs/9-daily-review/spec.md, "Done when" 11). Rows come from
// Supabase with times as text and the state as the same strings as v2's State;
// they become a Card for schedule(), and the result becomes the arguments of
// public.record_review. The Worker's clock gives the review time.

const STATES: Readonly<Record<CardRow['state'], State>> = {
  new: State.New,
  learning: State.Learning,
  review: State.Review,
  relearning: State.Relearning,
}

function stateName(state: State): CardRow['state'] {
  switch (state) {
    case State.New:
      return 'new'
    case State.Learning:
      return 'learning'
    case State.Review:
      return 'review'
    case State.Relearning:
      return 'relearning'
  }
}

/** A card row as v2's Card. */
export function toCard(row: CardRow): Card {
  return {
    due: new Date(row.due),
    stability: row.stability,
    difficulty: row.difficulty,
    elapsed_days: row.elapsedDays,
    scheduled_days: row.scheduledDays,
    reps: row.reps,
    lapses: row.lapses,
    state: STATES[row.state],
    last_review: row.lastReview === null ? null : new Date(row.lastReview),
  }
}

/**
 * Schedules the card with the grader's rating and returns what
 * public.record_review saves: the new card values and the log, guarded by the
 * reps the Worker read.
 */
export function scheduleReview(
  row: CardRow,
  rating: Rating,
  now: Date,
  mode: RecordReviewArgs['p_mode'],
): RecordReviewArgs {
  const { card, log } = new FSRS().schedule(toCard(row), rating, now)
  return {
    p_form_id: row.formId,
    p_expected_reps: row.reps,
    p_due: card.due.toISOString(),
    p_stability: card.stability,
    p_difficulty: card.difficulty,
    p_elapsed_days: card.elapsed_days,
    p_scheduled_days: card.scheduled_days,
    p_reps: card.reps,
    p_lapses: card.lapses,
    p_state: stateName(card.state),
    p_last_review: card.last_review === null ? now.toISOString() : card.last_review.toISOString(),
    p_rating: log.rating,
    p_mode: mode,
    p_log_state: stateName(log.state),
    p_log_due: log.due.toISOString(),
    p_log_stability: log.stability,
    p_log_difficulty: log.difficulty,
    p_log_elapsed_days: log.elapsed_days,
    p_log_last_elapsed_days: log.last_elapsed_days,
    p_log_scheduled_days: log.scheduled_days,
    p_review_time: log.review_time.toISOString(),
  }
}
