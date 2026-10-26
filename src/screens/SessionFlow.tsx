import type { ReviewItem } from '../lib/review-types.ts'
import type { ReadySession } from '../lib/session-types.ts'
import { FinishScreen } from './FinishScreen.tsx'
import { PatternsProvider } from './PatternsProvider.tsx'
import type { SessionPosition, SessionStep } from './session-steps.ts'

// Shows the screen for where the session stands: one step from the list,
// each in the session frame with the list's names, or the finish screen.
// Every word card in it can open "Patterns you've seen" (job 12-units-1-3),
// which is not a step.

interface SessionFlowProps {
  steps: readonly SessionStep[]
  session: ReadySession
  position: SessionPosition
  /** Stores the step at this index as reached, then moves on. */
  onStepDone: (index: number) => Promise<boolean>
  /** The review items loaded with the session, for Keep it (job 9-daily-review). */
  review?: readonly ReviewItem[]
}

export function SessionFlow({ steps, session, position, onStepDone, review }: SessionFlowProps) {
  const names = steps.map((step) => step.name)
  const current = position.kind === 'step' ? steps[position.index] : undefined
  if (position.kind === 'finish' || !current) {
    return (
      <PatternsProvider sessionId={session.session.id}>
        <FinishScreen session={session} steps={names} />
      </PatternsProvider>
    )
  }
  const { Screen } = current
  const index = position.index
  return (
    <PatternsProvider sessionId={session.session.id}>
      <Screen
        key={current.id}
        session={session}
        frame={{ step: current.name, steps: names }}
        onDone={() => onStepDone(index)}
        review={review}
      />
    </PatternsProvider>
  )
}
