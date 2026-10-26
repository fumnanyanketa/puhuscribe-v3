// The shapes the Worker sends the app for the Keep it step
// (factory/jobs/9-daily-review/spec.md). Shared by worker/ and src/, so both
// sides agree. Nothing here identifies the learner: no user id, no token, and
// no card values.

import type { SessionLine } from './session-types.ts'

/** At most this many cards in one review run (Decision 5). One constant to change. */
export const MAX_REVIEW_RUN = 15

/** The longest typed answer accepted, in characters (UTF-16 code units, as maxLength counts). */
export const MAX_ANSWER_LENGTH = 100

/**
 * How the learner answered: by typing, or by saying it (job 10-speaking-feedback,
 * "Done when" 21). A spoken answer holds the class the Worker itself worked
 * out from the speech service's answer; the browser can never send one
 * (POST /api/review/answer takes only the typed kind).
 */
export interface TypedAnswer {
  kind: 'typed'
  text: string
}
export type SpokenClass = 'clear' | 'close' | 'try_again'
export interface SpokenAnswer {
  kind: 'spoken'
  feedbackClass: SpokenClass
}
export type ReviewAnswer = TypedAnswer | SpokenAnswer
export type AnswerKind = ReviewAnswer['kind']

/** The grader's result. Its rating follows from it (src/lib/review-grade.ts). */
export type ReviewResult = 'correct' | 'close' | 'wrong'

/**
 * One word of the prompt line, as it appears in the line. A gap stands where
 * the missing word is: it carries the punctuation around it, never the word.
 */
export type PromptWord =
  { text: string; before?: string; after?: string } | { gap: true; before?: string; after?: string }

/**
 * One review item, before the learner answers. It holds the line in one
 * register with the form's words replaced by gaps, and nothing else of the
 * answer: no form surface, no gapped word, no line text in the other register.
 */
export interface ReviewItem {
  formId: number
  speaker: string
  /** The line's English meaning. */
  gloss: string
  /** Which register the prompt line is in: spoken where the spoken line has the form, else written. */
  register: 'spoken' | 'written'
  /** Same address path of the line's audio in that register, such as /audio/<key>. */
  audio: string
  words: PromptWord[]
}

/** The answer of GET /api/sessions/<id>/review. */
export interface ReviewItemsAnswer {
  items: ReviewItem[]
}

/** The answer of POST /api/review/answer: the result and the whole line, shown after answering. */
export interface ReviewFeedback {
  result: ReviewResult
  line: SessionLine
  /** Which words of each register are the answer (indexes into line.spoken and line.written). */
  marked: { spoken: number[]; written: number[] }
  /** The form's two shapes. */
  form: { spoken: string; written: string }
}

/** Today's Helsinki date and the day of the next review, as YYYY-MM-DD (from public.next_review_day). */
export interface NextReview {
  today: string
  day: string
}
