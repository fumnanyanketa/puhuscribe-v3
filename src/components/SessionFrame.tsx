import type { ReactNode } from 'react'
import styles from './SessionFrame.module.css'

// The session frame (design.md, "Session frame"): a top bar with the loop
// step named in words and a "Leave session" control, a scrolling content area,
// and a bottom action area that stays in view, clear of the iPhone home bar.
// The learner never picks a mode: the steps follow the loop order.

export const LOOP_STEPS = ['Hear it', 'Understand it', 'Say it', 'Keep it', 'Use it'] as const
export type LoopStep = (typeof LOOP_STEPS)[number]

interface SessionFrameProps {
  step: LoopStep
  /** Use it appears only in sessions that have it (from unit 4). */
  hasUseIt?: boolean
  /**
   * The steps this session has, in order. Given, it replaces the default list
   * (and hasUseIt). The first session loop passes Hear it and Understand it
   * (src/screens/session-steps.ts).
   */
  steps?: readonly LoopStep[]
  /** The finish screen after the last step: every segment done, "Session finished". */
  finished?: boolean
  leaveHref: string
  children: ReactNode
  actions: ReactNode
  /** Fills its parent instead of the screen (the reference page shows it in a box). */
  contained?: boolean
}

export function SessionFrame({
  step,
  hasUseIt = false,
  steps: given,
  finished = false,
  leaveHref,
  children,
  actions,
  contained = false,
}: SessionFrameProps) {
  const steps = given ?? (hasUseIt ? LOOP_STEPS : LOOP_STEPS.slice(0, 4))
  const number = finished ? steps.length + 1 : steps.indexOf(step) + 1
  return (
    <div className={contained ? `${styles.frame} ${styles.contained}` : styles.frame}>
      <header className={styles.topBar}>
        <a className={styles.leave} href={leaveHref} aria-label="Leave session">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M6 6l12 12M18 6L6 18" />
          </svg>
        </a>
        <div className={styles.segments} aria-hidden="true">
          {steps.map((name, i) => (
            <span
              key={name}
              className={
                i + 1 === number ? styles.segmentNow : i + 1 < number ? styles.segmentDone : styles.segment
              }
            />
          ))}
        </div>
        <p className={styles.step}>
          {finished ? 'Session finished' : `${step}, step ${String(number)} of ${String(steps.length)}`}
        </p>
      </header>
      <div className={styles.content}>{children}</div>
      <div className={styles.actions}>{actions}</div>
    </div>
  )
}
