import { expect, test } from '@playwright/test'
import { recordApiTimings } from './api-timing.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/1-stack/spec.md that each test protects. Job 2-smoke replaced
// the page, and job 8-first-session replaced it again with the front door
// (statement 21), so the page tests now look for the front door's heading and
// its GET /api/today call; what each test proves is unchanged.
//
// The same tests run against the built app locally and in the GitHub check,
// and against the private preview link (with the evaluator's service token).
// Locally they need Supabase settings in .env.local. On a pull request the
// check points the app at a throwaway local Supabase; after merge, at the test
// project (job 6-pr-local-db).

const onPreview = Boolean(process.env.PLAYWRIGHT_BASE_URL?.includes('.workers.dev'))

test.beforeEach(({ page }, testInfo) => {
  recordApiTimings(page, testInfo)
})

test('[2] [10] the page loads with no console errors and reaches the Worker', async ({ page }) => {
  const problems: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') problems.push(message.text())
  })
  page.on('pageerror', (error) => problems.push(error.message))

  const today = page.waitForResponse((res) => new URL(res.url()).pathname === '/api/today')
  await page.goto('/')
  await expect(page.getByRole('heading', { level: 1, name: "Today's session" })).toBeVisible()
  // The front door asks the Worker what to show and gets its answer.
  expect((await today).status()).toBe(200)
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  expect(problems).toEqual([])
})

test('[2] [10] /api/health answers with JSON from the Worker', async ({ request }) => {
  const res = await request.get('/api/health')
  expect(res.status()).toBe(200)
  expect(res.headers()['content-type']).toMatch(/^application\/json/)
  expect(await res.json()).toMatchObject({ status: 'ok', service: 'puhuscribe' })
})

test('[13] /api/health reports the Supabase test project as reachable', async ({ request }) => {
  const res = await request.get('/api/health')
  expect(await res.json()).toMatchObject({ database: 'reachable' })
})

test('[8] /api/health sends no cross site header, even when another site asks', async ({ request }) => {
  const res = await request.get('/api/health', { headers: { Origin: 'https://evil.example' } })
  expect(res.headers()['access-control-allow-origin']).toBeUndefined()
})

test('[8] the page calls the API on its own address', async ({ page }) => {
  const todayCall = page.waitForRequest((req) => new URL(req.url()).pathname === '/api/today')
  await page.goto('/')
  const call = await todayCall
  expect(new URL(call.url()).origin).toBe(new URL(page.url()).origin)
})

test('[2] an unknown page still loads the app (single page app routing)', async ({ page }) => {
  await page.goto('/some/deep/link')
  await expect(page.getByRole('heading', { level: 1, name: "Today's session" })).toBeVisible()
})

test.describe('private preview link', { tag: '@preview' }, () => {
  test.skip(!onPreview, 'Only runs against a preview link')

  // In Playwright Test, new contexts inherit the config's extraHTTPHeaders,
  // which hold the evaluator's service token. Clearing them here is what makes
  // these contexts anonymous, like a private browser window. Each test also
  // checks that no service token header went out.

  test('[12] a visitor without sign in gets the Cloudflare Access sign in, not the app', async ({
    browser,
    baseURL,
  }) => {
    const context = await browser.newContext({ extraHTTPHeaders: {} })
    const page = await context.newPage()
    const sentServiceToken: string[] = []
    page.on('request', (request) => {
      if ('cf-access-client-id' in request.headers()) sentServiceToken.push(request.url())
    })
    await page.goto(baseURL ?? '/')
    expect(sentServiceToken).toEqual([])
    expect(new URL(page.url()).hostname).toMatch(/\.cloudflareaccess\.com$/)
    // Match the app's own text exactly, so nothing on the Access page can match by accident.
    await expect(page.getByRole('heading', { level: 1, name: "Today's session", exact: true })).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toHaveCount(0)
    await context.close()
  })

  test('[12] the API is closed too without sign in', async ({ playwright, baseURL }) => {
    const anonymous = await playwright.request.newContext({ extraHTTPHeaders: {}, maxRedirects: 0 })
    const res = await anonymous.get(`${baseURL ?? ''}/api/health`)
    expect([302, 401, 403]).toContain(res.status())
    expect(await res.text()).not.toContain('"status":"ok"')
    await anonymous.dispose()
  })
})
