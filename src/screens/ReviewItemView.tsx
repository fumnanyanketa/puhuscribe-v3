import { GapLine } from '../components/GapLine.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import type { ReviewItem, TypedAnswer } from '../lib/review-types.ts'
import { ANSWER_METHODS, methodFormId, type AnswerMethod, type RecordedResult } from './answer-methods.ts'
import { LINE_AUDIO, Meaning } from './LineCard.tsx'
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
  onAnswer: (answer: TypedAnswer) => void
  /** A spoken answer was recorded (or recording failed). */
  onRecorded?: (result: RecordedResult) => void
  /** The answer methods; the one list in answer-methods.ts unless a test gives another. */
  methods?: readonly AnswerMethod[]
  /** "Word 3 of 15." (job 9, statement 8), small at the card's top right where a line card says "Line 2 of 8". */
  place?: string
}

export function ReviewItemView({
  item,
  formBase,
  disabled,
  onReady,
  onAnswer,
  onRecorded = () => undefined,
  methods = ANSWER_METHODS,
  place,
}: ReviewItemViewProps) {
  const what = item.register === 'spoken' ? LINE_AUDIO.spoken : LINE_AUDIO.written
  return (
    <div className={styles.reviewItem} data-review-item={item.formId}>
      <div className={styles.card}>
        <div className={styles.cardHead}>
          <p className={styles.speaker}>{item.speaker}</p>
          {place && <p className={styles.count}>{place}</p>}
        </div>
        <GapLine
          register={item.register}
          words={item.words}
          control={
            <PlayControl
              src={item.audio}
              what={what}
              size={item.register === 'spoken' ? 'regular' : 'small'}
              tone={item.register === 'spoken' ? 'spoken' : 'written'}
            />
          }
        />
        <Meaning english={item.gloss} />
      </div>
      <div className={styles.answerArea} data-answer-area="">
        {methods.map(({ kind, Answer }) => (
          <Answer
            key={kind}
            formId={methodFormId(formBase, kind)}
            disabled={disabled}
            onReady={onReady}
            onAnswer={onAnswer}
            onRecorded={onRecorded}
          />
        ))}
      </div>
    </div>
  )
}
