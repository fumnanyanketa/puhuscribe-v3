import { WORDMARK } from './wordmark-paths.ts'
import styles from './Wordmark.module.css'

// The Aleksi wordmark, W4 (owner approved 5 November 2026, fast route intro-logo): "Aleksi" in Poppins
// ExtraBold as outlines, the A a fell with no crossbar and the dot of the i a small mint speech bubble
// (design/assets/wordmark.svg). It holds no text, so it looks the same whatever fonts the phone has.
// Until 5 November 2026 it was v2's sprout mark beside the name; the sprout stays as SproutMark below.

export function Wordmark({ height = 32 }: { height?: number }) {
  return (
    <svg
      className={styles.wordmark}
      viewBox={`0 0 ${String(WORDMARK.width)} ${String(WORDMARK.height)}`}
      height={height}
      width={(height * WORDMARK.width) / WORDMARK.height}
      role="img"
      aria-label="Aleksi"
    >
      <path className={styles.letters} data-part="fell" d={WORDMARK.fell} />
      <path className={styles.letters} data-part="letters" d={WORDMARK.letters} />
      <path className={styles.bubble} data-part="bubble" d={WORDMARK.bubble} />
    </svg>
  )
}

/** The sprout mark alone, on its mint tile (owner's call 14 of job 19-redesign). */
export function SproutMark({ size = 56 }: { size?: number }) {
  return (
    <svg className={styles.wordmark} viewBox="0 0 100 100" width={size} height={size} aria-hidden="true">
      <rect className={styles.tile} x="8" y="8" width="84" height="84" rx="26" />
      <path className={styles.stem} d="M50 78 L50 50" />
      <path className={styles.leaf} d="M50 62 C 50 45 37 39 23 41 C 25 58 40 65 50 62 Z" />
      <path className={styles.leafBack} d="M50 55 C 50 41 63 36 77 38 C 75 53 60 59 50 55 Z" />
    </svg>
  )
}
