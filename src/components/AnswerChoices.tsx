import styles from './AnswerChoices.module.css'

// Answer choice rows (factory/jobs/8-first-session/spec.md, "Done when" 13).
// One full width row per choice, in v2's white pill look with a visible edge.
// A wrong choice becomes unavailable: muted, a dashed edge and the words
// "not this one" for screen readers. Never red, no cross, no score. The right
// choice gets a tick and "that is right". Each row stays focusable in every
// state (aria-disabled, not disabled), so keyboard focus is never lost.

interface AnswerChoicesProps {
  choices: readonly string[]
  /** Choices already tried and found wrong. */
  unavailable: ReadonlySet<number>
  /** The right choice, once it has been chosen. */
  right: number | null
  onChoose: (index: number) => void
  /** The id of the question's heading, which names the group. */
  labelledBy: string
}

function Tick() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={styles.tick}>
      <path d="M5 12.5l4.5 4.5L19 7.5" />
    </svg>
  )
}

export function AnswerChoices({ choices, unavailable, right, onChoose, labelledBy }: AnswerChoicesProps) {
  return (
    <ul className={styles.list} aria-labelledby={labelledBy}>
      {choices.map((choice, i) => {
        const wrong = unavailable.has(i)
        const isRight = right === i
        const locked = wrong || right !== null
        const look = isRight ? styles.right : wrong ? styles.wrong : styles.choice
        return (
          <li key={choice}>
            <button
              type="button"
              className={look}
              aria-disabled={locked || undefined}
              aria-pressed={isRight || undefined}
              onClick={() => {
                if (!locked) onChoose(i)
              }}
            >
              <span className={styles.text}>{choice}</span>
              {isRight && <Tick />}
              {wrong && <span className={styles.hidden}>, not this one</span>}
              {isRight && <span className={styles.hidden}>, that is right</span>}
            </button>
          </li>
        )
      })}
    </ul>
  )
}
