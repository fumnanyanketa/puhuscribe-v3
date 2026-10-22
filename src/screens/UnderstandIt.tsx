import { useEffect, useId, useMemo, useRef, useState } from 'react'
import { AnswerChoices } from '../components/AnswerChoices.tsx'
import { Button } from '../components/Button.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { pickQuestions } from '../lib/session-rules.ts'
import { LineCard, hasChangedWords } from './LineCard.tsx'
import { CHANGED_HINT, NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'

// Understand it (factory/jobs/8-first-session/spec.md, "Done when" 13). Up to
// three questions, one at a time, from the fixed rule in
// src/lib/session-rules.ts. A wrong choice gets a gentle line and becomes
// unavailable; the learner simply tries another. Nothing about the answers
// is counted, scored or sent anywhere. After the last question, "Next"
// stores step_reached = 'understand'.

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
  const nextButton = useRef<HTMLDivElement>(null)
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
        nextButton.current?.querySelector('button')?.focus()
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

  const actions = (
    <>
      <StatusLine tone={tone}>{message}</StatusLine>
      {(right !== null || questions.length === 0) && (
        <div ref={nextButton} className={styles.next}>
          <Button block busy={saving} busyLabel="Saving your progress." onClick={() => void next()}>
            Next
          </Button>
        </div>
      )}
    </>
  )

  return (
    <SessionFrame step={frame.step} steps={frame.steps} leaveHref="/" actions={actions}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 className={styles.title}>Understand it</h1>
          <p className={styles.lead}>{session.dialogue.title}</p>
          {questions.slice(0, index + 1).some((q) => hasChangedWords(q.line)) && (
            <p className={styles.hint}>{CHANGED_HINT}</p>
          )}
        </div>
        {question && (
          <div className={styles.question} key={question.line.id} data-question-line={question.line.id}>
            <LineCard line={question.line} speakerAs="p" />
            <h2 id={headingId} ref={heading} tabIndex={-1} className={styles.ask}>
              What does this mean?
            </h2>
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
