import type { LoopStep } from '../components/SessionFrame.tsx'
import type { ReadySession } from '../lib/session-types.ts'

// What every step screen of a session gets (src/screens/session-steps.ts).

export interface StepScreenProps {
  session: ReadySession
  /** The step's name and the session's steps, for the top bar. */
  frame: { step: LoopStep; steps: readonly LoopStep[] }
  /** Stores the step as reached, then moves on. Resolves false when it could not be saved. */
  onDone: () => Promise<boolean>
}

export const NOT_SAVED = 'Your progress was not saved. Check your internet connection, then try again.'
export const CHANGED_HINT = 'Blue words change between spoken and written Finnish.'
