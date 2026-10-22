import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame, type LoopStep } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import { afterResult, placeOf, startRun } from '../lib/review-run.ts'
import type { ReviewAnswer, ReviewFeedback, ReviewItem, ReviewResult } from '../lib/review-types.ts'
import { methodFormId } from './answer-methods.ts'
import { LineCard, hasChangedWords } from './LineCard.tsx'
import { ReviewItemView } from './ReviewItemView.tsx'
import { CHANGED_HINT, NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'

// Keep it (factory/jobs/9-daily-review/spec.md, "Done when" 6 to 9 and 12 to
// 14). The learner recalls each word by typing it into the line where they met
// it. The Worker grades and schedules every answer and saves it at once, so
// leaving halfway loses nothing that was checked. After each answer the whole
// line shows in both registers with the word marked, whatever the result:
// gentle wording, no red, no score and no count of mistakes. A word graded
// close or missed comes back once more at the end of the run.

export const INSTRUCTION = 'Type the missing word.'
export const RESULT_TEXT: Readonly<Record<ReviewResult, string>> = {
  correct: 'Yes, that is right.',
  close: 'Close. Check the spelling below.',
  wrong: 'Here is the word. It will come back soon.',
}
const RESULT_TONE: Readonly<Record<ReviewResult, StatusTone>> = {
  correct: 'neutral',
  close: 'gentle',
  wrong: 'gentle',
}
const NOT_CHECKED = 'Your answer could not be checked. Check your internet connection, then try again.'
const ALREADY_SAVED = 'This word was already saved. Press Next to go on.'
const NOTHING_NOW = 'There are no words to review right now.'
const ONE_MORE_TRY = 'One more try at this word.'

interface Shown {
  feedback: ReviewFeedback
  typed: string
}

function isFeedback(body: unknown): body is ReviewFeedback {
  return (
    isRecord(body) &&
    (body.result === 'correct' || body.result === 'close' || body.result === 'wrong') &&
    isRecord(body.line) &&
    isRecord(body.marked) &&
    isRecord(body.form)
  )
}

interface KeepItProps {
  sessionId: string
  /** The run's items, loaded with the session (GET /api/sessions/<id>/review). */
  items: readonly ReviewItem[]
  frame: { step: LoopStep; steps: readonly LoopStep[] }
  /** Stores Keep it as done, then moves on. Resolves false when it could not be saved. */
  onDone: () => Promise<boolean>
}

export function KeepIt({ sessionId, items, frame, onDone }: KeepItProps) {
  const [run, setRun] = useState(() => startRun(items.length))
  const [at, setAt] = useState(0)
  const [ready, setReady] = useState(false)
  const [checking, setChecking] = useState(false)
  const [problem, setProblem] = useState(false)
  const [shown, setShown] = useState<Shown | 'already_saved' | null>(null)
  const [saving, setSaving] = useState(false)
  const [failed, setFailed] = useState(false)
  const formBase = useId()
  const heading = useRef<HTMLHeadingElement>(null)
  const nextButton = useRef<HTMLDivElement>(null)
  const firstTurn = useRef(true)

  const turn = run.at(at)
  const item = turn ? items[turn.item] : undefined
  const typingForm = methodFormId(formBase, 'typed')

  // A new item puts the cursor in its field, except when the screen first
  // opens (the learner first sees the line and its meaning).
  useEffect(() => {
    if (firstTurn.current) {
      firstTurn.current = false
      return
    }
    document.getElementById(typingForm)?.querySelector('input')?.focus()
  }, [at, typingForm])

  async function check(answer: ReviewAnswer) {
    if (!item || checking) return
    setChecking(true)
    setProblem(false)
    const reply = await callApi('/api/review/answer', 'POST', {
      sessionId,
      formId: item.formId,
      text: answer.text,
      kind: answer.kind,
    })
    setChecking(false)
    if (reply?.status === 200 && isFeedback(reply.body)) {
      const feedback = reply.body
      setShown({ feedback, typed: answer.text })
      setRun(afterResult(run, at, feedback.result))
    } else if (reply?.status === 409 && isRecord(reply.body) && reply.body.error === 'card_changed') {
      // Saved already, from another tab: the first result stands.
      setShown('already_saved')
    } else {
      setProblem(true)
      return
    }
    setTimeout(() => {
      nextButton.current?.querySelector('button')?.focus()
    }, 0)
  }

  async function next() {
    if (at + 1 < run.length) {
      setAt(at + 1)
      setShown(null)
      setReady(false)
      return
    }
    setSaving(true)
    setFailed(false)
    const saved = await onDone()
    if (!saved) {
      setSaving(false)
      setFailed(true)
    }
  }

  let message = INSTRUCTION
  let tone: StatusTone = 'neutral'
  if (failed) {
    message = NOT_SAVED
    tone = 'problem'
  } else if (problem) {
    message = NOT_CHECKED
    tone = 'problem'
  } else if (shown === 'already_saved') message = ALREADY_SAVED
  else if (shown) {
    message = RESULT_TEXT[shown.feedback.result]
    tone = RESULT_TONE[shown.feedback.result]
  } else if (!item) message = NOTHING_NOW

  const answering = item !== undefined && shown === null
  const actions = (
    <>
      <StatusLine tone={tone}>{message}</StatusLine>
      {answering ? (
        <>
          <Button
            block
            type="submit"
            form={typingForm}
            disabled={!ready && !checking}
            busy={checking}
            busyLabel="Checking your answer."
          >
            Check
          </Button>
          <Button
            variant="quiet"
            disabled={checking}
            onClick={() => {
              void check({ kind: 'typed', text: '' })
            }}
          >
            I don&apos;t remember
          </Button>
        </>
      ) : (
        <div ref={nextButton} className={styles.next}>
          <Button block busy={saving} busyLabel="Saving your progress." onClick={() => void next()}>
            Next
          </Button>
        </div>
      )}
    </>
  )

  const place = turn ? placeOf(turn, items.length) : null

  return (
    <SessionFrame step={frame.step} steps={frame.steps} leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 ref={heading} tabIndex={-1} className={styles.title}>
            Keep it
          </h1>
          {item && <p className={styles.lead}>{place ? `Word ${place}.` : ONE_MORE_TRY}</p>}
          {shown !== null && shown !== 'already_saved' && hasChangedWords(shown.feedback.line) && (
            <p className={styles.hint}>{CHANGED_HINT}</p>
          )}
        </div>
        {item && shown === null && (
          <ReviewItemView
            key={at}
            item={item}
            formBase={formBase}
            disabled={checking}
            onReady={setReady}
            onAnswer={(answer) => void check(answer)}
          />
        )}
        {item && shown !== null && shown !== 'already_saved' && (
          <div className={styles.reviewItem} data-review-feedback={item.formId}>
            <LineCard line={shown.feedback.line} marked={shown.feedback.marked} speakerAs="p" showGloss />
            <p className={styles.reviewNote}>
              {shown.feedback.form.spoken === shown.feedback.form.written ? (
                <>
                  The word is <span lang="fi">{shown.feedback.form.spoken}</span> in spoken and written
                  Finnish.
                </>
              ) : (
                <>
                  The word is <span lang="fi">{shown.feedback.form.spoken}</span> in spoken Finnish and{' '}
                  <span lang="fi">{shown.feedback.form.written}</span> in written Finnish.
                </>
              )}
            </p>
            {shown.typed.trim() !== '' && (
              <p className={styles.reviewNote}>
                You wrote <span lang="fi">{shown.typed}</span>.
              </p>
            )}
          </div>
        )}
      </main>
    </SessionFrame>
  )
}

/** Keep it as a step of a dialogue session (src/screens/session-steps.ts). */
export function KeepItStep({ session, frame, onDone, review }: StepScreenProps) {
  return <KeepIt sessionId={session.session.id} items={review ?? []} frame={frame} onDone={onDone} />
}
