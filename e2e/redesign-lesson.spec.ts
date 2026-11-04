import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page } from '@playwright/test'
import { mockLesson, type LessonMocks } from './lesson-mocks.ts'
import { microphoneCalls, stubMicrophone } from './microphone.ts'
import { dismissTip, leaveLesson, sheetsSettled } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. These answer the lesson's reads and writes
// themselves (e2e/lesson-mocks.ts), so they need no database.

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']

/** One computed style of the element. The e2e files have no DOM types, so the page's function is reached through a cast. */
const styleOf = (locator: Locator, property: string): Promise<string> =>
  locator.evaluate(
    (el, name) =>
      (
        globalThis as unknown as { getComputedStyle: (e: unknown) => Record<string, string | undefined> }
      ).getComputedStyle(el)[name] ?? '',
    property,
  )

async function open(page: Page, mocks: LessonMocks = {}) {
  const calls = await mockLesson(page, mocks)
  await page.goto('/learn/session')
  return calls
}

const hearIt = (page: Page) => expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()

/**
 * Fast route hear-and-say: with speaking feedback on (the mocks' default), "Next line" comes only after a
 * try or after "I can't speak right now", which lets the learner hear the rest of the lines.
 */
const cantSpeak = (page: Page) => page.getByRole('button', { name: "I can't speak right now" }).click()

/** The Recap's hint without speaking feedback (src/screens/SayIt.tsx, RECAP_ALOUD). */
const RECAP_ALOUD = 'Say it out loud from memory, then show the Finnish.'

/**
 * Playwright's Windows WebKit build has no Web Audio (no AudioContext), so the app's own support check
 * (src/lib/recorder.ts, recordingSupported) rightly says "Recording is not available in this browser." and the
 * microphone stand-ins of e2e/microphone.ts cannot help. A test that needs the record button skips there, with
 * this reason; the Linux WebKit of the GitHub run has Web Audio and runs it.
 */
const NO_WEB_AUDIO = 'This WebKit build has no Web Audio, so the app cannot record here (Windows WebKit).'
const hasWebAudio = (page: Page) =>
  page.evaluate<boolean>("typeof AudioContext === 'function' || typeof webkitAudioContext === 'function'")

test.describe('the lesson frame and the leave sheet', () => {
  test('[redesign 21] the frame has the cross, a bar named by its step and the step name as the one h1', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await expect(page.getByRole('heading', { level: 1 })).toHaveCount(1)
    await expect(page.getByRole('progressbar', { name: 'Hear it, say it, step 1 of 3' })).toBeVisible()
    const cross = await page.getByRole('button', { name: 'Leave session' }).boundingBox()
    expect(cross?.width ?? 0).toBeGreaterThanOrEqual(44)
    expect(cross?.height ?? 0).toBeGreaterThanOrEqual(44)
  })

  // Round 6 (owner, item 8): the band is the drawing's 280 x 170 shape and starts under the phone's own
  // status strip, as drawn, so about 185 px of it shows on a 375 px screen (the spec's "about 210").
  test('[redesign 4] the band behind the top is an inline drawing: hidden from screen readers, no image file, no request of its own, about 185 to 210 px on screen', async ({
    page,
  }) => {
    const requests: string[] = []
    page.on('request', (request) => requests.push(request.resourceType()))
    await open(page)
    await hearIt(page)
    const band = await page.evaluate<{
      hidden: boolean
      height: number
      bottom: number
      images: number
      fills: string[]
    }>(`(() => {
      const svg = [...document.querySelectorAll('div[aria-hidden="true"] > svg')][0]
      const box = svg.parentElement
      return {
        hidden: box.getAttribute('aria-hidden') === 'true',
        height: Math.round(box.getBoundingClientRect().height),
        bottom: Math.round(box.getBoundingClientRect().bottom),
        images: document.querySelectorAll('img, picture, image, video, canvas').length,
        fills: [...svg.querySelectorAll('[fill]')].map((el) => el.getAttribute('fill')).filter((f) => /^#/.test(f ?? '')),
      }
    })()`)
    expect(band.hidden).toBe(true)
    expect(band.bottom).toBeGreaterThanOrEqual(175)
    expect(band.bottom).toBeLessThanOrEqual(220)
    expect(Math.abs(band.height - Math.round((375 * 170) / 280))).toBeLessThanOrEqual(1)
    expect(band.images).toBe(0)
    // The art's colours come from tokens, not from colour values written into the drawing.
    expect(band.fills).toEqual([])
    expect(requests.filter((type) => ['image', 'media'].includes(type))).toEqual([])
  })

  test('[redesign 21] the bar fills by the share of the lesson done: a line shown moves it, a step finished moves it more', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    const bar = page.getByRole('progressbar', { name: 'Hear it, say it, step 1 of 3' })
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    const first = Number(await bar.getAttribute('aria-valuenow'))
    await page.getByRole('button', { name: 'Next line' }).click()
    const second = Number(await bar.getAttribute('aria-valuenow'))
    expect(second).toBeGreaterThan(first)
    await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    const next = page.getByRole('progressbar', { name: 'Understand it, step 2 of 3' })
    await expect(next).toBeVisible()
    expect(Number(await next.getAttribute('aria-valuenow'))).toBeGreaterThan(30)
  })

  // Round 4 (evaluator, statement 22): Safari does not focus a button when it is tapped, so what the page
  // remembers as "the opener" is the body. A mousedown that is not allowed to move focus does the same in
  // every browser, so these taps behave like a real iPhone's, also on the Linux WebKit the checks run on.
  const TAP_DOES_NOT_FOCUS = "document.addEventListener('mousedown', (event) => event.preventDefault(), true)"

  test('[redesign 22] a tap on the cross, then a tap on Keep going or on the dimmed page, gives focus back to the cross even where a tap does not focus a button', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await page.evaluate(TAP_DOES_NOT_FOCUS)
    const cross = page.getByRole('button', { name: 'Leave session' })
    for (const how of ['Keep going', 'the dimmed page'] as const) {
      await cross.click()
      const sheet = page.getByRole('dialog', { name: 'Leave this lesson?' })
      await expect(sheet).toBeVisible()
      if (how === 'Keep going') await sheet.getByRole('button', { name: 'Keep going' }).click()
      else await page.mouse.click(187, 8)
      await expect(sheet).toBeHidden()
      await expect(cross, `after a tap on ${how}`).toBeFocused()
    }
  })

  test('[redesign 22] a tap on the cross, then Escape, gives focus back to the cross even where a tap does not focus a button', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await page.evaluate(TAP_DOES_NOT_FOCUS)
    const cross = page.getByRole('button', { name: 'Leave session' })
    await cross.click()
    await expect(page.getByRole('dialog', { name: 'Leave this lesson?' })).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(page.getByRole('dialog', { name: 'Leave this lesson?' })).toBeHidden()
    await expect(cross).toBeFocused()
  })

  test('[redesign 22] the cross opens "Leave this lesson?"; Keep going closes it and gives focus back to the cross', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    const cross = page.getByRole('button', { name: 'Leave session' })
    await cross.click()
    const sheet = page.getByRole('dialog', { name: 'Leave this lesson?' })
    await expect(sheet).toBeVisible()
    await expect(sheet.getByText('You can carry on later from here.')).toBeVisible()
    await sheet.getByRole('button', { name: 'Keep going' }).click()
    await expect(sheet).toBeHidden()
    await expect(cross).toBeFocused()
  })

  // Round 4 (evaluator, statement 43): the helpers the browser tests use to leave a lesson looked once for the
  // tip and the consent sheet. When the voice settings arrive late, the consent sheet opens a moment after
  // Say it appears, and the helper pressed the cross under it. They now wait for the screen to settle.
  // Fast route hear-and-say: the old Say it step is now the Recap (stored step "say"), named "Recap".
  test('[redesign 22] leaving the Recap by the helper works when the voice settings arrive late and the consent sheet opens after the screen', async ({
    page,
  }) => {
    await open(page, { step: 'understand', processing: 'not_asked' })
    await page.route('**/api/voice', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 900))
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          available: true,
          region: null,
          processing: 'not_asked',
          retention: false,
          recordings: [],
        }),
      })
    })
    await page.reload()
    await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeAttached()
    // The helper waits for the screen to settle: it does not come back while the voice settings are
    // still on their way, so it cannot look for the sheet a moment too early.
    const started = Date.now()
    await sheetsSettled(page)
    expect(Date.now() - started).toBeGreaterThan(300)
    await expect(page.getByRole('dialog', { name: 'Say it out loud' })).toBeVisible()
    await leaveLesson(page)
    await page.waitForURL((url) => url.pathname === '/learn')
  })

  test('[redesign 25] closing the first lesson tip by the helper works when the tip is drawn a moment after the screen', async ({
    page,
  }) => {
    await open(page, { firstLesson: true })
    await dismissTip(page)
    await expect(page.getByRole('dialog', { name: 'How this screen works' })).toBeHidden()
  })

  // Round 5 (evaluator, statement 47): every other place that opens a sheet is checked the same way, with a tap
  // that does not move focus. (The switch in Voice settings is in e2e/redesign-pages.spec.ts.)
  // Fast route hear-and-say: Say it is now the Recap, whose hint without speaking feedback is its own.
  test('[redesign 47] the quiet "Turn on speaking feedback" in the Recap opens the consent sheet, and Not now, Escape and the dimmed page give focus back to it after a tap', async ({
    page,
  }) => {
    await open(page, { step: 'understand', processing: 'withdrawn' })
    await expect(page.getByText(RECAP_ALOUD)).toBeVisible()
    await page.evaluate(TAP_DOES_NOT_FOCUS)
    const opener = page.getByRole('button', { name: 'Turn on speaking feedback' })
    for (const how of ['Not now', 'Escape', 'the dimmed page'] as const) {
      await opener.click()
      const sheet = page.getByRole('dialog', { name: 'Say it out loud' })
      await expect(sheet).toBeVisible()
      if (how === 'Not now') await sheet.getByRole('button', { name: 'Not now' }).click()
      else if (how === 'Escape') await page.keyboard.press('Escape')
      else await page.mouse.click(187, 8)
      await expect(sheet).toBeHidden()
      await expect(opener, `after ${how}`).toBeFocused()
    }
  })

  test('[redesign 47] a tap on a word opens its card, and Close and Escape give focus back to the word after a tap that does not focus', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await page.evaluate(TAP_DOES_NOT_FOCUS)
    const word = page.locator('[data-line-id]').getByRole('button', { name: 'noi', exact: true })
    for (const how of ['Close', 'Escape'] as const) {
      await word.click()
      const card = page.getByRole('dialog', { name: 'noi' })
      await expect(card).toBeVisible()
      if (how === 'Close') await card.getByRole('button', { name: 'Close' }).click()
      else await page.keyboard.press('Escape')
      await expect(card).toBeHidden()
      await expect(word, `after ${how}`).toBeFocused()
    }
  })

  test('[redesign 22] Escape closes the sheet, the page behind cannot be used or scrolled, and Leave goes to the road', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await page.getByRole('button', { name: 'Leave session' }).click()
    const sheet = page.getByRole('dialog', { name: 'Leave this lesson?' })
    await expect(sheet).toBeVisible()
    expect(await page.evaluate<string>('document.documentElement.style.overflow')).toBe('hidden')
    await page.keyboard.press('Escape')
    await expect(sheet).toBeHidden()
    await page.getByRole('button', { name: 'Leave session' }).click()
    await page
      .getByRole('dialog', { name: 'Leave this lesson?' })
      .getByRole('button', { name: 'Leave' })
      .click()
    await page.waitForURL((url) => url.pathname === '/learn')
  })

  // Round 6 (owner, item 26): no bar and no "Lesson finished" on the finish screen, as drawn (the bar stays
  // for screen readers). The cross stays as a link that leaves at once (job 18, statement 12), so no sheet.
  test('[redesign 22] [redesign 33] the finish screen has no drawn bar and no sheet: its cross leaves at once', async ({
    page,
  }) => {
    await open(page, { step: 'say' })
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    const cross = page.getByRole('link', { name: 'Leave session' })
    // The app moved under /learn (src/lib/app-paths.ts), so the cross leaves to the road there.
    await expect(cross).toHaveAttribute('href', '/learn')
    await expect(page.getByRole('button', { name: 'Leave session' })).toHaveCount(0)
    const bar = page.getByRole('progressbar', { name: 'Session finished' })
    await expect(bar).toBeAttached()
    expect(await bar.evaluate((el) => (el as unknown as { clientWidth: number }).clientWidth)).toBeLessThan(3)
  })
})

test.describe('Hear it and its line card', () => {
  test('[redesign 23] [redesign 24] one line card at a time, with the speaker, the count, no labels, and a play button on each line', async ({
    page,
  }) => {
    const calls = await open(page)
    await hearIt(page)
    await expect(page.locator('[data-line-id]')).toHaveCount(1)
    await expect(page.getByText('Pekka', { exact: true })).toBeVisible()
    await expect(page.getByText('Line 1 of 3', { exact: true })).toBeVisible()
    await expect(page.getByText('How much are those strawberries?')).toBeVisible()
    for (const gone of ['Spoken', 'Written', 'Unit goal', 'Dialogue', 'Press play to hear each line']) {
      await expect(page.getByText(gone, { exact: true })).toHaveCount(0)
    }
    await expect(page.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Play the written line' })).toBeVisible()
    // The status line says the same, for screen readers.
    await expect(page.getByRole('status')).toHaveText('Line 1 of 3.')
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    // The next line replaces the card; the last line says Continue. Nothing plays by itself.
    await page.getByRole('button', { name: 'Next line' }).click()
    await expect(page.locator('[data-line-id]')).toHaveCount(1)
    await expect(page.getByText('Maria', { exact: true })).toBeVisible()
    await page.getByRole('button', { name: 'Next line' }).click()
    await expect(page.getByRole('button', { name: 'Continue' })).toBeVisible()
    expect(calls.audio).toEqual([])
  })

  test('[redesign 23] [redesign 46] the rows of a Finnish line are about 1.4 apart while every word is still a 44 px target', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    const rows = await page.evaluate<{ pitch: number; size: number; rows: number; short: number }>(`(() => {
      const line = document.querySelector('[data-line-id] p[lang="fi"]')
      const size = parseFloat(getComputedStyle(line).fontSize)
      // The tops of the text itself, one per row (words in one row are within a pixel or two of each other).
      const found = []
      const walker = document.createTreeWalker(line, NodeFilter.SHOW_TEXT)
      for (let node = walker.nextNode(); node; node = walker.nextNode()) {
        if (!node.textContent.trim()) continue
        const range = document.createRange()
        range.selectNodeContents(node)
        for (const box of range.getClientRects()) if (box.width > 2) found.push(box.top)
      }
      found.sort((a, b) => a - b)
      const tops = []
      for (const top of found) if (tops.length === 0 || top - tops[tops.length - 1] > size * 0.5) tops.push(top)
      const buttons = [...line.querySelectorAll('button')].map((b) => b.getBoundingClientRect().height)
      return { pitch: tops.length > 1 ? (tops[tops.length - 1] - tops[0]) / (tops.length - 1) : 0, size, rows: tops.length, short: buttons.filter((h) => h < 43.5).length }
    })()`)
    expect(rows.rows).toBeGreaterThan(1)
    expect(rows.pitch / rows.size).toBeLessThan(1.6)
    expect(rows.pitch / rows.size).toBeGreaterThan(1.2)
    expect(rows.short).toBe(0)
  })

  test('[redesign 23] a word with word data is a button and a word without it is plain text', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    const card = page.locator('[data-line-id]')
    await expect(card.getByRole('button', { name: 'noi', exact: true })).toBeVisible()
    await expect(card.getByRole('button', { name: 'mansikat' })).toHaveCount(0)
    await expect(card.getByText('mansikat').first()).toBeVisible()
  })

  test('[redesign 2] the spoken dot is mint, the written dot and line are slate, and a changed word is peach on its wash in both lines', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    const colours = await page.evaluate<{
      dotSpoken: string
      dotWritten: string
      spoken: { text: string; color: string; background: string; ring: string }[]
      written: { text: string; color: string; background: string; ring: string }[]
    }>(
      `(() => {
        const read = (group) => [...document.querySelectorAll('[role="group"][aria-label="' + group + '"] [class*="face"]')].map((el) => {
          const s = getComputedStyle(el)
          return { text: el.textContent, color: s.color, background: s.backgroundColor, ring: s.boxShadow }
        })
        return {
          dotSpoken: getComputedStyle(document.querySelector('[class*="dotSpoken"]')).backgroundColor,
          dotWritten: getComputedStyle(document.querySelector('[class*="dotWritten"]')).backgroundColor,
          spoken: read('How people say it'),
          written: read('How it is written'),
        }
      })()`,
    )
    expect(colours.dotSpoken).toBe('rgb(30, 133, 111)')
    expect(colours.dotWritten).toBe('rgb(56, 82, 122)')
    for (const word of colours.spoken) {
      if (word.text === 'noi') {
        expect(word.color).toBe('rgb(127, 54, 24)')
        expect(word.background).toBe('rgb(253, 228, 216)')
        // The drawn thin peach ring (round 2, design review): 1 px, inside, in the peach mark colour.
        expect(word.ring).toBe('rgb(219, 114, 73) 0px 0px 0px 1px inset')
      } else {
        expect(word.color, word.text).toBe('rgb(27, 42, 38)')
        expect(word.background, word.text).toBe('rgba(0, 0, 0, 0)')
        expect(word.ring, word.text).toBe('none')
      }
    }
    for (const word of colours.written) {
      if (word.text === 'nuo') {
        expect(word.color).toBe('rgb(127, 54, 24)')
        expect(word.background).toBe('rgb(253, 228, 216)')
        expect(word.ring).toBe('rgb(219, 114, 73) 0px 0px 0px 1px inset')
      } else {
        expect(word.color, word.text).toBe('rgb(56, 82, 122)')
        expect(word.background, word.text).toBe('rgba(0, 0, 0, 0)')
        expect(word.ring, word.text).toBe('none')
      }
    }
  })

  // Round 4 (evaluator): a fast double tap on "Next line" moved two lines, so a line could be skipped
  // without being read. A second tap in the same moment is ignored; a tap after a pause moves on.
  test('[redesign 24] a double click on "Next line" moves one line, and a later click moves the next', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    await page.getByRole('button', { name: 'Next line' }).dblclick()
    await expect(page.getByRole('status')).toHaveText('Line 2 of 3.')
    await page.waitForTimeout(600)
    await expect(page.getByRole('status')).toHaveText('Line 2 of 3.')
    await page.getByRole('button', { name: 'Next line' }).click()
    await expect(page.getByRole('status')).toHaveText('Line 3 of 3.')
  })

  test('[redesign 24] two quick taps with a finger on "Next line" move one line, and a tap after a pause moves the next', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    const box = await page.getByRole('button', { name: 'Next line' }).boundingBox()
    const x = (box?.x ?? 0) + (box?.width ?? 0) / 2
    const y = (box?.y ?? 0) + (box?.height ?? 0) / 2
    await page.touchscreen.tap(x, y)
    await page.touchscreen.tap(x, y)
    await expect(page.getByRole('status')).toHaveText('Line 2 of 3.')
    await page.waitForTimeout(700)
    await page.touchscreen.tap(x, y)
    await expect(page.getByRole('status')).toHaveText('Line 3 of 3.')
  })

  test('[redesign 24] the last line says Continue and stores the step', async ({ page }) => {
    const calls = await open(page)
    await hearIt(page)
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeAttached()
    expect(calls.steps).toEqual(['hear'])
  })
})

test.describe('the tip on the first lesson', () => {
  test('[redesign 25] shows on a first lesson with three lines and "Got it", replacing the old help and the blue words line', async ({
    page,
    browserName,
  }) => {
    // Fast route hear-and-say: the record button comes after the tip, so the microphone stand-ins are added
    // where a browser lacks them (Playwright's Linux WebKit), as for every recording test.
    await stubMicrophone(page, 'tone')
    await open(page, { firstLesson: true })
    await hearIt(page)
    const tip = page.getByRole('dialog', { name: 'How this screen works' })
    await expect(tip).toBeVisible()
    await expect(tip.getByText('How people say it')).toBeVisible()
    await expect(tip.getByText('How it’s written').or(tip.getByText("How it's written"))).toBeVisible()
    await expect(tip.getByText('Tap any word to learn it')).toBeVisible()
    // Fast route hear-and-say: the tip also says the learner says each line back.
    await expect(tip.getByText('After each line, say it back.')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Got it' })).toBeFocused()
    await expect(page.getByText('Blue words change')).toHaveCount(0)
    // Tab cannot reach the page behind: the focus stays in the lit card and the tip.
    const tab = browserName === 'webkit' ? 'Alt+Tab' : 'Tab'
    for (let i = 0; i < 8; i += 1) {
      await page.keyboard.press(tab)
      expect(
        await page.evaluate<boolean>('document.querySelector("main").contains(document.activeElement)'),
      ).toBe(true)
    }
    await page.getByRole('button', { name: 'Got it' }).click()
    await expect(tip).toBeHidden()
    // Fast route hear-and-say: before a try there is no "Next line" yet, so focus goes to the line's next
    // action, "I can't speak right now" (src/screens/SayIt.tsx, afterTip). Where the browser cannot record
    // (Windows WebKit has no Web Audio), "Next line" is there at once and focus goes to it, as before.
    if (await hasWebAudio(page)) {
      await expect(page.getByRole('button', { name: 'Record yourself saying the line' })).toBeVisible()
      await expect(page.getByRole('button', { name: "I can't speak right now" })).toBeFocused()
    } else {
      await expect(page.getByRole('button', { name: 'Recording is not available' })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Next line' })).toBeFocused()
    }
  })

  test('[redesign 25] Escape closes it, and a reload shows it again while the lesson is still at Hear it', async ({
    page,
  }) => {
    await open(page, { firstLesson: true })
    await hearIt(page)
    const tip = page.getByRole('dialog', { name: 'How this screen works' })
    await expect(tip).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(tip).toBeHidden()
    await page.reload()
    await expect(page.getByRole('dialog', { name: 'How this screen works' })).toBeVisible()
    // Nothing is kept on the phone for it.
    expect(await page.evaluate<number>('localStorage.length + sessionStorage.length')).toBe(0)
    expect(await page.evaluate<string>('document.cookie')).toBe('')
  })

  test('[redesign 25] does not show on a later session, and a word card from the lit card opens over it', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await expect(page.getByRole('dialog', { name: 'How this screen works' })).toHaveCount(0)
    const first = await page.context().newPage()
    await open(first, { firstLesson: true })
    await first.getByRole('button', { name: 'noi', exact: true }).click()
    await expect(first.getByRole('dialog', { name: 'noi' })).toBeVisible()
    await first.keyboard.press('Escape')
    await expect(first.getByRole('dialog', { name: 'noi' })).toBeHidden()
    await expect(first.getByRole('dialog', { name: 'How this screen works' })).toBeVisible()
  })
})

test.describe('the word card', () => {
  test(
    '[redesign 26] [redesign 27] shows the word, its meaning, both registers, the dictionary form and the reason behind a tap',
    { tag: '@smoke' },
    async ({ page }) => {
      await open(page)
      // Fast route word-audio: the card asks for the word's own clip at /audio/words/, and the mocks answer
      // every audio address. These words have no approved clip, so the card plays the whole line.
      await page.route('**/audio/words/**', (route) => route.fulfill({ status: 404 }))
      await hearIt(page)
      const opener = page.locator('[data-line-id]').getByRole('button', { name: 'noi', exact: true })
      await opener.click()
      const card = page.getByRole('dialog', { name: 'noi' })
      await expect(card).toBeVisible()
      await expect(card.getByText('those', { exact: true })).toBeVisible()
      await expect(card.getByText('People say')).toBeVisible()
      await expect(card.getByText('Books write')).toBeVisible()
      await expect(card.getByText('Dictionary form')).toBeVisible()
      await expect(card.getByText('that', { exact: true })).toBeVisible()
      // Round 6 (item 21): "Plays the whole line." is not drawn; the play buttons' names say it.
      const caption = card.getByText('Plays the whole line.')
      expect((await caption.boundingBox())?.width ?? 0).toBeLessThan(3)
      await expect(card.getByText('Spoken Finnish says noi where books write nuo.')).toHaveCount(0)
      await card.getByRole('button', { name: 'Why does it change?' }).click()
      await expect(card.getByText('Spoken Finnish says noi where books write nuo.')).toBeVisible()
      await expect(card.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
      await expect(card.getByRole('button', { name: 'Play the written line' })).toBeVisible()
      await card.getByRole('button', { name: 'Close' }).click()
      await expect(card).toBeHidden()
      await expect(opener).toBeFocused()
    },
  )

  test('[redesign 27] a form with no meanings shows no invented meaning line', async ({ page }) => {
    await open(page)
    await hearIt(page)
    // Fast route hear-and-say: "Next line" waits for a try, so the learner chooses to only hear the lines.
    await cantSpeak(page)
    await page.getByRole('button', { name: 'Next line' }).click()
    await page.locator('[data-line-id]').getByRole('button', { name: 'mä', exact: true }).click()
    const card = page.getByRole('dialog', { name: 'mä' })
    await expect(card).toBeVisible()
    await expect(card.getByText('Dictionary form')).toBeVisible()
    await expect(card.getByText('minä', { exact: true }).first()).toBeVisible()
    expect(
      await card
        .locator('p')
        .filter({ hasText: /^those$/ })
        .count(),
    ).toBe(0)
    // The card holds only the facts it has: the word, two tiles, the dictionary form and the notes.
    const paragraphs = await card.locator('p').allInnerTexts()
    expect(paragraphs.some((text) => /meaning|means/i.test(text))).toBe(false)
  })
})

test.describe('Understand it', () => {
  test('[redesign 28] the spoken line is one milky card, not a card inside a card', async ({ page }) => {
    await open(page, { step: 'hear' })
    await expect(page.getByRole('heading', { level: 2, name: 'What does this mean?' })).toBeVisible()
    const look = await page.evaluate<{ shadow: string; fill: string; panels: number }>(`(() => {
      const outer = document.querySelector('[data-line-id]')
      const style = getComputedStyle(outer)
      const panels = [...outer.querySelectorAll('*')].filter((el) => {
        const s = getComputedStyle(el)
        const box = el.getBoundingClientRect()
        return s.boxShadow !== 'none' && s.backgroundColor !== 'rgba(0, 0, 0, 0)' && box.width > 150 && box.height > 50
      })
      return { shadow: style.boxShadow, fill: style.backgroundColor, panels: panels.length }
    })()`)
    expect(look.fill).toBe('rgba(0, 0, 0, 0)')
    expect(look.shadow).toBe('none')
    expect(look.panels).toBe(1)
  })

  test('[redesign 28] the question, one spoken line with one play button, three rows, and Next unavailable until the answer is right', async ({
    page,
  }) => {
    await open(page, { step: 'hear' })
    await expect(page.getByRole('heading', { level: 2, name: 'What does this mean?' })).toBeVisible()
    const card = page.locator('[data-line-id]')
    await expect(card.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play the written line' })).toHaveCount(0)
    const rows = page.getByRole('list').getByRole('button')
    await expect(rows).toHaveCount(3)
    const next = page.getByRole('button', { name: 'Next', exact: true })
    await expect(next).toBeDisabled()
    for (let i = 0; i < 3; i += 1) {
      await rows.nth(i).click()
      if ((await page.getByRole('status').innerText()) === 'Yes, that is right.') break
      await expect(page.getByRole('status')).toHaveText('Not this one. Listen again and try another.')
    }
    await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
    await expect(next).toBeEnabled()
  })
})

test.describe('the speaking consent sheet', () => {
  // The shared stub counts every getUserMedia call, and adds stand-ins where Playwright's Linux
  // WebKit has no MediaRecorder, so the record button is the real one in both browsers.
  async function noMicrophone(page: Page) {
    await stubMicrophone(page, 'tone')
  }

  // Fast route hear-and-say: the learner now meets the consent sheet in the first step, "Hear it, say it",
  // before the first line is said back, so these open the lesson there (they opened Say it before).
  test('[redesign 29] shows only the title, "How it works", "Turn on" and "Not now", with no box and no microphone request', async ({
    page,
  }) => {
    await noMicrophone(page)
    await open(page, { processing: 'not_asked' })
    await hearIt(page)
    const sheet = page.getByRole('dialog', { name: 'Say it out loud' })
    await expect(sheet).toBeVisible()
    await expect(sheet.getByRole('link', { name: /How it works/ })).toHaveAttribute(
      'href',
      /\/privacy#privacy-voice$/,
    )
    await expect(sheet.getByRole('button', { name: 'Turn on speaking feedback' })).toHaveText('Turn on')
    await expect(sheet.getByRole('button', { name: 'Not now' })).toBeVisible()
    await expect(sheet.getByRole('checkbox')).toHaveCount(0)
    expect(await microphoneCalls(page)).toBe(0)
  })

  test('[redesign 29] "Turn on" records one choice with the box unticked, and still asks for no microphone', async ({
    page,
  }) => {
    await noMicrophone(page)
    const calls = await open(page, { processing: 'not_asked' })
    await hearIt(page)
    await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect(page.getByRole('dialog', { name: 'Say it out loud' })).toBeHidden()
    expect(calls.consent).toEqual([{ choice: 'turn_on', keepRecordings: false }])
    if (await hasWebAudio(page)) {
      await expect(page.getByRole('button', { name: 'Record yourself saying the line' })).toBeVisible()
      // Hear it, say it keeps Say it's drawn hint (RECORD_HINTS in src/screens/SayIt.tsx).
      await expect(page.getByText('Tap and say the line', { exact: true })).toBeVisible()
    } else {
      // NO_WEB_AUDIO: the app says so instead of offering a button that cannot work.
      await expect(page.getByRole('button', { name: 'Recording is not available' })).toBeVisible()
    }
    expect(await microphoneCalls(page)).toBe(0)
  })

  // Fast route hear-and-say: without feedback the first step is Hear it again: each line with its play
  // buttons and "Next line", no record button, and the quiet way to turn feedback on.
  test('[redesign 29] "Not now" and Escape let the learner say each line without feedback and send nothing', async ({
    page,
  }) => {
    const calls = await open(page, { processing: 'not_asked' })
    await hearIt(page)
    await page.getByRole('button', { name: 'Not now' }).click()
    await expect(page.getByRole('dialog', { name: 'Say it out loud' })).toBeHidden()
    await expect(page.getByRole('button', { name: 'Next line' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Turn on speaking feedback' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Record yourself saying the line' })).toHaveCount(0)
    expect(calls.consent).toEqual([])
    const escape = await page.context().newPage()
    const second = await open(escape, { processing: 'not_asked' })
    await expect(escape.getByRole('dialog', { name: 'Say it out loud' })).toBeVisible()
    await escape.keyboard.press('Escape')
    await expect(escape.getByRole('dialog', { name: 'Say it out loud' })).toBeHidden()
    await expect(escape.getByRole('button', { name: 'Next line' })).toBeVisible()
    await expect(escape.getByRole('button', { name: 'Turn on speaking feedback' })).toBeVisible()
    await expect(escape.getByRole('button', { name: 'Record yourself saying the line' })).toHaveCount(0)
    expect(second.consent).toEqual([])
  })

  // Fast route hear-and-say: Say it is now the Recap, which still has "Next line" without speaking feedback.
  test('[redesign 30] a double click on "Next line" in the Recap moves one line, so no line is skipped', async ({
    page,
  }) => {
    await open(page, { step: 'understand', processing: 'withdrawn' })
    await expect(page.getByText(RECAP_ALOUD)).toBeVisible()
    await page.getByRole('button', { name: 'Next line' }).dblclick()
    await expect(page.getByRole('status')).toHaveText('Line 2 of 3.')
  })

  // Fast route hear-and-say: Say it is now the Recap. Its card covers the Finnish behind "Show the Finnish"
  // until a try, so the play buttons are looked for again once the Finnish shows, and its hint is its own.
  test(
    '[redesign 30] the Recap: the card without play buttons, the large record button, the hint and a quiet way out',
    { tag: '@smoke' },
    async ({ page }) => {
      await noMicrophone(page)
      await open(page, { step: 'understand' })
      await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeVisible()
      await expect(page.locator('[data-line-id]').getByRole('button', { name: /^Play/ })).toHaveCount(0)
      // Where the browser cannot record (NO_WEB_AUDIO), the same large button says so, with its reason
      // in place of the hint.
      const canRecord = await hasWebAudio(page)
      const record = page.getByRole('button', {
        name: canRecord ? 'Record yourself saying the line' : 'Recording is not available',
      })
      await expect(record).toBeVisible()
      const box = await record.boundingBox()
      expect(box?.width ?? 0).toBeGreaterThanOrEqual(80)
      // Round 6 (item 23): the drawing's hint, and "Line 1 of 3." is for screen readers only.
      await expect(
        page.getByText(
          canRecord ? 'Tap and say it in Finnish' : 'Recording is not available in this browser.',
          {
            exact: true,
          },
        ),
      ).toBeVisible()
      await expect(page.getByRole('button', { name: "I can't speak right now" })).toBeVisible()
      await expect(page.getByRole('status')).toHaveText('Line 1 of 3.')
      expect((await page.getByRole('status').boundingBox())?.width ?? 0).toBeLessThan(3)
      await page.locator('[data-line-id]').getByRole('button', { name: 'Show the Finnish' }).click()
      await expect(page.locator('[data-line-id] p[lang="fi"]').first()).toBeVisible()
      await expect(page.locator('[data-line-id]').getByRole('button', { name: /^Play/ })).toHaveCount(0)
    },
  )
})

test.describe('the finished lesson', () => {
  test('[redesign 33] the tick, the line card, the new words as chips that open their cards, and one status line', async ({
    page,
  }) => {
    await open(page, { step: 'say', newWords: 3, me: { kind: 'guest' } })
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    await expect(page.getByRole('heading', { level: 2, name: '3 new words' })).toBeVisible()
    const chips = page.getByRole('list').filter({ has: page.getByRole('button', { name: 'sana0' }) })
    await expect(chips.getByRole('button')).toHaveText(['sana0', 'sana1', 'sana2'])
    await page.getByRole('button', { name: 'sana1' }).click()
    await expect(page.getByRole('dialog', { name: 'sana1' })).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(page.getByRole('button', { name: 'sana1' })).toBeFocused()
    await expect(page.getByRole('status')).toHaveCount(1)
    await expect(page.getByRole('status')).toHaveText('Your progress is saved on this device.')
    // The drawing's "lines said aloud" figure is not built.
    await expect(page.getByText(/lines said aloud/)).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Send feedback' })).toBeVisible()
  })

  test(
    '[redesign 31] Keep it says "Type the missing word" once to the eye, and the status line carries it for screen readers',
    { tag: '@smoke' },
    async ({ page }) => {
      await open(page, { step: 'say', review: true })
      await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeAttached()
      await expect(page.getByLabel('Type the missing word', { exact: true })).toBeVisible()
      const seen = await page.evaluate<number>(`[...document.querySelectorAll('body *')]
      .filter((el) => el.children.length === 0 && el.textContent.trim().startsWith('Type the missing word'))
      .filter((el) => { const box = el.getBoundingClientRect(); return box.width > 2 && box.height > 2 })
      .length`)
      expect(seen).toBe(1)
      await expect(page.getByRole('status')).toHaveText('Type the missing word.')
    },
  )

  test('[redesign 33] the Done dock is a milky bar with a soft edge over the new words, not a hard cut', async ({
    page,
  }) => {
    await open(page, { step: 'say', newWords: 11, saveNote: 'first' })
    const done = page.getByRole('button', { name: 'Done', exact: true })
    await expect(done).toBeVisible()
    const dock = await page.evaluate<{ fill: string; shadow: string }>(`(() => {
      const button = [...document.querySelectorAll('button')].find((b) => b.textContent.trim() === 'Done')
      const style = getComputedStyle(button.parentElement)
      return { fill: style.backgroundColor, shadow: style.boxShadow }
    })()`)
    expect(dock.fill).not.toBe('rgba(0, 0, 0, 0)')
    expect(dock.shadow).not.toBe('none')
  })

  test('[redesign 33] one new word says "1 new word", and none shows no panel at all', async ({ page }) => {
    await open(page, { step: 'say', newWords: 1 })
    await expect(page.getByRole('heading', { level: 2, name: '1 new word' })).toBeVisible()
    const none = await page.context().newPage()
    await open(none, { step: 'say', newWords: 0 })
    await expect(none.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    await expect(none.getByText(/new word/)).toHaveCount(0)
  })

  test('[redesign 33] the save note: the owner’s words, "Create account" first, "Not now" quiet, and it is not a status', async ({
    page,
  }) => {
    await open(page, { step: 'say', saveNote: 'first', me: { kind: 'guest' } })
    const note = page.getByRole('region', { name: 'Keep your progress' })
    await expect(note.getByText('Create an account to save your progress.')).toBeVisible()
    await expect(note.getByRole('button', { name: 'Create account' })).toBeVisible()
    await expect(note.getByRole('button', { name: 'Not now' })).toBeVisible()
    await expect(page.getByRole('status')).toHaveCount(1)
    expect(await page.evaluate<boolean>('document.activeElement === document.body')).toBe(true)
    await note.getByRole('button', { name: 'Not now' }).click()
    await expect(page.getByText('No problem. You can add your email later from Your account.')).toBeFocused()
    await expect(page.getByRole('status')).toHaveCount(1)
  })

  // Round 6 (item 26): the drawing's "Saved to your account." in the shape of the guest's protected line.
  test('[redesign 33] an email account sees "Your progress is saved to your account." and no note', async ({
    page,
  }) => {
    await open(page, { step: 'say', me: { kind: 'email', email: 'maria@example.fi' } })
    await expect(page.getByRole('status')).toHaveText('Your progress is saved to your account.')
    await expect(page.getByRole('region', { name: 'Keep your progress' })).toHaveCount(0)
  })
})

test.describe('phone size, keyboard and screen reader', () => {
  const STEPS: [string, LessonMocks][] = [
    ['Hear it', {}],
    ['Hear it with the tip', { firstLesson: true }],
    ['Understand it', { step: 'hear' }],
    // Fast route hear-and-say: the step after Understand it is now the Recap (it was Say it).
    ['the Recap', { step: 'understand' }],
    ['the Recap with the sheet', { step: 'understand', processing: 'not_asked' }],
    ['the finish screen', { step: 'say', newWords: 4, saveNote: 'first' }],
  ]
  for (const [name, mocks] of STEPS) {
    test(`[redesign 46] [redesign 47] ${name}: no sideways scroll, controls at least 44 px, one h1, and axe finds nothing`, async ({
      page,
    }) => {
      await open(page, mocks)
      await expect(page.getByRole('heading', { level: 1 })).toHaveCount(1)
      await page.evaluate('document.fonts.ready')
      await page.waitForTimeout(300)
      expect(
        await page.evaluate<boolean>(
          'document.documentElement.scrollWidth <= document.documentElement.clientWidth',
        ),
      ).toBe(true)
      const small = await page.evaluate<string[]>(
        `[...document.querySelectorAll('button, a[href]')].filter((el) => {
          const box = el.getBoundingClientRect()
          const hidden = box.width === 0 || box.height === 0 || el.closest('dialog:not([open])') || getComputedStyle(el).visibility === 'hidden'
          return !hidden && !el.closest('[class*="keep"]') && (box.height < 43.5 || box.width < 23.5)
        }).map((el) => (el.getAttribute('aria-label') || el.textContent).trim())`,
      )
      expect(small).toEqual([])
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
    })
  }

  // Round 4 (evaluator, statements 5 and 46): the words of a line wrap when they are too long for it. The old
  // test looked at the group's box, which a word running past the card does not widen, so it passed for the
  // wrong reason. This one measures the box of each word itself against the line it sits in.
  const LONG = 'epäjärjestelmällistyttämättömyydelläänsäkään'
  const aForm = { lemma: 'pitkä', formName: 'Long', why: 'A made up long word.', spoken: LONG, written: LONG }

  async function lessonWith(page: Page, lines: unknown[], step: string | null = null) {
    await mockLesson(page)
    await page.route('**/api/sessions/today', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          state: 'ready',
          session: { id: 's1', step },
          unit: { title: 'U', canDo: 'C' },
          dialogue: { title: 'D' },
          lines,
        }),
      }),
    )
    await page.goto('/learn/session')
    // Fast route hear-and-say: the step after Understand it is now the Recap. Its card covers the Finnish
    // until a try, so the Finnish is shown here for the tests that measure it.
    await expect(
      page.getByRole('heading', { level: 1, name: step === null ? 'Hear it' : 'Recap' }),
    ).toBeVisible()
    if (step !== null) await page.getByRole('button', { name: 'Show the Finnish' }).click()
  }

  const lineOf = (id: number, spoken: unknown[], written: unknown[]) => ({
    id,
    speaker: 'Pekka',
    gloss: 'A long word.',
    spokenAudio: '/audio/a.wav',
    writtenAudio: '/audio/b.wav',
    spoken,
    written,
  })

  /** For each Finnish line of the card: the word boxes past the line's own right edge, and the punctuation alone on a row. */
  const WORD_BOXES = `(() => [...document.querySelectorAll('[data-line-id] p[lang="fi"]')].map((line) => {
    const edge = line.getBoundingClientRect().right
    const card = line.closest('[data-line-id]').getBoundingClientRect().right
    let past = 0
    let alone = 0
    for (const word of line.querySelectorAll('[data-word]')) {
      for (const box of word.getClientRects()) if (box.width > 1 && box.right > edge + 0.5) past += 1
      const texts = []
      const walker = document.createTreeWalker(word, NodeFilter.SHOW_TEXT)
      for (let node = walker.nextNode(); node; node = walker.nextNode()) if (node.textContent.trim()) texts.push(node)
      const last = texts.at(-1)
      const before = texts.at(-2)
      if (last && before && /^[^\\p{L}]+$/u.test(last.textContent)) {
        // The last letter and the punctuation after it must sit on one row: the same top, give or take a pixel.
        const rowOf = (node, from, to) => {
          const range = document.createRange()
          range.setStart(node, from)
          range.setEnd(node, to)
          return range.getBoundingClientRect().top
        }
        const letter = rowOf(before, before.textContent.length - 1, before.textContent.length)
        const mark = rowOf(last, 0, 1)
        if (Math.abs(letter - mark) > 3) alone += 1
      }
    }
    return { past, alone, edge, card }
  }))()`

  const variants: [string, unknown[]][] = [
    ['a plain word alone', [{ text: LONG }]],
    ['a tappable word alone', [{ text: LONG, form: aForm }]],
    [
      'a tappable word in the middle with punctuation',
      [{ text: 'Voinks' }, { text: LONG, form: aForm, after: '?' }, { text: 'maksaa', after: '.' }],
    ],
    [
      'a plain word in the middle with punctuation',
      [{ text: 'Voinks' }, { text: LONG, after: '!' }, { text: 'maksaa' }],
    ],
  ]
  for (const [name, words] of variants) {
    test(`[redesign 46] [redesign 5] a 44 letter Finnish word wraps inside its line at 375 px: ${name}`, async ({
      page,
    }) => {
      await lessonWith(page, [lineOf(1, words, words)])
      const lines =
        await page.evaluate<{ past: number; alone: number; edge: number; card: number }[]>(WORD_BOXES)
      expect(lines).toHaveLength(2)
      for (const line of lines) {
        expect(line.past, 'a word runs past the right edge of its line').toBe(0)
        expect(line.alone, 'punctuation is alone on a row').toBe(0)
        expect(line.edge).toBeLessThanOrEqual(line.card)
      }
      expect(
        await page.evaluate<boolean>(
          'document.documentElement.scrollWidth <= document.documentElement.clientWidth',
        ),
      ).toBe(true)
      // The word is still all there, in one piece for a screen reader.
      await expect(page.locator('[data-line-id] p[lang="fi"]').first()).toContainText(LONG)
    })
  }

  // Round 5 (evaluator, statement 46): a tappable word that wraps onto several rows is a tall button. Its
  // negative block margin then pulled its first row up over the row above, and its pieces were centred (a
  // lone "rin" in the middle of a row). Padding that is cancelled by the margin keeps the text where the line
  // puts it, and the pieces start at the left. These tests measure the text itself, not the buttons, with a
  // real 21 letter word after other words, in the spoken and in the written line, in Hear it and in Say it.
  const REAL = 'terveyskeskuslääkärin'
  // A word that wraps in each screen: the 21 letter word in Hear it, a longer one in the Recap (once Say it),
  // whose card has no play buttons and so a wider line.
  const wordsWith = (word: string) => [
    { text: 'Missä' },
    { text: 'on' },
    { text: word, form: { ...aForm, spoken: word, written: word } },
    { text: 'vastaanotto', after: '?' },
  ]

  /** For each Finnish line: how far the first piece of the tappable word sits above the bottom of the text row above it, and how far apart the left edges of its pieces are. */
  const wrappedWord = (word: string) =>
    `(() => [...document.querySelectorAll('[data-line-id] p[lang="fi"]')].map((line) => {
    const rectsOf = (node) => { const range = document.createRange(); range.selectNodeContents(node); return [...range.getClientRects()].filter((r) => r.width > 1) }
    const button = [...line.querySelectorAll('button')].find((b) => b.textContent.includes('__REAL__'))
    const face = button.querySelector('[class*="face"]')
    const pieces = rectsOf(face.firstChild).sort((a, b) => a.top - b.top)
    const rows = [...new Set(pieces.map((r) => Math.round(r.top)))].length
    const others = []
    const walker = document.createTreeWalker(line, NodeFilter.SHOW_TEXT)
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      if (!node.textContent.trim() || button.contains(node)) continue
      others.push(...rectsOf(node))
    }
    const above = others.filter((r) => r.bottom <= pieces[0].bottom - 4)
    const aboveBottom = above.length ? Math.max(...above.map((r) => r.bottom)) : -Infinity
    // The first piece starts after the word's own padding (the wash); every piece after it starts at the same left edge.
    const lefts = pieces.slice(1).map((r) => r.left)
    const buttonLeft = button.getBoundingClientRect().left
    // How far each piece after the first starts from the button's left edge: 0 when the text is left aligned.
    const spread = Math.max(0, ...lefts.map((left) => Math.abs(left - buttonLeft)))
    return { rows, overlap: aboveBottom - pieces[0].top, spread, buttonLeft: button.getBoundingClientRect().left, firstLeft: pieces[0].left }
  }))()`.replace('__REAL__', word)

  for (const [where, step, word] of [
    ['Hear it', null, REAL],
    ['the Recap', 'understand', REAL + 'vastaanottolääkäri'],
  ] as const) {
    test(`[redesign 46] [redesign 5] a 21 letter tappable word after other words does not run into the row above and its pieces start at the left, in ${where}`, async ({
      page,
    }) => {
      await lessonWith(page, [lineOf(1, wordsWith(word), wordsWith(word))], step)
      await expect(page.locator('[data-line-id]')).toBeVisible()
      const lines = await page.evaluate<
        { rows: number; overlap: number; spread: number; buttonLeft: number; firstLeft: number }[]
      >(wrappedWord(word))
      expect(lines).toHaveLength(2)
      // The bold spoken line wraps the word; the lighter written line may fit it whole. Every row that does wrap
      // is checked.
      expect(
        lines.some((line) => line.rows > 1),
        'the word really wrapped',
      ).toBe(true)
      for (const line of lines.filter((candidate) => candidate.rows > 1)) {
        expect(line.overlap, 'the word overlaps the text row above').toBeLessThanOrEqual(1)
        expect(line.spread, 'the pieces of the word are not left aligned').toBeLessThan(1)
        expect(line.firstLeft).toBeGreaterThanOrEqual(line.buttonLeft - 1)
      }
    })
  }

  test('[redesign 46] [redesign 5] a word and its punctuation still never part when a line wraps between its words', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 640 })
    const sentence = [
      { text: 'Voinks', form: aForm, after: ',' },
      { text: 'mä' },
      { text: 'maksaa', after: ',' },
      { text: 'kortilla', form: aForm, after: '?' },
      { text: 'Kyllä', after: ',' },
      { text: 'totta', form: aForm, after: '.' },
      { text: 'kahvilassa', after: '!' },
      { text: 'maksaa', form: aForm, after: '?' },
    ]
    await lessonWith(page, [lineOf(1, sentence, sentence)])
    const lines = await page.evaluate<{ past: number; alone: number; rows: number }[]>(WORD_BOXES)
    for (const line of lines) {
      expect(line.past).toBe(0)
      expect(line.alone).toBe(0)
    }
    // The line really did wrap between words, so the check means something.
    const rows = await page.evaluate<number>(`(() => {
      const line = document.querySelector('[data-line-id] p[lang="fi"]')
      return new Set([...line.querySelectorAll('[data-word]')].map((word) => Math.round(word.getBoundingClientRect().top / 8))).size
    })()`)
    expect(rows).toBeGreaterThan(2)
  })
})

// Round 6: the owner asked for the lesson screens to look exactly like the drawings
// (factory/jobs/19-redesign/owner-differences.md). These protect what changed on purpose.
test.describe('round 6, as drawn', () => {
  test('[redesign 20] [redesign 25] the tip: three white lines on the dimmed screen and "Got it" as a white pill with no mint edge', async ({
    page,
  }) => {
    await open(page, { firstLesson: true })
    const got = page.getByRole('button', { name: 'Got it' })
    await expect(got).toBeFocused()
    expect(await styleOf(got, 'backgroundColor')).toBe('rgb(255, 255, 255)')
    expect(await styleOf(got, 'boxShadow')).not.toContain('inset')
    expect(
      await styleOf(
        page.getByRole('dialog', { name: 'How this screen works' }).locator('li').first(),
        'color',
      ),
    ).toBe('rgb(255, 255, 255)')
    // White lines on the scrim pass the text floor (axe checks the colours it can see).
    const axe = await new AxeBuilder({ page }).withTags(TAGS).include('[role="dialog"]').analyze()
    expect(axe.violations).toEqual([])
  })

  test('[redesign 28] Understand it: "Understand" at the top right, the play button on the left of the line, and no drawn help line', async ({
    page,
  }) => {
    await open(page, { step: 'hear' })
    const heading = page.getByRole('heading', { level: 1, name: 'Understand it' })
    await expect(heading).toBeVisible()
    // "Understand" is drawn; " it" is there for screen readers only.
    expect(
      await heading.evaluate(
        (el) => (el as unknown as { firstChild: { textContent: string } }).firstChild.textContent,
      ),
    ).toBe('Understand')
    expect((await heading.locator('span').boundingBox())?.width ?? 0).toBeLessThan(3)
    const card = page.locator('[data-line-id]')
    const play = await card.getByRole('button', { name: 'Play the spoken line' }).boundingBox()
    const line = await card.locator('p[lang="fi"]').boundingBox()
    expect((play?.x ?? 0) < (line?.x ?? 0)).toBe(true)
    await expect(page.getByRole('status')).toHaveText('Choose what the line means.')
    expect((await page.getByRole('status').boundingBox())?.width ?? 0).toBeLessThan(3)
  })

  test('[redesign 33] the finish screen: the spoken line centred with its English, five chips then "+6", and the saved line small under Done', async ({
    page,
  }) => {
    await open(page, { step: 'say', newWords: 11, me: { kind: 'guest' } })
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    // No speaker; the written line and both play controls stay small (job 8, statement 14).
    const sentence = page.locator('[data-line-id]')
    await expect(sentence.getByRole('button')).toHaveCount(2)
    await expect(sentence.locator('p')).toHaveCount(3)
    expect(await styleOf(sentence, 'textAlign')).toBe('center')
    await expect(page.getByRole('heading', { level: 2, name: '11 new words' })).toBeVisible()
    const chips = page.getByRole('list').filter({ has: page.getByRole('button', { name: 'sana0' }) })
    await expect(chips.getByRole('button')).toHaveText(['sana0', 'sana1', 'sana2', 'sana3', 'sana4', '+6'])
    await chips.getByRole('button', { name: 'Show 6 more words' }).click()
    await expect(chips.getByRole('button')).toHaveCount(11)
    await expect(chips.getByRole('button', { name: 'sana5' })).toBeFocused()
    const status = page.getByRole('status')
    await expect(status).toHaveText('Your progress is saved on this device.')
    const done = await page.getByRole('button', { name: 'Done', exact: true }).boundingBox()
    const line = await status.boundingBox()
    expect((line?.y ?? 0) > (done?.y ?? 0)).toBe(true)
    expect(await styleOf(status, 'fontSize')).toBe('12.5px')
  })

  test('[redesign 31] Keep it right: the field keeps the answer with a mint edge and tick, the word is peach in both lines, and the long sentences are for screen readers', async ({
    page,
  }) => {
    await open(page, { step: 'say', review: true })
    await expect(page.getByText('Word 1 of 1.', { exact: true })).toBeVisible()
    await page.getByLabel('Type the missing word', { exact: true }).fill('maksaa')
    await page.getByRole('button', { name: 'Check', exact: true }).click()
    const feedback = page.locator('[data-review-feedback]')
    await expect(feedback).toBeVisible()
    await expect(page.getByText('Type the missing word', { exact: true })).toBeVisible()
    const echo = feedback.locator('p[aria-hidden="true"]', { hasText: 'maksaa' })
    await expect(echo).toBeVisible()
    expect(await styleOf(echo, 'borderTopColor')).toBe('rgb(30, 133, 111)')
    await expect(echo.locator('svg')).toHaveCount(1)
    let peach = 0
    for (const word of await feedback
      .locator('[data-line-id] [lang="fi"] span', { hasText: /^maksaa$/ })
      .all()) {
      if ((await styleOf(word, 'backgroundColor')) === 'rgb(253, 228, 216)') peach += 1
    }
    expect(peach).toBeGreaterThanOrEqual(2)
    for (const sentence of [/^The word is maksaa/, /^You wrote/]) {
      const text = feedback.getByText(sentence)
      await expect(text).toBeAttached()
      expect((await text.boundingBox())?.width ?? 0).toBeLessThan(3)
    }
    await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
  })

  test('[redesign 31] [redesign 42] Keep it close: the gentle peach note sits under the field and points up to the marked word', async ({
    page,
  }) => {
    await open(page, { step: 'say', review: true })
    await page.getByLabel('Type the missing word', { exact: true }).fill('maksa')
    await page.getByRole('button', { name: 'Check', exact: true }).click()
    const status = page.getByRole('status')
    await expect(status).toHaveText('Close. Check the spelling above.')
    await expect(status).toHaveAttribute('data-tone', 'gentle')
    const echo = await page.locator('[data-review-feedback] p[aria-hidden="true"]').boundingBox()
    const card = await page.locator('[data-review-feedback] [data-line-id]').boundingBox()
    const note = await status.boundingBox()
    expect((note?.y ?? 0) > (echo?.y ?? 0)).toBe(true)
    expect((card?.y ?? 0) < (note?.y ?? 0)).toBe(true)
  })

  // Follow up after the merge (owner, Keep it right and close pairs): as drawn, only the answer is marked
  // on the result. The changed word box (mä and minä in the mock line) would put a second mark beside it.
  for (const [answer, outcome] of [
    ['maksaa', 'right'],
    ['maksa', 'close'],
  ] as const) {
    test(`[redesign 31] Keep it ${outcome}: exactly one word per line carries a mark, the answer, in peach deep, bold in the spoken line`, async ({
      page,
    }) => {
      await open(page, { step: 'say', review: true })
      await page.getByLabel('Type the missing word', { exact: true }).fill(answer)
      await page.getByRole('button', { name: 'Check', exact: true }).click()
      const feedback = page.locator('[data-review-feedback]')
      await expect(feedback).toBeVisible()
      for (const group of ['How people say it', 'How it is written']) {
        // Every word face in the line, with what would show it as marked: a wash, a ring or a colour of its own.
        const faces = await feedback
          .getByRole('group', { name: group })
          .locator('[data-word] span[class*="face"]')
          .evaluateAll((spans) => {
            const view = globalThis as unknown as { getComputedStyle: (e: unknown) => Record<string, string> }
            return spans.map((span) => {
              const style = view.getComputedStyle(span)
              const line = view.getComputedStyle(
                (span as unknown as { closest: (s: string) => unknown }).closest('p'),
              )
              return {
                text: (span as unknown as { textContent: string }).textContent,
                wash: style.backgroundColor !== 'rgba(0, 0, 0, 0)',
                ring: style.boxShadow !== 'none',
                ownColour: style.color !== line.color,
                colour: style.color,
                weight: style.fontWeight,
              }
            })
          })
        expect(faces.length).toBeGreaterThan(2)
        const marked = faces.filter((face) => face.wash || face.ring || face.ownColour)
        expect(marked.map((face) => face.text)).toEqual(['maksaa'])
        const [mark] = marked
        expect(mark?.wash).toBe(true)
        expect(mark?.ring).toBe(false)
        // Peach deep, darkened to the 7 to 1 floor of a Finnish line (src/styles/contrast-pairs.ts).
        expect(mark?.colour).toBe('rgb(127, 54, 24)')
        expect(mark?.weight).toBe(group === 'How people say it' ? '700' : '400')
      }
      // Still named for screen readers, once per line.
      await expect(feedback.getByText(', the missing word')).toHaveCount(2)
    })
  }

  test('[redesign 2] the changed word box stays on Hear it', async ({ page }) => {
    await open(page)
    await hearIt(page)
    await expect(page.locator('[data-line-id] [lang="fi"] span[class*="changed"]').first()).toBeVisible()
  })

  // Fast route hear-and-say: each line is now said back in the first step, "Hear it, say it", so the try
  // again result is checked there (it was Say it's). "Next line" comes with the try.
  test('[redesign 30] Hear it, say it, try again: the peach note above the record button, which is now "Try again", "Play mine" small, and Next line stays (job 10)', async ({
    page,
    browserName,
  }) => {
    test.skip(
      browserName === 'webkit' && (process.env.PLAYWRIGHT_BASE_URL ?? '').startsWith('http://'),
      'WebKit records only on a secure page; the GitHub run serves HTTPS.',
    )
    await stubMicrophone(page, 'tone')
    await open(page)
    await hearIt(page)
    test.skip(!(await hasWebAudio(page)), NO_WEB_AUDIO)
    await expect(page.getByRole('button', { name: 'Next line' })).toHaveCount(0)
    await page.route('**/api/speech/say', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ feedbackClass: 'try_again' }),
      }),
    )
    await page.getByRole('button', { name: 'Record yourself saying the line' }).click()
    await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
    await page.waitForTimeout(1200)
    await page.getByRole('button', { name: /^Stop recording/ }).click()
    const again = page.getByRole('button', { name: 'Try again, record yourself saying the line' })
    await expect(again).toBeVisible({ timeout: 10_000 })
    await expect(page.getByRole('button', { name: 'Try again', exact: true })).toHaveCount(0)
    const note = await page.getByRole('status').boundingBox()
    const mic = await again.boundingBox()
    expect((note?.y ?? 0) < (mic?.y ?? 0)).toBe(true)
    await expect(page.getByRole('status')).toHaveAttribute('data-tone', 'gentle')
    await expect(page.getByRole('button', { name: 'Play mine' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Next line' })).toBeEnabled()
  })
})
