import type { Database } from '../src/lib/database.types.ts'
import type { NextReview } from '../src/lib/review-types.ts'
import type { RecordableStep, StepReached } from '../src/lib/session-types.ts'
import type { LearnerClient } from './learner-auth.ts'
import type { ReviewLineRow, ReviewMaterial } from './review-plan.ts'

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

/** One reviewable card from public.review_queue (job 9-daily-review). */
export interface QueueCard {
  formId: number
  reps: number
  due: string
}

/** The learner's own card for a form, as the scheduler needs it. Times are text. */
export interface CardRow {
  formId: number
  due: string
  stability: number
  difficulty: number
  elapsedDays: number
  scheduledDays: number
  reps: number
  lapses: number
  state: Database['public']['Enums']['card_state']
  lastReview: string | null
}

/** The arguments of public.record_review. */
export type RecordReviewArgs = Database['public']['Functions']['record_review']['Args']

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

/**
 * The reads and writes of the Keep it step (factory/jobs/9-daily-review/spec.md),
 * made with the learner's own token like every LearnerDb call. Kept apart from
 * LearnerDb so job 8's routes and their tests stay as they were.
 */
export interface ReviewDb {
  /** public.review_queue: the learner's reviewable cards, oldest due first, at most 15. */
  reviewQueue: (limit: number) => Promise<QueueCard[]>
  /** public.next_review_day: today's Helsinki date and the next review day, or null when there is none. */
  nextReviewDay: () => Promise<NextReview | null>
  /**
   * The approved lines of the given dialogues whose words link to any of the
   * forms, every word of those lines, and the readable forms those words link to.
   */
  reviewMaterial: (formIds: readonly number[], dialogueIds: readonly number[]) => Promise<ReviewMaterial>
  /** The learner's own card for a form, or null. */
  card: (formId: number) => Promise<CardRow | null>
  /** public.record_review, once, as the learner. False when the card changed since it was read. */
  recordReview: (args: RecordReviewArgs) => Promise<boolean>
  /** Adds one review only session (no dialogue), owned by the token's user. */
  startReviewSession: () => Promise<SessionRow>
  /**
   * Stores step_reached = 'keep' on an unfinished session, and its end time
   * when one is given. False when there is no such unfinished session.
   */
  finishKeep: (id: string, endedAt: string | null) => Promise<boolean>
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

export function supabaseLearnerDb(client: LearnerClient): LearnerDb & ReviewDb {
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

    async reviewQueue(limit) {
      const rows = must(await client.rpc('review_queue', { p_limit: limit }))
      return rows.map((row) => ({ formId: row.form_id, reps: row.reps, due: row.due }))
    },

    async nextReviewDay() {
      const rows = must(await client.rpc('next_review_day'))
      const row = rows[0]
      if (!row?.today || !row.next_day) return null
      return { today: row.today, day: row.next_day }
    },

    async reviewMaterial(formIds, dialogueIds) {
      const empty: ReviewMaterial = { lines: [], tokens: [], forms: [] }
      if (formIds.length === 0 || dialogueIds.length === 0) return empty
      const linking = must(
        await client
          .from('tokens')
          .select('line_id')
          .in('form_id', [...formIds]),
      )
      const candidateIds = [...new Set(linking.map((token) => token.line_id))]
      if (candidateIds.length === 0) return empty
      const lines = must(
        await client
          .from('dialogue_lines')
          .select(
            'id, dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key',
          )
          .in('id', candidateIds)
          .in('dialogue_id', [...dialogueIds]),
      )
      if (lines.length === 0) return empty
      const tokens = must(
        await client
          .from('tokens')
          .select('line_id, register, position, surface, form_id')
          .in(
            'line_id',
            lines.map((line) => line.id),
          ),
      )
      const linked = [...new Set(tokens.flatMap((token) => (token.form_id === null ? [] : [token.form_id])))]
      const forms =
        linked.length === 0
          ? []
          : must(
              await client
                .from('forms')
                .select('id, lemma, surface_kirja, surface_puhe, form_name_en, why_en')
                .in('id', linked),
            )
      return {
        // An approved line always has both texts, its meaning and both audio keys.
        lines: lines.map((line): ReviewLineRow => ({
          id: line.id,
          dialogueId: line.dialogue_id,
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

    async card(formId) {
      const result = await client
        .from('cards')
        .select(
          'form_id, due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review',
        )
        .eq('form_id', formId)
        .maybeSingle()
      if (result.error) throw new DatabaseUnavailable()
      const row = result.data
      if (!row) return null
      return {
        formId: row.form_id,
        due: row.due,
        stability: row.stability,
        difficulty: row.difficulty,
        elapsedDays: row.elapsed_days,
        scheduledDays: row.scheduled_days,
        reps: row.reps,
        lapses: row.lapses,
        state: row.state,
        lastReview: row.last_review,
      }
    },

    async recordReview(args) {
      const { data, error } = await client.rpc('record_review', args)
      if (error || typeof data !== 'boolean') throw new DatabaseUnavailable()
      return data
    },

    async startReviewSession() {
      return toSession(
        must(await client.from('sessions').insert({ dialogue_id: null }).select(SESSION_COLUMNS).single()),
      )
    },

    async finishKeep(id, endedAt) {
      const updated = must(
        await client
          .from('sessions')
          .update(endedAt === null ? { step_reached: 'keep' } : { step_reached: 'keep', ended_at: endedAt })
          .eq('id', id)
          .is('ended_at', null)
          .select('id'),
      )
      return updated.length === 1
    },
  }
}
