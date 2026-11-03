// The shapes of a practice replay (owner's fast route "go-back", 3 November 2026). Shared by worker/
// and src/, so both sides agree. Nothing here identifies the learner: no user id, no token.
//
// A practice replay plays a lesson the learner has already finished again: Hear it, say it, Understand
// it, the Recap and Keep it for that one dialogue. It is not a new session. It writes no session step,
// does not finish anything, does not move the road and does not touch the review schedule. The only
// writes it can lead to are the speaking feedback checks the learner asks for, which the owner allowed.

import type { ReviewFeedback, ReviewItem } from './review-types.ts'
import type { ReadySession } from './session-types.ts'

/** One lesson the learner has finished, which they may play again as practice. */
export interface PracticeLesson {
  /** The dialogue's id, used in the practice address (/session?practice=<id>). */
  dialogueId: number
  /** The road stop the lesson belongs to. */
  stop: number
  /** 1 based: the lesson's place in its stop. */
  lesson: number
  /** The lesson's title, in English. */
  title: string
}

/** The answer of GET /api/practice: every finished lesson on the road, in road order. */
export interface PracticeListAnswer {
  lessons: PracticeLesson[]
}

/**
 * One Keep it item of a practice replay. The answer comes with it, because a practice answer is
 * checked in the browser and never sent or stored: the lesson is one the learner has already finished.
 */
export interface PracticeKeepItem {
  item: ReviewItem
  answer: Omit<ReviewFeedback, 'result'>
}

/** The answer of GET /api/practice?dialogue=<id>. */
export interface PracticeAnswer {
  /** The lesson as a session screen shows it. Its session id is the learner's finished session for it. */
  session: ReadySession
  /** Keep it's items: the lesson's words that are in the learner's review, at most 15. */
  keep: PracticeKeepItem[]
}

/** The page address of a practice replay. */
export function practiceQuery(dialogueId: number): string {
  return `?practice=${String(dialogueId)}`
}

const DIALOGUE_ID = /^[1-9][0-9]{0,8}$/

/** The dialogue id in a practice address, or null when there is none or it is not an id. */
export function practiceIdFrom(search: string): number | null {
  const asked = new URLSearchParams(search).get('practice')
  return asked !== null && DIALOGUE_ID.test(asked) ? Number(asked) : null
}
