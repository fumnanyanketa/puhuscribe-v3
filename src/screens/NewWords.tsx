import { useRef, useState } from 'react'
import { WordCard } from '../components/WordCard.tsx'
import type { NewWord } from '../lib/session-types.ts'
import { cardOf, newWordsHeading } from './new-words.ts'
import { CARD_AUDIO_CAPTION, LINE_AUDIO } from './LineCard.tsx'
import styles from './NewWords.module.css'

// The panel on the finish screen (job 19-redesign, statement 33, the owner's
// choice of 1 November 2026, option C of design-drafts/numbers-question.html):
// "11 new words" and the words themselves as chips. Each chip is a button that
// opens the word's card, like a word in a line. As drawn (round 6), five chips
// show, then "+6", which shows the rest. The heading counts the new words and
// nothing else: no score, no streak, no "lines said aloud".

/** As drawn (round 6): at most five chips, then a "+N" chip that shows the rest. */
export const CHIPS_SHOWN = 5

export function NewWords({ words }: { words: readonly NewWord[] }) {
  const [open, setOpen] = useState<number | null>(null)
  const [all, setAll] = useState(false)
  const chips = useRef(new Map<number, HTMLButtonElement>())
  if (words.length === 0) return null
  const hidden = all ? 0 : Math.max(0, words.length - CHIPS_SHOWN)
  const shown = hidden > 0 ? words.slice(0, CHIPS_SHOWN) : words
  const current = open === null ? undefined : words.at(open)

  function close() {
    const back = open === null ? undefined : chips.current.get(open)
    setOpen(null)
    // Back to the same chip, once the card has closed.
    if (back)
      setTimeout(() => {
        back.focus()
      }, 0)
  }

  return (
    <section className={styles.panel} aria-labelledby="new-words-heading">
      <h2 id="new-words-heading" className={styles.heading}>
        {newWordsHeading(words.length)}
      </h2>
      <ul className={styles.chips}>
        {shown.map((word, index) => (
          <li key={`${word.form.lemma}-${word.form.spoken}`}>
            <button
              type="button"
              className={styles.chip}
              aria-haspopup="dialog"
              lang="fi"
              ref={(element) => {
                if (element) chips.current.set(index, element)
                else chips.current.delete(index)
              }}
              onClick={() => {
                setOpen(index)
              }}
            >
              <span className={styles.pill}>{word.form.spoken}</span>
            </button>
          </li>
        ))}
        {hidden > 0 && (
          <li>
            <button
              type="button"
              className={styles.chip}
              aria-expanded={false}
              aria-label={`Show ${String(hidden)} more ${hidden === 1 ? 'word' : 'words'}`}
              onClick={() => {
                setAll(true)
                // The first of the words just shown gets focus, so the keyboard is not left on a button that has gone.
                setTimeout(() => {
                  chips.current.get(CHIPS_SHOWN)?.focus()
                }, 0)
              }}
            >
              <span className={`${styles.pill} ${styles.more}`}>+{hidden}</span>
            </button>
          </li>
        )}
      </ul>
      <WordCard
        data={current ? cardOf(current) : null}
        onClose={close}
        audioWhat={LINE_AUDIO}
        audioCaption={CARD_AUDIO_CAPTION}
      />
    </section>
  )
}
