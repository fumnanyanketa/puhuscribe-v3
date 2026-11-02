import { useRef, useState, type MouseEvent } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { useSteadyPress } from '../lib/use-steady-press.ts'
import { FirstLessonTip } from './FirstLessonTip.tsx'
import { LineCard } from './LineCard.tsx'
import { NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'

// Hear it (factory/jobs/8-first-session/spec.md, "Done when" 9 and 10; redrawn
// in job 19-redesign, statements 24 and 25). The dialogue one line card at a
// time (owner's call 6, answer A): "Next line" shows the next line, and on the
// last line the button reads "Continue", which stores step_reached = 'hear'.
// Nothing plays by itself. The status line says which line of how many is
// showing, so a new line is announced to screen readers; it is not drawn,
// because the card says "Line 2 of 8" too. The card shows the dialogue's lines
// only: the dialogue title and the can do sentence are not on this screen.
//
// On the learner's first lesson only, before Hear it is finished, the tip
// explains the card (src/screens/FirstLessonTip.tsx).

export function HearIt({ session, frame, onDone }: StepScreenProps) {
  const lines = session.lines
  const [shown, setShown] = useState(1)
  const [saving, setSaving] = useState(false)
  const [failed, setFailed] = useState(false)
  const [tip, setTip] = useState(session.firstLesson === true)
  const next = useRef<HTMLButtonElement>(null)
  const steady = useSteadyPress()
  const region = useRef<HTMLElement>(null)
  const last = shown >= lines.length
  const line = lines.at(shown - 1)

  async function advance(event: MouseEvent) {
    if (!steady.accept(event)) return
    if (!last) {
      setShown(shown + 1)
      return
    }
    setSaving(true)
    setFailed(false)
    const saved = await onDone()
    if (!saved) {
      setSaving(false)
      setFailed(true)
    }
  }

  const actions = (
    <>
      <StatusLine tone={failed ? 'problem' : 'neutral'} visuallyHidden={!failed}>
        {failed ? NOT_SAVED : `Line ${String(shown)} of ${String(lines.length)}.`}
      </StatusLine>
      <Button
        block
        ref={next}
        busy={saving}
        busyLabel="Saving your progress."
        onPointerDown={steady.onPointerDown}
        onClick={(event) => void advance(event)}
      >
        {last ? 'Continue' : 'Next line'}
      </Button>
    </>
  )

  return (
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      progress={shown / Math.max(1, lines.length)}
      leaveHref={PATHS.home}
      stepHeading
      dim={tip}
      actions={actions}
    >
      <main className={styles.main} ref={region}>
        {line && <LineCard key={line.id} line={line} count={{ shown, of: lines.length }} showGloss />}
        {tip && (
          <FirstLessonTip
            region={region}
            restoreFocusTo={next}
            onClose={() => {
              setTip(false)
            }}
          />
        )}
      </main>
    </SessionFrame>
  )
}
