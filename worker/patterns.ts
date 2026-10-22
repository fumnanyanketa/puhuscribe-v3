import type { PatternForm, PatternGroup, PatternsAnswer } from '../src/lib/patterns-types.ts'
import type { LearnerClient } from './learner-auth.ts'
import {
  DatabaseUnavailable,
  supabaseLearnerDb,
  type FormRow,
  type ReadableDialogue,
  type SessionRow,
} from './learner-db.ts'
import { audioPath } from './session-plan.ts'

// The "Patterns you've seen" panel's data, GET /api/patterns
// (factory/jobs/12-units-1-3/spec.md, "Done when" 11, 12 and 14).
//
// Every read is made with the learner's own token, so the database's existing
// rules (jobs 3 and 8) decide what comes back: only approved units, dialogues,
// lines and forms, and only the learner's own sessions and cards. Nothing is
// written. The routes use the PatternsDb interface, so unit tests use a fake.
//
// Which forms: the approved forms the learner has a card for, plus the
// approved forms of the session they are in. Which line: the earliest line,
// by unit, dialogue and line position, of a dialogue they finished
// Understand it in, or of the current session's dialogue.

export interface PatternLineRow {
  id: number
  dialogueId: number
  position: number
  textPuhe: string
  textKirja: string
  audioPuheKey: string
  audioKirjaKey: string
}

export interface PatternTokenRow {
  lineId: number
  formId: number
}

export interface PatternsDb {
  /** Every dialogue the learner can read, with its unit. */
  readableDialogues: () => Promise<ReadableDialogue[]>
  /** The learner's own sessions. */
  mySessions: () => Promise<SessionRow[]>
  /** The form ids of the learner's own cards, and nothing else of the card. */
  cardFormIds: () => Promise<number[]>
  /** The readable lines of these dialogues. */
  lines: (dialogueIds: readonly number[]) => Promise<PatternLineRow[]>
  /** The words of these lines that have a form. */
  tokens: (lineIds: readonly number[]) => Promise<PatternTokenRow[]>
  /** These forms, as far as the learner may read them (approved only). */
  forms: (formIds: readonly number[]) => Promise<FormRow[]>
}

const LOOP_ORDER = ['hear', 'understand', 'say', 'keep', 'use'] as const

/** True when the session has finished Understand it. */
export function finishedUnderstand(session: SessionRow): boolean {
  return session.step !== null && LOOP_ORDER.indexOf(session.step) >= LOOP_ORDER.indexOf('understand')
}

export interface PatternsInput {
  dialogues: readonly ReadableDialogue[]
  sessions: readonly SessionRow[]
  currentSessionId: string | null
  cardFormIds: readonly number[]
  lines: readonly PatternLineRow[]
  tokens: readonly PatternTokenRow[]
  forms: readonly FormRow[]
}

/** The sessions whose dialogue counts as met, and the current session, if it is the learner's. */
export function metSessions(
  sessions: readonly SessionRow[],
  currentSessionId: string | null,
): { met: SessionRow[]; current: SessionRow | null } {
  const current =
    currentSessionId === null
      ? null
      : (sessions.find((s) => s.id === currentSessionId && s.dialogueId !== null) ?? null)
  const met = sessions.filter((s) => s.dialogueId !== null && (finishedUnderstand(s) || s === current))
  return { met, current }
}

/** The forms whose cards or current dialogue put them in the panel. */
export function formIdsToShow(
  cardFormIds: readonly number[],
  current: SessionRow | null,
  lines: readonly PatternLineRow[],
  tokens: readonly PatternTokenRow[],
): number[] {
  const ids = new Set(cardFormIds)
  if (current) {
    const currentLines = new Set(lines.filter((l) => l.dialogueId === current.dialogueId).map((l) => l.id))
    for (const token of tokens) if (currentLines.has(token.lineId)) ids.add(token.formId)
  }
  return [...ids].sort((a, b) => a - b)
}

function compareText(a: string, b: string): number {
  return a < b ? -1 : a > b ? 1 : 0
}

/**
 * Builds the panel's groups (statement 12). Groups are ordered by when the
 * learner first met a form of that pattern, oldest first; forms inside a group
 * the same way; ties by base form. "First met" is the start of the learner's
 * earliest met session whose dialogue has the form in a line.
 */
export function buildPatterns(input: PatternsInput): PatternsAnswer {
  const { met, current } = metSessions(input.sessions, input.currentSessionId)
  const dialogues = new Map(input.dialogues.map((d) => [d.id, d]))
  const metDialogues = new Set(
    met.flatMap((s) => (s.dialogueId !== null && dialogues.has(s.dialogueId) ? [s.dialogueId] : [])),
  )
  const lines = input.lines.filter((l) => metDialogues.has(l.dialogueId))
  const lineById = new Map(lines.map((l) => [l.id, l]))
  const wanted = new Set(formIdsToShow(input.cardFormIds, current, lines, input.tokens))

  // Where each form appears, among the met dialogues' lines.
  const linesOfForm = new Map<number, PatternLineRow[]>()
  for (const token of input.tokens) {
    const line = lineById.get(token.lineId)
    if (!line || !wanted.has(token.formId)) continue
    const list = linesOfForm.get(token.formId) ?? []
    if (!list.includes(line)) list.push(line)
    linesOfForm.set(token.formId, list)
  }

  const order = (line: PatternLineRow): [number, number, number] => {
    const dialogue = dialogues.get(line.dialogueId)
    return [dialogue?.unitPosition ?? 0, dialogue?.position ?? 0, line.position]
  }
  const firstStart = new Map<number, string>()
  for (const session of met) {
    if (session.dialogueId === null) continue
    const start = firstStart.get(session.dialogueId)
    if (start === undefined || session.startedAt < start)
      firstStart.set(session.dialogueId, session.startedAt)
  }

  interface Entry {
    form: PatternForm
    formName: string
    firstMet: string
  }
  const entries: Entry[] = []
  for (const form of input.forms) {
    if (!wanted.has(form.id)) continue
    const found = linesOfForm.get(form.id) ?? []
    const earliest = [...found].sort((a, b) => {
      const [ua, da, la] = order(a)
      const [ub, db, lb] = order(b)
      return ua - ub || da - db || la - lb
    })[0]
    if (!earliest) continue
    const spokenAudio = audioPath(earliest.audioPuheKey)
    const writtenAudio = audioPath(earliest.audioKirjaKey)
    if (!spokenAudio || !writtenAudio) continue
    const starts = found.flatMap((l) => {
      const start = firstStart.get(l.dialogueId)
      return start === undefined ? [] : [start]
    })
    const firstMet = starts.sort(compareText)[0] ?? ''
    entries.push({
      formName: form.formName,
      firstMet,
      form: {
        lemma: form.lemma,
        spoken: form.surfacePuhe,
        written: form.surfaceKirja,
        why: form.why,
        line: {
          spoken: earliest.textPuhe,
          written: earliest.textKirja,
          spokenAudio,
          writtenAudio,
        },
      },
    })
  }

  entries.sort(
    (a, b) =>
      compareText(a.firstMet, b.firstMet) ||
      compareText(a.form.lemma, b.form.lemma) ||
      compareText(a.form.written, b.form.written) ||
      compareText(a.form.spoken, b.form.spoken),
  )
  const groups: PatternGroup[] = []
  const byName = new Map<string, PatternGroup>()
  for (const entry of entries) {
    let group = byName.get(entry.formName)
    if (!group) {
      group = { formName: entry.formName, forms: [] }
      byName.set(entry.formName, group)
      groups.push(group)
    }
    group.forms.push(entry.form)
  }
  return { groups }
}

/** Reads everything the panel needs, in four rounds of reads, and builds it. */
export async function patternsFor(db: PatternsDb, currentSessionId: string | null): Promise<PatternsAnswer> {
  const [dialogues, sessions, cardFormIds] = await Promise.all([
    db.readableDialogues(),
    db.mySessions(),
    db.cardFormIds(),
  ])
  const { met } = metSessions(sessions, currentSessionId)
  const readable = new Set(dialogues.map((d) => d.id))
  const dialogueIds = [
    ...new Set(
      met.flatMap((s) => (s.dialogueId !== null && readable.has(s.dialogueId) ? [s.dialogueId] : [])),
    ),
  ]
  const lines = dialogueIds.length === 0 ? [] : await db.lines(dialogueIds)
  const tokens = lines.length === 0 ? [] : await db.tokens(lines.map((l) => l.id))
  const { current } = metSessions(sessions, currentSessionId)
  const formIds = formIdsToShow(cardFormIds, current, lines, tokens)
  const forms = formIds.length === 0 ? [] : await db.forms(formIds)
  return buildPatterns({ dialogues, sessions, currentSessionId, cardFormIds, lines, tokens, forms })
}

function must<T>(result: { data: T | null; error: unknown }): T {
  if (result.error || result.data === null) throw new DatabaseUnavailable()
  return result.data
}

export function supabasePatternsDb(client: LearnerClient): PatternsDb {
  const learner = supabaseLearnerDb(client)
  return {
    readableDialogues: learner.readableDialogues,
    mySessions: learner.mySessions,

    async cardFormIds() {
      return must(await client.from('cards').select('form_id')).map((row) => row.form_id)
    },

    async lines(dialogueIds) {
      const rows = must(
        await client
          .from('dialogue_lines')
          .select('id, dialogue_id, position, text_puhe, text_kirja, audio_puhe_key, audio_kirja_key')
          .in('dialogue_id', [...dialogueIds])
          .eq('status', 'approved'),
      )
      // An approved line always has both texts and both audio keys.
      return rows.map((line) => ({
        id: line.id,
        dialogueId: line.dialogue_id,
        position: line.position,
        textPuhe: line.text_puhe ?? '',
        textKirja: line.text_kirja ?? '',
        audioPuheKey: line.audio_puhe_key ?? '',
        audioKirjaKey: line.audio_kirja_key ?? '',
      }))
    },

    async tokens(lineIds) {
      const rows = must(
        await client
          .from('tokens')
          .select('line_id, form_id')
          .in('line_id', [...lineIds])
          .not('form_id', 'is', null),
      )
      return rows.map((row) => ({ lineId: row.line_id, formId: row.form_id }))
    },

    async forms(formIds) {
      const rows = must(
        await client
          .from('forms')
          .select('id, lemma, surface_kirja, surface_puhe, form_name_en, why_en')
          .in('id', [...formIds])
          .eq('status', 'approved'),
      )
      return rows.map((form) => ({
        id: form.id,
        lemma: form.lemma,
        formName: form.form_name_en ?? '',
        why: form.why_en ?? '',
        surfacePuhe: form.surface_puhe,
        surfaceKirja: form.surface_kirja,
      }))
    },
  }
}
