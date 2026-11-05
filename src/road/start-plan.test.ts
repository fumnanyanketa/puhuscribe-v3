import { describe, expect, it } from 'vitest'
import { ALL_DONE, ENDED, NOT_READY } from '../screens/road-copy.ts'
import { homeView, todayInfoFrom } from './home-view.ts'
import { roadFixture } from './road-fixture.ts'
import { startNote, startPlan } from './start-plan.ts'

// Fast route road-stops (owner approved 5 November 2026): what the road's one Start does in each state.
// "Done when" 4 (Start opens the stop screen for the right stop), 5 (Continue then does what Start did
// before: "guest" makes or finds the account, "session" opens the open session) and 7 (part way through a
// stop, Start goes straight to the lesson).

const visitor = todayInfoFrom({ signedIn: false, ended: false })
const signedIn = (today: string, extra: Record<string, unknown> = {}) =>
  todayInfoFrom({ signedIn: true, today, ...extra })
const planOf = (info: ReturnType<typeof todayInfoFrom>, done: Record<number, number> = {}) =>
  startPlan(homeView(roadFixture(done), info, null).card)
const firstStops = (count: number) =>
  Object.fromEntries(Array.from({ length: count }, (_, i) => [i + 1, 4] as const))

describe('what Start does', () => {
  it('[road-stops 4] [road-stops 5] a visitor: the stop screen for stop 1, and Continue makes the guest account', () => {
    const plan = planOf(visitor)
    expect(plan.kind).toBe('stop-screen')
    if (plan.kind !== 'stop-screen') return
    expect(plan.stop.number).toBe(1)
    expect(plan.stop.name).toBe('Meeting people')
    expect(plan.go).toBe('guest')
    // A visitor whose guest session ended starts again at stop 1 too.
    expect(planOf(todayInfoFrom({ signedIn: false, ended: true }))).toMatchObject({ kind: 'stop-screen' })
  })

  it('[road-stops 4] a learner about to begin stop 25 gets the stop screen for stop 25', () => {
    const plan = planOf(signedIn('start'), firstStops(24))
    expect(plan).toMatchObject({ kind: 'stop-screen', stop: { number: 25, name: 'Coffee break and sauna' } })
  })

  it('[road-stops 4] a stop just finished: Start shows the next stop, and Continue goes to the lesson as the old Continue did', () => {
    const plan = planOf(signedIn('start'), { 1: 4, 2: 4, 3: 4 })
    expect(plan).toMatchObject({ kind: 'stop-screen', go: 'session', stop: { number: 4 } })
  })

  it('[road-stops 7] part way through a stop (some lessons done), Start goes straight to the lesson', () => {
    expect(planOf(signedIn('start'), { 1: 4, 2: 4, 3: 2 })).toEqual({ kind: 'straight', go: 'guest' })
    expect(planOf(signedIn('start'), { 1: 1 })).toEqual({ kind: 'straight', go: 'guest' })
  })

  it('[road-stops 7] a session already open, or a review, goes straight on', () => {
    expect(planOf(signedIn('continue'), { 1: 4, 2: 4, 3: 2 })).toEqual({ kind: 'straight', go: 'session' })
    expect(planOf(signedIn('continue'))).toEqual({ kind: 'straight', go: 'session' })
    expect(planOf(signedIn('review', { reviewCount: 4 }), { 1: 4 })).toEqual({
      kind: 'straight',
      go: 'guest',
    })
  })

  it('[road-stops 2] nothing ready: no Start, only the one plain line', () => {
    const allDone = homeView(roadFixture(), signedIn('all_done'), null).card
    expect(startPlan(allDone)).toEqual({ kind: 'none' })
    expect(startNote(allDone)).toBe(ALL_DONE)
    const notReady = homeView(roadFixture(), signedIn('not_ready'), null).card
    expect(startPlan(notReady)).toEqual({ kind: 'none' })
    expect(startNote(notReady)).toBe(NOT_READY)
    const tomorrow = homeView(
      roadFixture({ 1: 4 }),
      signedIn('all_done', { nextReview: { today: '2026-11-01', day: '2026-11-02' } }),
      null,
    ).card
    expect(startPlan(tomorrow)).toEqual({ kind: 'none' })
    expect(startNote(tomorrow)).toBe('Your next review is tomorrow.')
  })

  it('[road-stops 2] a message above Start only when the road has one to give', () => {
    const ended = homeView(roadFixture(), todayInfoFrom({ signedIn: false, ended: true }), null).card
    expect(startNote(ended)).toBe(ENDED)
    expect(startNote(homeView(roadFixture(), visitor, null).card)).toBeUndefined()
    expect(
      startNote(homeView(roadFixture({ 1: 4, 2: 4, 3: 2 }), signedIn('start'), null).card),
    ).toBeUndefined()
  })
})
