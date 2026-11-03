import { TUTOR_NOTICE_VERSION } from '../src/lib/tutor-consent.ts'
import type { TutorConsent } from '../src/lib/tutor-types.ts'
import type { LearnerClient } from './learner-auth.ts'
import {
  DatabaseUnavailable,
  supabaseLearnerDb,
  type FormRow,
  type ReadableDialogue,
  type SessionRow,
} from './learner-db.ts'
import { readAll, readAllIn } from './paging.ts'

// Every database read and write of the tutor step (factory/jobs/16-tutor-step/spec.md), made with
// the learner's own token, so the database's rules decide what comes back: only approved content,
// and only the learner's own sessions, cards, consents and tutor calls. Nothing here stores text.
// The routes use the TutorDb interface, so unit tests can use a fake.

export interface TutorLineRow {
  id: number
  dialogueId: number
  position: number
  speaker: string
  spoken: string
  written: string
  gloss: string
  audioPuheKey: string
  audioKirjaKey: string
}

export interface TutorTokenRow {
  lineId: number
  register: 'puhe' | 'kirja'
  position: number
  surface: string
  formId: number | null
}

/** What the outcome of one call is, written into its reserved row. */
export interface CallResult {
  outcome: 'served' | 'failed_check' | 'provider_error'
  provider: string
  model: string
  inputTokens: number
  outputTokens: number
  costUsd: number
}

export interface TutorConsents {
  tutor: TutorConsent
  /** The newest voice_processing row is a grant, with its consent text's version label. */
  voice: { granted: boolean; version: string } | null
}

export interface TutorDb {
  consents: () => Promise<TutorConsents>
  addTutorConsent: (granted: boolean, version: string) => Promise<void>
  /** True when the account is a guest (an anonymous sign in). */
  isGuest: () => Promise<boolean>
  /** public.tutor_allowance(): an exchange could start now. */
  allowance: () => Promise<boolean>
  /** public.reserve_tutor_call(): the reserved row's id, or null when a rule or cap refused. */
  reserve: (sessionId: string, turn: number, attempt: number) => Promise<string | null>
  /** Fills in a reserved row. A failure here is ignored by the caller: the slot is already counted. */
  finish: (callId: string, result: CallResult) => Promise<void>
  readableDialogues: () => Promise<ReadableDialogue[]>
  mySessions: () => Promise<SessionRow[]>
  session: (id: string) => Promise<SessionRow | null>
  cardFormIds: () => Promise<number[]>
  lines: (dialogueIds: readonly number[]) => Promise<TutorLineRow[]>
  tokens: (lineIds: readonly number[]) => Promise<TutorTokenRow[]>
  forms: (formIds: readonly number[]) => Promise<FormRow[]>
}

const unavailable = (): Error => new DatabaseUnavailable()

function present(text: string | null): string | undefined {
  const trimmed = text?.trim() ?? ''
  return trimmed === '' ? undefined : trimmed
}

export function supabaseTutorDb(client: LearnerClient): TutorDb {
  const learner = supabaseLearnerDb(client)
  return {
    async consents() {
      const result = await client
        .from('consents')
        .select('kind, granted, notice_version, created_at')
        .in('kind', ['ai_tutor', 'voice_processing'])
        .order('created_at', { ascending: false })
        .limit(200)
      if (result.error) throw new DatabaseUnavailable()
      const rows = result.data
      const tutor = rows.find((row) => row.kind === 'ai_tutor')
      const voice = rows.find((row) => row.kind === 'voice_processing')
      return {
        // A grant given under an older consent text counts as not asked, so the learner sees the
        // current text once (owner, 3 November 2026: the text now says chat text is sent as typed).
        tutor: tutor
          ? tutor.granted
            ? tutor.notice_version === TUTOR_NOTICE_VERSION
              ? 'granted'
              : 'not_asked'
            : 'withdrawn'
          : 'not_asked',
        voice: voice ? { granted: voice.granted, version: voice.notice_version } : null,
      }
    },

    async addTutorConsent(granted, version) {
      const result = await client
        .from('consents')
        .insert({ kind: 'ai_tutor', granted, notice_version: version })
      if (result.error) throw new DatabaseUnavailable()
    },

    async isGuest() {
      const { data, error } = await client.rpc('my_account')
      if (error) throw new DatabaseUnavailable()
      const row = (data as { is_anonymous: boolean }[] | null)?.[0]
      return row ? row.is_anonymous : true
    },

    async allowance() {
      const { data, error } = await client.rpc('tutor_allowance')
      if (error) throw new DatabaseUnavailable()
      return data
    },

    async reserve(sessionId, turn, attempt) {
      const { data, error } = await client.rpc('reserve_tutor_call', {
        p_session_id: sessionId,
        p_turn: turn,
        p_attempt: attempt,
      })
      if (error) throw new DatabaseUnavailable()
      return typeof data === 'string' ? data : null
    },

    async finish(callId, result) {
      const { error } = await client
        .from('tutor_calls')
        .update({
          outcome: result.outcome,
          provider: result.provider,
          model: result.model,
          input_tokens: result.inputTokens,
          output_tokens: result.outputTokens,
          cost_usd: result.costUsd,
        })
        .eq('id', callId)
      if (error) throw new DatabaseUnavailable()
    },

    readableDialogues: learner.readableDialogues,
    mySessions: learner.mySessions,
    session: learner.session,

    async cardFormIds() {
      const rows = await readAll(
        (from, to) => client.from('cards').select('form_id').order('form_id').range(from, to),
        unavailable,
      )
      return rows.map((row) => row.form_id)
    },

    async lines(dialogueIds) {
      const rows = await readAllIn(
        dialogueIds,
        (chunk) => (from, to) =>
          client
            .from('dialogue_lines')
            .select(
              'id, dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key',
            )
            .in('dialogue_id', chunk)
            .eq('status', 'approved')
            .order('id')
            .range(from, to),
        unavailable,
      )
      return rows.map((line) => ({
        id: line.id,
        dialogueId: line.dialogue_id,
        position: line.position,
        speaker: line.speaker,
        spoken: line.text_puhe ?? '',
        written: line.text_kirja ?? '',
        gloss: line.gloss_en ?? '',
        audioPuheKey: line.audio_puhe_key ?? '',
        audioKirjaKey: line.audio_kirja_key ?? '',
      }))
    },

    async tokens(lineIds) {
      const rows = await readAllIn(
        lineIds,
        (chunk) => (from, to) =>
          client
            .from('tokens')
            .select('line_id, register, position, surface, form_id')
            .in('line_id', chunk)
            .order('id')
            .range(from, to),
        unavailable,
      )
      return rows.map((row) => ({
        lineId: row.line_id,
        register: row.register,
        position: row.position,
        surface: row.surface,
        formId: row.form_id,
      }))
    },

    async forms(formIds) {
      const rows = await readAllIn(
        formIds,
        (chunk) => (from, to) =>
          client
            .from('forms')
            .select(
              'id, lemma, surface_kirja, surface_puhe, form_name_en, why_en, meaning_en, lemma_meaning_en',
            )
            .in('id', chunk)
            .eq('status', 'approved')
            .order('id')
            .range(from, to),
        unavailable,
      )
      return rows.map((form) => {
        const meaning = present(form.meaning_en)
        const baseMeaning = present(form.lemma_meaning_en)
        return {
          id: form.id,
          lemma: form.lemma,
          formName: form.form_name_en ?? '',
          why: form.why_en ?? '',
          surfacePuhe: form.surface_puhe,
          surfaceKirja: form.surface_kirja,
          ...(meaning ? { meaning } : {}),
          ...(baseMeaning ? { baseMeaning } : {}),
        }
      })
    },
  }
}
