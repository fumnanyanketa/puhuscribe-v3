import { expect, test } from '@playwright/test'
import { recordApiTimings } from './api-timing.ts'
import { isGuestPost, recordRequests, scrollsSideways } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md ([session N]), and, for protections
// moved here from the retired "Hei!" page tests (statement 21), from
// factory/jobs/2-smoke/spec.md ([smoke N]) and
// factory/jobs/5-design-system/spec.md ([design N]), labels kept.
//
// These need no seed rows and make no account, so they also run against the
// test project after merge.

test.beforeEach(({ page }, testInfo) => {
  recordApiTimings(page, testInfo)
})

test('[session 1] shows the wordmark, the heading, one sentence, Start and the guest line, and loading it makes no account', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/')
  await expect(page.getByRole('img', { name: 'PuhuScribe' })).toBeVisible()
  await expect(page.getByRole('heading', { level: 1, name: "Today's session" })).toBeVisible()
  await expect(
    page.getByText(
      'A session is one short Finnish dialogue that you hear line by line and then check you understand.',
    ),
  ).toBeVisible()
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await expect(
    page.getByText(
      'Starting creates a guest account on this device so your progress is saved. PuhuScribe is for adults, 18 and over.',
      { exact: true },
    ),
  ).toBeVisible()
  await page.waitForLoadState('networkidle')
  await page.reload()
  await page.waitForLoadState('networkidle')
  expect(requests.filter(isGuestPost)).toHaveLength(0)
  await expect(page).toHaveTitle('PuhuScribe')
})

test('[smoke 2] [smoke 6] [session 3] every request the front door makes goes to its own address, never to Supabase', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/')
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await page.waitForLoadState('networkidle')
  const origin = new URL(page.url()).origin
  expect(requests.length).toBeGreaterThan(0)
  for (const request of requests) {
    expect(new URL(request.url()).origin, request.url()).toBe(origin)
    expect(new URL(request.url()).hostname, request.url()).not.toMatch(/supabase\.co$/)
  }
  expect(await page.evaluate<string>('document.cookie')).toBe('')
})

// Replaces "[smoke 1] [design 19] loads only its own stylesheet and font
// files ... no images, icons or media". The front door now has component
// styles and the wordmark (an inline SVG drawing, not a file), so the "no
// class, no svg" part, which described the unstyled Hei! page, is gone; the
// rest still holds.
test('[smoke 1] [design 19] loads only its own stylesheet and font files, from its own address, and no image or media files', async ({
  page,
}) => {
  const loaded: { type: string; url: string }[] = []
  page.on('request', (request) => {
    if (!request.url().startsWith('data:')) loaded.push({ type: request.resourceType(), url: request.url() })
  })
  await page.goto('/')
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await page.evaluate('document.fonts.ready')
  await page.waitForLoadState('networkidle')
  const origin = new URL(page.url()).origin
  const styling = loaded.filter(({ type }) => ['stylesheet', 'font'].includes(type))
  expect(styling.filter(({ type }) => type === 'stylesheet').length).toBeGreaterThan(0)
  for (const { url } of styling) expect(new URL(url).origin, url).toBe(origin)
  expect(loaded.filter(({ type }) => ['image', 'media'].includes(type))).toEqual([])
  await expect(page.locator('img, picture, video, canvas, object, embed')).toHaveCount(0)
  await expect(page.locator('link[rel~="icon"]:not([href="data:,"])')).toHaveCount(0)
})

test('[session 22] the front door fits 320 px and 200 percent text without sideways scrolling', async ({
  page,
}) => {
  await page.goto('/')
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await page.setViewportSize({ width: 320, height: 640 })
  expect(await scrollsSideways(page)).toBe(false)
  await page.setViewportSize({ width: 375, height: 812 })
  await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
  expect(await scrollsSideways(page)).toBe(false)
  const start = await page.getByRole('button', { name: 'Start', exact: true }).boundingBox()
  expect(start?.height ?? 0).toBeGreaterThanOrEqual(44)
})

test('[session 6] [session 18] /session without a sign in goes back to the front door and makes nothing', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/session')
  await page.waitForURL((url) => url.pathname === '/')
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  expect(requests.filter(isGuestPost)).toHaveLength(0)
})

test.describe('the API from outside the page', () => {
  test('[session 21] unknown /api paths and the retired /api/visits answer 404', async ({ request }) => {
    for (const path of ['/api/visits', '/api/nothing-here', '/api/sessions/today/extra']) {
      const res = await request.post(path, { headers: { 'content-type': 'application/json' }, data: {} })
      expect(res.status(), path).toBe(404)
    }
  })

  test('[session 5] GET routes change nothing and the guest route refuses GET', async ({ request }) => {
    const res = await request.get('/api/guest')
    expect(res.status()).toBe(405)
    expect(res.headers().allow).toBe('POST')
    expect(res.headers()['set-cookie']).toBeUndefined()
  })

  test('[session 5] another site cannot start a guest account', async ({ request }) => {
    const res = await request.post('/api/guest', {
      headers: { 'content-type': 'application/json', origin: 'https://evil.example' },
      data: {},
    })
    expect(res.status()).toBe(403)
    expect(res.headers()['set-cookie']).toBeUndefined()
    expect(res.headers()['access-control-allow-origin']).toBeUndefined()
    const form = await request.post('/api/guest', { form: { a: '1' } })
    expect(form.status()).toBe(415)
    expect(form.headers()['set-cookie']).toBeUndefined()
  })
})

// Moved from the retired e2e/visits.spec.ts (statement 21), labels kept: the
// app's requests must work on browsers without AbortSignal.timeout (older iOS
// Safari, Android WebViews), and a request that never answers must end in the
// problem message after the page's own 10 second limit.
test.describe('older browsers', () => {
  test('[smoke 3] the front door still works on a browser without AbortSignal.timeout', async ({ page }) => {
    await page.addInitScript(
      'Object.defineProperty(AbortSignal, "timeout", { value: undefined, configurable: true })',
    )
    const today = page.waitForResponse((res) => new URL(res.url()).pathname === '/api/today')
    await page.goto('/')
    expect(await page.evaluate<string>('typeof AbortSignal.timeout')).toBe('undefined')
    expect((await today).status()).toBe(200)
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  })

  test('[smoke 3] without AbortSignal.timeout, a Start that gets no answer ends in the problem message after 10 seconds', async ({
    page,
  }) => {
    await page.addInitScript(
      'Object.defineProperty(AbortSignal, "timeout", { value: undefined, configurable: true })',
    )
    // The request is held and never answered.
    await page.route('**/api/guest', () => undefined)
    await page.clock.install()
    await page.goto('/')
    const start = page.getByRole('button', { name: 'Start', exact: true })
    await start.click()
    const status = page.getByRole('status')
    // While busy the button keeps its place and tells screen readers what is happening.
    const busy = page.getByRole('button', { name: 'Starting your session.' })
    await expect(busy).toHaveAttribute('aria-busy', 'true')
    await page.clock.runFor(9_000)
    await expect(busy).toHaveAttribute('aria-busy', 'true')
    await expect(status).toHaveText('')
    await page.clock.runFor(1_000)
    await expect(status).toHaveText(
      'Could not start your session. Check your internet connection, then try again.',
    )
    await expect(status).toHaveAttribute('data-tone', 'problem')
    await expect(start).not.toHaveAttribute('aria-busy', 'true')
  })
})

test.describe('private preview link', { tag: '@preview' }, () => {
  test.skip(!process.env.PLAYWRIGHT_BASE_URL?.includes('.workers.dev'), 'Only runs against a preview link')

  // Moved from e2e/visits.spec.ts ("[smoke 12] POST /api/visits is refused
  // without sign in and saves nothing"), now for the route that makes
  // accounts. Clearing the config's extraHTTPHeaders makes this context
  // anonymous; with a valid token Access would let the request through.
  test('[smoke 12] [session 5] POST /api/guest is refused without the Access sign in and makes nothing', async ({
    playwright,
    baseURL,
  }) => {
    const anonymous = await playwright.request.newContext({ extraHTTPHeaders: {}, maxRedirects: 0 })
    const res = await anonymous.post(`${baseURL ?? ''}/api/guest`, {
      headers: { 'content-type': 'application/json' },
      data: '{}',
    })
    expect([302, 401, 403]).toContain(res.status())
    expect(await res.text()).not.toContain('"guest"')
    expect(res.headers()['set-cookie'] ?? '').not.toContain('puhuscribe-auth')
    await anonymous.dispose()
  })
})
