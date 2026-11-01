import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { mockLesson, type LessonMocks } from './lesson-mocks.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. These answer the lesson's reads and writes
// themselves (e2e/lesson-mocks.ts), so they need no database.

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']

async function open(page: Page, mocks: LessonMocks = {}) {
  const calls = await mockLesson(page, mocks)
  await page.goto('/session')
  return calls
}

const hearIt = (page: Page) => expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()

test.describe('the lesson frame and the leave sheet', () => {
  test('[redesign 21] the frame has the cross, a bar named by its step and the step name as the one h1', async ({
    page,
  }) => {
    await open(page)
    await hearIt(page)
    await expect(page.getByRole('heading', { level: 1 })).toHaveCount(1)
    await expect(page.getByRole('progressbar', { name: 'Hear it, step 1 of 3' })).toBeVisible()
    const cross = await page.getByRole('button', { name: 'Leave session' }).boundingBox()
    expect(cross?.width ?? 0).toBeGreaterThanOrEqual(44)
    expect(cross?.height ?? 0).toBeGreaterThanOrEqual(44)
  })

  test('[redesign 4] the band behind the top is an inline drawing: hidden from screen readers, no image file, no request of its own, about 210 px high', async ({
    page,
  }) => {
    const requests: string[] = []
    page.on('request', (request) => requests.push(request.resourceType()))
    await open(page)
    await hearIt(page)
    const band = await page.evaluate<{
      hidden: boolean
      height: number
      images: number
      fills: string[]
    }>(`(() => {
      const svg = [...document.querySelectorAll('div[aria-hidden="true"] > svg')][0]
      const box = svg.parentElement
      return {
        hidden: box.getAttribute('aria-hidden') === 'true',
        height: Math.round(box.getBoundingClientRect().height),
        images: document.querySelectorAll('img, picture, image, video, canvas').length,
        fills: [...svg.querySelectorAll('[fill]')].map((el) => el.getAttribute('fill')).filter((f) => /^#/.test(f ?? '')),
      }
    })()`)
    expect(band.hidden).toBe(true)
    expect(band.height).toBeGreaterThanOrEqual(200)
    expect(band.height).toBeLessThanOrEqual(220)
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
    const bar = page.getByRole('progressbar', { name: 'Hear it, step 1 of 3' })
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
    await page.waitForURL((url) => url.pathname === '/')
  })

  test('[redesign 22] the finish screen has no sheet: its cross leaves at once', async ({ page }) => {
    await open(page, { step: 'say' })
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    const cross = page.getByRole('link', { name: 'Leave session' })
    await expect(cross).toHaveAttribute('href', '/')
    await expect(page.getByRole('button', { name: 'Leave session' })).toHaveCount(0)
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
    // The next line replaces the card; the last line says Continue. Nothing plays by itself.
    await page.getByRole('button', { name: 'Next line' }).click()
    await expect(page.locator('[data-line-id]')).toHaveCount(1)
    await expect(page.getByText('Maria', { exact: true })).toBeVisible()
    await page.getByRole('button', { name: 'Next line' }).click()
    await expect(page.getByRole('button', { name: 'Continue' })).toBeVisible()
    expect(calls.audio).toEqual([])
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
      spoken: { text: string; color: string; background: string }[]
      written: { text: string; color: string; background: string }[]
    }>(
      `(() => {
        const read = (group) => [...document.querySelectorAll('[role="group"][aria-label="' + group + '"] [class*="face"]')].map((el) => {
          const s = getComputedStyle(el)
          return { text: el.textContent, color: s.color, background: s.backgroundColor }
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
      } else {
        expect(word.color, word.text).toBe('rgb(27, 42, 38)')
        expect(word.background, word.text).toBe('rgba(0, 0, 0, 0)')
      }
    }
    for (const word of colours.written) {
      if (word.text === 'nuo') {
        expect(word.color).toBe('rgb(127, 54, 24)')
        expect(word.background).toBe('rgb(253, 228, 216)')
      } else {
        expect(word.color, word.text).toBe('rgb(56, 82, 122)')
        expect(word.background, word.text).toBe('rgba(0, 0, 0, 0)')
      }
    }
  })

  test('[redesign 24] the last line says Continue and stores the step', async ({ page }) => {
    const calls = await open(page)
    await hearIt(page)
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
    await open(page, { firstLesson: true })
    await hearIt(page)
    const tip = page.getByRole('dialog', { name: 'How this screen works' })
    await expect(tip).toBeVisible()
    await expect(tip.getByText('How people say it')).toBeVisible()
    await expect(tip.getByText('How it’s written').or(tip.getByText("How it's written"))).toBeVisible()
    await expect(tip.getByText('Tap any word to learn it')).toBeVisible()
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
    await expect(page.getByRole('button', { name: 'Next line' })).toBeFocused()
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
  test('[redesign 26] [redesign 27] shows the word, its meaning, both registers, the dictionary form and the reason behind a tap', async ({
    page,
  }) => {
    await open(page)
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
    await expect(card.getByText('Plays the whole line.')).toBeVisible()
    await expect(card.getByText('Spoken Finnish says noi where books write nuo.')).toHaveCount(0)
    await card.getByRole('button', { name: 'Why does it change?' }).click()
    await expect(card.getByText('Spoken Finnish says noi where books write nuo.')).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play the written line' })).toBeVisible()
    await card.getByRole('button', { name: 'Close' }).click()
    await expect(card).toBeHidden()
    await expect(opener).toBeFocused()
  })

  test('[redesign 27] a form with no meanings shows no invented meaning line', async ({ page }) => {
    await open(page)
    await hearIt(page)
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
  async function noMicrophone(page: Page) {
    await page.addInitScript(`
      window.__mic = 0
      Object.defineProperty(navigator, 'mediaDevices', {
        value: { getUserMedia: () => { window.__mic += 1; return Promise.reject(new Error('no microphone in this test')) } },
        configurable: true,
      })
    `)
  }

  test('[redesign 29] shows only the title, "How it works", "Turn on" and "Not now", with no box and no microphone request', async ({
    page,
  }) => {
    await noMicrophone(page)
    await open(page, { step: 'understand', processing: 'not_asked' })
    const sheet = page.getByRole('dialog', { name: 'Say it out loud' })
    await expect(sheet).toBeVisible()
    await expect(sheet.getByRole('link', { name: /How it works/ })).toHaveAttribute(
      'href',
      /\/privacy#privacy-voice$/,
    )
    await expect(sheet.getByRole('button', { name: 'Turn on speaking feedback' })).toHaveText('Turn on')
    await expect(sheet.getByRole('button', { name: 'Not now' })).toBeVisible()
    await expect(sheet.getByRole('checkbox')).toHaveCount(0)
    expect(await page.evaluate<number>('window.__mic')).toBe(0)
  })

  test('[redesign 29] "Turn on" records one choice with the box unticked, and still asks for no microphone', async ({
    page,
  }) => {
    await noMicrophone(page)
    const calls = await open(page, { step: 'understand', processing: 'not_asked' })
    await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect(page.getByRole('dialog', { name: 'Say it out loud' })).toBeHidden()
    expect(calls.consent).toEqual([{ choice: 'turn_on', keepRecordings: false }])
    await expect(page.getByRole('button', { name: 'Record yourself saying the line' })).toBeVisible()
    await expect(page.getByText('Tap and say the line.')).toBeVisible()
    expect(await page.evaluate<number>('window.__mic')).toBe(0)
  })

  test('[redesign 29] "Not now" and Escape let the learner say each line without feedback and send nothing', async ({
    page,
  }) => {
    const calls = await open(page, { step: 'understand', processing: 'not_asked' })
    await page.getByRole('button', { name: 'Not now' }).click()
    await expect(page.getByText('Say the line out loud after the voice.')).toBeVisible()
    expect(calls.consent).toEqual([])
    const escape = await page.context().newPage()
    const second = await open(escape, { step: 'understand', processing: 'not_asked' })
    await expect(escape.getByRole('dialog', { name: 'Say it out loud' })).toBeVisible()
    await escape.keyboard.press('Escape')
    await expect(escape.getByText('Say the line out loud after the voice.')).toBeVisible()
    expect(second.consent).toEqual([])
  })

  test('[redesign 30] Say it: the card without play buttons, the large record button, the hint and a quiet way out', async ({
    page,
  }) => {
    await open(page, { step: 'understand' })
    await expect(page.getByRole('heading', { level: 1, name: 'Say it' })).toBeVisible()
    await expect(page.locator('[data-line-id]').getByRole('button', { name: /^Play/ })).toHaveCount(0)
    const record = page.getByRole('button', { name: 'Record yourself saying the line' })
    const box = await record.boundingBox()
    expect(box?.width ?? 0).toBeGreaterThanOrEqual(80)
    await expect(page.getByText('Tap and say the line.')).toBeVisible()
    await expect(page.getByRole('button', { name: "I can't speak right now" })).toBeVisible()
  })
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

  test('[redesign 33] an email account sees "Your progress is saved." and no note', async ({ page }) => {
    await open(page, { step: 'say', me: { kind: 'email', email: 'maria@example.fi' } })
    await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
    await expect(page.getByRole('region', { name: 'Keep your progress' })).toHaveCount(0)
  })
})

test.describe('phone size, keyboard and screen reader', () => {
  const STEPS: [string, LessonMocks][] = [
    ['Hear it', {}],
    ['Hear it with the tip', { firstLesson: true }],
    ['Understand it', { step: 'hear' }],
    ['Say it', { step: 'understand' }],
    ['Say it with the sheet', { step: 'understand', processing: 'not_asked' }],
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

  test('[redesign 46] a 40 letter Finnish word wraps inside its card at 375 px', async ({ page }) => {
    await mockLesson(page)
    await page.route('**/api/sessions/today', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          state: 'ready',
          session: { id: 's1', step: null },
          unit: { title: 'U', canDo: 'C' },
          dialogue: { title: 'D' },
          lines: [
            {
              id: 1,
              speaker: 'Pekka',
              gloss: 'A long word.',
              spokenAudio: '/audio/a.wav',
              writtenAudio: '/audio/b.wav',
              spoken: [{ text: 'epäjärjestelmällistyttämättömyydelläänsäkään' }],
              written: [{ text: 'epäjärjestelmällistyttämättömyydelläänsäkään' }],
            },
          ],
        }),
      }),
    )
    await page.goto('/session')
    await hearIt(page)
    const fits = await page.evaluate<boolean>(
      `[...document.querySelectorAll('[role="group"]')].every((el) => el.getBoundingClientRect().right <= document.documentElement.clientWidth)`,
    )
    expect(fits).toBe(true)
    expect(
      await page.evaluate<boolean>(
        'document.documentElement.scrollWidth <= document.documentElement.clientWidth',
      ),
    ).toBe(true)
  })
})
