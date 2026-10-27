import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { recordApiTimings } from './api-timing.ts'
import { isGuestPost, recordRequests, scrollsSideways, settleAnimations, tabTo } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
//
// The pages that need no account and no seed rows: the front door's new
// links, the privacy notice, and the account page of a device with no
// account. They make no account, so they also run against the test project
// after merge and on preview links.

test.beforeEach(({ page }, testInfo) => {
  recordApiTimings(page, testInfo)
})

const SECTIONS = [
  'Who is responsible',
  'What we keep and why',
  'How long we keep it',
  'Where it is kept and who processes it',
  'Cookies',
  'Your rights',
  'Age',
  'Last updated',
]

async function checkFits(page: Page, label: string) {
  for (const [width, text] of [
    [320, '100%'],
    [375, '200%'],
  ] as const) {
    await page.setViewportSize({ width, height: 812 })
    await page.addStyleTag({ content: `html { font-size: ${text} !important; }` })
    expect(await scrollsSideways(page), `${label} at ${String(width)} px, text ${text}`).toBe(false)
    await page.addStyleTag({ content: 'html { font-size: 100% !important; }' })
  }
  await page.setViewportSize({ width: 375, height: 812 })
  for (const control of await page.locator('button, a[href], input').all()) {
    if (!(await control.isVisible())) continue
    const box = await control.boundingBox()
    const name = (await control.innerText().catch(() => '')) || ((await control.getAttribute('id')) ?? '')
    expect(box?.height ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
    expect(box?.width ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
  }
}

async function axe(page: Page, label: string) {
  await page.evaluate('document.fonts.ready')
  // A colour scheme switched on an open page starts the buttons' colour
  // transitions; axe must measure the finished colours, not a frame halfway.
  await settleAnimations(page)
  const result = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
    .analyze()
  expect(
    result.violations.map((v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
  ).toEqual([])
}

test('[accounts 1] the front door shows the privacy notice link, the account link and "I already have an account", and loading it makes nothing', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/')
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await expect(page.getByRole('link', { name: 'Privacy notice' })).toHaveAttribute('href', '/privacy')
  await expect(page.getByRole('link', { name: 'Your account' })).toHaveAttribute('href', '/account')
  const already = page.getByRole('button', { name: 'I already have an account' })
  await expect(already).toBeVisible()
  // The links sit under the Start line.
  const line = await page
    .getByText('Starting creates a guest account on this device so your progress is saved.', { exact: false })
    .boundingBox()
  const link = await page.getByRole('link', { name: 'Privacy notice' }).boundingBox()
  expect(link?.y ?? 0).toBeGreaterThan(line?.y ?? Infinity)
  await page.waitForLoadState('networkidle')
  expect(requests.filter(isGuestPost)).toHaveLength(0)
  expect(requests.filter((r) => r.method() === 'POST')).toHaveLength(0)
  await already.click()
  await page.waitForURL('**/sign-in')
  await expect(page.getByRole('heading', { level: 1, name: 'Sign in with your email' })).toBeVisible()
})

test('[accounts 16] the privacy notice loads without an account, makes no /api call, and has every section', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/privacy')
  await expect(page.getByRole('heading', { level: 1, name: 'Privacy notice' })).toBeVisible()
  for (const heading of SECTIONS) {
    await expect(page.getByRole('heading', { level: 2, name: heading, exact: true })).toBeVisible()
  }
  await expect(page.getByText('PuhuScribe is for adults, 18 and over.')).toBeVisible()
  await expect(
    page.getByText(/A guest account is deleted after 90 days with no learning activity/),
  ).toBeVisible()
  await page.waitForLoadState('networkidle')
  const origin = new URL(page.url()).origin
  for (const request of requests) expect(new URL(request.url()).origin, request.url()).toBe(origin)
  expect(requests.filter((r) => new URL(r.url()).pathname.startsWith('/api/'))).toEqual([])
  expect(await page.evaluate<string>('document.cookie')).toBe('')
})

test('[accounts 16] the privacy notice names who is responsible, with a mailto link that fits at 320 px', async ({
  page,
}) => {
  await page.setViewportSize({ width: 320, height: 640 })
  await page.goto('/privacy')
  await expect(page.getByText(/ is responsible for your data in PuhuScribe\./)).toBeVisible()
  const contact = page.locator('a[href^="mailto:"]')
  await expect(contact).toHaveCount(1)
  const address = ((await contact.getAttribute('href')) ?? '').replace('mailto:', '')
  await expect(contact).toHaveText(address)
  const box = await contact.boundingBox()
  expect((box?.x ?? 999) + (box?.width ?? 999)).toBeLessThanOrEqual(320)
  expect(await page.evaluate<boolean>('document.documentElement.scrollWidth <= 320')).toBe(true)
})

test('[accounts 16] the privacy notice is linked from the front door, the account page and the email screen', async ({
  page,
}) => {
  for (const path of ['/', '/account', '/sign-in']) {
    await page.goto(path)
    const link = page.getByRole('link', { name: 'Privacy notice' })
    await expect(link, path).toBeVisible()
    await link.click()
    await page.waitForURL('**/privacy')
    await expect(page.getByRole('heading', { level: 1, name: 'Privacy notice' })).toBeVisible()
  }
})

test('[accounts 2] with no account on this device the account page says so and offers sign in only', async ({
  page,
}) => {
  await page.goto('/account')
  await expect(page.getByRole('heading', { level: 1, name: 'Your account' })).toBeVisible()
  await expect(page.getByText('There is no account on this device.', { exact: true })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Sign in with your email' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Download my data' })).toHaveCount(0)
  await expect(page.getByRole('link', { name: 'Delete my account' })).toHaveCount(0)
  await expect(page.getByRole('button', { name: 'Sign out' })).toHaveCount(0)
  await expect(page.getByRole('link', { name: 'Privacy notice' })).toBeVisible()
  await page.getByRole('button', { name: 'Sign in with your email' }).click()
  await page.waitForURL('**/sign-in')
})

test('[accounts 4] [accounts 10] the sign in email screen: one email field, the text, and a gentle line for a bad address with no request', async ({
  page,
}) => {
  const requests = recordRequests(page)
  await page.goto('/sign-in')
  await expect(page.getByRole('heading', { level: 1, name: 'Sign in with your email' })).toBeVisible()
  await expect(
    page.getByText(
      'We send a 6 digit code to this address. We use your email only to send you sign in codes.',
    ),
  ).toBeVisible()
  const field = page.getByLabel('Email address')
  await expect(field).toHaveAttribute('type', 'email')
  await expect(field).toHaveAttribute('autocomplete', 'email')
  for (const bad of ['', 'learner', 'learner@example', `${'a'.repeat(250)}@example.com`]) {
    await field.fill(bad)
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('status')).toHaveText('Please check the email address.')
    await expect(page.getByRole('status')).toHaveAttribute('data-tone', 'gentle')
  }
  expect(requests.filter((r) => /\/api\/(sign-in|account\/email)/.test(new URL(r.url()).pathname))).toEqual(
    [],
  )
})

test('[accounts 27] the privacy notice, the account page and the sign in screen fit 320 px and 200 percent text, with 44 px controls', async ({
  page,
}) => {
  for (const path of ['/privacy', '/account', '/sign-in', '/']) {
    await page.goto(path)
    await page.waitForLoadState('networkidle')
    await checkFits(page, path)
  }
})

test('[accounts 27] the sign in screen works with the keyboard alone', async ({ page }, testInfo) => {
  const requests = recordRequests(page)
  await page.goto('/')
  await tabTo(page, page.getByRole('button', { name: 'I already have an account' }), testInfo)
  await page.keyboard.press('Enter')
  await page.waitForURL('**/sign-in')
  await expect(page.getByLabel('Email address')).toBeFocused()
  await page.keyboard.type('learner')
  await page.keyboard.press('Enter')
  await expect(page.getByRole('status')).toHaveText('Please check the email address.')
  expect(requests.filter((r) => new URL(r.url()).pathname === '/api/sign-in')).toEqual([])
})

for (const scheme of ['light', 'dark'] as const) {
  test(`[accounts 27] axe finds no WCAG A or AA problem on the pages with no account, ${scheme}`, async ({
    page,
  }) => {
    await page.emulateMedia({ colorScheme: scheme })
    for (const path of ['/', '/privacy', '/account', '/sign-in']) {
      await page.goto(path)
      await page.waitForLoadState('networkidle')
      await axe(page, path)
    }
    await page.goto('/sign-in')
    await page.getByLabel('Email address').fill('x')
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('status')).toHaveText('Please check the email address.')
    await axe(page, '/sign-in, gentle line')
  })
}

test.describe('the API from outside the page', () => {
  test('[accounts 26] every new route that changes something refuses another site, a form post and GET, with no CORS header and no cookie', async ({
    request,
  }) => {
    for (const path of [
      '/api/account/email',
      '/api/account/email/verify',
      '/api/sign-in',
      '/api/sign-in/verify',
      '/api/sign-out',
      '/api/account/delete',
    ]) {
      const evil = await request.post(path, {
        headers: { 'content-type': 'application/json', origin: 'https://evil.example' },
        data: { email: 'learner-a@example.com', code: '123456' },
      })
      expect(evil.status(), path).toBe(403)
      expect(evil.headers()['access-control-allow-origin']).toBeUndefined()
      expect(evil.headers()['set-cookie']).toBeUndefined()
      const form = await request.post(path, { form: { email: 'learner-a@example.com' } })
      expect(form.status(), path).toBe(415)
      const viaGet = await request.get(path)
      expect(viaGet.status(), path).toBe(405)
    }
  })

  test('[accounts 3] GET /api/me with no sign in answers kind none, and the export needs a sign in', async ({
    request,
  }) => {
    const me = await request.get('/api/me')
    expect(me.status()).toBe(200)
    expect(await me.json()).toEqual({ kind: 'none' })
    expect(me.headers()['access-control-allow-origin']).toBeUndefined()
    const file = await request.get('/api/account/export')
    expect(file.status()).toBe(401)
  })
})
