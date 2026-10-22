import { describe, expect, it } from 'vitest'
import type { Database } from './database.types'
import { createEmptyCard, FSRS } from './fsrs/scheduler'
import { Rating, State, type Card, type ReviewLog } from './fsrs/types'

// [data 3] Review is scheduled per form, matching the imported scheduler
// (factory/jobs/3-data-model/spec.md). database.types.ts is made by the
// Supabase CLI from the migrated database, and the database check fails when
// it is out of date. These tests prove, at compile time (npm run typecheck)
// and at run time, that the scheduler's Card and ReviewLog fit the cards and
// review_logs tables one to one, with no cast.

type Tables = Database['public']['Tables']
type CardRow = Tables['cards']['Row']
type CardInsert = Tables['cards']['Insert']
type LogRow = Tables['review_logs']['Row']
type LogInsert = Tables['review_logs']['Insert']

// `true` only when the two key lists are the same set.
type SameKeys<A, B> = [Exclude<keyof A, keyof B>, Exclude<keyof B, keyof A>] extends [never, never]
  ? true
  : false

// cards = Card + who, which form, and when the card was made.
const cardColumnsMatch: SameKeys<
  CardRow,
  Card & { user_id: unknown; form_id: unknown; created_at: unknown }
> = true
// review_logs = ReviewLog + its id, who, which form, and typed or spoken.
const logColumnsMatch: SameKeys<
  LogRow,
  ReviewLog & { id: unknown; user_id: unknown; form_id: unknown; mode: unknown }
> = true

// card_state has exactly the scheduler's State values, in both directions.
const statesMatch: [Exclude<CardRow['state'], `${State}`>, Exclude<`${State}`, CardRow['state']>] extends [
  never,
  never,
]
  ? true
  : false = true

const USER = '00000000-0000-4000-8000-000000000001'
const FORM = 1
const NOW = new Date('2026-10-20T08:00:00.000Z')

// Every field is assigned by name. Dates become ISO strings, which is how the
// database client sends a timestamptz; there is no type cast anywhere.
function cardInsert(card: Card): CardInsert {
  return {
    user_id: USER,
    form_id: FORM,
    due: card.due.toISOString(),
    stability: card.stability,
    difficulty: card.difficulty,
    elapsed_days: card.elapsed_days,
    scheduled_days: card.scheduled_days,
    reps: card.reps,
    lapses: card.lapses,
    state: card.state,
    last_review: card.last_review ? card.last_review.toISOString() : null,
  }
}

function logInsert(log: ReviewLog, mode: LogInsert['mode']): LogInsert {
  return {
    user_id: USER,
    form_id: FORM,
    mode,
    rating: log.rating,
    state: log.state,
    due: log.due.toISOString(),
    stability: log.stability,
    difficulty: log.difficulty,
    elapsed_days: log.elapsed_days,
    last_elapsed_days: log.last_elapsed_days,
    scheduled_days: log.scheduled_days,
    review_time: log.review_time.toISOString(),
  }
}

describe('[data 3] the scheduler fits the cards and review_logs tables', () => {
  it('[data 3] the cards and review_logs columns are the Card and ReviewLog fields plus the listed extras', () => {
    expect(cardColumnsMatch).toBe(true)
    expect(logColumnsMatch).toBe(true)
  })

  it('[data 3] a new card from createEmptyCard() fills every cards field', () => {
    const empty = createEmptyCard(NOW)
    const row = cardInsert(empty)
    expect(Object.keys(row).sort()).toEqual([...Object.keys(empty), 'form_id', 'user_id'].sort())
    expect(row).toEqual({
      user_id: USER,
      form_id: FORM,
      due: '2026-10-20T08:00:00.000Z',
      stability: 0,
      difficulty: 0,
      elapsed_days: 0,
      scheduled_days: 0,
      reps: 0,
      lapses: 0,
      state: 'new',
      last_review: null,
    })
  })

  it('[data 3] a card and log from FSRS.schedule() fill every cards and review_logs field', () => {
    const { card, log } = new FSRS().schedule(createEmptyCard(NOW), Rating.Good, NOW)
    const cardRow = cardInsert(card)
    const logRow = logInsert(log, 'spoken')
    expect(cardRow.state).toBe(State.Learning)
    expect(cardRow.reps).toBe(1)
    expect(cardRow.last_review).toBe(NOW.toISOString())
    expect(Object.keys(logRow).sort()).toEqual([...Object.keys(log), 'form_id', 'mode', 'user_id'].sort())
    expect(logRow).toMatchObject({ rating: 3, state: 'new', mode: 'spoken', review_time: NOW.toISOString() })
  })

  it("[data 3] the card_state values are the scheduler's State values", () => {
    const states: CardRow['state'][] = [State.New, State.Learning, State.Review, State.Relearning]
    expect(states).toEqual(['new', 'learning', 'review', 'relearning'])
    expect(statesMatch).toBe(true)
  })
})
