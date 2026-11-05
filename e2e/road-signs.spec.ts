import { expect, test } from '@playwright/test'
import { STOP_SHORT_NAMES } from '../src/lib/stop-short-names.ts'
import { mockHome } from './road-mocks.ts'

// Fast route road-signs (owner approved 5 November 2026). Labels in brackets are the "Done when" numbers of
// the job's brief: 2 short names on the road, full names for screen readers; 3 deep mint upcoming boards
// with white text and a rim; 4 done and upcoming signs differ; 5 the landing hero shows short names.

const SIGN_LOOK = `(() => [...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => {
  const board = li.querySelector('[data-sign-board]')
  const name = board.querySelector('[data-sign-name]')
  const num = board.querySelector('span')
  const s = getComputedStyle(board)
  const after = getComputedStyle(board, '::after')
  return {
    stop: Number(li.getAttribute('data-stop')),
    state: li.getAttribute('data-state'),
    name: name.textContent.trim(),
    background: s.backgroundColor,
    color: getComputedStyle(name).color,
    weight: getComputedStyle(name).fontWeight,
    wrap: getComputedStyle(name).overflowWrap,
    shadow: s.boxShadow,
    rimWidth: after.borderTopWidth,
    rimColor: after.borderTopColor,
    numShown: getComputedStyle(num).display !== 'none' && num !== name,
    tick: Boolean(board.querySelector('svg')),
    numBackground: num !== name ? getComputedStyle(num).backgroundColor : '',
  }
}))()`

interface Look {
  stop: number
  state: string
  name: string
  background: string
  color: string
  weight: string
  wrap: string
  shadow: string
  rimWidth: string
  rimColor: string
  numShown: boolean
  tick: boolean
  numBackground: string
}

const rgb = (text: string) => (text.match(/\d+(\.\d+)?/g) ?? []).slice(0, 3).map(Number)
const lum = ([r = 0, g = 0, b = 0]: number[]) => {
  const f = (v: number) => {
    const c = v / 255
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
  }
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)
}
const ratio = (a: number[], b: number[]) => {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x)
  return ((hi ?? 0) + 0.05) / ((lo ?? 0) + 0.05)
}

async function openRoad(page: import('@playwright/test').Page, done: Record<number, number>) {
  await mockHome(page, { today: { signedIn: true, today: 'continue' }, done })
  await page.goto('/learn')
  await expect(page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem')).not.toHaveCount(
    0,
  )
  await page.waitForTimeout(700)
}

test.describe('road signs with short names', () => {
  test('[road-signs 2] the road shows short names and the screen-reader labels keep the full names', async ({
    page,
  }) => {
    await openRoad(page, { 1: 4, 2: 4, 3: 1 })
    const looks = await page.evaluate<Look[]>(SIGN_LOOK)
    expect(looks.length).toBeGreaterThan(2)
    for (const look of looks) {
      expect(look.name).toBe(STOP_SHORT_NAMES[look.stop])
      expect(look.name.length).toBeLessThanOrEqual(16)
    }
    const tree = await page.getByRole('list', { name: 'Stops on your road' }).ariaSnapshot()
    expect(tree).toContain('Stop 4, Numbers, prices and paying, later')
    expect(tree).toContain('Stop 3, At the grocery store, current')
  })

  test('[road-signs 3] [road-signs 4] upcoming boards are deep mint with a white name and rim, and differ from done signs', async ({
    page,
  }) => {
    await openRoad(page, { 1: 4, 2: 4, 3: 1 })
    const looks = await page.evaluate<Look[]>(SIGN_LOOK)
    const upcoming = looks.filter((look) => look.state === 'next' || look.state === 'later')
    const done = looks.filter((look) => look.state === 'done')
    expect(upcoming.length).toBeGreaterThan(0)
    expect(done.length).toBeGreaterThan(0)
    for (const look of upcoming) {
      expect(rgb(look.background), `stop ${String(look.stop)}`).toEqual([26, 111, 93])
      expect(rgb(look.color)).toEqual([255, 255, 255])
      expect(Number(look.weight)).toBeGreaterThanOrEqual(600)
      expect(look.wrap).toBe('anywhere')
      expect(look.rimWidth).not.toBe('0px')
      expect(rgb(look.rimColor)).toEqual([255, 255, 255])
      expect(look.shadow).not.toBe('none')
      expect(look.numShown).toBe(false)
      expect(ratio(rgb(look.color), rgb(look.background))).toBeGreaterThanOrEqual(4.5)
    }
    for (const look of done) {
      expect(rgb(look.rimColor)).toEqual([255, 255, 255])
      expect(look.rimWidth).not.toBe('0px')
      expect(look.tick).toBe(true)
      // Done signs are the lighter mint; upcoming signs are the deeper one.
      expect(look.background).not.toBe(upcoming[0]?.background)
      expect(look.numBackground).not.toBe('rgba(0, 0, 0, 0)')
      expect(ratio(rgb(look.color), rgb(look.background))).toBeGreaterThanOrEqual(4.5)
    }
    const current = looks.find((look) => look.state === 'current')
    expect(rgb(current?.background ?? '')).toEqual([255, 255, 255])
    expect(current?.rimWidth).toBe('0px')
    expect(current?.numShown).toBe(true)
  })

  test('[road-signs 5] the landing hero road shows short names', async ({ page }) => {
    await page.goto('/')
    await page.waitForSelector('ol[aria-label="Stops on your road"] [data-sign-name]', { state: 'attached' })
    const names = await page.evaluate<string[]>(
      `[...document.querySelectorAll('ol[aria-label="Stops on your road"] > li')].map((li) => li.querySelector('[data-sign-name]').textContent.trim())`,
    )
    expect(names.length).toBeGreaterThan(2)
    for (const name of names) expect(Object.values(STOP_SHORT_NAMES)).toContain(name)
  })
})
