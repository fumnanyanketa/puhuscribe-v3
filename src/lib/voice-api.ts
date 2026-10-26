import { callApi, isRecord, type ApiAnswer } from './api.ts'
import { FEEDBACK_CLASSES, type Feedback, type Hint } from './speech-feedback.ts'
import type { KeptRecording, ProcessingChoice, VoiceAnswer, VoiceChoice } from './speech-types.ts'
import { toBase64 } from './wav.ts'

// The app's side of the voice routes (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 1 to 4, 14, 15 and 19). Every answer is checked before it is
// used: anything the app does not expect counts as "could not load".

/** The text shown when the voice service is not set up or could not be reached. */
export const NOT_AVAILABLE = 'Speaking feedback is not available right now.'
/** The cap message the Worker sends with a 429 (statement 14). */
export const TOO_MANY = 'You have recorded a lot in the last few minutes. Take a short break, then try again.'

const PROCESSING: readonly ProcessingChoice[] = ['granted', 'withdrawn', 'not_asked']

function keptRecording(value: unknown): KeptRecording | null {
  if (!isRecord(value)) return null
  const { id, line, slot, createdAt } = value
  if (typeof id !== 'string' || typeof createdAt !== 'string') return null
  if (line !== null && typeof line !== 'string') return null
  if (slot !== 'first' && slot !== 'latest') return null
  return { id, line, slot, createdAt }
}

/** The Worker's voice answer, or null when the body is not one. */
export function parseVoiceAnswer(body: unknown): VoiceAnswer | null {
  if (!isRecord(body)) return null
  const { available, region, processing, retention, recordings } = body
  if (typeof available !== 'boolean' || typeof retention !== 'boolean') return null
  if (region !== null && typeof region !== 'string') return null
  const choice = PROCESSING.find((p) => p === processing)
  if (!choice || !Array.isArray(recordings)) return null
  const kept = recordings.map(keptRecording)
  if (kept.some((row) => row === null)) return null
  return { available, region, processing: choice, retention, recordings: kept as KeptRecording[] }
}

export type VoiceLoad = { kind: 'ok'; voice: VoiceAnswer } | { kind: 'signed_out' } | { kind: 'failed' }

function voiceLoad(answer: ApiAnswer | null): VoiceLoad {
  if (answer?.status === 401) return { kind: 'signed_out' }
  const voice = answer?.status === 200 ? parseVoiceAnswer(answer.body) : null
  return voice ? { kind: 'ok', voice } : { kind: 'failed' }
}

export async function loadVoice(): Promise<VoiceLoad> {
  return voiceLoad(await callApi('/api/voice', 'GET'))
}

export async function chooseVoice(choice: VoiceChoice, keepRecordings?: boolean): Promise<VoiceLoad> {
  const body = keepRecordings === undefined ? { choice } : { choice, keepRecordings }
  return voiceLoad(await callApi('/api/voice/consent', 'POST', body))
}

export async function deleteKept(which: { id: string } | { all: true }): Promise<VoiceLoad> {
  return voiceLoad(await callApi('/api/voice/recordings/delete', 'POST', which))
}

function hint(value: unknown): Hint | null {
  if (!isRecord(value)) return null
  const text = (key: string) => (typeof value[key] === 'string' ? value[key] : null)
  switch (value.kind) {
    case 'double':
    case 'single': {
      const letter = text('letter')
      return letter ? { kind: value.kind, letter } : null
    }
    case 'vowel': {
      const want = text('want')
      const heard = text('heard')
      return want && heard ? { kind: 'vowel', want, heard } : null
    }
    case 'missing':
    case 'off': {
      const word = text('word')
      return word ? { kind: value.kind, word } : null
    }
    default:
      return null
  }
}

/** The feedback in a say answer, or null when the body is not one. */
export function parseSayAnswer(body: unknown): Feedback | null {
  if (!isRecord(body)) return null
  const feedbackClass = FEEDBACK_CLASSES.find((c) => c === body.feedbackClass)
  if (!feedbackClass) return null
  if (feedbackClass === 'close') {
    const found = hint(body.hint)
    return found ? { feedbackClass, hint: found } : null
  }
  return { feedbackClass }
}

export type SayResult =
  | { kind: 'feedback'; feedback: Feedback }
  | { kind: 'no_consent' }
  | { kind: 'not_available' }
  | { kind: 'too_many' }
  | { kind: 'signed_out' }
  | { kind: 'failed' }

/** How long the app waits for a check: the service's own 10 seconds, one retry and the upload. */
const SAY_TIMEOUT_MS = 30_000

/** Sends one recording to be checked against a line of the session. */
export async function sayLine(sessionId: string, lineId: number, wav: Uint8Array): Promise<SayResult> {
  const answer = await callApi(
    '/api/speech/say',
    'POST',
    { sessionId, lineId, audio: toBase64(wav) },
    SAY_TIMEOUT_MS,
  )
  if (!answer) return { kind: 'failed' }
  const error = isRecord(answer.body) ? answer.body.error : undefined
  if (answer.status === 200) {
    const feedback = parseSayAnswer(answer.body)
    return feedback ? { kind: 'feedback', feedback } : { kind: 'failed' }
  }
  if (answer.status === 401) return { kind: 'signed_out' }
  if (answer.status === 403 && error === 'no_voice_consent') return { kind: 'no_consent' }
  if (answer.status === 429) return { kind: 'too_many' }
  if (answer.status === 503 && error === 'speech_not_available') return { kind: 'not_available' }
  return { kind: 'failed' }
}
