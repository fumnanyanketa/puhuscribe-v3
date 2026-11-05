import { useEffect, useRef, type RefObject } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import type { RoadStop } from '../lib/road-types.ts'
import { GUEST_LINE } from '../screens/road-copy.ts'
import { AleksiFace } from './AleksiFace.tsx'
import { CheckSlot } from './CheckSlot.tsx'
import { learnLine } from './stop-can-do.ts'
import { stopPicture, stopPictureRatio } from './stop-pictures.ts'
import styles from './StopScreen.module.css'

// Aleksi's stop screen (fast route road-stops, owner approved 5 November 2026, mockup stop-screen.png). The
// road's Start opens it before each stop the learner has not begun: a back button to the road, the stop's
// picture large, Aleksi's round photo with two white bubbles ("This is stop N, <name>." and what the stop
// teaches, said to the learner), and Continue. Continue does what Start did before this screen existed:
// for a visitor it makes the guest account (through the Turnstile check when Cloudflare asks), then the
// lesson opens. Only a visitor with no account sees the quiet guest line and the privacy link under it.
// English only: no Finnish on this screen.

interface StopScreenProps {
  stop: RoadStop
  /** A visitor with no account on this device: Continue makes a guest account. */
  visitor: boolean
  onBack: () => void
  onContinue: () => void
  starting: boolean
  problem: string | null
  checkRef: RefObject<HTMLDivElement | null>
  asking: boolean
}

function Chevron() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" className={styles.chevron}>
      <path d="M15 6l-6 6 6 6" />
    </svg>
  )
}

export function StopScreen({
  stop,
  visitor,
  onBack,
  onContinue,
  starting,
  problem,
  checkRef,
  asking,
}: StopScreenProps) {
  const heading = useRef<HTMLHeadingElement>(null)
  // The screen is new to the learner: focus goes to what Aleksi says first, so a screen reader reads it.
  useEffect(() => {
    heading.current?.focus()
  }, [])
  const picture = stopPicture(stop.number)
  const learn = learnLine(stop.number)
  return (
    <main className={styles.screen} data-stop={stop.number}>
      <div className={styles.top}>
        <button type="button" className={styles.back} aria-label="Back to the road" onClick={onBack}>
          <Chevron />
        </button>
      </div>
      <div className={styles.picture}>
        {picture && (
          <img
            className={styles.image}
            src={picture}
            alt=""
            style={{ aspectRatio: String(stopPictureRatio(stop.number)) }}
            data-testid="stop-picture"
          />
        )}
      </div>
      <div className={styles.chat}>
        <AleksiFace />
        <div className={styles.bubbles}>
          <h1 className={styles.bubble} ref={heading} tabIndex={-1}>
            This is stop {stop.number}, <strong className={styles.name}>{stop.name}</strong>.
          </h1>
          {learn && <p className={styles.bubble}>{learn}</p>}
        </div>
      </div>
      <div className={styles.actions}>
        <CheckSlot checkRef={checkRef} asking={asking} />
        <Button
          block
          className={styles.continue}
          busy={starting}
          busyLabel="Starting your session."
          onClick={onContinue}
        >
          Continue
        </Button>
        {visitor && (
          <p className={styles.note}>
            <span>{GUEST_LINE}</span>{' '}
            <a className={styles.link} href={PATHS.privacy}>
              Privacy notice
            </a>
          </p>
        )}
        {problem && <StatusLine tone="problem">{problem}</StatusLine>}
      </div>
    </main>
  )
}
