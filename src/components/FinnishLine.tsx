import { useRef, useState, type ReactNode } from 'react'
import type { LineWord, WordCardData } from './finnish.ts'
import { WordCard } from './WordCard.tsx'
import styles from './FinnishLine.module.css'

// A dialogue line (design.md, "Line card"), as drawn on 1 November 2026: the
// spoken line in a soft box with a play button at its end, the written line
// under it in slate with its own play button, and two dots joined by a dotted
// line at the left (mint for spoken, slate for written). There are no
// "Spoken" and "Written" labels: the two groups are named for screen readers,
// and both lines carry lang="fi". The words that change between the two are
// peach on a peach wash in both lines. Every word with a card is a button that
// opens it; the card returns focus to the same word on close. A word without a
// card (such as a name) is plain text, never a dead button.

interface FinnishLineProps {
  spoken: LineWord[]
  written: LineWord[]
  /** Index of the spoken word being spoken right now, if any. */
  current?: number
  /** The play control at the end of the spoken line (the session screens). */
  spokenControl?: ReactNode
  /** The play control at the end of the written line. */
  writtenControl?: ReactNode
  /** Only the spoken line, with no dots and no written line (Understand it). */
  only?: 'spoken'
  /** The larger spoken line of Understand it. */
  large?: boolean
  /** Passed to each word card, such as "Sample, not reviewed." on design pages. */
  cardNote?: string
  /** Passed to each word card: what its play controls play. */
  cardAudioWhat?: { spoken: string; written: string }
  /** Passed to each word card: one plain line under its play controls. */
  cardAudioCaption?: string
  /** Passed to each word card: opens "Patterns you've seen" (session screens only). */
  cardOnPatterns?: (formName: string, button: HTMLButtonElement) => void
}

type Which = 'spoken' | 'written'

/** Read after a marked word by screen readers. */
export const MARKED_NAME = ', the missing word'

/** What names each group for screen readers, in place of the old visible labels. */
export const SPOKEN_GROUP = 'How people say it'
export const WRITTEN_GROUP = 'How it is written'

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
    // Punctuation sits tight against its word: on the side where a "!" or a
    // quote touches the word, the face keeps almost no padding and the target
    // drops its negative margin, so "Hei!" never reads as "Hei !".
    const tight = [word.before ? styles.withBefore : '', word.after ? styles.withAfter : '']
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
            <span
              className={[styles.plain, ...tight].join(' ').trim()}
              aria-current={i === current ? 'true' : undefined}
            >
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
          <button
            type="button"
            className={[styles.word, ...tight].join(' ').trim()}
            aria-current={i === current ? 'true' : undefined}
            aria-haspopup="dialog"
            ref={(element) => {
              register(`${which}-${String(i)}`, element)
            }}
            onClick={() => {
              onOpen(which, i)
            }}
          >
            {/* The punctuation is inside the button, so a word too long for its line wraps with its "?" or its quote at the end of the last piece. Hidden from a screen reader, so the button's name stays the word. */}
            {word.before && <span aria-hidden="true">{word.before}</span>}
            <span className={face.join(' ')}>{word.text}</span>
            {marker}
            {word.after && <span aria-hidden="true">{word.after}</span>}
          </button>
        </span>
      </span>
    )
  })
}

export function FinnishLine({
  spoken,
  written,
  current = -1,
  spokenControl,
  writtenControl,
  only,
  large = false,
  cardNote,
  cardAudioWhat,
  cardAudioCaption,
  cardOnPatterns,
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
      {only !== 'spoken' && (
        <div className={styles.rail} aria-hidden="true">
          <span className={styles.dotSpoken} />
          <span className={styles.connector} />
          <span className={styles.dotWritten} />
        </div>
      )}
      <div className={styles.rows}>
        <div
          className={large ? `${styles.spokenRow} ${styles.large}` : styles.spokenRow}
          role="group"
          aria-label={SPOKEN_GROUP}
        >
          {/* Understand it: the play button sits before the line, on the left, as drawn (round 6). */}
          {large && spokenControl}
          <p className={styles.spokenLine} lang="fi">
            <Words words={spoken} which="spoken" current={current} onOpen={openCard} register={register} />
          </p>
          {!large && spokenControl}
        </div>
        {only !== 'spoken' && (
          <div className={styles.writtenRow} role="group" aria-label={WRITTEN_GROUP}>
            <p className={styles.writtenLine} lang="fi">
              <Words words={written} which="written" current={-1} onOpen={openCard} register={register} />
            </p>
            {writtenControl}
          </div>
        )}
      </div>
      <WordCard
        data={card}
        onClose={close}
        note={cardNote}
        audioWhat={cardAudioWhat}
        audioCaption={cardAudioCaption}
        onPatterns={cardOnPatterns}
      />
    </div>
  )
}
