import type { LearnerClient } from './learner-auth.ts'
import { DatabaseUnavailable } from './learner-db.ts'

// The one place kept recordings are written, read and deleted
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 19, Decision 6 and
// Risks). Today they live in the kept_recordings table of the EU Supabase
// project, behind its access rules, read and written with the learner's own
// token. Moving them to another store (such as Cloudflare R2) changes this
// file only. Recordings are kept only for learners whose newest
// voice_recording_retention consent is a grant; the database refuses anything
// else.

export interface ListedRecording {
  id: string
  lineId: number
  slot: 'first' | 'latest'
  createdAt: string
}

/** PostgREST sends bytea as "\x" and hex digits. */
export function bytesFromHex(value: string): Uint8Array | null {
  const hex = value.startsWith('\\x') ? value.slice(2) : value
  if (hex.length % 2 !== 0 || !/^[0-9a-f]*$/i.test(hex)) return null
  const bytes = new Uint8Array(hex.length / 2)
  for (let i = 0; i < bytes.length; i += 1) bytes[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16)
  return bytes
}

export interface RecordingStore {
  /** Keeps a WAV as the line's first try, or replaces its latest. False when the database refused it. */
  keep: (lineId: number, wavBase64: string) => Promise<boolean>
  /** The learner's kept recordings, newest first, without their audio. */
  list: () => Promise<ListedRecording[]>
  /** One of the learner's own recordings as WAV bytes, or null (another learner's id reads as missing). */
  read: (id: string) => Promise<Uint8Array | null>
  /** Deletes one of the learner's own recordings. */
  remove: (id: string) => Promise<void>
  /** Deletes every recording of the learner. */
  removeAll: () => Promise<void>
}

export function supabaseRecordingStore(client: LearnerClient): RecordingStore {
  return {
    async keep(lineId, wavBase64) {
      const { error } = await client.rpc('keep_recording', { line_id: lineId, audio_base64: wavBase64 })
      if (!error) return true
      // 42501: the access rules refused it (no retention consent).
      if (error.code === '42501') return false
      throw new DatabaseUnavailable()
    },

    async list() {
      const { data, error } = await client
        .from('kept_recordings')
        .select('id, line_id, slot, created_at')
        .order('created_at', { ascending: false })
      if (error) throw new DatabaseUnavailable()
      return data.map((row) => ({
        id: row.id,
        lineId: row.line_id,
        slot: row.slot === 'first' ? 'first' : 'latest',
        createdAt: row.created_at,
      }))
    },

    async read(id) {
      const { data, error } = await client.from('kept_recordings').select('audio').eq('id', id).maybeSingle()
      if (error) throw new DatabaseUnavailable()
      if (!data) return null
      return bytesFromHex(data.audio)
    },

    async remove(id) {
      const { error } = await client.from('kept_recordings').delete().eq('id', id)
      if (error) throw new DatabaseUnavailable()
    },

    async removeAll() {
      // Supabase refuses a delete with no filter; the access rules keep it to
      // the learner's own rows.
      const { error } = await client.from('kept_recordings').delete().in('slot', ['first', 'latest'])
      if (error) throw new DatabaseUnavailable()
    },
  }
}
