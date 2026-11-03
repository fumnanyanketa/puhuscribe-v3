import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { SessionFrame, type LoopStep } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import { NOT_HEARD_LIMIT, answerModeFor } from '../lib/answer-mode.ts'
import { recordingSupported } from '../lib/recorder.ts'
import { gradeReview } from '../lib/review-grade.ts'
import { afterResult, placeOf, startRun } from '../lib/review-run.ts'
import type { ReviewFeedback, ReviewItem, ReviewResult, TypedAnswer } from '../lib/review-types.ts'
import { MIN_RECORDING_MS } from '../lib/speech-types.ts'
import { TOO_MANY, loadVoice, recallForm } from '../lib/voice-api.ts'
import { methodFormId, methodsFor, type RecordedResult } from './answer-methods.ts'
import { PATHS } from '../lib/app-paths.ts'
import { LineCard } from './LineCard.tsx'
import { ReviewItemView } from './ReviewItemView.tsx'
import { NOT_SAVED, type StepScreenProps } from './step-screen.ts'
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
  // The note sits under the field and the marked word is in the card above it (round 6), so it says above.
  close: 'Close. Check the spelling above.',
  wrong: 'Here is the word. It will come back soon.',
}
const RESULT_TONE: Readonly<Record<ReviewResult, StatusTone>> = {
  correct: 'neutral',
  close: 'gentle',
  wrong: 'gentle',
}
/** What a spoken answer says, in the same gentle tone (job 10-speaking-feedback, "Done when" 21). */
export const SPOKEN_INSTRUCTION = 'Say the missing word.'
export const SPOKEN_RESULT_TEXT: Readonly<Record<ReviewResult, string>> = {
  correct: 'Yes, that was clear.',
  close: 'Close. Listen to the word above.',
  wrong: 'Here is the word. It will come back soon.',
}
export const SPOKEN_NOT_HEARD = 'That was too quiet to hear. Try again a little closer to the phone.'
export const SPOKEN_TO_TYPING = 'We could not hear that. Type the missing word instead.'
const NOT_CHECKED = 'Your answer could not be checked. Check your internet connection, then try again.'
const ALREADY_SAVED = 'This word was already saved. Press Next to go on.'
const NOTHING_NOW = 'There are no words to review right now.'
const ONE_MORE_TRY = 'One more try at this word.'

interface Shown {
  feedback: ReviewFeedback
  typed: string
  spoken: boolean
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
  /**
   * A practice replay of a finished lesson (fast route go-back): each item's answer, by form id. Answers
   * are then checked here in the browser with the same grader and never sent, so the review schedule
   * does not change. Every item is typed: a spoken answer would be saved by the Worker.
   */
  practiceAnswers?: ReadonlyMap<number, Omit<ReviewFeedback, 'result'>>
}

export function KeepIt({ sessionId, items, frame, onDone, practiceAnswers }: KeepItProps) {
  const [run, setRun] = useState(() => startRun(items.length))
  const [at, setAt] = useState(0)
  const [ready, setReady] = useState(false)
  const [checking, setChecking] = useState(false)
  const [problem, setProblem] = useState(false)
  const [shown, setShown] = useState<Shown | 'already_saved' | null>(null)
  const [saving, setSaving] = useState(false)
  const [failed, setFailed] = useState(false)
  // Spoken answers: whether speaking feedback is on, which items fell back to
  // typing, and a note to show for a recording that did not work.
  const [speakingOn, setSpeakingOn] = useState(false)
  const [switched, setSwitched] = useState<readonly number[]>([])
  const [note, setNote] = useState<string | null>(null)
  const notHeard = useRef(new Map<number, number>())
  const formBase = useId()
  const heading = useRef<HTMLHeadingElement>(null)
  const nextButton = useRef<HTMLDivElement>(null)
  const firstTurn = useRef(true)

  const turn = run.at(at)
  const item = turn ? items[turn.item] : undefined
  const typingForm = methodFormId(formBase, 'typed')
  const mode = turn
    ? answerModeFor({
        position: turn.item,
        speakingOn,
        recordingWorks: speakingOn && recordingSupported(),
        switchedToTyping: switched.includes(turn.item),
      })
    : 'typed'

  // Whether speaking feedback is on is asked once, when there is a second item
  // that could be spoken. Until it is known, every item is typed.
  useEffect(() => {
    if (items.length < 2 || practiceAnswers) return
    let active = true
    void loadVoice().then((load) => {
      if (active && load.kind === 'ok')
        setSpeakingOn(load.voice.available && load.voice.processing === 'granted')
    })
    return () => {
      active = false
    }
  }, [items.length, practiceAnswers])

  // A new item puts the cursor in its field, except when the screen first
  // opens (the learner first sees the line and its meaning).
  useEffect(() => {
    if (firstTurn.current) {
      firstTurn.current = false
      return
    }
    document.getElementById(typingForm)?.querySelector('input')?.focus()
  }, [at, typingForm, switched.length])

  // After an answer is checked, focus moves to "Next", once it is on screen.
  // (Moving it straight after the answer came back ran before React had drawn
  // the button, so focus was lost: the keyboard browser test caught it.)
  useEffect(() => {
    if (shown !== null) nextButton.current?.querySelector('button')?.focus()
  }, [shown])

  async function check(answer: TypedAnswer) {
    if (!item || checking) return
    setProblem(false)
    setNote(null)
    const known = practiceAnswers?.get(item.formId)
    if (practiceAnswers) {
      // Practice: graded here, against both shapes, with the grader the Worker uses. Nothing is sent.
      if (!known) {
        setProblem(true)
        return
      }
      const { result } = gradeReview(answer, known.form)
      setShown({ feedback: { ...known, result }, typed: answer.text, spoken: false })
      setRun(afterResult(run, at, result))
      return
    }
    setChecking(true)
    const reply = await callApi('/api/review/answer', 'POST', {
      sessionId,
      formId: item.formId,
      text: answer.text,
      kind: answer.kind,
    })
    setChecking(false)
    if (reply?.status === 200 && isFeedback(reply.body)) {
      const feedback = reply.body
      setShown({ feedback, typed: answer.text, spoken: false })
      setRun(afterResult(run, at, feedback.result))
    } else if (reply?.status === 409 && isRecord(reply.body) && reply.body.error === 'card_changed') {
      // Saved already, from another tab: the first result stands.
      setShown('already_saved')
    } else {
      setProblem(true)
    }
  }

  function switchToTyping(message: string) {
    if (turn) setSwitched([...switched, turn.item])
    setNote(message)
  }

  // A recording of the learner saying the word. The Worker checks it, grades it
  // by the fixed class table and saves it through the same path as typing.
  async function checkSpoken(result: RecordedResult) {
    if (!item || !turn || checking) return
    setProblem(false)
    setNote(null)
    if (result.kind === 'failed') {
      switchToTyping(SPOKEN_TO_TYPING)
      return
    }
    const heardTooLittle = (): void => {
      const count = (notHeard.current.get(turn.item) ?? 0) + 1
      notHeard.current.set(turn.item, count)
      if (count >= NOT_HEARD_LIMIT) switchToTyping(SPOKEN_TO_TYPING)
      else setNote(SPOKEN_NOT_HEARD)
    }
    if (result.recording.durationMs < MIN_RECORDING_MS) {
      heardTooLittle()
      return
    }
    setChecking(true)
    const reply = await recallForm(sessionId, item.formId, result.recording.wav)
    setChecking(false)
    if (reply.kind === 'signed_out') {
      window.location.replace('/')
    } else if (reply.kind === 'graded' && isFeedback(reply.body)) {
      const feedback = reply.body
      setShown({ feedback, typed: '', spoken: true })
      setRun(afterResult(run, at, feedback.result))
    } else if (reply.kind === 'not_heard') heardTooLittle()
    else if (reply.kind === 'already_saved') setShown('already_saved')
    else if (reply.kind === 'too_many') switchToTyping(TOO_MANY)
    else switchToTyping(SPOKEN_TO_TYPING)
  }

  async function next() {
    if (at + 1 < run.length) {
      setAt(at + 1)
      setShown(null)
      setReady(false)
      setNote(null)
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

  const spokenItem = mode === 'spoken'
  let message = spokenItem ? SPOKEN_INSTRUCTION : INSTRUCTION
  let tone: StatusTone = 'neutral'
  if (failed) {
    message = NOT_SAVED
    tone = 'problem'
  } else if (problem) {
    message = NOT_CHECKED
    tone = 'problem'
  } else if (shown === 'already_saved') message = ALREADY_SAVED
  else if (shown) {
    message = (shown.spoken ? SPOKEN_RESULT_TEXT : RESULT_TEXT)[shown.feedback.result]
    tone = RESULT_TONE[shown.feedback.result]
  } else if (note) {
    message = note
    tone = 'gentle'
  } else if (!item) message = NOTHING_NOW

  const answering = item !== undefined && shown === null
  // As drawn (round 6): a gentle result is the peach note under the field; "Yes, that is right." is small
  // and centred above Next; the instruction is drawn once, as the title, and read from the status line.
  const resultShown = shown !== null && shown !== 'already_saved' ? shown : null
  const noteUnder = resultShown !== null && tone === 'gentle'
  const status = (
    <StatusLine tone={tone} visuallyHidden={message === INSTRUCTION || message === SPOKEN_INSTRUCTION}>
      {message}
    </StatusLine>
  )
  const actions = (
    <>
      {noteUnder ? null : resultShown?.feedback.result === 'correct' ? (
        <div className={styles.rightHint}>{status}</div>
      ) : (
        status
      )}
      {answering ? (
        <>
          {!spokenItem && (
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
          )}
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
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      progress={run.length === 0 ? 0 : (at + (shown !== null ? 1 : 0)) / run.length}
      leaveHref={PATHS.home}
      actions={actions}
    >
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 ref={heading} tabIndex={-1} className={styles.hiddenTitle}>
            Keep it
          </h1>
          {/* The drawing's title at the top. The field's own label and the status line say it to a screen reader. */}
          {item && (
            <p className={styles.keepTitle} aria-hidden="true">
              {spokenItem ? 'Say the missing word' : 'Type the missing word'}
            </p>
          )}
        </div>
        {item && shown === null && (
          <ReviewItemView
            key={at}
            item={item}
            formBase={formBase}
            place={place ? `Word ${place}.` : ONE_MORE_TRY}
            disabled={checking}
            methods={methodsFor(mode)}
            onReady={setReady}
            onAnswer={(answer) => void check(answer)}
            onRecorded={(result) => void checkSpoken(result)}
          />
        )}
        {item && resultShown !== null && (
          <div className={styles.reviewItem} data-review-feedback={item.formId}>
            {/* Only the answer is marked, as drawn: a changed word box beside it would read as a second answer. */}
            <LineCard
              line={resultShown.feedback.line}
              marked={resultShown.feedback.marked}
              showChanged={false}
            />
            {/* What the learner typed stays in the field, as drawn: a right answer gets the mint edge and tick. */}
            {resultShown.typed.trim() !== '' && (
              <p
                className={
                  resultShown.feedback.result === 'correct'
                    ? `${styles.typedEcho} ${styles.typedRight}`
                    : styles.typedEcho
                }
                aria-hidden="true"
              >
                <span lang="fi">{resultShown.typed}</span>
                {resultShown.feedback.result === 'correct' && (
                  <span className={styles.typedTick}>
                    <svg viewBox="0 0 24 24" focusable="false">
                      <path d="M5 12.5l4.5 4.5L19 7.5" />
                    </svg>
                  </span>
                )}
              </p>
            )}
            {noteUnder && status}
            {/* Job 9 (statement 12) keeps these for screen readers; the marked words and the field show them to the eye. */}
            <p className={styles.hiddenTitle}>
              {resultShown.feedback.form.spoken === resultShown.feedback.form.written ? (
                <>
                  The word is <span lang="fi">{resultShown.feedback.form.spoken}</span> in spoken and written
                  Finnish.
                </>
              ) : (
                <>
                  The word is <span lang="fi">{resultShown.feedback.form.spoken}</span> in spoken Finnish and{' '}
                  <span lang="fi">{resultShown.feedback.form.written}</span> in written Finnish.
                </>
              )}
            </p>
            {resultShown.typed.trim() !== '' && (
              <p className={styles.hiddenTitle}>
                You wrote <span lang="fi">{resultShown.typed}</span>.
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
