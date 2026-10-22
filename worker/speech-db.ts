import type { FeedbackClass } from '../src/lib/speech-feedback.ts'
import type { ProcessingChoice } from '../src/lib/speech-types.ts'
import type { LearnerClient } from './learner-auth.ts'
import { DatabaseUnavailable } from './learner-db.ts'

// Every database read and write of speaking feedback except the kept
// recordings (worker/recording-store.ts), made with the learner's own token
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 2, 4, 14, 16 and
// 20). The database's rules decide what each call sees and may write: only
// the learner's own consents and attempts, and only lines they may read. The
// user id is never sent: the database takes it from the token.

export interface VoiceConsents {
  processing: ProcessingChoice
  retention: boolean
}

export interface ConsentRow {
  kind: 'voice_processing' | 'voice_recording_retention'
  granted: boolean
}

export interface SpeechLine {
  id: number
  dialogueId: number
  spoken: string
  written: string
}

export interface AttemptRow {
  sessionId: string
  lineId: number
  /** What the service heard, at most 300 characters; it never leaves the server. */
  transcript: string
  feedbackClass: FeedbackClass
  provider: string
  audioMs: number
  costUsd: number
}

export interface SpeechDb {
  /** The learner's newest choice of each kind. */
  consents: () => Promise<VoiceConsents>
  /** Adds consent rows in one statement, with the Worker's notice version. */
  addConsents: (rows: readonly ConsentRow[], noticeVersion: string) => Promise<void>
  /** One line the learner may read, or null. */
  line: (id: number) => Promise<SpeechLine | null>
  /** The spoken text of each line the learner may read, by id. */
  spokenLines: (ids: readonly number[]) => Promise<Map<number, string>>
  /** How many checks the learner made since this time. */
  attemptsSince: (since: Date) => Promise<number>
  /** Adds one attempt. False when the database refused it (no consent, a line not reached). */
  addAttempt: (attempt: AttemptRow) => Promise<boolean>
}

function must<T>(result: { data: T | null; error: unknown }): T {
  if (result.error || result.data === null) throw new DatabaseUnavailable()
  return result.data
}

const KINDS = ['voice_processing', 'voice_recording_retention'] as const

export function supabaseSpeechDb(client: LearnerClient): SpeechDb {
  async function newest(kind: (typeof KINDS)[number]): Promise<boolean | null> {
    const rows = must(
      await client
        .from('consents')
        .select('granted')
        .eq('kind', kind)
        .order('created_at', { ascending: false })
        .limit(1),
    )
    return rows.at(0)?.granted ?? null
  }

  return {
    async consents() {
      const [processing, retention] = await Promise.all(KINDS.map(newest))
      return {
        processing:
          processing === null || processing === undefined
            ? 'not_asked'
            : processing
              ? 'granted'
              : 'withdrawn',
        retention: retention === true,
      }
    },

    async addConsents(rows, noticeVersion) {
      if (rows.length === 0) return
      const { error } = await client
        .from('consents')
        .insert(rows.map((row) => ({ kind: row.kind, granted: row.granted, notice_version: noticeVersion })))
      if (error) throw new DatabaseUnavailable()
    },

    async line(id) {
      const result = await client
        .from('dialogue_lines')
        .select('id, dialogue_id, text_puhe, text_kirja')
        .eq('id', id)
        .maybeSingle()
      if (result.error) throw new DatabaseUnavailable()
      const row = result.data
      if (!row?.text_puhe || !row.text_kirja) return null
      return { id: row.id, dialogueId: row.dialogue_id, spoken: row.text_puhe, written: row.text_kirja }
    },

    async spokenLines(ids) {
      if (ids.length === 0) return new Map()
      const rows = must(
        await client
          .from('dialogue_lines')
          .select('id, text_puhe')
          .in('id', [...ids]),
      )
      return new Map(rows.flatMap((row) => (row.text_puhe ? [[row.id, row.text_puhe] as const] : [])))
    },

    async attemptsSince(since) {
      const { count, error } = await client
        .from('speaking_attempts')
        .select('id', { count: 'exact', head: true })
        .gte('created_at', since.toISOString())
      if (error || count === null) throw new DatabaseUnavailable()
      return count
    },

    async addAttempt(attempt) {
      const { error } = await client.from('speaking_attempts').insert({
        session_id: attempt.sessionId,
        line_id: attempt.lineId,
        transcript: attempt.transcript.slice(0, 300),
        feedback_class: attempt.feedbackClass,
        provider: attempt.provider,
        audio_ms: attempt.audioMs,
        cost_usd: attempt.costUsd,
      })
      if (!error) return true
      // 42501: the access rules refused the row (consent withdrawn meanwhile).
      if (error.code === '42501') return false
      throw new DatabaseUnavailable()
    },
  }
}
