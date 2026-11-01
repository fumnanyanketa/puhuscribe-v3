import { useId, useRef, useState } from 'react'
import { Button } from './Button.tsx'
import { PlayControl } from './PlayControl.tsx'
import { Sheet } from './Sheet.tsx'
import type { WordCardData } from './finnish.ts'
import styles from './WordCard.module.css'

// The word card (design.md, "Word card"): grammar is a card behind a tap. A
// bottom sheet, opened as a native <dialog> with showModal() so the page behind
// cannot be used; it rises from the bottom on a phone. It shows the word large
// with a play button, what it means, two tiles "People say" (mint) and "Books
// write" (slate) each with a play button, the dictionary form, and "Why does it
// change?" behind one more tap. It closes with the close button, the Escape
// key, or a tap outside it. Focus moves into the card when it opens; the Finnish
// line returns it to the word when it closes. While it is open the page behind
// cannot scroll.
//
// Audio exists per line only (job 8, Decision 6): every play button plays the
// whole line in its register, its name says so, and one plain caption says
// "Plays the whole line." The two meaning lines come from word data that may
// be missing; when it is, the line is left out and no text is invented.

interface WordCardProps {
  data: WordCardData | null
  onClose: () => void
  /** A line shown at the foot of the card, such as "Sample, not reviewed." on design pages. */
  note?: string
  /**
   * What the two register tiles play, as in "the spoken form". Session screens
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

function Close() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M6 6l12 12M18 6L6 18" />
    </svg>
  )
}

export function WordCard({
  data,
  onClose,
  note,
  audioWhat = FORM_AUDIO,
  audioCaption,
  onPatterns,
}: WordCardProps) {
  const heading = useRef<HTMLHeadingElement>(null)
  const titleId = useId()
  const whyId = useId()
  const [why, setWhy] = useState(false)

  function close() {
    setWhy(false)
    onClose()
  }

  return (
    <Sheet open={data !== null} onClose={close} labelledBy={titleId} initialFocus={heading}>
      {data && (
        <>
          <div className={styles.top}>
            <div className={styles.wordRow}>
              <h2 id={titleId} ref={heading} tabIndex={-1} className={styles.word} lang="fi">
                {data.word}
              </h2>
              <PlayControl src={data.spoken.audio} what={audioCaption ? 'the line' : 'the word'} />
            </div>
            <button type="button" className={styles.close} onClick={close} aria-label="Close">
              <Close />
            </button>
          </div>
          {data.meaning && <p className={styles.meaning}>{data.meaning}</p>}
          <div className={styles.tiles}>
            <div className={styles.tileSpoken}>
              <div>
                <p className={styles.tileLabelSpoken}>People say</p>
                <p className={styles.tileText} lang="fi">
                  {data.spoken.text}
                </p>
              </div>
              <PlayControl src={data.spoken.audio} what={audioWhat.spoken} size="small" />
            </div>
            <div className={styles.tileWritten}>
              <div>
                <p className={styles.tileLabelWritten}>Books write</p>
                <p className={styles.tileTextWritten} lang="fi">
                  {data.written.text}
                </p>
              </div>
              <PlayControl src={data.written.audio} what={audioWhat.written} size="small" tone="written" />
            </div>
          </div>
          {audioCaption && <p className={styles.note}>{audioCaption}</p>}
          <p className={styles.dictionary}>
            <span className={styles.dictionaryLabel}>Dictionary form</span>
            <span className={styles.dictionaryValue}>
              <span className={styles.base} lang="fi">
                {data.baseForm}
              </span>
              {data.baseMeaning && <span> {data.baseMeaning}</span>}
            </span>
          </p>
          <Button
            variant="quiet"
            className={styles.whyButton}
            aria-expanded={why}
            aria-controls={whyId}
            onClick={() => {
              setWhy(!why)
            }}
          >
            Why does it change?
          </Button>
          {why && (
            <p id={whyId} className={styles.why}>
              <span className={styles.whyForm}>{data.formName}.</span> {data.why}
            </p>
          )}
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
          {note && <p className={styles.note}>{note}</p>}
        </>
      )}
    </Sheet>
  )
}
