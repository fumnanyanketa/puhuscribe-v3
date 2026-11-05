import { PORTRAIT_WIDTHS, portraitSrc } from '../lib/aleksi-intro.ts'
import styles from './AleksiFace.module.css'

// Aleksi's small round photo beside his speech bubbles on the road and on the stop screen (fast route
// road-stops). The crop is the owner's correction of 5 November 2026, so his whole head shows: cover,
// placed at 50% 18%, scaled 1.12 from 50% 30%. The words beside it say who speaks, so the photo is
// decoration for screen readers.

const smallest = PORTRAIT_WIDTHS[0]

export function AleksiFace() {
  return (
    <span className={styles.face} aria-hidden="true">
      <img
        className={styles.image}
        src={portraitSrc(smallest)}
        alt=""
        width={48}
        height={48}
        decoding="async"
      />
    </span>
  )
}
