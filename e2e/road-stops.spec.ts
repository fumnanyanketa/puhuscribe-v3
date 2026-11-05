import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { mockHome, type HomeMocks } from './road-mocks.ts'
import { scrollsSideways } from './session-helpers.ts'

// Labels in brackets are the "Done when" statements of fast route road-stops (the manager's brief of
// 5 November 2026, listed in factory/jobs/road-stops/build.md): the clean road with one Start, a picture on
// every sign, Aleksi's bubble on the visit he introduced himself, and Aleksi's stop screen before a stop.
// These answer the road's reads themselves (e2e/road-mocks.ts), so they need no database. By default the
// mocks press "Nice to meet you" when Aleksi's intro appears, as a new visitor would.
//
// Evidence: PUHUSCRIBE_EVIDENCE=1 also saves the screenshots to factory/jobs/road-stops/evidence/.

const EVIDENCE = process.env.PUHUSCRIBE_EVIDENCE === '1'
const OUT = resolve('factory/jobs/road-stops/evidence')

async function shot(page: Page, name: string, project: string) {
  if (!EVIDENCE || project !== 'chromium') return
  mkdirSync(OUT, { recursive: true })
  await page.evaluate('document.fonts.ready')
  await page.screenshot({ path: `${OUT}/${name}.png` })
}

/** Every stop done up to `count`. */
const doneUpTo = (count: number) =>
  Object.fromEntries(Array.from({ length: count }, (_, i) => [i + 1, 4] as const))

/** An email account that finished a stop: Aleksi does not introduce himself, so no bubble. */
const RETURNING: HomeMocks = {
  today: { signedIn: true, today: 'start', account: 'email', finishedStop: true },
  done: doneUpTo(24),
}

const start = (page: Page) => page.getByRole('button', { name: 'Start', exact: true })
const bubble = (page: Page) => page.getByTestId('road-bubble')
const BUBBLE_TEXT = 'These are the stops I’ll take you through.'
const GUEST_NOTE = 'Starting creates a guest account on this device so your progress is saved.'

async function openRoad(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, mocks)
  await page.goto('/learn')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  return calls
}

/** The road's opening is over and its signs have been fitted. */
async function settled(page: Page) {
  await expect(start(page)).toBeVisible({ timeout: 8000 })
  await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0)
  await page.waitForTimeout(500)
}

/** Each sign's stop number and the address of the picture standing above its board. */
async function signPictures(page: Page) {
  return page.evaluate<{ stop: string; src: string | null; loaded: boolean; above: boolean }[]>(
    `[...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
      const img = li.querySelector('img[data-sign-picture]')
      const board = li.querySelector('[data-sign-board]').getBoundingClientRect()
      const pic = img && img.getBoundingClientRect()
      return {
        stop: li.getAttribute('data-stop'),
        src: img && img.getAttribute('src'),
        loaded: Boolean(img && img.complete && img.naturalWidth > 0 && pic.height > 8),
        above: Boolean(pic && pic.bottom <= board.top + 4 && pic.left < board.right && board.left < pic.right),
      }
    })`,
  )
}

/** The finite animations of the page. */
async function finiteAnimations(page: Page) {
  return page.evaluate<{ name: string; end: number; delay: number }[]>(
    `document.getAnimations().flatMap((a) => {
      const t = a.effect.getComputedTiming()
      return Number.isFinite(t.endTime) ? [{ name: a.animationName || '', end: t.endTime, delay: t.delay }] : []
    })`,
  )
}

test.describe('the clean road', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[road-stops 1] every sign on the day one road shows its own stop’s picture, loaded, just above its board', async ({
    page,
  }) => {
    await openRoad(page)
    await settled(page)
    const signs = await signPictures(page)
    expect(signs.length).toBeGreaterThanOrEqual(4)
    for (const sign of signs) {
      expect(sign.src, `stop ${sign.stop}`).toBe(`/stops/${sign.stop.padStart(2, '0')}.svg`)
      expect(sign.loaded, `stop ${sign.stop}`).toBe(true)
      expect(sign.above, `stop ${sign.stop}`).toBe(true)
    }
    // Pictures say nothing to a screen reader: the sign's name does.
    await expect(page.locator('img[data-sign-picture]:not([alt=""])')).toHaveCount(0)
  })

  test('[road-stops 1] further along, every sign shows its own picture too', async ({ page }) => {
    await openRoad(page, RETURNING)
    await settled(page)
    const signs = await signPictures(page)
    expect(signs.map((sign) => sign.stop)).toContain('25')
    for (const sign of signs) {
      expect(sign.src, `stop ${sign.stop}`).toBe(`/stops/${sign.stop.padStart(2, '0')}.svg`)
      expect(sign.loaded, `stop ${sign.stop}`).toBe(true)
    }
  })

  for (const [who, mocks] of [
    ['a visitor', {}],
    [
      'a learner part way through a stop',
      { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 2 } },
    ],
    ['a learner with a session open', { today: { signedIn: true, today: 'continue' }, done: { 1: 4, 2: 2 } }],
    [
      'a learner with a review',
      { today: { signedIn: true, today: 'review', reviewCount: 9 }, done: { 1: 4 } },
    ],
    ['a learner who just finished a stop', { today: { signedIn: true, today: 'start' }, done: doneUpTo(3) }],
  ] as const) {
    test(`[road-stops 2] the road shows no card, only one Start: ${who}`, async ({ page }) => {
      await openRoad(page, mocks)
      await settled(page)
      await expect(page.getByRole('region', { name: 'Today' })).toHaveCount(0)
      const text = await page.locator('main').innerText()
      for (const gone of [
        'Have an account?',
        'Privacy notice',
        'Stop 1 ·',
        'short lessons',
        'lesson 3 of 4',
        'Next stop',
        'Practise',
        'Continue',
        'Start review',
        GUEST_NOTE,
      ]) {
        expect(text, gone).not.toContain(gone)
      }
      await expect(page.getByRole('link', { name: 'Sign in' })).toHaveCount(0)
      await expect(page.getByRole('heading', { level: 2 })).toHaveCount(0)
      // The only button is Start (a finished stop's sign is still a button that opens its practice), the
      // only link the account button.
      await expect(page.locator('main button:visible:not(ol button)')).toHaveCount(1)
      await expect(start(page)).toBeVisible()
      await expect(page.locator('main a:visible')).toHaveCount(1)
      await expect(page.getByRole('link', { name: 'Your account' })).toBeVisible()
      // Start is the app's mint pill, centred, not full width, about 56 px tall.
      const box = await start(page).boundingBox()
      expect(box?.height ?? 0).toBeGreaterThanOrEqual(54)
      expect(box?.height ?? 0).toBeLessThanOrEqual(60)
      expect(box?.width ?? 0).toBeLessThan(375 - 64)
      expect(Math.abs((box?.x ?? 0) + (box?.width ?? 0) / 2 - 375 / 2)).toBeLessThanOrEqual(2)
      await expect(start(page)).toHaveCSS('background-color', 'rgb(30, 133, 111)')
    })
  }

  test('[road-stops 2] nothing ready today: no Start and no card, only the one plain line', async ({
    page,
  }) => {
    await openRoad(page, {
      today: { signedIn: true, today: 'all_done', nextReview: { today: '2026-11-01', day: '2026-11-02' } },
      done: { 1: 4, 2: 4, 3: 2 },
    })
    await expect(page.getByRole('status')).toHaveText('Your next review is tomorrow.')
    await expect(start(page)).toHaveCount(0)
    await expect(page.getByRole('region', { name: 'Today' })).toHaveCount(0)
    await expect(page.locator('main button:visible:not(ol button)')).toHaveCount(0)
  })

  test('[road-stops 2] a session that ended: the one line above Start', async ({ page }) => {
    await openRoad(page, { today: { signedIn: false, ended: true } })
    await expect(page.getByRole('status')).toHaveText(
      'Your guest session ended on this device. Press Start to begin again.',
    )
    await expect(start(page)).toBeVisible()
  })

  test('[road-stops 1] [road-stops 2] the road before and after: screenshots', async ({ page }, info) => {
    await openRoad(page)
    await settled(page)
    await expect(bubble(page)).toBeVisible()
    await shot(page, '1-2-3-road-new-visitor-with-bubble-375x812', info.project.name)
    const back = await page.context().newPage()
    await openRoad(back, RETURNING)
    await settled(back)
    await expect(bubble(back)).toHaveCount(0)
    await shot(back, '1-2-3-road-returning-learner-375x812', info.project.name)
  })
})

test.describe('Aleksi’s bubble on the road', () => {
  test.describe('with the opening animation', () => {
    test.use({ reducedMotion: 'no-preference' })

    test('[road-stops 3] after "Nice to meet you" the bubble shows only once the opening animation is over', async ({
      page,
    }) => {
      await openRoad(page)
      // While the road is drawn the bubble keeps its place but is not shown.
      await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
      await expect(bubble(page)).toBeAttached()
      await expect(bubble(page)).toBeHidden()
      // The animation ends by itself; then the bubble is there with Aleksi's photo and line.
      await settled(page)
      await expect(bubble(page)).toBeVisible()
      await expect(bubble(page)).toHaveText(BUBBLE_TEXT)
      const face = bubble(page).locator('img')
      await expect(face).toHaveAttribute('src', /\/aleksi\/portrait-360\.webp$/)
      // The owner's crop: his whole head shows.
      await expect(face).toHaveCSS('object-fit', 'cover')
      await expect(face).toHaveCSS('object-position', '50% 18%')
      await expect(face).toHaveCSS('transform', 'matrix(1.12, 0, 0, 1.12, 0, 0)')
      await expect(face).toHaveCSS('transform-origin', '24px 14.4px')
      // It sits just above Start, inside the screen.
      const said = await bubble(page).boundingBox()
      const button = await start(page).boundingBox()
      expect((said?.y ?? 0) + (said?.height ?? 0)).toBeLessThanOrEqual(button?.y ?? 0)
      expect((button?.y ?? 0) - ((said?.y ?? 0) + (said?.height ?? 0))).toBeLessThanOrEqual(40)
    })

    test('[road-stops 3] Skip ends the animation and the bubble shows', async ({ page }) => {
      await openRoad(page)
      await page.getByRole('button', { name: 'Skip' }).click()
      await expect(bubble(page)).toBeVisible()
      await expect(start(page)).toBeFocused()
    })
  })

  test.describe('without the animation', () => {
    test.use({ reducedMotion: 'reduce' })

    test('[road-stops 3] a later road open in the same visit has no bubble', async ({ page }) => {
      await openRoad(page)
      await expect(bubble(page)).toBeVisible()
      // Back to the road later in the visit (a reload keeps the tab's visit marker): no intro, no bubble.
      await page.reload()
      await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Nice to meet you' })).toHaveCount(0)
      await settled(page)
      await expect(bubble(page)).toHaveCount(0)
    })

    test('[road-stops 3] a learner who does not meet Aleksi sees no bubble', async ({ page }) => {
      await openRoad(page, RETURNING)
      await settled(page)
      await expect(bubble(page)).toHaveCount(0)
      await expect(page.getByText(BUBBLE_TEXT)).toHaveCount(0)
    })

    test('[road-stops 3] once Start is pressed the bubble is gone, also back on the road', async ({
      page,
    }) => {
      await openRoad(page)
      await expect(bubble(page)).toBeVisible()
      await start(page).click()
      await page.getByRole('button', { name: 'Back to the road' }).click()
      await expect(start(page)).toBeVisible()
      await expect(bubble(page)).toHaveCount(0)
    })
  })
})

test.describe('Aleksi’s stop screen', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[road-stops 4] [road-stops 6] a visitor’s Start opens stop 1: number, name, picture, the second person line and the guest note', async ({
    page,
  }, info) => {
    const calls = await openRoad(page)
    await settled(page)
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1 })).toHaveText('This is stop 1, Meeting people.')
    await expect(page.getByRole('heading', { level: 1 }).locator('strong')).toHaveText('Meeting people')
    await expect(page.getByRole('heading', { level: 1 })).toBeFocused()
    await expect(
      page.getByText('Here you’ll learn to say who you are and where you’re from, and ask the same.', {
        exact: true,
      }),
    ).toBeVisible()
    const picture = page.getByTestId('stop-picture')
    await expect(picture).toHaveAttribute('src', '/stops/01.svg')
    expect(
      await page.evaluate<boolean>(
        `(() => { const img = document.querySelector('[data-testid="stop-picture"]'); return img.complete && img.naturalWidth > 0 })()`,
      ),
    ).toBe(true)
    expect((await picture.boundingBox())?.height ?? 0).toBeGreaterThan(150)
    await expect(page.getByRole('button', { name: 'Back to the road' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Continue', exact: true })).toBeVisible()
    // The guest note: one quiet line, with no age in it, and the privacy link.
    const note = page.getByText(GUEST_NOTE, { exact: true })
    await expect(note).toBeVisible()
    await expect(page.getByText(/18|adult/i)).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Privacy notice' })).toHaveAttribute('href', '/learn/privacy')
    // English only, and nothing is made yet.
    await expect(page.locator('[lang="fi"]')).toHaveCount(0)
    expect(calls.guest).toBe(0)
    await shot(page, '4-6-stop-screen-stop-1-visitor-375x812', info.project.name)
  })

  test('[road-stops 4] [road-stops 6] stop 25 for a signed in learner: its own picture and line, and no guest note', async ({
    page,
  }, info) => {
    await openRoad(page, RETURNING)
    await settled(page)
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      'This is stop 25, Coffee break and sauna.',
    )
    await expect(page.getByTestId('stop-picture')).toHaveAttribute('src', '/stops/25.svg')
    await expect(
      page.getByText('Here you’ll learn to join a coffee break and accept a sauna invitation.', {
        exact: true,
      }),
    ).toBeVisible()
    await expect(page.getByText(GUEST_NOTE)).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Privacy notice' })).toHaveCount(0)
    await shot(page, '4-6-stop-screen-stop-25-signed-in-375x812', info.project.name)
  })

  test('[road-stops 6] a guest with an account sees no guest note either', async ({ page }) => {
    await openRoad(page, { today: { signedIn: true, today: 'start', account: 'guest' } })
    await settled(page)
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1 })).toHaveText('This is stop 1, Meeting people.')
    await expect(page.getByText(GUEST_NOTE)).toHaveCount(0)
  })

  test('[road-stops 4] the back button and the browser’s Back both return to the road, with focus on Start', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    await settled(page)
    await start(page).click()
    await page.getByRole('button', { name: 'Back to the road' }).click()
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
    await expect(start(page)).toBeFocused()
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1, name: /^This is stop 1/ })).toBeVisible()
    await page.goBack()
    await expect(start(page)).toBeVisible()
    await expect(page).toHaveURL(/\/learn$/)
    expect(calls.guest).toBe(0)
  })

  test('[road-stops 5] a visitor’s Continue makes the guest account, then opens the lesson', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    await settled(page)
    await start(page).click()
    expect(calls.guest).toBe(0)
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
    expect(calls.guest).toBe(1)
  })

  test('[road-stops 5] when Cloudflare asks for its check, Continue runs it and sends the token, as Start did', async ({
    page,
  }) => {
    await mockHome(page)
    // The Turnstile script, a stand-in that hands over Cloudflare's published dummy token at once.
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
    await settled(page)
    await start(page).click()
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
    expect(bodies).toHaveLength(2)
    expect(bodies[1]).toContain('XXXX.DUMMY.TOKEN.XXXX')
  })

  test('[road-stops 5] a signed in learner’s Continue opens the lesson', async ({ page }) => {
    const calls = await openRoad(page, { today: { signedIn: true, today: 'start', account: 'guest' } })
    await settled(page)
    await start(page).click()
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
    expect(calls.guest).toBe(1)
  })

  test('[road-stops 5] after a finished stop, Continue on the next stop’s screen opens the lesson', async ({
    page,
  }) => {
    const calls = await openRoad(page, { today: { signedIn: true, today: 'start' }, done: doneUpTo(3) })
    await settled(page)
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      'This is stop 4, Numbers, prices and paying.',
    )
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
    await page.waitForURL('**/learn/session')
    expect(calls.guest).toBe(0)
  })

  for (const [who, mocks, posts] of [
    ['two lessons into stop 3', { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 2 } }, 1],
    ['with a session open', { today: { signedIn: true, today: 'continue' }, done: { 1: 4, 2: 4, 3: 2 } }, 0],
    [
      'with a review due',
      { today: { signedIn: true, today: 'review', reviewCount: 9 }, done: { 1: 4, 2: 1 } },
      1,
    ],
  ] as const) {
    test(`[road-stops 7] part way through a stop, Start goes straight to the lesson: ${who}`, async ({
      page,
    }) => {
      const calls = await openRoad(page, mocks)
      await settled(page)
      await start(page).click()
      await page.waitForURL('**/learn/session')
      expect(calls.guest).toBe(posts)
    })
  }
})

test.describe('signing in from the road', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[road-stops 8] a visitor reaches sign in from the person button', async ({ page }) => {
    await openRoad(page, { me: 401 })
    await settled(page)
    await page.getByRole('link', { name: 'Your account' }).click()
    await page.waitForURL('**/learn/account')
    await expect(page.getByText('There is no account on this device.')).toBeVisible()
    await page.getByRole('button', { name: 'Sign in with your email' }).click()
    await page.waitForURL('**/learn/sign-in')
  })
})

test.describe('the opening animation with pictures', () => {
  test.use({ reducedMotion: 'no-preference' })

  test('[road-stops 1] [road-stops 3] the signs pop up one after another with their pictures, nearest first, then the view settles', async ({
    page,
  }, info) => {
    await openRoad(page)
    const pops = (await finiteAnimations(page)).filter((a) => a.name.includes('signPop'))
    // Each sign's board and its picture pop.
    expect(pops.length).toBeGreaterThanOrEqual(8)
    const delays = [...new Set(pops.map((a) => Math.round(a.delay)))].sort((a, b) => a - b)
    expect(delays.length).toBeGreaterThanOrEqual(8)
    // One after another: the start times climb, the first well before the view moves in.
    const signOrder = await page.evaluate<number[]>(
      `[...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
        const a = li.querySelector('[data-sign-board]').parentElement.getAnimations()[0]
        return a ? a.effect.getComputedTiming().delay : -1
      })`,
    )
    for (let i = 1; i < signOrder.length; i++) expect(signOrder[i]).toBeGreaterThan(signOrder[i - 1] ?? 0)
    expect(signOrder[0]).toBeGreaterThan(0)
    expect(Math.max(...signOrder)).toBeLessThan(2500)
    // The whole opening still takes about 4.5 seconds.
    const longest = Math.max(...(await finiteAnimations(page)).map((a) => a.end))
    expect(longest).toBeGreaterThanOrEqual(4000)
    expect(longest).toBeLessThanOrEqual(5000)
    if (EVIDENCE && info.project.name === 'chromium') {
      mkdirSync(OUT, { recursive: true })
      for (const [at, name] of [
        [600, 'a'],
        [1300, 'b'],
      ] as const) {
        await page.evaluate(
          `document.getAnimations().forEach((a) => { a.pause(); a.currentTime = ${String(at)} })`,
        )
        await page.screenshot({ path: `${OUT}/1-3-animation-frame-${name}-${String(at)}ms.png` })
      }
      // The end, in a fresh page that plays the whole opening untouched.
      const whole = await page.context().newPage()
      await mockHome(whole)
      await whole.goto('/learn')
      await settled(whole)
      await expect(bubble(whole)).toBeVisible()
      await whole.bringToFront()
      await expect(bubble(whole)).toHaveCSS('opacity', '1')
      await whole.waitForTimeout(400)
      await whole.screenshot({ path: `${OUT}/1-3-animation-frame-c-settled.png` })
    }
  })
})

test.describe('reduced motion', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[road-stops 9] the end state at once: no pop, no Skip, every picture and the bubble already there', async ({
    page,
  }) => {
    // Watches the page from its first moment, so a Skip or an animation that shows only briefly is still
    // caught (an assertion that waits would let a short animation end first and pass).
    await page.addInitScript({
      content: `window.__motion = { skip: false, animated: false }
      new MutationObserver(() => {
        for (const button of document.querySelectorAll('button'))
          if ((button.textContent || '').trim() === 'Skip') window.__motion.skip = true
        if (document.querySelector('main[data-intro="on"]')) window.__motion.animated = true
      }).observe(document, { childList: true, subtree: true, attributes: true })`,
    })
    await openRoad(page)
    await expect(bubble(page)).toBeVisible()
    expect(await page.evaluate<{ skip: boolean; animated: boolean }>('window.__motion')).toEqual({
      skip: false,
      animated: false,
    })
    await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0)
    expect(await finiteAnimations(page)).toEqual([])
    await page.waitForTimeout(400)
    for (const sign of await signPictures(page)) expect(sign.loaded, `stop ${sign.stop}`).toBe(true)
    expect(await finiteAnimations(page)).toEqual([])
  })
})

test.describe('nothing overflows', () => {
  test.use({ reducedMotion: 'reduce' })

  const ROAD_PARTS =
    '[data-sign-board], img[data-sign-picture], [data-testid="road-start"] *, [role="progressbar"], a[aria-label="Your account"]'

  /**
   * The visible elements of `selector` whose box runs past the screen's sides. The road's scene itself is
   * wider than the screen on purpose (the opening animation zooms in) and clipped, so on the road only what
   * a learner reads or taps is checked: the signs, their pictures, the top and the bottom.
   */
  async function outside(page: Page, selector: string) {
    return page.evaluate<string[]>(
      `[...document.querySelectorAll(${JSON.stringify(selector)})].filter((el) => {
        const r = el.getBoundingClientRect()
        if (r.width === 0 || r.height === 0) return false
        const s = getComputedStyle(el)
        if (s.visibility === 'hidden') return false
        return r.left < -1 || r.right > document.documentElement.clientWidth + 1
      }).map((el) => el.tagName + ' ' + (el.textContent || '').slice(0, 30))`,
    )
  }

  for (const text of ['100%', '200%'] as const) {
    test(`[road-stops 10] at 375 x 812, text ${text}: the road, the bubble and the stop screen stay inside the screen`, async ({
      page,
    }, info) => {
      await mockHome(page)
      if (text !== '100%')
        await page.addInitScript({
          content: `document.addEventListener('DOMContentLoaded', () => {
            const style = document.createElement('style')
            style.textContent = 'html { font-size: ${text} !important; }'
            document.head.append(style)
          })`,
        })
      await page.goto('/learn')
      await settled(page)
      await expect(bubble(page)).toBeVisible()
      expect(await scrollsSideways(page)).toBe(false)
      expect(await outside(page, ROAD_PARTS)).toEqual([])
      // Start and the bubble are whole on the screen, the bubble above Start.
      await expect(start(page)).toBeInViewport({ ratio: 1 })
      await expect(bubble(page)).toBeInViewport({ ratio: 1 })
      // No sign or picture touches another, the bubble, the top bar or the sun's side of the screen.
      const boxes = await page.evaluate<{ left: number; top: number; right: number; bottom: number }[]>(
        `[...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
          const parts = [li.querySelector('[data-sign-board]'), li.querySelector('img[data-sign-picture]')]
            .filter(Boolean).map((el) => el.getBoundingClientRect()).filter((r) => r.height > 0)
          return {
            left: Math.min(...parts.map((r) => r.left)), top: Math.min(...parts.map((r) => r.top)),
            right: Math.max(...parts.map((r) => r.right)), bottom: Math.max(...parts.map((r) => r.bottom)),
          }
        })`,
      )
      const bottomArea = await page.getByTestId('road-start').boundingBox()
      for (const [i, box] of boxes.entries()) {
        expect(box.bottom, `sign ${String(i)}`).toBeLessThanOrEqual(bottomArea?.y ?? 0)
        for (const other of boxes.slice(i + 1))
          expect(
            box.left < other.right &&
              other.left < box.right &&
              box.top < other.bottom &&
              other.top < box.bottom,
          ).toBe(false)
      }
      if (text === '200%') await shot(page, '10-road-200-percent-375x812', info.project.name)
      await start(page).click()
      await expect(page.getByRole('heading', { level: 1, name: /^This is stop 1/ })).toBeVisible()
      expect(await scrollsSideways(page)).toBe(false)
      expect(await outside(page, 'main *')).toEqual([])
      // Every word and the button are reachable by scrolling down.
      const cont = page.getByRole('button', { name: 'Continue', exact: true })
      await cont.scrollIntoViewIfNeeded()
      await expect(cont).toBeInViewport()
      await page.getByRole('link', { name: 'Privacy notice' }).scrollIntoViewIfNeeded()
      await expect(page.getByRole('link', { name: 'Privacy notice' })).toBeInViewport()
      if (text === '200%') await shot(page, '10-stop-screen-200-percent-375x812', info.project.name)
    })
  }

  test('[road-stops 10] at 320 px wide with text at 200 percent nothing scrolls sideways on the road or the stop screen', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 640 })
    await openRoad(page, RETURNING)
    await settled(page)
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    await page.waitForTimeout(500)
    expect(await scrollsSideways(page)).toBe(false)
    await start(page).click()
    await expect(page.getByRole('heading', { level: 1, name: /^This is stop 25/ })).toBeVisible()
    expect(await scrollsSideways(page)).toBe(false)
  })
})
