import { SproutMark } from '../components/Wordmark.tsx'
import styles from './LoadingMark.module.css'

// The drawing "Opening" (job 19-redesign, statement 11): the sprout mark and
// three fading dots, shown while the road loads. It is one status for screen
// readers, with a plain sentence, and it stands still with reduced motion.

export function LoadingMark({ label }: { label: string }) {
  return (
    <main className={styles.screen}>
      <h1 className={styles.hidden}>Your road to A1</h1>
      <SproutMark size={72} />
      <span className={styles.dots} aria-hidden="true">
        <i />
        <i />
        <i />
      </span>
      <p role="status" className={styles.hidden}>
        {label}
      </p>
    </main>
  )
}
