import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page, type Request } from '@playwright/test'
import { INTRO_KEY } from '../src/lib/intro-answers.ts'
import { FIRST_LINE_AUDIO } from '../src/lib/intro-first-line.ts'
import { roadFixture } from '../src/road/road-fixture.ts'
import { GUEST_LINE } from '../src/screens/road-copy.ts'
import { mockHome, type HomeMocks } from './road-mocks.ts'

// The first-open questions and the recap card (fast route "intro", the
// owner's five-line plan of 3 November 2026). [intro N] is the plan's item:
// 1 the two questions with Skip, 2 the recap card, 3 the answers stay on the
// phone, 4 once per phone and never for a returning learner. These answer the
// road's reads themselves (e2e/road-mocks.ts), so they need no database, and
// they use plain Playwright, so the phone has not seen the questions.

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
const REASON = 'Why are you learning Finnish?'
const TIME = 'When will you practise?'
const SKIP = { name: 'Skip this question' }

async function openRoad(page: Page, mocks: HomeMocks = {}) {
  const calls = await mockHome(page, mocks)
  await page.goto('/')
  await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
  return calls
}

const start = (page: Page) => page.getByRole('button', { name: 'Start', exact: true })
const heading = (page: Page, name: string) => page.getByRole('heading', { level: 1, name })
const stored = (page: Page) =>
  page.evaluate<string | null>(`localStorage.getItem(${JSON.stringify(INTRO_KEY)})`)

test.describe('the first-open questions', () => {
  test('[intro 1] [intro 2] Start on day one asks two questions, one per screen, then shows the recap card; only its Start makes the guest', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    await start(page).click()

    await expect(heading(page, REASON)).toBeFocused()
    const reasons = page.getByRole('list', { name: REASON }).getByRole('button')
    await expect(reasons).toHaveText(['Work', 'Daily life', 'Family and friends', 'Studies'])
    await expect(page.getByRole('button', SKIP)).toHaveText('Skip')
    await page.getByRole('button', { name: 'Family and friends' }).click()

    await expect(heading(page, TIME)).toBeFocused()
    const times = page.getByRole('list', { name: TIME }).getByRole('button')
    await expect(times).toHaveText(['Morning', 'Lunch break', 'Evening', 'No fixed time'])
    await page.getByRole('button', { name: 'Evening' }).click()

    // The recap card on the road: stop 1 from the road data, its "I can" line, the first line, Start.
    const card = page.getByRole('region', { name: 'Today' })
    await expect(card.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeFocused()
    const stop1 = roadFixture({})[0]
    await expect(card.getByText(`I can ${stop1?.canDo ?? ''}.`, { exact: true })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Play your first line' })).toBeVisible()
    await expect(card.getByText(GUEST_LINE)).toBeVisible()
    await expect(card.getByRole('link', { name: 'Privacy notice' })).toHaveAttribute('href', '/privacy')
    expect(calls.guest).toBe(0)

    await card.getByRole('button', { name: 'Start', exact: true }).click()
    await expect.poll(() => calls.guest).toBe(1)
    await page.waitForURL('**/session')
  })

  test('[intro 1] Skip on each screen moves on without an answer, and the back arrow goes back a screen', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    await start(page).click()
    await page.getByRole('button', SKIP).click()
    await expect(heading(page, TIME)).toBeVisible()
    await page.getByRole('button', { name: 'Back to the first question' }).click()
    await expect(heading(page, REASON)).toBeFocused()
    await page.getByRole('button', { name: 'Back to the road' }).click()
    await expect(start(page)).toBeVisible()
    await expect(page.getByText(GUEST_LINE)).toBeVisible()
    expect(await stored(page)).toBeNull()

    await start(page).click()
    await page.getByRole('button', SKIP).click()
    await page.getByRole('button', SKIP).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()
    expect(JSON.parse((await stored(page)) ?? '')).toEqual({ seen: true })
    expect(calls.guest).toBe(0)
  })

  test('[intro 3] the answers stay on the phone: kept in its storage, never in a request', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    const sent: Request[] = []
    page.on('request', (request) => sent.push(request))
    await start(page).click()
    await page.getByRole('button', { name: 'Work' }).click()
    await page.getByRole('button', { name: 'Lunch break' }).click()
    expect(JSON.parse((await stored(page)) ?? '')).toEqual({
      seen: true,
      reason: 'work',
      time: 'lunch-break',
    })
    // Answering sent nothing to the Worker.
    expect(sent.filter((request) => new URL(request.url()).pathname.startsWith('/api/'))).toEqual([])

    await start(page).click()
    await expect.poll(() => calls.guest).toBe(1)
    for (const request of sent) {
      const text = `${request.url()} ${request.postData() ?? ''}`
      expect(text).not.toMatch(/work|lunch/i)
    }
    expect(
      sent.filter((request) => request.method() !== 'GET').map((r) => new URL(r.url()).pathname),
    ).toEqual(['/api/guest'])
  })

  test('[intro 2] the play button plays the real first line, fetched only when pressed', async ({ page }) => {
    await openRoad(page)
    const audio: string[] = []
    page.on('request', (request) => {
      if (new URL(request.url()).pathname.startsWith('/audio/')) audio.push(new URL(request.url()).pathname)
    })
    await start(page).click()
    await page.getByRole('button', SKIP).click()
    await page.getByRole('button', SKIP).click()
    const play = page.getByRole('button', { name: 'Play your first line' })
    await expect(play).toBeVisible()
    expect(audio).toEqual([])
    const answer = page.waitForResponse((response) => new URL(response.url()).pathname === FIRST_LINE_AUDIO)
    await play.click()
    expect((await answer).ok()).toBe(true)
  })
})

test.describe('once per phone', () => {
  test('[intro 4] after the questions, a reload goes straight from Start to the session', async ({
    page,
  }) => {
    const calls = await openRoad(page)
    await start(page).click()
    await page.getByRole('button', SKIP).click()
    await page.getByRole('button', { name: 'Morning' }).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()

    await page.reload()
    await expect(start(page)).toBeVisible()
    await expect(page.getByRole('button', { name: 'Play your first line' })).toHaveCount(0)
    await start(page).click()
    await expect.poll(() => calls.guest).toBe(1)
    await expect(heading(page, REASON)).toHaveCount(0)
  })

  test('[intro 4] a learner with a guest session or an account never sees the questions', async ({
    page,
  }) => {
    const calls = await openRoad(page, { today: { signedIn: true, today: 'start' }, done: { 1: 1 } })
    await start(page).click()
    await expect.poll(() => calls.guest).toBe(1)
    await expect(heading(page, REASON)).toHaveCount(0)
  })

  test('[intro 4] a guest whose session ended on this phone goes straight to Start as today', async ({
    page,
  }) => {
    const calls = await openRoad(page, { today: { signedIn: false, ended: true } })
    await expect(page.getByText('Your guest session ended on this device.', { exact: false })).toBeVisible()
    await start(page).click()
    await expect.poll(() => calls.guest).toBe(1)
    await expect(heading(page, REASON)).toHaveCount(0)
  })
})

test.describe('when the phone refuses storage', () => {
  test('[intro 3] storage that cannot even be reached: the questions and Start still work', async ({
    page,
  }) => {
    await page.addInitScript({
      content: `Object.defineProperty(window, 'localStorage', { configurable: true, get() { throw new DOMException('The operation is insecure.', 'SecurityError') } })`,
    })
    const calls = await openRoad(page)
    await start(page).click()
    await page.getByRole('button', { name: 'Studies' }).click()
    await page.getByRole('button', { name: 'No fixed time' }).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()
    await start(page).click()
    await expect.poll(() => calls.guest).toBe(1)
  })

  test('[intro 3] storage that refuses to write: the flow works and simply shows again next time', async ({
    page,
  }) => {
    await page.addInitScript({
      content: `Storage.prototype.setItem = () => { throw new DOMException('Quota exceeded', 'QuotaExceededError') }`,
    })
    const calls = await openRoad(page)
    await start(page).click()
    await page.getByRole('button', { name: 'Daily life' }).click()
    await page.getByRole('button', SKIP).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()
    await page.reload()
    await start(page).click()
    await expect(heading(page, REASON)).toBeVisible()
    expect(calls.guest).toBe(0)
  })
})

test.describe('accessibility of the three screens', () => {
  async function check(page: Page) {
    await page.evaluate('document.fonts.ready')
    const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
    expect(
      result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
    ).toEqual([])
    // Every control is at least 44 px both ways, and nothing scrolls sideways.
    for (const control of await page.locator('main button:visible, main a[href]:visible').all()) {
      const box = await control.boundingBox()
      const name = (await control.getAttribute('aria-label')) ?? (await control.innerText())
      if (name.trim() === 'Privacy notice' || name.trim() === 'Sign in') continue
      expect(box?.height ?? 0, name).toBeGreaterThanOrEqual(44)
      expect(box?.width ?? 0, name).toBeGreaterThanOrEqual(44)
    }
    expect(
      await page.evaluate<boolean>(
        'document.documentElement.scrollWidth > document.documentElement.clientWidth + 1',
      ),
    ).toBe(false)
  }

  test('[intro 1] [intro 2] axe finds no WCAG A or AA problem, and every target is 44 px', async ({
    page,
  }) => {
    await openRoad(page)
    await start(page).click()
    await expect(heading(page, REASON)).toBeVisible()
    await check(page)
    await page.getByRole('button', { name: 'Work' }).click()
    await expect(heading(page, TIME)).toBeVisible()
    await check(page)
    await page.getByRole('button', { name: 'Evening' }).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()
    await check(page)
  })

  test('[intro 1] from the question, the keyboard reaches the answers, then Skip, in reading order', async ({
    page,
    browserName,
  }) => {
    test.skip(browserName === 'webkit', 'WebKit skips buttons on Tab unless a system setting allows it')
    await openRoad(page)
    await start(page).click()
    await expect(heading(page, REASON)).toBeFocused()
    const order: string[] = []
    for (let i = 0; i < 5; i += 1) {
      await page.keyboard.press('Tab')
      order.push(
        await page.evaluate<string>(
          'document.activeElement.getAttribute("aria-label") || document.activeElement.innerText',
        ),
      )
    }
    expect(order).toEqual(['Work', 'Daily life', 'Family and friends', 'Studies', 'Skip this question'])
    // The back arrow comes before the question in the page, so Shift+Tab from the question reaches it.
    await heading(page, REASON).focus()
    await page.keyboard.press('Shift+Tab')
    await expect(page.getByRole('button', { name: 'Back to the road' })).toBeFocused()
  })

  test('[intro 2] a 40 letter stop name wraps inside the recap card at 375 px and at 320 px', async ({
    page,
  }) => {
    const long = 'Kansainvälistymiskehittämisohjelmaneuvot'
    expect(long).toHaveLength(40)
    const stops = roadFixture({}).map((stop, index) => (index === 0 ? { ...stop, name: long } : stop))
    await mockHome(page)
    await page.route('**/api/road', (route) =>
      route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ stops }) }),
    )
    for (const width of [375, 320]) {
      await page.setViewportSize({ width, height: 812 })
      await page.goto('/')
      await page.evaluate(`localStorage.removeItem(${JSON.stringify(INTRO_KEY)})`)
      await start(page).click()
      await page.getByRole('button', SKIP).click()
      await page.getByRole('button', SKIP).click()
      const title = page.getByRole('heading', { level: 2, name: long })
      await expect(title).toBeVisible()
      const fits = await page.evaluate<boolean>(`(() => {
        const title = [...document.querySelectorAll('section h2')].find((h) => h.textContent === ${JSON.stringify(long)})
        const card = title.closest('section').getBoundingClientRect()
        const box = title.getBoundingClientRect()
        return box.right <= card.right + 0.5 && box.left >= card.left - 0.5
      })()`)
      expect(fits).toBe(true)
      expect(
        await page.evaluate<boolean>(
          'document.documentElement.scrollWidth > document.documentElement.clientWidth + 1',
        ),
      ).toBe(false)
    }
  })
})

// The three screens at 375 px for the owner, made on purpose (PUHUSCRIBE_EVIDENCE=1), Chromium only.
test.describe('evidence', () => {
  test.skip(process.env.PUHUSCRIBE_EVIDENCE !== '1', 'Evidence is made on purpose (PUHUSCRIBE_EVIDENCE=1).')

  test('the three screens at 375 x 812', async ({ page, browserName }) => {
    test.skip(browserName !== 'chromium', 'Taken once.')
    const folder = 'factory/jobs/intro/evidence'
    await openRoad(page)
    await page.evaluate('document.fonts.ready')
    await page.screenshot({ path: `${folder}/0-day-one-road.png` })
    await start(page).click()
    await expect(heading(page, REASON)).toBeVisible()
    await page.screenshot({ path: `${folder}/1-why-question.png` })
    await page.getByRole('button', { name: 'Family and friends' }).click()
    await expect(heading(page, TIME)).toBeVisible()
    await page.screenshot({ path: `${folder}/2-when-question.png` })
    await page.getByRole('button', { name: 'Evening' }).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Meeting people' })).toBeVisible()
    await page.waitForTimeout(400)
    await page.screenshot({ path: `${folder}/3-recap-card.png` })
  })
})
