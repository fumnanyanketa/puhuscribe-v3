import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import type { ReadySession } from '../lib/session-types.ts'
import { ALL_DONE, NOT_READY } from './FrontDoor.tsx'
import { SESSION_STEPS, after, resumeAt, type SessionPosition } from './session-steps.ts'
import { SessionFlow } from './SessionFlow.tsx'
import styles from './Screens.module.css'

// The session, at /session (factory/jobs/8-first-session/spec.md, "Done
// when" 6 and 18). It asks the Worker for today's session, which is reused if
// the learner left it unfinished, and resumes at the step after the one
// reached. Without a sign in it goes back to the front door.

const LOADING = "Loading today's session."
const NOT_LOADED = "Today's session could not be loaded. Check your internet connection, then try again."
const UNUSABLE = "Today's session cannot be shown right now. Please come back later."

type Page =
  | { kind: 'loading' }
  | { kind: 'message'; text: string; tone: 'neutral' | 'problem'; retry: boolean }
  | { kind: 'ready'; session: ReadySession; position: SessionPosition }

function pageFrom(answer: ApiAnswer | null): Page | 'signed_out' {
  if (!answer) return { kind: 'message', text: NOT_LOADED, tone: 'problem', retry: true }
  if (answer.status === 401) return 'signed_out'
  const body = isRecord(answer.body) ? answer.body : {}
  if (answer.status === 500 && body.error === 'content_unusable') {
    return { kind: 'message', text: UNUSABLE, tone: 'problem', retry: false }
  }
  if (answer.status !== 200) return { kind: 'message', text: NOT_LOADED, tone: 'problem', retry: true }
  if (body.state === 'not_ready') return { kind: 'message', text: NOT_READY, tone: 'neutral', retry: false }
  if (body.state === 'all_done') return { kind: 'message', text: ALL_DONE, tone: 'neutral', retry: false }
  if (body.state !== 'ready') return { kind: 'message', text: NOT_LOADED, tone: 'problem', retry: true }
  const session = body as unknown as ReadySession
  return { kind: 'ready', session, position: resumeAt(SESSION_STEPS, session.session.step) }
}

function loadToday(): Promise<ApiAnswer | null> {
  return callApi('/api/sessions/today', 'POST')
}

function show(answer: ApiAnswer | null, setPage: (page: Page) => void) {
  const next = pageFrom(answer)
  if (next === 'signed_out') {
    window.location.replace('/')
    return
  }
  setPage(next)
}

export function SessionPage() {
  const [page, setPage] = useState<Page>({ kind: 'loading' })
  const status = useRef<HTMLParagraphElement>(null)
  // One request per page load, also under React's strict mode.
  const firstLoad = useRef<Promise<ApiAnswer | null> | null>(null)

  useEffect(() => {
    let active = true
    firstLoad.current ??= loadToday()
    void firstLoad.current.then((answer) => {
      if (active) show(answer, setPage)
    })
    return () => {
      active = false
    }
  }, [])

  function tryAgain() {
    status.current?.focus()
    setPage({ kind: 'loading' })
    void loadToday().then((answer) => {
      show(answer, setPage)
    })
  }

  async function stepDone(session: ReadySession, index: number): Promise<boolean> {
    const step = SESSION_STEPS.at(index)
    if (!step) return false
    const answer = await callApi(`/api/sessions/${session.session.id}/step`, 'POST', { step: step.id })
    if (answer?.status !== 200) return false
    setPage({ kind: 'ready', session, position: after(SESSION_STEPS, index) })
    return true
  }

  if (page.kind === 'ready') {
    return (
      <SessionFlow
        steps={SESSION_STEPS}
        session={page.session}
        position={page.position}
        onStepDone={(index) => stepDone(page.session, index)}
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
