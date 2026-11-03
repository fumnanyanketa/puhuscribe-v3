import { useEffect, useRef, type RefObject } from 'react'
import styles from './FirstLessonTip.module.css'

// The tip on a learner's first lesson (job 19-redesign, statement 25). Before
// Hear it is finished, the line card stays lit, the rest of the screen dims
// (the frame draws the scrim), and three short lines say what the card shows:
// "How people say it" (mint dot), "How it's written" (slate dot) and "Tap any
// word to learn it" (peach ring). Since Hear it, say it (fast route
// hear-and-say, 3 November 2026) one plain sentence follows, "After each line,
// say it back.", then the "Got it" button. Whether it shows
// comes from the session answer (firstLesson); nothing is kept on the phone.
//
// It follows the dialog rules of the word card (job 5): focus moves to "Got it"
// when it opens and back to what the screen names when it closes, Escape closes
// it, Tab cannot leave the lit card and the tip, and the page behind cannot be
// used or scrolled. A word card opened from the lit card is a modal dialog of
// its own and takes over both keys while it is open.

interface FirstLessonTipProps {
  /** The lit card and this tip: the only place Tab may go while it is open. */
  region: RefObject<HTMLElement | null>
  /** Where focus goes when the tip closes: "Next line", or "I can't speak right now" before a try. */
  restoreFocusTo: RefObject<HTMLElement | null>
  onClose: () => void
}

/** The tip's one sentence on Hear it, say it (fast route hear-and-say, 3 November 2026). */
export const TIP_SAY_BACK = 'After each line, say it back.'

const FOCUSABLE = 'button:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])'

function anotherDialogIsOpen(): boolean {
  return document.querySelector('dialog[open]') !== null
}

export function FirstLessonTip({ region, restoreFocusTo, onClose }: FirstLessonTipProps) {
  const gotIt = useRef<HTMLButtonElement>(null)
  const closing = useRef(onClose)
  useEffect(() => {
    closing.current = onClose
  }, [onClose])

  useEffect(() => {
    const area = region.current
    const root = document.documentElement
    const before = root.style.overflow
    root.style.overflow = 'hidden'
    gotIt.current?.focus()

    const onKey = (event: KeyboardEvent) => {
      if (anotherDialogIsOpen()) return
      if (event.key === 'Escape') {
        event.preventDefault()
        closing.current()
        return
      }
      if (event.key !== 'Tab' || !area) return
      const items = [...area.querySelectorAll<HTMLElement>(FOCUSABLE)]
      const first = items.at(0)
      const last = items.at(-1)
      if (!first || !last) return
      const active = document.activeElement
      const inside = active instanceof Node && area.contains(active)
      if (event.shiftKey && (active === first || !inside)) {
        event.preventDefault()
        last.focus()
      } else if (!event.shiftKey && (active === last || !inside)) {
        event.preventDefault()
        first.focus()
      }
    }
    const onFocusIn = (event: FocusEvent) => {
      if (anotherDialogIsOpen()) return
      if (area && event.target instanceof Node && !area.contains(event.target)) gotIt.current?.focus()
    }
    document.addEventListener('keydown', onKey, true)
    document.addEventListener('focusin', onFocusIn)
    // The ref itself, read when the tip closes (see below).
    const back = restoreFocusTo
    return () => {
      document.removeEventListener('keydown', onKey, true)
      document.removeEventListener('focusin', onFocusIn)
      root.style.overflow = before
      // Back to what the screen names, once the tip has gone. Read now, not when the tip opened: in
      // Hear it, say it that button appears only after speaking feedback has loaded.
      setTimeout(() => {
        back.current?.focus()
      }, 0)
    }
  }, [region, restoreFocusTo])

  return (
    <div className={styles.tip} role="dialog" aria-modal="true" aria-label="How this screen works">
      <ul className={styles.legend}>
        <li>
          <span className={styles.dotSpoken} aria-hidden="true" />
          How people say it
        </li>
        <li>
          <span className={styles.dotWritten} aria-hidden="true" />
          How it&apos;s written
        </li>
        <li>
          <span className={styles.ring} aria-hidden="true" />
          Tap any word to learn it
        </li>
      </ul>
      <p className={styles.sayBack}>{TIP_SAY_BACK}</p>
      <button type="button" className={styles.gotIt} ref={gotIt} onClick={onClose}>
        Got it
      </button>
    </div>
  )
}
