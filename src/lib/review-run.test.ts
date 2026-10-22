import { describe, expect, it } from 'vitest'
import { afterResult, placeOf, startRun, type RunTurn } from './review-run.ts'
import type { ReviewResult } from './review-types.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// The order of one review run, with one more try for a missed item.

/** Plays a whole run: results[i] is the result of the i-th turn. */
function play(count: number, results: ReviewResult[]): RunTurn[] {
  let run = startRun(count)
  for (let at = 0; at < run.length; at += 1) run = afterResult(run, at, results[at] ?? 'correct')
  return run
}

describe('the review run', () => {
  it('[review 13] every item comes once, in order, when all are right', () => {
    expect(play(3, ['correct', 'correct', 'correct'])).toEqual([
      { item: 0, retry: false },
      { item: 1, retry: false },
      { item: 2, retry: false },
    ])
  })

  it('[review 13] an item graded close or wrong comes back once more after the other items', () => {
    expect(play(3, ['wrong', 'correct', 'close', 'correct', 'correct'])).toEqual([
      { item: 0, retry: false },
      { item: 1, retry: false },
      { item: 2, retry: false },
      { item: 0, retry: true },
      { item: 2, retry: true },
    ])
  })

  it('[review 13] it does not come back a third time, even when missed again', () => {
    expect(play(2, ['wrong', 'correct', 'wrong'])).toEqual([
      { item: 0, retry: false },
      { item: 1, retry: false },
      { item: 0, retry: true },
    ])
  })

  it('[review 8] [review 13] the first pass shows its place, a retry shows none', () => {
    expect(placeOf({ item: 2, retry: false }, 15)).toBe('3 of 15')
    expect(placeOf({ item: 2, retry: true }, 15)).toBeNull()
  })

  it('[review 13] an empty run stays empty', () => {
    expect(startRun(0)).toEqual([])
    expect(afterResult([], 0, 'wrong')).toEqual([])
  })
})
