import { useEffect, useRef, useState } from 'react'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { SAMPLE_DIALOGUE, type Word } from './sample-dialogue.ts'
import styles from './HearItSample.module.css'

// The design sample for job 5-design-system, round 1: the "Hear it" step of
// unit 1 at phone size, in v2's look, for the owner to review before the rest
// of the design system is built. There is no real audio yet. Play steps the
// highlight through the spoken words on a timer, and the page says so.

type PlayState = 'ready' | 'playing' | 'paused' | 'finished'

// How long each word stays lit, and the pause between the two speakers.
const WORD_MS = 450
const LINE_GAP_MS = 900

// Every spoken word in order, with the line it belongs to.
const SPOKEN = SAMPLE_DIALOGUE.flatMap((line, lineIndex) =>
  line.spoken.map((word, wordIndex) => ({ lineIndex, wordIndex, word })),
)

// The bar heights of the slim waveform, as percentages. A fixed pattern for
// the sample; real audio will draw its own.
const WAVE_BARS = Array.from({ length: 36 }, (_, i) =>
  Math.round(28 + 64 * Math.abs(Math.sin(i * 1.7) * Math.cos(i * 0.37))),
)

const MESSAGES: Record<PlayState, string> = {
  ready: 'No sound yet. Play lights up each word.',
  playing: 'Playing. Each word lights up as it is spoken.',
  paused: 'Paused. Press Play to carry on.',
  finished: 'That was the whole dialogue. Press Play to hear it again.',
}
const SAMPLE_END = 'This sample ends here. The next step, Understand it, is built in a later job.'

function Line({ words, current }: { words: Word[]; current: number }) {
  return words.map((word, i) => {
    const classes = [styles.word]
    if (word.changes) classes.push(styles.changed)
    if (i === current) classes.push(styles.current)
    return (
      <span key={i}>
        {i > 0 && ' '}
        <span className={classes.join(' ')} aria-current={i === current ? 'true' : undefined}>
          {word.text}
        </span>
        {word.after}
      </span>
    )
  })
}

export default function HearItSample() {
  const [state, setState] = useState<PlayState>('ready')
  // Index into SPOKEN of the word being spoken, or -1 before the first one.
  const [position, setPosition] = useState(-1)
  const [ended, setEnded] = useState(false)
  // Set at once when Play or Pause is pressed, so a timer that fires just
  // after Pause, before React has cleared it, cannot light the next word.
  const playingNow = useRef(false)

  useEffect(() => {
    if (state !== 'playing') return
    const next = position + 1
    let delay = position === -1 ? 0 : WORD_MS
    if (next < SPOKEN.length && position >= 0 && SPOKEN[next]?.lineIndex !== SPOKEN[position]?.lineIndex)
      delay = LINE_GAP_MS
    const timer = setTimeout(() => {
      if (!playingNow.current) return
      if (next < SPOKEN.length) {
        setPosition(next)
      } else {
        playingNow.current = false
        setState('finished')
        setPosition(-1)
      }
    }, delay)
    return () => {
      clearTimeout(timer)
    }
  }, [state, position])

  function togglePlay() {
    setEnded(false)
    if (state === 'playing') {
      playingNow.current = false
      setState('paused')
      return
    }
    if (state === 'finished') setPosition(-1)
    playingNow.current = true
    setState('playing')
  }

  const now = position >= 0 ? SPOKEN[position] : undefined
  const playing = state === 'playing'
  const progress = state === 'finished' ? 1 : (position + 1) / SPOKEN.length
  const playedBars = Math.round(progress * WAVE_BARS.length)

  const actions = (
    <>
      <div className={styles.player}>
        <button
          type="button"
          className={styles.play}
          onClick={togglePlay}
          aria-label={playing ? 'Pause the dialogue' : 'Play the dialogue'}
        >
          {playing ? (
            <svg viewBox="0 0 24 24" width="26" height="26" aria-hidden="true">
              <rect x="6" y="5" width="4" height="14" rx="1.2" />
              <rect x="14" y="5" width="4" height="14" rx="1.2" />
            </svg>
          ) : (
            <svg viewBox="0 0 24 24" width="26" height="26" aria-hidden="true">
              <path d="M8 5.5v13a1 1 0 0 0 1.5.86l10.6-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z" />
            </svg>
          )}
        </button>
        <div className={styles.wave} aria-hidden="true">
          {WAVE_BARS.map((height, i) => (
            <span
              key={i}
              className={i < playedBars ? styles.barPlayed : styles.bar}
              style={{ height: `${String(height)}%` }}
            />
          ))}
        </div>
      </div>
      <p className={styles.status} role="status">
        {ended ? SAMPLE_END : MESSAGES[state]}
      </p>
      <button
        type="button"
        className={styles.primary}
        onClick={() => {
          setEnded(true)
        }}
      >
        Continue
      </button>
    </>
  )

  // The top bar, the scrolling content and the action area come from the
  // shared SessionFrame (job 5, round 3), so the sample and real screens
  // cannot drift apart. Unit 1 has no Use it step, so this is step 1 of 4.
  return (
    <SessionFrame step="Hear it" leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 className={styles.title}>Hear it</h1>
          <p className={styles.lead}>
            Alex meets Sanna.{' '}
            <span className={styles.hint}>Blue words change between spoken and written Finnish.</span>
          </p>
          <p className={styles.note}>Sample, not reviewed.</p>
        </div>

        <ol className={styles.dialogue}>
          {SAMPLE_DIALOGUE.map((line, lineIndex) => {
            const isNow = now?.lineIndex === lineIndex
            return (
              <li key={line.speaker} className={isNow ? `${styles.card} ${styles.cardNow}` : styles.card}>
                <h2 className={styles.speaker}>{line.speaker}</h2>
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
                        <Line words={line.spoken} current={isNow ? now.wordIndex : -1} />
                      </p>
                    </div>
                    <div className={styles.written}>
                      <p className={styles.labelWritten}>Written</p>
                      <p className={styles.writtenLine} lang="fi">
                        <Line words={line.written} current={-1} />
                      </p>
                    </div>
                  </div>
                </div>
              </li>
            )
          })}
        </ol>
      </main>
    </SessionFrame>
  )
}
