import type { RoadStop } from '../lib/road-types.ts'
import type { CardView } from './RoadCard.tsx'

// What the road's one Start button does (fast route road-stops, owner approved 5 November 2026). The road
// has no card any more: one Start, and Aleksi's stop screen before each stop. The work Start used to do
// stays as it was on each state of the card it replaces (src/road/home-view.ts works the state out):
//
// - "guest": POST /api/guest (it makes a guest account for a visitor through the Turnstile check, and
//   finds the account of a learner who has one), then the lesson. The old Start and Start review.
// - "session": straight to the lesson. The old Continue.
//
// Start first opens the stop screen when the learner is about to begin a stop, that is, none of the
// stop's lessons are done yet. Part way through a stop, in a review, or with a session already open, it
// goes straight on. When nothing is ready (done for today, not ready, every dialogue finished) the road
// has no Start, as the old card had no button then; it shows only that one plain line.

export type StartGo = 'guest' | 'session'

export type StartPlan =
  { kind: 'stop-screen'; stop: RoadStop; go: StartGo } | { kind: 'straight'; go: StartGo } | { kind: 'none' }

/** Before a stop: the stop screen. Part way through it (some lessons done): straight on. */
function viaStop(stop: RoadStop, go: StartGo): StartPlan {
  return stop.lessonsDone > 0 ? { kind: 'straight', go } : { kind: 'stop-screen', stop, go }
}

export function startPlan(card: CardView): StartPlan {
  switch (card.kind) {
    case 'day-one':
      return viaStop(card.stop, 'guest')
    case 'lesson':
      return card.action === 'Continue' ? { kind: 'straight', go: 'session' } : viaStop(card.stop, 'guest')
    case 'stop-finished':
      return viaStop(card.next, 'session')
    case 'review':
      return { kind: 'straight', go: 'guest' }
    case 'done':
    case 'message':
      return { kind: 'none' }
  }
}

/** The one plain line the road shows above Start (or alone, when there is no Start), if any. */
export function startNote(card: CardView): string | undefined {
  switch (card.kind) {
    case 'day-one':
      return card.message
    case 'done':
      return card.line
    case 'message':
      return card.text
    default:
      return undefined
  }
}
