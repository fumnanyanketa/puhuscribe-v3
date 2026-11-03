import { SpeakLines } from './SayIt.tsx'
import type { StepScreenProps } from './step-screen.ts'

// "Hear it, say it", the session's first step (owner's fast route hear-and-say,
// 3 November 2026, replacing Hear it of factory/jobs/8-first-session/spec.md,
// "Done when" 9 and 10, and job 19-redesign, statements 24 and 25). The
// dialogue one line card at a time, as Hear it showed it; after each line the
// learner says it back with Say it's recorder and feedback, then "Next line".
// On the last line the button reads "Continue", which stores step_reached =
// 'hear'. The screen itself is SpeakLines in SayIt.tsx, shared with the recap.

export function HearIt(props: StepScreenProps) {
  return <SpeakLines {...props} variant="hear" />
}
