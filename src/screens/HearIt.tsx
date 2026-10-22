import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { CanDo } from './CanDo.tsx'
import { LineCard, hasChangedWords } from './LineCard.tsx'
import { CHANGED_HINT, NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'

// Hear it (factory/jobs/8-first-session/spec.md, "Done when" 9 and 10). The
// dialogue line by line: "Next line" adds the next line under the earlier
// ones, which stay. On the last line the button reads "Continue", which
// stores step_reached = 'hear'. Nothing plays by itself. The status line
// says which line of how many is showing, so a new line is announced to
// screen readers (design review, round 1).

const HELP = 'Press play to hear each line. Tap a word for its card.'

export function HearIt({ session, frame, onDone }: StepScreenProps) {
  const lines = session.lines
  const [shown, setShown] = useState(1)
  const [saving, setSaving] = useState(false)
  const [failed, setFailed] = useState(false)
  const newest = useRef<HTMLLIElement>(null)
  const last = shown >= lines.length

  useEffect(() => {
    if (shown > 1) newest.current?.scrollIntoView({ block: 'nearest' })
  }, [shown])

  async function next() {
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

  const visible = lines.slice(0, shown)
  const actions = (
    <>
      <StatusLine tone={failed ? 'problem' : 'neutral'}>
        {failed ? NOT_SAVED : `Line ${String(shown)} of ${String(lines.length)}.`}
      </StatusLine>
      <Button block busy={saving} busyLabel="Saving your progress." onClick={() => void next()}>
        {last ? 'Continue' : 'Next line'}
      </Button>
    </>
  )

  return (
    <SessionFrame step={frame.step} steps={frame.steps} leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 className={styles.title}>Hear it</h1>
          <p className={styles.lead}>{session.dialogue.title}</p>
          <CanDo text={session.unit.canDo} className={styles.canDo} />
          <p className={styles.help}>{HELP}</p>
          {visible.some(hasChangedWords) && <p className={styles.hint}>{CHANGED_HINT}</p>}
        </div>
        <ol className={styles.dialogue}>
          {visible.map((line, i) => (
            <li key={line.id} ref={i === shown - 1 ? newest : undefined}>
              <LineCard line={line} />
            </li>
          ))}
        </ol>
      </main>
    </SessionFrame>
  )
}
