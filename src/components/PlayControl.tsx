import { useCallback, useEffect, useRef, useState } from 'react'
import { finished, startExclusive } from './play-registry.ts'
import styles from './PlayControl.module.css'

// Plays and pauses one audio file (design.md, "Play control").
// States: ready, loading, playing, and "could not play" with "Try again".
// The accessible name says what it plays: "Play the spoken line".
// Audio starts only from a tap or key press: the file is not even fetched
// until the first press. Starting one control stops any other that plays.

export type PlayState = 'ready' | 'loading' | 'playing' | 'error'

interface PlayControlProps {
  src: string
  /** What it plays, as in "the spoken line". */
  what: string
  size?: 'regular' | 'small'
  /** Reference page only: shows a state without playing anything. */
  showState?: PlayState
  /** Told when playback starts and when it stops, so a screen can mark what is playing. */
  onPlayingChange?: (playing: boolean) => void
}

function PlayIcon() {
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

export function PlayControl({ src, what, size = 'regular', showState, onPlayingChange }: PlayControlProps) {
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

  function press() {
    if (showState) return
    if (state === 'playing' || state === 'loading') {
      audio.current?.pause()
      finished(stop)
      setState('ready')
      return
    }
    if (!audio.current) {
      const element = new Audio()
      element.preload = 'none'
      element.addEventListener('playing', () => {
        setState('playing')
      })
      element.addEventListener('ended', () => {
        finished(stop)
        setState('ready')
      })
      element.addEventListener('error', () => {
        finished(stop)
        setState('error')
      })
      element.src = src
      audio.current = element
    } else if (state === 'error') {
      audio.current.load()
    }
    startExclusive(stop)
    setState('loading')
    audio.current.play().catch(() => {
      // A pause before playback started also rejects; only report real failures.
      if (audio.current && !audio.current.paused) return
      if (audio.current?.error) setState('error')
    })
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
  const look = failed ? styles.retry : `${styles.play} ${size === 'small' ? styles.small : ''}`
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
