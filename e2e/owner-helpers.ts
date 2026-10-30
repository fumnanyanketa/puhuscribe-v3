import { existsSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { expect, type Browser, type BrowserContext, type Page, type TestInfo } from '@playwright/test'
import { importJWK, SignJWT, type JWK } from 'jose'
import { addEmail, signIn, startGuest, testAddress } from './account-helpers.ts'
import { sql } from './db.ts'

// Shared steps for the owner page browser tests (factory/jobs/14-analytics).
//
// The local Worker treats 127.0.0.1 (or [::1]) as the owner host and checks Access
// tokens against a key made for this run by scripts/ci/test-owner-access.ts
// (the pull request browser job runs it before the build). The app itself
// stays on localhost, so the two hosts keep separate cookies, as the live
// hostnames will. Nothing here prints a code, a cookie or a token.

const ACCESS_FILE = join('.wrangler', 'test-owner-access', 'access.json')

interface LocalAccess {
  host: string
  teamDomain: string
  aud: string
  privateJwk: JWK & { kid?: string }
}

/** Why the owner page tests cannot run here, or null when they can. */
export function ownerHostMissing(): string | null {
  if (process.env.PLAYWRIGHT_BASE_URL) return 'The owner host exists only on the local test server.'
  if (!existsSync(ACCESS_FILE))
    return 'No local owner page settings: run node scripts/ci/test-owner-access.ts >> .env.local before the build.'
  return null
}

function access(): LocalAccess {
  return JSON.parse(readFileSync(ACCESS_FILE, 'utf8')) as LocalAccess
}

/** The owner host's address, on the same port as the app's. */
export function ownerOrigin(appBaseURL: string | undefined): string {
  const app = new URL(appBaseURL ?? 'https://localhost:4173')
  return `${app.protocol}//${access().host}:${app.port}`
}

/** A token as Cloudflare Access would add it, signed by this run's local key. */
export async function accessToken(): Promise<string> {
  const { teamDomain, aud, privateJwk } = access()
  const key = await importJWK(privateJwk, 'RS256')
  return new SignJWT({ type: 'app' })
    .setProtectedHeader({ alg: 'RS256', kid: privateJwk.kid ?? '' })
    .setIssuer(teamDomain)
    .setAudience(aud)
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key)
}

function phoneOptions(testInfo: TestInfo) {
  const use = testInfo.project.use
  return {
    ignoreHTTPSErrors: true,
    viewport: use.viewport ?? { width: 375, height: 812 },
    hasTouch: use.hasTouch,
    isMobile: use.isMobile,
    userAgent: use.userAgent,
    deviceScaleFactor: use.deviceScaleFactor,
  }
}

/** A browser on the owner host that has passed Cloudflare Access (lock one). */
export async function ownerBrowser(
  browser: Browser,
  testInfo: TestInfo,
  appBaseURL: string | undefined,
): Promise<BrowserContext> {
  return browser.newContext({
    ...phoneOptions(testInfo),
    baseURL: ownerOrigin(appBaseURL),
    extraHTTPHeaders: { 'Cf-Access-Jwt-Assertion': await accessToken() },
  })
}

/** A second browser on the app host, sharing no cookies with any other. */
export async function appBrowser(
  browser: Browser,
  testInfo: TestInfo,
  appBaseURL: string | undefined,
  extraHTTPHeaders: Record<string, string> = {},
): Promise<BrowserContext> {
  return browser.newContext({ ...phoneOptions(testInfo), baseURL: appBaseURL, extraHTTPHeaders })
}

/**
 * An email account made through the app (Start, then "Add your email" with
 * the code from Mailpit), then signed in on the owner host. Returns the owner
 * host page, signed in, and the account's id. The account is NOT yet on the
 * owner list: call addToOwnerList.
 */
export async function ownerAccount(
  browser: Browser,
  testInfo: TestInfo,
  appBaseURL: string | undefined,
): Promise<{ page: Page; userId: string; context: BrowserContext }> {
  const address = testAddress('owner', testInfo)
  const app = await appBrowser(browser, testInfo, appBaseURL)
  const appPage = await app.newPage()
  const userId = await startGuest(appPage)
  await addEmail(appPage, address)
  await expect(appPage.getByRole('status')).toHaveText(
    'Your email is added. Your progress is saved to your account.',
  )
  await app.close()
  const context = await ownerBrowser(browser, testInfo, appBaseURL)
  const page = await context.newPage()
  await signIn(page, address)
  return { page, userId, context }
}

/** Puts an account on the owner list, as the README's SQL line does (throwaway database only). */
export function addToOwnerList(userId: string): void {
  sql(`insert into private.owners (user_id) values (:'uid') on conflict do nothing`, { uid: userId })
}

export interface Dashboard {
  visits_by_day: { day: string; visits: number; fi: number }[]
  visits_by_country: { country: string; visits: number }[]
  active_learners: number
  day7_retention: { retained: number; cohort: number; percent: number | null }
  median_session_minutes: { minutes: number | null; used: number; left_out: number }
  speak_back: { count: number; base: number; percent: number | null }
  ai_cost_usd: { total: number; per_active_learner: number | null }
  feedback: { created_at: string; screen: string; account: string; message: string }[]
  crashes: {
    name: string
    message: string
    count: number
    path: string
    browser: string
    app_version: string
    frames: unknown[]
  }[]
}

/** The owner's numbers as the owner page receives them. */
export async function dashboard(page: Page): Promise<Dashboard> {
  const res = await page.request.get('/api/owner/dashboard')
  expect(res.status()).toBe(200)
  return (await res.json()) as Dashboard
}

/** Waits until the owner page has drawn its numbers. */
export async function openOwnerPage(page: Page): Promise<void> {
  await page.goto('/owner')
  await expect(page.getByRole('heading', { level: 1, name: 'Owner page' })).toBeVisible()
  await expect(page.getByRole('heading', { level: 2, name: 'Crashes' })).toBeVisible()
}
