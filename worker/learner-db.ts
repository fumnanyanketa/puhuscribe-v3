import type { RecordableStep, StepReached } from '../src/lib/session-types.ts'
import type { LearnerClient } from './learner-auth.ts'

// Every database read and write of the first session loop, made with the
// learner's own token (factory/jobs/8-first-session/spec.md, "Done when" 6, 7
// and 15). The database's access rules (jobs 3 and 8) decide what each call
// sees: only approved content with approved parents, and only the learner's
// own sessions. The user id is never sent: the database takes it from the token.
//
// The routes use the LearnerDb interface, so their unit tests can use a fake.

export class DatabaseUnavailable extends Error {
  constructor() {
    super('The database did not answer as expected.')
    this.name = 'DatabaseUnavailable'
  }
}

export interface ReadableDialogue {
  id: number
  position: number
  title: string
  unitPosition: number
  unitTitle: string
  canDo: string
}

export interface SessionRow {
  id: string
  dialogueId: number | null
  step: StepReached
  startedAt: string
  endedAt: string | null
}

export interface LineRow {
  id: number
  position: number
  speaker: string
  textPuhe: string
  textKirja: string
  gloss: string
  audioPuheKey: string
  audioKirjaKey: string
}

export interface TokenRow {
  lineId: number
  register: 'puhe' | 'kirja'
  position: number
  surface: string
  formId: number | null
}

export interface FormRow {
  id: number
  lemma: string
  formName: string
  why: string
  surfacePuhe: string
  surfaceKirja: string
}

export interface DialogueContent {
  lines: LineRow[]
  tokens: TokenRow[]
  forms: FormRow[]
}

export type CompleteResult = 'saved' | 'not_found' | 'not_ready'

export interface LearnerDb {
  /** Every dialogue the learner can read, with its unit. */
  readableDialogues: () => Promise<ReadableDialogue[]>
  /** The learner's own sessions. */
  mySessions: () => Promise<SessionRow[]>
  /** Adds one session for the dialogue, owned by the token's user. */
  startSession: (dialogueId: number) => Promise<SessionRow>
  /** The lines, words and forms of a dialogue, as far as the learner may read them. */
  dialogueContent: (dialogueId: number) => Promise<DialogueContent>
  /** One of the learner's own sessions, or null. */
  session: (id: string) => Promise<SessionRow | null>
  /** Moves an unfinished session's step forward. False when no such session. */
  setStep: (id: string, step: RecordableStep) => Promise<boolean>
  /** public.complete_session, once, as the learner. */
  completeSession: (id: string) => Promise<CompleteResult>
}

const SESSION_COLUMNS = 'id, dialogue_id, step_reached, started_at, ended_at'

interface SessionRecord {
  id: string
  dialogue_id: number | null
  step_reached: StepReached
  started_at: string
  ended_at: string | null
}

function toSession(row: SessionRecord): SessionRow {
  return {
    id: row.id,
    dialogueId: row.dialogue_id,
    step: row.step_reached,
    startedAt: row.started_at,
    endedAt: row.ended_at,
  }
}

function must<T>(result: { data: T | null; error: unknown }): T {
  if (result.error || result.data === null) throw new DatabaseUnavailable()
  return result.data
}

export function supabaseLearnerDb(client: LearnerClient): LearnerDb {
  return {
    async readableDialogues() {
      const units = must(await client.from('units').select('id, position, title_en, can_do_en'))
      const dialogues = must(await client.from('dialogues').select('id, unit_id, position, title_en'))
      const byId = new Map(units.map((unit) => [unit.id, unit]))
      return dialogues.flatMap((dialogue) => {
        const unit = byId.get(dialogue.unit_id)
        if (!unit) return []
        return [
          {
            id: dialogue.id,
            position: dialogue.position,
            title: dialogue.title_en,
            unitPosition: unit.position,
            unitTitle: unit.title_en,
            canDo: unit.can_do_en,
          },
        ]
      })
    },

    async mySessions() {
      return must(await client.from('sessions').select(SESSION_COLUMNS)).map(toSession)
    },

    async startSession(dialogueId) {
      return toSession(
        must(
          await client.from('sessions').insert({ dialogue_id: dialogueId }).select(SESSION_COLUMNS).single(),
        ),
      )
    },

    async dialogueContent(dialogueId) {
      const lines = must(
        await client
          .from('dialogue_lines')
          .select('id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key')
          .eq('dialogue_id', dialogueId)
          .order('position'),
      )
      const lineIds = lines.map((line) => line.id)
      const tokens =
        lineIds.length === 0
          ? []
          : must(
              await client
                .from('tokens')
                .select('line_id, register, position, surface, form_id')
                .in('line_id', lineIds)
                .order('line_id')
                .order('register')
                .order('position'),
            )
      const formIds = [...new Set(tokens.flatMap((token) => (token.form_id === null ? [] : [token.form_id])))]
      const forms =
        formIds.length === 0
          ? []
          : must(
              await client
                .from('forms')
                .select('id, lemma, surface_kirja, surface_puhe, form_name_en, why_en')
                .in('id', formIds),
            )
      return {
        // An approved line always has both texts, its meaning and both audio
        // keys (the database refuses to approve it otherwise).
        lines: lines.map((line) => ({
          id: line.id,
          position: line.position,
          speaker: line.speaker,
          textPuhe: line.text_puhe ?? '',
          textKirja: line.text_kirja ?? '',
          gloss: line.gloss_en ?? '',
          audioPuheKey: line.audio_puhe_key ?? '',
          audioKirjaKey: line.audio_kirja_key ?? '',
        })),
        tokens: tokens.map((token) => ({
          lineId: token.line_id,
          register: token.register,
          position: token.position,
          surface: token.surface,
          formId: token.form_id,
        })),
        forms: forms.map((form) => ({
          id: form.id,
          lemma: form.lemma,
          formName: form.form_name_en ?? '',
          why: form.why_en ?? '',
          surfacePuhe: form.surface_puhe,
          surfaceKirja: form.surface_kirja,
        })),
      }
    },

    async session(id) {
      const result = await client.from('sessions').select(SESSION_COLUMNS).eq('id', id).maybeSingle()
      if (result.error) throw new DatabaseUnavailable()
      return result.data ? toSession(result.data) : null
    },

    async setStep(id, step) {
      const updated = must(
        await client
          .from('sessions')
          .update({ step_reached: step })
          .eq('id', id)
          .is('ended_at', null)
          .select('id'),
      )
      return updated.length === 1
    },

    async completeSession(id) {
      const { error } = await client.rpc('complete_session', { session_id: id })
      if (!error) return 'saved'
      if (error.code === 'P0002') return 'not_found'
      if (error.code === '22023') return 'not_ready'
      throw new DatabaseUnavailable()
    },
  }
}
