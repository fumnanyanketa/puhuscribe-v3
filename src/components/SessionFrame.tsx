import { useId, useState, type ReactNode } from 'react'
import { Button } from './Button.tsx'
import { Landscape } from './Landscape.tsx'
import { Sheet } from './Sheet.tsx'
import styles from './SessionFrame.module.css'

// The session frame (design.md, "Session frame"): the landscape band, a 44 px
// cross in a milky round, a progress bar that fills by the share of the lesson
// done, the step name at the right, a scrolling content area and a bottom
// action area that stays in view, clear of the iPhone home bar. The cross opens
// the sheet "Leave this lesson?" (job 19-redesign, statement 22); on the finish
// screen nothing is lost, so it leaves at once. The learner never picks a mode:
// the steps follow the loop order.

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
  /** The share of the current step that is done, from 0 to 1 (lines shown, questions answered, words done). */
  progress?: number
  /** The finish screen after the last step: the bar is full. */
  finished?: boolean
  /** Dims everything but the content, for the first lesson tip. */
  dim?: boolean
  /** The step name is the screen's h1 (the step screens), instead of plain text. */
  stepHeading?: boolean
  /** Hides the step name from the eye where the drawing shows only the question. It stays for screen readers. */
  hideStepName?: boolean
  leaveHref: string
  children: ReactNode
  actions: ReactNode
  /** Fills its parent instead of the screen (the reference page shows it in a box). */
  contained?: boolean
}

function clamp(value: number): number {
  return Math.min(1, Math.max(0, value))
}

export function SessionFrame({
  step,
  hasUseIt = false,
  steps: given,
  progress = 0,
  finished = false,
  stepHeading = false,
  hideStepName = false,
  dim = false,
  leaveHref,
  children,
  actions,
  contained = false,
}: SessionFrameProps) {
  const steps = given ?? (hasUseIt ? LOOP_STEPS : LOOP_STEPS.slice(0, 4))
  const number = finished ? steps.length + 1 : steps.indexOf(step) + 1
  const share = finished ? 1 : clamp((number - 1 + clamp(progress)) / steps.length)
  const name = finished ? 'Session finished' : `${step}, step ${String(number)} of ${String(steps.length)}`
  const [leaving, setLeaving] = useState(false)
  const titleId = useId()
  const StepName = stepHeading ? 'h1' : 'p'
  return (
    <div
      className={contained ? `${styles.frame} ${styles.contained}` : styles.frame}
      data-dim={dim ? 'on' : undefined}
    >
      <Landscape />
      <header className={styles.topBar}>
        {finished ? (
          <a className={styles.leave} href={leaveHref} aria-label="Leave session">
            <Cross />
          </a>
        ) : (
          <button
            type="button"
            className={styles.leave}
            aria-label="Leave session"
            aria-haspopup="dialog"
            onClick={() => {
              setLeaving(true)
            }}
          >
            <Cross />
          </button>
        )}
        <div
          className={styles.bar}
          role="progressbar"
          aria-label={name}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={Math.round(share * 100)}
        >
          <span className={styles.fill} style={{ width: `${String(Math.round(share * 1000) / 10)}%` }} />
        </div>
        <StepName className={hideStepName ? styles.stepHidden : styles.step}>
          {finished ? 'Lesson finished' : step}
        </StepName>
      </header>
      {dim && <div className={styles.scrim} aria-hidden="true" />}
      <div className={styles.content}>{children}</div>
      <div className={styles.actions}>{actions}</div>
      <Sheet
        open={leaving}
        labelledBy={titleId}
        onClose={() => {
          setLeaving(false)
        }}
      >
        <h2 id={titleId} className={styles.sheetTitle}>
          Leave this lesson?
        </h2>
        <p className={styles.sheetText}>You can carry on later from here.</p>
        <div className={styles.sheetActions}>
          <Button
            block
            data-sheet-focus
            onClick={() => {
              setLeaving(false)
            }}
          >
            Keep going
          </Button>
          <Button
            variant="secondary"
            block
            onClick={() => {
              window.location.assign(leaveHref)
            }}
          >
            Leave
          </Button>
        </div>
      </Sheet>
    </div>
  )
}

function Cross() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M6 6l12 12M18 6L6 18" />
    </svg>
  )
}
