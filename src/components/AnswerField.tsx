import { useId, useRef, type SyntheticEvent } from 'react'
import styles from './AnswerField.module.css'

// The text field of a review item (factory/jobs/9-daily-review/spec.md, "Done
// when" 9). Laid out after v2's recall screen ("Recall" in
// design/v2-handoff/app-screens/screens-review.jsx), without its uppercase
// labels: a plain label, one field for Finnish, and two buttons under it that
// type ä and ö where the cursor is, for keyboards without them. The field is
// in its own form, so Enter submits it through the form's submit button,
// wherever that button sits on the screen (the review item's "Check").
//
// Phone keyboards: autocorrect, capitals, spelling and suggestions are off, so
// a Finnish word is not changed as it is typed (older browsers may ignore
// autocorrect="off"; spec risks).

export const FIELD_LABEL = 'Type the missing word'
const LETTERS = ['ä', 'ö'] as const

interface AnswerFieldProps {
  /** The id of the field's form, for a submit button elsewhere on the screen. */
  formId: string
  value: string
  maxLength: number
  disabled?: boolean
  onChange: (value: string) => void
  /** Enter, or the form's submit button. Not called while the field is empty. */
  onSubmit: () => void
}

export function AnswerField({
  formId,
  value,
  maxLength,
  disabled = false,
  onChange,
  onSubmit,
}: AnswerFieldProps) {
  const fieldId = useId()
  const field = useRef<HTMLInputElement>(null)

  function submit(event: SyntheticEvent) {
    event.preventDefault()
    if (disabled || value.trim() === '') return
    onSubmit()
  }

  // Puts the letter where the cursor is (replacing any selection), then puts
  // focus and the cursor back in the field, after the new letter.
  function type(letter: string) {
    const input = field.current
    if (!input || disabled) return
    const start = input.selectionStart ?? value.length
    const end = input.selectionEnd ?? value.length
    const next = value.slice(0, start) + letter + value.slice(end)
    if (next.length > maxLength) {
      input.focus()
      return
    }
    onChange(next)
    const cursor = start + letter.length
    setTimeout(() => {
      input.focus()
      input.setSelectionRange(cursor, cursor)
    }, 0)
  }

  return (
    <form id={formId} className={styles.form} onSubmit={submit} noValidate>
      <label htmlFor={fieldId} className={styles.label}>
        {FIELD_LABEL}
      </label>
      <input
        ref={field}
        id={fieldId}
        className={styles.field}
        type="text"
        lang="fi"
        value={value}
        maxLength={maxLength}
        disabled={disabled}
        autoCapitalize="off"
        autoCorrect="off"
        spellCheck={false}
        autoComplete="off"
        enterKeyHint="done"
        onChange={(event) => {
          onChange(event.target.value)
        }}
      />
      <div className={styles.letters}>
        {LETTERS.map((letter) => (
          <button
            key={letter}
            type="button"
            className={styles.letter}
            aria-label={`Type ${letter}`}
            disabled={disabled}
            // Keeps focus (and the phone keyboard) in the field when tapped.
            onMouseDown={(event) => {
              event.preventDefault()
            }}
            onClick={() => {
              type(letter)
            }}
          >
            <span lang="fi">{letter}</span>
          </button>
        ))}
      </div>
    </form>
  )
}
