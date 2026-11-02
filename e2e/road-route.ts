import type { BrowserContext, Page } from '@playwright/test'
import { roadFixture } from '../src/road/road-fixture.ts'

// Job 20-a1-road is merged: the Worker answers GET /api/road, from the database
// (public.road() for a learner, public.road_for_visitors() for a visitor). Where
// a real Worker runs, the browser tests read that real route: that is every run
// on GitHub (CI is set) and any run with PUHUSCRIBE_REAL_ROAD=1. Only a run with
// no Worker behind it (the mock based specs on a laptop with no Docker) answers
// the road from the fixture (src/road/road-fixture.ts, for tests and
// /design-reference only; a normal build holds none of it). PUHUSCRIBE_REAL_ROAD=0
// forces the fixture. The mock based redesign specs (e2e/road-mocks.ts) always use
// the fixture, because they need to set how many lessons are done.

const setting = process.env.PUHUSCRIBE_REAL_ROAD
export const useRealRoad = setting === undefined ? Boolean(process.env.CI) : setting === '1'

export type Routable = Page | BrowserContext

/** Answers GET /api/road with the fixture stops, as the list the route returns. */
export async function installRoad(target: Routable, done: Record<number, number> = {}): Promise<void> {
  if (useRealRoad) return
  await target.route('**/api/road', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ stops: roadFixture(done) }),
    }),
  )
}

/** Answers GET /api/road with a failure, for the "No connection" screen. */
export async function breakRoad(target: Routable): Promise<void> {
  await target.route('**/api/road', (route) => route.abort('failed'))
}
