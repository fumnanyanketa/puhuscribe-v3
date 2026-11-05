import { mkdirSync, readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page } from '@playwright/test'
import { GREETING_AUDIO, JOURNEY_AUDIO, VISIT_KEY } from '../src/lib/aleksi-intro.ts'
import { at, fakeIntroAudio, played, seen, sounded, type Played } from './intro-audio.ts'
import { mockHome, type HomeMocks } from './road-mocks.ts'
import { pressStart } from './road-start.ts'
import { scrollsSideways } from './session-helpers.ts'
import { STORED_BESIDES_VISIT, VISIT_VALUE } from './visit-marker.ts'

// Fast route intro-logo, version E (the owner's changes of 5 November 2026, listed in
// factory/jobs/intro-logo/build.md): the new logo and Aleksi's intro, which plays on its own. Labels
// [intro-logo N] are the numbered "Done when" items:
//   1 the Wordmark draws the new outlined logo (unit tests, and the logo here),
//   2 the intro opens on the logo, with no tap screen,
//   3 it plays on its own with no tap: card, spoken line, written line, road, journey bubble, Start,
//   4 it tries to play the greeting at 0.95 s with no tap,
//   5 when play is refused, the first tap starts the voice,
//   6 Aleksi says only two clips, his spoken greeting and his journey line,
//   7 no clip overlaps another,
//   8 the speaker on his card: its waves pulse while he speaks, "Tap to hear" while a tap is needed; nothing
//     in the intro mutes the sound,
//   9 Skip and reduced motion show the end state at once,
//  10 the intro shows only when the rule says so, and the visit is marked on its end, Skip or Start,
//  11 the old screens are gone ("Nice to meet you", "Play with sound", "Sound on"),
//  12 nothing overflows at 375 x 812 in Chromium and WebKit, nor with text at 200 percent,
//  13 Finnish lines carry lang="fi".
// The road answers from e2e/road-mocks.ts (met: false, so the test meets the intro itself), and the audio is
// the stand-in of e2e/intro-audio.ts unless a test says otherwise. With PUHUSCRIBE_EVIDENCE=1 the screenshots
// go to factory/jobs/intro-logo/evidence/ (Chromium only).

const OUT = resolve('factory/jobs/intro-logo/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'

const SPOKEN = 'Moi! Mä oon Aleksi.'
const WRITTEN = 'Moi! Minä olen Aleksi.'
const MEANING = 'Hi! I’m Aleksi.'
const JOURNEY_FI = 'Ja mä vien sut tälle matkalle.'
const JOURNEY_EN = 'And I’m here to take you on this journey.'
const OLD_TEXTS = [
  'Nice to meet you',
  'No account needed to start.',
  'I’ll be with you on your Finnish journey.',
  'These are the stops I’ll take you through.',
  'Play with sound',
  'Sound on',
  'Sound off',
]
const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
/** The language an element is read in: its nearest lang attribute. */
const LANG_OF = (el: unknown) =>
  (el as { closest: (s: string) => { getAttribute: (n: string) => string | null } | null })
    .closest('[lang]')
    ?.getAttribute('lang') ?? null

/**
 * How late a scene may come, in ms. Timers are never early, but on a busy test machine (4 workers, two
 * browsers) WebKit ran them up to about 0.8 s late; on a quiet run they are under 0.1 s late.
 */
const LATE = 1500

/**
 * Holds the page's clock (timers, Date, performance.now) still from before the page loads, so a scene stays
 * on screen as long as the test needs; `moveOn` runs the intro forward. CSS motion still runs in real time.
 */
async function holdTime(page: Page) {
  await page.clock.install()
  await page.clock.pauseAt(Date.now() + 1000)
  return (ms: number) => page.clock.runFor(ms)
}

/** A returning learner: signed in with email, stop 1 finished. The rule says no intro. */
const RETURNING: HomeMocks = {
  met: false,
  today: { signedIn: true, today: 'start', account: 'email', finishedStop: true },
  done: { 1: 4, 2: 1 },
}

async function shot(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png`, animations: 'allow' })
}

const logo = (page: Page) => page.getByTestId('intro-logo')
const introSkip = (page: Page) => page.locator('button[data-intro-skip]')
const roadList = (page: Page) => page.getByRole('list', { name: 'Stops on your road' })
const start = (page: Page) => page.getByRole('button', { name: 'Start', exact: true })
const bubble = (page: Page) => page.getByTestId('road-bubble')
const speaker = (page: Page) => page.getByTestId('intro-speaker')

/** A new visitor opens the app. */
async function openNew(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, { met: false, ...mocks })
  await page.goto('/learn')
  return calls
}

/** The end state: the road, Aleksi's bubble with his journey line and its play button, and Start. */
async function seesEndState(page: Page) {
  await expect(roadList(page)).toBeVisible()
  await expect(bubble(page)).toBeVisible()
  await expect(bubble(page)).toContainText(JOURNEY_FI)
  await expect(bubble(page)).toContainText(JOURNEY_EN)
  await expect(bubble(page).getByRole('button', { name: 'Play Aleksi’s line' })).toBeVisible()
  await expect(start(page)).toBeVisible()
}

/** The finite animations that are running. */
async function finiteAnimations(page: Page) {
  return page.evaluate<number>(
    `document.getAnimations().filter((a) => Number.isFinite(a.effect.getComputedTiming().endTime) && a.playState === 'running').length`,
  )
}

/** The element's box lies inside the screen, to within a pixel of rounding. */
async function whollyOnScreen(page: Page, part: Locator) {
  const box = await part.boundingBox()
  const size = page.viewportSize()
  if (!box || !size) return false
  return (
    box.x >= -1 && box.y >= -1 && box.x + box.width <= size.width + 1 && box.y + box.height <= size.height + 1
  )
}

test.describe('with motion on', () => {
  test.use({ reducedMotion: 'no-preference' })

  test('[intro-logo 2] [intro-logo 1] the intro opens on the logo, centred on the wash, with no tap screen', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    const moveOn = await holdTime(page)
    await openNew(page)
    await expect(logo(page)).toBeAttached()
    // The outlined wordmark, alone in the middle of the screen, with no text inside the drawing.
    const mark = logo(page).getByRole('img', { name: 'Aleksi', exact: true })
    await expect(mark.locator('text, tspan')).toHaveCount(0)
    await expect(mark.locator('path[data-part="fell"]')).toHaveCount(1)
    await expect(mark.locator('path[data-part="bubble"]')).toHaveCount(1)
    const box = await mark.boundingBox()
    expect(Math.abs((box?.x ?? 0) + (box?.width ?? 0) / 2 - 375 / 2)).toBeLessThan(3)
    expect(Math.abs((box?.y ?? 0) + (box?.height ?? 0) / 2 - 812 / 2)).toBeLessThan(3)
    await shot(page, '2-logo-375x812')
    // No tap screen: the only control is Skip, at least 44 px.
    const buttons = await page.getByRole('button').all()
    expect(buttons).toHaveLength(1)
    await expect(introSkip(page)).toHaveText('Skip')
    const skipBox = await introSkip(page).boundingBox()
    expect(skipBox?.width ?? 0).toBeGreaterThanOrEqual(44)
    expect(skipBox?.height ?? 0).toBeGreaterThanOrEqual(44)
    // The logo wastes no time: it has gone by the time the written line comes in (2.35 s).
    await moveOn(2400)
    await expect(page.getByTestId('intro-written')).toBeVisible()
    await expect(logo(page)).toHaveCount(0)
  })

  test('[intro-logo 3] [intro-logo 10] with no tap at all it plays on its own: card, spoken line, written line, road, bubble, Start', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    // The spoken line, while the greeting plays.
    await expect(page.getByTestId('intro-spoken')).toHaveText(SPOKEN)
    await expect(page.getByTestId('intro-card').getByText('Aleksi', { exact: true })).toBeVisible()
    await expect(page.getByTestId('intro-spoken')).toHaveCSS('opacity', '1')
    await shot(page, '3-spoken-line-375x812')
    // The written line and the meaning, while he is still speaking.
    await expect(page.getByTestId('intro-meaning')).toHaveCSS('opacity', '1', { timeout: 5000 })
    await expect(page.getByTestId('intro-written')).toHaveText(WRITTEN)
    await expect(page.getByTestId('intro-meaning')).toHaveText(`Meaning ${MEANING}`)
    await shot(page, '3-written-line-375x812')
    // The visit is not marked while the intro is still on.
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    await expect(start(page)).toBeVisible({ timeout: 10_000 })
    await seesEndState(page)
    await page.waitForTimeout(300)
    await shot(page, '3-road-journey-bubble-start-375x812')

    // The moments, from the logo: never early, and on time to within a busy machine's lateness.
    const scenes = await seen(page)
    const zero = at(scenes, 'logo')
    const moments: [string, number][] = [
      ['scene:spoken', 650],
      ['scene:written', 2350],
      ['scene:leaving', 4150],
      ['road animation', 4200],
      ['bubble', 4500],
      ['start', 6750],
    ]
    for (const [name, ms] of moments) {
      const when = at(scenes, name) - zero
      expect(when, name).toBeGreaterThanOrEqual(ms - 50)
      expect(when, name).toBeLessThanOrEqual(ms + LATE)
    }
    // [intro-logo 10] The visit is marked when the intro ends: only a time is kept.
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    expect(await page.evaluate<number>(STORED_BESIDES_VISIT)).toBe(0)
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    // Start comes in while the road is still settling; the page is checked once the road has settled (the
    // road's own Skip fades as its top bar comes in, as on every road opening).
    await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0, { timeout: 5000 })
    const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
    expect(axe.violations).toEqual([])
  })

  test('[intro-logo 4] [intro-logo 6] [intro-logo 7] [intro-logo 8] with no tap it plays the greeting at 0.95 s and the journey line at 4.65 s: two clips, never overlapping, never muted', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    const audio: string[] = []
    page.on('request', (request) => {
      const path = new URL(request.url()).pathname
      if (path.startsWith('/audio/')) audio.push(path)
    })
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(speaker(page)).toHaveAttribute('data-state', 'playing', { timeout: 3000 })
    // The waves pulse while he speaks.
    const waves = await speaker(page)
      .locator('path')
      .evaluateAll((paths) =>
        paths.map((p) => (p as unknown as { getAnimations: () => unknown[] }).getAnimations().length),
      )
    expect(waves.filter((n) => n > 0)).toHaveLength(2)
    await shot(page, '8-speaker-playing-375x812')
    await expect(start(page)).toBeVisible({ timeout: 10_000 })
    await page.waitForTimeout(3000)

    const log = await played(page)
    const zero = at(await seen(page), 'logo')
    // Two clips, the spoken greeting and the journey line, each from its start, none muted.
    expect(log.map((entry) => entry.src)).toEqual([GREETING_AUDIO, JOURNEY_AUDIO])
    expect(log.every((entry) => !entry.muted && entry.from === 0 && !entry.refused)).toBe(true)
    const [greeting, journey] = log as [Played, Played]
    expect(greeting.start - zero).toBeGreaterThanOrEqual(950 - 50)
    expect(greeting.start - zero).toBeLessThanOrEqual(950 + LATE)
    expect(journey.start - zero).toBeGreaterThanOrEqual(4650 - 50)
    expect(journey.start - zero).toBeLessThanOrEqual(4650 + LATE)
    // No overlap: the greeting had stopped when the journey line started.
    expect(greeting.end).not.toBeNull()
    expect(journey.start).toBeGreaterThanOrEqual(greeting.end ?? Infinity)
    // The written greeting is never fetched or said.
    expect(audio.filter((path) => path.includes('greeting-written'))).toEqual([])
    // [intro-logo 8] Nothing in the intro mutes the sound: no media element is muted or turned down.
    expect(
      await page.evaluate<boolean>(
        `[...document.querySelectorAll('audio, video')].every((m) => !m.muted && m.volume === 1)`,
      ),
    ).toBe(true)
  })

  test('[intro-logo 5] [intro-logo 8] when play is refused, the speaker says "Tap to hear", and the first tap starts his voice from where the scenes are', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page, { refuseUntilTap: true })
    await openNew(page)
    const pill = speaker(page).getByText('Tap to hear', { exact: true })
    await expect(pill).toBeVisible({ timeout: 3000 })
    await expect(speaker(page)).toHaveAttribute('data-state', 'waiting-for-tap')
    await expect(speaker(page)).toHaveAttribute('aria-hidden', 'true')
    // Not a control: the speaker is not a button and takes no focus.
    expect(await speaker(page).evaluate((el) => (el as unknown as { tagName: string }).tagName)).toBe('SPAN')
    await page.waitForTimeout(400)
    await shot(page, '5-tap-to-hear-375x812')
    // The first tap anywhere: here on the card.
    await page.getByTestId('intro-card').click({ position: { x: 20, y: 20 } })
    await expect(speaker(page)).toHaveAttribute('data-state', 'playing')
    await expect(pill).toHaveCount(0)
    const log = await played(page)
    const resumed = sounded(log)
    expect(resumed).toHaveLength(1)
    expect(resumed[0]?.src).toBe(GREETING_AUDIO)
    // From where the scenes are: part way into the clip, not from its start.
    expect(resumed[0]?.from ?? 0).toBeGreaterThan(0.3)
    expect(resumed[0]?.muted).toBe(false)
    // Later clips play at their time with no tap.
    await expect(start(page)).toBeVisible({ timeout: 10_000 })
    await page.waitForTimeout(3000)
    const after = sounded(await played(page))
    expect(after.map((entry) => entry.src)).toEqual([GREETING_AUDIO, JOURNEY_AUDIO])
    expect(after[1]?.from).toBe(0)
  })

  test('[intro-logo 5] when play is refused and nobody taps, the intro still plays to its end, in silence', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page, { refuseUntilTap: true })
    await openNew(page)
    await expect(start(page)).toBeVisible({ timeout: 12_000 })
    await seesEndState(page)
    expect(sounded(await played(page))).toEqual([])
  })

  test('[intro-logo 9] [intro-logo 10] Skip at the start: the end state at once, no sound, the visit marked', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page)
    await introSkip(page).click()
    await seesEndState(page)
    await expect(start(page)).toBeFocused()
    expect(await finiteAnimations(page)).toBe(0)
    expect(await played(page)).toEqual([])
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    await page.reload()
    await expect(roadList(page)).toBeVisible()
    await expect(logo(page)).toHaveCount(0)
    await expect(bubble(page)).toHaveCount(0)
  })

  test('[intro-logo 9] Skip while the greeting plays: the voice stops at once and the end state shows', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page)
    await expect.poll(async () => sounded(await played(page)).length).toBe(1)
    await introSkip(page).click()
    await seesEndState(page)
    await expect(start(page)).toBeFocused()
    const [greeting] = sounded(await played(page))
    expect(greeting?.end).not.toBeNull()
    await page.waitForTimeout(5000)
    expect(sounded(await played(page))).toHaveLength(1)
  })

  test('[intro-logo 9] Skip on the road, while it draws: the end state at once', async ({ page }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(page.locator('main[data-intro="on"]')).toBeAttached({ timeout: 8000 })
    await page.getByRole('button', { name: 'Skip' }).click()
    await seesEndState(page)
    await expect(start(page)).toBeFocused()
    await expect(page.locator('main[data-intro="on"]')).toHaveCount(0)
  })

  test('[intro-logo 10] the rule: a returning learner never sees the intro, nor does a visit under way', async ({
    page,
    context,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page, RETURNING)
    await expect(roadList(page)).toBeAttached()
    await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
    await expect(logo(page)).toHaveCount(0)
    await expect(introSkip(page)).toHaveCount(0)
    await expect(start(page)).toBeVisible({ timeout: 8000 })
    await expect(bubble(page)).toHaveCount(0)
    expect(await played(page)).toEqual([])

    // A visit under way (the app used 10 minutes ago in this tab): no intro.
    const fresh = await context.newPage()
    await fakeIntroAudio(fresh)
    await fresh.addInitScript({
      content: `try { sessionStorage.setItem(${JSON.stringify(VISIT_KEY)}, String(Date.now() - 600000)) } catch {}`,
    })
    await openNew(fresh)
    await expect(roadList(fresh)).toBeAttached()
    await expect(logo(fresh)).toHaveCount(0)
    await expect(start(fresh)).toBeVisible({ timeout: 8000 })
    await expect(bubble(fresh)).toHaveCount(0)
  })

  test('[intro-logo 10] leaving before the intro ends does not mark the visit', async ({ page }) => {
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(page.getByTestId('intro-spoken')).toBeVisible()
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    // A reload part way is the same tab with no visit yet: the intro comes again.
    await page.reload()
    await expect(logo(page)).toBeAttached()
  })

  test('[intro-logo 11] the old screens are gone: none of their words, buttons or the sound switch', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(page.getByTestId('intro-written')).toBeVisible({ timeout: 5000 })
    for (const text of OLD_TEXTS) await expect(page.getByText(text)).toHaveCount(0)
    await expect(page.getByRole('img', { name: 'Aleksi, your Finnish tutor' })).toHaveCount(0)
    await expect(page.locator('[aria-pressed]')).toHaveCount(0)
    await expect(start(page)).toBeVisible({ timeout: 10_000 })
    for (const text of OLD_TEXTS) await expect(page.getByText(text)).toHaveCount(0)
  })

  test('[intro-logo 13] every Finnish line carries lang="fi", and the English ones do not', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(page.getByTestId('intro-written')).toBeVisible({ timeout: 5000 })
    for (const text of ['Puhekieli', 'Kirjakieli']) {
      await expect(page.getByText(text, { exact: true })).toHaveAttribute('lang', 'fi')
    }
    await expect(page.getByTestId('intro-spoken')).toHaveAttribute('lang', 'fi')
    await expect(page.getByTestId('intro-written')).toHaveAttribute('lang', 'fi')
    expect(await page.getByText(MEANING, { exact: true }).evaluate(LANG_OF)).toBe('en')
    await expect(start(page)).toBeVisible({ timeout: 10_000 })
    await expect(bubble(page).getByText(JOURNEY_FI, { exact: true })).toHaveAttribute('lang', 'fi')
    expect(await bubble(page).getByText(JOURNEY_EN, { exact: true }).evaluate(LANG_OF)).toBe('en')
  })

  test('[intro-logo 3] with real audio both clips play, the greeting until the journey line takes over', async ({
    page,
  }) => {
    // Real playback, in Chromium. Playwright's WebKit on Windows refuses these MP3 files (media error 4, "not
    // supported", seen on 5 November 2026), so there the stand-in covers it.
    test.skip(test.info().project.name !== 'chromium', 'Real MP3 playback is tested in Chromium')
    test.setTimeout(60_000)
    await page.addInitScript({
      content: `window.__real = []
        const real = HTMLMediaElement.prototype.play
        HTMLMediaElement.prototype.play = function () {
          if (!this.__watched) {
            this.__watched = true
            this.addEventListener('ended', () => { if (this.__entry) this.__entry.ended = performance.now() })
            this.addEventListener('playing', () => { if (this.__entry) this.__entry.playing = performance.now() })
          }
          const entry = { src: new URL(this.src, location.href).pathname, start: performance.now() }
          this.__entry = entry
          window.__real.push(entry)
          return real.call(this).catch((e) => { entry.refused = e.name; throw e })
        }`,
    })
    await openNew(page)
    await expect(start(page)).toBeVisible({ timeout: 15_000 })
    await page.waitForTimeout(3500)
    const log =
      await page.evaluate<
        { src: string; start: number; playing?: number; ended?: number; refused?: string }[]
      >('window.__real')
    expect(log.map((entry) => entry.src)).toEqual([GREETING_AUDIO, JOURNEY_AUDIO])
    for (const entry of log) {
      expect(entry.refused, entry.src).toBeUndefined()
      expect(entry.playing, entry.src).toBeDefined()
    }
    // The journey line played to its end.
    expect(log[1]?.ended).toBeDefined()
  })
})

test.describe('reduced motion', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[intro-logo 9] [intro-logo 10] with reduced motion the intro is its end state at once: no logo, no animation, no sound', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    await page.addInitScript({
      content: `window.__motion = { intro: false, animated: false }
      new MutationObserver(() => {
        if (document.querySelector('[data-scene]')) window.__motion.intro = true
        if (document.querySelector('main[data-intro="on"]')) window.__motion.animated = true
      }).observe(document, { childList: true, subtree: true, attributes: true })`,
    })
    await openNew(page)
    await seesEndState(page)
    expect(await page.evaluate<{ intro: boolean; animated: boolean }>('window.__motion')).toEqual({
      intro: false,
      animated: false,
    })
    expect(await finiteAnimations(page)).toBe(0)
    await page.waitForTimeout(1500)
    expect(await played(page)).toEqual([])
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    await bubble(page).getByRole('button', { name: 'Play Aleksi’s line' }).click()
    expect(sounded(await played(page)).map((entry) => entry.src)).toEqual([JOURNEY_AUDIO])
  })

  test('[intro-logo 10] Start marks the visit too', async ({ page }) => {
    await fakeIntroAudio(page)
    const calls = await openNew(page)
    await seesEndState(page)
    // The marker is cleared after the end state, so only Start can write it again.
    await page.evaluate(`sessionStorage.removeItem(${JSON.stringify(VISIT_KEY)})`)
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    await pressStart(page)
    await expect.poll(() => calls.guest).toBe(1)
    await page.waitForURL('**/learn/session')
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
  })
})

/** The elements whose box runs past the screen's sides, or lines of text that run past their own box. */
async function overflowing(page: Page, selector: string) {
  return page.evaluate<string[]>(
    `[...document.querySelectorAll(${JSON.stringify(selector)})].filter((el) => {
      const r = el.getBoundingClientRect()
      if (r.width === 0 || r.height === 0 || getComputedStyle(el).visibility === 'hidden') return false
      // A line of text must also fit its own box (a photo's crop may overflow its round frame on purpose).
      const text = el.matches('p')
      return r.left < -1 || r.right > document.documentElement.clientWidth + 1 || (text && el.scrollWidth > el.clientWidth + 1)
    }).map((el) => el.tagName + ' ' + (el.textContent || '').slice(0, 30))`,
  )
}

const INTRO_PARTS =
  '[data-testid="intro-logo"] svg, button, [data-testid="intro-card"], [data-testid="intro-card"] p, [data-testid="intro-card"] span'
const END_PARTS =
  '[data-testid="road-bubble"], [data-testid="road-bubble"] *, [data-testid="road-start"] button'

for (const text of ['100%', '200%'] as const) {
  test.describe(`at 375 x 812 with text at ${text}`, () => {
    test.use({ reducedMotion: 'no-preference', viewport: { width: 375, height: 812 } })

    test(`[intro-logo 12] nothing overflows: the logo, the card with both lines and the speaker, and the end state (text ${text})`, async ({
      page,
    }) => {
      test.setTimeout(60_000)
      await fakeIntroAudio(page, { refuseUntilTap: true })
      const moveOn = await holdTime(page)
      if (text !== '100%')
        await page.addInitScript({
          content: `document.addEventListener('DOMContentLoaded', () => {
            const style = document.createElement('style')
            style.textContent = 'html { font-size: ${text} !important; }'
            document.head.append(style)
          })`,
        })
      await openNew(page)
      await expect(logo(page)).toBeAttached()
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, INTRO_PARTS)).toEqual([])
      expect(await whollyOnScreen(page, introSkip(page))).toBe(true)

      // The card with both lines, and the "Tap to hear" pill, its widest state (the written scene, 2.35 s on).
      await moveOn(3500)
      await expect(page.getByTestId('intro-meaning')).toHaveCSS('opacity', '1')
      await expect(speaker(page)).toHaveAttribute('data-state', 'waiting-for-tap')
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, INTRO_PARTS)).toEqual([])
      // The pill stays on the card's row, inside the card.
      const card = await page.getByTestId('intro-card').boundingBox()
      const pill = await speaker(page).boundingBox()
      expect((pill?.x ?? 0) + (pill?.width ?? 0)).toBeLessThanOrEqual((card?.x ?? 0) + (card?.width ?? 0))
      if (text === '200%') await shot(page, '12-card-text-200-375x812')

      await introSkip(page).click()
      await seesEndState(page)
      await moveOn(500)
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, END_PARTS)).toEqual([])
      for (const part of [bubble(page), start(page)]) {
        await part.scrollIntoViewIfNeeded()
        expect(await whollyOnScreen(page, part)).toBe(true)
      }
      if (text === '200%') await shot(page, '12-end-state-text-200-375x812')
    })
  })
}

test('[intro-logo 1] the brand files: the logo on light and dark', async ({ page }) => {
  test.skip(!evidence || test.info().project.name !== 'chromium', 'Evidence pictures only')
  const light = readFileSync('design/assets/wordmark.svg', 'utf8')
  const dark = readFileSync('design/assets/wordmark-dark.svg', 'utf8')
  await page.setViewportSize({ width: 900, height: 520 })
  await page.setContent(`<body style="margin:0;font-family:sans-serif">
    <div style="display:flex;align-items:center;justify-content:center;height:260px;background:#f7f8f6">${light}</div>
    <div style="display:flex;align-items:center;justify-content:center;height:260px;background:#1b2a26">${dark}</div>
  </body>`)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/1-logo-light-and-dark.png` })
})
