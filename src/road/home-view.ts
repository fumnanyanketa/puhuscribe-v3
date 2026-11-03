import { nextReviewSentence } from '../lib/review-day.ts'
import { isRecord } from '../lib/api.ts'
import { SIGNED_OUT_EMAIL } from '../lib/account-notice.ts'
import {
  currentIndex,
  isStopFinished,
  markerIndex,
  progressSegments,
  signWindow,
  travelled,
  type SignView,
} from '../lib/road-state.ts'
import type { RoadStop, TodayState } from '../lib/road-types.ts'
import { ALL_DONE, ENDED, NOT_READY } from '../screens/road-copy.ts'
import type { CardView } from './RoadCard.tsx'

// What the home screen shows, worked out from the road and from the existing
// GET /api/today answer (job 19-redesign, statements 13 to 15). A pure
// function, so each card state is tested without a browser.

export interface TodayInfo {
  signedIn: boolean
  /** The sign in ended (a guest session or an email sign in). */
  ended: boolean
  /** The ended account was an email account. */
  email: boolean
  today?: TodayState
  /** The sentence about the next review, already worded. */
  nextReview?: string
  reviewCount?: number
}

/** Reads the answer of GET /api/today. Anything unclear counts as "no account on this device". */
export function todayInfoFrom(body: unknown): TodayInfo {
  const none: TodayInfo = { signedIn: false, ended: false, email: false }
  if (!isRecord(body)) return none
  if (body.signedIn !== true) {
    return { signedIn: false, ended: body.ended === true, email: body.account === 'email' }
  }
  const today = body.today
  if (
    today !== 'start' &&
    today !== 'continue' &&
    today !== 'review' &&
    today !== 'all_done' &&
    today !== 'not_ready'
  ) {
    return none
  }
  const next = body.nextReview
  const nextReview =
    isRecord(next) && typeof next.today === 'string' && typeof next.day === 'string'
      ? (nextReviewSentence(next.today, next.day) ?? undefined)
      : undefined
  const count = body.reviewCount
  return {
    signedIn: true,
    ended: false,
    email: false,
    today,
    ...(nextReview ? { nextReview } : {}),
    ...(typeof count === 'number' && Number.isInteger(count) && count > 0 ? { reviewCount: count } : {}),
  }
}

export interface HomeView {
  card: CardView
  signs: SignView[]
  /** Index in `signs` of the stop the "you" marker stands at. */
  markerAt: number
  travelledTo: number
  pieces: boolean[]
  evening: boolean
  /** Whether the opening animation plays: every time the road opens, for everyone (owner, 3 November 2026). The road screen leaves it out when reduced motion is on. */
  intro: boolean
  /** The stop the opening animation's sample line belongs to. */
  firstStop: RoadStop | undefined
}

export function homeView(stops: readonly RoadStop[], info: TodayInfo, notice: string | null): HomeView {
  const current = currentIndex(stops)
  const stop = stops.at(current)
  const first = stops.at(0)
  const state = info.signedIn ? info.today : undefined
  const stopFinished = isStopFinished(stops, info.signedIn ? (state ?? 'signed_out') : 'signed_out')
  const marker = markerIndex(stops, stopFinished)
  const { start, signs } = signWindow(stops, marker, stopFinished)

  let card: CardView
  let evening = false
  if (!info.signedIn) {
    const message = info.ended ? (info.email ? SIGNED_OUT_EMAIL : ENDED) : (notice ?? undefined)
    card = { kind: 'day-one', stop: first ?? placeholder(), ...(message ? { message } : {}) }
  } else if (state === 'review') {
    card = { kind: 'review', count: info.reviewCount ?? null }
  } else if (state === 'all_done') {
    evening = true
    card = info.nextReview ? { kind: 'done', line: info.nextReview } : { kind: 'message', text: ALL_DONE }
  } else if (state === 'not_ready') {
    evening = true
    card = { kind: 'message', text: NOT_READY }
  } else if (stopFinished && stop && stops.at(current - 1)) {
    card = { kind: 'stop-finished', done: stops.at(current - 1) ?? placeholder(), next: stop }
  } else {
    card = {
      kind: 'lesson',
      stop: stop ?? placeholder(),
      action: state === 'continue' ? 'Continue' : 'Start',
    }
  }

  return {
    card,
    signs,
    markerAt: marker - start,
    travelledTo: travelled(stops, marker),
    pieces: progressSegments(stops),
    evening,
    intro: true,
    firstStop: first,
  }
}

// The road always has stops when it is drawn (loadRoad refuses an empty list),
// so this is only a type guard that is never shown.
function placeholder(): RoadStop {
  return { number: 1, name: '', canDo: '', part: 1, lessons: 1, lessonsDone: 0 }
}
