import { readFileSync } from 'node:fs'
import { expect, test, type Page } from '@playwright/test'
import { SCENE_HEIGHT, SCENE_WIDTH, SUN_BOX } from '../src/components/landscape-geometry.ts'
import { roadFixture } from '../src/road/road-fixture.ts'
import { mockHome } from './road-mocks.ts'

// Follow up 19-sign-overflow of job 19-redesign. Labels in brackets are the
// "Done when" statement numbers from factory/jobs/19-redesign/spec.md
// (13: the signs, 20: the card never covers a sign and nothing scrolls
// sideways, 46: large text). The runs after the merge found road signs past the
// edge of 320 px and 375 px screens with text at 200 percent. A sign was placed with its
// board centred on its pole and pulled back inside the screen by a script one
// frame later, so for a frame or two it stood past the edge. These tests look
// at every frame, not only at the end.
//
// The stop names are the published ones: the names the migration that loads
// the road stops writes into public.road_stops, which GET /api/road serves on
// the test project. A longer real name is tested the day it lands. They are
// checked against content/road/road-report.md, the road job 20 imported.

const STOPS_SQL = readFileSync('supabase/migrations/20261101120100_load_road_stops.sql', 'utf8')
const unquote = (text: string) => text.replaceAll("''", "'")
const REAL_NAMES = new Map(
  [...STOPS_SQL.matchAll(/^\s+\((\d+), '[a-z0-9-]+', \d+, '((?:[^']|'')+)',/gm)].map((match) => [
    Number(match[1]),
    unquote(match[2] ?? ''),
  ]),
)
const REPORT_NAMES = new Map(
  [...readFileSync('content/road/road-report.md', 'utf8').matchAll(/^## Stop (\d+)\. (.+)$/gm)].map(
    (match) => [Number(match[1]), (match[2] ?? '').trim()],
  ),
)
const LONGEST = [...REAL_NAMES.entries()].reduce((a, b) => (b[1].length > a[1].length ? b : a))

/** Answers GET /api/road with the real stop names and the given lessons done. */
async function realRoad(page: Page, done: Record<number, number>) {
  await mockHome(page, { today: { signedIn: true, today: 'continue' }, done })
  // A route added later wins: the same stops, with their real names.
  await page.route('**/api/road', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        stops: roadFixture(done).map((stop) => ({ ...stop, name: REAL_NAMES.get(stop.number) ?? stop.name })),
      }),
    }),
  )
}

interface Frame {
  t: number
  out: { stop: string; left: number; right: number }[]
  signs: number
}

// Every frame for a second and a half: which boards stand past an edge of the screen.
const WATCH = `(async (grow) => {
  const width = document.documentElement.clientWidth
  const frame = () => new Promise((resolve) => requestAnimationFrame(() => resolve()))
  const boards = () => [...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
    const box = li.querySelector('[aria-hidden="true"]').getBoundingClientRect()
    return { stop: li.getAttribute('data-stop'), left: box.left, right: box.right }
  })
  if (grow) {
    const style = document.createElement('style')
    style.textContent = 'html { font-size: 200% !important; }'
    document.head.appendChild(style)
  }
  const frames = []
  const start = performance.now()
  while (performance.now() - start < 1500) {
    const all = boards()
    frames.push({ t: Math.round(performance.now() - start), signs: all.length, out: all.filter((b) => b.left < -0.5 || b.right > width + 0.5) })
    await frame()
  }
  return frames
})`

/** Stops before `stop` finished and one lesson of `stop` done: `stop` is the current sign. */
const currentAt = (stop: number) => ({
  ...Object.fromEntries(Array.from({ length: stop - 1 }, (_, i) => [i + 1, 4])),
  [stop]: 1,
})

// The longest real name as the current sign, as the upcoming sign after it (no number, round 6), and as
// the done sign before it.
const PLACES = [
  ['current', currentAt(LONGEST[0])],
  ['upcoming', currentAt(LONGEST[0] - 1)],
  ['done', currentAt(LONGEST[0] + 1)],
] as const

// The text size the learner set on the phone, there before the page draws anything.
const LARGE_TEXT_FROM_THE_START = `document.addEventListener('DOMContentLoaded', () => {
  const style = document.createElement('style')
  style.textContent = 'html { font-size: 200% !important; }'
  document.head.appendChild(style)
})`

// A small phone and the project's phone size (Playwright's 375 x 812).
const SCREENS = [
  [320, 640],
  [375, 812],
] as const

test.describe('road signs at 320 and 375 px with text at 200 percent', () => {
  test('[redesign 13] the longest published stop name is read from the road stops migration', () => {
    expect(REAL_NAMES.size).toBe(36)
    expect(REAL_NAMES).toEqual(REPORT_NAMES)
    expect(LONGEST[1].length).toBeGreaterThanOrEqual(30)
  })

  for (const [width, height] of SCREENS)
    for (const [place, done] of PLACES) {
      test(`[redesign 20] [redesign 46] ${String(width)} px, text grown to 200 percent: no sign stands past the screen edge in any frame, longest real name as the ${place} sign`, async ({
        page,
      }) => {
        await page.setViewportSize({ width, height })
        await realRoad(page, done)
        await page.goto('/learn')
        const list = page.getByRole('list', { name: 'Stops on your road' })
        await expect(list.getByRole('listitem').filter({ hasText: LONGEST[1] })).toHaveCount(1)
        await page.waitForTimeout(500)
        const frames = await page.evaluate<Frame[]>(`${WATCH}(true)`)
        expect(frames.length).toBeGreaterThan(10)
        expect(frames.filter((frame) => frame.out.length > 0)).toEqual([])
      })

      test(`[redesign 20] [redesign 46] ${String(width)} px, text at 200 percent from the start: no sign stands past the screen edge in any frame, longest real name as the ${place} sign`, async ({
        page,
      }) => {
        await page.setViewportSize({ width, height })
        await page.addInitScript(LARGE_TEXT_FROM_THE_START)
        await realRoad(page, done)
        await page.goto('/learn')
        // Watch from the first frame the signs are on the page.
        await page.waitForSelector('ol[aria-label="Stops on your road"] > li', { state: 'attached' })
        const frames = await page.evaluate<Frame[]>(`${WATCH}(false)`)
        expect(frames.some((frame) => frame.signs > 0)).toBe(true)
        expect(frames.filter((frame) => frame.out.length > 0)).toEqual([])
        // The current sign and the one after it always show; a done sign may be left out when they would not
        // fit. Each keeps its full stop name for screen readers.
        const list = page.getByRole('list', { name: 'Stops on your road' })
        await expect(list.locator('li[data-state="current"]')).toHaveCount(1)
        expect(await list.getByRole('listitem').count()).toBeGreaterThanOrEqual(2)
        if (place !== 'done')
          await expect(list.getByRole('listitem').filter({ hasText: LONGEST[1] })).toHaveCount(1)
      })
    }

  test('[redesign 13] at 375 px and normal text every sign is a one line pill with its pole under it, and upcoming signs have no number', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    await realRoad(page, { 1: 4, 2: 4, 3: 2 })
    await page.goto('/learn')
    await expect(page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem')).toHaveCount(5)
    await page.waitForTimeout(500)
    const signs = await page.evaluate<
      { state: string; lines: number; poleInside: boolean; numbered: boolean; left: number; right: number }[]
    >(`[...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
      const board = li.querySelector('[aria-hidden="true"]')
      const name = board.lastElementChild
      const pole = board.nextElementSibling.getBoundingClientRect()
      const box = board.getBoundingClientRect()
      const lineHeight = parseFloat(getComputedStyle(name).lineHeight)
      const middle = pole.left + pole.width / 2
      return {
        state: li.getAttribute('data-state'),
        lines: Math.round(name.getBoundingClientRect().height / lineHeight),
        poleInside: middle > box.left + 8 && middle < box.right - 8,
        numbered: [...board.children].filter((el) => getComputedStyle(el).display !== 'none').length > 1,
        left: box.left,
        right: box.right,
      }
    })`)
    for (const sign of signs) {
      expect(sign.lines, sign.state).toBe(1)
      expect(sign.poleInside, sign.state).toBe(true)
      expect(sign.numbered, sign.state).toBe(sign.state === 'done' || sign.state === 'current')
      expect(sign.left).toBeGreaterThanOrEqual(0)
      expect(sign.right).toBeLessThanOrEqual(375)
    }
  })
})

test.describe('road signs on the reference page', () => {
  for (const width of [320, 375])
    test(`[design 7] [redesign 46] the moment text grows to 200 percent at ${String(width)} px, every road sign on the reference page is already inside the screen`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height: 812 })
      await page.goto('/design-reference')
      await expect(page.getByRole('heading', { level: 1, name: 'Design reference' })).toBeVisible()
      await page.evaluate('document.fonts.ready')
      // The text grows and the signs are measured in the same task, before any script can run between.
      const past = await page.evaluate<string[]>(`(() => {
      const style = document.createElement('style')
      style.textContent = 'html { font-size: 200% !important; }'
      document.head.appendChild(style)
      const width = document.documentElement.clientWidth
      return [...document.querySelectorAll('main ol > li[data-stop]')]
        .filter((li) => li.getBoundingClientRect().right > width + 0.5 || li.getBoundingClientRect().left < -0.5)
        .map((li) => li.getAttribute('data-state') + ' ' + li.getAttribute('data-stop'))
    })()`)
      expect(past).toEqual([])
    })
})

// The owner's choice of 2 November ("Number pins only"): when the text is too large for the drawn signs to
// fit, every sign becomes a small round pin with its stop number and no visible name, in the drawing's sign
// colours. The sun, its A1 and the fell labels stay clear, the card keeps the current stop's name, and each
// pin keeps its full stop name for screen readers. At normal text size nothing changes from round 6.

interface PinLook {
  pins: boolean
  signs: {
    stop: number
    state: string
    shown: string
    nameVisible: boolean
    width: number
    height: number
    box: { left: number; top: number; right: number; bottom: number }
  }[]
  scenery: { name: string; left: number; top: number; right: number; bottom: number }[]
  width: number
}

// What a sighted learner sees of each sign, and where the sun with its A1 and the fell labels are.
const PIN_LOOK = `(() => {
  const SUN = ${JSON.stringify(SUN_BOX)}
  const list = document.querySelector('ol[aria-label="Stops on your road"]')
  const scene = list.parentElement.getBoundingClientRect()
  const rect = (r) => ({ left: r.left, top: r.top, right: r.right, bottom: r.bottom })
  const visible = (el) => { const r = el.getBoundingClientRect(); const s = getComputedStyle(el); return r.width > 0 && r.height > 0 && s.display !== 'none' && s.visibility !== 'hidden' }
  return {
    pins: list.parentElement.getAttribute('data-pins') === 'on',
    width: document.documentElement.clientWidth,
    signs: [...list.children].map((li) => {
      const board = li.querySelector('[aria-hidden="true"]')
      const name = board.querySelector('[class*="_name_"]')
      const shown = [...board.querySelectorAll('*')]
        .filter((el) => el.tagName !== 'path' && (el.tagName === 'svg' || el.children.length === 0) && visible(el))
        .map((el) => el.tagName === 'svg' ? 'tick' : el.textContent.trim()).join(' ')
      const r = board.getBoundingClientRect()
      return { stop: Number(li.getAttribute('data-stop')), state: li.getAttribute('data-state'), shown, nameVisible: Boolean(name && visible(name)), width: r.width, height: r.height, box: rect(r) }
    }),
    scenery: [
      { name: 'sun and A1', left: scene.left + (SUN.left / ${String(SCENE_WIDTH)}) * scene.width, top: scene.top + (SUN.top / ${String(SCENE_HEIGHT)}) * scene.height, right: scene.left + (SUN.right / ${String(SCENE_WIDTH)}) * scene.width, bottom: scene.top + (SUN.bottom / ${String(SCENE_HEIGHT)}) * scene.height },
      ...[...document.querySelectorAll('ul[aria-label="Levels beyond A1"] > li')].map((li) => ({ name: li.textContent.trim(), ...rect(li.getBoundingClientRect()) })),
    ],
  }
})()`

const overlaps = (a: PinLook['scenery'][number], b: PinLook['signs'][number]['box']) =>
  a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom

test.describe('number pins when the text is too large for the drawn signs', () => {
  const STATES = [
    ['longest name current', currentAt(LONGEST[0])],
    ['longest name upcoming', currentAt(LONGEST[0] - 1)],
    ['stop 3 current', { 1: 4, 2: 4, 3: 2 }],
    ['first stop', currentAt(1)],
  ] as const
  for (const [width, height] of SCREENS)
    for (const [name, done] of STATES) {
      test(`[redesign 13] [redesign 46] ${String(width)} px, text at 200 percent, ${name}: every sign is a round number pin clear of the sun, A1 and the fell labels, with its full name for screen readers`, async ({
        page,
      }) => {
        await page.setViewportSize({ width, height })
        await page.addInitScript(LARGE_TEXT_FROM_THE_START)
        await realRoad(page, done)
        await page.goto('/learn')
        const list = page.getByRole('list', { name: 'Stops on your road' })
        await expect(list.locator('li[data-state="current"]')).toHaveCount(1)
        await page.waitForTimeout(700)
        const look = await page.evaluate<PinLook>(PIN_LOOK)
        expect(look.pins).toBe(true)
        expect(look.signs.length).toBeGreaterThanOrEqual(2)
        for (const sign of look.signs) {
          // A number, or a tick on a done stop, and no visible name.
          expect(sign.nameVisible, String(sign.stop)).toBe(false)
          expect(sign.shown, String(sign.stop)).toBe(sign.state === 'done' ? 'tick' : String(sign.stop))
          // Round and small.
          expect(Math.abs(sign.width - sign.height), String(sign.stop)).toBeLessThanOrEqual(1)
          expect(sign.width).toBeLessThan(width / 4)
          expect(sign.box.left).toBeGreaterThanOrEqual(0)
          expect(sign.box.right).toBeLessThanOrEqual(look.width)
          for (const thing of look.scenery)
            expect(overlaps(thing, sign.box), `stop ${String(sign.stop)} over ${thing.name}`).toBe(false)
        }
        // Screen readers still hear each stop's full name: the list as the accessibility tree has it.
        const tree = await list.ariaSnapshot()
        for (const sign of look.signs)
          expect(tree).toContain(`Stop ${String(sign.stop)}, ${REAL_NAMES.get(sign.stop) ?? ''},`)
        // The card that kept the current stop's name is gone (fast route road-stops): the name is still
        // read out from the list above, and the stop screen says it in full (e2e/road-stops.spec.ts).
        const current = look.signs.find((sign) => sign.state === 'current')
        expect(tree).toContain(
          `Stop ${String(current?.stop ?? 0)}, ${REAL_NAMES.get(current?.stop ?? 0) ?? ''}, current`,
        )
      })
    }

  for (const [width, height] of SCREENS)
    test(`[redesign 13] [redesign 46] ${String(width)} px: when the text grows to 200 percent the signs become pins, still never past the screen edge`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height })
      await realRoad(page, currentAt(LONGEST[0]))
      await page.goto('/learn')
      await expect(
        page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem'),
      ).not.toHaveCount(0)
      await page.waitForTimeout(500)
      expect((await page.evaluate<PinLook>(PIN_LOOK)).pins).toBe(false)
      const frames = await page.evaluate<Frame[]>(`${WATCH}(true)`)
      expect(frames.filter((frame) => frame.out.length > 0)).toEqual([])
      const look = await page.evaluate<PinLook>(PIN_LOOK)
      expect(look.pins).toBe(true)
      for (const sign of look.signs) expect(sign.nameVisible).toBe(false)
    })

  for (const [width, height] of SCREENS)
    test(`[redesign 13] ${String(width)} px, normal text: the drawn signs are unchanged, names on one line and no number on upcoming signs`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height })
      await realRoad(page, currentAt(LONGEST[0]))
      await page.goto('/learn')
      await expect(
        page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem'),
      ).not.toHaveCount(0)
      await page.waitForTimeout(500)
      const look = await page.evaluate<PinLook>(PIN_LOOK)
      expect(look.pins).toBe(false)
      for (const sign of look.signs) {
        const name = REAL_NAMES.get(sign.stop) ?? ''
        expect(sign.nameVisible, name).toBe(true)
        // Done: tick and name. Current: number and name. Upcoming: the name only.
        const expected =
          sign.state === 'done'
            ? `tick ${name}`
            : sign.state === 'current'
              ? `${String(sign.stop)} ${name}`
              : name
        expect(sign.shown).toBe(expected)
        expect(sign.width).toBeGreaterThan(sign.height * 2)
      }
    })

  test('[design 7] [redesign 46] the reference page shows number pins at 320 px with text at 200 percent', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 812 })
    await page.addInitScript(LARGE_TEXT_FROM_THE_START)
    await page.goto('/design-reference')
    await expect(page.getByRole('heading', { level: 1, name: 'Design reference' })).toBeVisible()
    await page.waitForTimeout(700)
    const pins = await page.evaluate<boolean[]>(
      `[...document.querySelectorAll('ol[aria-label="Stops on your road"]')].map((list) => list.parentElement.getAttribute('data-pins') === 'on')`,
    )
    expect(pins.length).toBeGreaterThan(0)
    expect(pins.every(Boolean)).toBe(true)
  })
})
