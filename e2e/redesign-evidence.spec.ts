import { mkdirSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { expect, test, type Page } from '@playwright/test'
import { mockLesson, type LessonMocks } from './lesson-mocks.ts'
import { stubMicrophone } from './microphone.ts'
import { mockHome, type HomeMocks } from './road-mocks.ts'

// The evidence of job 19-redesign (statement 48): one screenshot at phone size,
// in each browser, of every screen the drawings show that can be reached
// without a database, each beside a screenshot of the same drawing taken from
// the static page. Run it on purpose:
//   PUHUSCRIBE_EVIDENCE=1 npx playwright test e2e/redesign-evidence.spec.ts
// The files go to factory/jobs/19-redesign/evidence/. Nothing here holds a
// secret: the pages answer from mocks and show only made up text.

test.skip(process.env.PUHUSCRIBE_EVIDENCE !== '1', 'Evidence is made on purpose (PUHUSCRIBE_EVIDENCE=1).')

const OUT = resolve('factory/jobs/19-redesign/evidence')

interface Shot {
  /** The drawing's caption, as in design-drafts/v1-screens.html or road-journey.html. */
  drawing: string
  file: string
  /** Resolves to a picture when the screen is a box on another page (the crash screen), else nothing. */
  run: (page: Page) => Promise<unknown>
}

const slug = (text: string) =>
  text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')

const MID = { 1: 4, 2: 4, 3: 2 }
const SIGNED_IN = { signedIn: true, today: 'continue' }

async function road(page: Page, mocks: HomeMocks, skip = true) {
  await mockHome(page, mocks)
  await page.goto('/')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  if (skip)
    await page
      .getByRole('button', { name: 'Skip' })
      .click({ timeout: 1500 })
      .catch(() => undefined)
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(900)
}

async function lesson(page: Page, mocks: LessonMocks, path = '/session') {
  await mockLesson(page, mocks)
  await page.goto(path)
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(500)
}

async function pages(page: Page, path: string, me: Record<string, unknown> = { kind: 'guest' }) {
  await mockHome(page, { done: MID, me })
  await page.route('**/api/voice', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        available: true,
        region: null,
        processing: 'granted',
        retention: false,
        recordings: [],
      }),
    }),
  )
  await page.goto(path)
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
}

/** Keep it with one typed answer, checked by the mock. */
async function keepItAnswer(page: Page, text: string) {
  await lesson(page, { step: 'say', review: true })
  await page.locator('input').first().fill(text)
  await page.getByRole('button', { name: 'Check', exact: true }).click()
  await expect(page.locator('[data-review-feedback]')).toBeVisible()
  await page.waitForTimeout(600)
}

/** Say it after one recorded try (a generated tone, never a voice) that the speech check answers with the given class. */
async function sayItResult(page: Page, feedbackClass: string) {
  await stubMicrophone(page, 'tone')
  await lesson(page, { step: 'understand' })
  await page.route('**/api/speech/say', (route) =>
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ feedbackClass }) }),
  )
  await page.getByRole('button', { name: 'Record yourself saying the line' }).click()
  await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
  await page.waitForTimeout(1200)
  await page.getByRole('button', { name: /^Stop recording/ }).click()
  await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible({ timeout: 10_000 })
  await page.waitForTimeout(600)
}

const SHOTS: Shot[] = [
  {
    drawing: 'Opening',
    file: 'loading',
    run: async (page) => {
      await mockHome(page, { roadDelayMs: 4000 })
      await page.goto('/')
      await page.waitForTimeout(600)
    },
  },
  { drawing: 'Journey, day one', file: 'road-day-one', run: (page) => road(page, {}) },
  {
    drawing: 'Journey, three stops later',
    file: 'road-continue',
    run: (page) => road(page, { today: SIGNED_IN, done: MID }),
  },
  {
    drawing: 'Stop finished',
    file: 'road-stop-finished',
    run: (page) => road(page, { today: { signedIn: true, today: 'start' }, done: { 1: 4, 2: 4, 3: 4 } }),
  },
  {
    drawing: 'Review waiting',
    file: 'road-review',
    run: (page) => road(page, { today: { signedIn: true, today: 'review', reviewCount: 14 }, done: MID }),
  },
  {
    drawing: 'Done for today',
    file: 'road-done',
    run: (page) =>
      road(page, {
        today: { signedIn: true, today: 'all_done', nextReview: { today: '2026-11-01', day: '2026-11-02' } },
        done: MID,
      }),
  },
  { drawing: 'Hear it, first time', file: 'hear-it-tip', run: (page) => lesson(page, { firstLesson: true }) },
  {
    drawing: 'Word card',
    file: 'word-card',
    run: async (page) => {
      await lesson(page, {})
      await page.locator('[data-line-id]').getByRole('button', { name: 'noi', exact: true }).click()
      await page.waitForTimeout(500)
    },
  },
  { drawing: 'Understand it', file: 'understand-it', run: (page) => lesson(page, { step: 'hear' }) },
  {
    drawing: 'Speaking, first time',
    file: 'speaking-first-time',
    run: (page) => lesson(page, { step: 'understand', processing: 'not_asked' }),
  },
  { drawing: 'Say it', file: 'say-it', run: (page) => lesson(page, { step: 'understand' }) },
  {
    drawing: 'Leave the lesson?',
    file: 'leave-the-lesson',
    run: async (page) => {
      await lesson(page, {})
      await page.getByRole('button', { name: 'Leave session' }).click()
      await page.waitForTimeout(500)
    },
  },
  {
    drawing: 'C. The new words themselves',
    file: 'lesson-finished',
    run: (page) => lesson(page, { step: 'say', newWords: 11, saveNote: 'first' }),
  },
  {
    drawing: 'C, signed in',
    file: 'lesson-finished-signed-in',
    run: (page) =>
      lesson(page, { step: 'say', newWords: 11, me: { kind: 'email', email: 'alex@example.com' } }),
  },
  { drawing: 'Your account, guest', file: 'account-guest', run: (page) => pages(page, '/account') },
  {
    drawing: 'Your account, signed in',
    file: 'account-signed-in',
    run: (page) => pages(page, '/account', { kind: 'email', email: 'alex@example.com' }),
  },
  { drawing: 'Create account', file: 'create-account', run: (page) => pages(page, '/account/email') },
  {
    drawing: 'Enter the code',
    file: 'enter-the-code',
    run: async (page) => {
      await pages(page, '/account/email')
      await page.route('**/api/account/email', (route) =>
        route.fulfill({ status: 200, contentType: 'application/json', body: '{"sent":true}' }),
      )
      await page.getByLabel('Email address').fill('alex@example.com')
      await page.getByRole('button', { name: 'Send code' }).click()
      await page.getByLabel('6 digit code').fill('4719')
      await page.waitForTimeout(300)
    },
  },
  { drawing: 'Sign in', file: 'sign-in', run: (page) => pages(page, '/sign-in', { kind: 'none' }) },
  { drawing: 'Voice settings', file: 'voice-settings', run: (page) => pages(page, '/voice') },
  {
    drawing: 'Download my data',
    file: 'download-ready',
    run: async (page) => {
      await pages(page, '/account')
      await page.route('**/api/account/export', (route) =>
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          headers: { 'content-disposition': 'attachment; filename="puhuscribe-data.json"' },
          body: '{}',
        }),
      )
      await page.getByRole('button', { name: 'Download my data' }).click()
      await page.waitForTimeout(600)
    },
  },
  { drawing: 'Delete my account', file: 'delete-my-account', run: (page) => pages(page, '/account/delete') },
  { drawing: 'Privacy notice', file: 'privacy-notice', run: (page) => pages(page, '/privacy') },
  { drawing: 'Send feedback', file: 'send-feedback', run: (page) => pages(page, '/feedback?from=account') },
  {
    drawing: 'No internet',
    file: 'no-connection',
    run: async (page) => {
      await mockHome(page, { roadFails: 0 })
      await page.goto('/')
      await page.waitForTimeout(500)
    },
  },
  {
    drawing: 'Keep it',
    file: 'keep-it',
    run: async (page) => {
      await lesson(page, { step: 'say', review: true })
      await page.locator('input').first().focus()
      await page.waitForTimeout(300)
    },
  },
  {
    drawing: 'Keep it, right',
    file: 'keep-it-right',
    run: (page) => keepItAnswer(page, 'maksaa'),
  },
  {
    drawing: 'Keep it, close',
    file: 'keep-it-close',
    run: (page) => keepItAnswer(page, 'maksa'),
  },
  {
    drawing: 'Something went wrong',
    file: 'something-went-wrong',
    run: async (page) => {
      // The crash screen is shown on the reference page, in its own box (a render error cannot be made on purpose in the app).
      await page.goto('/design-reference')
      await page.evaluate('document.fonts.ready')
      const box = page.locator('[data-crash-screen]')
      await box.scrollIntoViewIfNeeded()
      await page.waitForTimeout(300)
      return box.screenshot()
    },
  },
  {
    drawing: 'Say it, listening',
    file: 'say-it-listening',
    run: async (page) => {
      await stubMicrophone(page, 'tone')
      await lesson(page, { step: 'understand' })
      await page.getByRole('button', { name: 'Record yourself saying the line' }).click()
      await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
      await page.waitForTimeout(900)
    },
  },
  {
    drawing: 'Say it, clear',
    file: 'say-it-clear',
    run: (page) => sayItResult(page, 'clear'),
  },
  {
    drawing: 'Say it, try again',
    file: 'say-it-try-again',
    run: (page) => sayItResult(page, 'try_again'),
  },
]

test.describe('the app screens', () => {
  for (const [index, shot] of SHOTS.entries()) {
    test(`[redesign 48] ${shot.drawing}`, async ({ page, browserName }, testInfo) => {
      // Recording needs a secure page, and the local WebKit build runs the page over plain http, so the
      // three recording states are taken in Chromium here. Both browsers run them in the GitHub checks
      // (e2e/speaking-feedback.spec.ts) and the reference page shows each state.
      test.skip(
        browserName === 'webkit' && shot.drawing.startsWith('Say it, '),
        'The local WebKit page is not a secure page, so it cannot record.',
      )
      mkdirSync(OUT, { recursive: true })
      const taken = await shot.run(page)
      const name = `${String(index + 1).padStart(2, '0')}-${shot.file}-app-${testInfo.project.name}.png`
      if (Buffer.isBuffer(taken)) writeFileSync(join(OUT, name), taken)
      else await page.screenshot({ path: join(OUT, name) })
    })
  }
})

// The same screens on a short phone and with large text (round 2, design review): 375 x 667, and 320 px
// wide with text at 200 percent. They show that the card never covers the sign, nothing scrolls sideways
// and the content clears the landscape.
const SMALL_SCREENS = [
  'road-day-one',
  'road-continue',
  'hear-it-tip',
  'understand-it',
  'say-it',
  'keep-it',
  'lesson-finished',
  'account-guest',
  'create-account',
  'voice-settings',
  'privacy-notice',
  'send-feedback',
]
const SMALL_SIZES = [
  { width: 375, height: 667, text: '100%', label: '375x667' },
  { width: 320, height: 640, text: '200%', label: '320x640-text-200' },
] as const

test.describe('the app screens on a short phone and with large text', () => {
  for (const [index, shot] of SHOTS.entries()) {
    if (!SMALL_SCREENS.includes(shot.file)) continue
    for (const size of SMALL_SIZES) {
      test(`[redesign 48] ${shot.drawing}, ${size.label}`, async ({ page }, testInfo) => {
        mkdirSync(OUT, { recursive: true })
        await page.setViewportSize({ width: size.width, height: size.height })
        await shot.run(page)
        if (size.text !== '100%') {
          await page.addStyleTag({ content: `html { font-size: ${size.text} !important; }` })
          await page.waitForTimeout(500)
        }
        const name = `${String(index + 1).padStart(2, '0')}-${shot.file}-${size.label}-${testInfo.project.name}.png`
        await page.screenshot({ path: join(OUT, name) })
      })
    }
  }
})

// The same drawings, taken from the static pages. One set (Chromium) is enough: they do not change.
test.describe('the drawings', () => {
  test('[redesign 48] each drawing, from the static page', async ({ page, browserName }) => {
    test.skip(browserName !== 'chromium', 'The drawings are taken once.')
    mkdirSync(OUT, { recursive: true })
    const taken = new Set<string>()
    for (const file of ['v1-screens', 'road-journey', 'numbers-question']) {
      await page.goto(pathToFileURL(resolve(`design-drafts/${file}.html`)).href)
      await page.waitForTimeout(800)
      for (const figure of await page.locator('figure').all()) {
        const caption = (
          (await figure
            .locator('figcaption b')
            .first()
            .textContent()
            .catch(() => '')) ?? ''
        ).trim()
        const match = SHOTS.findIndex((shot) => shot.drawing.toLowerCase() === caption.toLowerCase())
        if (match < 0 || taken.has(caption)) continue
        taken.add(caption)
        const name = `${String(match + 1).padStart(2, '0')}-${slug(SHOTS[match]?.file ?? caption)}-drawing.png`
        await figure
          .locator('.phone')
          .first()
          .screenshot({ path: join(OUT, name) })
      }
    }
    expect(taken.size).toBeGreaterThan(5)
  })
})
