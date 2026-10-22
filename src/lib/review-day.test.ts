import { afterEach, describe, expect, it, vi } from 'vitest'
import { nextReviewSentence } from './review-day.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// The front door's sentence for the day of the next review.

describe('nextReviewSentence', () => {
  afterEach(() => {
    vi.useRealTimers()
  })

  it('[review 5] the same day is "later today"', () => {
    expect(nextReviewSentence('2026-10-22', '2026-10-22')).toBe('Your next review is later today.')
  })

  it('[review 5] the next day is "tomorrow"', () => {
    expect(nextReviewSentence('2026-10-22', '2026-10-23')).toBe('Your next review is tomorrow.')
  })

  it('[review 5] a later day is named by weekday and date, in English', () => {
    expect(nextReviewSentence('2026-10-22', '2026-10-24')).toBe('Your next review is on Saturday 24 October.')
    expect(nextReviewSentence('2026-10-22', '2026-11-05')).toBe('Your next review is on Thursday 5 November.')
  })

  it('[review 5] across the end of a month', () => {
    expect(nextReviewSentence('2026-10-31', '2026-11-01')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2026-10-30', '2026-11-01')).toBe('Your next review is on Sunday 1 November.')
    expect(nextReviewSentence('2028-02-28', '2028-02-29')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2028-02-28', '2028-03-01')).toBe('Your next review is on Wednesday 1 March.')
  })

  it('[review 5] across the end of a year', () => {
    expect(nextReviewSentence('2026-12-31', '2027-01-01')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2026-12-30', '2027-01-04')).toBe('Your next review is on Monday 4 January.')
  })

  it('[review 5] across a daylight saving change (Finland: 25 October 2026 and 28 March 2027)', () => {
    expect(nextReviewSentence('2026-10-24', '2026-10-25')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2026-10-25', '2026-10-26')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2026-10-24', '2026-10-26')).toBe('Your next review is on Monday 26 October.')
    expect(nextReviewSentence('2027-03-27', '2027-03-28')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2027-03-28', '2027-03-29')).toBe('Your next review is tomorrow.')
    expect(nextReviewSentence('2027-03-27', '2027-03-29')).toBe('Your next review is on Monday 29 March.')
  })

  it('[review 5] never reads the device clock: the same dates give the same words at any time and in any time zone', () => {
    const before = nextReviewSentence('2026-10-22', '2026-10-24')
    vi.useFakeTimers()
    vi.setSystemTime(new Date('2031-06-01T23:59:00Z'))
    expect(nextReviewSentence('2026-10-22', '2026-10-24')).toBe(before)
    expect(nextReviewSentence('2026-10-22', '2026-10-22')).toBe('Your next review is later today.')
  })

  it('[review 5] a date that is not real gives no sentence', () => {
    expect(nextReviewSentence('2026-02-30', '2026-03-01')).toBeNull()
    expect(nextReviewSentence('2026-10-22', 'tomorrow')).toBeNull()
    expect(nextReviewSentence('', '2026-10-22')).toBeNull()
  })
})
