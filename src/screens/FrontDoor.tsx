import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { CanDo } from './CanDo.tsx'
import { SIGNED_OUT_EMAIL, noticeFrom } from '../lib/account-notice.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { nextReviewSentence } from '../lib/review-day.ts'
import styles from './FrontDoor.module.css'

// The front door, at / (factory/jobs/8-first-session/spec.md, "Done when" 1,
// 2, 4, 6 and 18). One front door, one loop: the learner never picks a mode.
// Loading this page creates nothing. Only pressing Start sends POST /api/guest.
// Job 11-accounts adds, under the Start line, the privacy notice and account
// links, "I already have an account" when this device has no account, and the
// messages after signing out or deleting the account ("Done when" 1, 14, 20
// and 22).
//
// Job 9-daily-review ("Done when" 4 and 5) adds review to the same states,
// never as a second choice: a session that ends with a review says so; with
// no new dialogue, today's session is the review alone; and an empty day says
// so plainly with the day of the next review, as worded from the database's
// two Helsinki dates (never the device clock). No count of due words appears.

export const GUEST_LINE =
  'Starting creates a guest account on this device so your progress is saved. PuhuScribe is for adults, 18 and over.'
export const ENDED = 'Your guest session ended on this device. Press Start to begin again.'
export const ALL_DONE = 'You have finished every dialogue that is ready.'
export const NOT_READY = "Today's session is not ready yet. Please come back later."
const NOT_STARTED = 'Could not start your session. Check your internet connection, then try again.'
const LOADING = "Loading today's session."
const LEAD =
  'A session is one short Finnish dialogue that you hear line by line and then check you understand.'
export const ENDS_WITH_REVIEW = 'It ends with a short review of words you met before.'
export const REVIEW_ONLY = 'A short review of words you met before. Type each missing word from memory.'
export const EMPTY_DAY = 'That is all for today.'

type View =
  | { kind: 'loading' }
  | { kind: 'signed_out'; ended: boolean; email?: boolean }
  | { kind: 'start' | 'continue'; canDo?: string; review?: boolean }
  | { kind: 'review' }
  | { kind: 'all_done'; nextReview?: string }
  | { kind: 'not_ready' }

function nextReviewOf(value: unknown): string | undefined {
  if (!isRecord(value) || typeof value.today !== 'string' || typeof value.day !== 'string') return undefined
  return nextReviewSentence(value.today, value.day) ?? undefined
}

function viewFrom(body: unknown): View {
  if (!isRecord(body)) return { kind: 'signed_out', ended: false }
  const answer = body as {
    signedIn?: unknown
    ended?: unknown
    account?: unknown
    today?: unknown
    canDo?: unknown
    review?: unknown
    nextReview?: unknown
  }
  if (answer.signedIn !== true) {
    return { kind: 'signed_out', ended: answer.ended === true, email: answer.account === 'email' }
  }
  const canDo = typeof answer.canDo === 'string' ? answer.canDo : undefined
  if (answer.today === 'continue' || answer.today === 'start') {
    return { kind: answer.today, canDo, review: answer.review === true }
  }
  if (answer.today === 'review') return { kind: 'review' }
  if (answer.today === 'all_done') return { kind: 'all_done', nextReview: nextReviewOf(answer.nextReview) }
  if (answer.today === 'not_ready') return { kind: answer.today }
  return { kind: 'signed_out', ended: false }
}

export function FrontDoor() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const [starting, setStarting] = useState(false)
  const [problem, setProblem] = useState(false)
  // React's strict mode runs start-up effects twice in development; the
  // second run reuses this request.
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/today', 'GET').then((answer) =>
      // Without an answer the page offers Start, which finds an existing
      // guest on this device instead of making a second one.
      answer?.status === 200 ? viewFrom(answer.body) : { kind: 'signed_out', ended: false },
    )
    void firstLook.current.then((next) => {
      if (active) setView(next)
    })
    return () => {
      active = false
    }
  }, [])

  async function start() {
    setStarting(true)
    setProblem(false)
    const answer = await callApi('/api/guest', 'POST')
    if (answer && (answer.status === 200 || answer.status === 201)) {
      window.location.assign('/session')
      return
    }
    setStarting(false)
    setProblem(true)
  }

  let message = ''
  let tone: StatusTone = 'neutral'
  if (problem) {
    message = NOT_STARTED
    tone = 'problem'
  } else if (view.kind === 'signed_out' && view.ended) message = view.email ? SIGNED_OUT_EMAIL : ENDED
  else if (view.kind === 'signed_out') message = noticeFrom(window.location.search) ?? ''
  else if (view.kind === 'loading') message = LOADING
  // With nothing to start, the message takes the lead sentence's place under
  // the heading instead of sitting alone at the bottom (design review, round 1).
  const instead = view.kind === 'all_done' ? ALL_DONE : view.kind === 'not_ready' ? NOT_READY : null

  const signedOut = view.kind === 'signed_out'
  const canDo = view.kind === 'start' || view.kind === 'continue' ? view.canDo : undefined
  const nextReview = view.kind === 'all_done' ? view.nextReview : undefined
  let lead = LEAD
  if (view.kind === 'review') lead = REVIEW_ONLY
  else if (view.kind === 'start' && view.review) lead = `${LEAD} ${ENDS_WITH_REVIEW}`

  return (
    <main className={styles.page}>
      <div className={styles.top}>
        <Wordmark height={36} />
      </div>
      <div className={styles.intro}>
        <h1 className={styles.title}>{nextReview ? EMPTY_DAY : <>Today&apos;s session</>}</h1>
        {instead ? (
          <p className={styles.message} role="status">
            {instead}
          </p>
        ) : (
          <p className={styles.lead}>{lead}</p>
        )}
        {nextReview && <p className={styles.message}>{nextReview}</p>}
        {canDo && <CanDo text={canDo} className={styles.canDo} />}
      </div>
      <div className={styles.actions}>
        {(signedOut || view.kind === 'start' || view.kind === 'review') && (
          <Button block busy={starting} busyLabel="Starting your session." onClick={() => void start()}>
            Start
          </Button>
        )}
        {view.kind === 'continue' && (
          <Button
            block
            onClick={() => {
              window.location.assign('/session')
            }}
          >
            Continue today&apos;s session
          </Button>
        )}
        {signedOut && <p className={styles.guestLine}>{GUEST_LINE}</p>}
        {signedOut && (
          <Button
            variant="quiet"
            onClick={() => {
              window.location.assign('/sign-in')
            }}
          >
            I already have an account
          </Button>
        )}
        {!instead && <StatusLine tone={tone}>{message}</StatusLine>}
        {/* Voice settings (job 10-speaking-feedback, "Done when" 4), once signed in. */}
        {view.kind !== 'loading' && !signedOut && (
          <a className={styles.voiceLink} href="/voice">
            Voice settings
          </a>
        )}
        <ul className={styles.links}>
          <li>
            <a className={styles.link} href="/privacy">
              Privacy notice
            </a>
          </li>
          <li>
            <a className={styles.link} href="/account">
              Your account
            </a>
          </li>
        </ul>
      </div>
    </main>
  )
}
