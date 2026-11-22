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
//
// Create an account or continue as a guest (fast route signup-choice, owner, 22 November 2026): a visitor
// with no account gets two buttons in place of Continue. The mint "Create an account" makes the guest the
// same way, then opens the "Create your account" screen; the white "Continue as guest" is the old Continue.
// A sign in line under them catches people who already have an account. Everyone else keeps one Continue.

interface StopScreenProps {
  stop: RoadStop
  /** A visitor with no account on this device: they choose between an account and a guest. */
  visitor: boolean
  onBack: () => void
  /** Continue, or for a visitor "Continue as guest": makes or finds the account, then the lesson. */
  onContinue: () => void
  /** A visitor's "Create an account": makes the guest, then the "Create your account" screen. */
  onCreateAccount: () => void
  /** Which button is working, if any. */
  starting: false | 'lesson' | 'account'
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
  onCreateAccount,
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
        {visitor ? (
          <>
            <Button
              block
              className={styles.continue}
              busy={starting === 'account'}
              busyLabel="Starting your account."
              onClick={onCreateAccount}
            >
              Create an account
            </Button>
            <Button
              variant="secondary"
              block
              className={styles.guest}
              busy={starting === 'lesson'}
              busyLabel="Starting your session."
              onClick={onContinue}
            >
              Continue as guest
            </Button>
            <p className={styles.note}>
              <span>Already have an account?</span>{' '}
              <a className={styles.link} href={PATHS.signIn}>
                Sign in
              </a>
            </p>
            <p className={styles.note}>
              <span>{GUEST_LINE}</span>{' '}
              <a className={styles.link} href={PATHS.privacy}>
                Privacy notice
              </a>
            </p>
          </>
        ) : (
          <Button
            block
            className={styles.continue}
            busy={starting === 'lesson'}
            busyLabel="Starting your session."
            onClick={onContinue}
          >
            Continue
          </Button>
        )}
        {problem && <StatusLine tone="problem">{problem}</StatusLine>}
      </div>
    </main>
  )
}
