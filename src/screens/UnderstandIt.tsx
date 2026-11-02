import { useEffect, useId, useMemo, useRef, useState } from 'react'
import { AnswerChoices } from '../components/AnswerChoices.tsx'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { pickQuestions } from '../lib/session-rules.ts'
import { LineCard } from './LineCard.tsx'
import { NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'

// Understand it (factory/jobs/8-first-session/spec.md, "Done when" 13; redrawn
// in job 19-redesign, statement 28). Up to three questions, one at a time, from
// the fixed rule in src/lib/session-rules.ts: the question, the one spoken line
// in a milky card with a play button, and three answer rows. A wrong choice
// gets a gentle line and becomes unavailable; the learner simply tries another.
// Nothing about the answers is counted, scored or sent anywhere. The bottom
// pill reads "Next" and is unavailable until the answer is right; after the
// last question it stores step_reached = 'understand'. The written line is not
// shown here, and the words of the spoken line stay tappable.

export const RIGHT = 'Yes, that is right.'
export const WRONG = 'Not this one. Listen again and try another.'
const HELP = 'Choose what the line means.'

export function UnderstandIt({ session, frame, onDone }: StepScreenProps) {
  const questions = useMemo(() => pickQuestions(session.lines, session.session.id), [session])
  const [index, setIndex] = useState(0)
  const [tried, setTried] = useState<ReadonlySet<number>>(new Set())
  const [right, setRight] = useState<number | null>(null)
  const [lastWrong, setLastWrong] = useState(false)
  const [saving, setSaving] = useState(false)
  const [failed, setFailed] = useState(false)
  const heading = useRef<HTMLHeadingElement>(null)
  const nextButton = useRef<HTMLButtonElement>(null)
  const choices = useRef<HTMLDivElement>(null)
  const headingId = useId()
  const question = questions.at(index)

  // The answer rows stay in view on a short phone: when a question opens and
  // after each answer (a wrong answer makes the action area taller), the list
  // is scrolled into view (design review, round 1).
  useEffect(() => {
    choices.current?.scrollIntoView({ block: 'nearest' })
  }, [index, tried, right])

  function choose(choice: number) {
    if (!question) return
    if (choice === question.answer) {
      setRight(choice)
      setLastWrong(false)
      // The next action is the "Next" button in the action area.
      setTimeout(() => {
        nextButton.current?.focus()
      }, 0)
      return
    }
    setTried(new Set(tried).add(choice))
    setLastWrong(true)
  }

  async function next() {
    if (index + 1 < questions.length) {
      setIndex(index + 1)
      setTried(new Set())
      setRight(null)
      setLastWrong(false)
      setTimeout(() => {
        heading.current?.focus({ preventScroll: true })
        choices.current?.scrollIntoView({ block: 'nearest' })
      }, 0)
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

  let message = HELP
  let tone: StatusTone = 'neutral'
  if (failed) {
    message = NOT_SAVED
    tone = 'problem'
  } else if (right !== null) message = RIGHT
  else if (lastWrong) {
    message = WRONG
    tone = 'gentle'
  }

  const ready = right !== null || questions.length === 0
  const actions = (
    <>
      {/* "Choose what the line means." is for screen readers; the drawing shows no line there (round 6). */}
      <StatusLine tone={tone} visuallyHidden={message === HELP}>
        {message}
      </StatusLine>
      <Button
        block
        ref={nextButton}
        disabled={!ready}
        busy={saving}
        busyLabel="Saving your progress."
        onClick={() => void next()}
      >
        Next
      </Button>
    </>
  )

  const answered = questions.length === 0 ? 0 : (index + (right === null ? 0 : 1)) / questions.length

  return (
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      progress={answered}
      leaveHref={PATHS.home}
      stepHeading
      actions={actions}
    >
      <main className={styles.main}>
        {question && (
          <div className={styles.question} key={question.line.id} data-question-line={question.line.id}>
            <h2 id={headingId} ref={heading} tabIndex={-1} className={styles.ask}>
              What does this mean?
            </h2>
            <LineCard line={question.line} only="spoken" />
            <div ref={choices}>
              <AnswerChoices
                choices={question.choices}
                unavailable={tried}
                right={right}
                onChoose={choose}
                labelledBy={headingId}
              />
            </div>
          </div>
        )}
      </main>
    </SessionFrame>
  )
}
