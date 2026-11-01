import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { emailSignInEnded, leaveWith } from '../lib/account-notice.ts'
import { callApi } from '../lib/api.ts'
import { PATHS } from '../lib/app-paths.ts'
import { pickFinishLine } from '../lib/session-rules.ts'
import type { NewWord, ReadySession } from '../lib/session-types.ts'
import type { LoopStep } from '../components/SessionFrame.tsx'
import { LineCard } from './LineCard.tsx'
import { newWordsFrom } from './new-words.ts'
import { NewWords } from './NewWords.tsx'
import { accountKindOf, carriesSaveNote } from './save-note.ts'
import { SAVED_ON_THIS_DEVICE } from './save-note-copy.ts'
import { SaveNote } from './SaveNote.tsx'
import { NOT_SAVED } from './step-screen.ts'
import styles from './Screens.module.css'

// The finish screen (factory/jobs/8-first-session/spec.md, "Done when" 14 and
// 15). One sentence the learner can now say, picked by the fixed rule in
// src/lib/session-rules.ts. When it opens, the Worker saves the end of the
// session once (public.complete_session). Redrawn in job 19-redesign
// (statement 33): a tick orb, the line card, a panel of the new words as
// chips, the save note, a quiet feedback link and "Done". No scores, badges,
// streaks or celebration; the only number is how many new words there are.

export const NOW_YOU_CAN = 'Now you can say this.'
const SAVING = 'Saving your progress.'
const SAVED = 'Your progress is saved.'

type SaveState = 'saving' | 'saved' | 'not_saved'

/** Saving's result: whether it worked, and whether the answer asks for the note (job 18-save-progress). */
interface SaveResult {
  saved: boolean
  note: boolean
  /** A guest is told the progress is saved on this device (owner's choice, 1 November 2026). */
  guest: boolean
  /** The words this lesson added to the review, for the chips. */
  newWords: NewWord[]
}

async function save(sessionId: string): Promise<SaveResult> {
  const answer = await callApi(`/api/sessions/${sessionId}/complete`, 'POST')
  // An email account deleted or signed out on another device (job 11-accounts,
  // "Done when" 22). Guests keep job 8's own handling.
  if (emailSignInEnded(answer)) leaveWith('signed-out-email')
  const saved = answer?.status === 200
  // Only after a save: which kind of account this is, from the same route the
  // account page uses. Without a clear answer the plain line is shown.
  const guest = saved && accountKindOf(await callApi('/api/me', 'GET')) === 'guest'
  return { saved, note: carriesSaveNote(answer), guest, newWords: saved ? newWordsFrom(answer.body) : [] }
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
  const [guest, setGuest] = useState(false)
  const [newWords, setNewWords] = useState<NewWord[]>([])
  // After "Try again" the status line keeps one place for the rest of the screen's life: a line that
  // moves in the page loses the keyboard focus that "Try again" gave it.
  const [retried, setRetried] = useState(false)
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
      setGuest(result.saved && result.guest)
      setNewWords(result.newWords)
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
    setRetried(true)
    status.current?.focus()
    setState('saving')
    setNote(false)
    setGuest(false)
    setNewWords([])
    void save(session.session.id).then((result) => {
      setState(result.saved ? 'saved' : 'not_saved')
      setNote(result.saved && result.note)
      setGuest(result.saved && result.guest)
      setNewWords(result.newWords)
    })
  }

  const savedLine = guest ? SAVED_ON_THIS_DEVICE : SAVED
  const message = state === 'saving' ? SAVING : state === 'saved' ? savedLine : NOT_SAVED
  const tone: StatusTone = state === 'not_saved' ? 'problem' : 'neutral'
  const lastStep = steps[steps.length - 1] ?? 'Hear it'

  // The line sits above the buttons while the save is unfinished or failed, and under "Done" once saved, as drawn.
  const statusAbove = state !== 'saved' || retried
  const status_line = (
    <StatusLine ref={status} tone={tone}>
      {message}
    </StatusLine>
  )
  const actions = (
    <>
      {statusAbove && status_line}
      {state === 'not_saved' && (
        <Button variant="secondary" block onClick={tryAgain}>
          Try again
        </Button>
      )}
      <Button
        block
        onClick={() => {
          window.location.assign(PATHS.home)
        }}
      >
        Done
      </Button>
      {!statusAbove && status_line}
    </>
  )

  return (
    <SessionFrame step={lastStep} steps={steps} finished leaveHref={PATHS.home} actions={actions}>
      <main className={styles.finishMain}>
        <div className={styles.orb} aria-hidden="true">
          <svg viewBox="0 0 24 24" focusable="false">
            <path d="M5 12.5l4.5 4.5L19 7.5" />
          </svg>
        </div>
        <h1 className={styles.finishTitle}>{NOW_YOU_CAN}</h1>
        {line && (
          <div className={styles.finishLine}>
            <LineCard line={line} showGloss />
          </div>
        )}
        {state === 'saved' && <NewWords words={newWords} />}
        {state === 'saved' && note && <SaveNote />}
        {/* Job 14-analytics, "Done when" 19: a quiet link, never a step of the loop. */}
        <a className={styles.feedbackLink} href={`${PATHS.feedback}?from=finish`}>
          Send feedback
        </a>
      </main>
    </SessionFrame>
  )
}
