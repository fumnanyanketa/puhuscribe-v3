import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import {
  ADD_EMAIL_PATH,
  SAVE_NOTE_ADD,
  SAVE_NOTE_CLOSED,
  SAVE_NOTE_LATER,
  SAVE_NOTE_REGION,
  SAVE_NOTE_SENTENCE,
} from './save-note-copy.ts'
import styles from './SaveNote.module.css'

// The note on the finish screen that asks a guest to add an email
// (factory/jobs/18-save-progress/spec.md, "Done when" 1, 10 to 12 and 15).
// A block in the page, never a dialog: no focus trap, no overlay, no timer, no
// animation, and it does not take focus when it appears. "Done" is untouched.
// "Not now" sends nothing and stores nothing: the note is replaced by one plain
// line, and focus moves to that line. Neither the note nor the line is a
// status or an alert, because the finish screen has exactly one status line.

export function SaveNote() {
  const [closed, setClosed] = useState(false)
  const closedLine = useRef<HTMLParagraphElement>(null)

  useEffect(() => {
    if (closed) closedLine.current?.focus()
  }, [closed])

  if (closed) {
    return (
      <p ref={closedLine} tabIndex={-1} className={styles.closed}>
        {SAVE_NOTE_CLOSED}
      </p>
    )
  }

  return (
    <section aria-label={SAVE_NOTE_REGION} className={styles.note}>
      <p className={styles.sentence}>{SAVE_NOTE_SENTENCE}</p>
      <div className={styles.actions}>
        <Button
          variant="secondary"
          onClick={() => {
            window.location.assign(ADD_EMAIL_PATH)
          }}
        >
          {SAVE_NOTE_ADD}
        </Button>
        <Button
          variant="quiet"
          onClick={() => {
            setClosed(true)
          }}
        >
          {SAVE_NOTE_LATER}
        </Button>
      </div>
    </section>
  )
}
