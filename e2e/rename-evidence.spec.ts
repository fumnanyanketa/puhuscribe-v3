import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page, type Route } from '@playwright/test'
import { markIntroSeen } from './intro-seen.ts'
import { MOCK_LINES, mockLesson } from './lesson-mocks.ts'
import { mockHome } from './road-mocks.ts'

// The evidence of job rename-aleksi (owner, 4 November 2026): the main screens at phone size in
// Chromium, after PuhuScribe and Otso became Aleksi. Run it on purpose, against a build made with
// VITE_DESIGN_REFERENCE=1 (the wordmark is drawn on the design page):
//   VITE_DESIGN_REFERENCE=1 npm run build
//   PUHUSCRIBE_EVIDENCE=1 npx playwright test e2e/rename-evidence.spec.ts --project=chromium
// The files go to factory/jobs/rename-aleksi/evidence/. The pages answer from mocks and show only
// the lesson mocks' test lines. Nothing here holds a secret.

test.skip(process.env.PUHUSCRIBE_EVIDENCE !== '1', 'Evidence is made on purpose (PUHUSCRIBE_EVIDENCE=1).')

const OUT = resolve('factory/jobs/rename-aleksi/evidence')

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

async function shot(page: Page, name: string, fullPage = false) {
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage })
}

const EMAIL_ME = { kind: 'email', email: 'alex@example.com' }

async function accountPages(page: Page, path: string, me: Record<string, unknown>) {
  await mockHome(page, { done: { 1: 4, 2: 4, 3: 2 }, me })
  await page.route('**/api/voice', (route) =>
    json(route, { available: true, region: null, processing: 'granted', retention: false, recordings: [] }),
  )
  await page.route('**/api/tutor', (route) =>
    json(route, { available: true, consent: 'granted', guest: false, speech: true, voiceForTutor: true }),
  )
  await page.goto(path)
}

/** A stop 5 session whose last step is the chat, with the tutor state given. */
async function tutorSession(page: Page, state: Record<string, unknown>) {
  await mockLesson(page, { step: 'say' })
  await page.route('**/api/sessions/today', (route) =>
    json(route, {
      state: 'ready',
      session: { id: 's1', step: 'say' },
      unit: { title: 'Unit', canDo: 'Can do.' },
      dialogue: { title: 'Dialogue' },
      stop: 5,
      lines: MOCK_LINES,
    }),
  )
  await page.route('**/api/tutor?session=s1', (route) =>
    json(route, { available: true, speech: true, voiceForTutor: true, ...state }),
  )
  await page.route('**/api/tutor/turn', (route) =>
    json(route, {
      turn: 1,
      closing: false,
      otso: {
        kind: 'ai',
        text: 'Joo, totta kai.',
        words: [{ text: 'Joo', after: ',' }, { text: 'totta' }, { text: 'kai', after: '.' }],
        meaning: 'Yes, of course.',
      },
    }),
  )
  await page.goto('/learn/session')
}

test.beforeEach(async ({ context }) => {
  await markIntroSeen(context)
})

test('home, the road', async ({ page }) => {
  await mockHome(page, { done: { 1: 4, 2: 4, 3: 2 } })
  await page.goto('/learn')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  await page
    .getByRole('button', { name: 'Skip' })
    .click({ timeout: 1500 })
    .catch(() => undefined)
  await shot(page, 'home')
})

test('a lesson, Hear it', async ({ page }) => {
  await mockLesson(page, {})
  await page.goto('/learn/session')
  await expect(page.getByText('How much are those strawberries?').first()).toBeVisible()
  await shot(page, 'lesson')
})

test('the tutor chat', async ({ page }) => {
  await tutorSession(page, { consent: 'granted', guest: false, offer: 'ready' })
  await expect(page.getByRole('heading', { name: 'Talk with Aleksi' })).toBeVisible()
  await page.getByLabel('Your reply').fill('Ne maksaa neljä euroo.')
  await page.getByRole('button', { name: 'Send' }).click()
  await expect(page.getByText('Yes, of course.')).toBeVisible()
  await shot(page, 'tutor-chat')
})

test('the tutor consent screen', async ({ page }) => {
  await tutorSession(page, { consent: 'not_asked', guest: false, offer: 'consent' })
  await expect(page.getByRole('button', { name: 'Talk with Aleksi' })).toBeVisible()
  await shot(page, 'tutor-consent', true)
})

test('the tutor guest card', async ({ page }) => {
  await tutorSession(page, { consent: 'not_asked', guest: true, offer: 'guest' })
  await expect(page.getByRole('heading', { name: 'Talk with Aleksi' })).toBeVisible()
  await shot(page, 'tutor-guest')
})

test('the account page, signed in', async ({ page }) => {
  await accountPages(page, '/learn/account', EMAIL_ME)
  await expect(page.getByText('Talk with Aleksi')).toBeVisible()
  await shot(page, 'account', true)
})

test('the create account page', async ({ page }) => {
  await accountPages(page, '/learn/account/email', { kind: 'guest' })
  await shot(page, 'create-account', true)
})

test('the privacy notice, with the tutor detail and the full notice open', async ({ page }) => {
  await accountPages(page, '/learn/privacy', { kind: 'guest' })
  await shot(page, 'privacy-first-layer', true)
  await page.getByRole('button', { name: 'More about Aleksi' }).click()
  await page.getByRole('button', { name: 'Read the full notice' }).click()
  await shot(page, 'privacy-full', true)
})

test('the landing page', async ({ page }) => {
  await page.goto('/')
  await shot(page, 'landing-top')
  // The pictures load lazily and the sections fade in as they scroll into view, so scroll down a
  // screen at a time before the full page picture.
  for (let y = 0; y < 8000; y += 600) {
    await page.evaluate(`window.scrollTo(0, ${String(y)})`)
    await page.waitForTimeout(150)
  }
  await page.waitForTimeout(600)
  await shot(page, 'landing-full', true)
  const chat = page.getByRole('heading', { name: 'Practise a real chat without the nerves' })
  await chat.scrollIntoViewIfNeeded()
  await page.evaluate('window.scrollBy(0, -40)')
  await shot(page, 'landing-chat-section')
})

test('the wordmark on the design reference page', async ({ page }) => {
  await page.goto('/design-reference')
  await expect(page.getByRole('img', { name: 'Aleksi', exact: true })).toBeVisible()
  await page.getByRole('img', { name: 'Aleksi', exact: true }).screenshot({ path: `${OUT}/wordmark.png` })
})
