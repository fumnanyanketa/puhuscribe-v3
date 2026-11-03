import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page, type Route } from '@playwright/test'
import { MOCK_LINES, mockLesson } from './lesson-mocks.ts'

// The evidence of job 16-tutor-step (the tutor, Otso): one screenshot at phone size of each state the
// owner asked to see, with the lesson and the tutor routes answered from mocks. Run it on purpose:
//   PUHUSCRIBE_EVIDENCE=1 npx playwright test e2e/tutor-evidence.spec.ts --project=chromium
// The files go to factory/jobs/16-tutor-step/evidence/. Nothing here holds a secret, and the Finnish
// is the lesson mocks' own short test dialogue, which exists in no app build.

test.skip(process.env.PUHUSCRIBE_EVIDENCE !== '1', 'Evidence is made on purpose (PUHUSCRIBE_EVIDENCE=1).')

const OUT = resolve('factory/jobs/16-tutor-step/evidence')

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

const word = (text: string, after?: string, form?: Record<string, unknown>) => ({
  text,
  ...(after ? { after } : {}),
  ...(form ? { form } : {}),
})

/** Otso's answers, turn by turn, as the Worker sends them after its checks. */
const TURNS = [
  {
    turn: 1,
    closing: false,
    otso: {
      kind: 'ai',
      text: 'Joo, totta kai. Voinks mä maksaa kortilla?',
      words: [
        word('Joo', ','),
        word('totta'),
        word('kai', '.'),
        word('Voinks'),
        word('mä', undefined, {
          lemma: 'minä',
          formName: 'I',
          why: 'Spoken Finnish says mä where books write minä.',
          spoken: 'mä',
          written: 'minä',
        }),
        word('maksaa'),
        word('kortilla', '?'),
      ],
      meaning: 'Yes, of course. Can I pay by card?',
    },
  },
  {
    turn: 2,
    closing: false,
    otso: {
      kind: 'ai',
      text: 'Joo, totta kai.',
      words: [word('Joo', ','), word('totta'), word('kai', '.')],
      meaning: 'Yes, of course.',
    },
  },
  {
    turn: 3,
    closing: true,
    otso: {
      kind: 'ai',
      text: 'Joo, totta kai.',
      words: [word('Joo', ','), word('totta'), word('kai', '.')],
      meaning: 'Yes, of course.',
    },
    tip: {
      spoken: 'Voinks mä maksaa kortilla?',
      written: 'Voinko minä maksaa kortilla?',
      gloss: 'Can I pay by card?',
      spokenAudio: '/audio/a.wav',
      writtenAudio: '/audio/b.wav',
    },
  },
]

async function lesson(page: Page, offer: string, turn: (route: Route, n: number) => Promise<void>) {
  await mockLesson(page, { step: 'say' })
  // The session is in stop 5, so the app asks about Otso's step.
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
    json(route, {
      available: true,
      consent: offer === 'consent' ? 'not_asked' : 'granted',
      guest: offer === 'guest',
      offer,
      speech: true,
      voiceForTutor: true,
    }),
  )
  await page.route('**/api/tutor/consent', (route) => json(route, { consent: 'granted' }))
  let n = 0
  await page.route('**/api/tutor/turn', (route) => {
    n += 1
    return turn(route, n)
  })
  await page.goto('/learn/session')
  await page.evaluate('document.fonts.ready')
}

async function shot(page: Page, name: string) {
  mkdirSync(OUT, { recursive: true })
  await page.waitForTimeout(400)
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage: false })
}

async function reply(page: Page, text: string) {
  await page.getByLabel('Your reply').fill(text)
  await page.getByRole('button', { name: 'Send' }).click()
}

test('Otso: the opening, a reply, the end with the tip', async ({ page }) => {
  await lesson(page, 'ready', (route, n) => json(route, TURNS[n - 1]))
  await expect(page.getByRole('heading', { name: 'Talk with Otso' })).toBeVisible()
  await shot(page, '1-opening')
  await reply(page, 'Ne maksaa neljä euroo.')
  await expect(page.getByText('Yes, of course. Can I pay by card?')).toBeVisible()
  await shot(page, '2-a-reply')
  await reply(page, 'Joo.')
  await expect(page.getByText('3 of 3', { exact: false })).toBeVisible()
  await reply(page, 'Kiitos!')
  await expect(page.getByRole('heading', { name: 'Nicely done' })).toBeVisible()
  await page.getByRole('region', { name: 'One tip' }).scrollIntoViewIfNeeded()
  await shot(page, '3-the-end-with-the-tip')
})

test('Otso: the guest card', async ({ page }) => {
  await lesson(page, 'guest', (route) => json(route, {}, 403))
  await expect(page.getByRole('button', { name: 'Add your email' })).toBeVisible()
  await shot(page, '4-guest-card')
})

test('Otso: the monthly cap stops the chat kindly', async ({ page }) => {
  await lesson(page, 'ready', (route) => json(route, { error: 'tutor_cap' }, 429))
  await reply(page, 'Ne maksaa neljä euroo.')
  await expect(page.getByText('Otso has talked enough for today.', { exact: false })).toBeVisible()
  await shot(page, '5-cap-message')
})

test('Otso: the consent screen', async ({ page }) => {
  await lesson(page, 'consent', (route, n) => json(route, TURNS[n - 1]))
  await expect(page.getByRole('button', { name: 'Talk with Otso' })).toBeVisible()
  await shot(page, '6-consent')
})
