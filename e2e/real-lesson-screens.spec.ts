import { createHash } from 'node:crypto'
import { mkdirSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { markIntroSeen } from './intro-seen.ts'
import { stubMicrophone } from './microphone.ts'

// Screenshots of the real stop 1, lesson 1, for the owner's screen review (7 November 2026). It runs only
// in .github/workflows/real-screens.yml, against a local Worker on the TEST project, as a new guest. Nothing
// is mocked except the speech check's answer (the runner has no speech service) and the microphone, which
// plays a tone. Every other screen, word and line is the real app and the real lesson.

test.skip(process.env.PUHUSCRIBE_REAL_SCREENS !== '1', 'Runs only in the real-screens workflow.')
test.use({ deviceScaleFactor: 2 })

const OUT = resolve('real-screens')

test('stop 1, lesson 1, every screen', async ({ page }) => {
  test.setTimeout(240_000)
  mkdirSync(OUT, { recursive: true })
  await stubMicrophone(page, 'tone')
  await page.route('**/api/speech/say', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ feedbackClass: 'clear' }),
    }),
  )
  // The meaning of each line, from the real session answer, to pick the right answer in Understand it.
  const gloss = new Map<string, string>()
  page.on('response', async (response) => {
    if (!response.url().includes('/api/sessions/today')) return
    try {
      const body = (await response.json()) as { lines?: { id: number | string; gloss?: string }[] }
      for (const line of body.lines ?? []) gloss.set(String(line.id), String(line.gloss ?? ''))
    } catch {
      // Not JSON: nothing to learn from it.
    }
  })

  let n = 0
  let lastHash = ''
  const shot = async (label: string, force = false) => {
    await page.waitForTimeout(450)
    const text = await page.evaluate<string>('document.body.innerText')
    const hash = createHash('sha1').update(text).digest('hex')
    if (!force && hash === lastHash) return
    lastHash = hash
    n += 1
    await page.screenshot({ path: join(OUT, `${String(n).padStart(2, '0')}-${label}.png`) })
  }
  const visible = async (loc: ReturnType<Page['locator']>) =>
    loc
      .first()
      .isVisible()
      .catch(() => false)
  const button = (name: string | RegExp, exact = true) =>
    page.getByRole('button', typeof name === 'string' ? { name, exact } : { name })

  await markIntroSeen(page)
  await page.goto('/learn')
  await expect(button('Start')).toBeVisible({ timeout: 20_000 })
  await page.waitForTimeout(2500)
  await shot('road')
  await button('Start').click()
  await expect(page.getByRole('heading', { level: 1, name: /^This is stop \d+, / })).toBeVisible({
    timeout: 15_000,
  })
  await shot('stop-screen')
  await button('Continue').click()
  await page.waitForURL('**/session', { timeout: 20_000 })
  await page.waitForTimeout(1200)

  let wordCardDone = false
  const recorded = new Set<string>()
  for (let i = 0; i < 140; i++) {
    const h1 =
      (await page
        .locator('h1')
        .first()
        .textContent()
        .catch(() => '')) ?? ''
    const step = h1
      .trim()
      .toLowerCase()
      .replace(/[^a-z]+/g, '-')
    await shot(step || 'screen')

    if (await visible(page.getByText('Now you can say this.'))) break

    const consent = page.getByRole('dialog', { name: 'Say it out loud' })
    if (await visible(consent)) {
      await consent.getByRole('button', { name: /Turn on/ }).click()
      continue
    }
    if (await visible(button('Got it'))) {
      await button('Got it').click()
      continue
    }
    // The word card, once, on the first line that has a tappable word.
    if (!wordCardDone && step.includes('hear')) {
      const word = page
        .locator('[data-line-id] button')
        .filter({ hasNotText: /play|pause/i })
        .first()
      if (await visible(word)) {
        wordCardDone = true
        await word.click()
        await page.waitForTimeout(600)
        await shot('word-card', true)
        const close = page.getByRole('button', { name: 'Close' })
        if (await visible(close)) await close.click()
        else await page.keyboard.press('Escape')
        await page.waitForTimeout(500)
        continue
      }
    }
    // Understand it: the right meaning, then Next.
    const question = page.getByRole('heading', { level: 2, name: 'What does this mean?' })
    if (await visible(question)) {
      const status = page.getByRole('status')
      if (
        !/right/i.test(
          (await status
            .first()
            .textContent()
            .catch(() => '')) ?? '',
        )
      ) {
        const id =
          (await page
            .locator('[data-question-line]')
            .first()
            .getAttribute('data-question-line')
            .catch(() => '')) ?? ''
        const list = page.getByRole('list', { name: 'What does this mean?' })
        const right = gloss.get(id)
        const choice = right
          ? list.getByRole('button', { name: right, exact: true })
          : list.getByRole('button').first()
        await choice.first().click()
        await page.waitForTimeout(500)
        await shot('understand-it-answered', true)
        if (await visible(button('Next'))) await button('Next').click()
        continue
      }
    }
    // Recording: once per line on each step.
    const record = button('Record yourself saying the line')
    if (await visible(record)) {
      const line =
        (await page
          .locator('[data-line-id]')
          .first()
          .getAttribute('data-line-id')
          .catch(() => '')) ?? String(i)
      const key = `${step}:${line}`
      if (!recorded.has(key)) {
        recorded.add(key)
        await record.click()
        await page.waitForTimeout(1300)
        await shot(`${step}-listening`, true)
        await button(/^Stop recording/)
          .first()
          .click()
        await page.waitForTimeout(1800)
        await shot(`${step}-result`, true)
        continue
      }
    }
    if (await visible(button("I don't remember"))) {
      await button("I don't remember").click()
      continue
    }
    let moved = false
    for (const name of ['Next line', 'Continue', 'Next', 'Done']) {
      const b = button(name)
      if ((await visible(b)) && (await b.first().isEnabled())) {
        await b.first().click()
        moved = true
        break
      }
    }
    if (!moved) {
      await page.waitForTimeout(800)
    }
  }
  await shot('finished', true)
})
