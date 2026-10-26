import type { ReviewResult } from './review-types.ts'

// The order of one review run (factory/jobs/9-daily-review/spec.md, "Done
// when" 13). Every item once, in the order the Worker gave. An item graded
// close or wrong on its first pass comes back once more, after the other
// items, without a place number. It never comes back a third time in the
// same run; the database's once a day rule then holds it until tomorrow.

export interface RunTurn {
  /** Index of the item in the run's item list. */
  item: number
  /** True for the one more try. */
  retry: boolean
}

/** The first pass: every item once, in order. */
export function startRun(count: number): RunTurn[] {
  return Array.from({ length: count }, (_, item) => ({ item, retry: false }))
}

/** The run after the turn at `at` was graded `result`. */
export function afterResult(run: readonly RunTurn[], at: number, result: ReviewResult): RunTurn[] {
  const turn = run.at(at)
  if (!turn || turn.retry || result === 'correct') return [...run]
  return [...run, { item: turn.item, retry: true }]
}

/** "3 of 15" on the first pass; nothing on a retry. */
export function placeOf(turn: RunTurn, count: number): string | null {
  return turn.retry ? null : `${String(turn.item + 1)} of ${String(count)}`
}
