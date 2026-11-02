// The road scene's geometry, ported from the owner's approved drawing
// (design-drafts/road-journey.html, job 19-redesign). The drawing's scene is a
// 280 x 620 box whose road runs on to 660, below the phone's edge; here the box
// is 280 x 660, so the road runs on behind the bottom card to the screen's edge
// as drawn (round 6). The road runs in perspective from the bottom of the box
// to the horizon, where the A1 sun sits. All of it is fixed numbers and
// shapes; nothing in it comes from learner or stop data.

export const SCENE_WIDTH = 280
export const SCENE_HEIGHT = 660
export const HORIZON = 238
const BOTTOM = 660

/** Vertical position of the road at t (0 at the bottom, 1 at the horizon). */
export function yAt(t: number): number {
  return HORIZON + (BOTTOM - HORIZON) * Math.pow(1 - t, 1.9)
}

/** Horizontal centre of the road at t, with the drawing's bend of 34 (round 6, back from round 2's 48). */
export const BEND = 34

export function xAt(t: number): number {
  return 142 + BEND * Math.sin(t * Math.PI * 1.7) * (1 - t * 0.9)
}

/** Width of the road at t. */
export function wAt(t: number): number {
  return 168 * Math.pow(1 - t, 1.55) + 3
}

/** The t at which the road sits at the given height of the scene box. */
export function tAtY(y: number): number {
  const share = (y - HORIZON) / (BOTTOM - HORIZON)
  return 1 - Math.pow(Math.min(1, Math.max(0, share)), 1 / 1.9)
}

type Point = [number, number]

const fixed = (n: number): string => n.toFixed(1)

export function pointsText(points: Point[]): string {
  return points.map((p) => `${fixed(p[0])},${fixed(p[1])}`).join(' ')
}

/** One edge of the road between two t values. */
export function edge(side: -1 | 1, from: number, to: number, k = 1): Point[] {
  const points: Point[] = []
  for (let i = 0; i <= 70; i++) {
    const t = from + ((to - from) * i) / 70
    points.push([xAt(t) + (side * wAt(t) * k) / 2, yAt(t)])
  }
  return points
}

/** The whole road between two t values, as a polygon. */
export function roadPolygon(from: number, to: number, k = 1): string {
  return pointsText([...edge(-1, from, to, k), ...edge(1, from, to, k).reverse()])
}

/** A short stretch of the centre line, as a polygon. */
export function stripe(t0: number, t1: number, k: number): string {
  const w0 = Math.max(0.45, wAt(t0) * k)
  const w1 = Math.max(0.4, wAt(t1) * k)
  return pointsText([
    [xAt(t0) - w0, yAt(t0)],
    [xAt(t0) + w0, yAt(t0)],
    [xAt(t1) + w1, yAt(t1)],
    [xAt(t1) - w1, yAt(t1)],
  ])
}

/** The dashes of the centre line from one t to another. */
export function dashPolygons(from: number, to: number): string[] {
  const dashes: string[] = []
  for (let i = 0; i < 30; i++) {
    const t0 = from + ((to - from) * i) / 30
    const t1 = t0 + ((to - from) * 0.5) / 30
    dashes.push(stripe(t0, t1, 0.026))
  }
  return dashes
}

/** The travelled stretch of centre line: solid, from the bottom up to t. */
export function travelledPolygons(to: number): string[] {
  const pieces: string[] = []
  for (let i = 0; i < 24; i++) {
    const t0 = (to * i) / 24
    const t1 = (to * (i + 1)) / 24 + 0.002
    pieces.push(stripe(t0, t1, 0.032))
  }
  return pieces
}

/** Small pines along the horizon, at fixed places. */
export function horizonPines(): { d: string; key: number }[] {
  return [8, 18, 27, 39, 52, 61, 74, 88, 98, 186, 197, 209, 221, 232, 246, 257, 268, 276].map((x, i) => {
    const h = 9 + ((i * 7) % 6)
    const b = 234 + Math.sin(x / 40) * 4
    return {
      key: x,
      d: `M${String(x)} ${fixed(b - h)} L${fixed(x - h * 0.38)} ${fixed(b)} L${fixed(x + h * 0.38)} ${fixed(b)} Z`,
    }
  })
}

/** Small pines for the band behind lesson screens, at fixed places. */
export function bandPines(): { d: string; key: number }[] {
  return [14, 26, 36, 49, 61, 150, 163, 176, 236, 248, 262].map((x, i) => {
    const h = 7 + ((i * 5) % 5)
    const b = 112 + Math.sin(x / 30) * 4
    return {
      key: x,
      d: `M${String(x)} ${fixed(b - h)} L${fixed(x - h * 0.38)} ${fixed(b)} L${fixed(x + h * 0.38)} ${fixed(b)} Z`,
    }
  })
}

/** Where a fell's summit flag stands, in scene units. */
export const FELLS = {
  A2: { x: 222, y: HORIZON - 52 },
  B1: { x: 86, y: HORIZON - 72 },
  B2: { x: 160, y: HORIZON - 94 },
} as const

/**
 * The positions of the signs, from the nearest to the farthest, each on the
 * other side of the road from the one before. They stand where the drawing
 * puts them (road-journey.html, round 6): at five fixed places on the road,
 * higher and smaller toward the horizon, each a little beside the road. Two
 * rules move them. A sign's foot stands at least SIGN_CLEAR_OF_SUN below the
 * horizon, so no board covers the sun, its "A1" or the fell labels (the
 * drawing's farthest sign touches the sun). And `lowest` is the lowest scene
 * height a foot may stand at, so the card at the bottom never covers one: when
 * the nearest drawn place is below it, the places are drawn closer together
 * toward the horizon. `minGap` keeps two neighbouring signs apart, so tall
 * boards (large text) never touch; when there is no room, the road screen
 * shows fewer signs.
 */
export interface SignSpot {
  /** Centre of the sign's foot, in scene units. */
  x: number
  y: number
  /** Where on the road the sign stands (0 at the bottom, 1 at the horizon). */
  t: number
  /** The drawing's perspective: 1 near, smaller toward the horizon. The text never goes under 12 px. */
  scale: number
  side: -1 | 1
}

/** Where the drawing puts the five signs on the road, from the nearest (the drawing's STOPS). */
export const DRAWN_SIGN_T = [0.3, 0.46, 0.59, 0.7, 0.78] as const

/** A sign's foot stands at least this far below the horizon (scene units), so its board stays below the sun. */
export const SIGN_CLEAR_OF_SUN = 50

/** The least height between two neighbouring signs' feet (scene units), so a board never sits on the next one. */
export const SIGN_STEP = 22

/** The drawing's perspective scale of a sign at t. */
export function signScale(t: number): number {
  return 1 - t * 0.5
}

export function signSpots(
  count: number,
  lowest: number,
  firstSide: -1 | 1 = 1,
  /** The least height between two neighbouring signs' feet, in scene units, so tall boards never touch. */
  minGap = 0,
): SignSpot[] {
  const top = HORIZON + SIGN_CLEAR_OF_SUN
  const bottom = Math.min(Math.max(lowest, top + 24), 560)
  const drawn = Array.from({ length: Math.min(count, 5) }, (_, i) =>
    Math.max(top, yAt(DRAWN_SIGN_T[i] ?? 0.78)),
  )
  // From the farthest down: a sign stands at least a step below the one beyond it (more when large
  // text makes the boards tall), then the places are drawn closer together if the card needs the room.
  const step = Math.max(SIGN_STEP, minGap)
  for (let i = drawn.length - 2; i >= 0; i--)
    drawn[i] = Math.max(drawn[i] ?? top, (drawn[i + 1] ?? top) + step)
  const nearest = drawn[0] ?? bottom
  const squeeze = nearest > bottom ? (bottom - top) / Math.max(1, nearest - top) : 1
  const ys = drawn.map((y) => top + (y - top) * squeeze)
  // Squeezed too close for tall boards (a short phone with large text): the gap wins over the sun, and the
  // road screen then shows fewer signs, because no board may cover the sun or another board.
  for (let i = 1; i < ys.length; i++) ys[i] = Math.min(ys[i] ?? top, (ys[i - 1] ?? top) - step)
  return ys.map((y, i) => {
    const t = tAtY(y)
    const side = (i % 2 === 0 ? firstSide : -firstSide) as -1 | 1
    const scale = signScale(t)
    const x = Math.min(206, Math.max(64, xAt(t) + side * (wAt(t) * 0.61 + 34 * scale)))
    return { x, y, t, scale, side }
  })
}

/**
 * The "you" marker stands on the road a little nearer than its sign, as drawn (0.27 beside a sign at
 * 0.3), unless that would bring it within 20 scene units of `lowest` (the card): then it stands level
 * with its sign, so the card never covers it.
 */
export function markerT(signT: number, lowest = Infinity): number {
  const nearer = Math.max(0, signT - 0.03)
  return yAt(nearer) + 20 > lowest ? signT : nearer
}

/** The sun's disc above the horizon, in scene units, which no sign may cover (round 6). */
export const SUN_BOX = { left: 120, right: 180, top: HORIZON - 36, bottom: HORIZON + 2 } as const
