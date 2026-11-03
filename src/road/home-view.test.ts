import { describe, expect, it } from 'vitest'
import { ALL_DONE, ENDED, NOT_READY } from '../screens/road-copy.ts'
import { SIGNED_OUT_EMAIL } from '../lib/account-notice.ts'
import { ROAD_DAY_ONE, ROAD_MID, roadFixture } from './road-fixture.ts'
import { homeView, todayInfoFrom } from './home-view.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md.

const signedIn = (today: string, extra: Record<string, unknown> = {}) =>
  todayInfoFrom({ signedIn: true, today, ...extra })
const visitor = todayInfoFrom({ signedIn: false, ended: false })

describe('reading what today holds', () => {
  it('[redesign 15] reads GET /api/today, and takes anything unclear as no account on this device', () => {
    expect(visitor).toEqual({ signedIn: false, ended: false, email: false })
    expect(todayInfoFrom(null)).toEqual(visitor)
    expect(todayInfoFrom({ signedIn: true, today: 'nonsense' })).toEqual(visitor)
    expect(todayInfoFrom({ signedIn: false, ended: true, account: 'email' })).toEqual({
      signedIn: false,
      ended: true,
      email: true,
    })
    expect(signedIn('review', { reviewCount: 14 }).reviewCount).toBe(14)
    expect(signedIn('review', { reviewCount: -3 }).reviewCount).toBeUndefined()
    expect(signedIn('review', { reviewCount: 2.5 }).reviewCount).toBeUndefined()
    expect(signedIn('all_done', { nextReview: { today: '2026-11-01', day: '2026-11-02' } }).nextReview).toBe(
      'Your next review is tomorrow.',
    )
  })
})

describe('the card by state', () => {
  it('[redesign 15] day one: stop 1, Start and Sign in, with no account on this device', () => {
    const view = homeView(ROAD_DAY_ONE, visitor, null)
    expect(view.card).toEqual({ kind: 'day-one', stop: ROAD_DAY_ONE[0] })
    expect(view.intro).toBe(true)
    expect(view.evening).toBe(false)
    expect(view.markerAt).toBe(0)
    expect(view.signs[0]?.state).toBe('current')
  })

  it('[redesign 15] shows the ended message in the same card, in the existing words', () => {
    expect(homeView(ROAD_DAY_ONE, todayInfoFrom({ signedIn: false, ended: true }), null).card).toMatchObject({
      message: ENDED,
    })
    expect(
      homeView(ROAD_DAY_ONE, todayInfoFrom({ signedIn: false, ended: true, account: 'email' }), null).card,
    ).toMatchObject({ message: SIGNED_OUT_EMAIL })
    expect(homeView(ROAD_DAY_ONE, visitor, 'Your account and all its data are deleted.').card).toMatchObject({
      message: 'Your account and all its data are deleted.',
    })
  })

  it('[redesign 15] [intro animation] start and continue show the stop and its lesson, and the animation plays for them too (owner, 3 November 2026)', () => {
    const start = homeView(ROAD_MID, signedIn('start'), null)
    expect(start.card).toEqual({ kind: 'lesson', stop: ROAD_MID[2], action: 'Start' })
    expect(start.intro).toBe(true)
    expect(homeView(ROAD_MID, signedIn('continue'), null).card).toMatchObject({ action: 'Continue' })
  })

  it('[redesign 15] review only: the count, and the stop stays current', () => {
    const view = homeView(ROAD_MID, signedIn('review', { reviewCount: 14 }), null)
    expect(view.card).toEqual({ kind: 'review', count: 14 })
    expect(view.signs.find((sign) => sign.state === 'current')?.stop.number).toBe(3)
    expect(homeView(ROAD_MID, signedIn('review'), null).card).toEqual({ kind: 'review', count: null })
  })

  it('[redesign 15] done for today: the evening sky, with the next review sentence and no button', () => {
    const view = homeView(
      ROAD_MID,
      signedIn('all_done', { nextReview: { today: '2026-11-01', day: '2026-11-02' } }),
      null,
    )
    expect(view.card).toEqual({ kind: 'done', line: 'Your next review is tomorrow.' })
    expect(view.evening).toBe(true)
  })

  it('[redesign 15] the end of the road and "not ready" use the evening card and the existing sentences', () => {
    expect(homeView(ROAD_MID, signedIn('all_done'), null)).toMatchObject({
      card: { kind: 'message', text: ALL_DONE },
      evening: true,
    })
    expect(homeView(ROAD_MID, signedIn('not_ready'), null)).toMatchObject({
      card: { kind: 'message', text: NOT_READY },
      evening: true,
    })
  })

  it('[redesign 15] stop finished: the stop done, its sentence, the next stop, and the next sign lit', () => {
    const stops = roadFixture({ 1: 4, 2: 4, 3: 4 })
    const view = homeView(stops, signedIn('start'), null)
    expect(view.card).toMatchObject({ kind: 'stop-finished', done: { number: 3 }, next: { number: 4 } })
    expect(view.signs.map((sign) => sign.state)).toEqual(['done', 'done', 'done', 'next', 'later'])
    expect(view.signs[view.markerAt]?.stop.number).toBe(3)
    // Not on the first stop, and not while a lesson is open.
    expect(homeView(stops, signedIn('continue'), null).card).toMatchObject({ kind: 'lesson' })
  })

  it('[redesign 14] the progress bar has 12 pieces and the line reaches the marker', () => {
    const view = homeView(roadFixture({ 1: 4, 2: 4, 3: 4, 4: 4, 5: 4, 6: 4 }), signedIn('start'), null)
    expect(view.pieces).toHaveLength(12)
    expect(view.pieces.slice(0, 3)).toEqual([true, true, false])
    expect(view.travelledTo).toBeGreaterThan(0)
  })
})
