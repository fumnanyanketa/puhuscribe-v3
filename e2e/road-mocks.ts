import type { Page, Route } from '@playwright/test'
import { roadFixture } from '../src/road/road-fixture.ts'
import { markIntroSeen } from './intro-seen.ts'

// Answers for the home screen's three reads, so the road can be tested in every
// state without a database: GET /api/road (the fixture, until job 20-a1-road is
// merged), GET /api/today and GET /api/me. Nothing here reaches a real server.

export interface HomeMocks {
  /** False to leave Aleksi's intro for the test itself; by default the tab's visit is under way, so the intro does not show (e2e/intro-seen.ts). */
  met?: boolean
  /** The body of GET /api/today. Default: no account on this device. */
  today?: Record<string, unknown>
  /** The body of GET /api/me, or a status number for a failure. Default: a guest. */
  me?: Record<string, unknown> | number
  /** Lessons done per stop number. */
  done?: Record<number, number>
  /** Holds the road back this long, to see the loading screen. */
  roadDelayMs?: number
  /** Makes the road fail with this status, or the network fail with 0. */
  roadFails?: number
}

export interface HomeCalls {
  road: number
  today: number
  me: number
  guest: number
}

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

export async function mockHome(page: Page, mocks: HomeMocks = {}): Promise<HomeCalls> {
  const calls: HomeCalls = { road: 0, today: 0, me: 0, guest: 0 }
  // The visit is under way, so the intro does not show, unless the test says not (fast route intro-rule).
  if (mocks.met !== false) await markIntroSeen(page)
  await page.route('**/api/road', async (route) => {
    calls.road += 1
    if (mocks.roadDelayMs) await new Promise((resolve) => setTimeout(resolve, mocks.roadDelayMs))
    if (mocks.roadFails === 0) return route.abort('failed')
    if (mocks.roadFails) return json(route, { error: 'x' }, mocks.roadFails)
    return json(route, { stops: roadFixture(mocks.done ?? {}) })
  })
  await page.route('**/api/today', (route) => {
    calls.today += 1
    return json(route, mocks.today ?? { signedIn: false, ended: false })
  })
  await page.route('**/api/me', (route) => {
    calls.me += 1
    const me = mocks.me ?? { kind: 'guest' }
    return typeof me === 'number' ? json(route, { error: 'x' }, me) : json(route, me)
  })
  await page.route('**/api/guest', (route) => {
    calls.guest += 1
    return json(route, { guest: 'created' }, 201)
  })
  return calls
}
