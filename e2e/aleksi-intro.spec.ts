import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { OLD_INTRO_KEY, OLD_MET_KEY } from '../src/lib/aleksi-intro.ts'
import { fakeIntroAudio, played } from './intro-audio.ts'
import { mockHome } from './road-mocks.ts'
import { STORED_BESIDES_VISIT, VISIT_VALUE } from './visit-marker.ts'
import { pressStart } from './road-start.ts'

// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026). Labels name the item of the
// owner's brief; [intro-rule N] and [intro-stop N] labels are the owner's rules of 4 November 2026 on who
// sees the intro (factory/jobs/intro-rule/build.md, factory/jobs/intro-stop/build.md), and [intro-visit N]
// the owner's rule of 5 November 2026 on when: only at the start of a visit (factory/jobs/intro-visit/build.md,
// more in e2e/intro-visit.spec.ts). The road answers from e2e/road-mocks.ts, so no database is needed. With
// PUHUSCRIBE_EVIDENCE=1 the screenshots go to factory/jobs/aleksi-intro/evidence/ (Chromium only).
//
// Fast route intro-logo (owner, 5 November 2026) replaced the "Nice to meet you" screen with the new intro,
// version E: the logo, the lesson card, then the road and his journey line, all on its own
// (e2e/intro-logo.spec.ts). The rules of who meets him and when are unchanged, so these tests stay, on the new
// screen. With reduced motion, as the tests run, the intro is its end state at once: his bubble with his
// journey line on the road (it shows only when he introduced himself). With motion on, the intro opens on the
// logo, and its Skip takes the place of the old "Nice to meet you". The old tests of that screen itself
// ([aleksi-intro 2] its photo card and words, [aleksi-intro 3] the greeting and its play button) were replaced
// by the [intro-logo] tests of the new intro.

const OUT = resolve('factory/jobs/aleksi-intro/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'
const JOURNEY_FI = 'Lähetään yhessä matkaan!'
/** The intro screen's own Skip: it is in the page only while the intro shows. */
const INTRO = 'button[data-intro-skip]'

async function shot(page: Page, name: string, fullPage = false) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage })
}

async function openNew(
  page: Page,
  today: Record<string, unknown> = { signedIn: false, ended: false },
  done: Record<number, number> = {},
) {
  await fakeIntroAudio(page)
  const calls = await mockHome(page, { met: false, today, done })
  await page.goto('/learn')
  return calls
}

const road = (page: Page) => page.getByRole('list', { name: 'Stops on your road' })
/** With reduced motion: Aleksi introduced himself, so his bubble with his journey line is on the road. */
const introBubble = (page: Page) => page.getByTestId('road-bubble').getByText(JOURNEY_FI, { exact: true })

/** Reduced motion: the intro shows as its end state. */
async function meetsAleksi(page: Page) {
  await expect(road(page)).toBeVisible()
  await expect(introBubble(page)).toBeVisible()
}

/** The road opens with no intro. */
async function noIntro(page: Page) {
  await expect(road(page)).toBeVisible()
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await expect(page.getByTestId('road-bubble')).toHaveCount(0)
  await expect(page.locator(INTRO)).toHaveCount(0)
}

// Fast route intro-visit changed this test: a reload in the same visit used to show the intro again. Now
// only a new visit does (a new tab here), and the phone still keeps no "met" flag in localStorage.
test('[intro-rule 3] [intro-visit 1] [intro-visit 2] a new visitor meets Aleksi again in a new tab, not after a reload: the phone keeps no "met" flag', async ({
  page,
  context,
}) => {
  await openNew(page)
  await meetsAleksi(page)
  expect(await page.evaluate<number>('localStorage.length')).toBe(0)
  await page.reload()
  await noIntro(page)
  const fresh = await context.newPage()
  await openNew(fresh)
  await meetsAleksi(fresh)
})

// Every case of the owner's rule, with the GET /api/today body the Worker gives for it and the lessons done
// on the road (stop 1, "Meeting people", has 4 lessons).
const MEETS_ALEKSI: [string, Record<string, unknown>, Record<number, number>][] = [
  [
    'a guest with nothing done',
    { signedIn: true, today: 'start', account: 'guest', finishedStop: false },
    {},
  ],
  [
    'a guest who finished stop 1',
    { signedIn: true, today: 'start', account: 'guest', finishedStop: true },
    { 1: 4 },
  ],
  [
    'an email account with one lesson done and the stop not finished',
    { signedIn: true, today: 'start', account: 'email', finishedStop: false },
    { 1: 1 },
  ],
  [
    'an email account with three of four lessons done',
    { signedIn: true, today: 'start', account: 'email', finishedStop: false },
    { 1: 3 },
  ],
  ['a guest whose sign in ended', { signedIn: false, ended: true }, {}],
  ['an email account whose sign in ended', { signedIn: false, ended: true, account: 'email' }, {}],
]

// Fast route intro-visit changed these tests: they used to see the intro again after a reload. Now the reload
// is the same visit, and a new tab is a new one.
for (const [who, today, done] of MEETS_ALEKSI) {
  test(`[intro-stop 1] [intro-visit 1] [intro-visit 2] ${who} meets Aleksi at the start of each visit`, async ({
    page,
    context,
  }) => {
    await openNew(page, today, done)
    await meetsAleksi(page)
    await page.reload()
    await noIntro(page)
    const fresh = await context.newPage()
    await openNew(fresh, today, done)
    await meetsAleksi(fresh)
  })
}

test('[intro-stop 1] [intro-stop 4] an email account that did one lesson and left meets Aleksi again, then the road opens at their own place', async ({
  page,
}) => {
  await openNew(page, { signedIn: true, today: 'start', account: 'email', finishedStop: false }, { 1: 1 })
  await meetsAleksi(page)
  // Their progress is kept: stop 1 is current with one of its four lessons done, and Start opens the next one.
  const signs = road(page).getByRole('listitem')
  await expect(signs.first()).toHaveText(/Stop 1, Meeting people, current/)
  // The card is gone (fast route road-stops): one Start, which goes straight on part way through a stop.
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await expect(page.getByRole('link', { name: 'Sign in' })).toHaveCount(0)
})

// The intro and the road's opening animation with motion on; the test config turns motion off, so these turn
// it back on.
test.describe('with motion on', () => {
  test.use({ reducedMotion: 'no-preference' })

  test('[aleksi-intro 4] [intro-rule 3] [intro-rule 4] [intro-visit 1] Skip on the intro opens the road, keeps only the visit time, and Start goes straight to the lesson', async ({
    page,
  }) => {
    const calls = await openNew(page)
    await expect(page.locator(INTRO)).toBeVisible()
    // Nothing is kept on the phone before the intro ends or is skipped.
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    await page.locator('button[data-intro-skip]').click()
    await expect(road(page)).toBeVisible()
    // The only key is the visit marker in sessionStorage, holding a time (fast route intro-visit).
    expect(await page.evaluate<number>(STORED_BESIDES_VISIT)).toBe(0)
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    await shot(page, 'road-after-intro-375x812')
    // The day one card and its "Have an account? Sign in" are gone (fast route road-stops): sign in is
    // reached from the account button.
    await expect(page.getByRole('link', { name: 'Your account' })).toBeVisible()
    expect(calls.guest).toBe(0)
    await pressStart(page)
    await expect.poll(() => calls.guest).toBe(1)
    await expect(page.getByText('Why are you learning Finnish?')).toHaveCount(0)
  })

  test('[intro-stop 1] [intro-stop 4] [intro-visit 4] an email account that finished stop 1 never sees the intro: the road opens at their place with its animation', async ({
    page,
  }) => {
    await openNew(
      page,
      { signedIn: true, today: 'start', account: 'email', finishedStop: true },
      { 1: 4, 2: 1 },
    )
    await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
    await expect(road(page)).toBeAttached()
    await expect(page.locator(INTRO)).toHaveCount(0)
    await expect(road(page).getByRole('listitem').nth(1)).toHaveText(/Stop 2, .*current/)
    // Aleksi's voice never plays for this learner.
    expect(await played(page)).toEqual([])
    await page.reload()
    await expect(road(page)).toBeAttached()
    await expect(page.locator(INTRO)).toHaveCount(0)
  })
})

test('[intro-rule 3] the old "met Aleksi" flag is cleared from the phone and no longer skips the intro', async ({
  page,
}) => {
  await page.addInitScript({
    content: `try { localStorage.setItem(${JSON.stringify(OLD_MET_KEY)}, 'yes') } catch {}`,
  })
  await openNew(page)
  await meetsAleksi(page)
  // The init script writes the key again on every load, so this reads it once the page has cleared it.
  expect(
    await page.evaluate<string | null>(`localStorage.getItem(${JSON.stringify(OLD_MET_KEY)})`),
  ).toBeNull()
})

test('[aleksi-intro 4] the answers of the old first-open questions are cleared from the phone', async ({
  page,
}) => {
  await page.addInitScript({
    content: `try { localStorage.setItem(${JSON.stringify(OLD_INTRO_KEY)}, '{"seen":true,"reason":"work"}') } catch {}`,
  })
  await mockHome(page)
  await page.goto('/learn')
  await expect(road(page)).toBeVisible()
  // The init script writes the key again on every load, so this reads it once the page has cleared it.
  expect(
    await page.evaluate<string | null>(`localStorage.getItem(${JSON.stringify(OLD_INTRO_KEY)})`),
  ).toBeNull()
})

test.describe('narrow', () => {
  test.use({ viewport: { width: 320, height: 640 }, reducedMotion: 'no-preference' })

  test('[aleksi-intro 2] [intro-logo 12] at 320 px wide nothing on the intro runs sideways', async ({
    page,
  }) => {
    await openNew(page)
    await expect(page.locator(INTRO)).toBeVisible()
    expect(await page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')).toBe(
      false,
    )
    await shot(page, 'intro-320x640')
    await page.locator('button[data-intro-skip]').click()
    await expect(introBubble(page)).toBeVisible()
    expect(await page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')).toBe(
      false,
    )
  })
})

test('[aleksi-intro 1] every landing button says "Meet Aleksi" and opens the app', async ({ page }) => {
  await page.goto('/')
  // The hero's and the closing section's buttons (the top bar left the page in job landing-no-bar).
  const buttons = page.getByRole('link', { name: 'Meet Aleksi' })
  await expect(buttons).toHaveCount(2)
  for (const link of await buttons.all()) await expect(link).toHaveAttribute('href', '/learn')
  await expect(page.getByText('Start your journey now')).toHaveCount(0)
  await shot(page, 'landing-button-375x812')
})
