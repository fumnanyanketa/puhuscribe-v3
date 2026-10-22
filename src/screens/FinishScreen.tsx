import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { callApi } from '../lib/api.ts'
import { pickFinishLine } from '../lib/session-rules.ts'
import type { ReadySession } from '../lib/session-types.ts'
import type { LoopStep } from '../components/SessionFrame.tsx'
import { LineCard } from './LineCard.tsx'
import { NOT_SAVED } from './step-screen.ts'
import styles from './Screens.module.css'

// The finish screen (factory/jobs/8-first-session/spec.md, "Done when" 14 and
// 15). One sentence the learner can now say, picked by the fixed rule in
// src/lib/session-rules.ts. When it opens, the Worker saves the end of the
// session once (public.complete_session). No counts, scores, badges, streaks
// or celebration.

export const NOW_YOU_CAN = 'Now you can say this.'
export const COMES_BACK = 'The words you met will come back in your review.'
const SAVING = 'Saving your progress.'
const SAVED = 'Your progress is saved.'

type SaveState = 'saving' | 'saved' | 'not_saved'

async function save(sessionId: string): Promise<boolean> {
  const answer = await callApi(`/api/sessions/${sessionId}/complete`, 'POST')
  return answer?.status === 200
}

interface FinishScreenProps {
  session: ReadySession
  steps: readonly LoopStep[]
}

export function FinishScreen({ session, steps }: FinishScreenProps) {
  const line = pickFinishLine(session.lines)
  const [state, setState] = useState<SaveState>('saving')
  const status = useRef<HTMLParagraphElement>(null)
  // Saved once per screen: React's strict mode runs effects twice in
  // development, and the second run reuses this request.
  const firstSave = useRef<Promise<boolean> | null>(null)

  useEffect(() => {
    let active = true
    firstSave.current ??= save(session.session.id)
    void firstSave.current.then((saved) => {
      if (active) setState(saved ? 'saved' : 'not_saved')
    })
    return () => {
      active = false
    }
  }, [session.session.id])

  function tryAgain() {
    status.current?.focus()
    setState('saving')
    void save(session.session.id).then((saved) => {
      setState(saved ? 'saved' : 'not_saved')
    })
  }

  const message = state === 'saving' ? SAVING : state === 'saved' ? SAVED : NOT_SAVED
  const tone: StatusTone = state === 'not_saved' ? 'problem' : 'neutral'
  const lastStep = steps[steps.length - 1] ?? 'Hear it'

  const actions = (
    <>
      <StatusLine ref={status} tone={tone}>
        {message}
      </StatusLine>
      {state === 'not_saved' && (
        <Button variant="secondary" block onClick={tryAgain}>
          Try again
        </Button>
      )}
      <Button
        block
        onClick={() => {
          window.location.assign('/')
        }}
      >
        Done
      </Button>
    </>
  )

  return (
    <SessionFrame step={lastStep} steps={steps} finished leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 className={styles.title}>{NOW_YOU_CAN}</h1>
        </div>
        {line && (
          <div className={styles.finishLine}>
            <LineCard line={line} speakerAs="p" showGloss />
          </div>
        )}
        <p className={styles.comesBack}>{COMES_BACK}</p>
      </main>
    </SessionFrame>
  )
}
