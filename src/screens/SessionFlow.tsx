import type { ReadySession } from '../lib/session-types.ts'
import { FinishScreen } from './FinishScreen.tsx'
import type { SessionPosition, SessionStep } from './session-steps.ts'

// Shows the screen for where the session stands: one step from the list,
// each in the session frame with the list's names, or the finish screen.

interface SessionFlowProps {
  steps: readonly SessionStep[]
  session: ReadySession
  position: SessionPosition
  /** Stores the step at this index as reached, then moves on. */
  onStepDone: (index: number) => Promise<boolean>
}

export function SessionFlow({ steps, session, position, onStepDone }: SessionFlowProps) {
  const names = steps.map((step) => step.name)
  const current = position.kind === 'step' ? steps[position.index] : undefined
  if (position.kind === 'finish' || !current) return <FinishScreen session={session} steps={names} />
  const { Screen } = current
  const index = position.index
  return (
    <Screen
      key={current.id}
      session={session}
      frame={{ step: current.name, steps: names }}
      onDone={() => onStepDone(index)}
    />
  )
}
