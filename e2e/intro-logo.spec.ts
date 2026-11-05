import { mkdirSync, readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { GREETING_AUDIO, GREETING_WRITTEN_AUDIO, JOURNEY_AUDIO, VISIT_KEY } from '../src/lib/aleksi-intro.ts'
import { at, fakeIntroAudio, played, seen, type Played } from './intro-audio.ts'
import { mockHome, type HomeMocks } from './road-mocks.ts'
import { pressStart } from './road-start.ts'
import { scrollsSideways } from './session-helpers.ts'
import { STORED_BESIDES_VISIT, VISIT_VALUE } from './visit-marker.ts'

// Fast route intro-logo (the manager's brief of 5 November 2026, listed in factory/jobs/intro-logo/build.md):
// the new logo and Aleksi's new intro, the owner's prototype version D. Labels [intro-logo N] are the
// brief's numbered "Done when" statements:
//   1 the Wordmark draws the new outlined logo (unit tests, and the logo at the top here),
//   2 the intro opens on the logo and "Play with sound", and nothing plays before the tap,
//   3 after the tap the scenes and the three clips run in order, no clip before the last one ended,
//   4 Skip and reduced motion show the end state at once,
//   5 the intro shows only when the rule says so, and the visit is marked on its end, Skip or Start,
//   6 the old "Nice to meet you" screen is gone,
//   7 nothing overflows at 375 x 812 in Chromium and WebKit, nor with text at 200 percent,
//   8 Finnish lines carry lang="fi".
// The road answers from e2e/road-mocks.ts (met: false, so the test meets the intro itself), and the audio
// is the stand-in of e2e/intro-audio.ts unless a test says otherwise. With PUHUSCRIBE_EVIDENCE=1 the
// screenshots go to factory/jobs/intro-logo/evidence/ (Chromium only).

const OUT = resolve('factory/jobs/intro-logo/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'

const PLAY = 'Play with sound'
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
]
const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
const CLIPS = [GREETING_AUDIO, GREETING_WRITTEN_AUDIO, JOURNEY_AUDIO]
/** The language an element is read in: its nearest lang attribute. */
const LANG_OF = (el: unknown) =>
  (el as { closest: (s: string) => { getAttribute: (n: string) => string | null } | null })
    .closest('[lang]')
    ?.getAttribute('lang') ?? null

/** A returning learner: signed in with email, stop 1 finished. The rule says no intro. */
const RETURNING: HomeMocks = {
  met: false,
  today: { signedIn: true, today: 'start', account: 'email', finishedStop: true },
  done: { 1: 4, 2: 1 },
}

async function shot(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png` })
}

const playButton = (page: Page) => page.getByRole('button', { name: PLAY })
const introSkip = (page: Page) => page.locator('button[data-intro-skip]')
const roadList = (page: Page) => page.getByRole('list', { name: 'Stops on your road' })
const start = (page: Page) => page.getByRole('button', { name: 'Start', exact: true })
const bubble = (page: Page) => page.getByTestId('road-bubble')

/** A new visitor opens the app. */
async function openNew(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, { met: false, ...mocks })
  await page.goto('/learn')
  return calls
}

/** The clips said aloud (not the muted unlock), in order. */
const aloud = (log: Played[]) => log.filter((entry) => !entry.muted)

/** The end state: the road, Aleksi's bubble with his journey line and its play button, and Start. */
async function seesEndState(page: Page) {
  await expect(roadList(page)).toBeVisible()
  await expect(bubble(page)).toBeVisible()
  await expect(bubble(page)).toContainText(JOURNEY_FI)
  await expect(bubble(page)).toContainText(JOURNEY_EN)
  await expect(bubble(page).getByRole('button', { name: 'Play Aleksi’s line' })).toBeVisible()
  await expect(start(page)).toBeVisible()
  await expect(page.locator('main[data-intro="on"]')).toHaveCount(0)
}

/** The finite animations of the page. */
async function finiteAnimations(page: Page) {
  return page.evaluate<number>(
    `document.getAnimations().filter((a) => Number.isFinite(a.effect.getComputedTiming().endTime) && a.playState === 'running').length`,
  )
}

test.describe('with motion on', () => {
  test.use({ reducedMotion: 'no-preference' })

  test('[intro-logo 2] [intro-logo 1] the intro opens on the logo and "Play with sound", and nothing plays before the tap', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    const audioRequests: string[] = []
    page.on('request', (request) => {
      if (new URL(request.url()).pathname.startsWith('/audio/')) audioRequests.push(request.url())
    })
    await openNew(page)
    await expect(playButton(page)).toBeVisible()
    // The new logo at the top: the outlined wordmark, as the page's heading, with no text inside it.
    const logo = page.getByRole('heading', { level: 1 }).getByRole('img', { name: 'Aleksi', exact: true })
    await expect(logo).toBeVisible()
    await expect(logo.locator('text, tspan')).toHaveCount(0)
    await expect(logo.locator('path[data-part="fell"]')).toHaveCount(1)
    await expect(logo.locator('path[data-part="bubble"]')).toHaveCount(1)
    const logoBox = await logo.boundingBox()
    expect(logoBox?.y ?? 999).toBeLessThan(80)
    // One centred "Play with sound" and a quiet Skip, each at least 44 px.
    const box = await playButton(page).boundingBox()
    const middle = (box?.x ?? 0) + (box?.width ?? 0) / 2
    expect(Math.abs(middle - 375 / 2)).toBeLessThan(2)
    await expect(introSkip(page)).toHaveText('Skip')
    for (const control of [playButton(page), introSkip(page)]) {
      const b = await control.boundingBox()
      expect(b?.width ?? 0).toBeGreaterThanOrEqual(44)
      expect(b?.height ?? 0).toBeGreaterThanOrEqual(44)
    }
    // Nothing plays, and no clip is even fetched, before the tap.
    await page.waitForTimeout(3000)
    expect(await played(page)).toEqual([])
    expect(audioRequests).toEqual([])
    await expect(roadList(page)).toHaveCount(0)
    const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
    expect(axe.violations).toEqual([])
    await shot(page, '2-logo-and-play-375x812')
  })

  test('[intro-logo 3] [intro-logo 5] after the tap: the card, the greeting spoken then written, the road, the journey line, then Start; each clip after the last has ended', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await playButton(page).click()
    // The spoken line, while the greeting plays.
    const card = page.getByTestId('intro-card')
    await expect(card).toBeVisible()
    await expect(card.getByText('Aleksi', { exact: true })).toBeVisible()
    await expect(page.getByTestId('intro-spoken')).toHaveText(SPOKEN)
    await expect(page.getByTestId('intro-written')).toBeHidden()
    await expect.poll(async () => aloud(await played(page)).length).toBe(1)
    await expect(page.getByTestId('intro-spoken')).toHaveCSS('opacity', '1')
    await shot(page, '3-spoken-line-375x812')
    // The written line, while the written greeting plays, then the meaning.
    await expect(page.getByTestId('intro-written')).toBeVisible({ timeout: 8000 })
    await expect(page.getByTestId('intro-written')).toHaveText(WRITTEN)
    await expect(page.getByTestId('intro-meaning')).toBeVisible({ timeout: 5000 })
    await expect(page.getByTestId('intro-meaning')).toHaveText(`Meaning ${MEANING}`)
    await expect(page.getByTestId('intro-meaning')).toHaveCSS('opacity', '1', { timeout: 5000 })
    await shot(page, '3-written-line-375x812')
    // The visit is not marked while the intro is still on.
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    // Then the road with its opening animation, the bubble and his journey line, then Start.
    await expect(roadList(page)).toBeAttached({ timeout: 10_000 })
    await expect(start(page)).toBeVisible({ timeout: 20_000 })
    await seesEndState(page)
    await shot(page, '3-road-journey-bubble-start-375x812')

    const log = await played(page)
    const said = aloud(log)
    // One muted start inside the tap (the unlock), first, then the three clips in order.
    expect(log[0]).toMatchObject({ src: GREETING_AUDIO, muted: true })
    expect(log.filter((entry) => entry.muted)).toHaveLength(1)
    expect(said.map((entry) => entry.src)).toEqual(CLIPS)
    // No clip starts before the one before it has ended, and each played to its end.
    for (const [i, entry] of said.entries()) {
      expect(entry.end, entry.src).not.toBeNull()
      if (i > 0) expect(entry.start).toBeGreaterThanOrEqual(said[i - 1]?.end ?? Infinity)
    }
    // The scenes run in order with their clips.
    const scenes = await seen(page)
    const [greeting, written, journey] = said as [Played, Played, Played]
    expect(at(scenes, 'ask')).toBeLessThan(at(scenes, 'scene:spoken'))
    expect(at(scenes, 'scene:spoken')).toBeLessThan(greeting.start)
    expect(at(scenes, 'scene:written')).toBeGreaterThanOrEqual(greeting.end ?? Infinity)
    expect(written.start).toBeGreaterThan(at(scenes, 'scene:written'))
    expect(at(scenes, 'scene:leaving')).toBeGreaterThanOrEqual(written.end ?? Infinity)
    expect(at(scenes, 'road animation')).toBeGreaterThan(at(scenes, 'scene:leaving'))
    expect(at(scenes, 'bubble')).toBeGreaterThan(at(scenes, 'road animation'))
    expect(journey.start).toBeGreaterThanOrEqual(at(scenes, 'bubble'))
    expect(at(scenes, 'start')).toBeGreaterThanOrEqual(journey.end ?? Infinity)
    // [intro-logo 5] The visit is marked when the intro ends: only a time is kept.
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    expect(await page.evaluate<number>(STORED_BESIDES_VISIT)).toBe(0)
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
    expect(axe.violations).toEqual([])
  })

  test('[intro-logo 3] with real audio the three clips play to their ends, one after another', async ({
    page,
  }) => {
    // Real playback, in Chromium. Playwright's WebKit on Windows refuses these MP3 files (media error 4, "not
    // supported", seen on 5 November 2026), so there it would only test the "cannot play" path, which the
    // test below covers in both browsers.
    test.skip(test.info().project.name !== 'chromium', 'Real MP3 playback is tested in Chromium')
    test.setTimeout(60_000)
    await page.addInitScript({
      content: `window.__real = []
        const real = HTMLMediaElement.prototype.play
        HTMLMediaElement.prototype.play = function () {
          if (!this.__watched) {
            this.__watched = true
            this.addEventListener('ended', () => { if (this.__entry) this.__entry.ended = performance.now() })
            this.addEventListener('pause', () => { if (this.__entry && !this.__entry.ended) this.__entry.paused = performance.now() })
          }
          const entry = { src: new URL(this.src, location.href).pathname, muted: this.muted, start: performance.now() }
          this.__entry = entry
          window.__real.push(entry)
          return real.call(this)
        }`,
    })
    await openNew(page)
    await playButton(page).click()
    await expect(start(page)).toBeVisible({ timeout: 40_000 })
    const log =
      await page.evaluate<{ src: string; muted: boolean; start: number; ended?: number; paused?: number }[]>(
        'window.__real',
      )
    const said = log.filter((entry) => !entry.muted)
    expect(said.map((entry) => entry.src)).toEqual(CLIPS)
    for (const [i, entry] of said.entries()) {
      // Each clip played to its real end (about 4.0, 4.0 and 2.8 seconds), not cut short.
      expect(entry.ended, entry.src).toBeDefined()
      expect((entry.ended ?? 0) - entry.start).toBeGreaterThan(2500)
      if (i > 0) expect(entry.start).toBeGreaterThanOrEqual(said[i - 1]?.ended ?? Infinity)
    }
  })

  test('[intro-logo 3] when the browser will not play a clip, the scenes keep their pace and the intro still ends', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page, { refuse: true })
    await openNew(page)
    await playButton(page).click()
    await expect(page.getByTestId('intro-written')).toBeVisible({ timeout: 8000 })
    await expect(start(page)).toBeVisible({ timeout: 25_000 })
    await seesEndState(page)
    await expect(page.getByText('Could not play.')).toHaveCount(0)
    const scenes = await seen(page)
    // The written line waited out the greeting's length (4.0 s) after it came in.
    expect(at(scenes, 'scene:written') - at(scenes, 'scene:spoken')).toBeGreaterThan(4000)
  })

  test('[intro-logo 4] [intro-logo 5] Skip on the first screen: the end state at once, no sound, the visit marked', async ({
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
    await expect(playButton(page)).toHaveCount(0)
    await expect(bubble(page)).toHaveCount(0)
  })

  test('[intro-logo 4] Skip while the greeting plays: the voice stops at once and the end state shows', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page)
    await playButton(page).click()
    await expect.poll(async () => aloud(await played(page)).length).toBe(1)
    await introSkip(page).click()
    await seesEndState(page)
    await expect(start(page)).toBeFocused()
    const [greeting] = aloud(await played(page))
    expect(greeting?.end).not.toBeNull()
    // Nothing more is said after Skip.
    await page.waitForTimeout(6000)
    expect(aloud(await played(page))).toHaveLength(1)
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
  })

  test('[intro-logo 4] Skip on the road, while it draws or while Aleksi speaks: the end state at once', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await playButton(page).click()
    // The road's own Skip, while its opening animation plays after the card.
    await expect(page.locator('main[data-intro="on"]')).toBeAttached({ timeout: 15_000 })
    await page.getByRole('button', { name: 'Skip' }).click()
    await seesEndState(page)
    await expect(start(page)).toBeFocused()
    expect(aloud(await played(page)).map((entry) => entry.src)).toEqual([
      GREETING_AUDIO,
      GREETING_WRITTEN_AUDIO,
    ])
    await page.waitForTimeout(4000)
    expect(aloud(await played(page))).toHaveLength(2)
  })

  test('[intro-logo 5] the rule: a returning learner never sees the intro, nor does a visit under way', async ({
    page,
    context,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page, RETURNING)
    await expect(roadList(page)).toBeAttached()
    await expect(page.getByRole('button', { name: 'Skip' })).toBeVisible()
    await expect(playButton(page)).toHaveCount(0)
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
    await expect(playButton(fresh)).toHaveCount(0)
    await expect(start(fresh)).toBeVisible({ timeout: 8000 })
    await expect(bubble(fresh)).toHaveCount(0)
  })

  test('[intro-logo 5] a new visitor meets the intro; leaving before it ends does not mark the visit', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    await openNew(page)
    await playButton(page).click()
    await expect(page.getByTestId('intro-spoken')).toBeVisible()
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toBeNull()
    // A reload part way is the same tab with no visit yet: the intro comes again.
    await page.reload()
    await expect(playButton(page)).toBeVisible()
  })

  test('[intro-logo 6] the old "Nice to meet you" screen is gone: none of its words, its photo card or its button', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await expect(playButton(page)).toBeVisible()
    for (const text of OLD_TEXTS) await expect(page.getByText(text)).toHaveCount(0)
    await expect(page.getByRole('img', { name: 'Aleksi, your Finnish tutor' })).toHaveCount(0)
    await playButton(page).click()
    await expect(start(page)).toBeVisible({ timeout: 25_000 })
    for (const text of OLD_TEXTS) await expect(page.getByText(text)).toHaveCount(0)
    await expect(page.getByRole('button', { name: /Nice to meet you/ })).toHaveCount(0)
  })

  test('[intro-logo 8] every Finnish line carries lang="fi", and the English ones do not', async ({
    page,
  }) => {
    test.setTimeout(60_000)
    await fakeIntroAudio(page)
    await openNew(page)
    await playButton(page).click()
    await expect(page.getByTestId('intro-meaning')).toBeVisible({ timeout: 10_000 })
    for (const text of ['Puhekieli', 'Kirjakieli']) {
      await expect(page.getByText(text, { exact: true })).toHaveAttribute('lang', 'fi')
    }
    await expect(page.getByTestId('intro-spoken')).toHaveAttribute('lang', 'fi')
    await expect(page.getByTestId('intro-written')).toHaveAttribute('lang', 'fi')
    const english = await page.getByText(MEANING, { exact: true }).evaluate(LANG_OF)
    expect(english).toBe('en')
    await expect(start(page)).toBeVisible({ timeout: 25_000 })
    await expect(bubble(page).getByText(JOURNEY_FI, { exact: true })).toHaveAttribute('lang', 'fi')
    const journeyEnglish = await bubble(page).getByText(JOURNEY_EN, { exact: true }).evaluate(LANG_OF)
    expect(journeyEnglish).toBe('en')
    // Every text on the page that holds a Finnish line sits inside lang="fi".
    const unmarked = await page.evaluate<string[]>(`(() => {
      const finnish = [${JSON.stringify(SPOKEN)}, ${JSON.stringify(WRITTEN)}, ${JSON.stringify(JOURNEY_FI)}, 'Puhekieli', 'Kirjakieli']
      return [...document.querySelectorAll('body *')].filter((el) =>
        el.children.length === 0 || el.matches('p')
      ).filter((el) => finnish.some((line) => (el.textContent || '').includes(line)))
        .filter((el) => el.closest('[lang]').getAttribute('lang') !== 'fi')
        .map((el) => el.textContent)
    })()`)
    expect(unmarked).toEqual([])
  })
})

test.describe('reduced motion', () => {
  test.use({ reducedMotion: 'reduce' })

  test('[intro-logo 4] [intro-logo 5] with reduced motion the intro is its end state at once: no first screen, no animation, no sound', async ({
    page,
  }) => {
    await fakeIntroAudio(page)
    // Watches from the first moment, so a screen or an animation that shows only briefly is still caught.
    await page.addInitScript({
      content: `window.__motion = { ask: false, animated: false }
      new MutationObserver(() => {
        if ([...document.querySelectorAll('button')].some((b) => (b.textContent || '').trim() === ${JSON.stringify(PLAY)}))
          window.__motion.ask = true
        if (document.querySelector('main[data-intro="on"], main[data-scene]')) window.__motion.animated = true
      }).observe(document, { childList: true, subtree: true, attributes: true })`,
    })
    await openNew(page)
    await seesEndState(page)
    expect(await page.evaluate<{ ask: boolean; animated: boolean }>('window.__motion')).toEqual({
      ask: false,
      animated: false,
    })
    expect(await finiteAnimations(page)).toBe(0)
    await page.waitForTimeout(1500)
    expect(await played(page)).toEqual([])
    // The end state is the intro's end: the visit is marked, and the bubble's play button plays the line.
    expect(await page.evaluate<string | null>(VISIT_VALUE)).toMatch(/^\d+$/)
    await bubble(page).getByRole('button', { name: 'Play Aleksi’s line' }).click()
    expect(aloud(await played(page)).map((entry) => entry.src)).toEqual([JOURNEY_AUDIO])
  })

  test('[intro-logo 5] Start marks the visit too', async ({ page }) => {
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

/** The element's box lies inside the screen, to within a pixel of rounding. */
async function whollyOnScreen(page: Page, part: ReturnType<Page['locator']>) {
  const box = await part.boundingBox()
  const size = page.viewportSize()
  if (!box || !size) return false
  return (
    box.x >= -1 && box.y >= -1 && box.x + box.width <= size.width + 1 && box.y + box.height <= size.height + 1
  )
}

const INTRO_PARTS =
  'main h1, main h1 svg, button, [data-testid="intro-card"], [data-testid="intro-card"] p, [data-testid="intro-card"] span'
const END_PARTS =
  '[data-testid="road-bubble"], [data-testid="road-bubble"] *, [data-testid="road-start"] button'

for (const text of ['100%', '200%'] as const) {
  test.describe(`at 375 x 812 with text at ${text}`, () => {
    test.use({ reducedMotion: 'no-preference', viewport: { width: 375, height: 812 } })

    test(`[intro-logo 7] nothing overflows: the first screen, the card with both lines, and the end state (text ${text})`, async ({
      page,
    }) => {
      test.setTimeout(60_000)
      await fakeIntroAudio(page)
      if (text !== '100%')
        await page.addInitScript({
          content: `document.addEventListener('DOMContentLoaded', () => {
            const style = document.createElement('style')
            style.textContent = 'html { font-size: ${text} !important; }'
            document.head.append(style)
          })`,
        })
      await openNew(page)
      await expect(playButton(page)).toBeVisible()
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, INTRO_PARTS)).toEqual([])
      await expect(playButton(page)).toBeInViewport({ ratio: 1 })
      await expect(introSkip(page)).toBeInViewport({ ratio: 1 })
      // The logo and Skip never meet.
      const logo = await page.getByRole('heading', { level: 1 }).locator('svg').boundingBox()
      const skipBox = await introSkip(page).boundingBox()
      expect((logo?.x ?? 0) + (logo?.width ?? 0)).toBeLessThanOrEqual(skipBox?.x ?? 0)

      await playButton(page).click()
      await expect(page.getByTestId('intro-meaning')).toHaveCSS('opacity', '1', { timeout: 12_000 })
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, INTRO_PARTS)).toEqual([])
      // Every line of the card can be reached on the screen.
      for (const id of ['intro-spoken', 'intro-written', 'intro-meaning']) {
        await page.getByTestId(id).scrollIntoViewIfNeeded()
        await expect(page.getByTestId(id)).toBeInViewport({ ratio: 1 })
      }
      if (text === '200%') await shot(page, '7-card-text-200-375x812')

      await introSkip(page).click()
      await seesEndState(page)
      await page.waitForTimeout(500)
      expect(await scrollsSideways(page)).toBe(false)
      expect(await overflowing(page, END_PARTS)).toEqual([])
      for (const part of [bubble(page), start(page)]) {
        await part.scrollIntoViewIfNeeded()
        expect(await whollyOnScreen(page, part)).toBe(true)
      }
      if (text === '200%') await shot(page, '7-end-state-text-200-375x812')
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
