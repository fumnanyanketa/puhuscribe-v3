import type { ReactNode } from 'react'
import { Button } from './Button.tsx'
import styles from './RecordControl.module.css'

// The record control (design.md, "Record control"): a large round button with
// two soft rings. States: ready (mint), recording (peach, with a wave and one
// white "Tap to stop listening" pill under it), working (three fading dots) and unavailable with a one line
// reason. The accessible name changes with the state. It does not ask for the
// microphone itself: the screen that uses it does, through src/lib/recorder.ts.
// Colour is never the only sign: each state has its own words.

export type RecordState = 'ready' | 'recording' | 'working' | 'unavailable'

/**
 * The one line under the wave while recording, on every screen (fast route stop-clearer, owner, 5 November
 * 2026). It replaced a "Listening" caption and a small "Stop" link, which did not say what to do.
 */
export const STOP_LISTENING = 'Tap to stop listening'

interface RecordControlProps {
  state: RecordState
  /** Whole seconds recorded so far, said to screen readers while recording. */
  seconds?: number
  /** Why recording is unavailable, as one full sentence. */
  reason?: string
  onStart?: () => void
  onStop?: () => void
  /**
   * The hint under the ready button, when the screen words it (Say it: "Tap and
   * say the line"). Without it the control keeps its first wording, which the
   * spoken answer in Keep it still uses. While recording every screen shows the
   * same stop line, STOP_LISTENING.
   */
  hints?: { ready: string }
  /** The ready button's name, when the screen words it ("Try again, record yourself saying the line"). */
  readyName?: string
  /** The hint under the ready button. Off after a try, where the drawing shows the button alone. */
  readyHint?: boolean
}

/** The drawing's microphone: a filled capsule in a cup (round 6). The island card's "Say it all" uses it too. */
export function MicIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={styles.line}>
      <rect className={styles.capsule} x="8.6" y="2.5" width="6.8" height="11.5" rx="3.4" />
      <path d="M6 11.5a6 6 0 0 0 12 0" />
    </svg>
  )
}

const BARS = [8, 14, 22, 12, 26, 18, 10, 20, 28, 14, 18, 24, 10, 16, 22, 8, 18, 12]

/** A still drawing of a sound wave: it carries no information, only the look. */
export function Wave({ tone = 'spoken' }: { tone?: 'spoken' | 'recording' }) {
  return (
    <span
      className={tone === 'recording' ? `${styles.wave} ${styles.waveRecording}` : styles.wave}
      aria-hidden="true"
    >
      {BARS.map((height, index) => (
        <i key={index} style={{ height: `${String(height)}px` }} />
      ))}
    </span>
  )
}

function Caption({ children }: { children: ReactNode }) {
  return <p className={styles.caption}>{children}</p>
}

export function RecordControl({
  state,
  seconds = 0,
  reason,
  onStart,
  onStop,
  hints,
  readyName,
  readyHint = true,
}: RecordControlProps) {
  if (state === 'recording') {
    return (
      <div className={styles.column}>
        <button
          type="button"
          className={`${styles.record} ${styles.recording}`}
          onClick={onStop}
          aria-label={`Stop recording, ${String(seconds)} ${seconds === 1 ? 'second' : 'seconds'} recorded`}
          data-state="recording"
        >
          <MicIcon />
        </button>
        <Wave tone="recording" />
        <Button variant="secondary" className={styles.stop} onClick={onStop}>
          {STOP_LISTENING}
        </Button>
      </div>
    )
  }
  if (state === 'working') {
    return (
      <div className={styles.column}>
        <button
          type="button"
          className={`${styles.record} ${styles.working}`}
          aria-label="Working on your recording"
          aria-busy="true"
          aria-disabled="true"
          data-state="working"
        >
          <span className={styles.dots} aria-hidden="true">
            <span />
            <span />
            <span />
          </span>
        </button>
        <Caption>Listening to your recording.</Caption>
      </div>
    )
  }
  if (state === 'unavailable') {
    return (
      <div className={styles.column}>
        <button
          type="button"
          className={`${styles.record} ${styles.unavailable}`}
          disabled
          aria-label="Recording is not available"
          data-state="unavailable"
        >
          <MicIcon />
        </button>
        <Caption>{reason ?? 'Recording is not available on this device.'}</Caption>
      </div>
    )
  }
  return (
    <div className={styles.column}>
      <button
        type="button"
        className={styles.record}
        onClick={onStart}
        aria-label={readyName ?? 'Record yourself saying the line'}
        data-state="ready"
      >
        <MicIcon />
      </button>
      {readyHint && <Caption>{hints?.ready ?? 'Tap to record yourself.'}</Caption>}
    </div>
  )
}
