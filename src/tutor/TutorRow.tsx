import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { Sheet } from '../components/Sheet.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { TUTOR_NOTICE } from '../lib/tutor-consent.ts'
import type { TutorState } from '../lib/tutor-types.ts'
import { OtsoAvatar } from './OtsoAvatar.tsx'
import { chooseTutor, loadTutor } from './tutor-api.ts'
import styles from './Tutor.module.css'

// The "Talk with Otso" row of the account page (factory/jobs/16-tutor-step/spec.md, "Done when" 6).
// It shows the learner's current choice. Turning Otso off is one tap and takes effect at once;
// turning him on first shows the same consent text as the lesson, so the choice is informed. There
// is nothing stored to delete. The row is left out when the tutor is not set up.

export function TutorRow({ rowClass, valueClass }: { rowClass: string; valueClass: string }) {
  const [state, setState] = useState<TutorState | null>(null)
  const [asking, setAsking] = useState(false)
  const [busy, setBusy] = useState(false)
  const [problem, setProblem] = useState(false)
  const button = useRef<HTMLButtonElement>(null)
  const titleId = useId()

  useEffect(() => {
    let active = true
    void loadTutor().then((loaded) => {
      if (active) setState(loaded)
    })
    return () => {
      active = false
    }
  }, [])

  if (!state?.available) return null
  const on = state.consent === 'granted'

  async function choose(choice: 'on' | 'off') {
    setBusy(true)
    setProblem(false)
    const saved = await chooseTutor(choice)
    setBusy(false)
    if (!saved) {
      setProblem(true)
      return
    }
    setAsking(false)
    setState((now) => (now ? { ...now, consent: choice === 'on' ? 'granted' : 'withdrawn' } : now))
  }

  return (
    <li>
      <button
        ref={button}
        type="button"
        className={rowClass}
        aria-busy={busy || undefined}
        onClick={() => {
          if (busy) return
          if (on) void choose('off')
          else setAsking(true)
        }}
      >
        <span>Talk with Otso</span>
        <span className={valueClass}>{on ? 'On' : 'Off'}</span>
      </button>
      {problem && !asking && (
        <StatusLine tone="problem">
          Your choice was not saved. Check your internet connection, then try again.
        </StatusLine>
      )}
      <Sheet
        open={asking}
        onClose={() => {
          setAsking(false)
        }}
        labelledBy={titleId}
        returnFocus={button}
      >
        <div className={styles.sheetBody}>
          <div className={styles.cardHead}>
            <OtsoAvatar />
            <h2 id={titleId} className={styles.cardTitle}>
              {TUTOR_NOTICE.heading}
            </h2>
          </div>
          {TUTOR_NOTICE.paragraphs.map((text) => (
            <p key={text} className={styles.cardText}>
              {text}
            </p>
          ))}
          {problem && (
            <StatusLine tone="problem">
              Your choice was not saved. Check your internet connection, then try again.
            </StatusLine>
          )}
          <Button block busy={busy} busyLabel="Saving your choice." onClick={() => void choose('on')}>
            {TUTOR_NOTICE.turnOn}
          </Button>
          <Button
            variant="quiet"
            onClick={() => {
              setAsking(false)
            }}
          >
            {TUTOR_NOTICE.notNow}
          </Button>
        </div>
      </Sheet>
    </li>
  )
}
