import { useRef, useState } from 'react'
import type { LineWord, WordCardData } from './finnish.ts'
import { WordCard } from './WordCard.tsx'
import styles from './FinnishLine.module.css'

// A dialogue line (design.md, "Finnish line and word card"), in v2's register
// pairing: spoken Finnish first on a teal band, the written line under it,
// both labelled in text and marked lang="fi", joined by a connector. The
// words that change between the two are azure. Every word with a card is a
// button that opens it; the card returns focus to the same word on close. A
// word without a card (such as a name) is plain text.

interface FinnishLineProps {
  spoken: LineWord[]
  written: LineWord[]
  /** Index of the spoken word being spoken right now, if any. */
  current?: number
  /** Passed to each word card, such as "Sample, not reviewed." on design pages. */
  cardNote?: string
  /** Passed to each word card: what its two play controls play. */
  cardAudioWhat?: { spoken: string; written: string }
  /** Passed to each word card: one plain line under its play controls. */
  cardAudioCaption?: string
}

type Which = 'spoken' | 'written'

/** Read after a marked word by screen readers. */
export const MARKED_NAME = ', the missing word'

function Words({
  words,
  which,
  current,
  onOpen,
  register,
}: {
  words: LineWord[]
  which: Which
  current: number
  onOpen: (which: Which, index: number) => void
  register: (key: string, element: HTMLButtonElement | null) => void
}) {
  return words.map((word, i) => {
    // The button is the 44 px tap area; the face inside it carries the wash
    // and the lit block at text height.
    const face = [styles.face]
    if (word.changes) face.push(styles.changed)
    if (i === current) face.push(styles.current)
    if (word.marked) face.push(styles.marked)
    // The answer word after a review is underlined and also named in words,
    // so colour or line is never the only sign.
    const marker = word.marked ? (
      <span className={styles.hidden} lang="en">
        {MARKED_NAME}
      </span>
    ) : null
    // Each word and its punctuation sit in one span that does not wrap, so a
    // "?" or a comma never drops onto a line of its own (design review,
    // job 8 round 1). The button stays the word's one tap target.
    if (!word.card) {
      return (
        <span key={i}>
          {i > 0 && ' '}
          <span className={styles.keep} data-word="">
            {word.before}
            <span className={styles.plain} aria-current={i === current ? 'true' : undefined}>
              <span className={face.join(' ')}>{word.text}</span>
              {marker}
            </span>
            {word.after}
          </span>
        </span>
      )
    }
    return (
      <span key={i}>
        {i > 0 && ' '}
        <span className={styles.keep} data-word="">
          {word.before}
          <button
            type="button"
            className={styles.word}
            aria-current={i === current ? 'true' : undefined}
            aria-haspopup="dialog"
            ref={(element) => {
              register(`${which}-${String(i)}`, element)
            }}
            onClick={() => {
              onOpen(which, i)
            }}
          >
            <span className={face.join(' ')}>{word.text}</span>
            {marker}
          </button>
          {word.after}
        </span>
      </span>
    )
  })
}

export function FinnishLine({
  spoken,
  written,
  current = -1,
  cardNote,
  cardAudioWhat,
  cardAudioCaption,
}: FinnishLineProps) {
  const [open, setOpen] = useState<{ which: Which; index: number } | null>(null)
  const buttons = useRef(new Map<string, HTMLButtonElement>())

  function register(key: string, element: HTMLButtonElement | null) {
    if (element) buttons.current.set(key, element)
    else buttons.current.delete(key)
  }

  function close() {
    const back = open && buttons.current.get(`${open.which}-${String(open.index)}`)
    setOpen(null)
    // Back to the same word, once the card has closed.
    if (back)
      setTimeout(() => {
        back.focus()
      }, 0)
  }

  let card: WordCardData | null = null
  if (open) card = (open.which === 'spoken' ? spoken : written)[open.index]?.card ?? null

  const openCard = (which: Which, index: number) => {
    setOpen({ which, index })
  }

  return (
    <div className={styles.pair}>
      <div className={styles.rail} aria-hidden="true">
        <span className={styles.dotSpoken} />
        <span className={styles.connector} />
        <span className={styles.dotWritten} />
      </div>
      <div className={styles.registers}>
        <div className={styles.spokenBand}>
          <p className={styles.labelSpoken}>Spoken</p>
          <p className={styles.spokenLine} lang="fi">
            <Words words={spoken} which="spoken" current={current} onOpen={openCard} register={register} />
          </p>
        </div>
        <div className={styles.written}>
          <p className={styles.labelWritten}>Written</p>
          <p className={styles.writtenLine} lang="fi">
            <Words words={written} which="written" current={-1} onOpen={openCard} register={register} />
          </p>
        </div>
      </div>
      <WordCard
        data={card}
        onClose={close}
        note={cardNote}
        audioWhat={cardAudioWhat}
        audioCaption={cardAudioCaption}
      />
    </div>
  )
}
