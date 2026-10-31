import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { emailSignInEnded, leaveWith } from '../lib/account-notice.ts'
import { callApi } from '../lib/api.ts'
import { pickFinishLine } from '../lib/session-rules.ts'
import type { ReadySession } from '../lib/session-types.ts'
import type { LoopStep } from '../components/SessionFrame.tsx'
import { LineCard } from './LineCard.tsx'
import { carriesSaveNote } from './save-note.ts'
import { SaveNote } from './SaveNote.tsx'
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

/** Saving's result: whether it worked, and whether the answer asks for the note (job 18-save-progress). */
interface SaveResult {
  saved: boolean
  note: boolean
}

async function save(sessionId: string): Promise<SaveResult> {
  const answer = await callApi(`/api/sessions/${sessionId}/complete`, 'POST')
  // An email account deleted or signed out on another device (job 11-accounts,
  // "Done when" 22). Guests keep job 8's own handling.
  if (emailSignInEnded(answer)) leaveWith('signed-out-email')
  return { saved: answer?.status === 200, note: carriesSaveNote(answer) }
}

interface FinishScreenProps {
  session: ReadySession
  steps: readonly LoopStep[]
}

export function FinishScreen({ session, steps }: FinishScreenProps) {
  const line = pickFinishLine(session.lines)
  const [state, setState] = useState<SaveState>('saving')
  // Job 18-save-progress, "Done when" 1 and 2: the note follows a saved answer
  // that asks for it, and never shows while saving or after a failed save.
  const [note, setNote] = useState(false)
  const status = useRef<HTMLParagraphElement>(null)
  // Saved once per screen: React's strict mode runs effects twice in
  // development, and the second run reuses this request.
  const firstSave = useRef<Promise<SaveResult> | null>(null)

  useEffect(() => {
    let active = true
    firstSave.current ??= save(session.session.id)
    void firstSave.current.then((result) => {
      if (!active) return
      setState(result.saved ? 'saved' : 'not_saved')
      setNote(result.saved && result.note)
    })
    return () => {
      active = false
    }
  }, [session.session.id])

  // Job 18-save-progress, "Done when" 7: the note belongs to the moment the
  // session was saved. A browser that brings this screen back from its back
  // forward cache (Back from the add email screen) must not show it again.
  useEffect(() => {
    const onShow = (event: PageTransitionEvent) => {
      if (event.persisted) setNote(false)
    }
    window.addEventListener('pageshow', onShow)
    return () => {
      window.removeEventListener('pageshow', onShow)
    }
  }, [])

  function tryAgain() {
    status.current?.focus()
    setState('saving')
    setNote(false)
    void save(session.session.id).then((result) => {
      setState(result.saved ? 'saved' : 'not_saved')
      setNote(result.saved && result.note)
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
        {state === 'saved' && note && <SaveNote />}
        {/* Job 14-analytics, "Done when" 19: a quiet link, never a step of the loop. */}
        <a className={styles.feedbackLink} href="/feedback?from=finish">
          Send feedback
        </a>
      </main>
    </SessionFrame>
  )
}
