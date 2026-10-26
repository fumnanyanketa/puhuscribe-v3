// How a review item is answered (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 21). One rule decides it, and the learner never picks: every
// second item of the run asks for a spoken answer when speaking feedback is on
// and recording works on this device; every other item is typed. An item that
// failed to record twice, or could not be recorded, is typed from then on
// (a recovery, not a choice).

export type AnswerMode = 'typed' | 'spoken'

export interface AnswerModeInput {
  /** The item's place in the run's first pass, counting from 0. */
  position: number
  /** Speaking feedback is set up and the learner has it on. */
  speakingOn: boolean
  /** This device can record (src/lib/recorder.ts recordingSupported). */
  recordingWorks: boolean
  /** This item already switched to typing after a failure. */
  switchedToTyping: boolean
}

export function answerModeFor(input: AnswerModeInput): AnswerMode {
  if (input.switchedToTyping || !input.speakingOn || !input.recordingWorks) return 'typed'
  return input.position % 2 === 1 ? 'spoken' : 'typed'
}

/** A recording that was not heard is asked for once more; the second time the item is typed. */
export const NOT_HEARD_LIMIT = 2
