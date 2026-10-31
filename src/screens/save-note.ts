import { isRecord, type ApiAnswer } from '../lib/api.ts'

// What the complete answer says about the finish screen's note (factory/jobs/
// 18-save-progress/spec.md, "Done when" 3). The Worker adds "saveNote" ("first"
// or "reminder") to {"saved":true} only when the database says the note is due.

/** True only for a saved answer that carries a note word this screen knows. */
export function carriesSaveNote(answer: ApiAnswer | null): boolean {
  if (answer?.status !== 200 || !isRecord(answer.body)) return false
  if (answer.body.saved !== true) return false
  return answer.body.saveNote === 'first' || answer.body.saveNote === 'reminder'
}
