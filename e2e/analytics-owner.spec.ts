import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { one, sql } from './db.ts'
import {
  addToOwnerList,
  appBrowser,
  dashboard,
  openOwnerPage,
  ownerAccount,
  ownerHostMissing,
  ownerOrigin,
} from './owner-helpers.ts'
import { scrollsSideways, settleAnimations, tabTo } from './session-helpers.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
//
// The owner page on its own host. Locally the owner host is 127.0.0.1 or [::1] (the
// app stays on localhost), with a Cloudflare Access token made by this run's
// local key (e2e/owner-helpers.ts). The owner account is a real email account
// made through the app with its code from Mailpit (@email), then put on the
// owner list with the README's SQL line (@seed: throwaway database only).

const FORTY = 'Työttömyysturvalakimuutoksenvalmistelijat'

test.describe('the owner page', { tag: ['@seed', '@email'] }, () => {
  test.skip(ownerHostMissing() !== null, ownerHostMissing() ?? '')

  async function axe(page: Page, label: string) {
    await page.evaluate('document.fonts.ready')
    await settleAnimations(page)
    const result = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze()
    expect(
      result.violations.map((v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
    ).toEqual([])
  }

  test('[analytics 14] without the Access token, the owner host answers 403 with one plain line and no number', async ({
    request,
    baseURL,
  }) => {
    const origin = ownerOrigin(baseURL)
    for (const path of ['/owner', '/api/owner/dashboard', '/api/me', '/']) {
      const res = await request.get(`${origin}${path}`, { headers: {}, maxRedirects: 0 })
      expect(res.status(), path).toBe(403)
      expect(await res.text()).toBe(
        'This page is private. Sign in through its Cloudflare Access page to open it.\n',
      )
      expect(res.headers()['x-robots-tag']).toBe('noindex, nofollow')
    }
  })

  test('[analytics 13] [analytics 15] [analytics 17] [analytics 18] an account not on the list sees the refusal; on the list, the owner sees every section', async ({
    browser,
    baseURL,
  }, testInfo) => {
    const { page, userId, context } = await ownerAccount(browser, testInfo, baseURL)
    await page.goto('/owner')
    await expect(page.getByRole('status')).toHaveText('This account cannot open the owner page.')
    await expect(page.getByRole('heading', { level: 2, name: 'Learners' })).toHaveCount(0)

    addToOwnerList(userId)
    const answer = await page.goto('/owner')
    const headers = answer?.headers() ?? {}
    expect(headers['x-robots-tag']).toBe('noindex, nofollow')
    expect(headers['cache-control']).toBe('private, no-store')
    expect(headers['referrer-policy']).toBe('no-referrer')
    expect(headers['content-security-policy']).toContain("frame-ancestors 'none'")
    for (const heading of ['Learners', 'Visits', 'Feedback', 'Crashes']) {
      await expect(page.getByRole('heading', { level: 2, name: heading })).toBeVisible()
    }
    for (const title of [
      'Active learners',
      'Day 7 retention',
      'Median session',
      'Speak back',
      'AI and speech cost',
    ]) {
      await expect(page.getByRole('heading', { level: 3, name: title })).toBeVisible()
    }
    for (const goal of [
      'Goal: at least 25 percent.',
      'Goal: at least 8 minutes.',
      'Goal: at least half.',
      'PRD target: under €0.75 a month.',
    ]) {
      await expect(page.getByText(goal, { exact: true })).toBeVisible()
    }
    await expect(page.getByRole('table', { name: 'Visits by day, last 30 days' })).toBeVisible()
    await expect(
      page.getByRole('table', { name: 'Visits by day, last 30 days' }).locator('tbody tr'),
    ).toHaveCount(30)
    await expect(page.getByText(/^These numbers were worked out on /)).toBeVisible()
    await expect(page.locator('canvas, select, input[type="date"]')).toHaveCount(0)

    // Other page routes on the owner host go to /owner; the app's routes are not there.
    await page.goto('/session')
    await page.waitForURL('**/owner')
    const today = await page.request.get('/api/today')
    expect(today.status()).toBe(404)
    // The dashboard refuses a request from the app's own address.
    const cross = await page.request.get('/api/owner/dashboard', { headers: { origin: baseURL ?? '' } })
    expect(cross.status()).toBe(403)
    expect(cross.headers()['access-control-allow-origin']).toBeUndefined()
    await context.close()
  })

  test('[analytics 20] feedback shows as plain text with its date, screen and account kind, runs nothing, links nothing, and wraps a 40 letter word', async ({
    browser,
    baseURL,
  }, testInfo) => {
    const { page, userId, context } = await ownerAccount(browser, testInfo, baseURL)
    addToOwnerList(userId)
    const learner = one(
      `insert into auth.users (id, is_anonymous) values (gen_random_uuid(), true) returning id`,
    )
    const marker = `${testInfo.project.name}-${String(Date.now())}`
    const messages = [
      `<script>window.__ran = 1</script> ${marker}`,
      `<img src=x onerror="window.__ran = 2"> ${marker}`,
      `see https://example.com/page ${marker}`,
      `${FORTY}${FORTY} ${marker}`,
    ]
    for (const message of messages) {
      sql(`insert into public.feedback (user_id, screen, message) values (:'uid', 'finish', :'msg')`, {
        uid: learner,
        msg: message,
      })
    }
    let dialogs = 0
    page.on('dialog', (dialog) => {
      dialogs += 1
      void dialog.dismiss()
    })
    await openOwnerPage(page)
    const list = page.locator('[data-owner="feedback"]')
    for (const message of messages) await expect(list.getByText(message, { exact: true })).toBeVisible()
    await expect(list.locator('script, img, a')).toHaveCount(0)
    expect(await page.evaluate<unknown>('window.__ran')).toBeUndefined()
    expect(dialogs).toBe(0)
    await expect(list.getByText(/From the finish screen\. Guest account\./).first()).toBeVisible()
    expect(await page.content()).not.toContain(learner)
    expect(await scrollsSideways(page)).toBe(false)
    const wide = await list.getByText(`${FORTY}${FORTY} ${marker}`).boundingBox()
    expect((wide?.x ?? 999) + (wide?.width ?? 999)).toBeLessThanOrEqual(375)
    await context.close()
  })

  test('[analytics 27] "Send a test error" throws a real error, and after a reload the crash list shows it with its details', async ({
    browser,
    baseURL,
  }, testInfo) => {
    const { page, userId, context } = await ownerAccount(browser, testInfo, baseURL)
    addToOwnerList(userId)
    await openOwnerPage(page)
    const errors: string[] = []
    page.on('pageerror', (error) => errors.push(error.name))
    const sent = page.waitForResponse((res) => res.url().endsWith('/api/crash'))
    await page.getByRole('button', { name: 'Send a test error' }).click()
    expect((await sent).status()).toBe(204)
    expect(errors).toContain('OwnerPageTestError')
    await openOwnerPage(page)
    const crash = page.locator('[data-owner="crashes"] > li').filter({ hasText: 'OwnerPageTestError' })
    await expect(crash).toBeVisible()
    await expect(crash).toContainText('A test error from the owner page.')
    await expect(crash).toContainText(/Seen (once|\d+ times) in the last 30 days, last on /)
    await expect(crash).toContainText('Path /owner.')
    await expect(crash).toContainText(/App version ([0-9a-f]{7,40}|local)\./)
    await expect(crash).toContainText(/(Chrome|Safari) \d+, /)
    await expect(crash.locator('ol li').first()).toContainText(/^\/assets\/[A-Za-z0-9_.-]+\.js:\d+:\d+/)
    const label = testInfo.project.name === 'webkit' ? 'Safari%' : 'Chrome%'
    expect(
      one(
        `select count(*) from private.crash_reports
          where error_name = 'OwnerPageTestError' and path = '/owner' and browser like :'label'`,
        { label },
      ),
    ).not.toBe('0')
    await context.close()
  })

  test('[analytics 27] an error thrown on the learner front door shows up on the owner page', async ({
    browser,
    baseURL,
  }, testInfo) => {
    const { page, userId, context } = await ownerAccount(browser, testInfo, baseURL)
    addToOwnerList(userId)
    const learnerContext = await appBrowser(browser, testInfo, baseURL)
    const learner = await learnerContext.newPage()
    await learner.goto('/')
    await expect(learner.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    const name = `FrontDoorTestError${testInfo.project.name === 'webkit' ? 'Webkit' : 'Chromium'}`
    const sent = learner.waitForResponse((res) => res.url().endsWith('/api/crash'))
    await learner.evaluate((errorName) => {
      const error = new Error('A test error on the front door.')
      error.name = errorName
      setTimeout(() => {
        throw error
      }, 0)
    }, name)
    expect((await sent).status()).toBe(204)
    await learnerContext.close()
    await openOwnerPage(page)
    const crash = page.locator('[data-owner="crashes"] > li').filter({ hasText: name })
    await expect(crash).toBeVisible()
    await expect(crash).toContainText('A test error on the front door.')
    await expect(crash).toContainText('Path /.')
    expect((await dashboard(page)).crashes.some((c) => c.name === name && c.path === '/')).toBe(true)
    await context.close()
  })

  test('[analytics 31] the owner page fits 320 px and 200 percent text, has 44 px controls, works by keyboard, and axe finds nothing in light or dark', async ({
    browser,
    baseURL,
  }, testInfo) => {
    const { page, userId, context } = await ownerAccount(browser, testInfo, baseURL)
    addToOwnerList(userId)
    await openOwnerPage(page)
    for (const [width, text] of [
      [320, '100%'],
      [375, '200%'],
    ] as const) {
      await page.setViewportSize({ width, height: 812 })
      await page.addStyleTag({ content: `html { font-size: ${text} !important; }` })
      expect(await scrollsSideways(page), `${String(width)} px, text ${text}`).toBe(false)
      await page.addStyleTag({ content: 'html { font-size: 100% !important; }' })
    }
    await page.setViewportSize({ width: 375, height: 812 })
    for (const control of await page.locator('button, a[href]').all()) {
      if (!(await control.isVisible())) continue
      const size = await control.boundingBox()
      expect(size?.height ?? 0).toBeGreaterThanOrEqual(44)
      expect(size?.width ?? 0).toBeGreaterThanOrEqual(44)
    }
    const button = page.getByRole('button', { name: 'Send a test error' })
    await tabTo(page, button, testInfo)
    const sent = page.waitForResponse((res) => res.url().endsWith('/api/crash'))
    await page.keyboard.press('Enter')
    expect((await sent).status()).toBe(204)
    await expect(page.getByRole('status').filter({ hasText: 'A test error was thrown.' })).toBeVisible()
    for (const scheme of ['light', 'dark'] as const) {
      await page.emulateMedia({ colorScheme: scheme })
      await openOwnerPage(page)
      await axe(page, `/owner ${scheme}`)
    }
    await page.goto('/sign-in')
    await axe(page, '/sign-in on the owner host')
    await context.close()
  })
})
