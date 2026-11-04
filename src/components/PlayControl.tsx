import { useCallback, useEffect, useRef, useState } from 'react'
import { finished, startExclusive } from './play-registry.ts'
import styles from './PlayControl.module.css'

// Plays and pauses one audio file (design.md, "Play control").
// States: ready, loading, playing, and "could not play" with "Try again".
// The accessible name says what it plays: "Play the spoken line".
// Audio starts only from a tap or key press: the file is not even fetched
// until the first press. Starting one control stops any other that plays.
// One exception, Aleksi's greeting (fast route aleksi-intro): with tryOnOpen
// the control tries once to play when it first appears. If the browser blocks
// that (iPhones do without a tap), it quietly stays ready and a press plays it.

export type PlayState = 'ready' | 'loading' | 'playing' | 'error'

interface PlayControlProps {
  src: string
  /** What it plays, as in "the spoken line". */
  what: string
  /** "mini" is the island card's small pale round (language islands). */
  size?: 'regular' | 'small' | 'mini'
  /** Mint for the spoken line, slate for the written line (job 19-redesign). */
  tone?: 'spoken' | 'written'
  /** Reference page only: shows a state without playing anything. */
  showState?: PlayState
  /** Told when playback starts and when it stops, so a screen can mark what is playing. */
  onPlayingChange?: (playing: boolean) => void
  /** Tries once to play when the control first appears; a blocked try leaves it ready (aleksi-intro). */
  tryOnOpen?: boolean
}

/** The play triangle. The island card's "Play all" uses it too. */
export function PlayIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M8 5.5v13a1 1 0 0 0 1.5.86l10.6-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z" />
    </svg>
  )
}

function PauseIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <rect x="6" y="5" width="4" height="14" rx="1.2" />
      <rect x="14" y="5" width="4" height="14" rx="1.2" />
    </svg>
  )
}

export function PlayControl({
  src,
  what,
  size = 'regular',
  tone = 'spoken',
  showState,
  onPlayingChange,
  tryOnOpen = false,
}: PlayControlProps) {
  const [liveState, setState] = useState<PlayState>('ready')
  const state = showState ?? liveState
  const audio = useRef<HTMLAudioElement | null>(null)
  const playingChange = useRef(onPlayingChange)
  useEffect(() => {
    playingChange.current = onPlayingChange
  }, [onPlayingChange])
  useEffect(() => {
    if (showState) return
    playingChange.current?.(liveState === 'playing')
  }, [liveState, showState])

  const stop = useCallback(() => {
    audio.current?.pause()
    if (audio.current) audio.current.currentTime = 0
    setState('ready')
  }, [])

  useEffect(
    () => () => {
      audio.current?.pause()
      finished(stop)
    },
    [stop],
  )

  // Counts the starts, so the answer of an older play() cannot change the state of a newer one.
  const attempt = useRef(0)

  /** The audio element, made on first use; the file is fetched only when it plays. */
  const element = useCallback(() => {
    if (audio.current) return audio.current
    const made = new Audio()
    made.preload = 'none'
    made.addEventListener('playing', () => {
      setState('playing')
    })
    made.addEventListener('ended', () => {
      finished(stop)
      setState('ready')
    })
    made.addEventListener('error', () => {
      finished(stop)
      setState('error')
    })
    made.src = src
    audio.current = made
    return made
  }, [src, stop])

  /** Starts playback. `unasked` is the one try when the control opens (tryOnOpen). */
  const playFrom = useCallback(
    (target: HTMLAudioElement, unasked: boolean) => {
      const mine = ++attempt.current
      startExclusive(stop)
      target.play().catch(() => {
        if (mine !== attempt.current) return
        // A pause before playback started also rejects; only report real failures.
        if (!target.paused) return
        if (target.error) setState('error')
        else if (unasked) {
          // The browser would not play without a tap: the control stays ready, with nothing said.
          finished(stop)
          setState('ready')
        }
      })
    },
    [stop],
  )

  // The one unasked try, when the control first appears. Under React's strict mode the first mount is
  // undone at once, which pauses it, so the try runs again on the real mount.
  useEffect(() => {
    if (!tryOnOpen || showState) return
    playFrom(element(), true)
  }, [tryOnOpen, showState, element, playFrom])

  function press() {
    if (showState) return
    if (state === 'playing' || state === 'loading') {
      attempt.current += 1
      audio.current?.pause()
      finished(stop)
      setState('ready')
      return
    }
    const target = element()
    if (state === 'error') target.load()
    setState('loading')
    playFrom(target, false)
  }

  // One button in every state, so keyboard focus stays on it when playback
  // fails and when "Try again" is pressed (job 5, round 3).
  const failed = state === 'error'
  const label = failed
    ? `Try again: play ${what}`
    : state === 'playing'
      ? `Pause ${what}`
      : state === 'loading'
        ? `Loading ${what}`
        : `Play ${what}`
  const look = failed
    ? styles.retry
    : `${styles.play} ${size === 'small' ? styles.small : size === 'mini' ? styles.mini : ''} ${tone === 'written' ? styles.written : ''}`
  return (
    <span className={failed ? styles.errorRow : styles.wrap}>
      {failed && <span className={styles.errorText}>Could not play.</span>}
      <button
        type="button"
        className={look}
        onClick={press}
        aria-label={label}
        aria-busy={state === 'loading' || undefined}
        data-state={state}
      >
        {failed ? (
          'Try again'
        ) : state === 'playing' ? (
          <PauseIcon />
        ) : state === 'loading' ? (
          <span className={styles.loading} />
        ) : (
          <PlayIcon />
        )}
      </button>
    </span>
  )
}
