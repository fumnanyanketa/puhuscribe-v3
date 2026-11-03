import { callApi, isRecord } from '../lib/api.ts'
import type { TutorHistoryItem, TutorState, TutorTranscript, TutorTurnAnswer } from '../lib/tutor-types.ts'
import { toBase64 } from '../lib/wav.ts'

// The app's calls to the tutor routes (worker/tutor.ts). The chat itself stays in the page's memory;
// these functions send it and never store any of it.

function isState(body: unknown): body is TutorState {
  return (
    isRecord(body) &&
    typeof body.available === 'boolean' &&
    typeof body.consent === 'string' &&
    typeof body.guest === 'boolean'
  )
}

/** The learner's Otso state, and with a session id what that session's step shows. Null when it could not load. */
export async function loadTutor(sessionId?: string): Promise<TutorState | null> {
  const path = sessionId ? `/api/tutor?session=${encodeURIComponent(sessionId)}` : '/api/tutor'
  const answer = await callApi(path, 'GET')
  return answer?.status === 200 && isState(answer.body) ? answer.body : null
}

/** Turns Otso on or off: one consent row. True when it was saved. */
export async function chooseTutor(choice: 'on' | 'off'): Promise<boolean> {
  const answer = await callApi('/api/tutor/consent', 'POST', { choice })
  return answer?.status === 200
}

export type TurnResult =
  | { kind: 'answer'; answer: TutorTurnAnswer }
  | { kind: 'cap' }
  | { kind: 'unavailable' }
  | { kind: 'signed_out' }

/** How long the app waits for a turn: up to three AI calls of 15 seconds each, and the network. */
const TURN_TIMEOUT_MS = 50_000

function isTurnAnswer(body: unknown): body is TutorTurnAnswer {
  return (
    isRecord(body) &&
    typeof body.turn === 'number' &&
    isRecord(body.otso) &&
    typeof body.closing === 'boolean'
  )
}

export async function sendTurn(
  sessionId: string,
  reply: string,
  history: TutorHistoryItem[],
): Promise<TurnResult> {
  const answer = await callApi('/api/tutor/turn', 'POST', { sessionId, reply, history }, TURN_TIMEOUT_MS)
  if (!answer) return { kind: 'unavailable' }
  if (answer.status === 200 && isTurnAnswer(answer.body)) return { kind: 'answer', answer: answer.body }
  if (answer.status === 429) return { kind: 'cap' }
  if (answer.status === 401) return { kind: 'signed_out' }
  return { kind: 'unavailable' }
}

export type TranscribeResult =
  | { kind: 'heard'; text: string }
  | { kind: 'not_heard' }
  | { kind: 'no_voice_consent' }
  | { kind: 'too_many' }
  | { kind: 'failed' }

/** Sends a spoken answer to be turned into text. The text comes back for the learner to check. */
export async function transcribe(sessionId: string, wav: Uint8Array): Promise<TranscribeResult> {
  const answer = await callApi('/api/tutor/transcribe', 'POST', { sessionId, audio: toBase64(wav) }, 30_000)
  if (!answer) return { kind: 'failed' }
  const error = isRecord(answer.body) ? answer.body.error : undefined
  if (answer.status === 200 && isRecord(answer.body)) {
    const body = answer.body as TutorTranscript
    if (body.status === 'heard' && typeof body.text === 'string') return { kind: 'heard', text: body.text }
    if (body.status === 'not_heard') return { kind: 'not_heard' }
  }
  if (answer.status === 403 && error === 'no_voice_consent') return { kind: 'no_voice_consent' }
  if (answer.status === 429) return { kind: 'too_many' }
  return { kind: 'failed' }
}
