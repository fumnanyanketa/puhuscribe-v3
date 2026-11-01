import type { RoadStop, TodayState } from './road-types.ts'

// What the road shows, worked out from the stops and today's state
// (factory/jobs/19-redesign/spec.md, statements 13 to 15). Pure functions, so
// every rule is tested without a browser.

export type SignState = 'done' | 'current' | 'next' | 'later'

/** The first stop with a lesson left; the last stop when every stop is done. */
export function currentIndex(stops: readonly RoadStop[]): number {
  const index = stops.findIndex((stop) => stop.lessonsDone < stop.lessons)
  return index === -1 ? Math.max(0, stops.length - 1) : index
}

export function roadFinished(stops: readonly RoadStop[]): boolean {
  return stops.length > 0 && stops.every((stop) => stop.lessonsDone >= stop.lessons)
}

/**
 * "Stop finished": today's next lesson is a new one, the current stop has none
 * done, and it is not the first stop (so a stop was finished before it).
 */
export function isStopFinished(stops: readonly RoadStop[], today: TodayState | 'signed_out'): boolean {
  if (today !== 'start') return false
  const index = currentIndex(stops)
  return index > 0 && stops[index]?.lessonsDone === 0
}

/**
 * The stop the "you" marker stands at: the current stop, or the stop just
 * finished when the "Stop finished" card shows.
 */
export function markerIndex(stops: readonly RoadStop[], stopFinished: boolean): number {
  const index = currentIndex(stops)
  return stopFinished ? index - 1 : index
}

export interface SignView {
  stop: RoadStop
  state: SignState
  /** What a screen reader hears, such as "Stop 3, Grocery store, current". */
  label: string
}

const STATE_WORDS: Record<SignState, string> = {
  done: 'done',
  current: 'current',
  next: 'next',
  later: 'later',
}

/**
 * Five signs at a time: the marker's stop, up to two before it, and the rest
 * after it, shifted so five always show (at the start the current stop is
 * first). `count` is five unless the road has fewer stops.
 */
export function signWindow(
  stops: readonly RoadStop[],
  marker: number,
  stopFinished: boolean,
  count = 5,
): { start: number; signs: SignView[] } {
  const size = Math.min(count, stops.length)
  const start = Math.max(0, Math.min(marker - 2, stops.length - size))
  const signs = stops.slice(start, start + size).map((stop, offset): SignView => {
    const index = start + offset
    let state: SignState
    if (stopFinished) state = index <= marker ? 'done' : index === marker + 1 ? 'next' : 'later'
    else state = index < marker ? 'done' : index === marker ? 'current' : 'later'
    return { stop, state, label: `Stop ${String(stop.number)}, ${stop.name}, ${STATE_WORDS[state]}` }
  })
  return { start, signs }
}

/**
 * The progress bar: `segments` pieces (12, owner's call 12). A piece is filled
 * when every stop it covers is done, so with 36 stops one piece covers three.
 */
export function progressSegments(stops: readonly RoadStop[], segments = 12): boolean[] {
  if (stops.length === 0) return Array.from({ length: segments }, () => false)
  return Array.from({ length: segments }, (_, piece) => {
    const from = Math.floor((piece * stops.length) / segments)
    const to = Math.floor(((piece + 1) * stops.length) / segments)
    const covered = stops.slice(from, Math.max(to, from + 1))
    return covered.length > 0 && covered.every((stop) => stop.lessonsDone >= stop.lessons)
  })
}

/** How far up the road the learner has travelled, from 0 to 1, for the mint centre line. */
export function travelled(stops: readonly RoadStop[], marker: number): number {
  if (stops.length <= 1) return 0
  return Math.min(1, Math.max(0, marker / (stops.length - 1)))
}

/** One piece per lesson of the stop, filled for the lessons done. */
export function lessonSegments(stop: RoadStop): boolean[] {
  return Array.from({ length: stop.lessons }, (_, i) => i < stop.lessonsDone)
}

/** "Stop 3, lesson 2 of 4": the lesson the learner is at, never past the last. */
export function lessonLine(stop: RoadStop): string {
  const lesson = Math.min(stop.lessons, stop.lessonsDone + 1)
  return `Stop ${String(stop.number)}, lesson ${String(lesson)} of ${String(stop.lessons)}`
}

/** "Stop 1, 4 short lessons", for a visitor on day one. */
export function dayOneLine(stop: RoadStop): string {
  return `Stop ${String(stop.number)}, ${String(stop.lessons)} short lessons`
}

/** The first letter of an email, as the account button shows it. A guest gets G. */
export function accountLetter(kind: 'guest' | 'email', email?: string): string {
  if (kind === 'guest') return 'G'
  const first = email?.trim().charAt(0) ?? ''
  return /\p{L}|\p{N}/u.test(first) ? first.toUpperCase() : 'G'
}
