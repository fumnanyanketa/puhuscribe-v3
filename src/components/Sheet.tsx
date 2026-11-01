import {
  useEffect,
  useRef,
  type MouseEvent,
  type ReactNode,
  type RefObject,
  type SyntheticEvent,
} from 'react'
import styles from './Sheet.module.css'

// A bottom sheet (design.md, "Sheets"): a native <dialog> opened with
// showModal(), so the page behind cannot be used and Tab stays inside. It
// rises from the bottom on a phone and fades in with reduced motion. Escape
// and a tap on the dimmed page close it through onClose (a sheet that must not
// close that way passes closable={false}). While it is open the page behind
// cannot scroll. Focus moves to `initialFocus` (or the sheet's title) on open
// and goes back to what had it before when the sheet closes, because
// <dialog> alone does not do that on older iPhones (job 5).

interface SheetProps {
  open: boolean
  onClose: () => void
  /** The id of the sheet's heading, which names the dialog. */
  labelledBy: string
  children: ReactNode
  /** What gets focus when the sheet opens. Defaults to the first thing inside it. */
  initialFocus?: RefObject<HTMLElement | null>
  /** Escape and a tap outside close the sheet. On unless turned off. */
  closable?: boolean
  className?: string
}

export function Sheet({
  open,
  onClose,
  labelledBy,
  children,
  initialFocus,
  closable = true,
  className,
}: SheetProps) {
  const dialog = useRef<HTMLDialogElement>(null)

  useEffect(() => {
    const element = dialog.current
    if (!element || !open) return undefined
    const opener = document.activeElement instanceof HTMLElement ? document.activeElement : null
    if (!element.open) element.showModal()
    const root = document.documentElement
    const before = root.style.overflow
    root.style.overflow = 'hidden'
    const target = initialFocus?.current ?? element.querySelector<HTMLElement>('[data-sheet-focus]')
    target?.focus()
    return () => {
      root.style.overflow = before
      if (element.open) element.close()
      opener?.focus()
    }
  }, [open, initialFocus])

  function cancel(event: SyntheticEvent<HTMLDialogElement>) {
    event.preventDefault()
    if (closable) onClose()
  }

  // A tap on the dimmed page lands on the dialog element itself, because the
  // sheet's content fills an inner box.
  function tapOutside(event: MouseEvent<HTMLDialogElement>) {
    if (closable && event.target === event.currentTarget) onClose()
  }

  return (
    // Escape already closes the dialog; the click only adds "tap outside".
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <dialog
      ref={dialog}
      className={className ? `${styles.sheet} ${className}` : styles.sheet}
      onCancel={cancel}
      onClick={tapOutside}
      aria-labelledby={labelledBy}
    >
      {open && <div className={styles.body}>{children}</div>}
    </dialog>
  )
}
