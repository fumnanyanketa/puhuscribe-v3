import { forwardRef } from 'react'
import styles from './CodeField.module.css'

// The 6 digit code field (job 19-redesign, statement 35). It is one input with
// autocomplete="one-time-code", so a code pasted or filled in from the phone's
// messages works and a screen reader hears one field; a visible box for each
// digit is drawn behind it and carries no meaning of its own (aria-hidden).

const BOXES = 6

interface CodeFieldProps {
  id: string
  /** Its name for screen readers. It is not drawn: the page's title says what to do. */
  label: string
  value: string
  onChange: (value: string) => void
}

export const CodeField = forwardRef<HTMLInputElement, CodeFieldProps>(function CodeField(
  { id, label, value, onChange },
  ref,
) {
  const digits = value.replace(/\D/g, '').slice(0, BOXES)
  return (
    <div className={styles.wrap}>
      <label htmlFor={id} className={styles.hidden}>
        {label}
      </label>
      <div className={styles.boxes} aria-hidden="true">
        {Array.from({ length: BOXES }, (_, index) => (
          <span key={index} className={index === digits.length ? styles.boxNow : styles.box}>
            {digits.charAt(index)}
          </span>
        ))}
      </div>
      <input
        ref={ref}
        id={id}
        className={styles.input}
        type="text"
        inputMode="numeric"
        autoComplete="one-time-code"
        maxLength={12}
        value={value}
        onChange={(event) => {
          onChange(event.target.value)
        }}
      />
    </div>
  )
})
