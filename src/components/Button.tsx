import type { ButtonHTMLAttributes, ReactNode } from 'react'
import styles from './Button.module.css'

// The app's buttons (design.md, "Buttons"). Primary is v2's black pill, for
// the one main action on a screen. Secondary is v2's white pill with an edge.
// Quiet is text only, for a minor action. Every button is at least 44 x 44 px.
//
// Busy: the button keeps its size, ignores presses and tells screen readers
// what is happening through busyLabel ("Saving your answer").

export type ButtonVariant = 'primary' | 'secondary' | 'quiet'

interface ButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
  variant?: ButtonVariant
  children: ReactNode
  /** Shown to screen readers while busy, as a full sentence. */
  busyLabel?: string
  busy?: boolean
  /** Fills the width of its container. */
  block?: boolean
  /** Reference page only: shows the hover or pressed look without a pointer. */
  showState?: 'hover' | 'pressed'
}

export function Button({
  variant = 'primary',
  children,
  busy = false,
  busyLabel,
  block = false,
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
