import { MAX_REVIEW_RUN } from '../src/lib/review-types.ts'
import type {
  PracticeAnswer,
  PracticeKeepItem,
  PracticeLesson,
  PracticeListAnswer,
} from '../src/lib/practice-types.ts'
import type { ReadySession } from '../src/lib/session-types.ts'
import { json, refuseNonGet, withCookies } from './http.ts'
import type { LearnerContext } from './learner-auth.ts'
import type { LearnerDb, LessonFactsDb, ReadableDialogue, SessionRow } from './learner-db.ts'
import { feedbackLine, pickLine, reviewItem, type ReviewMaterial } from './review-plan.ts'
import { ContentUnusable, keyLinesOf, sessionLines } from './session-plan.ts'

// Practice replays (owner's fast route "go-back", 3 November 2026): a learner plays a lesson they have
// already finished again, as practice.
//
// GET /api/practice: every lesson on the road the learner has finished (a session of theirs for it has
// ended), with its stop and its place in the stop.
// GET /api/practice?dialogue=<id>: that lesson as the session screens show it, with Keep it's items and
// their answers. Only a lesson the learner has finished can be asked for; any other is 404.
//
// Both only read, with the learner's own token, so the database's read rules decide what is seen
// (approved content only, the learner's own sessions and cards). Nothing is written: no session is
// made, no step is stored, nothing is finished and no card changes. The session id in the answer is
// the learner's own finished session for the lesson, which the speaking feedback check of a practice
// line names (worker/speech.ts, "practice"). Nothing here is logged.

export interface PracticeKit {
  signedIn: (
    request: Request,
  ) => Promise<
    { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
  >
  learnerDb: (context: LearnerContext) => LearnerDb
  factsDb: (context: LearnerContext, db: LearnerDb) => LessonFactsDb
}

/** The road's dialogues in road order: by stop, then unit, then dialogue position. */
function roadOrder(dialogues: readonly ReadableDialogue[]): (ReadableDialogue & { stopNumber: number })[] {
  return dialogues
    .flatMap((d) => (typeof d.stopNumber === 'number' ? [{ ...d, stopNumber: d.stopNumber }] : []))
    .sort(
      (a, b) =>
        a.stopNumber - b.stopNumber ||
        a.unitPosition - b.unitPosition ||
        a.position - b.position ||
        a.id - b.id,
    )
}

/** The learner's newest finished session for each dialogue. */
function finishedSessions(sessions: readonly SessionRow[]): Map<number, SessionRow> {
  const found = new Map<number, SessionRow>()
  for (const session of sessions) {
    if (session.dialogueId === null || session.endedAt === null) continue
    const known = found.get(session.dialogueId)
    if (!known || (known.endedAt ?? '') < session.endedAt) found.set(session.dialogueId, session)
  }
  return found
}

/** Every finished lesson on the road, in road order, with its place in its stop. */
export function practiceLessons(
  dialogues: readonly ReadableDialogue[],
  sessions: readonly SessionRow[],
): PracticeLesson[] {
  const finished = finishedSessions(sessions)
  const places = new Map<number, number>()
  return roadOrder(dialogues).flatMap((d) => {
    const lesson = (places.get(d.stopNumber) ?? 0) + 1
    places.set(d.stopNumber, lesson)
    return finished.has(d.id) ? [{ dialogueId: d.id, stop: d.stopNumber, lesson, title: d.title }] : []
  })
}

/**
 * Keep it's items for one lesson: the lesson's words that are in the learner's review (they met them
 * when they finished it), in order of first appearance, at most 15, each asked in a line of this lesson
 * by job 9's rule, with its answer.
 */
export function practiceKeepItems(
  dialogue: ReadableDialogue,
  material: ReviewMaterial,
  cardFormIds: readonly number[],
): PracticeKeepItem[] {
  const cards = new Set(cardFormIds)
  const met = new Map([[dialogue.id, { unitPosition: dialogue.unitPosition, position: dialogue.position }]])
  const lineOrder = new Map(material.lines.map((line) => [line.id, line.position]))
  const ordered = [...material.tokens].sort(
    (a, b) =>
      (lineOrder.get(a.lineId) ?? 0) - (lineOrder.get(b.lineId) ?? 0) ||
      Number(a.register === 'kirja') - Number(b.register === 'kirja') ||
      a.position - b.position,
  )
  const formIds = [
    ...new Set(ordered.flatMap((t) => (t.formId !== null && cards.has(t.formId) ? [t.formId] : []))),
  ]
  const items: PracticeKeepItem[] = []
  for (const formId of formIds) {
    if (items.length >= MAX_REVIEW_RUN) break
    const picked = pickLine(formId, material, met)
    const form = material.forms.find((f) => f.id === formId)
    const item = picked && reviewItem(formId, picked, material.tokens)
    const shown = picked && feedbackLine(formId, picked, material)
    if (!item || !shown || !form) continue
    items.push({
      item,
      answer: {
        line: shown.line,
        marked: shown.marked,
        form: { spoken: form.surfacePuhe, written: form.surfaceKirja },
      },
    })
  }
  return items
}

const DIALOGUE_ID = /^[1-9][0-9]{0,8}$/

/** GET /api/practice and GET /api/practice?dialogue=<id>. */
export async function practiceRoute(request: Request, kit: PracticeKit): Promise<Response> {
  const refusedMethod = await refuseNonGet(request)
  if (refusedMethod) return refusedMethod
  const asked = new URL(request.url).searchParams.get('dialogue')
  if (asked !== null && !DIALOGUE_ID.test(asked)) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const db = kit.learnerDb(context)
    const [dialogues, sessions] = await Promise.all([db.readableDialogues(), db.mySessions()])
    if (asked === null) {
      const answer: PracticeListAnswer = { lessons: practiceLessons(dialogues, sessions) }
      return done(answer)
    }
    const dialogue = dialogues.find((d) => d.id === Number(asked))
    const session = dialogue && finishedSessions(sessions).get(dialogue.id)
    if (!dialogue || !session) return done({ error: 'not_found' }, 404)
    const content = await db.dialogueContent(dialogue.id)
    const lines = sessionLines(content)
    if (lines.length === 0) throw new ContentUnusable(0)
    // Every form counts as new for the recap, so it takes the lines with the most words, as a first
    // visit to the lesson would have (worker/session-plan.ts keyLinesOf).
    const ready: ReadySession = {
      state: 'ready',
      session: { id: session.id, step: session.step },
      unit: { title: dialogue.unitTitle, canDo: dialogue.canDo },
      dialogue: { title: dialogue.title },
      lines,
      keyLines: keyLinesOf(content, []),
    }
    // Keep it is optional: when the learner's cards cannot be read, the replay has no Keep it.
    let keep: PracticeKeepItem[] = []
    try {
      const cards = await kit.factsDb(context, db).cardFormIds()
      keep = practiceKeepItems(
        dialogue,
        {
          lines: content.lines.map((line) => ({ ...line, dialogueId: dialogue.id })),
          tokens: content.tokens,
          forms: content.forms,
        },
        cards,
      )
    } catch {
      // The replay without Keep it.
    }
    const answer: PracticeAnswer = { session: ready, keep }
    return done(answer)
  } catch (error) {
    if (error instanceof ContentUnusable) return done({ error: 'content_unusable' }, 500)
    return done({ error: 'not_available' }, 503)
  }
}
