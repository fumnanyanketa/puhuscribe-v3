// The road scene's geometry, ported from the owner's approved drawing
// (design-drafts/road-journey.html, job 19-redesign). The scene is drawn in a
// 280 x 620 box. The road runs in perspective from the bottom of the box to
// the horizon, where the A1 sun sits. All of it is fixed numbers and shapes;
// nothing in it comes from learner or stop data.

export const SCENE_WIDTH = 280
export const SCENE_HEIGHT = 620
export const HORIZON = 238
const BOTTOM = 660

/** Vertical position of the road at t (0 at the bottom, 1 at the horizon). */
export function yAt(t: number): number {
  return HORIZON + (BOTTOM - HORIZON) * Math.pow(1 - t, 1.9)
}

/** Horizontal centre of the road at t. */
export function xAt(t: number): number {
  return 142 + 34 * Math.sin(t * Math.PI * 1.7) * (1 - t * 0.9)
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
 * The positions of the five signs, from the nearest to the farthest. The
 * nearest is the lowest on the screen; each is placed on alternate sides of the
 * road. `lowest` is the lowest scene height a sign may stand at, so the card
 * at the bottom never covers one.
 */
export interface SignSpot {
  /** Centre of the sign's foot, in scene units. */
  x: number
  y: number
  /** Share of full size, kept high enough that its text stays at 12 px or more. */
  scale: number
  side: -1 | 1
}

export function signSpots(count: number, lowest: number, firstSide: -1 | 1 = 1): SignSpot[] {
  const nearest = tAtY(Math.min(lowest, 560))
  const farthest = 0.72
  const spots: SignSpot[] = []
  for (let i = 0; i < count; i++) {
    const share = count === 1 ? 0 : i / (count - 1)
    // Nearer signs are further apart: the road is in perspective.
    const t = nearest + (farthest - nearest) * Math.pow(share, 0.85)
    const side = (i % 2 === 0 ? firstSide : -firstSide) as -1 | 1
    const scale = 1 - share * 0.07
    const x = Math.min(205, Math.max(70, xAt(t) + side * (wAt(t) * 0.55 + 40)))
    spots.push({ x, y: yAt(t), scale, side })
  }
  return spots
}
