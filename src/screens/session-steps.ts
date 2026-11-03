import type { ComponentType } from 'react'
import type { LoopStep } from '../components/SessionFrame.tsx'
import type { StepReached } from '../lib/session-types.ts'
import { IslandUseIt } from '../island/IslandUseIt.tsx'
import { HearIt } from './HearIt.tsx'
import { SayIt } from './SayIt.tsx'
import { KeepItStep } from './KeepIt.tsx'
import type { StepScreenProps } from './step-screen.ts'
import { UnderstandIt } from './UnderstandIt.tsx'

// The steps of a session, in order, in one list
// (factory/jobs/8-first-session/spec.md, "Done when" 8). The finish screen
// always follows the last one. Say it (job 10-speaking-feedback) is added
// here, after Understand it. Since the owner's fast route hear-and-say
// (3 November 2026) the first step is "Hear it, say it" (each line heard, then
// said back) and Say it is the short "Recap" of the key lines; the stored ids
// stay "hear" and "say". Keep it (job 9-daily-review) comes after every
// step of this list, and only in a session that has words to review
// (stepsFor below).

export interface SessionStep {
  /** The value stored in sessions.step_reached when the step is done. */
  id: NonNullable<StepReached>
  /** The step's name in the top bar. */
  name: LoopStep
  Screen: ComponentType<StepScreenProps>
}

export const SESSION_STEPS: readonly SessionStep[] = [
  { id: 'hear', name: 'Hear it, say it', Screen: HearIt },
  { id: 'understand', name: 'Understand it', Screen: UnderstandIt },
  { id: 'say', name: 'Recap', Screen: SayIt },
]

/**
 * Keep it, the review (factory/jobs/9-daily-review/spec.md, "Done when" 6).
 * Its end is stored by POST /api/sessions/<id>/review/done, never by the step
 * route, which accepts no step beyond Understand it from the browser.
 */
export const KEEP_IT_STEP: SessionStep = { id: 'keep', name: 'Keep it', Screen: KeepItStep }

/**
 * The steps of one session: the list above, then Keep it when the learner had
 * a word to review as the session screen loaded, then Use it when the session
 * ends a stop whose island line the learner has not added. Without either, the
 * session is exactly the list above.
 */
export function stepsFor(review: boolean, island = false): readonly SessionStep[] {
  const steps = review ? [...SESSION_STEPS, KEEP_IT_STEP] : SESSION_STEPS
  return island ? [...steps, USE_IT_STEP] : steps
}

/**
 * Use it, the island step (language islands, fast route of 3 November 2026): last, in the session of
 * a stop's last lesson, when the stop has an island line and the learner has not added it yet. Its line
 * is stored by POST /api/island; the session's step route never stores "use".
 */
export const USE_IT_STEP: SessionStep = { id: 'use', name: 'Use it', Screen: IslandUseIt }

/** Where a session stands: one of its steps, or the finish screen. */
export type SessionPosition = { kind: 'step'; index: number } | { kind: 'finish' }

const LOOP_ORDER = ['hear', 'understand', 'say', 'keep', 'use'] as const

/**
 * Where to resume a session that has reached `reached`: the first step of the
 * list after it, or the finish screen when none is left.
 */
export function resumeAt(steps: readonly SessionStep[], reached: StepReached): SessionPosition {
  const done = reached === null ? -1 : LOOP_ORDER.indexOf(reached)
  const index = steps.findIndex((step) => LOOP_ORDER.indexOf(step.id) > done)
  return index === -1 ? { kind: 'finish' } : { kind: 'step', index }
}

/** The position after a step is done. */
export function after(steps: readonly SessionStep[], index: number): SessionPosition {
  return index + 1 < steps.length ? { kind: 'step', index: index + 1 } : { kind: 'finish' }
}
