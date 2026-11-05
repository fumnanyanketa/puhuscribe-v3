import type { RefObject } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { AleksiFace } from './AleksiFace.tsx'
import { CheckSlot } from './CheckSlot.tsx'
import styles from './RoadStart.module.css'

// The bottom of the clean road (fast route road-stops, owner approved 5 November 2026): no card, only one
// Start button, mint and centred. Above it, on the visit Aleksi has just introduced himself, his round
// photo and a white bubble. When the road has something to say (a session that ended, nothing ready
// today) it is one plain line above Start, or alone when there is nothing to start.

/** Aleksi's line on the road, on the visit he introduced himself. */
export const ROAD_BUBBLE = 'These are the stops I’ll take you through.'

interface RoadStartProps {
  /** False when nothing is ready: the road then has no Start. */
  showStart: boolean
  /** The one plain line above Start, if any. */
  note?: string
  /** Aleksi's bubble is in the page (it keeps its room so the signs never move when it shows). */
  bubble: boolean
  /** The bubble shows: the opening animation is over. */
  bubbleShown: boolean
  onStart: () => void
  starting: boolean
  problem: string | null
  startRef: RefObject<HTMLButtonElement | null>
  checkRef: RefObject<HTMLDivElement | null>
  asking: boolean
}

export function RoadStart({
  showStart,
  note,
  bubble,
  bubbleShown,
  onStart,
  starting,
  problem,
  startRef,
  checkRef,
  asking,
}: RoadStartProps) {
  return (
    <div className={styles.area}>
      {note && (
        <p className={styles.note} role="status">
          {note}
        </p>
      )}
      {bubble && (
        <div className={styles.chat} data-shown={bubbleShown ? 'yes' : undefined} data-testid="road-bubble">
          <AleksiFace />
          <p className={styles.bubble}>{ROAD_BUBBLE}</p>
        </div>
      )}
      {showStart && (
        <div className={styles.startArea}>
          <CheckSlot checkRef={checkRef} asking={asking} />
          <Button
            ref={startRef}
            className={styles.start}
            arrow={false}
            busy={starting}
            busyLabel="Starting your session."
            onClick={onStart}
          >
            Start
          </Button>
        </div>
      )}
      {problem && (
        <div className={styles.problem}>
          <StatusLine tone="problem">{problem}</StatusLine>
        </div>
      )}
    </div>
  )
}
