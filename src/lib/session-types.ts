// The shapes the Worker sends the app for the first session loop
// (factory/jobs/8-first-session/spec.md). Shared by worker/ and src/, so both
// sides agree. Nothing here identifies the learner: no user id, no token.

import type { Database } from './database.types.ts'

/** The furthest loop step a session has reached, or null before Hear it is done. */
export type StepReached = Database['public']['Enums']['loop_step'] | null

/** A word's form, shown on its word card. Only approved forms are ever sent. */
export interface WordForm {
  /** The base form, as a dictionary lists it (forms.lemma). */
  lemma: string
  /** The name of the form, in English (forms.form_name_en). */
  formName: string
  /** One line on why it looks like this (forms.why_en). */
  why: string
  /** The spoken form (forms.surface_puhe). */
  spoken: string
  /** The written form (forms.surface_kirja). */
  written: string
}

/** One word of a line, as it appears in the line's text. */
export interface SessionWord {
  text: string
  /** Punctuation before the first word of the line, such as an opening quote. */
  before?: string
  /** Punctuation after the word, shown outside its button. */
  after?: string
  /** Missing for words that are never reviewed (such as names) or whose form is not readable. */
  form?: WordForm
}

export interface SessionLine {
  id: number
  speaker: string
  gloss: string
  /** Same address paths of the line's audio, such as /audio/<key>. */
  spokenAudio: string
  writtenAudio: string
  spoken: SessionWord[]
  written: SessionWord[]
}

export interface ReadySession {
  state: 'ready'
  session: { id: string; step: StepReached }
  unit: { title: string; canDo: string }
  dialogue: { title: string }
  lines: SessionLine[]
}

/** The answer of POST /api/sessions/today when the learner is signed in. */
export type TodayAnswer = ReadySession | { state: 'not_ready' } | { state: 'all_done' }

/** What the front door shows next, from GET /api/today. */
export type FrontDoorState = 'start' | 'continue' | 'all_done' | 'not_ready'

/**
 * The answer of GET /api/today. When a sign in ended and it was an email
 * account, `account: 'email'` picks the email message (job 11-accounts,
 * "Done when" 22); guests get job 8's answer unchanged.
 */
export type FrontDoorAnswer =
  | { signedIn: false; ended: boolean; account?: 'email' }
  | { signedIn: true; today: FrontDoorState; canDo?: string }

/** The steps a learner may record from the browser. Never beyond understand. */
export const RECORDABLE_STEPS = ['hear', 'understand'] as const
export type RecordableStep = (typeof RECORDABLE_STEPS)[number]
