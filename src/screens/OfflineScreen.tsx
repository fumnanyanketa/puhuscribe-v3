import { Button } from '../components/Button.tsx'
import { Landscape } from '../components/Landscape.tsx'
import styles from './OfflineScreen.module.css'

// The drawing "No connection" (job 19-redesign, statement 41), shown when a
// page's first request cannot reach the app. "Your progress is safe." is only
// said where it is true (lesson from job 4): on the road and the account
// screens nothing waits to be saved. Inside a lesson the screen says only to
// check the connection.

export const OFFLINE_CHECK = 'Check your internet connection, then try again.'
export const OFFLINE_SAFE = 'Your progress is safe.'

export function OfflineScreen({
  where,
  embedded = false,
}: {
  where: 'road' | 'account' | 'lesson'
  /** Shown inside another page (the reference page): a plain box and a lower heading, no landmark. */
  embedded?: boolean
}) {
  const Root = embedded ? 'div' : 'main'
  const Title = embedded ? 'h3' : 'h1'
  return (
    <Root className={styles.screen}>
      <Landscape />
      <div className={styles.body}>
        <svg viewBox="0 0 64 64" className={styles.cloud} aria-hidden="true" focusable="false">
          <path d="M18 46h30a10 10 0 0 0 1.4-19.9A15 15 0 0 0 20.2 24 11 11 0 0 0 18 46z" />
          <path d="M12 54L52 10" />
        </svg>
        <Title className={styles.title}>No connection</Title>
        <p className={styles.text}>
          {where === 'lesson' ? OFFLINE_CHECK : `${OFFLINE_SAFE} ${OFFLINE_CHECK}`}
        </p>
        <Button
          variant="secondary"
          onClick={() => {
            window.location.reload()
          }}
        >
          Try again
        </Button>
      </div>
    </Root>
  )
}
