import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { GREETING_AUDIO, MET_KEY, OLD_INTRO_KEY } from '../src/lib/aleksi-intro.ts'
import { mockHome } from './road-mocks.ts'

// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026). Labels name the item of the
// owner's brief. The road answers from e2e/road-mocks.ts, so no database is needed. With
// PUHUSCRIBE_EVIDENCE=1 the screenshots go to factory/jobs/aleksi-intro/evidence/ (Chromium only).

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
const OUT = resolve('factory/jobs/aleksi-intro/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'

async function shot(page: Page, name: string, fullPage = false) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage })
}

/** Counts play() calls and, when `blocked`, refuses them as an iPhone does without a tap. */
async function watchPlay(page: Page, blocked: boolean) {
  await page.addInitScript({
    content: `window.__plays = 0
      window.__sources = []
      const real = HTMLMediaElement.prototype.play
      HTMLMediaElement.prototype.play = function () {
        window.__plays += 1
        window.__sources.push(this.src)
        if (${String(blocked)} && window.__plays === 1)
          return Promise.reject(new DOMException('blocked', 'NotAllowedError'))
        return ${String(blocked)} ? Promise.resolve() : real.call(this).catch(() => undefined)
      }`,
  })
}

const plays = (page: Page) => page.evaluate<number>('window.__plays')

async function openNew(page: Page, today: Record<string, unknown> = { signedIn: false, ended: false }) {
  const calls = await mockHome(page, { met: false, today })
  await page.goto('/learn')
  return calls
}

test('[aleksi-intro 2] a new visitor meets Aleksi first: photo, name, greeting, one line and the button', async ({
  page,
}) => {
  await watchPlay(page, false)
  await openNew(page)
  const main = page.getByRole('main')
  await expect(main.getByRole('img', { name: 'Aleksi, your Finnish tutor' })).toBeVisible()
  await expect(main.getByRole('heading', { level: 1, name: 'Aleksi' })).toBeVisible()
  const finnish = main.getByText('Moi! Mä oon Aleksi.', { exact: true })
  await expect(finnish).toHaveAttribute('lang', 'fi')
  await expect(main.getByText('Hi! I’m Aleksi.', { exact: true })).toBeVisible()
  await expect(main.getByText('I’ll be with you on your Finnish journey.', { exact: true })).toBeVisible()
  await expect(main.getByText('No account needed to start.', { exact: true })).toBeVisible()
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toHaveCount(0)
  // Every control is at least 44 px both ways.
  for (const control of await main.getByRole('button').all()) {
    const box = await control.boundingBox()
    expect(box?.width ?? 0).toBeGreaterThanOrEqual(44)
    expect(box?.height ?? 0).toBeGreaterThanOrEqual(44)
  }
  const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
  expect(axe.violations).toEqual([])
  await shot(page, 'intro-375x812')
})

test('[aleksi-intro 3] the greeting tries once to play when the screen opens, and only once', async ({
  page,
}) => {
  await watchPlay(page, false)
  await openNew(page)
  await expect.poll(() => plays(page)).toBe(1)
  // The try is Harri's clip. Chromium here allows it; Playwright's WebKit blocks it, as an iPhone does.
  const sources = await page.evaluate<string[]>('window.__sources')
  expect(sources.map((url) => new URL(url).pathname)).toEqual([GREETING_AUDIO])
  // No loop: after the greeting the control is ready again and nothing plays a second time.
  await expect(page.getByRole('button', { name: 'Play Aleksi’s greeting' })).toBeVisible({ timeout: 15_000 })
  await page.waitForTimeout(1500)
  expect(await plays(page)).toBe(1)
})

test('[aleksi-intro 3] when the browser blocks the try, nothing breaks and the play button plays it', async ({
  page,
}) => {
  await watchPlay(page, true)
  await openNew(page)
  const play = page.getByRole('button', { name: 'Play Aleksi’s greeting' })
  await expect(play).toBeVisible()
  await expect.poll(() => plays(page)).toBe(1)
  await expect(page.getByText('Could not play.')).toHaveCount(0)
  await play.click()
  expect(await plays(page)).toBe(2)
  await expect(page.getByRole('button', { name: 'Nice to meet you' })).toBeEnabled()
})

test('[aleksi-intro 4] "Nice to meet you" opens the road, marks the phone, and Start goes straight to the lesson', async ({
  page,
}) => {
  await watchPlay(page, true)
  const calls = await openNew(page)
  await page.getByRole('button', { name: 'Nice to meet you' }).click()
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  expect(await page.evaluate<string | null>(`localStorage.getItem(${JSON.stringify(MET_KEY)})`)).toBe('yes')
  await shot(page, 'road-after-intro-375x812')
  // The road keeps "Have an account? Sign in" on the day one card.
  await expect(page.getByRole('link', { name: 'Sign in' })).toBeVisible()
  expect(calls.guest).toBe(0)
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await expect.poll(() => calls.guest).toBe(1)
  await expect(page.getByText('Why are you learning Finnish?')).toHaveCount(0)
})

test('[aleksi-intro 4] a phone that met Aleksi goes straight to the road after a reload', async ({
  page,
}) => {
  await watchPlay(page, true)
  await openNew(page)
  await page.getByRole('button', { name: 'Nice to meet you' }).click()
  await page.reload()
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Nice to meet you' })).toHaveCount(0)
})

test('[aleksi-intro 2] a signed in learner and a guest whose session ended never see the intro', async ({
  page,
}) => {
  await openNew(page, { signedIn: true, today: 'continue' })
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Nice to meet you' })).toHaveCount(0)
  const ended = await page.context().newPage()
  await openNew(ended, { signedIn: false, ended: true })
  await expect(ended.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  await expect(ended.getByRole('button', { name: 'Nice to meet you' })).toHaveCount(0)
})

test('[aleksi-intro 4] the answers of the old first-open questions are cleared from the phone', async ({
  page,
}) => {
  await page.addInitScript({
    content: `try { localStorage.setItem(${JSON.stringify(OLD_INTRO_KEY)}, '{"seen":true,"reason":"work"}') } catch {}`,
  })
  await mockHome(page)
  await page.goto('/learn')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  // The init script writes the key again on every load, so this reads it once the page has cleared it.
  expect(
    await page.evaluate<string | null>(`localStorage.getItem(${JSON.stringify(OLD_INTRO_KEY)})`),
  ).toBeNull()
})

test.describe('narrow and large text', () => {
  test.use({ viewport: { width: 320, height: 640 } })

  test('[aleksi-intro 2] at 320 px wide nothing runs sideways and every word stays reachable', async ({
    page,
  }) => {
    await watchPlay(page, true)
    await openNew(page)
    await expect(page.getByRole('button', { name: 'Nice to meet you' })).toBeVisible()
    expect(await page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')).toBe(
      false,
    )
    await shot(page, 'intro-320x640')
  })

  test('[aleksi-intro 2] with text at 200 percent every word and the button stay on the page', async ({
    page,
  }) => {
    await watchPlay(page, true)
    await openNew(page)
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    expect(await page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')).toBe(
      false,
    )
    const button = page.getByRole('button', { name: 'Nice to meet you' })
    await button.scrollIntoViewIfNeeded()
    await expect(button).toBeInViewport()
    await expect(page.getByText('No account needed to start.')).toBeVisible()
    await shot(page, 'intro-320-text-200', true)
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
