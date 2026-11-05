import type { RefObject } from 'react'
import { CHECK_ASKING } from '../screens/road-copy.ts'
import styles from './CheckSlot.module.css'

// The place for Cloudflare's bot check (job turnstile), right above the button that makes a guest account:
// Start on the road and Continue on the stop screen (fast route road-stops). It takes no room until
// Cloudflare decides the learner must act; then the widget shows here with one quiet line above it.

interface CheckSlotProps {
  checkRef: RefObject<HTMLDivElement | null>
  asking: boolean
}

export function CheckSlot({ checkRef, asking }: CheckSlotProps) {
  return (
    <div className={styles.check} data-asking={asking ? 'yes' : undefined}>
      {asking && <p className={styles.note}>{CHECK_ASKING}</p>}
      <div ref={checkRef} className={styles.widget} />
    </div>
  )
}
