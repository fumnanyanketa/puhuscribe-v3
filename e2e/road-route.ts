import type { BrowserContext, Page } from '@playwright/test'
import { roadFixture } from '../src/road/road-fixture.ts'
import { markIntroSeen } from './intro-seen.ts'

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

/**
 * Cloudflare Turnstile's script address (src/lib/human-check.ts). Since the turnstile job (owner's choice
 * of 3 November 2026) a new guest's Start loads it once the Worker answers check_needed.
 */
export const TURNSTILE_SCRIPT = 'https://challenges.cloudflare.com/turnstile/v0/api.js'
/** The host of that script: the one outside address a new guest's Start may reach. */
export const TURNSTILE_HOST = 'challenges.cloudflare.com'

// A stand-in for the script: it renders nothing and hands the widget Cloudflare's published dummy token at
// once, as the test site key would after its quiet check. The Worker still checks the token with Cloudflare's
// siteverify and the test secret (worker/providers/human-check.ts), which always passes. The request to the
// script's address is still made by the page, so tests that list the page's requests see it.
const FAKE_TURNSTILE = `window.turnstile = {
  render: function (el, options) { setTimeout(function () { options.callback('XXXX.DUMMY.TOKEN.XXXX') }, 0); return 'test-widget' },
  remove: function () {},
};`

/**
 * Answers GET /api/road with the fixture stops, as the list the route returns. Every browser context
 * of the tests is set up here, so it also presses "Nice to meet you" when Aleksi's intro appears
 * (e2e/intro-seen.ts) unless `introSeen` is false, and answers Turnstile's script with the stand-in above.
 */
export async function installRoad(
  target: Routable,
  done: Record<number, number> = {},
  { introSeen = true }: { introSeen?: boolean } = {},
): Promise<void> {
  if (introSeen) await markIntroSeen(target)
  await target.route(`${TURNSTILE_SCRIPT}*`, (route) =>
    route.fulfill({ status: 200, contentType: 'text/javascript', body: FAKE_TURNSTILE }),
  )
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
