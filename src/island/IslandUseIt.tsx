import { useEffect } from 'react'
import { PATHS } from '../lib/app-paths.ts'
import { islandStop } from '../lib/islands.ts'
import type { StepScreenProps } from '../screens/step-screen.ts'
import { saveIslandLine } from './island-api.ts'
import { IslandStep } from './IslandStep.tsx'

// "Use it" as the last step of a stop's last lesson (language islands): the island step for the
// session's stop (ReadySession.islandStop). The line is stored by POST /api/island; the session's own
// step is not stored, because the step route takes no step beyond Say it from the browser. Adding the
// line (or skipping it, at stop 21) moves on to the finish screen.

export function IslandUseIt({ session, frame, onDone }: StepScreenProps) {
  const stop = session.islandStop === undefined ? undefined : islandStop(session.islandStop)

  // A session whose stop has no approved line moves on at once (it is not given this step).
  useEffect(() => {
    if (!stop) void onDone()
  }, [stop, onDone])

  if (!stop) return null
  return (
    <IslandStep
      stop={stop}
      frame={frame}
      leaveHref={PATHS.home}
      onSave={async (entry) => {
        const result = await saveIslandLine(entry)
        if (result === 'signed_out') {
          // The sign in ended on the way: the front door says so, as for every session route.
          window.location.replace(PATHS.home)
          return false
        }
        if (result !== 'saved') return false
        return onDone()
      }}
      onSkip={
        stop.optional
          ? () => {
              void onDone()
            }
          : undefined
      }
    />
  )
}
