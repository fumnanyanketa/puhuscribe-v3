import type { ReviewItem, PromptWord } from '../src/lib/review-types.ts'
import type { SessionLine } from '../src/lib/session-types.ts'
import type { FormRow, LineRow, ReadableDialogue, SessionRow, TokenRow } from './learner-db.ts'
import { audioPath, sessionLines, splitLine } from './session-plan.ts'

// Which line each review card is asked in, and the items the browser gets
// (factory/jobs/9-daily-review/spec.md, "Done when" 3, 8 and 17).
//
// Every prompt is a line the learner met: an approved line in a dialogue where
// the learner has a session that reached at least Understand it. Everything is
// read with the learner's own token, so only approved content can be here.

const MET_STEPS = new Set(['understand', 'say', 'keep', 'use'])

/** Where a met dialogue sits, for the tie rule. */
export interface MetDialogue {
  unitPosition: number
  position: number
}

/** The readable dialogues the learner met: a session of theirs reached at least Understand it. */
export function metDialogues(
  dialogues: readonly ReadableDialogue[],
  sessions: readonly SessionRow[],
): Map<number, MetDialogue> {
  const met = new Set(
    sessions.flatMap((s) =>
      s.dialogueId !== null && s.step !== null && MET_STEPS.has(s.step) ? [s.dialogueId] : [],
    ),
  )
  return new Map(
    dialogues
      .filter((d) => met.has(d.id))
      .map((d) => [d.id, { unitPosition: d.unitPosition, position: d.position }]),
  )
}

/** A line of a met dialogue, with what the review needs of it. */
export interface ReviewLineRow extends LineRow {
  dialogueId: number
}

/** The lines that hold the queue's forms, every word of those lines, and their readable forms. */
export interface ReviewMaterial {
  lines: ReviewLineRow[]
  tokens: TokenRow[]
  forms: FormRow[]
}

export interface PickedLine {
  line: ReviewLineRow
  register: 'puhe' | 'kirja'
}

function wordsOf(tokens: readonly TokenRow[], lineId: number, register: 'puhe' | 'kirja'): TokenRow[] {
  return tokens
    .filter((t) => t.lineId === lineId && t.register === register)
    .sort((a, b) => a.position - b.position)
}

/** True when the line can be shown: both registers split into their words and both audio paths are safe. */
function usable(line: LineRow, tokens: readonly TokenRow[]): boolean {
  return (
    splitLine(line.textPuhe, wordsOf(tokens, line.id, 'puhe')) !== null &&
    splitLine(line.textKirja, wordsOf(tokens, line.id, 'kirja')) !== null &&
    audioPath(line.audioPuheKey) !== null &&
    audioPath(line.audioKirjaKey) !== null
  )
}

/**
 * The one rule (statement 3). Among the usable lines of met dialogues, a line
 * whose spoken words link to the form comes before one where only the written
 * words do; ties go to the lowest unit position, then dialogue position, then
 * line position. Null when the form is not readable or no line qualifies: the
 * card is then skipped (not shown, not graded, not changed).
 */
export function pickLine(
  formId: number,
  material: ReviewMaterial,
  met: ReadonlyMap<number, MetDialogue>,
): PickedLine | null {
  if (!material.forms.some((form) => form.id === formId)) return null
  const ranked = material.lines.flatMap((line) => {
    const where = met.get(line.dialogueId)
    if (!where) return []
    const links = (register: 'puhe' | 'kirja') =>
      material.tokens.some((t) => t.lineId === line.id && t.register === register && t.formId === formId)
    const register: PickedLine['register'] | null = links('puhe') ? 'puhe' : links('kirja') ? 'kirja' : null
    if (register === null || !usable(line, material.tokens)) return []
    return [{ line, register, where }]
  })
  ranked.sort(
    (a, b) =>
      Number(a.register === 'kirja') - Number(b.register === 'kirja') ||
      a.where.unitPosition - b.where.unitPosition ||
      a.where.position - b.where.position ||
      a.line.position - b.line.position,
  )
  const best = ranked[0]
  return best ? { line: best.line, register: best.register } : null
}

/**
 * The item the browser gets before answering: the line in the picked register,
 * every word linked to the form replaced by a gap. No form, no gapped word and
 * no text of the other register is in it.
 */
export function reviewItem(
  formId: number,
  picked: PickedLine,
  tokens: readonly TokenRow[],
): ReviewItem | null {
  const { line, register } = picked
  const own = wordsOf(tokens, line.id, register)
  const split = splitLine(register === 'puhe' ? line.textPuhe : line.textKirja, own)
  const audio = audioPath(register === 'puhe' ? line.audioPuheKey : line.audioKirjaKey)
  if (!split || !audio) return null
  const words = split.map((word, i): PromptWord => {
    const punctuation = {
      ...(word.before ? { before: word.before } : {}),
      ...(word.after ? { after: word.after } : {}),
    }
    return own[i]?.formId === formId ? { gap: true, ...punctuation } : { text: word.text, ...punctuation }
  })
  return {
    formId,
    speaker: line.speaker,
    gloss: line.gloss,
    register: register === 'puhe' ? 'spoken' : 'written',
    audio,
    words,
  }
}

/** The whole line after answering, both registers with their word cards, and which words are the answer. */
export function feedbackLine(
  formId: number,
  picked: PickedLine,
  material: ReviewMaterial,
): { line: SessionLine; marked: { spoken: number[]; written: number[] } } | null {
  const tokens = material.tokens.filter((t) => t.lineId === picked.line.id)
  const formIds = new Set(tokens.flatMap((t) => (t.formId === null ? [] : [t.formId])))
  const [line] = sessionLines({
    lines: [picked.line],
    tokens,
    forms: material.forms.filter((form) => formIds.has(form.id)),
  })
  if (!line) return null
  const marked = (register: 'puhe' | 'kirja') =>
    wordsOf(tokens, picked.line.id, register).flatMap((t, i) => (t.formId === formId ? [i] : []))
  return { line, marked: { spoken: marked('puhe'), written: marked('kirja') } }
}
