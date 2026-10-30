import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page, type Request } from '@playwright/test'
import { finishTodaysSession, startGuest } from './account-helpers.ts'
import { one, sql } from './db.ts'
import { dayLater, finishEveryOtherDialogue, typeAnswer } from './review-helpers.ts'
import { scrollsSideways, settleAnimations, tabTo } from './session-helpers.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
//
// The feedback page and its three quiet links, the walk that must never leave
// the app's own address, and a crash on a screen with a typed answer. Phone
// size against the built app and the throwaway local Supabase with the test
// fixture unit (@seed).

const INTRO = 'Tell us what worked, what did not, or what broke. Please do not include personal details.'
const FORTY = 'Työttömyysturvalakimuutoksenvalmistelijat'

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

function feedbackOf(userId: string): { screen: string; message: string }[] {
  return sql(`select screen, message from public.feedback where user_id = :'uid' order by created_at`, {
    uid: userId,
  }).map(([screen = '', message = '']) => ({ screen, message }))
}

test.describe('feedback', { tag: '@seed' }, () => {
  test('[analytics 19] without an account the page says to start first, links to the front door, and the front door shows no feedback link', async ({
    page,
  }) => {
    await page.goto('/feedback')
    await expect(page.getByRole('heading', { level: 1, name: 'Send feedback' })).toBeVisible()
    await expect(page.getByText('Start your first session, then you can send feedback.')).toBeVisible()
    await expect(page.getByRole('link', { name: 'Go to the front door' })).toHaveAttribute('href', '/')
    await expect(page.getByLabel('Your message')).toHaveCount(0)
    await page.goto('/')
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Send feedback' })).toHaveCount(0)
  })

  test('[analytics 19] [analytics 21] a quiet link on the front door and the account page opens the form, and a message is stored with its screen', async ({
    page,
  }) => {
    const userId = await startGuest(page)
    await page.goto('/')
    const fromFront = page.getByRole('link', { name: 'Send feedback' })
    await expect(fromFront).toHaveAttribute('href', '/feedback?from=front_door')
    await fromFront.click()
    await page.waitForURL('**/feedback?from=front_door')
    await expect(page.getByRole('heading', { level: 1, name: 'Send feedback' })).toBeVisible()
    await expect(page.getByText(INTRO)).toBeVisible()
    const box = page.getByLabel('Your message')
    await expect(page.getByText('0 of 1,000 characters')).toBeVisible()
    await box.fill('The front door was clear.')
    await expect(page.getByText('25 of 1,000 characters')).toBeVisible()
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')

    await page.goto('/account')
    const fromAccount = page.getByRole('link', { name: 'Send feedback' })
    await expect(fromAccount).toHaveAttribute('href', '/feedback?from=account')
    await fromAccount.click()
    await page.getByLabel('Your message').fill('The account page works.')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')

    expect(feedbackOf(userId)).toEqual([
      { screen: 'front_door', message: 'The front door was clear.' },
      { screen: 'account', message: 'The account page works.' },
    ])
  })

  test('[analytics 19] the finish screen has the quiet link, and the loop gains no step', async ({
    page,
  }) => {
    const userId = await finishTodaysSession(page)
    // The finish screen: one heading, the Done button, and the quiet link.
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    const link = page.getByRole('link', { name: 'Send feedback' })
    await expect(link).toHaveAttribute('href', '/feedback?from=finish')
    await link.click()
    await page.getByLabel('Your message').fill('Hear it was fun.')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')
    expect(feedbackOf(userId)).toEqual([{ screen: 'finish', message: 'Hear it was fun.' }])
  })

  // Round 3 (evaluator failure 2): on a slow connection, a second tap or an
  // Enter on Send while the message is sending must not store it twice.
  test('[analytics 19] a second tap and an Enter on Send while the message is sending store it once', async ({
    page,
  }) => {
    const userId = await startGuest(page)
    await page.goto('/feedback?from=account')
    const isFeedbackPost = (request: Request) =>
      request.method() === 'POST' && new URL(request.url()).pathname === '/api/feedback'
    const posts: (string | null)[] = []
    let answered = 0
    page.on('request', (request) => {
      if (isFeedbackPost(request)) posts.push(request.postData())
    })
    page.on('response', (response) => {
      if (isFeedbackPost(response.request())) answered += 1
    })
    // A slow phone connection: the answer takes 2 seconds.
    await page.route('**/api/feedback', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 2_000))
      await route.continue()
    })
    await page.getByLabel('Your message').fill('Sent once on a slow connection.')
    const send = page.locator('form button[type="submit"]')
    await send.click()
    await expect(send).toHaveAttribute('aria-busy', 'true')
    // The busy button refuses Playwright's normal click, so tap it as a finger would.
    await send.click({ force: true })
    await send.focus()
    await page.keyboard.press('Enter')
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')
    await expect.poll(() => answered, { timeout: 10_000 }).toBe(posts.length)
    expect(posts).toEqual([JSON.stringify({ screen: 'account', message: 'Sent once on a slow connection.' })])
    expect(feedbackOf(userId)).toEqual([{ screen: 'account', message: 'Sent once on a slow connection.' }])
  })

  test('[analytics 22] an empty message is not sent, and the 6th message of the day gets the gentle line', async ({
    page,
  }) => {
    const userId = await startGuest(page)
    await page.goto('/feedback?from=account')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText('Please write your message first.')
    expect(feedbackOf(userId)).toEqual([])
    sql(
      `insert into public.feedback (user_id, screen, message)
       select :'uid', 'account', 'earlier ' || n from generate_series(1, 5) as n`,
      { uid: userId },
    )
    await page.getByLabel('Your message').fill('One more.')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText(
      'You have sent 5 messages today. Please try again tomorrow.',
    )
    await expect(page.locator('[data-tone="gentle"]')).toBeVisible()
    expect(feedbackOf(userId)).toHaveLength(5)
  })

  test('[analytics 31] the feedback page fits 320 px and 200 percent text, has 44 px controls and a visible label, wraps a 40 letter word, and works by keyboard', async ({
    page,
  }, testInfo) => {
    const userId = await startGuest(page)
    await page.goto('/feedback?from=account')
    const box = page.getByLabel('Your message')
    await expect(box).toBeVisible()
    await expect(page.locator('label', { hasText: 'Your message' })).toBeVisible()
    await box.fill(`${FORTY} ${FORTY}`)
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
    for (const control of await page.locator('button, a[href], textarea').all()) {
      const size = await control.boundingBox()
      expect(size?.height ?? 0).toBeGreaterThanOrEqual(44)
      expect(size?.width ?? 0).toBeGreaterThanOrEqual(44)
    }
    await box.fill('')
    await tabTo(page, box, testInfo)
    await page.keyboard.type('Sent with the keyboard.')
    await tabTo(page, page.getByRole('button', { name: 'Send', exact: true }), testInfo)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')
    expect(feedbackOf(userId)).toEqual([{ screen: 'account', message: 'Sent with the keyboard.' }])
  })

  for (const scheme of ['light', 'dark'] as const) {
    test(`[analytics 31] axe finds no WCAG A or AA problem on the feedback page, ${scheme}`, async ({
      page,
    }) => {
      await page.emulateMedia({ colorScheme: scheme })
      await page.goto('/feedback')
      await expect(page.getByText('Start your first session, then you can send feedback.')).toBeVisible()
      await axe(page, '/feedback, no account')
      await startGuest(page)
      await page.goto('/feedback?from=account')
      await expect(page.getByLabel('Your message')).toBeVisible()
      await axe(page, '/feedback, form')
      await page.getByRole('button', { name: 'Send', exact: true }).click()
      await expect(page.getByRole('status')).toHaveText('Please write your message first.')
      await axe(page, '/feedback, gentle line')
    })
  }
})

test.describe('no outside request', { tag: '@seed' }, () => {
  test('[analytics 7] a guest from the front door through the session, the feedback page and the account page never leaves the app address', async ({
    page,
  }) => {
    const requests: Request[] = []
    page.on('request', (request) => requests.push(request))
    await finishTodaysSession(page)
    await page.getByRole('link', { name: 'Send feedback' }).click()
    await page.getByLabel('Your message').fill('Walking through the whole app.')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText('Thank you. Your message is sent.')
    await page.goto('/account')
    await expect(page.getByRole('heading', { level: 1, name: 'Your account' })).toBeVisible()
    await page.waitForLoadState('networkidle')
    const origin = new URL(page.url()).origin
    const outside = requests
      .map((request) => request.url())
      .filter((url) => !url.startsWith('data:') && !url.startsWith('blob:') && new URL(url).origin !== origin)
    expect(requests.length).toBeGreaterThan(10)
    expect(outside).toEqual([])
  })
})

test.describe('a crash on a screen with a typed answer', { tag: '@seed' }, () => {
  test('[analytics 25] the stored report does not contain the answer the learner typed', async ({
    page,
  }, testInfo) => {
    const userId = await finishTodaysSession(page)
    // Keep it needs a day to pass and nothing new to learn (job 9's own steps).
    dayLater(userId)
    finishEveryOtherDialogue(userId)
    await page.goto('/')
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.locator('[data-review-item]').first()).toBeVisible()
    const answer = 'kahvilassa'
    await typeAnswer(page, answer)
    const name = `TypedAnswerTestError${testInfo.project.name === 'webkit' ? 'Webkit' : 'Chromium'}`
    // An error whose message carries the typed text, as a careless bug could.
    await page.evaluate(`(() => {
      const field = document.querySelector('input')
      const error = new Error('Could not grade "' + (field ? field.value : '') + '" on this screen')
      error.name = ${JSON.stringify(name)}
      setTimeout(() => { throw error }, 0)
    })()`)
    await expect
      .poll(() => one(`select count(*) from private.crash_reports where error_name = :'name'`, { name }), {
        timeout: 15_000,
      })
      .toBe('1')
    const stored = one(`select to_jsonb(c)::text from private.crash_reports c where error_name = :'name'`, {
      name,
    })
    expect(stored.toLowerCase()).not.toContain(answer)
    expect(stored).toContain('Could not grade \\"[typed]\\" on this screen')
    expect(stored).toContain('"path": "/session"')
  })

  // Round 2 (security note 1): only the owner host sends cookies with a crash
  // report. On the app host a signed in learner's report goes without them.
  test('[analytics 25] [analytics 30] on the app host, a signed in learner sends a crash report with no cookie', async ({
    page,
  }, testInfo) => {
    await startGuest(page)
    expect((await page.context().cookies()).length).toBeGreaterThan(0)
    await expect(page.locator('html')).not.toHaveAttribute('data-puhuscribe-host')
    const name = `AppHostCookieCheck${testInfo.project.name === 'webkit' ? 'Webkit' : 'Chromium'}`
    const request = page.waitForRequest((req) => req.url().endsWith('/api/crash'))
    const response = page.waitForResponse((res) => res.url().endsWith('/api/crash'))
    await page.evaluate(`(() => {
      const error = new Error('An app host cookie check.')
      error.name = ${JSON.stringify(name)}
      setTimeout(() => { throw error }, 0)
    })()`)
    const headers = await (await request).allHeaders()
    expect(headers.cookie).toBeUndefined()
    expect((await response).status()).toBe(204)
  })
})
