import { WORDMARK } from './wordmark-paths.ts'
import styles from './Wordmark.module.css'

// The PuhuScribe wordmark: v2's sprout mark and name, flat (design/assets/).

export function Wordmark({ height = 32 }: { height?: number }) {
  return (
    <svg
      className={styles.wordmark}
      viewBox={`0 0 ${String(WORDMARK.width)} 44`}
      height={height}
      width={(height * WORDMARK.width) / 44}
      role="img"
      aria-label="PuhuScribe"
    >
      <g transform="scale(0.44)">
        <rect className={styles.tile} x="8" y="8" width="84" height="84" rx="26" />
        <path className={styles.stem} d="M50 78 L50 50" />
        <path className={styles.leaf} d="M50 62 C 50 45 37 39 23 41 C 25 58 40 65 50 62 Z" />
        <path className={styles.leafBack} d="M50 55 C 50 41 63 36 77 38 C 75 53 60 59 50 55 Z" />
      </g>
      <g transform={`translate(${String(WORDMARK.textX)} ${String(WORDMARK.baseline)})`}>
        <path className={styles.puhu} d={WORDMARK.puhu} />
        <path className={styles.scribe} d={WORDMARK.scribe} />
      </g>
    </svg>
  )
}
