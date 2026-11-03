import { expect, test, type Locator, type Page } from '@playwright/test'
import { MOCK_LINES, mockLesson, type LessonMocks } from './lesson-mocks.ts'

// The English meaning on the line card (fast job english-meaning, owner's call
// of 3 November 2026). Labels in brackets are the job's "Done when" statements:
// 1. Hear it shows "Meaning" in front of the English, the English in ink at
//    16 px and medium weight, and a screen reader hears "Meaning: <English>".
// 2. The review card of Keep it (ReviewItemView) shows the English the same way.
// 3. A long English meaning wraps cleanly at 320 px with 200% text: no sideways
//    scroll, no word of the sentence split across two rows, every row of the
//    English starting at the same left edge, and the English inside the card.
// 4. The finish screen's English is unchanged (12 px, quiet, no "Meaning").
// These answer the lesson's reads and writes themselves (e2e/lesson-mocks.ts).

/** One computed style of the element, reached through a cast because the e2e files have no DOM types. */
const styleOf = (locator: Locator, property: string): Promise<string> =>
  locator.evaluate(
    (el, name) =>
      (
        globalThis as unknown as { getComputedStyle: (e: unknown) => Record<string, string | undefined> }
      ).getComputedStyle(el)[name] ?? '',
    property,
  )

/** A colour token resolved to the browser's rgb() form, as computed styles give it. */
const tokenColour = (page: Page, token: string): Promise<string> =>
  page.evaluate<string>(`(() => {
    const probe = document.createElement('span')
    probe.style.color = 'var(${token})'
    document.body.append(probe)
    const colour = getComputedStyle(probe).color
    probe.remove()
    return colour
  })()`)

async function open(page: Page, mocks: LessonMocks = {}) {
  await mockLesson(page, mocks)
  await page.goto('/learn/session')
}

/** The meaning line of the one card on screen, with its label and its English. */
function meaningOf(page: Page) {
  const line = page.locator('[data-line-id] [data-meaning], [data-review-item] [data-meaning]')
  return { line, label: line.locator('[data-meaning-label]'), english: line.locator('[data-meaning-text]') }
}

async function expectMeaningStyle(page: Page, english: string) {
  const { line, label, english: text } = meaningOf(page)
  await expect(line).toHaveCount(1)
  await expect(label).toHaveText('Meaning:')
  await expect(text).toHaveText(english)
  // To the eye "Meaning" has no colon: the colon is clipped to nothing, for screen readers only.
  await expect(label.locator('[data-meaning-word]')).toHaveText('Meaning')
  const colon = label.locator(':scope > :not([data-meaning-word])')
  await expect(colon).toHaveText(':')
  const colonBox = await colon.boundingBox()
  expect(colonBox?.width ?? 0).toBeLessThanOrEqual(1)
  expect(await styleOf(colon, 'clip')).toMatch(/rect\(0(px)?,? 0(px)?,? 0(px)?,? 0(px)?\)/)
  // The English in ink, 16 px, medium weight.
  expect(await styleOf(text, 'color')).toBe(await tokenColour(page, '--color-text'))
  expect(await styleOf(text, 'fontSize')).toBe('16px')
  expect(await styleOf(text, 'fontWeight')).toBe('500')
  // "Meaning" small and quiet, with no eyebrow styling.
  const word = label.locator('[data-meaning-word]')
  expect(await styleOf(word, 'color')).toBe(await tokenColour(page, '--color-text-quiet'))
  expect(await styleOf(word, 'fontSize')).toBe('12px')
  expect(await styleOf(word, 'textTransform')).toBe('none')
  expect(['normal', '0px']).toContain(await styleOf(word, 'letterSpacing'))
  // The two sit on one line, "Meaning" first.
  const labelBox = await word.boundingBox()
  const textBox = await text.boundingBox()
  expect(labelBox && textBox).toBeTruthy()
  if (labelBox && textBox) {
    expect(labelBox.x + labelBox.width).toBeLessThanOrEqual(textBox.x)
    // "Meaning" sits within the English's first row (one row of 16 px text is under 26 px tall).
    expect(labelBox.y).toBeGreaterThanOrEqual(textBox.y - 1)
    expect(labelBox.y + labelBox.height).toBeLessThanOrEqual(textBox.y + 26)
  }
}

test.describe('the English meaning on the line card', () => {
  test('[english-meaning 1] Hear it shows "Meaning" in front of the English, the English in ink at 16 px, medium weight', async ({
    page,
  }) => {
    await open(page)
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
    await expectMeaningStyle(page, 'How much are those strawberries?')
    // A screen reader hears the label and the meaning as one sentence.
    const { line } = meaningOf(page)
    expect((await line.textContent())?.replace(/\s+/g, ' ').trim()).toBe(
      'Meaning: How much are those strawberries?',
    )
    // The English is still findable on its own, as the older tests look for it.
    await expect(page.getByText('How much are those strawberries?', { exact: true })).toBeVisible()
  })

  test('[english-meaning 2] the Keep it review card shows the English the same way', async ({ page }) => {
    await open(page, { step: 'say', review: true })
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeAttached()
    await expect(page.locator('[data-review-item]')).toBeVisible()
    await expectMeaningStyle(page, 'Can I pay by card?')
  })

  test('[english-meaning 3] a long English meaning wraps cleanly at 320 px with 200% text', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 700 })
    await mockLesson(page)
    const long =
      'Excuse me, could you please tell me whereabouts the nearest pharmacy is, if there is one nearby?'
    const first = MOCK_LINES[0]
    await page.route('**/api/sessions/today', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          state: 'ready',
          session: { id: 's1', step: null },
          unit: { title: 'Unit', canDo: 'Can do.' },
          dialogue: { title: 'Dialogue' },
          lines: [{ ...first, gloss: long }, ...MOCK_LINES.slice(1)],
        }),
      }),
    )
    await page.goto('/learn/session')
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    await page.evaluate('document.fonts.ready')
    await page.waitForTimeout(300)
    const { english } = meaningOf(page)
    await expect(english).toHaveText(long)
    const layout = await page.evaluate<{
      sideways: boolean
      rows: number
      lefts: number[]
      split: string[]
      right: number
      cardRight: number
    }>(`(() => {
      const text = document.querySelector('[data-meaning-text]')
      const node = text.firstChild
      const card = text.closest('[data-line-id]').getBoundingClientRect()
      const range = document.createRange()
      range.selectNodeContents(text)
      const rects = [...range.getClientRects()].filter((r) => r.width > 1)
      // A word is split when its own letters sit on more than one row.
      const split = []
      for (const match of node.textContent.matchAll(/\\S+/g)) {
        const word = document.createRange()
        word.setStart(node, match.index)
        word.setEnd(node, match.index + match[0].length)
        const tops = new Set([...word.getClientRects()].filter((r) => r.width > 1).map((r) => Math.round(r.top)))
        if (tops.size > 1) split.push(match[0])
      }
      return {
        sideways: document.documentElement.scrollWidth > document.documentElement.clientWidth,
        rows: new Set(rects.map((r) => Math.round(r.top))).size,
        lefts: [...new Set(rects.map((r) => Math.round(r.left)))],
        split,
        right: Math.max(...rects.map((r) => r.right)),
        cardRight: card.right,
      }
    })()`)
    expect(layout.sideways).toBe(false)
    // It wraps onto several rows, each starting at the same left edge, and no word is broken in two.
    expect(layout.rows).toBeGreaterThan(1)
    expect(layout.split).toEqual([])
    expect(layout.lefts).toHaveLength(1)
    expect(layout.right).toBeLessThanOrEqual(layout.cardRight)
  })

  test('[english-meaning 4] the finish screen keeps its own small quiet English with no "Meaning"', async ({
    page,
  }) => {
    await open(page, { step: 'say', newWords: 1 })
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    await expect(page.locator('[data-meaning]')).toHaveCount(0)
    const english = page.locator('[data-line-id] > p').last()
    await expect(english).toBeVisible()
    expect(MOCK_LINES.map((line) => line.gloss)).toContain(await english.textContent())
    expect(await styleOf(english, 'fontSize')).toBe('12px')
    expect(await styleOf(english, 'color')).toBe(await tokenColour(page, '--color-text-quiet'))
  })
})
