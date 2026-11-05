import { useEffect, useLayoutEffect, useRef, useState, type CSSProperties } from 'react'
import { Button } from '../components/Button.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { GREETING_AUDIO } from '../lib/aleksi-intro.ts'
import { playCard, type CardScene, type IntroVoice } from '../lib/intro-voice.ts'
import { AleksiFace } from '../road/AleksiFace.tsx'
import styles from './AleksiIntro.module.css'

// Aleksi's intro (fast route intro-logo, owner approved 5 November 2026), the owner's prototype version D
// (design-drafts/intro-flow/intro-flow-d-aleksi.html), built with the app's tokens. It replaces the "Nice
// to meet you" screen of fast route aleksi-intro. The logo stays at the top. Browsers allow sound only after
// a tap, so it opens on one "Play with sound" button and a quiet Skip, and nothing plays before the tap.
// The tap plays the lesson card: Aleksi's photo and name, his greeting in spoken Finnish (Puhekieli) while
// the greeting clip plays, then a dotted line down to the same greeting in written Finnish (Kirjakieli)
// while its clip plays, then the meaning. The card then leaves and the road takes over (RoadScreen: the
// opening animation, his journey line, then Start). Skip goes straight to the road's end state. With
// reduced motion this screen is not shown at all. Nothing here is sent or kept.

/** Aleksi's greeting in spoken Finnish, with the words that change marked. */
export const GREETING_SPOKEN = { before: 'Moi! ', changed: 'Mä oon', after: ' Aleksi.' } as const
/** The same greeting in written Finnish (a draft for the native reviewer). */
export const GREETING_WRITTEN = { before: 'Moi! ', changed: 'Minä olen', after: ' Aleksi.' } as const
export const GREETING_MEANING = 'Hi! I’m Aleksi.'
export const PLAY_WITH_SOUND = 'Play with sound'

/** Where the dotted line runs: from under the spoken dot to above the written dot, in px. */
interface Rail {
  top: number
  height: number
}

function Greeting({ line }: { line: { before: string; changed: string; after: string } }) {
  return (
    <>
      {line.before}
      <span className={styles.changed}>{line.changed}</span>
      {line.after}
    </>
  )
}

interface AleksiIntroProps {
  /** The one audio element of the intro, shared with the road for Aleksi's journey line. */
  voice: IntroVoice
  /** Skip: the road's end state at once. */
  onSkip: () => void
  /** The card has left: the road opens with its animation. */
  onCardDone: () => void
}

export function AleksiIntro({ voice, onSkip, onCardDone }: AleksiIntroProps) {
  const [scene, setScene] = useState<CardScene | 'ask'>('ask')
  const [rail, setRail] = useState<Rail | null>(null)
  const live = useRef(true)
  const skipRef = useRef<HTMLButtonElement>(null)
  const pair = useRef<HTMLDivElement>(null)
  const topDot = useRef<HTMLSpanElement>(null)
  const bottomDot = useRef<HTMLSpanElement>(null)

  // Leaving the page (or Skip) stops the voice; nothing more happens after that.
  useEffect(() => {
    live.current = true
    return () => {
      live.current = false
      voice.stop()
    }
  }, [voice])

  // The dotted line joins the two dots, whatever the text size makes the lines' heights.
  const card = scene !== 'ask'
  useLayoutEffect(() => {
    if (!card) return undefined
    const measure = () => {
      const box = pair.current?.getBoundingClientRect()
      const a = topDot.current?.getBoundingClientRect()
      const b = bottomDot.current?.getBoundingClientRect()
      if (!box || !a || !b) return
      setRail({ top: a.bottom - box.top + 4, height: Math.max(0, b.top - a.bottom - 8) })
    }
    measure()
    window.addEventListener('resize', measure)
    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(measure)
    if (pair.current) observer?.observe(pair.current)
    return () => {
      window.removeEventListener('resize', measure)
      observer?.disconnect()
    }
  }, [card])

  /** "Play with sound": the tap that lets the browser play Aleksi's voice, and the start of the card. */
  function play() {
    voice.unlock(GREETING_AUDIO)
    // The button leaves the page; focus moves to Skip, the one control left.
    skipRef.current?.focus()
    void playCard({
      show: setScene,
      say: (clip) => voice.say(clip),
      wait: (ms) =>
        new Promise((resolve) => {
          window.setTimeout(resolve, ms)
        }),
      live: () => live.current,
    }).then((left) => {
      if (left) onCardDone()
    })
  }

  function skip() {
    live.current = false
    voice.stop()
    onSkip()
  }

  const railStyle = rail
    ? ({
        '--rail-top': `${String(rail.top)}px`,
        '--rail-height': `${String(rail.height)}px`,
      } as CSSProperties)
    : undefined

  return (
    <main className={styles.screen} data-scene={scene}>
      <h1 className={styles.logo}>
        <Wordmark height={36} />
      </h1>
      <button ref={skipRef} type="button" className={styles.skip} data-intro-skip="" onClick={skip}>
        Skip
      </button>
      {scene === 'ask' ? (
        <div className={styles.ask}>
          <Button className={styles.sound} arrow={false} onClick={play}>
            {PLAY_WITH_SOUND}
          </Button>
        </div>
      ) : (
        <div className={styles.stage}>
          <div className={styles.leave}>
            <section className={styles.card} aria-label="Aleksi says hello" data-testid="intro-card">
              <div className={styles.head}>
                <span className={styles.face}>
                  <AleksiFace />
                </span>
                <span className={styles.name}>Aleksi</span>
              </div>
              <div className={styles.pair} ref={pair} style={railStyle}>
                <p className={`${styles.tag} ${styles.spokenTag}`} lang="fi">
                  Puhekieli
                </p>
                <div className={`${styles.line} ${styles.spokenPart}`}>
                  <span className={styles.dotSpoken} ref={topDot} aria-hidden="true" />
                  <p className={styles.spoken} lang="fi" data-testid="intro-spoken">
                    <Greeting line={GREETING_SPOKEN} />
                  </p>
                </div>
                <p className={`${styles.tag} ${styles.writtenTag} ${styles.writtenPart}`} lang="fi">
                  Kirjakieli
                </p>
                <div className={`${styles.line} ${styles.writtenPart}`}>
                  <span className={styles.dotWritten} ref={bottomDot} aria-hidden="true" />
                  <p className={styles.written} lang="fi" data-testid="intro-written">
                    <Greeting line={GREETING_WRITTEN} />
                  </p>
                </div>
                <span className={styles.rail} aria-hidden="true" />
              </div>
              <p className={styles.meaning} data-testid="intro-meaning">
                <span className={styles.meaningLabel}>Meaning</span> <span>{GREETING_MEANING}</span>
              </p>
            </section>
          </div>
        </div>
      )}
    </main>
  )
}
