import { forwardRef } from 'react'
import styles from './StatusLine.module.css'

// The one status line (design.md, "Status line"), announced to screen readers
// with role="status". It always holds one full sentence ending in a full stop.
//
// - neutral: what is happening ("Saving your visit.").
// - gentle: the learner's attempt ("Close. Try the double k."). Soft lavender
//   block with rounded ends and a small open circle. Never red, never alarm words.
// - problem: a system fault ("No connection. Check your internet, then try
//   again."). Square-cornered block with an edge and a filled mark. Never used
//   for a learner's mistake.
// The three differ by wording and shape as well as colour.

export type StatusTone = 'neutral' | 'gentle' | 'problem'

interface StatusLineProps {
  tone?: StatusTone
  children: string
}

export const StatusLine = forwardRef<HTMLParagraphElement, StatusLineProps>(function StatusLine(
  { tone = 'neutral', children },
  ref,
) {
  return (
    <p ref={ref} role="status" tabIndex={-1} className={`${styles.status} ${styles[tone]}`} data-tone={tone}>
      {tone !== 'neutral' && <span className={styles.mark} aria-hidden="true" />}
      <span>{children}</span>
    </p>
  )
})
