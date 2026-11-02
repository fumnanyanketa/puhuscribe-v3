import { useId, type Ref } from 'react'
import styles from './Switch.module.css'

// A switch (design.md, "Switches"): a real switch with a name, one press
// changes it. It is a button with role="switch" and aria-checked, 44 px tall at
// least. The state is said in words by the hint under the name as well as by the
// track, so colour is never the only sign. While a change is being saved the
// switch ignores presses and says so.

interface SwitchProps {
  /** Its name, such as "Speaking feedback". */
  label: string
  /** One line under the name that says what the current state means. */
  hint?: string
  checked: boolean
  onChange: (next: boolean) => void
  busy?: boolean
  disabled?: boolean
  /** What a screen reader hears while the change is saved. */
  busyLabel?: string
  /** The switch itself, so a sheet it opens can give focus back to it (React 19 passes ref as a prop). */
  ref?: Ref<HTMLButtonElement>
}

export function Switch({
  label,
  hint,
  checked,
  onChange,
  busy = false,
  disabled = false,
  busyLabel,
  ref,
}: SwitchProps) {
  const labelId = useId()
  const hintId = useId()
  return (
    <div className={styles.row}>
      <div className={styles.text}>
        <span id={labelId} className={styles.label}>
          {label}
        </span>
        {hint && (
          <span id={hintId} className={styles.hint}>
            {hint}
          </span>
        )}
      </div>
      <button
        ref={ref}
        type="button"
        role="switch"
        className={styles.switch}
        aria-checked={checked}
        aria-labelledby={labelId}
        aria-describedby={hint ? hintId : undefined}
        aria-busy={busy || undefined}
        disabled={disabled}
        onClick={() => {
          if (!busy) onChange(!checked)
        }}
      >
        <span className={styles.thumb} aria-hidden="true" />
        {busy && <span className={styles.hidden}>{busyLabel ?? 'Saving your choice.'}</span>}
      </button>
    </div>
  )
}
