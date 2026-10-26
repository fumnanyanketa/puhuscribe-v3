import type { ComponentType } from 'react'
import type { AnswerMode } from '../lib/answer-mode.ts'
import type { AnswerKind, TypedAnswer as TypedAnswerValue } from '../lib/review-types.ts'
import type { Recording, RecorderProblem } from '../lib/recorder.ts'
import { SpokenAnswer } from './SpokenAnswer.tsx'
import { TypedAnswer } from './TypedAnswer.tsx'

// How a learner can answer a review item, in one list
// (factory/jobs/9-daily-review/spec.md, "Done when" 15). The review item shows
// every method of this list in its answer area. Today only typing. Job 10
// (speaking feedback) adds a spoken method here, with its own answer kind,
// without changing the item, the queue, the scheduler call or the database.

export interface AnswerMethodProps {
  /** The id for the method's form. The item's "Check" button submits the typing form. */
  formId: string
  disabled: boolean
  /** Whether "Check" can be pressed now (for typing, the field holds something). */
  onReady: (ready: boolean) => void
  /** Sends a typed answer to be graded. */
  onAnswer: (answer: TypedAnswerValue) => void
  /** A spoken answer was recorded, or recording failed. The recording is only sent, never kept. */
  onRecorded: (result: RecordedResult) => void
}

export type RecordedResult =
  { kind: 'recorded'; recording: Recording } | { kind: 'failed'; problem: RecorderProblem }

export interface AnswerMethod {
  kind: AnswerKind
  Answer: ComponentType<AnswerMethodProps>
}

/** The one list of answer methods. */
export const ALL_METHODS: readonly AnswerMethod[] = [
  { kind: 'typed', Answer: TypedAnswer },
  { kind: 'spoken', Answer: SpokenAnswer },
]

/** The methods an item shows for the answer mode its rule gave it. */
export function methodsFor(mode: AnswerMode): readonly AnswerMethod[] {
  return ALL_METHODS.filter((method) => method.kind === mode)
}

/** Typing, the method every item can fall back to. */
export const ANSWER_METHODS: readonly AnswerMethod[] = methodsFor('typed')

/** The id of a method's form, from the item's base id. */
export function methodFormId(base: string, kind: string): string {
  return `${base}-${kind}`
}
