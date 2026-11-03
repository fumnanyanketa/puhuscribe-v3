import { useEffect, useId, useRef, useState } from 'react'
import { wordClip } from '../lib/word-audio.ts'
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
// Audio (job 8, Decision 6, and job word-audio): on session screens (those that
// pass audioCaption) every play button plays the whole line in its register,
// its name says so, and one hidden caption says "Plays the whole line." When
// the owner has approved a word's own clip (src/lib/word-audio.ts), that
// register's tile plays the word ("Play the spoken word"), the button beside
// the large word plays the word in the register it was tapped in ("Play the
// word"), and one more control, "Play the whole line", keeps the line one tap
// away. A register without an approved clip plays the line exactly as before.
// The two meaning lines come from word data that may be missing; when it is,
// the line is left out and no text is invented.

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

interface WordClips {
  /** The two texts these answers belong to, so an answer for an earlier card is never used. */
  texts: string
  spoken: string | null
  written: string | null
}

/**
 * The approved clips of the card's two forms, or none. Only asked for when
 * `on` (session screens). Keyed by the texts, because the card's data is a new
 * object on every render of the line.
 */
function useWordClips(data: WordCardData | null, on: boolean): WordClips {
  const spokenText = data?.spoken.text ?? ''
  const writtenText = data?.written.text ?? ''
  const texts = `${spokenText}\n${writtenText}`
  const [clips, setClips] = useState<WordClips>({ texts: '', spoken: null, written: null })
  useEffect(() => {
    if (!on || !spokenText || !writtenText) return
    let live = true
    void Promise.all([wordClip(spokenText), wordClip(writtenText)]).then(([spoken, written]) => {
      if (live) setClips({ texts, spoken, written })
    })
    return () => {
      live = false
    }
  }, [on, spokenText, writtenText, texts])
  return on && clips.texts === texts ? clips : { texts, spoken: null, written: null }
}

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
  const clips = useWordClips(data, audioCaption !== undefined)

  function close() {
    setWhy(false)
    onClose()
  }

  // The register the word was tapped in: the written one when the word as shown
  // is the written form and that differs from the spoken one.
  const tapped =
    data &&
    data.written.text !== data.spoken.text &&
    data.word.toLocaleLowerCase('fi') === data.written.text.toLocaleLowerCase('fi')
      ? 'written'
      : 'spoken'
  const hasClip = clips.spoken !== null || clips.written !== null
  const tappedClip = tapped === 'written' ? clips.written : clips.spoken

  // Each control gets a key from its source, so a clip found after the card
  // opened replaces the line in a fresh control instead of a stale one.
  const wordSrc = tappedClip ?? data?.spoken.audio ?? ''
  const wordWhat = tappedClip ? 'the word' : audioCaption ? 'the line' : 'the word'
  const spokenSrc = clips.spoken ?? data?.spoken.audio ?? ''
  const spokenWhat = clips.spoken ? 'the spoken word' : audioWhat.spoken
  const writtenSrc = clips.written ?? data?.written.audio ?? ''
  const writtenWhat = clips.written ? 'the written word' : audioWhat.written
  const lineSrc = (tapped === 'written' ? data?.written.audio : data?.spoken.audio) ?? ''

  return (
    <Sheet open={data !== null} onClose={close} labelledBy={titleId} initialFocus={heading}>
      {data && (
        <>
          <div className={styles.top}>
            <div className={styles.wordRow}>
              <h2 id={titleId} ref={heading} tabIndex={-1} className={styles.word} lang="fi">
                {data.word}
              </h2>
              <PlayControl key={wordSrc} src={wordSrc} what={wordWhat} />
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
              <PlayControl key={spokenSrc} src={spokenSrc} what={spokenWhat} size="small" />
            </div>
            <div className={styles.tileWritten}>
              <div>
                <p className={styles.tileLabelWritten}>Books write</p>
                <p className={styles.tileTextWritten} lang="fi">
                  {data.written.text}
                </p>
              </div>
              <PlayControl key={writtenSrc} src={writtenSrc} what={writtenWhat} size="small" tone="written" />
            </div>
          </div>
          {hasClip && (
            <div className={styles.wholeLine}>
              <PlayControl
                key={lineSrc}
                src={lineSrc}
                what="the whole line"
                size="small"
                tone={tapped === 'written' ? 'written' : 'spoken'}
              />
              <span className={styles.wholeLineLabel} aria-hidden="true">
                The whole line
              </span>
            </div>
          )}
          {/* Not drawn (round 6): the play buttons' names already say they play the line. */}
          {audioCaption && !hasClip && <p className={styles.hidden}>{audioCaption}</p>}
          <p className={styles.dictionary}>
            <span className={styles.dictionaryLabel}>Dictionary form</span>
            <span className={styles.dictionaryValue}>
              <span className={styles.base} lang="fi">
                {data.baseForm}
              </span>
              {data.baseMeaning && <span className={styles.baseMeaning}> {data.baseMeaning}</span>}
            </span>
          </p>
          <Button
            variant="mint"
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
              variant="mint"
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
