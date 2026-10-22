import { Button } from '../components/Button.tsx'
import { SessionFrame, type LoopStep } from '../components/SessionFrame.tsx'
import styles from './Screens.module.css'

// The end of a review only session (factory/jobs/9-daily-review/spec.md,
// "Done when" 7). Plain words and one way back. No counts, scores or
// celebration.

export const REVIEW_FINISHED = 'Review finished.'
export const COME_BACK_WHEN_DUE = 'These words will come back when they are due.'

export function ReviewFinish({ steps }: { steps: readonly LoopStep[] }) {
  const lastStep = steps[steps.length - 1] ?? 'Keep it'
  const actions = (
    <Button
      block
      onClick={() => {
        window.location.assign('/')
      }}
    >
      Done
    </Button>
  )
  return (
    <SessionFrame step={lastStep} steps={steps} finished leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 className={styles.title}>{REVIEW_FINISHED}</h1>
        </div>
        <p className={styles.comesBack}>{COME_BACK_WHEN_DUE}</p>
      </main>
    </SessionFrame>
  )
}
