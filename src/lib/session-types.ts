// The shapes the Worker sends the app for the first session loop
// (factory/jobs/8-first-session/spec.md). Shared by worker/ and src/, so both
// sides agree. Nothing here identifies the learner: no user id, no token.

import type { Database } from './database.types.ts'
import type { NextReview } from './review-types.ts'

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
  /** What the word means in this line, in plain English (forms.meaning_en). Missing when the form has none. */
  meaning?: string
  /** What the dictionary form means, in plain English (forms.lemma_meaning_en). Missing in the same way. */
  baseMeaning?: string
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
  /**
   * True on the learner's first lesson, before Hear it is finished: the screen
   * shows its tip (job 19-redesign, statement 25). Worked out from the learner's
   * own session rows; nothing is stored for it.
   */
  firstLesson?: true
}

/** A word the learner met for the first time in a lesson, for the chips on the finish screen. */
export interface NewWord {
  form: WordForm
  /** The audio of the first line the word appears in, as paths under /audio/. */
  spokenAudio: string
  writtenAudio: string
}

/** The answer of POST /api/sessions/<id>/complete (job 8, job 18 and job 19-redesign). */
export interface CompleteAnswer {
  saved: true
  saveNote?: 'first' | 'reminder'
  /** The words this lesson added to the learner's review, at most 24. */
  newWords?: NewWord[]
}

/** A review only session: Keep it alone, when no new dialogue is ready (job 9-daily-review, "Done when" 7). */
export interface ReviewSession {
  state: 'review'
  session: { id: string; step: StepReached }
}

/** The answer of POST /api/sessions/today when the learner is signed in. */
export type TodayAnswer = ReadySession | ReviewSession | { state: 'not_ready' } | { state: 'all_done' }

/**
 * What the front door shows next, from GET /api/today. "review" offers a
 * review only session (job 9-daily-review); an unfinished one is "continue".
 */
export type FrontDoorState = 'start' | 'continue' | 'all_done' | 'not_ready' | 'review'

/**
 * The answer of GET /api/today. When a sign in ended and it was an email
 * account, `account: 'email'` picks the email message (job 11-accounts,
 * "Done when" 22); guests get job 8's answer unchanged.
 */
export type FrontDoorAnswer =
  | { signedIn: false; ended: boolean; account?: 'email' }
  | {
      signedIn: true
      today: FrontDoorState
      canDo?: string
      /** With "start": today's session ends with a short review (job 9-daily-review). */
      review?: true
      /** With "all_done", when the learner has cards: today's Helsinki date and the next review day. */
      nextReview?: NextReview
      /** With "review": how many words wait. The review card on the road shows it (job 19-redesign, owner's call 7). */
      reviewCount?: number
    }

/**
 * The steps a learner may record from the browser. Never beyond say: Say it
 * (job 10-speaking-feedback) comes after Understand it.
 */
export const RECORDABLE_STEPS = ['hear', 'understand', 'say'] as const
export type RecordableStep = (typeof RECORDABLE_STEPS)[number]
