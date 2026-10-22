import styles from './RecordControl.module.css'

// The record control, look only (design.md, "Record control"). This job never
// asks for the microphone; recording, voice consent and feedback are job 8.
// States: ready, recording (elapsed seconds and a Stop action), working, and
// unavailable with a one line reason. The accessible name changes with the state.

export type RecordState = 'ready' | 'recording' | 'working' | 'unavailable'

interface RecordControlProps {
  state: RecordState
  /** Whole seconds recorded so far, shown while recording. */
  seconds?: number
  /** Why recording is unavailable, as one full sentence. */
  reason?: string
  onStart?: () => void
  onStop?: () => void
}

function MicIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={styles.line}>
      <rect x="9" y="3" width="6" height="12" rx="3" />
      <path d="M5.5 11a6.5 6.5 0 0 0 13 0M12 17.5V21" />
    </svg>
  )
}

export function RecordControl({ state, seconds = 0, reason, onStart, onStop }: RecordControlProps) {
  const time = `${String(Math.floor(seconds / 60))}:${String(seconds % 60).padStart(2, '0')}`
  if (state === 'recording') {
    return (
      <div className={styles.row}>
        <button
          type="button"
          className={`${styles.record} ${styles.recording}`}
          onClick={onStop}
          aria-label={`Stop recording, ${String(seconds)} ${seconds === 1 ? 'second' : 'seconds'} recorded`}
          data-state="recording"
        >
          <span className={styles.stop} aria-hidden="true" />
        </button>
        <p className={styles.caption}>
          Recording <span className={styles.time}>{time}</span>. Tap to stop.
        </p>
      </div>
    )
  }
  if (state === 'working') {
    return (
      <div className={styles.row}>
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
        <p className={styles.caption}>Listening to your recording.</p>
      </div>
    )
  }
  if (state === 'unavailable') {
    return (
      <div className={styles.row}>
        <button
          type="button"
          className={`${styles.record} ${styles.unavailable}`}
          disabled
          aria-label="Recording is not available"
          data-state="unavailable"
        >
          <MicIcon />
        </button>
        <p className={styles.caption}>{reason ?? 'Recording is not available on this device.'}</p>
      </div>
    )
  }
  return (
    <div className={styles.row}>
      <button
        type="button"
        className={styles.record}
        onClick={onStart}
        aria-label="Record yourself saying the line"
        data-state="ready"
      >
        <MicIcon />
      </button>
      <p className={styles.caption}>Tap to record yourself.</p>
    </div>
  )
}
