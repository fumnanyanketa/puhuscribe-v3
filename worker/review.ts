import {
  MAX_ANSWER_LENGTH,
  MAX_REVIEW_RUN,
  type ReviewAnswer,
  type ReviewFeedback,
  type ReviewItem,
  type ReviewItemsAnswer,
} from '../src/lib/review-types.ts'
import { gradeReview } from '../src/lib/review-grade.ts'
import type { LearnerDb, ReviewDb, SessionRow } from './learner-db.ts'
import {
  feedbackLine,
  metDialogues,
  pickLine,
  reviewItem,
  type MetDialogue,
  type PickedLine,
  type ReviewMaterial,
} from './review-plan.ts'
import { scheduleReview } from './review-schedule.ts'

// The Keep it step on the Worker (factory/jobs/9-daily-review/spec.md, "Done
// when" 3, 6, 7, 8, 10, 11, 16 and 17). Everything is read and written with
// the learner's own token, through LearnerDb. The typed answer is used to
// grade and to show "You wrote", then dropped: it is never stored and never
// written to a log. This file writes nothing to the log at all.

const LOOP_ORDER = ['hear', 'understand', 'say', 'keep', 'use'] as const

function stepIndex(step: SessionRow['step']): number {
  return step === null ? -1 : LOOP_ORDER.indexOf(step)
}

/** A review only session: no dialogue. */
export function isReviewOnly(session: SessionRow): boolean {
  return session.dialogueId === null
}

/**
 * True when the session may hold Keep it now: a review only session, or a
 * dialogue session that reached at least Understand it (so the browser can
 * never jump past the steps that put words into review).
 */
export function canKeep(session: SessionRow): boolean {
  return isReviewOnly(session) || stepIndex(session.step) >= LOOP_ORDER.indexOf('understand')
}

/** The newest unfinished review only session, if any. */
export function openReviewSession(sessions: readonly SessionRow[]): SessionRow | null {
  return (
    sessions
      .filter((s) => isReviewOnly(s) && s.endedAt === null)
      .sort((a, b) => b.startedAt.localeCompare(a.startedAt))[0] ?? null
  )
}

interface Prepared {
  material: ReviewMaterial
  met: Map<number, MetDialogue>
}

async function prepare(db: LearnerDb, review: ReviewDb, formIds: readonly number[]): Promise<Prepared> {
  const [dialogues, sessions] = await Promise.all([db.readableDialogues(), db.mySessions()])
  const met = metDialogues(dialogues, sessions)
  const material = await review.reviewMaterial(formIds, [...met.keys()])
  return { material, met }
}

/**
 * The items of a run: the learner's reviewable cards (public.review_queue,
 * at most 15), each in the line picked for it. A card with no line to show is
 * skipped (statement 3).
 */
export async function reviewItems(db: LearnerDb, review: ReviewDb): Promise<ReviewItem[]> {
  const queue = await review.reviewQueue(MAX_REVIEW_RUN)
  if (queue.length === 0) return []
  const { material, met } = await prepare(
    db,
    review,
    queue.map((card) => card.formId),
  )
  return queue.flatMap((card) => {
    const picked = pickLine(card.formId, material, met)
    const item = picked && reviewItem(card.formId, picked, material.tokens)
    return item ? [item] : []
  })
}

// Request parsing ------------------------------------------------------------------

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
const ANSWER_FIELDS = new Set(['sessionId', 'formId', 'text', 'kind'])

export interface AnswerRequest {
  sessionId: string
  formId: number
  answer: ReviewAnswer
}

/**
 * The body of POST /api/review/answer: exactly the session id, the form id,
 * the typed text (at most 100 characters) and the kind "typed". Anything else,
 * such as a rating, card values or a user id, makes it null (400).
 */
export function parseAnswer(body: string): AnswerRequest | null {
  let parsed: unknown
  try {
    parsed = JSON.parse(body)
  } catch {
    return null
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) return null
  const fields = parsed as Record<string, unknown>
  const keys = Object.keys(fields)
  if (keys.length !== ANSWER_FIELDS.size || keys.some((key) => !ANSWER_FIELDS.has(key))) return null
  const { sessionId, formId, text, kind } = fields
  if (typeof sessionId !== 'string' || !UUID.test(sessionId)) return null
  if (typeof formId !== 'number' || !Number.isSafeInteger(formId) || formId < 1) return null
  if (typeof text !== 'string' || text.length > MAX_ANSWER_LENGTH) return null
  if (kind !== 'typed') return null
  return { sessionId, formId, answer: { kind, text } }
}

// What each route does with the database ---------------------------------------------

export type ItemsOutcome =
  { kind: 'not_found' } | { kind: 'not_ready' } | { kind: 'items'; answer: ReviewItemsAnswer }

/**
 * GET /api/sessions/<id>/review: the run's items, for the learner's own
 * unfinished session. The session screen asks as it loads: with items, the
 * session ends with Keep it (statement 6). Reading changes nothing, so this
 * also answers before Understand it; answering waits for it.
 */
export async function itemsFor(db: LearnerDb, review: ReviewDb, sessionId: string): Promise<ItemsOutcome> {
  const session = await db.session(sessionId)
  if (!session) return { kind: 'not_found' }
  if (session.endedAt !== null) return { kind: 'not_ready' }
  return { kind: 'items', answer: { items: await reviewItems(db, review) } }
}

export type AnswerOutcome =
  | { kind: 'not_found' }
  | { kind: 'not_ready' }
  | { kind: 'changed' }
  | { kind: 'graded'; feedback: ReviewFeedback }

/**
 * POST /api/review/answer. Reads the learner's card and the form with their
 * token, grades with v2's grader against both shapes, schedules with v2's
 * scheduler and saves once through public.record_review. A card whose form is
 * not readable, or that has no line the learner met, is skipped: not graded,
 * not changed (404).
 */
export async function answer(
  db: LearnerDb,
  review: ReviewDb,
  request: AnswerRequest,
  now: Date,
): Promise<AnswerOutcome> {
  const session = await db.session(request.sessionId)
  if (!session) return { kind: 'not_found' }
  if (session.endedAt !== null || !canKeep(session)) return { kind: 'not_ready' }
  const card = await review.card(request.formId)
  if (!card) return { kind: 'not_found' }
  const { material, met } = await prepare(db, review, [request.formId])
  const picked: PickedLine | null = pickLine(request.formId, material, met)
  const form = material.forms.find((f) => f.id === request.formId)
  const shown = picked && feedbackLine(request.formId, picked, material)
  if (!picked || !form || !shown) return { kind: 'not_found' }

  const graded = gradeReview(request.answer, { spoken: form.surfacePuhe, written: form.surfaceKirja })
  const saved = await review.recordReview(scheduleReview(card, graded.rating, now, request.answer.kind))
  if (!saved) return { kind: 'changed' }
  return {
    kind: 'graded',
    feedback: {
      result: graded.result,
      line: shown.line,
      marked: shown.marked,
      form: { spoken: form.surfacePuhe, written: form.surfaceKirja },
    },
  }
}

export type RecallOutcome =
  { kind: 'not_found' } | { kind: 'not_ready' } | { kind: 'ready'; form: { spoken: string; written: string } }

/**
 * Everything /api/speech/recall must know before it asks the speech service
 * (job 10-speaking-feedback, "Done when" 21): the learner's own unfinished
 * session at a step that may hold Keep it, a card they hold for the form, and
 * a line they met to show it in. The same conditions as answer(), so a check
 * that is paid for can always be graded. The reference is the form's spoken
 * shape; the written shape is also accepted.
 */
export async function recallTarget(
  db: LearnerDb,
  review: ReviewDb,
  sessionId: string,
  formId: number,
): Promise<RecallOutcome> {
  const session = await db.session(sessionId)
  if (!session) return { kind: 'not_found' }
  if (session.endedAt !== null || !canKeep(session)) return { kind: 'not_ready' }
  const card = await review.card(formId)
  if (!card) return { kind: 'not_found' }
  const { material, met } = await prepare(db, review, [formId])
  const picked = pickLine(formId, material, met)
  const form = material.forms.find((f) => f.id === formId)
  if (!picked || !form || !feedbackLine(formId, picked, material)) return { kind: 'not_found' }
  return { kind: 'ready', form: { spoken: form.surfacePuhe, written: form.surfaceKirja } }
}

export type DoneOutcome = { kind: 'not_found' } | { kind: 'not_ready' } | { kind: 'done'; ended: boolean }

/**
 * POST /api/sessions/<id>/review/done. Stores step_reached = 'keep'. A review
 * only session also gets its end time here (it has no complete_session); a
 * dialogue session is ended by the finish screen's complete_session, as in
 * job 8. Calling it again changes nothing.
 */
export async function finishKeep(
  db: LearnerDb,
  review: ReviewDb,
  sessionId: string,
  now: Date,
): Promise<DoneOutcome> {
  const session = await db.session(sessionId)
  if (!session) return { kind: 'not_found' }
  const reviewOnly = isReviewOnly(session)
  if (session.endedAt !== null)
    return reviewOnly && session.step === 'keep' ? { kind: 'done', ended: true } : { kind: 'not_ready' }
  if (!canKeep(session)) return { kind: 'not_ready' }
  if (!reviewOnly && session.step === 'keep') return { kind: 'done', ended: false }
  // The end time is never before the start time (the database checks it),
  // whatever the two clocks say. The start time can carry microseconds, so
  // one millisecond is added to it.
  const started = Date.parse(session.startedAt)
  const end = reviewOnly
    ? new Date(Number.isNaN(started) ? now.getTime() : Math.max(now.getTime(), started + 1)).toISOString()
    : null
  if (!(await review.finishKeep(sessionId, end))) return { kind: 'not_found' }
  return { kind: 'done', ended: reviewOnly }
}
