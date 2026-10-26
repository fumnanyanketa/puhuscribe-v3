import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import type { LoopStep } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import type { ReviewItem } from '../lib/review-types.ts'
import type { ReadySession, ReviewSession } from '../lib/session-types.ts'
import { ALL_DONE, NOT_READY } from './FrontDoor.tsx'
import { KeepIt } from './KeepIt.tsx'
import { ReviewFinish } from './ReviewFinish.tsx'
import { after, resumeAt, stepsFor, type SessionPosition, type SessionStep } from './session-steps.ts'
import { SessionFlow } from './SessionFlow.tsx'
import styles from './Screens.module.css'

// The session, at /session (factory/jobs/8-first-session/spec.md, "Done
// when" 6 and 18). It asks the Worker for today's session, which is reused if
// the learner left it unfinished, and resumes at the step after the one
// reached. Without a sign in it goes back to the front door.
//
// Job 9-daily-review ("Done when" 6, 7 and 14): as the session loads, it also
// asks which words are due for review. With any, the session ends with Keep
// it; without, it is exactly job 8's session. When no new dialogue is ready,
// today's session is Keep it alone. Continuing restarts Keep it with whatever
// is still due, so words already checked do not come back.

const LOADING = "Loading today's session."
const NOT_LOADED = "Today's session could not be loaded. Check your internet connection, then try again."
const UNUSABLE = "Today's session cannot be shown right now. Please come back later."
const REVIEW_ONLY_STEPS: readonly LoopStep[] = ['Keep it']

type Page =
  | { kind: 'loading' }
  | { kind: 'message'; text: string; tone: 'neutral' | 'problem'; retry: boolean }
  | {
      kind: 'ready'
      session: ReadySession
      steps: readonly SessionStep[]
      review: readonly ReviewItem[]
      position: SessionPosition
    }
  | { kind: 'review'; sessionId: string; items: readonly ReviewItem[]; finished: boolean }

const PROBLEM: Page = { kind: 'message', text: NOT_LOADED, tone: 'problem', retry: true }

function isItems(body: unknown): body is { items: ReviewItem[] } {
  return isRecord(body) && Array.isArray(body.items)
}

/** The words due for review, for a session as it loads; null when they could not be loaded. */
async function loadReview(sessionId: string): Promise<ReviewItem[] | null> {
  const answer = await callApi(`/api/sessions/${sessionId}/review`, 'GET')
  return answer?.status === 200 && isItems(answer.body) ? answer.body.items : null
}

async function pageFrom(answer: ApiAnswer | null): Promise<Page | 'signed_out'> {
  if (!answer) return PROBLEM
  if (answer.status === 401) return 'signed_out'
  const body = isRecord(answer.body) ? answer.body : {}
  if (answer.status === 500 && body.error === 'content_unusable') {
    return { kind: 'message', text: UNUSABLE, tone: 'problem', retry: false }
  }
  if (answer.status !== 200) return PROBLEM
  if (body.state === 'not_ready') return { kind: 'message', text: NOT_READY, tone: 'neutral', retry: false }
  if (body.state === 'all_done') return { kind: 'message', text: ALL_DONE, tone: 'neutral', retry: false }
  if (body.state === 'review') {
    const session = body as unknown as ReviewSession
    const items = await loadReview(session.session.id)
    return items ? { kind: 'review', sessionId: session.session.id, items, finished: false } : PROBLEM
  }
  if (body.state !== 'ready') return PROBLEM
  const session = body as unknown as ReadySession
  const review = await loadReview(session.session.id)
  if (!review) return PROBLEM
  const steps = stepsFor(review.length > 0)
  return { kind: 'ready', session, steps, review, position: resumeAt(steps, session.session.step) }
}

function loadToday(): Promise<Page | 'signed_out'> {
  return callApi('/api/sessions/today', 'POST').then(pageFrom)
}

function show(next: Page | 'signed_out', setPage: (page: Page) => void) {
  if (next === 'signed_out') {
    window.location.replace('/')
    return
  }
  setPage(next)
}

/** Stores a step as done: Keep it through its own route, the others through the step route. */
async function saveStep(sessionId: string, step: SessionStep): Promise<boolean> {
  const answer =
    step.id === 'keep'
      ? await callApi(`/api/sessions/${sessionId}/review/done`, 'POST')
      : await callApi(`/api/sessions/${sessionId}/step`, 'POST', { step: step.id })
  return answer?.status === 200
}

export function SessionPage() {
  const [page, setPage] = useState<Page>({ kind: 'loading' })
  const status = useRef<HTMLParagraphElement>(null)
  // One request per page load, also under React's strict mode.
  const firstLoad = useRef<Promise<Page | 'signed_out'> | null>(null)

  useEffect(() => {
    let active = true
    firstLoad.current ??= loadToday()
    void firstLoad.current.then((next) => {
      if (active) show(next, setPage)
    })
    return () => {
      active = false
    }
  }, [])

  function tryAgain() {
    status.current?.focus()
    setPage({ kind: 'loading' })
    void loadToday().then((next) => {
      show(next, setPage)
    })
  }

  if (page.kind === 'ready') {
    const { session, steps, review } = page
    return (
      <SessionFlow
        steps={steps}
        session={session}
        position={page.position}
        review={review}
        onStepDone={async (index) => {
          const step = steps.at(index)
          if (!step || !(await saveStep(session.session.id, step))) return false
          setPage({ ...page, position: after(steps, index) })
          return true
        }}
      />
    )
  }

  if (page.kind === 'review') {
    if (page.finished) return <ReviewFinish steps={REVIEW_ONLY_STEPS} />
    return (
      <KeepIt
        sessionId={page.sessionId}
        items={page.items}
        frame={{ step: 'Keep it', steps: REVIEW_ONLY_STEPS }}
        onDone={async () => {
          const answer = await callApi(`/api/sessions/${page.sessionId}/review/done`, 'POST')
          if (answer?.status !== 200) return false
          setPage({ ...page, finished: true })
          return true
        }}
      />
    )
  }

  return (
    <main className={styles.plainPage}>
      <h1 className={styles.title}>Today&apos;s session</h1>
      <StatusLine ref={status} tone={page.kind === 'message' ? page.tone : 'neutral'}>
        {page.kind === 'message' ? page.text : LOADING}
      </StatusLine>
      {page.kind === 'message' && page.retry && (
        <Button variant="secondary" block onClick={tryAgain}>
          Try again
        </Button>
      )}
      {/* Not a main action: for "not ready" and "all done" the front door shows
          the same message and no button (design review, round 1). */}
      {page.kind === 'message' && (
        <Button
          variant="quiet"
          onClick={() => {
            window.location.assign('/')
          }}
        >
          Back to the start
        </Button>
      )}
    </main>
  )
}
