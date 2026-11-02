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
/** The drawing's second sentence, said where the progress is safe (round 6). */
export const OFFLINE_LATER = "Try again when you're online."

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
        {/* The drawing's soft mint cloud with a peach slash (round 6). */}
        <span className={styles.cloud} aria-hidden="true">
          <span className={styles.slash} />
        </span>
        <Title className={styles.title}>No connection</Title>
        <p className={styles.text}>
          {where === 'lesson' ? OFFLINE_CHECK : `${OFFLINE_SAFE} ${OFFLINE_LATER}`}
        </p>
        <div className={styles.action}>
          <Button
            block
            onClick={() => {
              window.location.reload()
            }}
          >
            Try again
          </Button>
        </div>
      </div>
    </Root>
  )
}
