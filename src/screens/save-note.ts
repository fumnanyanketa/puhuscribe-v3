import { isRecord, type ApiAnswer } from '../lib/api.ts'

// What the complete answer says about the finish screen's note (factory/jobs/
// 18-save-progress/spec.md, "Done when" 3). The Worker adds "saveNote" ("first"
// or "reminder") to {"saved":true} only when the database says the note is due.

/** The kind of account GET /api/me (job 11-accounts) names: a guest, an email account, or anything else. */
export type AccountKind = 'guest' | 'email' | 'other'

/** Only a clear answer of "guest" or "email" counts; an answer that failed or is odd is "other". */
export function accountKindOf(answer: ApiAnswer | null): AccountKind {
  if (answer?.status !== 200 || !isRecord(answer.body)) return 'other'
  if (answer.body.kind === 'guest') return 'guest'
  if (answer.body.kind === 'email') return 'email'
  return 'other'
}

/** True only for a saved answer that carries a note word this screen knows. */
export function carriesSaveNote(answer: ApiAnswer | null): boolean {
  if (answer?.status !== 200 || !isRecord(answer.body)) return false
  if (answer.body.saved !== true) return false
  return answer.body.saveNote === 'first' || answer.body.saveNote === 'reminder'
}
