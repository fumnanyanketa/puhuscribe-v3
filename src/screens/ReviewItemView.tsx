import { GapLine } from '../components/GapLine.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import type { ReviewAnswer, ReviewItem } from '../lib/review-types.ts'
import { ANSWER_METHODS, methodFormId, type AnswerMethod } from './answer-methods.ts'
import { LINE_AUDIO } from './LineCard.tsx'
import styles from './Screens.module.css'

// One review item before it is answered (factory/jobs/9-daily-review/spec.md,
// "Done when" 8, 9 and 15): the speaker, the line in one register with a gap
// for the missing word, its English meaning, one play control that plays the
// line only when pressed, and the answer area with every answer method from
// the one list. The other register and the word cards appear only after
// answering.

interface ReviewItemViewProps {
  item: ReviewItem
  /** The base id of the methods' forms. */
  formBase: string
  disabled: boolean
  onReady: (ready: boolean) => void
  onAnswer: (answer: ReviewAnswer) => void
  /** The answer methods; the one list in answer-methods.ts unless a test gives another. */
  methods?: readonly AnswerMethod[]
}

export function ReviewItemView({
  item,
  formBase,
  disabled,
  onReady,
  onAnswer,
  methods = ANSWER_METHODS,
}: ReviewItemViewProps) {
  const what = item.register === 'spoken' ? LINE_AUDIO.spoken : LINE_AUDIO.written
  return (
    <div className={styles.reviewItem} data-review-item={item.formId}>
      <div className={styles.card}>
        <p className={styles.speaker}>{item.speaker}</p>
        <GapLine register={item.register} words={item.words} />
        <p className={styles.promptGloss}>{item.gloss}</p>
        <div className={styles.promptControls}>
          <span className={styles.lineControl}>
            <PlayControl src={item.audio} what={what} size="small" />
            <span className={styles.controlLabel}>{item.register === 'spoken' ? 'Spoken' : 'Written'}</span>
          </span>
        </div>
      </div>
      <div className={styles.answerArea} data-answer-area="">
        {methods.map(({ kind, Answer }) => (
          <Answer
            key={kind}
            formId={methodFormId(formBase, kind)}
            disabled={disabled}
            onReady={onReady}
            onAnswer={onAnswer}
          />
        ))}
      </div>
    </div>
  )
}
