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
  /**
   * The value stored in sessions.step_reached when the step is done. "tutor" is Otso's chat (job
   * 16-tutor-step), which stores no step: it sits between Keep it and the island step.
   */
  id: NonNullable<StepReached> | 'tutor'
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
 * a word to review as the session screen loaded, then Otso's chat when the
 * session is in stop 4 or later and the learner may have it (job 16-tutor-step),
 * then Use it when the session ends a stop whose island line the learner has not
 * added. Otso comes before the island step: the chat warms the learner up, and
 * the island line is what the stop leaves them with. Without any of these, the
 * session is exactly the list above.
 */
export function stepsFor(review: boolean, island = false, tutor?: SessionStep): readonly SessionStep[] {
  if (!review && !island && !tutor) return SESSION_STEPS
  const steps: SessionStep[] = review ? [...SESSION_STEPS, KEEP_IT_STEP] : [...SESSION_STEPS]
  if (tutor) steps.push(tutor)
  if (island) steps.push(USE_IT_STEP)
  return steps
}

/**
 * Use it, the island step (language islands, fast route of 3 November 2026): last, in the session of
 * a stop's last lesson, when the stop has an island line and the learner has not added it yet. Its line
 * is stored by POST /api/island; the session's step route never stores "use".
 */
export const USE_IT_STEP: SessionStep = { id: 'use', name: 'Use it', Screen: IslandUseIt }

/** Where a session stands: one of its steps, or the finish screen. */
export type SessionPosition = { kind: 'step'; index: number } | { kind: 'finish' }

/** The order of the steps; Otso's chat sits between Keep it and the island step. */
const LOOP_ORDER: Readonly<Record<SessionStep['id'], number>> = {
  hear: 0,
  understand: 1,
  say: 2,
  keep: 3,
  tutor: 3.5,
  use: 4,
}

/**
 * Where to resume a session that has reached `reached`: the first step of the
 * list after it, or the finish screen when none is left.
 */
export function resumeAt(steps: readonly SessionStep[], reached: StepReached): SessionPosition {
  const done = reached === null ? -1 : LOOP_ORDER[reached]
  const index = steps.findIndex((step) => LOOP_ORDER[step.id] > done)
  return index === -1 ? { kind: 'finish' } : { kind: 'step', index }
}

/** The position after a step is done. */
export function after(steps: readonly SessionStep[], index: number): SessionPosition {
  return index + 1 < steps.length ? { kind: 'step', index: index + 1 } : { kind: 'finish' }
}
