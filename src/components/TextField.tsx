import { forwardRef, type InputHTMLAttributes } from 'react'
import styles from './TextField.module.css'

// The app's text field (factory/jobs/11-accounts/spec.md, "Done when" 27):
// v2's white card field with a visible label above it, and an optional line of
// help under the label that screen readers read with the field.

interface TextFieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id' | 'className'> {
  id: string
  label: string
  hint?: string
}

export const TextField = forwardRef<HTMLInputElement, TextFieldProps>(function TextField(
  { id, label, hint, ...rest },
  ref,
) {
  const hintId = hint ? `${id}-hint` : undefined
  return (
    <div className={styles.field}>
      <label htmlFor={id} className={styles.label}>
        {label}
      </label>
      {hint && (
        <p id={hintId} className={styles.hint}>
          {hint}
        </p>
      )}
      <input ref={ref} id={id} className={styles.input} aria-describedby={hintId} {...rest} />
    </div>
  )
})
