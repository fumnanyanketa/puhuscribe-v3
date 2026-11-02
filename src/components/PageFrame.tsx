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
  /** Given, the back arrow is a button that does this instead of leaving the page (the code step goes back to the email). */
  onBack?: () => void
  /** The page's h1, drawn beside the arrow. A page whose h1 is in its content leaves it out. */
  title?: string
  /** "p": the title beside the arrow is plain text, because the page's h1 is in its content (the delete sheet). */
  titleAs?: 'h1' | 'p'
  children: ReactNode
  /** The buttons at the bottom. */
  actions?: ReactNode
  /**
   * Where the content starts, as drawn: "band" under the band's hills (168 px), "near" where the
   * drawings put content under a titled top bar (148 px), "profile" where the account page's avatar
   * overlaps the band (112 px).
   */
  contentTop?: 'band' | 'near' | 'profile'
  /** The content sits in the middle of the room left, as the drawn "Your file is ready" does. */
  centre?: boolean
}

export function PageFrame({
  back = PATHS.home,
  backLabel = 'Back',
  onBack,
  title,
  titleAs = 'h1',
  children,
  actions,
  contentTop = 'band',
  centre = false,
}: PageFrameProps) {
  return (
    <main className={styles.page}>
      <Landscape />
      <header
        className={
          contentTop === 'band'
            ? styles.header
            : `${styles.header} ${contentTop === 'near' ? styles.headerNear : styles.headerProfile}`
        }
      >
        {onBack ? (
          <button type="button" className={styles.back} aria-label={backLabel} onClick={onBack}>
            <BackArrow />
          </button>
        ) : (
          <a className={styles.back} href={back} aria-label={backLabel}>
            <BackArrow />
          </a>
        )}
        {title && titleAs === 'h1' && <h1 className={styles.title}>{title}</h1>}
        {title && titleAs === 'p' && <p className={styles.title}>{title}</p>}
      </header>
      <div className={centre ? `${styles.body} ${styles.centre}` : styles.body}>{children}</div>
      {actions && <div className={styles.actions}>{actions}</div>}
    </main>
  )
}

function BackArrow() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
      <path d="M14.5 5.5L8 12l6.5 6.5" />
    </svg>
  )
}
