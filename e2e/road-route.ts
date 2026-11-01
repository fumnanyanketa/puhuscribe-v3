import type { BrowserContext, Page } from '@playwright/test'
import { roadFixture } from '../src/road/road-fixture.ts'

// Until job 20-a1-road is merged, the Worker has no GET /api/road, so every
// browser test answers it from the road fixture (src/road/road-fixture.ts, for
// tests and /design-reference only; a normal build holds none of it). Set
// PUHUSCRIBE_REAL_ROAD=1 once job 20's route exists and the tests should read
// the real one. A test that needs a different road passes its own stops.

export const useRealRoad = process.env.PUHUSCRIBE_REAL_ROAD === '1'

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
