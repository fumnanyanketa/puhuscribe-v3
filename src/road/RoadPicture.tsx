import { useLayoutEffect, useRef, type CSSProperties } from 'react'
import { RoadBackdrop, RoadWay } from '../components/Landscape.tsx'
import {
  HORIZON,
  markerT,
  SCENE_HEIGHT,
  SCENE_WIDTH,
  signSpots,
  xAt,
  yAt,
} from '../components/landscape-geometry.ts'
import type { SampleLine } from '../lib/road-types.ts'
import type { SignView } from '../lib/road-state.ts'
import styles from './RoadPicture.module.css'

// The road picture (job 19-redesign, statements 12 and 13): the scene, the
// three fell labels, five signs and the pulsing "you" marker. The art is the
// scene SVG; the labels and the signs are real HTML text, so names wrap at
// large text sizes and screen readers read them. Every position is a share of
// the 280 x 620 scene box, so the picture scales with the screen width.
//
// A sign is a list item, not a button: no drawing shows one doing anything,
// and tapping one does nothing. Names are rendered as text, never as HTML.

interface RoadPictureProps {
  signs: readonly SignView[]
  /** Index in `signs` of the stop the "you" marker stands at. */
  markerAt: number
  /** How far up the road the learner has travelled, 0 to 1. */
  travelledTo: number
  /** The least height between two signs, in scene units (tall boards at large text). */
  signGap?: number
  /** Sideways nudges in px by stop number, so no board runs past the edge of the screen. */
  shifts?: Readonly<Record<number, number>>
  /** The lowest scene height a sign may stand at, so the card never covers one. */
  lowest: number
  evening?: boolean
  /** The opening animation is playing: the picture animates in. */
  intro?: boolean
  /** One approved spoken line to show as a speech bubble, only while the opening animation plays. */
  sampleLine?: SampleLine
}

const percentX = (x: number) => `${String((x / SCENE_WIDTH) * 100)}%`
const percentY = (y: number) => `${String((y / SCENE_HEIGHT) * 100)}%`

function Tick() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" className={styles.tick}>
      <path d="M5 12.5l4.5 4.5L19 7.5" />
    </svg>
  )
}

function Flag() {
  return (
    <svg viewBox="0 0 12 22" className={styles.flag} aria-hidden="true" focusable="false">
      <path className={styles.flagPole} d="M1 0v22" />
      <path className={styles.flagCloth} d="M1.5 1l10 4.5-10 4.5z" />
    </svg>
  )
}

const FELLS = [
  { name: 'A2', x: 222, y: HORIZON - 52 },
  { name: 'B1', x: 86, y: HORIZON - 72 },
  { name: 'B2', x: 160, y: HORIZON - 94 },
] as const

export function RoadPicture({
  signs,
  markerAt,
  travelledTo,
  signGap = 0,
  shifts: given,
  lowest,
  evening = false,
  intro = false,
  sampleLine,
}: RoadPictureProps) {
  const spots = signSpots(signs.length, lowest, 1, signGap)
  // Without nudges from the road screen (the reference page), the picture nudges its own boards back
  // inside the screen, 8 px from the edge, so a long name never runs past it.
  const box = useRef<HTMLDivElement>(null)
  const shifts = given ?? {}
  useLayoutEffect(() => {
    if (given) return undefined
    const items = [...(box.current?.querySelectorAll<HTMLElement>('ol > li') ?? [])]
    const nudge = () => {
      for (const item of items) {
        const board = item.querySelector('[aria-hidden="true"]')?.getBoundingClientRect()
        if (!board) continue
        const now = parseFloat(item.style.getPropertyValue('--shift')) || 0
        const room = document.documentElement.clientWidth - 8
        const delta = board.right > room ? room - board.right : board.left < 8 ? 8 - board.left : 0
        if (Math.abs(delta) >= 1) item.style.setProperty('--shift', `${String(now + delta)}px`)
      }
    }
    nudge()
    // A larger text size makes the boards wider without a new render: nudge again when they change.
    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(nudge)
    for (const item of items) observer?.observe(item)
    return () => {
      observer?.disconnect()
    }
  })
  const marker = spots.at(markerAt)
  const youAt = marker ? markerT(marker.t, lowest) : 0
  return (
    <div
      ref={box}
      className={styles.box}
      data-land={evening ? 'evening' : undefined}
      data-intro={intro ? 'on' : undefined}
    >
      <RoadBackdrop evening={evening} className={styles.backdrop} sunClassName={styles.sunRise} />
      {/* The mint runs from the bottom of the road up to the "you" marker (round 2, design review), so it is always seen between the card and the marker. Nothing is drawn while nothing is travelled. */}
      <RoadWay
        travelledTo={travelledTo > 0 ? (marker ? youAt : travelledTo) : 0}
        evening={evening}
        className={styles.way}
      />
      <ul className={styles.fells} aria-label="Levels beyond A1">
        {FELLS.map((fell) => (
          <li
            key={fell.name}
            className={styles.fell}
            style={{ left: percentX(fell.x), top: percentY(fell.y) }}
          >
            <Flag />
            <span className={styles.fellName}>{fell.name}</span>
          </li>
        ))}
      </ul>
      <ol className={styles.signs} aria-label="Stops on your road">
        {signs.map((sign, index) => {
          const spot = spots.at(index)
          if (!spot) return null
          return (
            <li
              key={sign.stop.number}
              className={`${styles.sign} ${styles[sign.state]}`}
              style={
                {
                  left: percentX(spot.x),
                  top: percentY(spot.y),
                  '--shift': `${String(shifts[sign.stop.number] ?? 0)}px`,
                  // The pole's place as a share of the box, so the stylesheet can keep the board inside the picture.
                  '--x': (spot.x / SCENE_WIDTH).toFixed(4),
                  '--sc': spot.scale.toFixed(3),
                } as CSSProperties
              }
              data-state={sign.state}
              data-stop={sign.stop.number}
            >
              <span className={styles.size}>
                <span className={styles.pop}>
                  <span className={styles.board} aria-hidden="true">
                    {/* As drawn: a done sign has its tick in a small white square, the current sign its
                        number; the next and later signs show the name only (round 6). */}
                    {(sign.state === 'done' || sign.state === 'current') && (
                      <span className={styles.num}>
                        {sign.state === 'done' ? <Tick /> : sign.stop.number}
                      </span>
                    )}
                    <span className={styles.name}>{sign.stop.name}</span>
                  </span>
                  <span className={styles.pole} aria-hidden="true" />
                  <span className={styles.foot} aria-hidden="true" />
                </span>
              </span>
              <span className={styles.hidden}>{sign.label}</span>
            </li>
          )
        })}
      </ol>
      {marker && (
        <span
          className={styles.you}
          style={{ left: percentX(xAt(youAt)), top: percentY(yAt(youAt)) }}
          aria-hidden="true"
          data-testid="you-marker"
        >
          <span className={styles.halo} />
          <span className={styles.pulse} />
          <span className={styles.dot} />
        </span>
      )}
      {intro && sampleLine && marker && (
        <p
          className={styles.say}
          style={{ left: percentX(marker.x), top: percentY(marker.y - 38) }}
          aria-hidden="true"
          lang="fi"
        >
          {sampleLine.words.map((word, index) => (
            <span key={index} className={word.changes ? styles.changed : undefined}>
              {index > 0 ? ' ' : ''}
              {word.text}
            </span>
          ))}
        </p>
      )}
    </div>
  )
}
