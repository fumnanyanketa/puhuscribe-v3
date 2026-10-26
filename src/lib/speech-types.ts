// The shapes the Worker and the app share for speaking feedback
// (factory/jobs/10-speaking-feedback/spec.md). Nothing here identifies the
// learner, and no answer ever holds a transcript.

import type { FeedbackClass, Hint } from './speech-feedback.ts'

/** The learner's newest voice_processing choice; not_asked when they never chose. */
export type ProcessingChoice = 'granted' | 'withdrawn' | 'not_asked'

export interface KeptRecording {
  id: string
  /** The line's spoken text, or null when the line is no longer readable. */
  line: string | null
  slot: 'first' | 'latest'
  createdAt: string
}

/** The answer of GET /api/voice and of every /api/voice change. */
export interface VoiceAnswer {
  /** False when the speech service is not set up (no key, no EU region). */
  available: boolean
  /** The EU country the audio goes to, for the consent text. */
  region: string | null
  processing: ProcessingChoice
  retention: boolean
  /** Newest first. */
  recordings: KeptRecording[]
}

/** What POST /api/voice/consent takes in "choice". */
export const VOICE_CHOICES = ['turn_on', 'turn_off', 'keep_on', 'keep_off'] as const
export type VoiceChoice = (typeof VOICE_CHOICES)[number]

/** The answer of POST /api/speech/say: the class and hint only. */
export interface SayAnswer {
  feedbackClass: FeedbackClass
  hint?: Hint
}

/** The body cap of POST /api/speech/say: a 10 second WAV as base64 fits with room. */
export const MAX_SAY_BODY_BYTES = 512 * 1024
/** A recording stops by itself after this long. */
export const MAX_RECORDING_MS = 10_000
/** Shorter than this is treated as not heard in the browser, with no call to the server. */
export const MIN_RECORDING_MS = 500
/** Each learner may make this many checks in this many minutes. */
export const SPEECH_RATE_LIMIT = { checks: 40, minutes: 10 } as const
