import type { RefObject } from 'react'
import { Button } from '../components/Button.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { JOURNEY_AUDIO } from '../lib/aleksi-intro.ts'
import { AleksiFace } from './AleksiFace.tsx'
import { CheckSlot } from './CheckSlot.tsx'
import styles from './RoadStart.module.css'

// The bottom of the clean road (fast route road-stops, owner approved 5 November 2026): no card, only one
// Start button, mint and centred. Above it, on the visit Aleksi has just introduced himself, his round
// photo and a white bubble. When the road has something to say (a session that ended, nothing ready
// today) it is one plain line above Start, or alone when there is nothing to start.
//
// The new intro (fast route intro-logo, owner approved 5 November 2026): the bubble holds his journey line
// in spoken Finnish with its meaning under it. While the intro plays it, Start waits, hidden; then Start
// and the bubble's play button come in.

/**
 * Aleksi's line on the road, on the visit he introduced himself, in spoken Finnish (a draft for the native
 * reviewer). The set phrase "lähteä matkaan" (owner, 5 November 2026: "viedä matkalle" is not an established
 * phrase). Its written form, not shown here, is "Lähdetään yhdessä matkaan!".
 */
export const JOURNEY_FI = 'Lähetään yhessä matkaan!'
export const JOURNEY_EN = 'Let’s set off on this journey together.'

interface RoadStartProps {
  /** False when nothing is ready: the road then has no Start. */
  showStart: boolean
  /** The one plain line above Start, if any. */
  note?: string
  /** Aleksi's bubble is in the page (it keeps its room so the signs never move when it shows). */
  bubble: boolean
  /** The bubble shows: the opening animation is over. */
  bubbleShown: boolean
  /** The bubble's play button shows: the intro has finished saying the line. */
  bubblePlayable: boolean
  /** The bubble fades in as it shows (the intro playing); otherwise it is there at once. */
  bubbleEnters: boolean
  /** Start waits, hidden but keeping its room, while the intro says Aleksi's line. */
  startWaits: boolean
  /** Start fades in (the intro played to its end); otherwise it is there at once. */
  startEnters: boolean
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
  bubblePlayable,
  bubbleEnters,
  startWaits,
  startEnters,
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
        <div
          className={styles.chat}
          data-shown={bubbleShown ? 'yes' : undefined}
          data-enters={bubbleEnters ? 'yes' : undefined}
          data-testid="road-bubble"
        >
          <AleksiFace />
          <div className={styles.bubble}>
            <div className={styles.bubbleText}>
              <p className={styles.finnish} lang="fi">
                {JOURNEY_FI}
              </p>
              <p className={styles.english}>{JOURNEY_EN}</p>
            </div>
            {bubblePlayable && <PlayControl src={JOURNEY_AUDIO} what="Aleksi’s line" size="small" />}
          </div>
        </div>
      )}
      {showStart && (
        <div
          className={styles.startArea}
          data-waits={startWaits ? 'yes' : undefined}
          data-enters={startEnters ? 'yes' : undefined}
        >
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
