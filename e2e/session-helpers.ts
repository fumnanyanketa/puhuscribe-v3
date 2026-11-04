import { expect, type Locator, type Page, type Request, type TestInfo } from '@playwright/test'
import { TURNSTILE_SCRIPT } from './road-route.ts'

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

/**
 * The first step's name. Since the owner's fast route hear-and-say (3 November 2026) the session opens on
 * "Hear it, say it" (each line heard, then said back), and the old Say it is the short "Recap".
 */
export const FIRST_STEP = 'Hear it, say it'
export const RECAP_STEP = 'Recap'

/**
 * Opens the front door, presses Start, and waits for Hear it, say it. The tip on a first lesson has its own
 * tests (e2e/redesign-lesson.spec.ts) and so has the speaking consent sheet (e2e/speaking-feedback.spec.ts);
 * the others start with the tip closed and "Not now" answered, unless `consent: 'open'` keeps the sheet.
 */
export async function startSession(
  page: Page,
  options: { consent?: 'not now' | 'open' } = {},
): Promise<void> {
  await page.goto('/learn')
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: FIRST_STEP })).toBeVisible()
  await dismissTip(page)
  if (options.consent !== 'open') await declineConsent(page)
}

/** "Not now" on the speaking consent sheet when it is open (job 10-speaking-feedback, "Done when" 3). */
export async function declineConsent(page: Page): Promise<void> {
  await sheetsSettled(page)
  const consent = page.getByRole('dialog', { name: 'Say it out loud' })
  if (await consent.isVisible()) {
    await consent.getByRole('button', { name: 'Not now', exact: true }).click()
    await expect(consent).toBeHidden()
  }
}

/**
 * Waits until the screen has decided which sheet it shows. Say it asks for the voice settings first and says
 * "Loading speaking feedback." until they are known; then the consent sheet may open. A sheet opens in an
 * effect right after the screen is drawn, so the wait also lets two frames pass. One look with `isVisible()`
 * could come a moment too early and miss the sheet (a race in round 3, found by the evaluator).
 */
export async function sheetsSettled(page: Page): Promise<void> {
  await expect(page.getByText('Loading speaking feedback.')).toHaveCount(0)
  await page.evaluate(
    '(() => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve))))()',
  )
}

/**
 * The tip on a learner's first lesson (job 19-redesign, statement 25): "Got it"
 * closes it. Most tests are about something else and start with it closed.
 */
export async function dismissTip(page: Page): Promise<void> {
  await sheetsSettled(page)
  const gotIt = page.getByRole('button', { name: 'Got it' })
  if (await gotIt.isVisible()) {
    await gotIt.click()
    await expect(gotIt).toBeHidden()
  }
}

/**
 * The cross opens "Leave this lesson?"; "Leave" goes to the road (job 19-redesign, statement 22).
 * The first lesson tip and the speaking consent sheet are modal, so the cross cannot be pressed
 * until they are closed ("Got it", "Not now"). On the finish screen nothing is lost, so the cross
 * is a link that leaves at once.
 */
export async function leaveLesson(page: Page): Promise<void> {
  await dismissTip(page)
  await sheetsSettled(page)
  const consent = page.getByRole('dialog', { name: 'Say it out loud' })
  if (await consent.isVisible()) await consent.getByRole('button', { name: 'Not now' }).click()
  const link = page.getByRole('link', { name: 'Leave session' })
  if ((await link.count()) > 0) {
    await link.click()
    return
  }
  await page.getByRole('button', { name: 'Leave session' }).click()
  await page
    .getByRole('dialog', { name: 'Leave this lesson?' })
    .getByRole('button', { name: 'Leave' })
    .click()
}

/**
 * Goes through every line of Hear it, say it without recording and presses Continue: "Not now" on the
 * consent sheet, or "I can't speak right now" when speaking feedback is on, then "Next line" on each line.
 */
export async function finishHearIt(page: Page): Promise<void> {
  await expect(page.getByRole('heading', { level: 1, name: FIRST_STEP })).toBeVisible()
  await dismissTip(page)
  await declineConsent(page)
  const next = page.getByRole('button', { name: 'Next line', exact: true })
  const cont = page.getByRole('button', { name: 'Continue', exact: true })
  const cantSpeak = page.getByRole('button', { name: "I can't speak right now", exact: true })
  await expect(next.or(cont).or(cantSpeak).first()).toBeVisible()
  if (await cantSpeak.isVisible()) await cantSpeak.click()
  for (;;) {
    await expect(next.or(cont).first()).toBeVisible()
    if (await cont.isVisible()) break
    await next.click()
  }
  await cont.click()
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
 * line) or, after the last one, for the next step (the Recap, which may open
 * on the speaking consent sheet when it was not answered on this page).
 * The last "Next" first saves the step, so the old question stays on screen
 * for a moment.
 */
export async function afterNext(page: Page, previousLineId: string): Promise<'done' | 'question'> {
  const done = page
    .getByRole('heading', { level: 1, name: RECAP_STEP })
    .or(page.getByRole('dialog', { name: 'Say it out loud' }))
    .first()
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
 * The Recap (once Say it) for a learner who has not turned on speaking feedback (job
 * 10-speaking-feedback, "Done when" 3): "Not now" on the consent screen when it asks again, then
 * each key line out loud with "Next line", and "Continue" to the finish screen. With speaking
 * feedback on, "I can't speak right now" ends the recap.
 */
export async function passSayIt(page: Page, after = 'Now you can say this.'): Promise<void> {
  const notNow = page.getByRole('button', { name: 'Not now', exact: true })
  const next = page.getByRole('button', { name: 'Next line', exact: true })
  const cont = page.getByRole('button', { name: 'Continue', exact: true })
  // Waits until Say it has loaded the learner's voice choices.
  const cantSpeak = page.getByRole('button', { name: "I can't speak right now", exact: true })
  await expect(notNow.or(next).or(cont).or(cantSpeak).first()).toBeVisible()
  if (await cantSpeak.isVisible()) {
    // Speaking feedback is already on: the quiet exit skips Say it.
    await cantSpeak.click()
    await expect(page.getByRole('heading', { level: 1, name: after })).toBeVisible()
    return
  }
  if (await notNow.isVisible()) await notNow.click()
  await expect(page.getByRole('heading', { level: 1, name: RECAP_STEP })).toBeVisible()
  for (;;) {
    await expect(next.or(cont).first()).toBeVisible()
    if (await cont.isVisible()) break
    await next.click()
  }
  await page.getByRole('button', { name: 'Continue', exact: true }).click()
  await expect(page.getByRole('heading', { level: 1, name: after })).toBeVisible()
}

/**
 * Cloudflare Turnstile's script (e2e/road-route.ts): the one outside address a new guest's Start reaches,
 * since the turnstile job (owner's choice of 3 November 2026). Tests of "every request stays on the app's
 * address" leave out this one request.
 */
export function isTurnstileScript(url: string): boolean {
  return url.startsWith(TURNSTILE_SCRIPT)
}
