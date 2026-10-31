import {
  WELCOME_HEADING,
  WELCOME_ORDER,
  WELCOME_SESSION,
  WELCOME_SPOKEN,
  WELCOME_SPOKEN_LABEL,
  WELCOME_TWO_FORMS,
  WELCOME_WRITTEN,
  WELCOME_WRITTEN_LABEL,
} from './welcome-copy.ts'
import styles from './Welcome.module.css'

// The welcome on the front door (factory/jobs/15-onboarding/spec.md, "Done when"
// 1 to 4). Text only: no button, link, input, picture or Finnish. Start, right
// below it, is the way on. Its two bands look like the Spoken and Written parts
// of a dialogue line in Hear it (design.md, "Welcome block"), so the learner
// meets the same teal and violet a few seconds later. Each band names itself
// in words, so colour is never the only sign. The words come from
// welcome-copy.ts.

export function Welcome({ className }: { className?: string }) {
  return (
    <section
      className={[styles.welcome, className].filter(Boolean).join(' ')}
      aria-labelledby="welcome-heading"
    >
      <h2 id="welcome-heading" className={styles.heading}>
        {WELCOME_HEADING}
      </h2>
      <p className={styles.text}>{WELCOME_SESSION}</p>
      <p className={styles.text}>{WELCOME_TWO_FORMS}</p>
      <div className={styles.spoken}>
        <p className={styles.labelSpoken}>{WELCOME_SPOKEN_LABEL}</p>
        <p className={styles.text}>{WELCOME_SPOKEN}</p>
      </div>
      <div className={styles.written}>
        <p className={styles.labelWritten}>{WELCOME_WRITTEN_LABEL}</p>
        <p className={styles.text}>{WELCOME_WRITTEN}</p>
      </div>
      <p className={styles.text}>{WELCOME_ORDER}</p>
    </section>
  )
}
