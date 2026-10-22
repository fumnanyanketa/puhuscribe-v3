import type { ComponentType } from 'react'
import type { AnswerKind, ReviewAnswer } from '../lib/review-types.ts'
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
  /** Sends the answer to be graded. */
  onAnswer: (answer: ReviewAnswer) => void
}

export interface AnswerMethod {
  kind: AnswerKind
  Answer: ComponentType<AnswerMethodProps>
}

export const ANSWER_METHODS: readonly AnswerMethod[] = [{ kind: 'typed', Answer: TypedAnswer }]

/** The id of a method's form, from the item's base id. */
export function methodFormId(base: string, kind: string): string {
  return `${base}-${kind}`
}
