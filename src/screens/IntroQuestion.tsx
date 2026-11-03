import { useEffect, useId, useRef } from 'react'
import { AnswerChoices } from '../components/AnswerChoices.tsx'
import { Button } from '../components/Button.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import styles from './IntroQuestion.module.css'

// One of the two first-open questions (fast route "intro", owner's plan of
// 3 November 2026, item 1). The landscape band, the question as the screen's
// heading, the answers as the app's existing choice rows (Understand it's), and
// a quiet "Skip". One tap on an answer moves on; nothing is checked, scored or
// sent anywhere. The back arrow goes one screen back. Focus moves to the
// question each time a screen opens, so a screen reader hears it first.

interface IntroQuestionProps {
  question: string
  options: readonly { value: string; label: string }[]
  onAnswer: (value: string) => void
  onSkip: () => void
  onBack: () => void
  backLabel: string
}

export function IntroQuestion({
  question,
  options,
  onAnswer,
  onSkip,
  onBack,
  backLabel,
}: IntroQuestionProps) {
  const headingId = useId()
  const heading = useRef<HTMLHeadingElement>(null)

  useEffect(() => {
    heading.current?.focus({ preventScroll: true })
  }, [question])

  return (
    <PageFrame
      onBack={onBack}
      backLabel={backLabel}
      actions={
        <Button variant="quiet" className={styles.skip} aria-label="Skip this question" onClick={onSkip}>
          Skip
        </Button>
      }
    >
      <div className={styles.question}>
        <h1 id={headingId} ref={heading} tabIndex={-1} className={styles.ask}>
          {question}
        </h1>
        <AnswerChoices
          choices={options.map((option) => option.label)}
          unavailable={new Set()}
          right={null}
          onChoose={(index) => {
            const option = options.at(index)
            if (option) onAnswer(option.value)
          }}
          labelledBy={headingId}
        />
      </div>
    </PageFrame>
  )
}
