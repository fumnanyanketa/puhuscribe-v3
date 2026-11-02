import { forwardRef, type InputHTMLAttributes } from 'react'
import styles from './TextField.module.css'

// The app's text field (factory/jobs/11-accounts/spec.md, "Done when" 27, and
// job 19-redesign round 6): the drawings' milky field with a soft shadow and no
// outline, its words as the placeholder ("Your email"). The label stays in the
// page for screen readers, visually hidden, so the field keeps its name. An
// optional line of help under it is read with the field.

interface TextFieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id' | 'className'> {
  id: string
  /** The field's name for screen readers, visually hidden. */
  label: string
  /** The words drawn inside the empty field, as in the drawings. */
  placeholder?: string
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
      <input ref={ref} id={id} className={styles.input} aria-describedby={hintId} {...rest} />
      {hint && (
        <p id={hintId} className={styles.hint}>
          {hint}
        </p>
      )}
    </div>
  )
})
