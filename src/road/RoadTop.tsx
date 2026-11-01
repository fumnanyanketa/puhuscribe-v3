import { PATHS } from '../lib/app-paths.ts'
import styles from './RoadTop.module.css'

// The top of the road (job 19-redesign, statement 14): only the progress bar
// and the account button. The bar has 12 pieces (owner's call 12). The button
// is a 44 px round named "Your account" that opens the account page and shows
// the first letter of the learner's email, a G for a guest, or a plain person
// mark when there is no account or the letter could not be read.

interface RoadTopProps {
  pieces: readonly boolean[]
  /** The letter on the button, or null for the person mark. */
  letter: string | null
}

export function RoadTop({ pieces, letter }: RoadTopProps) {
  const done = pieces.filter(Boolean).length
  return (
    <div className={styles.top}>
      <div
        className={styles.bar}
        role="progressbar"
        aria-label="Progress on the road"
        aria-valuemin={0}
        aria-valuemax={pieces.length}
        aria-valuenow={done}
        aria-valuetext={`${String(done)} of ${String(pieces.length)} parts of the road done`}
      >
        {pieces.map((filled, index) => (
          <i key={index} className={filled ? styles.pieceDone : styles.piece} />
        ))}
      </div>
      <a className={styles.account} href={PATHS.account} aria-label="Your account">
        {letter ? (
          <span aria-hidden="true">{letter}</span>
        ) : (
          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" className={styles.person}>
            <circle cx="12" cy="8.5" r="3.5" />
            <path d="M5 20c.8-4 3.6-6 7-6s6.2 2 7 6" />
          </svg>
        )}
      </a>
    </div>
  )
}
