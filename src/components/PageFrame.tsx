import type { ReactNode } from 'react'
import { PATHS } from '../lib/app-paths.ts'
import { Landscape } from './Landscape.tsx'
import styles from './PageFrame.module.css'

// The frame of every page that is not a lesson or the road (job 19-redesign,
// statements 34 to 41): the landscape band, a 44 px back arrow in a milky
// round, an optional title beside it (the page's one h1), the content, and an
// action area at the bottom that stays in view and clears the home bar.

interface PageFrameProps {
  /** Where the back arrow goes. */
  back?: string
  /** What the back arrow is called for screen readers. */
  backLabel?: string
  /** The page's h1, drawn beside the arrow. A page whose h1 is in its content leaves it out. */
  title?: string
  children: ReactNode
  /** The buttons at the bottom. */
  actions?: ReactNode
}

export function PageFrame({
  back = PATHS.home,
  backLabel = 'Back',
  title,
  children,
  actions,
}: PageFrameProps) {
  return (
    <main className={styles.page}>
      <Landscape />
      <header className={styles.header}>
        <a className={styles.back} href={back} aria-label={backLabel}>
          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
            <path d="M14.5 5.5L8 12l6.5 6.5" />
          </svg>
        </a>
        {title && <h1 className={styles.title}>{title}</h1>}
      </header>
      <div className={styles.body}>{children}</div>
      {actions && <div className={styles.actions}>{actions}</div>}
    </main>
  )
}
