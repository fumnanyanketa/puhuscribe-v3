import type { RefObject } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { reviewMinutesLine } from '../lib/review-day.ts'
import { dayOneLine, lessonLine, lessonSegments } from '../lib/road-state.ts'
import type { RoadStop } from '../lib/road-types.ts'
import { GUEST_LINE } from '../screens/road-copy.ts'
import styles from './RoadCard.module.css'

// The one milky card at the bottom of the road (job 19-redesign, statement
// 15), by state. Button names and actions are the ones the front door had:
// "Start" sends POST /api/guest and goes to the session, "Continue" goes to the
// session. Every stop name and sentence is rendered as text.

export type CardView =
  | { kind: 'day-one'; stop: RoadStop; message?: string }
  | { kind: 'lesson'; stop: RoadStop; action: 'Start' | 'Continue' }
  | { kind: 'review'; count: number | null }
  | { kind: 'stop-finished'; done: RoadStop; next: RoadStop }
  | { kind: 'done'; line: string }
  | { kind: 'message'; text: string }

interface RoadCardProps {
  view: CardView
  /** Pressing "Start": makes or finds the guest account, then opens the session. */
  onStart: () => void
  onContinue: () => void
  starting: boolean
  problem: string | null
  /** The primary button, so Skip can give it focus. */
  startRef: RefObject<HTMLButtonElement | null>
}

function Pieces({ stop }: { stop: RoadStop }) {
  return (
    <span className={styles.pieces} aria-hidden="true">
      {lessonSegments(stop).map((done, index) => (
        <i key={index} className={done ? styles.pieceDone : styles.piece} />
      ))}
    </span>
  )
}

function Tick() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" className={styles.tickIcon}>
      <path d="M5 12.5l4.5 4.5L19 7.5" />
    </svg>
  )
}

export function RoadCard({ view, onStart, onContinue, starting, problem, startRef }: RoadCardProps) {
  const tone: StatusTone = 'problem'
  return (
    <section className={styles.card} aria-label="Today">
      {view.kind === 'day-one' && (
        <>
          <div className={styles.head}>
            <div className={styles.text}>
              <h2 className={styles.title}>{view.stop.name}</h2>
              <p className={styles.sub}>{dayOneLine(view.stop)}</p>
            </div>
            <span className={styles.tile} aria-hidden="true">
              {view.stop.number}
            </span>
          </div>
          {view.message && <StatusLine>{view.message}</StatusLine>}
          <Button block ref={startRef} busy={starting} busyLabel="Starting your session." onClick={onStart}>
            Start
          </Button>
          <div className={styles.links}>
            <p className={styles.account}>
              Have an account?{' '}
              <a className={styles.link} href={PATHS.signIn}>
                Sign in
              </a>
            </p>
            <a className={styles.legalLink} href={PATHS.privacy}>
              Privacy notice
            </a>
          </div>
          <p className={styles.legal}>{GUEST_LINE}</p>
        </>
      )}
      {view.kind === 'lesson' && (
        <>
          <div className={styles.head}>
            <div className={styles.text}>
              <h2 className={styles.title}>{view.stop.name}</h2>
              <p className={styles.sub}>{lessonLine(view.stop)}</p>
            </div>
            <span className={styles.tile} aria-hidden="true">
              {view.stop.number}
            </span>
          </div>
          <Pieces stop={view.stop} />
          {view.action === 'Start' ? (
            <Button block ref={startRef} busy={starting} busyLabel="Starting your session." onClick={onStart}>
              Start
            </Button>
          ) : (
            <Button block ref={startRef} onClick={onContinue}>
              Continue
            </Button>
          )}
        </>
      )}
      {view.kind === 'review' && (
        <>
          <div className={styles.head}>
            <div className={styles.text}>
              <h2 className={styles.title}>Review</h2>
              {view.count !== null && <p className={styles.sub}>{reviewMinutesLine(view.count)}</p>}
            </div>
            {view.count !== null && (
              <span className={styles.countTile} aria-label={`${String(view.count)} words`}>
                {view.count}
              </span>
            )}
          </div>
          <Button block ref={startRef} busy={starting} busyLabel="Starting your session." onClick={onStart}>
            Start review
          </Button>
        </>
      )}
      {view.kind === 'stop-finished' && (
        <>
          <div className={styles.head}>
            <div className={styles.text}>
              <h2 className={styles.title}>{view.done.name}, done</h2>
              <p className={styles.sub}>{view.done.canDo}</p>
            </div>
            <span className={styles.tile} aria-hidden="true">
              {view.done.number}
            </span>
          </div>
          <p className={styles.next}>
            <span className={styles.nextLabel}>Next stop</span>
            <span className={styles.nextName}>{view.next.name}</span>
          </p>
          <Button block ref={startRef} onClick={onContinue}>
            Continue
          </Button>
        </>
      )}
      {view.kind === 'done' && (
        <div className={styles.head}>
          <div className={styles.text}>
            <h2 className={styles.title}>Done for today</h2>
            <p className={styles.sub}>{view.line}</p>
          </div>
          <span className={styles.tile} aria-hidden="true">
            <Tick />
          </span>
        </div>
      )}
      {view.kind === 'message' && (
        <p className={styles.message} role="status">
          {view.text}
        </p>
      )}
      {problem && <StatusLine tone={tone}>{problem}</StatusLine>}
    </section>
  )
}
