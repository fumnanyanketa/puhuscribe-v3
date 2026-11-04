import type { SessionWord } from './session-types.ts'

// The shapes the Worker sends the app for the tutor step, Otso (factory/jobs/16-tutor-step/spec.md).
// Shared by worker/ and src/. Nothing here identifies the learner, and nothing here is stored.

/** Whether the learner's newest ai_tutor consent row is a grant, a withdrawal, or missing. */
export type TutorConsent = 'granted' | 'withdrawn' | 'not_asked'

/**
 * What a session's step shows, from GET /api/tutor?session=<id>:
 * - none: the session has no Otso step (a stop below 4, no AI provider, or the learner turned it off);
 * - consent: the consent screen comes first;
 * - guest: the card asking a guest to add an email (owner's call 5, answer B);
 * - ready: the chat;
 * - cap: today's limit is reached, so the step is left out.
 */
export type TutorOffer = 'none' | 'consent' | 'guest' | 'ready' | 'cap'

export interface TutorState {
  /** The AI provider is set up. */
  available: boolean
  consent: TutorConsent
  guest: boolean
  /** With ?session=: what that session's step shows. */
  offer?: TutorOffer
  /** Spoken answers can be transcribed (the speech provider is set up). */
  speech: boolean
  /** The learner's newest voice consent names Otso's use of the transcript (src/lib/voice-consent.ts). */
  voiceForTutor: boolean
}

/** One earlier turn, as the app holds it in memory: what the learner sent and the text Otso showed. */
export interface TutorHistoryItem {
  you: string
  otso: string
}

/** The body of POST /api/tutor/turn. */
export interface TutorTurnRequest {
  sessionId: string
  reply: string
  /** The earlier turns of this exchange, oldest first, at most two. */
  history: TutorHistoryItem[]
}

/** Otso's answer to one turn. */
export type TutorReply =
  /** A line made by AI, checked by code: every word is one the learner met. No audio. */
  | { kind: 'ai'; text: string; words: SessionWord[]; meaning?: string }
  /** An approved line of today's dialogue, served when the AI's tries failed. */
  | { kind: 'line'; lineId: number; text: string }
  /** No approved line was left: Otso ends kindly. */
  | { kind: 'end' }

/** An approved line Otso points to at the end (statement 10). */
export interface TutorTip {
  spoken: string
  written: string
  gloss: string
  spokenAudio: string
  writtenAudio: string
}

export interface TutorTurnAnswer {
  turn: number
  otso: TutorReply
  /** True after the third turn: the exchange is over. */
  closing: boolean
  tip?: TutorTip
}

/** The answer of POST /api/tutor/transcribe: what the speech service heard, for the learner to check. */
export type TutorTranscript = { status: 'heard'; text: string } | { status: 'not_heard' }

export const OTSO_ENDS = 'That is enough Finnish for now. Nice work.'
export const OTSO_UNAVAILABLE = 'Aleksi is not available right now.'
export const OTSO_CAP = 'Aleksi has talked enough for today. You can talk to him again tomorrow.'
