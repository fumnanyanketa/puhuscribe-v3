import { AxeBuilder } from '@axe-core/playwright'
import { readFileSync } from 'node:fs'
import { expect, test, type Page } from '@playwright/test'
import { CONTRAST_PAIRS } from '../src/styles/contrast-pairs.ts'
import { colourTokens } from '../src/styles/token-values.ts'
import { SWITZER_SKIP_REASON, switzerPresent } from './switzer.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/5-design-system/spec.md. These run on the reference page,
// /design-reference, which exists only in builds made with
// VITE_DESIGN_REFERENCE=1 (the GitHub checks and preview links set it):
//   VITE_DESIGN_REFERENCE=1 npm run build
// e2e/ is type checked without the browser's types, so in-page expressions
// are passed as text.

const REFERENCE = '/design-reference'
const COLOUR_TOKENS = colourTokens(readFileSync('src/styles/tokens.css', 'utf8')).light

async function openReference(page: Page) {
  await page.goto(REFERENCE)
  await expect(page.getByRole('heading', { level: 1, name: 'Design reference' })).toBeVisible()
  await page.evaluate('document.fonts.ready')
}

const section = (page: Page, name: string) => page.getByRole('region', { name, exact: true })

test.describe('the reference page', () => {
  test('[design 16] shows every colour token, every contrast pairing in both modes, and the type, spacing and radius scales', async ({
    page,
  }) => {
    await openReference(page)
    const colour = section(page, 'Colour')
    for (const token of COLOUR_TOKENS)
      await expect(colour.getByText(token.name, { exact: true })).toHaveCount(1)
    await expect(colour.locator('tbody tr')).toHaveCount(CONTRAST_PAIRS.length)
    await expect(colour.locator('tbody td', { hasText: 'fails' })).toHaveCount(0)
    await expect(section(page, 'Type').getByText('--text-line', { exact: true })).toBeVisible()
    await expect(
      section(page, 'Spacing, corners and motion').getByText('--space-9', { exact: true }),
    ).toBeVisible()
    await expect(
      section(page, 'Spacing, corners and motion').getByText('--radius-pill', { exact: true }),
    ).toBeVisible()
  })

  test('[design 16] its Finnish is only the PRD example and the type sample, each marked "Sample, not reviewed"', async ({
    page,
  }) => {
    await openReference(page)
    const allowed = new Set([
      'Mä',
      'oon',
      'Minä',
      'olen',
      'Mä oon',
      'Minä olen',
      'ä ö å Ä Ö Å',
      'maahanmuuttovirasto',
      'kotoutumiskoulutus',
      'työttömyysturvailmoitus',
    ])
    const finnish = await page.evaluate<string[]>(
      `[...document.querySelectorAll('[lang="fi"]')].map((el) => el.textContent.replace(/\\s+/g, ' ').trim())`,
    )
    expect(finnish.length).toBeGreaterThan(0)
    for (const text of finnish) expect(allowed, text).toContain(text)
    for (const name of ['Type', 'Session frame', 'Finnish line and word card']) {
      await expect(section(page, name).getByText('Sample, not reviewed.', { exact: true })).toBeVisible()
    }
  })

  test('[design 16] every word card on the page is marked "Sample, not reviewed."', async ({ page }) => {
    await openReference(page)
    for (const sectionName of ['Session frame', 'Finnish line and word card']) {
      for (const word of ['Mä', 'oon', 'Minä', 'olen']) {
        await section(page, sectionName).getByRole('button', { name: word, exact: true }).click()
        const card = page.getByRole('dialog', { name: word })
        await expect(card).toBeVisible()
        await expect(card.getByText('Sample, not reviewed.', { exact: true })).toBeVisible()
        expect(await card.locator('[lang="fi"]').count(), `${sectionName} ${word}`).toBeGreaterThan(0)
        await card.getByRole('button', { name: 'Close' }).click()
        await expect(card).toBeHidden()
      }
    }
  })

  test('[design 5] fonts load from the app’s own address, and ä ö å render in Poppins', async ({ page }) => {
    const urls: string[] = []
    page.on('request', (request) => {
      if (!/^(data|blob):/.test(request.url())) urls.push(request.url())
    })
    await openReference(page)
    await page.waitForLoadState('networkidle')
    const origin = new URL(page.url()).origin
    for (const url of urls) expect(new URL(url).origin, url).toBe(origin)
    for (const font of ['600 22px Poppins']) {
      expect(await page.evaluate<boolean>(`document.fonts.check('${font}', 'äöåÄÖÅ')`), font).toBe(true)
    }
  })

  // Switzer is kept out of the public repository (docs/fonts.md): this test
  // runs when the files were fetched and skips, with its reason, when not.
  test('[design 5] ä ö å render in Switzer, and the body text uses it', async ({ page }) => {
    test.skip(!switzerPresent, SWITZER_SKIP_REASON)
    await openReference(page)
    await page.waitForLoadState('networkidle')
    for (const font of ['400 16px Switzer', '500 16px Switzer', '600 16px Switzer', '700 16px Switzer']) {
      expect(await page.evaluate<boolean>(`document.fonts.check('${font}', 'äöåÄÖÅ')`), font).toBe(true)
    }
    const body = await page.evaluate<string>('getComputedStyle(document.body).fontFamily')
    expect(body.startsWith('Switzer')).toBe(true)
  })
})

test.describe('session frame', () => {
  test('[design 7] names the step in words in loop order, offers "Leave session", and keeps the actions in view', async ({
    page,
  }) => {
    await openReference(page)
    const frame = section(page, 'Session frame')
    await expect(frame.getByText('Hear it, step 1 of 5', { exact: true })).toBeVisible()
    await expect(frame.getByRole('link', { name: 'Leave session' })).toBeVisible()
    // The actions sit at the bottom of the frame, and stay there when the
    // content scrolls.
    const place = await page.evaluate<{ before: number; after: number }>(`(() => {
      const region = document.getElementById('frame').closest('section')
      const box = region.querySelector('[class*="frameBox"]')
      const actions = [...region.querySelectorAll('button')].find((b) => b.textContent === 'Continue')
      const content = region.querySelector('[class*="_content_"]')
      const gap = () => box.getBoundingClientRect().bottom - actions.getBoundingClientRect().bottom
      const before = gap()
      content.scrollTop = 10000
      return { before, after: gap() }
    })()`)
    expect(place.before).toBeGreaterThanOrEqual(0)
    expect(place.before).toBeLessThan(40)
    expect(place.after).toBe(place.before)
  })

  for (const width of [375, 320]) {
    test(`[design 7] nothing on the reference page scrolls sideways at ${String(width)} px, also with text at 200 percent`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height: 812 })
      await openReference(page)
      const sideways = `(() => {
        const width = document.documentElement.clientWidth
        const past = [...document.querySelectorAll('main *')]
          .filter((el) => !el.closest('[class*="tableWrap"]') && el.getBoundingClientRect().right > width + 0.5)
          .map((el) => el.tagName + ' ' + String(el.className))
        return { scrollWidth: document.documentElement.scrollWidth, width, past }
      })()`
      for (const size of ['100%', '200%']) {
        await page.addStyleTag({ content: `html { font-size: ${size} !important; }` })
        const result = await page.evaluate<{ scrollWidth: number; width: number; past: string[] }>(sideways)
        expect(result.past, size).toEqual([])
        expect(result.scrollWidth, size).toBeLessThanOrEqual(result.width)
      }
    })
  }
})

test.describe('buttons and keyboard', () => {
  test('[design 8] every control is at least 44 x 44 px, and words at least 44 px tall and 24 px wide', async ({
    page,
  }) => {
    await openReference(page)
    const sizes = await page.evaluate<{ name: string; width: number; height: number; word: boolean }[]>(
      `[...document.querySelectorAll('main button, main a[href]')].filter((el) => !el.closest('dialog')).map((el) => {
        const box = el.getBoundingClientRect()
        return { name: el.getAttribute('aria-label') || el.textContent.trim(), width: box.width, height: box.height, word: Boolean(el.closest('[lang="fi"]')) }
      })`,
    )
    expect(sizes.length).toBeGreaterThan(20)
    for (const { name, width, height, word } of sizes) {
      expect(height, name).toBeGreaterThanOrEqual(44)
      expect(width, name).toBeGreaterThanOrEqual(word ? 24 : 44)
    }
  })

  test('[design 8] a busy button keeps its size, ignores presses and tells screen readers what is happening', async ({
    page,
  }) => {
    await openReference(page)
    const save = section(page, 'Buttons').getByRole('button', { name: 'Save', exact: true })
    const before = await save.boundingBox()
    await save.click()
    const busy = section(page, 'Buttons').getByRole('button', { name: 'Saving your answer.' }).last()
    await expect(busy).toHaveAttribute('aria-busy', 'true')
    // Same size (the page may have scrolled to it, so only the size is compared).
    const after = await busy.boundingBox()
    expect([after?.width, after?.height]).toEqual([before?.width, before?.height])
    await expect(section(page, 'Buttons').getByRole('button', { name: 'Save', exact: true })).toBeVisible({
      timeout: 5000,
    })
  })

  test('[design 9] Tab reaches every control in reading order, and each shows a focus outline of at least 2 px', async ({
    page,
    browserName,
  }) => {
    await openReference(page)
    const expected = await page.evaluate<number>(
      `[...document.querySelectorAll('main button:not([disabled]), main a[href], main [tabindex]:not([tabindex="-1"])')].filter((el) => !el.closest('dialog')).length`,
    )
    expect(expected).toBeGreaterThan(20)
    // Safari moves Tab between buttons only with Option held, unless a setting says otherwise.
    const tab = browserName === 'webkit' ? 'Alt+Tab' : 'Tab'
    // Start on the first control, then move with the keyboard only.
    await page.locator('main a[href]').first().focus()
    let previousTop = -Infinity
    for (let i = 0; i < expected; i += 1) {
      if (i > 0) await page.keyboard.press(tab)
      const focused = await page.evaluate<{
        index: number
        width: number
        style: string
        colour: string
        top: number
      }>(
        `(() => {
          const list = [...document.querySelectorAll('main button:not([disabled]), main a[href], main [tabindex]:not([tabindex="-1"])')].filter((el) => !el.closest('dialog'))
          const el = document.activeElement
          const style = getComputedStyle(el)
          return { index: list.indexOf(el), width: parseFloat(style.outlineWidth), style: style.outlineStyle, colour: style.outlineColor, top: el.getBoundingClientRect().top + window.scrollY }
        })()`,
      )
      expect(focused.index, `step ${String(i)}`).toBe(i)
      expect(focused.style).toBe('solid')
      expect(focused.width).toBeGreaterThanOrEqual(2)
      // Reading order: never jumps back up the page.
      expect(focused.top + 1).toBeGreaterThanOrEqual(previousTop - 200)
      previousTop = focused.top
    }
  })
})

test.describe('status line', () => {
  test('[design 10] three styles, each one full sentence in role="status", differing in shape as well as colour', async ({
    page,
  }) => {
    await openReference(page)
    const lines = section(page, 'Status line').getByRole('status')
    await expect(lines).toHaveCount(3)
    await expect(lines).toHaveText([
      'Saving your answer.',
      'Close. Try the double k.',
      'No connection. Check your internet, then try again.',
    ])
    const shapes = await page.evaluate<
      string[]
    >(`[...document.getElementById('status').closest('section').querySelectorAll('[role="status"]')].map((el) => {
      const style = getComputedStyle(el)
      return style.borderTopLeftRadius + ' ' + style.borderTopWidth + ' ' + String(el.querySelectorAll('[aria-hidden]').length)
    })`)
    expect(new Set(shapes).size).toBe(3)
  })
})

test.describe('Finnish line and word card', () => {
  const lineSection = (page: Page) => section(page, 'Finnish line and word card')

  test('[design 11] spoken first, written under it labelled "Written", both lang="fi", every word a button', async ({
    page,
  }) => {
    await openReference(page)
    const line = lineSection(page)
    await expect(line.locator('[lang="fi"]')).toHaveText(['Mä oon', 'Minä olen'])
    await expect(line.getByText('Written', { exact: true })).toBeVisible()
    await expect(line.locator('[lang="fi"] button')).toHaveCount(4)
  })

  test('[design 11] a changed word has its wash drawn at text height inside a 44 px tap area', async ({
    page,
  }) => {
    await openReference(page)
    const sizes = await page.evaluate<{ button: number; face: number; font: number }[]>(
      `[...document.getElementById('line').closest('section').querySelectorAll('[lang="fi"] button')].map((button) => ({
        button: button.getBoundingClientRect().height,
        face: button.firstElementChild.getBoundingClientRect().height,
        font: parseFloat(getComputedStyle(button).fontSize),
      }))`,
    )
    expect(sizes.length).toBe(4)
    for (const { button, face, font } of sizes) {
      expect(button).toBeGreaterThanOrEqual(44)
      expect(face).toBeLessThan(font * 1.6)
      expect(face).toBeLessThan(button)
    }
  })

  test('[design 11] a tap opens the card with every field; Close shuts it and returns focus to the word', async ({
    page,
  }) => {
    await openReference(page)
    const word = lineSection(page).getByRole('button', { name: 'oon', exact: true })
    await word.click()
    const card = page.getByRole('dialog', { name: 'oon' })
    await expect(card).toBeVisible()
    await expect(card.getByText('Base form')).toBeVisible()
    await expect(card.getByText('olla', { exact: true })).toBeVisible()
    await expect(card.getByText('Form', { exact: true })).toBeVisible()
    await expect(card.getByText('Why', { exact: true })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play the spoken form' })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play the written form' })).toBeVisible()
    expect(await page.evaluate<boolean>('Boolean(document.activeElement.closest("dialog"))')).toBe(true)
    await card.getByRole('button', { name: 'Close' }).click()
    await expect(card).toBeHidden()
    await expect(word).toBeFocused()
  })

  for (const key of ['Enter', ' ']) {
    test(`[design 11] ${key === ' ' ? 'Space' : key} on a word opens the card, and Escape closes it back to the word`, async ({
      page,
    }) => {
      await openReference(page)
      const word = lineSection(page).getByRole('button', { name: 'Minä', exact: true })
      await word.focus()
      await page.keyboard.press(key)
      const card = page.getByRole('dialog', { name: 'Minä' })
      await expect(card).toBeVisible()
      await page.keyboard.press('Escape')
      await expect(card).toBeHidden()
      await expect(word).toBeFocused()
    })
  }

  test('[design 11] a tap outside closes the card, and the page behind cannot be used or scrolled while it is open', async ({
    page,
  }) => {
    await openReference(page)
    const word = lineSection(page).getByRole('button', { name: 'Mä', exact: true })
    await word.scrollIntoViewIfNeeded()
    await word.click()
    const card = page.getByRole('dialog', { name: 'Mä' })
    await expect(card).toBeVisible()
    const scrollBefore = await page.evaluate<number>('window.scrollY')
    await page.mouse.move(180, 60)
    await page.mouse.wheel(0, 600)
    await page.waitForTimeout(300)
    expect(await page.evaluate<number>('window.scrollY')).toBe(scrollBefore)
    // The word behind is covered: a click cannot reach it.
    await expect(word.click({ timeout: 1000 })).rejects.toThrow()
    await page.mouse.click(180, 30)
    await expect(card).toBeHidden()
    await expect(word).toBeFocused()
  })
})

test.describe('motion', () => {
  test('[design 14] with reduce motion on, the word card appears without sliding', async ({ browser }) => {
    for (const [motion, animation] of [
      ['no-preference', /rise/],
      ['reduce', /appear/],
    ] as const) {
      const context = await browser.newContext({
        reducedMotion: motion,
        viewport: { width: 375, height: 812 },
      })
      const page = await context.newPage()
      await openReference(page)
      await section(page, 'Finnish line and word card')
        .getByRole('button', { name: 'oon', exact: true })
        .click()
      const card = page.getByRole('dialog', { name: 'oon' })
      await expect(card).toBeVisible()
      const name = await page.evaluate<string>(
        `getComputedStyle(document.querySelector('dialog[open]')).animationName`,
      )
      expect(name, motion).toMatch(animation)
      await context.close()
    }
  })
})

test.describe('play control', () => {
  test('[design 12] audio never starts by itself', async ({ page }) => {
    await page.addInitScript(`
      window.__plays = 0
      const play = HTMLMediaElement.prototype.play
      HTMLMediaElement.prototype.play = function () { window.__plays += 1; return play.call(this) }
    `)
    await openReference(page)
    await page.waitForTimeout(1500)
    expect(await page.evaluate<number>('window.__plays')).toBe(0)
  })

  test('[design 9] [design 12] keyboard focus stays on the play control when it cannot play and on Try again', async ({
    page,
  }) => {
    await openReference(page)
    const play = section(page, 'Play control')
    await play.getByRole('button', { name: 'Play a broken file' }).focus()
    await page.keyboard.press('Enter')
    const retry = play.getByRole('button', { name: 'Try again: play a broken file' })
    await expect(retry).toBeVisible()
    await expect(retry).toBeFocused()
    await page.keyboard.press('Enter')
    // It tries again, fails again, and focus never drops to the page.
    await expect(retry).toBeVisible()
    await expect(retry).toBeFocused()
    expect(await page.evaluate<string>('document.activeElement.tagName')).toBe('BUTTON')
  })

  test('[design 12] a file that cannot play shows "Could not play." and a "Try again" action', async ({
    page,
  }) => {
    await openReference(page)
    const play = section(page, 'Play control')
    await play.getByRole('button', { name: 'Play a broken file' }).click()
    await expect(play.getByText('Could not play.').first()).toBeVisible()
    await expect(play.getByRole('button', { name: 'Try again: play a broken file' })).toBeVisible()
  })

  test('[design 12] Play plays the tone, the name says what it plays, and starting another stops the first', async ({
    page,
    browserName,
  }) => {
    await openReference(page)
    const play = section(page, 'Play control')
    await play.getByRole('button', { name: 'Play the first tone' }).click()
    const outcome = await Promise.race([
      play
        .getByRole('button', { name: 'Pause the first tone' })
        .waitFor({ timeout: 5000 })
        .then(() => 'played'),
      play
        .getByRole('button', { name: 'Try again: play the first tone' })
        .waitFor({ timeout: 5000 })
        .then(() => 'could not play'),
    ])
    test.info().annotations.push({ type: 'audio', description: `${browserName}: ${outcome}` })
    // Printed so the GitHub log shows which path each browser took (evidence for build.md).
    process.stdout.write(`Audio check | ${browserName} | ${outcome}
`)
    // Chromium must play. Headless WebKit on Linux may have no audio output;
    // there the "could not play" path is the one that can be tested.
    if (browserName === 'chromium') expect(outcome).toBe('played')
    if (outcome !== 'played') return
    await play.getByRole('button', { name: 'Play the second tone' }).click()
    await expect(play.getByRole('button', { name: 'Pause the second tone' })).toBeVisible()
    await expect(play.getByRole('button', { name: 'Play the first tone' })).toBeVisible()
    // The tone is short: the control returns to ready by itself.
    await expect(play.getByRole('button', { name: 'Play the second tone' })).toBeVisible({ timeout: 5000 })
  })
})

test.describe('record control', () => {
  test('[design 13] each state has its own accessible name; unavailable gives its reason', async ({
    page,
  }) => {
    await openReference(page)
    const record = section(page, 'Record control')
    await expect(
      record.getByRole('button', { name: 'Record yourself saying the line' }).first(),
    ).toBeVisible()
    await expect(record.getByRole('button', { name: 'Stop recording, 3 seconds recorded' })).toBeVisible()
    await expect(record.getByRole('button', { name: 'Working on your recording' })).toHaveAttribute(
      'aria-busy',
      'true',
    )
    await expect(record.getByRole('button', { name: 'Recording is not available' })).toBeDisabled()
    await expect(record.getByText('This browser cannot record sound.')).toBeVisible()
  })

  test('[design 13] the live example moves through the states without asking for the microphone', async ({
    page,
  }) => {
    await page.addInitScript(`
      window.__mic = 0
      if (navigator.mediaDevices) navigator.mediaDevices.getUserMedia = () => { window.__mic += 1; return Promise.reject(new Error('no')) }
    `)
    await openReference(page)
    const record = section(page, 'Record control')
    await record.getByRole('button', { name: 'Record yourself saying the line' }).last().click()
    await record.getByRole('button', { name: /^Stop recording, 0 seconds recorded$/ }).click()
    await expect(record.getByRole('button', { name: 'Working on your recording' })).toHaveCount(2)
    await expect(record.getByRole('button', { name: 'Record yourself saying the line' })).toHaveCount(2, {
      timeout: 5000,
    })
    expect(await page.evaluate<number>('window.__mic')).toBe(0)
  })
})

test.describe('both colour modes', () => {
  test('[design 15] the page background fades from white to lilac in light, and to its dark equivalent in dark', async ({
    browser,
  }) => {
    for (const [scheme, stops] of [
      ['light', ['rgb(255, 255, 255)', 'rgb(250, 249, 252)', 'rgb(241, 240, 246)']],
      ['dark', ['rgb(18, 17, 23)', 'rgb(20, 19, 25)', 'rgb(23, 22, 29)']],
    ] as const) {
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await openReference(page)
      const image = await page.evaluate<string>('getComputedStyle(document.documentElement).backgroundImage')
      expect(image, scheme).toContain('linear-gradient')
      for (const stop of stops) expect(image, scheme).toContain(stop)
      await context.close()
    }
  })
})

test.describe('automatic accessibility check', () => {
  const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']

  for (const scheme of ['light', 'dark'] as const) {
    test(`[design 17] axe finds no WCAG A or AA problem on the reference page, ${scheme}`, async ({
      browser,
    }) => {
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await openReference(page)
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
      await context.close()
    })

    test(`[design 17] axe finds no WCAG A or AA problem on the reference page with a word card open, ${scheme}`, async ({
      browser,
    }) => {
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await openReference(page)
      await section(page, 'Finnish line and word card')
        .getByRole('button', { name: 'oon', exact: true })
        .click()
      await expect(page.getByRole('dialog', { name: 'oon' })).toBeVisible()
      await page.waitForTimeout(400)
      const result = await new AxeBuilder({ page }).withTags(TAGS).include('dialog').analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
      await context.close()
    })

    test(`[design 17] axe finds no WCAG A or AA problem on the front page when Start fails, ${scheme}`, async ({
      browser,
    }) => {
      // Forces the problem state and its "Start" again, which the GitHub
      // checks never reach on their own (evaluator, job 5 round 2). Since job
      // 8-first-session the front page is the front door (statement 21).
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await page.route('**/api/guest', (route) =>
        route.fulfill({
          status: 503,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'guest_not_created' }),
        }),
      )
      await page.goto('/')
      await page.getByRole('button', { name: 'Start', exact: true }).click()
      await expect(page.getByRole('status')).toHaveText(
        'Could not start your session. Check your internet connection, then try again.',
      )
      await page.evaluate('document.fonts.ready')
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
      const size = await page.getByRole('button', { name: 'Start', exact: true }).boundingBox()
      expect(size?.height ?? 0).toBeGreaterThanOrEqual(44)
      await context.close()
    })

    test(`[design 17] axe finds no WCAG A or AA problem on the front page, ${scheme}`, async ({
      browser,
    }) => {
      const context = await browser.newContext({ colorScheme: scheme, viewport: { width: 375, height: 812 } })
      const page = await context.newPage()
      await page.goto('/')
      await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible({ timeout: 11_000 })
      await page.evaluate('document.fonts.ready')
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
      await context.close()
    })
  }
})
