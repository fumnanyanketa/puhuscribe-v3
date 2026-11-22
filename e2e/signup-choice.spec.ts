import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { mockHome, type HomeMocks } from './road-mocks.ts'
import { scrollsSideways } from './session-helpers.ts'

// Create an account or continue as a guest (fast route signup-choice, owner, 22 November 2026). Labels are
// the "Done when" statements of factory/jobs/signup-choice/spec.md. Every answer is mocked
// (e2e/road-mocks.ts), so no database is needed and no account is made. With PUHUSCRIBE_EVIDENCE=1 the
// screenshots go to factory/jobs/signup-choice/evidence/ (Chromium only).

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
const OUT = resolve('factory/jobs/signup-choice/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'

const GUEST_NOTE = 'Starting creates a guest account on this device so your progress is saved.'
// The owner's shorter words of 22 November 2026.
const SENDS_CODE = 'We’ll email you a 6 digit code.'
const TAKEN_WARNING = 'If this email already has an account, your guest progress on this phone is replaced.'

async function shot(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(500)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png` })
}

const create = (page: Page) => page.getByRole('button', { name: 'Create an account', exact: true })
const guest = (page: Page) => page.getByRole('button', { name: 'Continue as guest', exact: true })

/** Opens the road and Aleksi's stop screen for stop 1. */
async function openStopScreen(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, mocks)
  await page.goto('/learn')
  await page.getByRole('button', { name: 'Start', exact: true }).click({ timeout: 8000 })
  await expect(page.getByRole('heading', { level: 1, name: /^This is stop 1, / })).toBeVisible()
  return calls
}

/** Answers the add email routes: the code is sent, then accepted with this result. */
async function mockAddEmail(page: Page, result: 'added' | 'switched') {
  const sent: string[] = []
  await page.route('**/api/account/email', (route) => {
    sent.push(route.request().postData() ?? '')
    return route.fulfill({ status: 200, contentType: 'application/json', body: '{"sent":true}' })
  })
  await page.route('**/api/account/email/verify', (route) =>
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ result }) }),
  )
  return sent
}

async function typeEmailAndCode(page: Page) {
  await page.getByLabel('Email address').fill('alex@example.com')
  await page.getByRole('button', { name: 'Send code' }).click()
  await page.getByLabel('6 digit code').fill('123456')
  await page.getByRole('button', { name: 'Confirm' }).click()
}

test.describe('the stop screen for a visitor', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[signup-choice 1] [signup-choice 4] [signup-choice 9] two full width buttons, the account one mint on top, then the sign in line and the guest line, all on one screen', async ({
    page,
  }) => {
    const calls = await openStopScreen(page)
    await expect(create(page)).toBeVisible()
    await expect(guest(page)).toBeVisible()
    // No plain "Continue" for a visitor any more.
    await expect(page.getByRole('button', { name: 'Continue', exact: true })).toHaveCount(0)
    const top = await create(page).boundingBox()
    const below = await guest(page).boundingBox()
    expect(top && below).toBeTruthy()
    if (!top || !below) return
    expect(below.y).toBeGreaterThanOrEqual(top.y + top.height)
    // Both are the full width of the screen's column and equally tall.
    expect(Math.abs(top.width - below.width)).toBeLessThanOrEqual(1)
    expect(top.width).toBeGreaterThan(300)
    expect(Math.abs(top.height - below.height)).toBeLessThanOrEqual(1)
    // The account button is the mint pill, the guest button the white one.
    const colours = await page.evaluate<{ create: string; guest: string }>(`(() => {
      const [a, b] = ['Create an account', 'Continue as guest'].map((name) =>
        [...document.querySelectorAll('button')].find((el) => el.textContent.trim() === name))
      return { create: getComputedStyle(a).backgroundColor, guest: getComputedStyle(b).backgroundColor }
    })()`)
    expect(colours.create).toBe('rgb(30, 133, 111)')
    expect(colours.guest).toBe('rgb(255, 255, 255)')
    // The sign in line, then the guest line with the privacy link, under the buttons.
    const signIn = page.getByRole('link', { name: 'Sign in', exact: true })
    await expect(page.getByText('Already have an account?', { exact: true })).toBeVisible()
    await expect(signIn).toHaveAttribute('href', '/learn/sign-in')
    await expect(page.getByText(GUEST_NOTE, { exact: true })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Privacy notice' })).toHaveAttribute('href', '/learn/privacy')
    // The link's tap area reaches above its text, so the line of text is measured.
    const signInBox = await page.getByText('Already have an account?', { exact: true }).boundingBox()
    const privacyBox = await page.getByRole('link', { name: 'Privacy notice' }).boundingBox()
    expect(signInBox?.y ?? 0).toBeGreaterThan(below.y + below.height - 1)
    expect(privacyBox?.y ?? 0).toBeGreaterThan(signInBox?.y ?? Infinity)
    // At 375 x 812 everything fits without scrolling.
    for (const part of [
      create(page),
      guest(page),
      signIn,
      page.getByRole('link', { name: 'Privacy notice' }),
    ])
      await expect(part).toBeInViewport({ ratio: 1 })
    expect(
      await page.evaluate<boolean>('document.documentElement.scrollHeight <= window.innerHeight + 1'),
    ).toBe(true)
    // Nothing is made just by looking.
    expect(calls.guest).toBe(0)
    await page.evaluate('document.fonts.ready')
    const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
    expect(result.violations.map((v) => v.id)).toEqual([])
    await shot(page, '1-stop-screen-visitor-375x812')
  })

  test('[signup-choice 2] "Continue as guest" makes the guest, then opens the lesson', async ({ page }) => {
    const calls = await openStopScreen(page)
    await guest(page).click()
    await page.waitForURL('**/learn/session')
    expect(calls.guest).toBe(1)
  })

  test('[signup-choice 2] [signup-choice 3] both buttons run the same Turnstile check and send its token', async ({
    page,
  }) => {
    await mockHome(page)
    await page.route('https://challenges.cloudflare.com/turnstile/v0/api.js*', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'text/javascript',
        body: `window.turnstile = { render: function (el, o) { setTimeout(function () { o.callback('XXXX.DUMMY.TOKEN.XXXX') }, 0); return 'w' }, remove: function () {} };`,
      }),
    )
    const bodies: string[] = []
    await page.route('**/api/guest', async (route) => {
      bodies.push(route.request().postData() ?? '')
      if (bodies.length === 1)
        return route.fulfill({
          status: 403,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'check_needed', siteKey: '1x00000000000000000000AA' }),
        })
      return route.fulfill({ status: 201, contentType: 'application/json', body: '{"guest":"created"}' })
    })
    await page.goto('/learn')
    await page.getByRole('button', { name: 'Start', exact: true }).click({ timeout: 8000 })
    await create(page).click()
    await page.waitForURL('**/learn/account/email?then=lesson')
    expect(bodies).toHaveLength(2)
    expect(bodies[0]).not.toContain('turnstileToken')
    expect(bodies[1]).toContain('XXXX.DUMMY.TOKEN.XXXX')
  })

  test('[signup-choice 3] "Create an account" makes the guest, then opens "Create your account" in its first lesson mode', async ({
    page,
  }) => {
    const calls = await openStopScreen(page)
    await create(page).click()
    await page.waitForURL('**/learn/account/email?then=lesson')
    expect(calls.guest).toBe(1)
    await expect(page.getByRole('heading', { level: 1, name: 'Create your account' })).toBeVisible()
    await expect(page.getByLabel('Email address')).toBeFocused()
  })

  test('[signup-choice 3] when making the guest fails, "Create an account" shows the problem line and goes nowhere', async ({
    page,
  }) => {
    await openStopScreen(page)
    await page.route('**/api/guest', (route) =>
      route.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"not_available"}' }),
    )
    await create(page).click()
    await expect(page.getByRole('status')).toHaveText(
      'Could not start your session. Check your internet connection, then try again.',
    )
    await expect(page).toHaveURL(/\/learn$/)
    await expect(create(page)).not.toHaveAttribute('aria-busy', 'true')
    await expect(guest(page)).toBeVisible()
  })

  test('[signup-choice 9] at 320 px wide with text at 200 percent, nothing runs sideways and both buttons and links are reachable', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 640 })
    await openStopScreen(page)
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    await page.waitForTimeout(300)
    expect(await scrollsSideways(page)).toBe(false)
    for (const part of [
      create(page),
      guest(page),
      page.getByRole('link', { name: 'Sign in', exact: true }),
      page.getByRole('link', { name: 'Privacy notice' }),
    ]) {
      await part.scrollIntoViewIfNeeded()
      await expect(part).toBeInViewport()
    }
  })
})

test.describe('the stop screen for someone with an account', () => {
  test.use({ reducedMotion: 'reduce' })

  for (const [who, today] of [
    ['a guest', { signedIn: true, today: 'start', account: 'guest' }],
    ['an email account', { signedIn: true, today: 'start', account: 'email' }],
  ] as const) {
    test(`[signup-choice 5] ${who} keeps the one Continue, with no account buttons and no sign in line`, async ({
      page,
    }) => {
      await openStopScreen(page, {
        today,
        me: today.account === 'email' ? { kind: 'email', email: 'a@example.com' } : { kind: 'guest' },
      })
      await expect(page.getByRole('button', { name: 'Continue', exact: true })).toBeVisible()
      await expect(create(page)).toHaveCount(0)
      await expect(guest(page)).toHaveCount(0)
      await expect(page.getByText('Already have an account?')).toHaveCount(0)
      await expect(page.getByRole('link', { name: 'Sign in', exact: true })).toHaveCount(0)
    })
  }
})

test.describe('"Create your account" before a first lesson', () => {
  test('[signup-choice 6] the back arrow goes to the road, one short line, and no guest progress warning', async ({
    page,
  }) => {
    await mockHome(page)
    await page.goto('/learn/account/email?then=lesson')
    await expect(page.getByRole('heading', { level: 1, name: 'Create your account' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Back to the road' })).toHaveAttribute('href', '/learn')
    await expect(page.getByText(TAKEN_WARNING)).toHaveCount(0)
    await expect(page.getByText(SENDS_CODE, { exact: true })).toBeVisible()
    await expect(page.getByText(/progress .*deleted/)).toHaveCount(0)
    await shot(page, '6-create-account-before-lesson-375x812')
  })

  test('[signup-choice 7] a new address: "Your account is ready.", then Continue opens the lesson', async ({
    page,
  }) => {
    await mockHome(page)
    const sent = await mockAddEmail(page, 'added')
    await page.goto('/learn/account/email?then=lesson')
    await typeEmailAndCode(page)
    await expect(page.getByRole('status')).toHaveText('Your account is ready.')
    expect(sent).toEqual(['{"email":"alex@example.com"}'])
    await shot(page, '7-account-ready-375x812')
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
  })

  test('[signup-choice 7] an address that already had an account: "You are signed in to your account.", then the lesson', async ({
    page,
  }) => {
    await mockHome(page)
    await mockAddEmail(page, 'switched')
    await page.goto('/learn/account/email?then=lesson')
    await typeEmailAndCode(page)
    await expect(page.getByRole('status')).toHaveText('You are signed in to your account.')
    await expect(page.getByText(/deleted/)).toHaveCount(0)
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
  })

  for (const query of ['', '?then=https://example.com', '?then=Lesson', '?next=lesson']) {
    test(`[signup-choice 8] "${query || 'no query'}" keeps the account page's screen: account back link, the warning, and the road after`, async ({
      page,
    }) => {
      await mockHome(page)
      await mockAddEmail(page, 'added')
      await page.goto(`/learn/account/email${query}`)
      await expect(page.getByRole('link', { name: 'Back to your account' })).toHaveAttribute(
        'href',
        '/learn/account',
      )
      await expect(page.getByText(TAKEN_WARNING, { exact: true })).toBeVisible()
      await typeEmailAndCode(page)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      await page.getByRole('button', { name: 'Continue', exact: true }).click()
      await page.waitForURL((url) => url.pathname === '/learn')
    })
  }
})

test.describe('when the code cannot be sent', () => {
  test('[signup-choice 10] a server failure says so, without blaming the internet', async ({ page }) => {
    await mockHome(page)
    await page.route('**/api/account/email', (route) =>
      route.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"not_available"}' }),
    )
    await page.goto('/learn/account/email?then=lesson')
    await page.getByLabel('Email address').fill('alex@example.com')
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('status')).toHaveText(
      'We couldn’t send the code right now. Please try again in a few minutes.',
    )
  })

  test('[signup-choice 10] no connection still asks to check the internet', async ({ page }) => {
    await mockHome(page)
    await page.route('**/api/account/email', (route) => route.abort('failed'))
    await page.goto('/learn/account/email?then=lesson')
    await page.getByLabel('Email address').fill('alex@example.com')
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('status')).toHaveText(
      'The code could not be sent. Check your internet connection, then try again.',
    )
  })
})
