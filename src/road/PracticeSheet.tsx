import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import type { PracticeLesson } from '../lib/practice-types.ts'
import type { RoadStop } from '../lib/road-types.ts'
import styles from './PracticeSheet.module.css'

// The practice sheet (owner's fast route go-back, 3 November 2026): opened from a done stop's sign on
// the road, or from the "stop done" card, it lists the stop's finished lessons. Picking one plays it
// again as practice (src/screens/PracticePage.tsx). It says plainly that practice changes nothing.

export const PRACTICE_LEAD =
  'Play a lesson again as practice. Your road and your review words stay as they are.'
export const PRACTICE_LOADING = 'Loading your lessons.'
export const PRACTICE_NOT_LOADED =
  'Your lessons could not be loaded. Check your internet connection, then try again.'
const NONE = 'There is no finished lesson to practise here yet.'

export type PracticeList =
  { kind: 'loading' } | { kind: 'problem' } | { kind: 'ready'; lessons: PracticeLesson[] }

interface PracticeSheetProps {
  titleId: string
  stop: RoadStop
  list: PracticeList
  onPick: (lesson: PracticeLesson) => void
  onRetry: () => void
  onClose: () => void
}

/** "Practise Greetings": the sheet's title. */
export function practiceTitle(stop: RoadStop): string {
  return `Practise ${stop.name}`
}

export function PracticeSheet({ titleId, stop, list, onPick, onRetry, onClose }: PracticeSheetProps) {
  const lessons = list.kind === 'ready' ? list.lessons.filter((lesson) => lesson.stop === stop.number) : []
  return (
    <div className={styles.box}>
      <h2 id={titleId} className={styles.title} tabIndex={-1} data-sheet-focus="">
        {practiceTitle(stop)}
      </h2>
      <p className={styles.lead}>{PRACTICE_LEAD}</p>
      {list.kind === 'loading' && <StatusLine>{PRACTICE_LOADING}</StatusLine>}
      {list.kind === 'problem' && (
        <>
          <StatusLine tone="problem">{PRACTICE_NOT_LOADED}</StatusLine>
          <Button variant="secondary" block onClick={onRetry}>
            Try again
          </Button>
        </>
      )}
      {list.kind === 'ready' && lessons.length === 0 && <p className={styles.lead}>{NONE}</p>}
      {lessons.length > 0 && (
        <ul className={styles.lessons} aria-label={`Finished lessons of ${stop.name}`}>
          {lessons.map((lesson) => (
            <li key={lesson.dialogueId}>
              <Button
                variant="secondary"
                block
                className={styles.lesson}
                onClick={() => {
                  onPick(lesson)
                }}
              >
                <span>
                  <span className={styles.lessonNumber}>Lesson {lesson.lesson}. </span>
                  {lesson.title}
                </span>
              </Button>
            </li>
          ))}
        </ul>
      )}
      <Button variant="quiet" onClick={onClose}>
        Close
      </Button>
    </div>
  )
}
