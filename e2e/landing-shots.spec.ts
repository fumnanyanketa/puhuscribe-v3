import { mkdirSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { expect, test, type Page, type Route } from '@playwright/test'
import { markIntroSeen } from './intro-seen.ts'
import { MOCK_LINES, mockLesson } from './lesson-mocks.ts'
import { stubMicrophone } from './microphone.ts'

// The landing page's pictures (job 17-landing-page): real screens of the app at phone size and
// device scale 2, answered from the lesson mocks, written as WebP files to public/landing/. Run it
// on purpose, in Chromium, against a build made with VITE_DESIGN_REFERENCE=1 (the island screen is
// the design page /sample/island):
//   VITE_DESIGN_REFERENCE=1 npm run build
//   PUHUSCRIBE_LANDING_SHOTS=1 npx playwright test e2e/landing-shots.spec.ts --project=chromium
// The Finnish in them is the lesson mocks' short test dialogue and the approved island lines, as in
// the owner's approved design. Nothing here holds a secret.

test.skip(process.env.PUHUSCRIBE_LANDING_SHOTS !== '1', 'The landing pictures are made on purpose.')
test.use({ deviceScaleFactor: 2, reducedMotion: 'reduce' })

const OUT = resolve('public/landing')

interface Clip {
  x: number
  y: number
  width: number
  height: number
}

/** Encodes a PNG as WebP at the given width, in the page's own browser (no extra package). */
async function writeWebp(page: Page, png: Buffer, name: string, width: number) {
  // A string, so this file needs no DOM types (the e2e folder is type checked for Node).
  const data = await page.evaluate<{ url: string; height: number }>(`(async () => {
    const image = new Image()
    image.src = 'data:image/png;base64,${png.toString('base64')}'
    await image.decode()
    const height = Math.round((image.naturalHeight * ${String(width)}) / image.naturalWidth)
    const canvas = document.createElement('canvas')
    canvas.width = ${String(width)}
    canvas.height = height
    const context = canvas.getContext('2d')
    context.imageSmoothingQuality = 'high'
    context.drawImage(image, 0, 0, ${String(width)}, height)
    return { url: canvas.toDataURL('image/webp', 0.82), height }
  })()`)
  mkdirSync(OUT, { recursive: true })
  writeFileSync(join(OUT, name), Buffer.from(data.url.split(',')[1] ?? '', 'base64'))
  console.log(`${name}: ${String(width)} x ${String(data.height)}`)
}

async function shoot(page: Page, name: string, width: number, clip?: Clip) {
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(600)
  const png = await page.screenshot(clip ? { clip } : {})
  await page.goto('about:blank')
  await writeWebp(page, png, name, width)
}

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

/** A card cut from a screen: 351 x 538 px from 12 px left, starting a little above the element. */
function cardClip(top: number): Clip {
  return { x: 12, y: Math.max(0, top - 14), width: 351, height: 538 }
}

async function sayIt(page: Page) {
  await stubMicrophone(page, 'tone')
  await mockLesson(page, { step: 'understand' })
  await page.goto('/learn/session')
  await expect(page.getByRole('button', { name: 'Record yourself saying the line' })).toBeVisible()
}

async function otso(page: Page) {
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
    json(route, {
      available: true,
      consent: 'granted',
      guest: false,
      offer: 'ready',
      speech: true,
      voiceForTutor: true,
    }),
  )
  const word = (text: string, after?: string, form?: Record<string, unknown>) => ({
    text,
    ...(after ? { after } : {}),
    ...(form ? { form } : {}),
  })
  await page.route('**/api/tutor/turn', (route) =>
    json(route, {
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
    }),
  )
  await page.goto('/learn/session')
  await expect(page.getByRole('heading', { name: 'Talk with Aleksi' })).toBeVisible()
  await page.getByLabel('Your reply').fill('Ne maksaa neljä euroo.')
  await page.getByRole('button', { name: 'Send' }).click()
  await expect(page.getByText('Yes, of course. Can I pay by card?')).toBeVisible()
}

test.beforeEach(async ({ context }) => {
  await markIntroSeen(context)
})

test('[landing] Hear it, the top of the screen', async ({ page }) => {
  await mockLesson(page, {})
  await page.goto('/learn/session')
  await expect(page.getByText('How much are those strawberries?').first()).toBeVisible()
  await shoot(page, 'hear-it.webp', 600, { x: 0, y: 0, width: 375, height: 420 })
})

test('[landing] Say it, clear', async ({ page }) => {
  await sayIt(page)
  await page.route('**/api/speech/say', (route) => json(route, { feedbackClass: 'clear' }))
  await page.getByRole('button', { name: 'Record yourself saying the line' }).click()
  await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
  await page.waitForTimeout(1200)
  await page.getByRole('button', { name: /^Stop recording/ }).click()
  await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible({ timeout: 10_000 })
  await shoot(page, 'say-it.webp', 600)
})

test('[landing] Say it, the line card and the microphone (hero card)', async ({ page }) => {
  await sayIt(page)
  // The line is hidden until the learner asks for it; the card shows it, as after that tap.
  await page.getByRole('button', { name: 'Show the Finnish' }).click()
  await page.waitForTimeout(400)
  const card = await page.getByText('Pekka').first().boundingBox()
  await shoot(page, 'hero-say-it.webp', 500, cardClip((card?.y ?? 80) - 14))
})

test('[landing] The language island', async ({ page }) => {
  await page.goto('/sample/island')
  await page.locator('input').first().fill('Ada')
  await page.getByText('Nigeriasta', { exact: true }).click()
  await page.locator('input').first().blur()
  await shoot(page, 'island.webp', 600)
})

test('[landing] Talk with Otso', async ({ page }) => {
  await otso(page)
  await shoot(page, 'otso.webp', 600)
})

test('[landing] Talk with Otso (hero card)', async ({ page }) => {
  await otso(page)
  const heading = await page.getByRole('heading', { name: 'Talk with Aleksi' }).boundingBox()
  await shoot(page, 'hero-otso.webp', 500, cardClip(heading?.y ?? 80))
})

test('[landing] Keep it, right', async ({ page }) => {
  await mockLesson(page, { step: 'say', review: true })
  await page.goto('/learn/session')
  await page.locator('input').first().fill('maksaa')
  await page.getByRole('button', { name: 'Check', exact: true }).click()
  await expect(page.locator('[data-review-feedback]')).toBeVisible()
  await shoot(page, 'review.webp', 600)
})
