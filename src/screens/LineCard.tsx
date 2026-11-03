import { useCallback, useState } from 'react'
import { FinnishLine } from '../components/FinnishLine.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import type { LineWord } from '../components/finnish.ts'
import type { SessionLine, SessionWord } from '../lib/session-types.ts'
import { useOpenPatterns } from './patterns-context.ts'
import styles from './Screens.module.css'

// One dialogue line in a session (factory/jobs/8-first-session/spec.md, "Done
// when" 9, 10 and 12; redrawn in job 19-redesign, statement 23): the speaker's
// name, "Line 2 of 8", the spoken line and the written line joined by two dots,
// a play button on each line, and the English meaning under a dashed line. Every
// word with a readable form opens its word card; the card's play buttons play
// the whole line in each register (Decision 6). While either of the line's
// controls plays, the card is ringed and says "Playing" in words, so colour is
// never the only sign (Decision 7).

export const LINE_AUDIO = { spoken: 'the spoken line', written: 'the written line' }
/** Under the word card's play controls: they play the line, not the one word (Decision 6). */
export const CARD_AUDIO_CAPTION = 'Plays the whole line.'

/**
 * The Finnish line's words, with their cards, from the Worker's words. The
 * words at the indexes in `marked` are the answer of a review (job 9). With
 * `showChanged` false, no word is drawn as changed (the Keep it result).
 */
export function lineWords(
  words: readonly SessionWord[],
  line: SessionLine,
  marked: readonly number[] = [],
  showChanged = true,
): LineWord[] {
  return words.map((word, index) => {
    const form = word.form
    return {
      text: word.text,
      before: word.before,
      after: word.after,
      changes: showChanged && form ? form.spoken !== form.written : false,
      ...(marked.includes(index) ? { marked: true } : {}),
      card: form
        ? {
            word: word.text,
            baseForm: form.lemma,
            formName: form.formName,
            why: form.why,
            ...(form.meaning ? { meaning: form.meaning } : {}),
            ...(form.baseMeaning ? { baseMeaning: form.baseMeaning } : {}),
            spoken: { text: form.spoken, audio: line.spokenAudio },
            written: { text: form.written, audio: line.writtenAudio },
          }
        : undefined,
    }
  })
}

/**
 * The line's English meaning under the card's dashed line, with a small quiet "Meaning" in front
 * (owner's call, 3 November 2026: the English looked hidden). Screen readers hear "Meaning: ..."
 * through a colon that only they get. Hear it and the review card of Keep it share it.
 */
export function Meaning({ english }: { english: string }) {
  return (
    <p className={styles.gloss} data-meaning="">
      <span className={styles.meaningLabel} data-meaning-label="">
        <span data-meaning-word="">Meaning</span>
        <span className={styles.visuallyHidden}>:</span>
      </span>{' '}
      <span className={styles.meaningText} data-meaning-text="">
        {english}
      </span>
    </p>
  )
}

/** True when any word of the line is shown as changed. */
export function hasChangedWords(line: SessionLine): boolean {
  return [...line.spoken, ...line.written].some((word) => word.form && word.form.spoken !== word.form.written)
}

interface LineCardProps {
  line: SessionLine
  /** Show the speaker's name as a heading or as plain text (the default). */
  speakerAs?: 'h2' | 'p'
  /** Show the line's English meaning under a dashed line (Hear it and the finish screen). */
  showGloss?: boolean
  /** "Line 2 of 8", at the top right of the card. Left out where the card has no play buttons. */
  count?: { shown: number; of: number }
  /** The play buttons on the two lines. On unless turned off (Say it and Keep it have none). */
  controls?: boolean
  /** Only the spoken line, larger, with its one play button (Understand it). */
  only?: 'spoken'
  /** The answer words of a review, by index in each register (job 9-daily-review). */
  marked?: { spoken: readonly number[]; written: readonly number[] }
  /**
   * Draw the box round the words that change between the two lines. On unless turned off: the Keep it
   * result turns it off, so the answer is the one marked word in each line, as drawn.
   */
  showChanged?: boolean
}

export function LineCard({
  line,
  speakerAs = 'p',
  showGloss = false,
  count,
  controls = true,
  only,
  marked,
  showChanged = true,
}: LineCardProps) {
  const [spokenPlaying, setSpokenPlaying] = useState(false)
  const [writtenPlaying, setWrittenPlaying] = useState(false)
  const spokenChange = useCallback((isPlaying: boolean) => {
    setSpokenPlaying(isPlaying)
  }, [])
  const writtenChange = useCallback((isPlaying: boolean) => {
    setWrittenPlaying(isPlaying)
  }, [])
  const now = spokenPlaying || writtenPlaying
  // Inside a session, each word card offers "Patterns you've seen" (job 12).
  const openPatterns = useOpenPatterns()
  const Speaker = speakerAs

  if (only === 'spoken') {
    return (
      // One card, as drawn: the line's own box is the card (round 2, design review), not a box inside a panel.
      <div className={now ? `${styles.cardBare} ${styles.cardNow}` : styles.cardBare} data-line-id={line.id}>
        <FinnishLine
          only="spoken"
          large
          spoken={lineWords(line.spoken, line, marked?.spoken, showChanged)}
          written={[]}
          spokenControl={
            <PlayControl src={line.spokenAudio} what={LINE_AUDIO.spoken} onPlayingChange={spokenChange} />
          }
          cardAudioWhat={LINE_AUDIO}
          cardAudioCaption={CARD_AUDIO_CAPTION}
          cardOnPatterns={openPatterns ?? undefined}
        />
      </div>
    )
  }

  return (
    <div className={now ? `${styles.card} ${styles.cardNow}` : styles.card} data-line-id={line.id}>
      <div className={styles.cardHead}>
        <Speaker className={styles.speaker}>
          {line.speaker}
          {now && <span className={styles.nowPlaying}> Playing</span>}
        </Speaker>
        {count && (
          <span className={styles.count}>
            Line {count.shown} of {count.of}
          </span>
        )}
      </div>
      <FinnishLine
        spoken={lineWords(line.spoken, line, marked?.spoken, showChanged)}
        written={lineWords(line.written, line, marked?.written, showChanged)}
        spokenControl={
          controls ? (
            <PlayControl src={line.spokenAudio} what={LINE_AUDIO.spoken} onPlayingChange={spokenChange} />
          ) : undefined
        }
        writtenControl={
          controls ? (
            <PlayControl
              src={line.writtenAudio}
              what={LINE_AUDIO.written}
              size="small"
              tone="written"
              onPlayingChange={writtenChange}
            />
          ) : undefined
        }
        cardAudioWhat={LINE_AUDIO}
        cardAudioCaption={CARD_AUDIO_CAPTION}
        cardOnPatterns={openPatterns ?? undefined}
      />
      {showGloss && <Meaning english={line.gloss} />}
    </div>
  )
}
