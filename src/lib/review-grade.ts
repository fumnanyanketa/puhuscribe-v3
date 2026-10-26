import { gradeAnswer, type GradeTier } from './grade.ts'
import { Rating } from './fsrs/types.ts'
import type { ReviewAnswer, ReviewResult, SpokenClass } from './review-types.ts'

// The grading wrapper of the Keep it step (factory/jobs/9-daily-review/spec.md,
// "Done when" 10 and 15). v2's grader (src/lib/grade.ts, unchanged) marks the
// answer against the form's spoken shape and its written shape, and the better
// result counts: both registers are right Finnish (Decision 3). The rating
// follows from the result and from nothing else; the learner never rates
// themselves.

/** The only rating there is for each result. */
export const RATING_FOR: Readonly<Record<ReviewResult, Rating>> = {
  correct: Rating.Good,
  close: Rating.Hard,
  wrong: Rating.Again,
}

/**
 * The class of a spoken answer becomes a result, and so a rating, by this table
 * only (job 10-speaking-feedback, "Done when" 21): clear is Good, close is
 * Hard, try again is Again. A recording that was not heard grades nothing.
 */
export const SPOKEN_RESULT: Readonly<Record<SpokenClass, ReviewResult>> = {
  clear: 'correct',
  close: 'close',
  try_again: 'wrong',
}

const BETTER: Readonly<Record<GradeTier, number>> = { correct: 0, close: 1, wrong: 2 }

export interface FormShapes {
  /** forms.surface_puhe */
  spoken: string
  /** forms.surface_kirja */
  written: string
}

export interface GradedReview {
  result: ReviewResult
  rating: Rating
}

export function gradeReview(answer: ReviewAnswer, form: FormShapes): GradedReview {
  if (answer.kind === 'spoken') {
    const result = SPOKEN_RESULT[answer.feedbackClass]
    return { result, rating: RATING_FOR[result] }
  }
  const text = answer.text
  const spoken = gradeAnswer(text, form.spoken)
  const written = gradeAnswer(text, form.written)
  const result = BETTER[written.tier] < BETTER[spoken.tier] ? written.tier : spoken.tier
  return { result, rating: RATING_FOR[result] }
}
