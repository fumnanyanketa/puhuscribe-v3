import { characterCount } from './reviewer-signup.ts'

// The private review links (fast route review-links,
// factory/jobs/review-links/spec.md). One set of rules, used by the review
// page before saving and by the Worker before it asks the database, which
// checks the same rules again (supabase/migrations/*_review_links.sql).

/** The page address of a link is /review/<secret>; a dialogue is /review/<secret>/<dialogue id>. */
export const REVIEW_PREFIX = '/review'

/**
 * The link's secret: 32 random bytes (256 bits) as base64url, 43 characters.
 * The database refuses any other shape, and a malformed secret gets the same
 * "This link does not work" as a wrong one.
 */
export const REVIEW_TOKEN = /^[A-Za-z0-9_-]{43}$/

export const REVIEW_ANSWERS = ['correct', 'needs_fix', 'not_sure'] as const
export type ReviewAnswer = (typeof REVIEW_ANSWERS)[number]

/** What each answer is called on the page, in the owner's words. */
export const ANSWER_LABELS: Record<ReviewAnswer, string> = {
  correct: 'Correct',
  needs_fix: 'Needs a fix',
  not_sure: 'Not sure',
}

/** The longest note, in characters as Postgres counts them. */
export const MAX_REVIEW_NOTE = 500

/** The batches: 4, of 27 dialogues each, batch 4 taking the rest (worked out by the database). */
export const REVIEW_BATCHES = [1, 2, 3, 4] as const

/** True when the text has the shape of a link secret. */
export function isReviewToken(value: unknown): value is string {
  return typeof value === 'string' && REVIEW_TOKEN.test(value)
}

/** Where a review page address points: the batch list, or one dialogue of it. */
export type ReviewPlace =
  | { kind: 'list'; token: string }
  | { kind: 'dialogue'; token: string; dialogueId: number }
  | { kind: 'broken' }

const DIALOGUE_ID = /^[1-9][0-9]{0,15}$/

/** Reads a page path under /review (no trailing slash). Anything odd is a broken link. */
export function reviewPlaceOf(path: string): ReviewPlace {
  if (!path.startsWith(`${REVIEW_PREFIX}/`)) return { kind: 'broken' }
  const parts = path.slice(REVIEW_PREFIX.length + 1).split('/')
  const token = parts[0]
  if (!isReviewToken(token) || parts.length > 2) return { kind: 'broken' }
  if (parts.length === 1) return { kind: 'list', token }
  const dialogue = parts[1] ?? ''
  if (!DIALOGUE_ID.test(dialogue)) return { kind: 'broken' }
  return { kind: 'dialogue', token, dialogueId: Number(dialogue) }
}

/** The page address of the batch list, or of one dialogue of it. */
export function reviewPagePath(token: string, dialogueId?: number): string {
  return dialogueId === undefined
    ? `${REVIEW_PREFIX}/${token}`
    : `${REVIEW_PREFIX}/${token}/${String(dialogueId)}`
}

// No control characters in a note, except a line break.
const CONTROL = /\p{Cc}/u

export interface ReviewAnswerInput {
  lineId: number
  answer: ReviewAnswer
  /** Only with needs_fix; null for none. */
  note: string | null
}

export type ReviewAnswerProblem = 'line' | 'answer' | 'note'

/** The note as it is saved: line breaks as \n, trimmed, empty as none, and none unless needs_fix. */
export function cleanNote(raw: unknown, answer: ReviewAnswer): string | null | undefined {
  if (raw === undefined || raw === null) return null
  if (typeof raw !== 'string') return undefined
  if (answer !== 'needs_fix') return null
  const note = raw.replace(/\r\n?/g, '\n').trim()
  if (note === '') return null
  if (characterCount(note) > MAX_REVIEW_NOTE || CONTROL.test(note.replace(/\n/g, ''))) return undefined
  return note
}

/** Checks one answer from the review page; the field that is wrong, or the clean answer. */
export function parseReviewAnswer(body: unknown): ReviewAnswerInput | { bad: ReviewAnswerProblem } {
  if (typeof body !== 'object' || body === null) return { bad: 'line' }
  const { lineId, answer, note } = body as Record<string, unknown>
  if (typeof lineId !== 'number' || !Number.isSafeInteger(lineId) || lineId < 1) return { bad: 'line' }
  if (typeof answer !== 'string' || !(REVIEW_ANSWERS as readonly string[]).includes(answer))
    return { bad: 'answer' }
  const clean = cleanNote(note, answer as ReviewAnswer)
  if (clean === undefined) return { bad: 'note' }
  return { lineId, answer: answer as ReviewAnswer, note: clean }
}

export type DialogueProgress = 'Not started' | 'In progress' | 'Done'

/** How far the reviewer got with one dialogue, in the owner's words. */
export function progressOf(answered: number, lines: number): DialogueProgress {
  if (answered <= 0) return 'Not started'
  return answered >= lines ? 'Done' : 'In progress'
}
