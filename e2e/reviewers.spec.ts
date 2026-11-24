import { expect, test, type Page, type Request } from '@playwright/test'
import { TURNSTILE_SCRIPT } from './road-route.ts'

// Labels [reviewers N] are the "Done when" statement numbers from
// factory/jobs/reviewers/spec.md that each test protects.
// The public reviewer sign up page at /reviewers: drawn by the app shell with
// no account and no cookie, the Turnstile round trip, one sign up per tap, and
// the error lines. POST /api/reviewers and Turnstile's script are answered by
// the test, so no row is written anywhere; the Worker's own rules are
// worker/reviewers.test.ts and supabase/tests/database/reviewers.test.sql.
//
// REVIEWERS_EVIDENCE_DIR set: the phone and desktop pictures are saved there
// (factory/jobs/reviewers/evidence/).

const FAKE_TURNSTILE = `window.turnstile = {
  render: function (el, o) { setTimeout(function () { o.callback('XXXX.DUMMY.TOKEN.XXXX') }, 0); return 'w' },
  remove: function () {},
};`

const evidence = process.env.REVIEWERS_EVIDENCE_DIR

async function fakeTurnstile(page: Page) {
  await page.route(`${TURNSTILE_SCRIPT}*`, (route) =>
    route.fulfill({ status: 200, contentType: 'text/javascript', body: FAKE_TURNSTILE }),
  )
}

/**
 * Answers POST /api/reviewers as the Worker does: check_needed first, then `final` for the sent token.
 * Given `hold`, every answer waits for it, so a test can tap again while the first send is open.
 */
async function fakeApi(page: Page, final: { status: number; body: unknown }, hold?: Promise<void>) {
  const bodies: string[] = []
  await page.route('**/api/reviewers', async (route) => {
    bodies.push(route.request().postData() ?? '')
    if (hold) await hold
    if (!(route.request().postData() ?? '').includes('turnstileToken')) {
      return route.fulfill({
        status: 403,
        contentType: 'application/json',
        body: JSON.stringify({ error: 'check_needed', siteKey: '1x00000000000000000000AA' }),
      })
    }
    return route.fulfill({
      status: final.status,
      contentType: 'application/json',
      body: JSON.stringify(final.body),
    })
  })
  return bodies
}

async function fill(page: Page, form: { name?: string; email?: string; thanks?: string }) {
  if (form.name !== undefined) await page.getByLabel('Your name').fill(form.name)
  if (form.email !== undefined) await page.getByLabel('Your email').fill(form.email)
  if (form.thanks !== undefined)
    await page.getByLabel('Name for the thank-you in my next video (optional)').fill(form.thanks)
}

test.describe('the reviewer sign up page', () => {
  test('[reviewers 1] shows the page at 375 x 812 with no account, no cookie and no API call before Send', async ({
    page,
    context,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    const apiCalls: string[] = []
    page.on('request', (request: Request) => {
      if (new URL(request.url()).pathname.startsWith('/api/')) apiCalls.push(request.url())
    })
    await page.goto('/reviewers')
    await expect(
      page.getByRole('heading', { level: 1, name: 'Help check the Finnish in Aleksi' }),
    ).toBeVisible()
    expect(new URL(page.url()).pathname).toBe('/reviewers')
    await expect(page.getByLabel('Your name')).toBeVisible()
    await expect(page.getByLabel('Your email')).toBeVisible()
    await expect(page.getByLabel('Name for the thank-you in my next video (optional)')).toBeVisible()
    await expect(page.getByText("Leave it empty if you'd rather not be named.")).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign up' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Read the privacy notice' })).toHaveAttribute(
      'href',
      '/learn/privacy',
    )
    expect(await page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')).toBe(true)
    expect(await context.cookies()).toEqual([])
    expect(await page.evaluate('document.cookie')).toBe('')
    expect(apiCalls).toEqual([])
    if (evidence) {
      await page.screenshot({ path: `${evidence}/1-reviewers-375x812.png` })
      await page.evaluate('window.scrollTo(0, document.documentElement.scrollHeight)')
      await page.screenshot({ path: `${evidence}/1-reviewers-375x812-bottom.png` })
    }
  })

  test('[reviewers 1] shows the page on a desktop', async ({ page, context }) => {
    await page.setViewportSize({ width: 1440, height: 900 })
    await page.goto('/reviewers')
    await expect(
      page.getByRole('heading', { level: 1, name: 'Help check the Finnish in Aleksi' }),
    ).toBeVisible()
    expect(await page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')).toBe(true)
    expect(await context.cookies()).toEqual([])
    if (evidence)
      await page.screenshot({ path: `${evidence}/1-reviewers-desktop-1440x900.png`, fullPage: true })
  })

  test('[reviewers 2] [reviewers 8] Send runs the check once, ignores taps while sending, then thanks', async ({
    page,
    context,
  }) => {
    await fakeTurnstile(page)
    // The answers wait until the extra taps are done, so they all land while the first send is open.
    let release: () => void = () => undefined
    const hold = new Promise<void>((resolve) => {
      release = resolve
    })
    const bodies = await fakeApi(page, { status: 201, body: { sent: true } }, hold)
    await page.goto('/reviewers')
    await fill(page, { name: 'Test Reviewer', email: 'reviewer@example.test', thanks: 'Test R' })
    // The button is renamed for screen readers while busy, so it is found by its kind here.
    const button = page.locator('button[type="submit"]')
    await button.click()
    await button.click({ force: true, timeout: 2000 })
    await page.getByLabel('Your name').press('Enter')
    release()
    await expect(page.getByText("Thank you. I'll email you the phrases soon.")).toBeVisible()
    expect(bodies).toHaveLength(2)
    expect(bodies[0]).not.toContain('turnstileToken')
    expect(JSON.parse(bodies[1] ?? '{}')).toEqual({
      name: 'Test Reviewer',
      email: 'reviewer@example.test',
      thanksName: 'Test R',
      turnstileToken: 'XXXX.DUMMY.TOKEN.XXXX',
    })
    await expect(page.getByRole('button', { name: 'Sign up' })).toHaveCount(0)
    expect(await context.cookies()).toEqual([])
  })

  test('[reviewers 3] [reviewers 8] an empty name or a wrong email is caught before anything is sent', async ({
    page,
  }) => {
    const bodies = await fakeApi(page, { status: 201, body: { sent: true } })
    await page.goto('/reviewers')
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(page.getByText('Please write your name, up to 100 characters.')).toBeVisible()
    await expect(page.getByLabel('Your name')).toBeFocused()
    await fill(page, { name: 'Test', email: 'not-an-email' })
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(page.getByText('Please check your email address.')).toBeVisible()
    await expect(page.getByLabel('Your email')).toBeFocused()
    expect(bodies).toEqual([])
  })

  test('[reviewers 8] the error line says only what happened', async ({ page }) => {
    await fakeTurnstile(page)
    await fakeApi(page, { status: 503, body: { error: 'not_available' } })
    await page.goto('/reviewers')
    await fill(page, { name: 'Test', email: 'reviewer@example.test' })
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(page.getByText('Your sign-up was not saved. Please try again in a moment.')).toBeVisible()
    await page.unroute('**/api/reviewers')
    await page.route('**/api/reviewers', (route) => route.abort())
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(
      page.getByText('Your sign-up was not sent. Check your internet connection, then try again.'),
    ).toBeVisible()
    await page.unroute('**/api/reviewers')
    await page.route('**/api/reviewers', (route) =>
      route.fulfill({ status: 429, contentType: 'application/json', body: '{"error":"limit"}' }),
    )
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(
      page.getByText('The sign-up limit for today is reached. Please try again tomorrow.'),
    ).toBeVisible()
  })
})
