import type { ReactNode } from 'react'
import type { PromptWord } from '../lib/review-types.ts'
import styles from './GapLine.module.css'

// The prompt line of a review item (factory/jobs/9-daily-review/spec.md, "Done
// when" 8; redrawn in job 19-redesign, statement 31): one dialogue line in one
// register, with a gap where the missing word goes, in the same look as the
// line card. A spoken line sits in a soft box with a mint dot, a written line
// is slate with a slate dot, and its play control sits at the end. The line is
// lang="fi"; a screen reader says "missing word" at the gap, which is drawn as
// a peach rule of the same height as the words.

interface GapLineProps {
  register: 'spoken' | 'written'
  words: readonly PromptWord[]
  /** The play control at the end of the line. */
  control?: ReactNode
}

export const GAP_NAME = 'missing word'

export function GapLine({ register, words, control }: GapLineProps) {
  const spoken = register === 'spoken'
  return (
    <div className={spoken ? styles.spokenRow : styles.writtenRow}>
      <span className={spoken ? styles.dotSpoken : styles.dotWritten} aria-hidden="true" />
      <p className={spoken ? styles.spokenLine : styles.writtenLine} lang="fi">
        {words.map((word, i) => (
          <span key={i}>
            {i > 0 && ' '}
            <span className={styles.keep}>
              {word.before}
              {'gap' in word ? (
                <span className={styles.gap} data-gap="">
                  <span className={styles.blank} aria-hidden="true" />
                  <span className={styles.hidden} lang="en">
                    {GAP_NAME}
                  </span>
                </span>
              ) : (
                word.text
              )}
              {word.after}
            </span>
          </span>
        ))}
      </p>
      {control}
    </div>
  )
}
