import { useEffect, useLayoutEffect, useRef, useState, type CSSProperties } from 'react'
import { Wordmark } from '../components/Wordmark.tsx'
import { playIntro, type IntroScene, type IntroVoice, type VoiceState } from '../lib/intro-voice.ts'
import { AleksiFace } from '../road/AleksiFace.tsx'
import styles from './AleksiIntro.module.css'

// Aleksi's intro (fast route intro-logo), the owner's prototype version E with its tight timing of
// 5 November 2026 (design-drafts/intro-flow/intro-flow-e-logo-first.html), built with the app's tokens. It
// replaces the "Nice to meet you" screen of fast route aleksi-intro, and the "Play with sound" start of
// version D. It plays on its own, with no tap, and Aleksi speaks from the start:
//   - the logo fades in on the wash, zooms forward and is gone by about 1.85 s;
//   - while it leaves, a white lesson card: Aleksi's photo and name, "Puhekieli" and his greeting in spoken
//     Finnish, which he says from 1.6 s; then, while he is still speaking, a dotted line down to
//     "Kirjakieli" and the same greeting in written Finnish (shown, never said), then the meaning;
//   - as he finishes, the card leaves over the road, which comes in under it (RoadScreen: his journey line,
//     then Start).
// There is no sound switch, and nothing here turns the sound off. A small mint speaker after his name shows
// that he is speaking: its waves pulse while his greeting plays. A phone that blocks sound before a tap
// (iPhones do) shows "Tap to hear" on it instead, with a gently pulsing ring, until the first tap anywhere,
// which starts his voice (src/lib/intro-voice.ts). Skip (top right) goes straight to the road's end state. With reduced motion this
// screen is not shown at all. Nothing here is sent or kept.

/** Aleksi's greeting in spoken Finnish, with the words that change marked. */
export const GREETING_SPOKEN = { before: 'Moi! ', changed: 'Mä oon', after: ' Aleksi.' } as const
/** The same greeting in written Finnish, shown and never said (a draft for the native reviewer). */
export const GREETING_WRITTEN = { before: 'Moi! ', changed: 'Minä olen', after: ' Aleksi.' } as const
export const GREETING_MEANING = 'Hi! I’m Aleksi.'
export const TAP_TO_HEAR = 'Tap to hear'

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

/**
 * The speaker after Aleksi's name: mint, with two waves that pulse while he speaks, or the "Tap to hear" pill
 * while the browser waits for a tap. It is not a control, so screen readers skip it.
 */
function Speaker({ state }: { state: VoiceState }) {
  return (
    <span className={styles.speaker} data-state={state} aria-hidden="true" data-testid="intro-speaker">
      <svg className={styles.speakerIcon} viewBox="0 0 20 20">
        <path className={styles.speakerBody} d="M3 8h3l4-3v10l-4-3H3z" />
        <path className={`${styles.wave} ${styles.waveNear}`} d="M13 7.5a3.5 3.5 0 0 1 0 5" />
        <path className={`${styles.wave} ${styles.waveFar}`} d="M15 5.5a6 6 0 0 1 0 9" />
      </svg>
      {state === 'waiting-for-tap' && <span className={styles.tapToHear}>{TAP_TO_HEAR}</span>}
    </span>
  )
}

interface AleksiIntroProps {
  /** The one audio element of the intro, shared with the road for Aleksi's journey line. */
  voice: IntroVoice
  /** Skip: the road's end state at once. */
  onSkip: () => void
  /** The road comes in under the leaving card, which fades out over it. */
  onRoad: () => void
}

export function AleksiIntro({ voice, onSkip, onRoad }: AleksiIntroProps) {
  const [scene, setScene] = useState<IntroScene>('splash')
  const [rail, setRail] = useState<Rail | null>(null)
  const [voiceState, setVoiceState] = useState<VoiceState>(voice.state)
  const live = useRef(true)
  const pair = useRef<HTMLDivElement>(null)
  const topDot = useRef<HTMLSpanElement>(null)
  const bottomDot = useRef<HTMLSpanElement>(null)
  const roadRef = useRef(onRoad)
  useEffect(() => {
    roadRef.current = onRoad
  }, [onRoad])

  // The speaker follows the voice.
  useEffect(() => voice.subscribe(setVoiceState), [voice])

  // The intro plays on its own from the moment it opens. Leaving the page (or Skip) stops it and the voice.
  useEffect(() => {
    // One run per mount: under React's strict mode the first mount is undone at once, and its run stops.
    let alive = true
    let completed = false
    live.current = true
    void playIntro({
      show: setScene,
      say: (clip) => voice.say(clip),
      wait: (ms) =>
        new Promise((resolve) => {
          window.setTimeout(resolve, ms)
        }),
      road: () => {
        roadRef.current()
      },
      live: () => alive && live.current,
    }).then((done) => {
      completed = done
    })
    return () => {
      alive = false
      live.current = false
      // Once the card is gone the road says the journey line on the same voice: that is not cut here.
      if (!completed) voice.stop()
    }
  }, [voice])

  // The dotted line joins the two dots, whatever the text size makes the lines' heights.
  const card = scene === 'spoken' || scene === 'written' || scene === 'leaving'
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
  // Once the card leaves, this screen lies over the road coming in, and nothing on it can be reached.
  const over = scene === 'leaving' || scene === 'gone'

  return (
    <div className={styles.screen} data-scene={scene}>
      {!over && (
        <button type="button" className={styles.skip} data-intro-skip="" onClick={skip}>
          Skip
        </button>
      )}
      {scene !== 'gone' && (
        <main className={styles.main} aria-hidden={over || undefined}>
          <h1 className={styles.hidden}>Aleksi says hello</h1>
          {(scene === 'splash' || scene === 'spoken') && (
            <div className={styles.splash} data-testid="intro-logo">
              <Wordmark height={54} />
            </div>
          )}
          {card && (
            <div className={styles.stage}>
              <div className={styles.leave}>
                <section className={styles.card} aria-label="Aleksi’s greeting" data-testid="intro-card">
                  <div className={styles.head}>
                    <span className={styles.face}>
                      <AleksiFace />
                    </span>
                    <span className={styles.name}>Aleksi</span>
                    <Speaker state={voiceState} />
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
      )}
    </div>
  )
}
