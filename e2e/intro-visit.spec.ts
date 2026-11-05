import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type BrowserContext, type Page } from '@playwright/test'
import { VISIT_KEY } from '../src/lib/aleksi-intro.ts'
import { mockLesson } from './lesson-mocks.ts'
import { mockHome } from './road-mocks.ts'
import { leaveLesson } from './session-helpers.ts'
import { STORED_BESIDES_VISIT, VISIT_VALUE } from './visit-marker.ts'

// Fast route intro-visit (owner, 5 November 2026): Aleksi's intro shows only at the start of a visit. A visit
// starts when the app opens fresh (a new tab: its sessionStorage holds no marker) or after 60 minutes or more
// without use. Labels [intro-visit N] are the numbered statements in factory/jobs/intro-visit/build.md. The
// road and the lesson answer from e2e/road-mocks.ts and e2e/lesson-mocks.ts, so no database is needed. With
// PUHUSCRIBE_EVIDENCE=1 the screenshot goes to factory/jobs/intro-visit/evidence/ (Chromium only).

const OUT = resolve('factory/jobs/intro-visit/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'
const MEET = 'Nice to meet you'
const MINUTE = 60 * 1000

async function shot(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png` })
}

/** The greeting's play() is refused, as an iPhone does without a tap, so no sound plays in the tests. */
async function quietGreeting(target: Page | BrowserContext) {
  await target.addInitScript({
    content: `HTMLMediaElement.prototype.play = function () {
      return Promise.reject(new DOMException('blocked', 'NotAllowedError'))
    }`,
  })
}

/** A new visitor's road and a lesson, both answered by the mocks; nothing presses "Nice to meet you" for the test. */
async function openApp(page: Page) {
  await quietGreeting(page)
  const calls = await mockHome(page, { met: false })
  await mockLesson(page)
  await page.goto('/learn')
  return calls
}

const intro = (page: Page) => page.getByRole('button', { name: MEET })
const road = (page: Page) => page.getByRole('list', { name: 'Stops on your road' })

/** The road is showing, and Aleksi's intro is not. */
async function seesRoad(page: Page) {
  await expect(road(page)).toBeVisible()
  await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  await expect(intro(page)).toHaveCount(0)
}

/** From the road, Start into the lesson and leave it, back to the road's address. */
async function lessonAndBack(page: Page) {
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/learn/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it, say it' })).toBeVisible()
  await leaveLesson(page)
  await page.waitForURL((url) => url.pathname === '/learn')
}

test('[intro-visit 1] after "Nice to meet you", going into a lesson and back opens the road, not the intro', async ({
  page,
}) => {
  const calls = await openApp(page)
  await expect(intro(page)).toBeVisible()
  await intro(page).click()
  await seesRoad(page)
  // The visit marker holds only a time, and nothing else is stored.
  expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
  expect(await page.evaluate<number>(STORED_BESIDES_VISIT)).toBe(0)

  await lessonAndBack(page)
  await seesRoad(page)
  expect(calls.guest).toBe(1)
  await shot(page, 'road-after-lesson-375x812')

  // A second lesson and back, and a reload: still the same visit.
  await lessonAndBack(page)
  await seesRoad(page)
  await page.reload()
  await seesRoad(page)
})

test('[intro-visit 2] a fresh open (a new tab, no marker) meets Aleksi again', async ({ page, context }) => {
  await openApp(page)
  await intro(page).click()
  await lessonAndBack(page)
  await seesRoad(page)

  const fresh = await context.newPage()
  await openApp(fresh)
  expect(await fresh.evaluate<string | null>(VISIT_VALUE)).toBeNull()
  await expect(intro(fresh)).toBeVisible()
  await expect(road(fresh)).toHaveCount(0)
})

test('[intro-visit 3] 60 minutes or more without use brings the intro back; under 60 minutes the road opens', async ({
  page,
}) => {
  await openApp(page)
  await intro(page).click()
  await seesRoad(page)

  // The last use was 59 minutes ago: the same visit.
  await page.evaluate(
    `sessionStorage.setItem(${JSON.stringify(VISIT_KEY)}, String(Date.now() - ${String(59 * MINUTE)}))`,
  )
  await page.reload()
  await seesRoad(page)

  // The last use was 60 minutes ago: a new visit.
  await page.evaluate(
    `sessionStorage.setItem(${JSON.stringify(VISIT_KEY)}, String(Date.now() - ${String(60 * MINUTE)}))`,
  )
  await page.reload()
  await expect(intro(page)).toBeVisible()
  await expect(road(page)).toHaveCount(0)
})

test('[intro-visit 5] with sessionStorage blocked, the intro shows, the road and the lesson work, and nothing throws', async ({
  page,
}) => {
  const errors: string[] = []
  page.on('pageerror', (error) => errors.push(error.message))
  await page.addInitScript({
    content: `Object.defineProperty(window, 'sessionStorage', {
      configurable: true,
      get() { throw new DOMException('The operation is insecure.', 'SecurityError') },
    })`,
  })
  await openApp(page)
  // The stand-in works: reaching sessionStorage throws, as with blocked site data.
  expect(
    await page.evaluate<string>(
      `(() => { try { sessionStorage; return 'reachable' } catch { return 'blocked' } })()`,
    ),
  ).toBe('blocked')
  await expect(intro(page)).toBeVisible()
  await intro(page).click()
  await seesRoad(page)
  // No visit can be kept, so the road after a lesson starts a new one, with the intro.
  await lessonAndBack(page)
  await expect(intro(page)).toBeVisible()
  await intro(page).click()
  await seesRoad(page)
  expect(errors).toEqual([])
})
