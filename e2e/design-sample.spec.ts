import { expect, test, type Page } from '@playwright/test'
import { SWITZER_SKIP_REASON, switzerPresent } from './switzer.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/5-design-system/spec.md that each test protects. Round 1 builds
// one sample screen (the Hear it step at /sample/hear-it) for the owner's
// review, so these tests cover what the sample shows: the design values, the
// self-hosted fonts, the session frame at phone size, tap sizes and both
// colour modes.
//
// The sample exists only in builds made with VITE_DESIGN_REFERENCE=1 (the
// GitHub checks and preview links set it). Build locally with
//   VITE_DESIGN_REFERENCE=1 npm run build
// before running these. e2e/ is type checked without the browser's types, so
// in-page expressions are passed as text.

const SAMPLE = '/sample/hear-it'
const FIRST_FINNISH_LINE = `document.querySelector('[lang="fi"]')`

async function openSample(page: Page) {
  await page.goto(SAMPLE)
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it', exact: true })).toBeVisible()
  await page.evaluate('document.fonts.ready')
}

async function spokenWordNow(page: Page): Promise<string | null> {
  // One read in the page, so a word that changes mid-check cannot be missed.
  return page.evaluate<string | null>(`document.querySelector('[aria-current="true"]')?.textContent ?? null`)
}

interface Sideways {
  scrollWidth: number
  width: number
  past: string[]
}

// Moves the fake clock in 25 ms steps, checking the page after each step,
// until the given word is lit (or, for null, until no word is). A word stays
// lit for 450 ms, so no word can pass unseen. Fails if one is skipped.
async function advanceUntil(page: Page, word: string | null, lit: (string | null)[]) {
  for (let waited = 0; waited <= 10_000; waited += 25) {
    const now = await spokenWordNow(page)
    if (lit.at(-1) !== now) lit.push(now)
    if (now === word) return
    await page.clock.runFor(25)
  }
  throw new Error(`"${String(word)}" was never lit`)
}

test.describe('the Hear it sample', () => {
  test('[design 5] every request goes to the app’s own address and the fonts are built in', async ({
    page,
  }) => {
    const urls: string[] = []
    page.on('request', (request) => {
      if (!request.url().startsWith('data:')) urls.push(request.url())
    })
    await openSample(page)
    await page.waitForLoadState('networkidle')
    const origin = new URL(page.url()).origin
    expect(urls.length).toBeGreaterThan(0)
    for (const url of urls) expect(new URL(url).origin, url).toBe(origin)
  })

  // Round 2: body text moved to Switzer (owner's decision, 21 October 2026),
  // so Poppins 500 is no longer used on this screen and is not loaded. The
  // test checks the faces the screen uses: Poppins for the spoken lines and
  // headings, Switzer for the written lines and body text.
  test('[design 5] ä, ö, å, Ä, Ö and Å render in Poppins, the font this screen uses for the spoken lines', async ({
    page,
  }) => {
    await openSample(page)
    for (const font of ['600 22px Poppins', '700 22px Poppins']) {
      expect(await page.evaluate<boolean>(`document.fonts.check('${font}', 'äöåÄÖÅ')`), font).toBe(true)
    }
    const family = await page.evaluate<string>(`getComputedStyle(${FIRST_FINNISH_LINE}).fontFamily`)
    expect(family.startsWith('Poppins')).toBe(true)
  })

  // Switzer is kept out of the public repository (docs/fonts.md): this test
  // runs when the files were fetched and skips, with its reason, when not.
  test('[design 5] ä, ö, å, Ä, Ö and Å render in Switzer, and the body text uses it', async ({ page }) => {
    test.skip(!switzerPresent, SWITZER_SKIP_REASON)
    await openSample(page)
    for (const font of ['400 16px Switzer', '500 16px Switzer']) {
      expect(await page.evaluate<boolean>(`document.fonts.check('${font}', 'äöåÄÖÅ')`), font).toBe(true)
    }
    const body = await page.evaluate<string>('getComputedStyle(document.body).fontFamily')
    expect(body.startsWith('Switzer')).toBe(true)
  })

  test('[design 5] text sizes follow the browser text size', async ({ page }) => {
    await openSample(page)
    const fontSize = `parseFloat(getComputedStyle(${FIRST_FINNISH_LINE}).fontSize)`
    const before = await page.evaluate<number>(fontSize)
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    const after = await page.evaluate<number>(fontSize)
    expect(after).toBeCloseTo(before * 2, 0)
  })

  test('[design 7] the frame names the step in words, offers "Leave session", and keeps the player in view', async ({
    page,
  }) => {
    await openSample(page)
    // Round 3: the top bar is the shared SessionFrame's, which names the step
    // in words. Unit 1 has no Use it step, so it is step 1 of 4.
    await expect(page.getByText('Hear it, step 1 of 4', { exact: true })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Leave session' })).toBeVisible()
    const play = page.getByRole('button', { name: 'Play the dialogue' })
    await expect(play).toBeInViewport()
    await expect(page.getByRole('button', { name: 'Continue' })).toBeInViewport()
    // Still in view after scrolling to the end of the content.
    await page.mouse.wheel(0, 2000)
    await expect(play).toBeInViewport()
  })

  for (const width of [375, 320]) {
    test(`[design 7] nothing scrolls sideways at ${String(width)} px, also with text at 200 percent`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height: 812 })
      await openSample(page)
      // The page's scroll width, and every element that reaches past the right edge.
      const sideways = `(() => {
        const width = document.documentElement.clientWidth
        const past = [...document.querySelectorAll('body *')]
          .filter((el) => el.getBoundingClientRect().right > width + 0.5)
          .map((el) => el.tagName + ' ' + String(el.className))
        return { scrollWidth: document.documentElement.scrollWidth, width, past }
      })()`
      const normal = await page.evaluate<Sideways>(sideways)
      expect(normal.past).toEqual([])
      expect(normal.scrollWidth).toBeLessThanOrEqual(normal.width)
      await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
      const large = await page.evaluate<Sideways>(sideways)
      expect(large.past).toEqual([])
      expect(large.scrollWidth).toBeLessThanOrEqual(large.width)
    })
  }

  test('[design 8] every button and link has a tap area of at least 44 x 44 px', async ({ page }) => {
    await openSample(page)
    const controls = page.locator('button, a[href]')
    const count = await controls.count()
    expect(count).toBeGreaterThanOrEqual(3)
    for (let i = 0; i < count; i += 1) {
      const box = await controls.nth(i).boundingBox()
      expect(box, `control ${String(i)}`).not.toBeNull()
      expect(box?.width ?? 0).toBeGreaterThanOrEqual(44)
      expect(box?.height ?? 0).toBeGreaterThanOrEqual(44)
    }
  })

  test('[design 9] keyboard focus on Play shows an outline at least 2 px thick', async ({ page }) => {
    await openSample(page)
    const play = page.getByRole('button', { name: 'Play the dialogue' })
    // WebKit only moves Tab between buttons when a system setting allows it,
    // so the focus is placed with the keyboard flag the browser would set.
    await play.focus()
    await page.keyboard.press('Shift+Tab')
    await page.keyboard.press('Tab')
    const isPlay = 'document.activeElement?.getAttribute("aria-label") === "Play the dialogue"'
    if (!(await page.evaluate<boolean>(isPlay))) await play.focus()
    await expect(play).toBeFocused()
    const outline = await page.evaluate<{ width: number; style: string }>(
      '({ width: parseFloat(getComputedStyle(document.activeElement).outlineWidth), style: getComputedStyle(document.activeElement).outlineStyle })',
    )
    expect(outline.style).toBe('solid')
    expect(outline.width).toBeGreaterThanOrEqual(2)
  })

  test('[design 11] both lines show spoken Finnish first and the written line under it, labelled, in Finnish', async ({
    page,
  }) => {
    await openSample(page)
    const finnish = page.locator('[lang="fi"]')
    await expect(finnish).toHaveText([
      'Moi! Mä oon Alex.',
      'Hei! Minä olen Alex.',
      'Mist sä oot kotoisin?',
      'Mistä sinä olet kotoisin?',
    ])
    await expect(page.getByText('Spoken', { exact: true })).toHaveCount(2)
    await expect(page.getByText('Written', { exact: true })).toHaveCount(2)
    // The page marks the lines as a sample the native reviewer has not checked
    // (round 3: in statement 16's words), and explains the blue words.
    await expect(page.getByText('Sample, not reviewed.', { exact: true })).toBeVisible()
    await expect(
      page.getByText('Blue words change between spoken and written Finnish.', { exact: true }),
    ).toBeVisible()
  })

  test('[design 12] Play lights each spoken word in turn, Pause holds it, and the end is announced', async ({
    page,
  }) => {
    await page.clock.install()
    await openSample(page)
    const status = page.getByRole('status')
    await expect(status).toHaveText(/^No sound yet/)
    expect(await spokenWordNow(page)).toBeNull()

    // Nothing was lit before Play (checked above).
    const lit: (string | null)[] = [null]
    await page.getByRole('button', { name: 'Play the dialogue' }).click()
    await advanceUntil(page, 'Moi', lit)
    await expect(status).toHaveText(/^Playing\./)
    await advanceUntil(page, 'Mä', lit)

    // Pause holds whichever word is lit when the page shows "Paused." (on a
    // slow preview link the next word may already have come).
    await page.getByRole('button', { name: 'Pause the dialogue' }).click()
    await expect(status).toHaveText(/^Paused\./)
    const held = await spokenWordNow(page)
    expect(['Mä', 'oon']).toContain(held)
    if (held !== lit.at(-1)) lit.push(held)
    await page.clock.runFor(3000)
    expect(await spokenWordNow(page)).toBe(held)

    await page.getByRole('button', { name: 'Play the dialogue' }).click()
    await advanceUntil(page, null, lit)
    // Every spoken word lit once, in order, and nothing after the last.
    expect(lit).toEqual([null, 'Moi', 'Mä', 'oon', 'Alex', 'Mist', 'sä', 'oot', 'kotoisin', null])
    await expect(status).toHaveText(/whole dialogue/)
  })

  test('[design 15] the page declares light and dark, and follows the phone’s setting', async ({
    browser,
  }) => {
    // Round 2: the page background is now v2's fade (owner's decision,
    // 21 October 2026), so the test reads the page's background image and
    // checks its first and last colour in each mode.
    for (const [scheme, top, bottom] of [
      ['light', 'rgb(255, 255, 255)', 'rgb(241, 240, 246)'],
      ['dark', 'rgb(18, 17, 23)', 'rgb(23, 22, 29)'],
    ] as const) {
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await openSample(page)
      await expect(page.locator('meta[name="color-scheme"]')).toHaveAttribute('content', 'light dark')
      const image = await page.evaluate<string>('getComputedStyle(document.documentElement).backgroundImage')
      expect(image, scheme).toContain(top)
      expect(image, scheme).toContain(bottom)
      await context.close()
    }
  })
})
