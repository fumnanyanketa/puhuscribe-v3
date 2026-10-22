import type { PromptWord } from '../lib/review-types.ts'
import styles from './GapLine.module.css'

// The prompt line of a review item (factory/jobs/9-daily-review/spec.md, "Done
// when" 8): one dialogue line in one register, with a gap where the missing
// word goes. Spoken lines sit on the teal band labelled "Spoken", as in
// FinnishLine; written lines are labelled "Written". The line is lang="fi";
// a screen reader says "missing word" at the gap, which is drawn as a blank
// line of the same height as the words.

interface GapLineProps {
  register: 'spoken' | 'written'
  words: readonly PromptWord[]
}

export const GAP_NAME = 'missing word'

export function GapLine({ register, words }: GapLineProps) {
  const spoken = register === 'spoken'
  return (
    <div className={spoken ? styles.spokenBand : styles.written}>
      <p className={spoken ? styles.labelSpoken : styles.labelWritten}>{spoken ? 'Spoken' : 'Written'}</p>
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
    </div>
  )
}
