import { useEffect, useId, useRef, type MouseEvent, type SyntheticEvent } from 'react'
import { Button } from './Button.tsx'
import { PlayControl } from './PlayControl.tsx'
import type { WordCardData } from './finnish.ts'
import styles from './WordCard.module.css'

// The word card (design.md, "Finnish line and word card"): grammar is a card
// behind a tap. A native <dialog>, opened with showModal() so the page behind
// cannot be used; it rises from the bottom on a phone. It closes with the
// Close button, the Escape key, or a tap outside it. Focus moves into the card
// when it opens; the Finnish line returns it to the word when it closes.
// While it is open the page behind cannot scroll.

interface WordCardProps {
  data: WordCardData | null
  onClose: () => void
  /** A line shown at the foot of the card, such as "Sample, not reviewed." on design pages. */
  note?: string
  /**
   * What the two play controls play, as in "the spoken form". Session screens
   * play the whole line in each register (job 8, Decision 6), so they pass
   * "the spoken line" and "the written line".
   */
  audioWhat?: { spoken: string; written: string }
  /** One plain line under the play controls, such as "Plays the whole line." */
  audioCaption?: string
  /**
   * Session screens only (job 12-units-1-3, "Done when" 9): shows the text
   * button "Patterns you've seen" under the facts. Told the card's form name
   * and the button, so the panel can open at that form's group and give focus
   * back to the button when it closes. Without it the card is unchanged.
   */
  onPatterns?: (formName: string, button: HTMLButtonElement) => void
}

const FORM_AUDIO = { spoken: 'the spoken form', written: 'the written form' }

export function WordCard({
  data,
  onClose,
  note,
  audioWhat = FORM_AUDIO,
  audioCaption,
  onPatterns,
}: WordCardProps) {
  const dialog = useRef<HTMLDialogElement>(null)
  const heading = useRef<HTMLHeadingElement>(null)
  const open = data !== null
  const titleId = useId()

  useEffect(() => {
    const element = dialog.current
    if (!element || !open) return undefined
    if (!element.open) element.showModal()
    const root = document.documentElement
    const before = root.style.overflow
    root.style.overflow = 'hidden'
    heading.current?.focus()
    return () => {
      root.style.overflow = before
      if (element.open) element.close()
    }
  }, [open])

  // Escape makes the browser fire "cancel"; the Finnish line does the closing.
  function cancel(event: SyntheticEvent<HTMLDialogElement>) {
    event.preventDefault()
    onClose()
  }

  // A tap on the dimmed page lands on the dialog element itself, because the
  // card's content fills an inner box.
  function tapOutside(event: MouseEvent<HTMLDialogElement>) {
    if (event.target === event.currentTarget) onClose()
  }

  return (
    // Escape already closes the dialog; the click only adds "tap outside".
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <dialog
      ref={dialog}
      className={styles.sheet}
      onCancel={cancel}
      onClick={tapOutside}
      aria-labelledby={titleId}
    >
      {data && (
        <div className={styles.body}>
          <div className={styles.top}>
            <h2 id={titleId} ref={heading} tabIndex={-1} className={styles.word} lang="fi">
              {data.word}
            </h2>
            <button type="button" className={styles.close} onClick={onClose}>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
              Close
            </button>
          </div>
          <dl className={styles.facts}>
            <div>
              <dt>Base form</dt>
              <dd lang="fi">{data.baseForm}</dd>
            </div>
            <div>
              <dt>Form</dt>
              <dd>{data.formName}</dd>
            </div>
            <div>
              <dt>Why</dt>
              <dd>{data.why}</dd>
            </div>
          </dl>
          {onPatterns && (
            <Button
              variant="quiet"
              className={styles.patterns}
              aria-haspopup="dialog"
              onClick={(event) => {
                onPatterns(data.formName, event.currentTarget)
              }}
            >
              Patterns you&apos;ve seen
            </Button>
          )}
          <div className={styles.forms}>
            <div className={styles.formSpoken}>
              <div>
                <p className={styles.labelSpoken}>Spoken</p>
                <p className={styles.formText} lang="fi">
                  {data.spoken.text}
                </p>
              </div>
              <PlayControl src={data.spoken.audio} what={audioWhat.spoken} size="small" />
            </div>
            <div className={styles.formWritten}>
              <div>
                <p className={styles.labelWritten}>Written</p>
                <p className={styles.formText} lang="fi">
                  {data.written.text}
                </p>
              </div>
              <PlayControl src={data.written.audio} what={audioWhat.written} size="small" />
            </div>
          </div>
          {audioCaption && <p className={styles.note}>{audioCaption}</p>}
          {note && <p className={styles.note}>{note}</p>}
        </div>
      )}
    </dialog>
  )
}
