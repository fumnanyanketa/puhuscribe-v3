import type { ButtonHTMLAttributes, ReactNode } from 'react'
import styles from './Button.module.css'

// The app's buttons (design.md, "Buttons"). Primary is the flat mint pill with
// a small arrow circle, for the one main action on a screen. Secondary is the
// white pill with a mint edge. Quiet is underlined text, for a minor action.
// Danger is the deep peach pill, for "Delete for good". Every button is at least
// 44 x 44 px (the pills are 52 px tall).
//
// Busy: the button keeps its size, ignores presses and tells screen readers
// what is happening through busyLabel ("Saving your answer").

export type ButtonVariant = 'primary' | 'secondary' | 'quiet' | 'danger'

interface ButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
  variant?: ButtonVariant
  children: ReactNode
  /** Shown to screen readers while busy, as a full sentence. */
  busyLabel?: string
  busy?: boolean
  /** Fills the width of its container. */
  block?: boolean
  /** The small arrow circle of the primary pill. On unless turned off. */
  arrow?: boolean
  /** Reference page only: shows the hover or pressed look without a pointer. */
  showState?: 'hover' | 'pressed'
}

export function Button({
  variant = 'primary',
  children,
  busy = false,
  busyLabel,
  block = false,
  arrow = true,
  showState,
  className,
  onClick,
  type = 'button',
  ...rest
}: ButtonProps) {
  const classes = [styles.button, styles[variant]]
  if (block) classes.push(styles.block)
  if (className) classes.push(className)
  return (
    <button
      {...rest}
      type={type}
      className={classes.join(' ')}
      data-state={showState}
      aria-busy={busy || undefined}
      aria-disabled={busy || undefined}
      onClick={busy ? undefined : onClick}
    >
      <span className={busy ? styles.hiddenLabel : styles.label} aria-hidden={busy || undefined}>
        {children}
        {variant === 'primary' && arrow && (
          <span className={styles.arrow} aria-hidden="true">
            <svg viewBox="0 0 24 24" focusable="false">
              <path d="M5 12h14M13 6l6 6-6 6" />
            </svg>
          </span>
        )}
      </span>
      {busy && (
        <>
          <span className={styles.spinner} aria-hidden="true" />
          <span className={styles.visuallyHidden}>{busyLabel ?? 'Working.'}</span>
        </>
      )}
    </button>
  )
}
