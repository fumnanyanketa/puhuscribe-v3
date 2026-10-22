import { useEffect, useId, useRef, type MouseEvent, type SyntheticEvent } from 'react'
import type { PatternGroup, PatternsAnswer } from '../lib/patterns-types.ts'
import { Button } from './Button.tsx'
import { PlayControl } from './PlayControl.tsx'
import { StatusLine } from './StatusLine.tsx'
import styles from './PatternsPanel.module.css'

// "Patterns you've seen" (factory/jobs/12-units-1-3/spec.md, "Done when" 10,
// 12 and 13): reference behind a tap, opened only from a word card in a
// session. A sheet in the word card's style, on top of the card. It groups
// every word form the learner has met by its form name, and shows each form's
// spoken and written shape, its base form, its "why" and one line where the
// learner met it, with both play controls. No counts, scores, progress, due
// dates or practice of any kind. It closes with Close, Escape or a tap
// outside; whoever opened it gives focus back to its button.

export const PATTERNS_TITLE = "Patterns you've seen"
export const PATTERNS_INTRO = 'Word forms from the dialogues you have met, grouped by pattern.'
export const PATTERNS_ERROR = 'Could not load your patterns.'
const PATTERNS_LOADING = 'Loading your patterns.'

export type PatternsState =
  { kind: 'loading' } | { kind: 'error' } | { kind: 'ready'; answer: PatternsAnswer }

interface PatternsPanelProps {
  open: boolean
  /** The form name of the word card it was opened from: its group gets focus. */
  focusGroup: string | null
  state: PatternsState
  onClose: () => void
  onRetry: () => void
}

function Group({ group, headingId }: { group: PatternGroup; headingId: string }) {
  return (
    <section className={styles.group} aria-labelledby={headingId}>
      <h3 id={headingId} tabIndex={-1} className={styles.groupName} data-form-name={group.formName}>
        {group.formName}
      </h3>
      <ul className={styles.forms}>
        {group.forms.map((form) => (
          <li key={`${form.lemma} ${form.written} ${form.spoken}`} className={styles.form}>
            <div className={styles.shapes}>
              <div className={styles.shapeSpoken}>
                <p className={styles.labelSpoken}>Spoken</p>
                <p className={styles.shapeText} lang="fi">
                  {form.spoken}
                </p>
              </div>
              <div className={styles.shapeWritten}>
                <p className={styles.labelWritten}>Written</p>
                <p className={styles.shapeText} lang="fi">
                  {form.written}
                </p>
              </div>
            </div>
            <dl className={styles.facts}>
              <div>
                <dt>Base form</dt>
                <dd lang="fi">{form.lemma}</dd>
              </div>
              <div>
                <dt>Why</dt>
                <dd>{form.why}</dd>
              </div>
            </dl>
            <p className={styles.metLabel}>Where you met it</p>
            <div className={styles.lineSpoken}>
              <div>
                <p className={styles.labelSpoken}>Spoken</p>
                <p className={styles.lineText} lang="fi">
                  {form.line.spoken}
                </p>
              </div>
              <PlayControl src={form.line.spokenAudio} what="the spoken line" size="small" />
            </div>
            <div className={styles.lineWritten}>
              <div>
                <p className={styles.labelWritten}>Written</p>
                <p className={styles.lineText} lang="fi">
                  {form.line.written}
                </p>
              </div>
              <PlayControl src={form.line.writtenAudio} what="the written line" size="small" />
            </div>
          </li>
        ))}
      </ul>
    </section>
  )
}

export function PatternsPanel({ open, focusGroup, state, onClose, onRetry }: PatternsPanelProps) {
  const dialog = useRef<HTMLDialogElement>(null)
  const title = useRef<HTMLHeadingElement>(null)
  const titleId = useId()
  const groupId = useId()

  useEffect(() => {
    const element = dialog.current
    if (!element || !open) return undefined
    if (!element.open) element.showModal()
    const root = document.documentElement
    const before = root.style.overflow
    root.style.overflow = 'hidden'
    title.current?.focus()
    return () => {
      root.style.overflow = before
      if (element.open) element.close()
    }
  }, [open])

  // Once the groups are shown, the word card's own group gets focus.
  useEffect(() => {
    const element = dialog.current
    if (!element || !open || state.kind !== 'ready' || focusGroup === null) return
    const heading = [...element.querySelectorAll<HTMLElement>('[data-form-name]')].find(
      (h) => h.dataset.formName === focusGroup,
    )
    if (!heading) return
    heading.scrollIntoView({ block: 'start' })
    heading.focus()
  }, [open, state, focusGroup])

  // Escape makes the browser fire "cancel". The panel sits on top of the word
  // card, so the event stops here and only the panel closes.
  function cancel(event: SyntheticEvent<HTMLDialogElement>) {
    event.preventDefault()
    event.stopPropagation()
    onClose()
  }

  function tapOutside(event: MouseEvent<HTMLDialogElement>) {
    event.stopPropagation()
    if (event.target === event.currentTarget) onClose()
  }

  return (
    // Escape already closes the dialog; the click only adds "tap outside".
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <dialog
      ref={dialog}
      className={styles.sheet}
      onCancel={cancel}
      onClick={tapOutside}
      aria-labelledby={titleId}
      data-testid="patterns-panel"
    >
      {open && (
        <div className={styles.body}>
          <div className={styles.top}>
            <h2 id={titleId} ref={title} tabIndex={-1} className={styles.title}>
              {PATTERNS_TITLE}
            </h2>
            <button type="button" className={styles.close} onClick={onClose}>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
              Close
            </button>
          </div>
          <p className={styles.intro}>{PATTERNS_INTRO}</p>
          {state.kind === 'loading' && <StatusLine>{PATTERNS_LOADING}</StatusLine>}
          {state.kind === 'error' && (
            <div className={styles.problem}>
              <StatusLine tone="problem">{PATTERNS_ERROR}</StatusLine>
              <Button variant="secondary" onClick={onRetry}>
                Try again
              </Button>
            </div>
          )}
          {state.kind === 'ready' &&
            state.answer.groups.map((group, i) => (
              <Group key={group.formName} group={group} headingId={`${groupId}-${String(i)}`} />
            ))}
        </div>
      )}
    </dialog>
  )
}
