import { gradeAnswer, type GradeTier } from './grade.ts'
import { Rating } from './fsrs/types.ts'
import type { ReviewAnswer, ReviewResult } from './review-types.ts'

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

/**
 * The text an answer gives the grader. Today every answer is typed. A spoken
 * answer (job 10) adds its kind to ReviewAnswer and gives its transcript here.
 */
function answerText(answer: ReviewAnswer): string {
  return answer.text
}

export function gradeReview(answer: ReviewAnswer, form: FormShapes): GradedReview {
  const text = answerText(answer)
  const spoken = gradeAnswer(text, form.spoken)
  const written = gradeAnswer(text, form.written)
  const result = BETTER[written.tier] < BETTER[spoken.tier] ? written.tier : spoken.tier
  return { result, rating: RATING_FOR[result] }
}
