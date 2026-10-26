import { useState } from 'react'
import { AnswerField } from '../components/AnswerField.tsx'
import { MAX_ANSWER_LENGTH } from '../lib/review-types.ts'
import type { AnswerMethodProps } from './answer-methods.ts'

// Typing, the first answer method of a review item
// (factory/jobs/9-daily-review/spec.md, "Done when" 9 and 15). The typed text
// stays in this screen until it is sent to be graded; it is never stored.

export function TypedAnswer({ formId, disabled, onReady, onAnswer }: AnswerMethodProps) {
  const [text, setText] = useState('')
  return (
    <AnswerField
      formId={formId}
      value={text}
      maxLength={MAX_ANSWER_LENGTH}
      disabled={disabled}
      onChange={(value) => {
        setText(value)
        onReady(value.trim() !== '')
      }}
      onSubmit={() => {
        onAnswer({ kind: 'typed', text })
      }}
    />
  )
}
