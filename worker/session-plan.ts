import type {
  FrontDoorState,
  ReadySession,
  SessionLine,
  SessionWord,
  WordForm,
} from '../src/lib/session-types.ts'
import type { DialogueContent, LearnerDb, ReadableDialogue, SessionRow, TokenRow } from './learner-db.ts'

// Which dialogue is today's, and the session screen's content
// (factory/jobs/8-first-session/spec.md, "Done when" 6, 7, 9 and 12).

/** A line whose words cannot be found in its text, in order. */
export class ContentUnusable extends Error {
  readonly lineId: number
  constructor(lineId: number) {
    super(`Line ${String(lineId)} cannot be split into its words.`)
    this.name = 'ContentUnusable'
    this.lineId = lineId
  }
}

export type TodayPick =
  | { kind: 'not_ready' }
  | { kind: 'all_done' }
  | { kind: 'dialogue'; dialogue: ReadableDialogue; open: SessionRow | null }

/**
 * The one rule. Today's dialogue is the first readable dialogue (lowest unit
 * position, then lowest dialogue position) the learner has not finished. A
 * session is finished when it has its end time. An unfinished session for that
 * dialogue is reused (the newest, if there are several).
 */
export function pickToday(
  dialogues: readonly ReadableDialogue[],
  sessions: readonly SessionRow[],
): TodayPick {
  if (dialogues.length === 0) return { kind: 'not_ready' }
  const finished = new Set(
    sessions.flatMap((s) => (s.endedAt !== null && s.dialogueId !== null ? [s.dialogueId] : [])),
  )
  const ordered = [...dialogues].sort((a, b) => a.unitPosition - b.unitPosition || a.position - b.position)
  const dialogue = ordered.find((d) => !finished.has(d.id))
  if (!dialogue) return { kind: 'all_done' }
  const open =
    sessions
      .filter((s) => s.dialogueId === dialogue.id && s.endedAt === null)
      .sort((a, b) => b.startedAt.localeCompare(a.startedAt))[0] ?? null
  return { kind: 'dialogue', dialogue, open }
}

export async function todayFor(db: LearnerDb): Promise<TodayPick> {
  const [dialogues, sessions] = await Promise.all([db.readableDialogues(), db.mySessions()])
  return pickToday(dialogues, sessions)
}

export function frontDoorState(pick: TodayPick): FrontDoorState {
  if (pick.kind !== 'dialogue') return pick.kind
  return pick.open ? 'continue' : 'start'
}

const HAS_LETTER_OR_DIGIT = /[\p{L}\p{N}]/u

/**
 * Splits a line's text into its words by finding each word's text in order.
 * What lies between two words may only be spaces and punctuation; it is kept
 * with the word before it. Returns null when the line cannot be split, so a
 * half-built line is never shown.
 */
export function splitLine(
  text: string,
  words: readonly { surface: string; form?: WordForm }[],
): SessionWord[] | null {
  if (words.length === 0) return null
  const out: SessionWord[] = []
  let cursor = 0
  for (const word of words) {
    const at = text.indexOf(word.surface, cursor)
    if (at < 0) return null
    const gap = text.slice(cursor, at).trim()
    if (HAS_LETTER_OR_DIGIT.test(gap)) return null
    const previous = out[out.length - 1]
    if (previous) {
      if (gap) previous.after = gap
    } else if (gap) {
      out.push({ text: word.surface, before: gap, ...(word.form ? { form: word.form } : {}) })
      cursor = at + word.surface.length
      continue
    }
    out.push({ text: word.surface, ...(word.form ? { form: word.form } : {}) })
    cursor = at + word.surface.length
  }
  const rest = text.slice(cursor).trim()
  if (HAS_LETTER_OR_DIGIT.test(rest)) return null
  const last = out[out.length - 1]
  if (last && rest) last.after = rest
  return out
}

const SAFE_KEY = /^[A-Za-z0-9][A-Za-z0-9._-]*(\/[A-Za-z0-9][A-Za-z0-9._-]*)*$/

/**
 * The same address path of a line's audio file: /audio/<key>. Job 7 copies the
 * file of every approved line there (manager addendum: no audio route). A key
 * that could leave the /audio/ folder is refused.
 */
export function audioPath(key: string): string | null {
  if (!SAFE_KEY.test(key) || key.split('/').some((part) => part === '..' || part === '.')) return null
  return `/audio/${key.split('/').map(encodeURIComponent).join('/')}`
}

function wordsOf(
  tokens: readonly TokenRow[],
  lineId: number,
  register: 'puhe' | 'kirja',
  forms: Map<number, WordForm>,
) {
  return tokens
    .filter((t) => t.lineId === lineId && t.register === register)
    .sort((a, b) => a.position - b.position)
    .map((t) => {
      // A form the learner cannot read is not returned by the database, so
      // its word stays plain text.
      const form = t.formId === null ? undefined : forms.get(t.formId)
      return form ? { surface: t.surface, form } : { surface: t.surface }
    })
}

export function sessionLines(content: DialogueContent): SessionLine[] {
  const forms = new Map<number, WordForm>(
    content.forms.map((f) => [
      f.id,
      { lemma: f.lemma, formName: f.formName, why: f.why, spoken: f.surfacePuhe, written: f.surfaceKirja },
    ]),
  )
  return [...content.lines]
    .sort((a, b) => a.position - b.position)
    .map((line) => {
      const spoken = splitLine(line.textPuhe, wordsOf(content.tokens, line.id, 'puhe', forms))
      const written = splitLine(line.textKirja, wordsOf(content.tokens, line.id, 'kirja', forms))
      const spokenAudio = audioPath(line.audioPuheKey)
      const writtenAudio = audioPath(line.audioKirjaKey)
      if (!spoken || !written || !spokenAudio || !writtenAudio) throw new ContentUnusable(line.id)
      return {
        id: line.id,
        speaker: line.speaker,
        gloss: line.gloss,
        spokenAudio,
        writtenAudio,
        spoken,
        written,
      }
    })
}

export async function readySession(
  db: LearnerDb,
  dialogue: ReadableDialogue,
  session: SessionRow,
): Promise<ReadySession> {
  const lines = sessionLines(await db.dialogueContent(dialogue.id))
  if (lines.length === 0) throw new ContentUnusable(0)
  return {
    state: 'ready',
    session: { id: session.id, step: session.step },
    unit: { title: dialogue.unitTitle, canDo: dialogue.canDo },
    dialogue: { title: dialogue.title },
    lines,
  }
}
