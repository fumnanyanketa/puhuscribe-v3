import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { mockHome, type HomeMocks } from './road-mocks.ts'
import { STORED_BESIDES_VISIT } from './visit-marker.ts'
import { pressStart } from './road-start.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. These answer the road's three reads
// themselves (e2e/road-mocks.ts), so they need no database. The stops are the
// road fixture of src/road/road-fixture.ts, which stands in for job 20.

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']

const SIGNED_IN = { signedIn: true, today: 'continue' }
/**
 * Keys in both storages. The tests set none themselves since fast route intro-rule removed the "met" flag.
 * The road's one key, the visit marker holding only a time (fast route intro-visit), is left out.
 */
const UNSET_STORAGE = STORED_BESIDES_VISIT
const MID = { 1: 4, 2: 4, 3: 2 }

async function openRoad(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, mocks)
  await page.goto('/learn')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  return calls
}

/** The finite animations of the page, with when each ends, in milliseconds. */
async function finiteAnimations(page: Page) {
  return page.evaluate<{ name: string; end: number }[]>(
    `document.getAnimations().flatMap((a) => {
      const t = a.effect.getComputedTiming()
      return Number.isFinite(t.endTime) ? [{ name: a.animationName || a.constructor.name, end: t.endTime }] : []
    })`,
  )
}

test.describe('the home screen is the road', () => {
  test(
    '[redesign 10] shows one hidden h1 "Your road to A1" and none of the old front door',
    { tag: '@smoke' },
    async ({ page }) => {
      await openRoad(page, { today: SIGNED_IN, done: MID })
      await expect(page.getByRole('heading', { level: 1 })).toHaveCount(1)
      await expect(page.getByRole('heading', { level: 1, name: 'Your road to A1' })).toBeAttached()
      const text = await page.locator('main').innerText()
      for (const gone of [
        "Today's session",
        'A session is one short Finnish dialogue',
        'Unit goal',
        'Voice settings',
        'Privacy notice',
        'Send feedback',
        'Your account',
        'Welcome',
      ]) {
        expect(text, gone).not.toContain(gone)
      }
      await expect(page.getByRole('img', { name: 'Aleksi', exact: true })).toHaveCount(0)
    },
  )

  test('[redesign 11] shows the sprout mark and a loading sentence while the road loads', async ({
    page,
  }) => {
    await mockHome(page, { roadDelayMs: 1500 })
    await page.goto('/learn')
    await expect(page.getByRole('status')).toHaveText('Loading your road.')
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
    await expect(page.getByRole('status')).toHaveCount(0)
  })

  test('[redesign 12] draws the three fell labels as real text, with B2 alone, and no YKI', async ({
    page,
  }) => {
    await openRoad(page, { today: SIGNED_IN, done: MID })
    const fells = page.getByRole('list', { name: 'Levels beyond A1' })
    await expect(fells.getByRole('listitem')).toHaveText(['A2', 'B1', 'B2'])
    expect(await page.locator('main').innerText()).not.toMatch(/YKI/)
    await expect(page.locator('svg text', { hasText: 'A1' })).toHaveCount(1)
  })

  test('[redesign 12] the mint travelled road runs from the bottom of the road up to the "you" marker at stop 3, and is not drawn on day one', async ({
    page,
  }) => {
    await openRoad(page, { today: SIGNED_IN, done: MID })
    await expect(page.getByTestId('you-marker')).toBeAttached()
    const mint = await page.evaluate<{ top: number; bottom: number; marker: number; box: number }>(`(() => {
      const group = document.querySelector('svg g[style*="land-travelled"]')
      const marker = document.querySelector('[data-testid="you-marker"]').getBoundingClientRect()
      const box = group.getBoundingClientRect()
      const scene = group.closest('svg').getBoundingClientRect()
      return { top: box.top, bottom: box.bottom, marker: marker.top + marker.height / 2, box: scene.bottom }
    })()`)
    // It ends at the marker (within a few pixels) and reaches the foot of the picture, behind the card.
    expect(Math.abs(mint.top - mint.marker)).toBeLessThan(12)
    expect(mint.bottom).toBeGreaterThan(mint.box - 20)
    expect(mint.bottom - mint.top).toBeGreaterThan(200)
    const none = await page.context().newPage()
    await openRoad(none, {})
    await expect(none.locator('svg g[style*="land-travelled"]')).toHaveCount(0)
  })

  test(
    '[redesign 13] five signs in one ordered list, each read like "Stop 3, At the grocery store, current"',
    { tag: '@smoke' },
    async ({ page }) => {
      await openRoad(page, { today: SIGNED_IN, done: MID })
      const signs = page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem')
      await expect(signs).toHaveCount(5)
      // Fast route go-back (owner, 3 November 2026): a done stop's sign is a button that offers its lessons
      // again as practice, and its name says so. Every other sign reads as before and is not a button.
      const done = page.getByRole('list', { name: 'Stops on your road' }).getByRole('button')
      await expect(done).toHaveCount(2)
      await expect(done.nth(0)).toHaveAccessibleName('Stop 1, Meeting people, done. Practise its lessons')
      await expect(done.nth(1)).toHaveAccessibleName('Stop 2, At the café, done. Practise its lessons')
      await expect(signs.nth(2)).toHaveText(/Stop 3, At the grocery store, current/)
      await expect(signs.nth(3)).toHaveText(/Stop 4, Numbers, prices and paying, later/)
      await expect(signs.nth(4)).toHaveText(/Stop 5, Getting around by bus and tram, later/)
      // A sign that is not done does nothing when pressed.
      const before = page.url()
      await signs.nth(3).click({ force: true })
      expect(page.url()).toBe(before)
    },
  )

  test('[redesign 13] a stop name is rendered as text, never as markup', async ({ page }) => {
    // A visitor, so Start opens the stop screen, which shows the name (fast route road-stops).
    await mockHome(page)
    await page.route('**/api/road', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          stops: [
            {
              number: 1,
              name: '<img src=x onerror="window.__ran=1">Meeting',
              canDo: '<b>I can</b> say hello.',
              part: 1,
              lessons: 4,
              lessonsDone: 0,
            },
          ],
        }),
      }),
    )
    await page.goto('/learn')
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
    // This name wraps on a drawn sign, so the sign is a number pin (follow up 19-sign-overflow, the owner's
    // "Number pins only"): the name is kept as text in the sign for screen readers, and shown as text on
    // Aleksi's stop screen (the card that showed it is gone since fast route road-stops).
    await expect(
      page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem').first(),
    ).toContainText('<img src=x onerror="window.__ran=1">Meeting')
    // The only pictures are the app's own: the stops' pictures and Aleksi's photo (fast route road-stops).
    const pictures = () =>
      page.evaluate<string[]>(
        `[...document.querySelectorAll('main img')].map((img) => img.getAttribute('src'))`,
      )
    for (const src of await pictures())
      expect(src).toMatch(/^\/(stops\/\d\d\.svg|aleksi\/portrait-\d+\.webp)$/)
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      'This is stop 1, <img src=x onerror="window.__ran=1">Meeting.',
    )
    expect(await page.evaluate<unknown>('window.__ran')).toBeUndefined()
    for (const src of await pictures())
      expect(src).toMatch(/^\/(stops\/\d\d\.svg|aleksi\/portrait-\d+\.webp)$/)
  })

  test('[redesign 14] the top holds the progress bar and the account button, with the letter of the email', async ({
    page,
  }) => {
    const calls = await openRoad(page, {
      today: SIGNED_IN,
      done: MID,
      me: { kind: 'email', email: 'maria@example.fi' },
    })
    const bar = page.getByRole('progressbar', { name: 'Progress on the road' })
    await expect(bar).toHaveAttribute('aria-valuemax', '12')
    await expect(bar.locator('i')).toHaveCount(12)
    const account = page.getByRole('link', { name: 'Your account' })
    await expect(account).toHaveText('M')
    expect(((await account.boundingBox())?.width ?? 0) >= 44).toBe(true)
    expect(calls.me).toBe(1)
  })

  // Round 6 (owner, item 1): the pieces are solid as drawn. A piece not reached is pale white with no
  // outline; a reached one is mint, which the contrast list holds at 3 to 1 or more on the pale piece.
  test('[redesign 14] [redesign 6] a progress piece not reached is solid pale white with no outline, and a reached one is solid mint', async ({
    page,
  }) => {
    await openRoad(page, { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 4 } })
    const bar = page.getByRole('progressbar', { name: 'Progress on the road' })
    await expect(bar).toBeVisible()
    const pieces = await page.evaluate<{ fill: string; ring: string }[]>(`(() =>
      [...document.querySelectorAll('[role="progressbar"] i')].map((item) => {
        const style = getComputedStyle(item)
        return { fill: style.backgroundColor, ring: style.boxShadow }
      }))()`)
    const reached = pieces.filter((piece) => piece.fill === 'rgb(30, 133, 111)')
    const open = pieces.filter((piece) => piece.fill !== 'rgb(30, 133, 111)')
    expect(reached.length).toBeGreaterThan(0)
    expect(open.length).toBeGreaterThan(0)
    for (const piece of open) {
      expect(piece.fill).toBe('rgb(255, 255, 255)')
      expect(piece.ring).not.toContain('inset')
    }
  })

  test('[redesign 14] a guest has a G, a visitor has a person mark and no call to GET /api/me, and a failure falls back to the mark', async ({
    page,
  }) => {
    await openRoad(page, { today: SIGNED_IN, me: { kind: 'guest' } })
    await expect(page.getByRole('link', { name: 'Your account' })).toHaveText('G')
    const visitor = await page.context().newPage()
    const calls = await openRoad(visitor)
    await expect(visitor.getByRole('link', { name: 'Your account' })).toHaveText('')
    expect(calls.me).toBe(0)
    const failing = await page.context().newPage()
    await openRoad(failing, { today: SIGNED_IN, me: 503 })
    await expect(failing.getByRole('link', { name: 'Your account' })).toHaveText('')
    await expect(failing.getByRole('link', { name: 'Your account' }).locator('svg')).toBeVisible()
  })

  // Changed requirement (fast route road-stops, owner, 5 November 2026): the card at the bottom of the road is
  // gone for everyone. The road shows one Start; the stop, the guest line and the privacy link moved to
  // Aleksi's stop screen, and sign in is reached from the account button (e2e/road-stops.spec.ts tests all
  // of it). These keep statement 15's other promises: the right action in each state, and its messages.
  test(
    '[redesign 15] [road-stops 2] day one: one Start, and its stop screen names the stop with the guest line in full and the privacy link',
    { tag: '@smoke' },
    async ({ page }) => {
      await openRoad(page)
      await expect(page.getByRole('region', { name: 'Today' })).toHaveCount(0)
      await page.getByRole('button', { name: 'Start', exact: true }).click()
      await expect(page.getByRole('heading', { level: 1 })).toHaveText('This is stop 1, Meeting people.')
      await expect(
        page.getByText('Starting creates a guest account on this device so your progress is saved.', {
          exact: true,
        }),
      ).toBeVisible()
      await expect(page.getByRole('link', { name: 'Privacy notice' })).toHaveAttribute('href', /privacy$/)
    },
  )

  test('[redesign 15] [road-stops 7] start or continue: one Start, straight into the lesson part way through a stop', async ({
    page,
  }) => {
    await openRoad(page, { today: { signedIn: true, today: 'start' }, done: MID })
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toContainText(
      'Stop 3, At the grocery store, current',
    )
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/learn/session')
    const resume = await page.context().newPage()
    await openRoad(resume, { today: SIGNED_IN, done: MID })
    await expect(resume.getByRole('button', { name: 'Continue', exact: true })).toHaveCount(0)
    await resume.getByRole('button', { name: 'Start', exact: true }).click()
    await resume.waitForURL('**/learn/session')
  })

  test('[redesign 15] review only: one Start, straight into the review', async ({ page }) => {
    const calls = await openRoad(page, {
      today: { signedIn: true, today: 'review', reviewCount: 14 },
      done: MID,
    })
    await expect(page.getByRole('button', { name: 'Start review' })).toHaveCount(0)
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/learn/session')
    expect(calls.guest).toBe(1)
  })

  test('[redesign 15] done for today: the evening sky, no button; stop finished: the next sign lit, and Start opens it', async ({
    page,
  }) => {
    await openRoad(page, {
      today: { signedIn: true, today: 'all_done', nextReview: { today: '2026-11-01', day: '2026-11-02' } },
      done: MID,
    })
    await expect(page.getByRole('status')).toHaveText('Your next review is tomorrow.')
    await expect(page.getByTestId('road-start').getByRole('button')).toHaveCount(0)
    await expect(page.locator('main[data-land="evening"]')).toHaveCount(1)
    const finished = await page.context().newPage()
    await openRoad(finished, { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 4 } })
    const next = finished.getByRole('list', { name: 'Stops on your road' }).locator('[data-stop="4"]')
    await expect(next).toHaveText(/Stop 4, Numbers, prices and paying, next/)
    await expect(next).toHaveAttribute('data-state', 'next')
    await finished.getByRole('button', { name: 'Start', exact: true }).click()
    await expect(finished.getByRole('heading', { level: 1 })).toHaveText(
      'This is stop 4, Numbers, prices and paying.',
    )
  })

  test('[redesign 15] the existing messages show as one plain line', async ({ page }) => {
    await openRoad(page, { today: { signedIn: false, ended: true } })
    await expect(page.getByRole('status')).toHaveText(
      'Your guest session ended on this device. Press Start to begin again.',
    )
    const notReady = await page.context().newPage()
    await openRoad(notReady, { today: { signedIn: true, today: 'not_ready' } })
    await expect(notReady.getByTestId('road-start').getByRole('status')).toHaveText(
      "Today's session is not ready yet. Please come back later.",
    )
    const allDone = await page.context().newPage()
    await openRoad(allDone, { today: { signedIn: true, today: 'all_done' } })
    await expect(allDone.getByRole('status')).toHaveText('You have finished every dialogue that is ready.')
  })

  test(
    '[redesign 16] loading the road creates nothing: no call to /api/guest before Start is pressed',
    { tag: '@smoke' },
    async ({ page }) => {
      const calls = await openRoad(page)
      await page.waitForLoadState('networkidle')
      await page.reload()
      await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
      expect(calls.guest).toBe(0)
      await page
        .getByRole('button', { name: 'Skip' })
        .click({ timeout: 1000 })
        .catch(() => undefined)
      // Since fast route road-stops the day one Start opens Aleksi's stop screen, which makes nothing either;
      // its Continue makes the guest account.
      await page.getByRole('button', { name: 'Start', exact: true }).click()
      await expect(page.getByRole('heading', { level: 1, name: /^This is stop 1/ })).toBeVisible()
      expect(calls.guest).toBe(0)
      await page.getByRole('button', { name: 'Back to the road' }).click()
      await pressStart(page)
      await expect.poll(() => calls.guest).toBe(1)
    },
  )

  test('[redesign 19] when the road cannot be read the page says "No connection", and no sign or stop is invented', async ({
    page,
  }) => {
    await mockHome(page, { roadFails: 503 })
    await page.goto('/learn')
    await expect(page.getByRole('heading', { level: 1, name: 'No connection' })).toBeVisible()
    await expect(page.getByText('Your progress is safe.')).toBeVisible()
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible()
  })
})

test.describe('the opening animation', () => {
  test.use({ reducedMotion: 'no-preference' })

  test('[redesign 17] [redesign 18] plays for a visitor in about 4.5 seconds, with Skip first, and ends on stop 1', async ({
    page,
  }) => {
    await openRoad(page)
    const longest = Math.max(...(await finiteAnimations(page)).map((a) => a.end))
    expect(longest).toBeGreaterThanOrEqual(4000)
    expect(longest).toBeLessThanOrEqual(5000)
    // Skip is the first control of the page and at least 44 px.
    const first = await page.evaluate<string>(
      `document.querySelector('main').querySelector('button, a[href]').textContent.trim()`,
    )
    expect(first).toBe('Skip')
    const box = await page.getByRole('button', { name: 'Skip' }).boundingBox()
    expect(box?.height ?? 0).toBeGreaterThanOrEqual(44)
    // Nothing hidden by the animation can be focused or tapped: Start is hidden with visibility.
    const hidden = await page.evaluate<string>(
      `getComputedStyle(document.querySelector('[data-testid="road-start"]')).visibility`,
    )
    expect(hidden).toBe('hidden')
    // It ends by itself on the day one road with stop 1 current.
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible({ timeout: 8000 })
    await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0)
    await expect(
      page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem').first(),
    ).toHaveText(/Stop 1, Meeting people, current/)
  })

  test('[redesign 18] Skip ends every animation within 300 ms and moves focus to Start', async ({ page }) => {
    await openRoad(page)
    expect((await finiteAnimations(page)).length).toBeGreaterThan(0)
    await page.getByRole('button', { name: 'Skip' }).click()
    await page.waitForTimeout(300)
    expect(await finiteAnimations(page)).toEqual([])
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeFocused()
  })

  test('[redesign 17] the animation is on the page from the start for screen readers: the road list is in the page and the layer that draws is aria-hidden', async ({
    page,
  }) => {
    await openRoad(page)
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeAttached()
    expect(await page.locator('svg[aria-hidden="true"]').count()).toBeGreaterThan(1)
    // Nothing is stored for it: no storage (beyond the visit's time stamp) and no cookie.
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    expect(await page.evaluate<number>(UNSET_STORAGE)).toBe(0)
  })

  // Owner, 3 November 2026: the animation plays every time the road opens, also for a learner who
  // comes back, and ends on the learner's own stop. This replaces "a signed in learner has no animation".
  test('[redesign 18] [intro animation] a signed in learner sees the animation too, can skip it, and it ends on their current stop', async ({
    page,
  }) => {
    await openRoad(page, { today: SIGNED_IN, done: MID })
    const longest = Math.max(...(await finiteAnimations(page)).map((a) => a.end))
    expect(longest).toBeGreaterThanOrEqual(4000)
    await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
    await page.getByRole('button', { name: 'Skip' }).click()
    await page.waitForTimeout(300)
    expect(await finiteAnimations(page)).toEqual([])
    // The road's one Start (it said "Continue" until fast route road-stops).
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeFocused()
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toContainText(
      'Stop 3, At the grocery store, current',
    )
  })

  test('[intro animation] it plays again for a returning learner after a refresh', async ({ page }) => {
    await openRoad(page, { today: SIGNED_IN, done: MID })
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible({ timeout: 8000 })
    await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0)
    await page.reload()
    await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
    expect((await finiteAnimations(page)).length).toBeGreaterThan(0)
  })
})

test.describe('with reduced motion', () => {
  test.use({ reducedMotion: 'reduce' })

  // Owner, 3 November 2026 (via the manager): with reduced motion there is no animation at all, the
  // road opens straight on its end state. This replaces the 600 ms crossfade of job 19.
  for (const [who, mocks, button] of [
    ['a visitor', {}, 'Start'],
    ['a signed in learner', { today: SIGNED_IN, done: MID }, 'Start'],
  ] as const) {
    test(`[redesign 17] [redesign 18] [intro animation] no animation and no Skip, straight to the end state, for ${who}`, async ({
      page,
    }) => {
      await openRoad(page, mocks)
      expect(await finiteAnimations(page)).toEqual([])
      await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0)
      await expect(page.getByRole('button', { name: button, exact: true })).toBeVisible()
      expect(
        await page.evaluate<string>(
          `getComputedStyle(document.querySelector('[data-testid="road-start"]')).visibility`,
        ),
      ).toBe('visible')
    })
  }

  test('[redesign 12] [redesign 47] no marker pulse with reduced motion on', async ({ page }) => {
    await openRoad(page, { today: SIGNED_IN, done: MID })
    await page.waitForTimeout(700)
    expect(await page.evaluate<number>('document.getAnimations().length')).toBe(0)
  })
})

test.describe('small phones and large text', () => {
  const STATES: [string, HomeMocks][] = [
    ['day one', {}],
    ['continue', { today: SIGNED_IN, done: MID }],
    ['review', { today: { signedIn: true, today: 'review', reviewCount: 14 }, done: MID }],
    ['stop finished', { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 4 } }],
    [
      'done',
      {
        today: { signedIn: true, today: 'all_done', nextReview: { today: '2026-11-01', day: '2026-11-02' } },
        done: MID,
      },
    ],
  ]
  for (const [name, mocks] of STATES) {
    test(`[redesign 20] at 375 x 667 the card never covers the current sign or the marker: ${name}`, async ({
      page,
    }) => {
      await page.setViewportSize({ width: 375, height: 667 })
      await openRoad(page, mocks)
      if (name === 'day one')
        await page
          .getByRole('button', { name: 'Skip' })
          .click({ timeout: 1500 })
          .catch(() => undefined)
      await page.waitForTimeout(400)
      const rects = await page.evaluate<{ card: number; marker: number; sign: number }>(
        `(() => {
          const card = document.querySelector('[data-testid="road-start"]').getBoundingClientRect().top
          const marker = document.querySelector('[data-testid="you-marker"]').getBoundingClientRect().bottom
          const current = document.querySelector('li[data-state="current"], li[data-state="done"]:last-of-type, li[data-state="next"]')
          const all = [...document.querySelectorAll('li[data-state]')]
          const pick = all.find((el) => el.getAttribute('data-state') === 'current') || all.filter((el) => el.getAttribute('data-state') === 'done').at(-1) || current
          return { card, marker, sign: pick.getBoundingClientRect().bottom }
        })()`,
      )
      expect(rects.marker).toBeLessThanOrEqual(rects.card + 1)
      expect(rects.sign).toBeLessThanOrEqual(rects.card + 1)
    })
  }

  // Round 3 (design review A and B): on a short phone and at 200 percent text the signs never pile up,
  // none touches the top bar, the sign of the current stop and the next one stay, and the card stops at a
  // share of the screen with its inside scrolling.
  for (const [name, mocks] of STATES) {
    for (const [width, height, text] of [
      [375, 667, '100%'],
      [320, 640, '200%'],
    ] as const) {
      test(`[redesign 20] [redesign 13] ${name} at ${String(width)} x ${String(height)}, text ${text}: no two signs touch, none touches the top bar, the card scrolls inside`, async ({
        page,
      }) => {
        await page.setViewportSize({ width, height })
        await openRoad(page, mocks)
        if (name === 'day one')
          await page
            .getByRole('button', { name: 'Skip' })
            .click({ timeout: 1500 })
            .catch(() => undefined)
        await page.addStyleTag({ content: `html { font-size: ${text} !important; }` })
        await page.waitForTimeout(700)
        const look = await page.evaluate<{
          boards: { left: number; top: number; right: number; bottom: number }[]
          bar: { left: number; top: number; right: number; bottom: number }[]
          states: string[]
          card: { height: number; scrolls: boolean; client: number }
          viewport: number
          topVisible: boolean[]
        }>(`(() => {
          const rect = (el) => { const r = el.getBoundingClientRect(); return { left: r.left, top: r.top, right: r.right, bottom: r.bottom } }
          const items = [...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')]
          const bar = [document.querySelector('[role="progressbar"]'), document.querySelector('a[aria-label="Your account"]')]
          const wrapper = document.querySelector('[data-testid="road-start"]')
          const covered = bar.map((el) => {
            const r = el.getBoundingClientRect()
            const hit = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2)
            return Boolean(hit && (el === hit || el.contains(hit)))
          })
          return {
            boards: items.map((li) => rect(li.firstElementChild.querySelector('[aria-hidden="true"]'))),
            bar: bar.map(rect),
            states: items.map((li) => li.getAttribute('data-state')),
            card: { height: wrapper.getBoundingClientRect().height, scrolls: wrapper.scrollHeight > wrapper.clientHeight, client: wrapper.clientHeight },
            viewport: window.innerHeight,
            topVisible: covered,
          }
        })()`)
        const touching = (a: { left: number; top: number; right: number; bottom: number }, b: typeof a) =>
          a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom
        expect(look.boards.length).toBeGreaterThanOrEqual(2)
        expect(look.states.some((state) => state === 'current' || state === 'done')).toBe(true)
        for (const [index, board] of look.boards.entries()) {
          for (const other of look.boards.slice(index + 1)) expect(touching(board, other)).toBe(false)
          for (const box of look.bar) expect(touching(board, box)).toBe(false)
        }
        // Every board is whole on the screen: none is cut by an edge.
        for (const board of look.boards) {
          expect(board.left).toBeGreaterThanOrEqual(0)
          expect(board.right).toBeLessThanOrEqual(width)
        }
        // The bar and the account button are on screen and not covered by anything.
        expect(look.topVisible).toEqual([true, true])
        expect(look.card.height).toBeLessThanOrEqual(look.viewport * 0.43)
        // What does not fit is reached by scrolling inside the card: the button is reachable.
        const card = page.getByTestId('road-start')
        const button = card.getByRole('button').first()
        if (await button.count()) {
          await button.scrollIntoViewIfNeeded()
          await expect(button).toBeInViewport()
        }
        await card.scrollIntoViewIfNeeded()
      })
    }
  }

  test('[redesign 20] [redesign 46] at 320 px wide with text at 200 percent nothing scrolls sideways, and the full stop name is still read out', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 568 })
    await openRoad(page, { today: SIGNED_IN, done: { 1: 4, 2: 4, 3: 4, 4: 4, 5: 4, 6: 1 } })
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    await page.waitForTimeout(300)
    const result = await page.evaluate<{ scroll: number; width: number }>(
      `({ scroll: document.documentElement.scrollWidth, width: document.documentElement.clientWidth })`,
    )
    expect(result.scroll).toBeLessThanOrEqual(result.width)
    // The card that showed the name is gone (fast route road-stops); the sign keeps it for screen readers.
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toContainText(
      'Stop 6, Small talk: weather and the weekend, current',
    )
  })
})

test.describe('what the road asks for', () => {
  test('[redesign 44] [intro-visit 1] a visitor’s road talks only to the app’s own address and stores nothing but the visit time', async ({
    page,
  }) => {
    const origins = new Set<string>()
    page.on('request', (request) => {
      if (!/^(data|blob):/.test(request.url())) origins.add(new URL(request.url()).origin)
    })
    await openRoad(page)
    await page.waitForLoadState('networkidle')
    expect([...origins]).toEqual([new URL(page.url()).origin])
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    expect(await page.evaluate<number>(UNSET_STORAGE)).toBe(0)
  })

  for (const [name, mocks] of [
    ['day one', {}],
    ['continue', { today: SIGNED_IN, done: MID }],
    [
      'done for today',
      {
        today: { signedIn: true, today: 'all_done', nextReview: { today: '2026-11-01', day: '2026-11-02' } },
        done: MID,
      },
    ],
    ['stop finished', { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 4 } }],
    ['review', { today: { signedIn: true, today: 'review', reviewCount: 14 }, done: MID }],
  ] as [string, HomeMocks][]) {
    test(`[redesign 47] axe finds no WCAG A or AA problem on the road: ${name}`, async ({ page }) => {
      await openRoad(page, mocks)
      if (name === 'day one')
        await page
          .getByRole('button', { name: 'Skip' })
          .click({ timeout: 1500 })
          .catch(() => undefined)
      await page.evaluate('document.fonts.ready')
      await page.waitForTimeout(300)
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
    })
  }
})
