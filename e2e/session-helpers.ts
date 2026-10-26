import { expect, type Locator, type Page, type Request, type TestInfo } from '@playwright/test'

// Shared steps for the first session browser tests
// (factory/jobs/8-first-session/spec.md). Expected content always comes from
// the database (e2e/db.ts), never from text written here, so the tests also
// pass when job 7's real dialogue is the first one.

/** A short generated tone, never speech: a 16 bit mono WAV (as job 5's reference page). */
export function tone(seconds = 0.6, hertz = 440): Buffer {
  const rate = 8000
  const samples = Math.round(rate * seconds)
  const buffer = Buffer.alloc(44 + samples * 2)
  buffer.write('RIFF', 0, 'ascii')
  buffer.writeUInt32LE(36 + samples * 2, 4)
  buffer.write('WAVE', 8, 'ascii')
  buffer.write('fmt ', 12, 'ascii')
  buffer.writeUInt32LE(16, 16)
  buffer.writeUInt16LE(1, 20)
  buffer.writeUInt16LE(1, 22)
  buffer.writeUInt32LE(rate, 24)
  buffer.writeUInt32LE(rate * 2, 28)
  buffer.writeUInt16LE(2, 32)
  buffer.writeUInt16LE(16, 34)
  buffer.write('data', 36, 'ascii')
  buffer.writeUInt32LE(samples * 2, 40)
  for (let i = 0; i < samples; i += 1) {
    const fade = Math.min(1, i / 400, (samples - i) / 400)
    buffer.writeInt16LE(Math.round(Math.sin((2 * Math.PI * hertz * i) / rate) * 8000 * fade), 44 + i * 2)
  }
  return buffer
}

/** Answers every /audio/ request with the tone and returns the paths asked for. */
export async function serveTone(page: Page, seconds = 0.6): Promise<string[]> {
  const asked: string[] = []
  const body = tone(seconds)
  await page.route('**/audio/**', async (route) => {
    asked.push(new URL(route.request().url()).pathname)
    await route.fulfill({ status: 200, contentType: 'audio/wav', body })
  })
  return asked
}

/** Every request the page makes, except data: and blob: addresses. */
export function recordRequests(page: Page): Request[] {
  const all: Request[] = []
  page.on('request', (request) => {
    if (!/^(data|blob):/.test(request.url())) all.push(request)
  })
  return all
}

export function isGuestPost(request: Request): boolean {
  return request.method() === 'POST' && new URL(request.url()).pathname === '/api/guest'
}

/** Opens the front door, presses Start, and waits for Hear it. */
export async function startSession(page: Page): Promise<void> {
  await page.goto('/')
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
}

/** Shows every line of Hear it and presses Continue. */
export async function finishHearIt(page: Page): Promise<void> {
  for (;;) {
    const next = page.getByRole('button', { name: 'Next line' })
    if ((await next.count()) === 0) break
    await next.click()
  }
  await page.getByRole('button', { name: 'Continue' }).click()
  await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeVisible()
}

/** The line of the question on screen, by its id; empty when no question is shown. */
export async function questionLineId(page: Page): Promise<string> {
  // The question can leave the screen between two reads (the last "Next"
  // opens the finish screen), so the read gives up quickly instead of waiting
  // for an element that will not come back.
  return page
    .locator('[data-question-line]')
    .first()
    .getAttribute('data-question-line', { timeout: 1_000 })
    .then(
      (id) => id ?? '',
      () => '',
    )
}

/** The line shown on the finish screen, by its id. */
export async function finishLineId(page: Page): Promise<string> {
  return (await page.locator('[data-line-id]').first().getAttribute('data-line-id')) ?? ''
}

/** Answers every question right, using each line's meaning from the database. */
/**
 * After "Next" in Understand it: waits for the next question (a different
 * line) or, after the last one, for the next step (Say it, job
 * 10-speaking-feedback, which opens on its consent screen for a new learner).
 * The last "Next" first saves the step, so the old question stays on screen
 * for a moment.
 */
export async function afterNext(page: Page, previousLineId: string): Promise<'done' | 'question'> {
  const done = page
    .getByRole('heading', { level: 1, name: 'Say it' })
    .or(page.getByRole('heading', { level: 1, name: 'Speaking feedback' }))
  const question = page.getByRole('heading', { level: 2, name: 'What does this mean?' })
  const seen: { state: 'done' | 'question' | 'waiting' } = { state: 'waiting' }
  await expect
    .poll(
      async () => {
        if (await done.isVisible()) seen.state = 'done'
        else {
          // Read once: the finish screen has no question, so its id is empty.
          const now = await questionLineId(page)
          if (now !== '' && now !== previousLineId && (await question.isVisible())) seen.state = 'question'
        }
        return seen.state
      },
      { timeout: 10_000 },
    )
    .not.toBe('waiting')
  return seen.state === 'done' ? 'done' : 'question'
}

/** Answers every question right, using each line's meaning from the database. */
export async function finishUnderstandIt(page: Page, glossOf: (lineId: string) => string): Promise<void> {
  for (;;) {
    const lineId = await questionLineId(page)
    await answerChoices(page)
      .getByRole('button', { name: glossOf(lineId), exact: true })
      .click()
    await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
    await page.getByRole('button', { name: 'Next', exact: true }).click()
    if ((await afterNext(page, lineId)) === 'done') return
  }
}

export function answerChoices(page: Page): Locator {
  return page.getByRole('list', { name: 'What does this mean?' })
}

/** True when the page scrolls sideways. */
export async function scrollsSideways(page: Page): Promise<boolean> {
  return page.evaluate<boolean>(
    'document.documentElement.scrollWidth > document.documentElement.clientWidth + 1',
  )
}

/** Focuses a control with the Tab key; WebKit skips buttons on Tab unless a system setting allows it. */
export async function tabTo(page: Page, target: Locator, testInfo: TestInfo): Promise<void> {
  for (let i = 0; i < 60; i += 1) {
    const focused = await expect(target)
      .toBeFocused({ timeout: 50 })
      .then(
        () => true,
        () => false,
      )
    if (focused) return
    await page.keyboard.press('Tab')
  }
  if (testInfo.project.name === 'webkit') {
    await target.focus()
    return
  }
  throw new Error('Tab never reached the control.')
}

// Waits until no animation or transition is still running, so axe measures
// the finished colours. A transition that is cancelled (a button's press or
// focus colour ending before it completes, common in WebKit after a click)
// rejects its `finished` promise with AbortError; a cancelled animation no
// longer affects the page, so it counts as settled. Cancelling one can start
// another, so this checks again until none is left.
export async function settleAnimations(page: Page) {
  await page.evaluate(`(async () => {
    for (let round = 0; round < 10; round++) {
      const running = document.getAnimations().filter((a) => a.playState !== 'finished')
      if (running.length === 0) return
      await Promise.allSettled(running.map((a) => a.finished))
    }
  })()`)
}

/**
 * Say it for a learner who has not turned on speaking feedback (job
 * 10-speaking-feedback, "Done when" 3): "Not now" on the consent screen, then
 * each line out loud with "Next line", and "Continue" to the finish screen.
 */
export async function passSayIt(page: Page, after = 'Now you can say this.'): Promise<void> {
  const notNow = page.getByRole('button', { name: 'Not now', exact: true })
  const next = page.getByRole('button', { name: 'Next line', exact: true })
  const cont = page.getByRole('button', { name: 'Continue', exact: true })
  // Waits until Say it has loaded the learner's voice choices.
  const cantSpeak = page.getByRole('button', { name: "I can't speak right now", exact: true })
  await expect(notNow.or(next).or(cont).or(cantSpeak)).toBeVisible()
  if (await cantSpeak.isVisible()) {
    // Speaking feedback is already on: the quiet exit skips Say it.
    await cantSpeak.click()
    await expect(page.getByRole('heading', { level: 1, name: after })).toBeVisible()
    return
  }
  if (await notNow.isVisible()) await notNow.click()
  await expect(page.getByRole('heading', { level: 1, name: 'Say it' })).toBeVisible()
  for (;;) {
    await expect(next.or(cont)).toBeVisible()
    if (await cont.isVisible()) break
    await next.click()
  }
  await page.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(page.getByRole('heading', { level: 1, name: after })).toBeVisible()
}
