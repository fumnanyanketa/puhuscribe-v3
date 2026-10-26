import { useCallback, useState } from 'react'
import { FinnishLine } from '../components/FinnishLine.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import type { LineWord } from '../components/finnish.ts'
import type { SessionLine, SessionWord } from '../lib/session-types.ts'
import { useOpenPatterns } from './patterns-context.ts'
import styles from './Screens.module.css'

// One dialogue line in a session (factory/jobs/8-first-session/spec.md,
// "Done when" 9, 10 and 12): the speaker, the spoken Finnish on the teal band
// with the written Finnish under it, and a play control for each register.
// Every word with a readable form opens its word card; the card's two play
// controls play the whole line in each register (Decision 6). While either of
// the line's controls plays, the card is ringed and says "Playing" in words,
// so colour is never the only sign (Decision 7).

export const LINE_AUDIO = { spoken: 'the spoken line', written: 'the written line' }
/** Under the word card's play controls: they play the line, not the one word (Decision 6). */
export const CARD_AUDIO_CAPTION = 'Plays the whole line.'

/**
 * The Finnish line's words, with their cards, from the Worker's words. The
 * words at the indexes in `marked` are the answer of a review (job 9).
 */
export function lineWords(
  words: readonly SessionWord[],
  line: SessionLine,
  marked: readonly number[] = [],
): LineWord[] {
  return words.map((word, index) => {
    const form = word.form
    return {
      text: word.text,
      before: word.before,
      after: word.after,
      changes: form ? form.spoken !== form.written : false,
      ...(marked.includes(index) ? { marked: true } : {}),
      card: form
        ? {
            word: word.text,
            baseForm: form.lemma,
            formName: form.formName,
            why: form.why,
            spoken: { text: form.spoken, audio: line.spokenAudio },
            written: { text: form.written, audio: line.writtenAudio },
          }
        : undefined,
    }
  })
}

/** True when any word of the line is shown as changed. */
export function hasChangedWords(line: SessionLine): boolean {
  return [...line.spoken, ...line.written].some((word) => word.form && word.form.spoken !== word.form.written)
}

interface LineCardProps {
  line: SessionLine
  /** Show the speaker's name as a heading (Hear it) or as plain text. */
  speakerAs?: 'h2' | 'p'
  /** Show the line's English meaning under it (the finish screen). */
  showGloss?: boolean
  /** The answer words of a review, by index in each register (job 9-daily-review). */
  marked?: { spoken: readonly number[]; written: readonly number[] }
}

export function LineCard({ line, speakerAs = 'h2', showGloss = false, marked }: LineCardProps) {
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

  return (
    <div className={now ? `${styles.card} ${styles.cardNow}` : styles.card} data-line-id={line.id}>
      <Speaker className={styles.speaker}>
        {line.speaker}
        {now && <span className={styles.nowPlaying}> Playing</span>}
      </Speaker>
      <FinnishLine
        spoken={lineWords(line.spoken, line, marked?.spoken)}
        written={lineWords(line.written, line, marked?.written)}
        cardAudioWhat={LINE_AUDIO}
        cardAudioCaption={CARD_AUDIO_CAPTION}
        cardOnPatterns={openPatterns ?? undefined}
      />
      {showGloss && <p className={styles.gloss}>{line.gloss}</p>}
      <div className={styles.lineControls}>
        <span className={styles.lineControl}>
          <PlayControl
            src={line.spokenAudio}
            what={LINE_AUDIO.spoken}
            size="small"
            onPlayingChange={spokenChange}
          />
          <span className={styles.controlLabel}>Spoken</span>
        </span>
        <span className={styles.lineControl}>
          <PlayControl
            src={line.writtenAudio}
            what={LINE_AUDIO.written}
            size="small"
            onPlayingChange={writtenChange}
          />
          <span className={styles.controlLabel}>Written</span>
        </span>
      </div>
    </div>
  )
}
