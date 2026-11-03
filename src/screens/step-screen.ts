import type { LoopStep } from '../components/SessionFrame.tsx'
import type { ReviewItem } from '../lib/review-types.ts'
import type { ReadySession } from '../lib/session-types.ts'

// What every step screen of a session gets (src/screens/session-steps.ts).

export interface StepScreenProps {
  session: ReadySession
  /** The step's name and the session's steps, for the top bar. */
  frame: { step: LoopStep; steps: readonly LoopStep[]; index?: number }
  /** Stores the step as reached, then moves on. Resolves false when it could not be saved. */
  onDone: () => Promise<boolean>
  /** The review items loaded with the session, for Keep it (job 9-daily-review). */
  review?: readonly ReviewItem[]
  /**
   * A practice replay of a finished lesson (fast route go-back): onDone stores nothing, and speaking
   * feedback checks name the finished session as practice.
   */
  practice?: boolean
}

export const NOT_SAVED = 'Your progress was not saved. Check your internet connection, then try again.'
