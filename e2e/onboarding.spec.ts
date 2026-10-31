import { readFileSync } from 'node:fs'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page } from '@playwright/test'
import {
  WELCOME_HEADING,
  WELCOME_ORDER,
  WELCOME_SESSION,
  WELCOME_SPOKEN,
  WELCOME_SPOKEN_LABEL,
  WELCOME_TWO_FORMS,
  WELCOME_WRITTEN,
  WELCOME_WRITTEN_LABEL,
} from '../src/screens/welcome-copy.ts'
import { contrast } from '../src/lib/contrast.ts'
import { asMap, colourTokens } from '../src/styles/token-values.ts'
import { addEmail, startGuest, testAddress } from './account-helpers.ts'
import { recordApiTimings } from './api-timing.ts'
import { linesOf, one, sessionsOf, userIdOf } from './db.ts'
import {
  isGuestPost,
  recordRequests,
  scrollsSideways,
  serveTone,
  settleAnimations,
  tabTo,
} from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/15-onboarding/spec.md ([onboarding N]).
//
// Phone size (375 x 812) in Chromium and WebKit, against the built app. The
// "new visitor" tests need no database and make no account, so they also run
// against the test project and preview links. The tests that press Start, use
// a guest or an email account, or read the fixture dialogue are tagged @seed
// (and @email), as in jobs 8 and 11, and run only on the pull request check's
// throwaway local Supabase. Tests that stand in for a returning learner by
// answering GET /api/today themselves say so in their names; each has a real
// account twin among the @seed tests. e2e/ is type checked without the
// browser's types, so in-page expressions are passed as text.
//
// Statement 7's command (git diff --stat main...HEAD) is tests/onboarding-rules.test.ts.
// Statement 12 (the hallway test) is a human test: factory/jobs/15-onboarding/evidence/hallway-test.md.

test.beforeEach(({ page }, testInfo) => {
  recordApiTimings(page, testInfo)
})

// The front door's own messages, written out here as the earlier browser tests
// write them (the screen files import CSS and the DOM, which e2e/ is not
// type checked for).
const GUEST_LINE =
  'Starting creates a guest account on this device so your progress is saved. PuhuScribe is for adults, 18 and over.'
const ENDED = 'Your guest session ended on this device. Press Start to begin again.'
const SIGNED_OUT = 'You are signed out on this device.'
const SIGNED_OUT_EMAIL = 'You are signed out on this device. Sign in with your email to continue.'
const DELETED = 'Your account and all its data are deleted.'

const REGION_NAME = 'Welcome to PuhuScribe'
const START_NAME = 'Start'
const TOKENS = colourTokens(readFileSync('src/styles/tokens.css', 'utf8'))
const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']
const SCHEMES = ['light', 'dark'] as const

const welcomeOf = (page: Page) => page.getByRole('region', { name: REGION_NAME, exact: true })
const startOf = (page: Page) => page.getByRole('button', { name: START_NAME, exact: true })
const guestLineOf = (page: Page) => page.getByText(GUEST_LINE, { exact: true })

/** The words of the welcome, block by block, as the page should show them. */
const WELCOME_LINES = [
  WELCOME_HEADING,
  WELCOME_SESSION,
  WELCOME_TWO_FORMS,
  WELCOME_SPOKEN_LABEL,
  WELCOME_SPOKEN,
  WELCOME_WRITTEN_LABEL,
  WELCOME_WRITTEN,
  WELCOME_ORDER,
]

/** A token's colour the way a browser reports it: rgb(r, g, b). */
function rgb(hex: string): string {
  const n = Number.parseInt(hex.slice(1, 7), 16)
  return `rgb(${String((n >> 16) & 255)}, ${String((n >> 8) & 255)}, ${String(n & 255)})`
}

function token(scheme: (typeof SCHEMES)[number], name: string): string {
  const value = asMap(TOKENS[scheme]).get(name)
  if (!value) throw new Error(`No colour token ${name} in ${scheme} mode.`)
  return rgb(value)
}

/** The little of an element that the marking step below uses (e2e/ is type checked without the DOM types). */
interface Probe {
  setAttribute(name: string, value: string): void
  removeAttribute(name: string): void
}

/**
 * Runs an expression, written as text, on one element of the page. A function
 * written as text is not called by Locator.evaluate, so the element is marked
 * for a moment, found again by the page level expression, and unmarked. The
 * mark matches no style.
 */
async function onElement<T>(target: Locator, expression: string): Promise<T> {
  await target.evaluate((el: Probe) => {
    el.setAttribute('data-test-probe', '')
  })
  try {
    return await target.page().evaluate<T>(`(${expression})(document.querySelector('[data-test-probe]'))`)
  } finally {
    await target.evaluate((el: Probe) => {
      el.removeAttribute('data-test-probe')
    })
  }
}

/** A token's colour as #rrggbb (6 digit tokens only). */
function hexOf(scheme: (typeof SCHEMES)[number], name: string): string {
  const value = asMap(TOKENS[scheme]).get(name)
  if (!value || !/^#[0-9a-f]{6}$/.test(value))
    throw new Error(`No opaque colour token ${name} in ${scheme} mode.`)
  return value
}

/** A computed colour, rgb(r, g, b), as #rrggbb. */
function hexFromRgb(colour: string): string {
  const parts = /^rgba?\((\d+), (\d+), (\d+)/.exec(colour)
  if (!parts) throw new Error(`Not an opaque colour: ${colour}`)
  return `#${[parts[1], parts[2], parts[3]].map((n) => Number(n).toString(16).padStart(2, '0')).join('')}`
}

async function style(target: Locator, property: string): Promise<string> {
  return onElement<string>(target, `(el) => getComputedStyle(el).${property}`)
}

/** The front door as a new visitor opens it, waiting until /api/today has answered. */
async function openAsNewVisitor(page: Page, scheme?: (typeof SCHEMES)[number]) {
  if (scheme) await page.emulateMedia({ colorScheme: scheme })
  await page.goto('/')
  await expect(welcomeOf(page)).toBeVisible()
  await page.evaluate('document.fonts.ready')
}

/** Answers GET /api/today with a made up body, as the Worker would for the state named. */
async function answerToday(page: Page, body: unknown, delayMs = 0) {
  await page.route('**/api/today', async (route) => {
    if (delayMs > 0) await new Promise((resolve) => setTimeout(resolve, delayMs))
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(body) })
  })
}

async function axe(page: Page, label: string) {
  await page.evaluate('document.fonts.ready')
  // A colour scheme switched on an open page starts the buttons' colour
  // transitions; axe must measure the finished colours, not a frame halfway.
  await settleAnimations(page)
  const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
  expect(
    result.violations.map((v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
  ).toEqual([])
}

// A new visitor: the page ---------------------------------------------------------------

test.describe('the welcome for a new visitor', () => {
  test('[onboarding 1] the front door shows, in order, the wordmark, the heading, the lead sentence, the welcome, Start, the guest line, "I already have an account" and the links', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    const parts: [string, Locator][] = [
      ['wordmark', page.getByRole('img', { name: 'PuhuScribe' })],
      ['heading', page.getByRole('heading', { level: 1, name: "Today's session" })],
      [
        'lead sentence',
        page.getByText(
          'A session is one short Finnish dialogue that you hear line by line and then check you understand.',
          { exact: true },
        ),
      ],
      ['welcome', welcomeOf(page)],
      ['Start', startOf(page)],
      ['guest line', guestLineOf(page)],
      ['already have an account', page.getByRole('button', { name: 'I already have an account' })],
      ['privacy link', page.getByRole('link', { name: 'Privacy notice' })],
      ['account link', page.getByRole('link', { name: 'Your account' })],
    ]
    let previous = -1
    for (const [name, part] of parts) {
      await expect(part, name).toBeVisible()
      const box = await part.boundingBox()
      expect(box, name).not.toBeNull()
      // Each part starts below the top of the one before it, in reading order
      // (the privacy and account links share one row).
      if (name === 'account link') expect(box?.y ?? -1, name).toBeGreaterThanOrEqual(previous)
      else expect(box?.y ?? -1, name).toBeGreaterThan(previous)
      previous = box?.y ?? -1
    }
    // The welcome ends before Start begins, and the guest line is the very next
    // element after Start with nothing between them.
    const welcome = await welcomeOf(page).boundingBox()
    const start = await startOf(page).boundingBox()
    expect((welcome?.y ?? 0) + (welcome?.height ?? 0)).toBeLessThanOrEqual(start?.y ?? 0)
    const adjacent = await page.evaluate<boolean>(`(() => {
      const start = [...document.querySelectorAll('button')].find((b) => b.textContent.trim() === 'Start')
      const next = start ? start.nextElementSibling : null
      return Boolean(next) && next.tagName === 'P' && next.textContent.trim() === ${JSON.stringify(GUEST_LINE)}
    })()`)
    expect(adjacent).toBe(true)
    // The welcome comes after the lead sentence in the document too (the
    // order above is by position, this is by structure).
    const inOrder = await page.evaluate<boolean>(`(() => {
      const all = [...document.querySelectorAll('main *')]
      const at = (el) => all.indexOf(el)
      const lead = all.find((el) => el.tagName === 'P' && el.textContent.startsWith('A session is one short'))
      const region = document.querySelector('section[aria-labelledby]')
      const start = [...document.querySelectorAll('button')].find((b) => b.textContent.trim() === 'Start')
      return at(lead) < at(region) && at(region) < at(start)
    })()`)
    expect(inOrder).toBe(true)
  })

  test('[onboarding 2] the welcome shows exactly the words of welcome-copy.ts and no other text', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    const region = welcomeOf(page)
    const shown = (await region.innerText())
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.length > 0)
    expect(shown).toEqual(WELCOME_LINES)
    // Hidden text would not show in innerText, so the whole text content is read too.
    const everything = await onElement<string>(region, '(el) => el.textContent')
    expect(everything.replace(/\s+/g, ' ').trim()).toBe(WELCOME_LINES.join('').replace(/\s+/g, ' ').trim())
    expect(await region.getByRole('heading', { level: 2, name: WELCOME_HEADING }).count()).toBe(1)
  })

  for (const scheme of SCHEMES) {
    test(`[onboarding 3] the Spoken band, then the Written band, in the Hear it colours, ${scheme}`, async ({
      page,
    }) => {
      await openAsNewVisitor(page, scheme)
      const region = welcomeOf(page)
      const spokenLabel = region.getByText(WELCOME_SPOKEN_LABEL, { exact: true })
      const writtenLabel = region.getByText(WELCOME_WRITTEN_LABEL, { exact: true })
      await expect(spokenLabel).toBeVisible()
      await expect(writtenLabel).toBeVisible()
      // Spoken first, then Written, each labelled in text.
      const spokenBox = await spokenLabel.boundingBox()
      const writtenBox = await writtenLabel.boundingBox()
      expect(spokenBox?.y ?? 0).toBeLessThan(writtenBox?.y ?? 0)
      // Colours against the tokens.
      expect(await style(spokenLabel, 'color')).toBe(token(scheme, '--color-spoken-text'))
      expect(await style(writtenLabel, 'color')).toBe(token(scheme, '--color-written'))
      const band = region.locator('div', { hasText: WELCOME_SPOKEN })
      expect(await style(band, 'backgroundColor')).toBe(token(scheme, '--color-spoken-band'))
      for (const sentence of [
        WELCOME_SESSION,
        WELCOME_TWO_FORMS,
        WELCOME_SPOKEN,
        WELCOME_WRITTEN,
        WELCOME_ORDER,
      ]) {
        expect(await style(region.getByText(sentence, { exact: true }), 'color'), sentence).toBe(
          token(scheme, '--color-text'),
        )
      }
      // Azure marks only the words that change, so nothing in the block is azure.
      const azure = [token(scheme, '--color-flag-text'), token(scheme, '--color-flag-wash')]
      const used = await onElement<string[]>(
        region,
        `(el) => [el, ...el.querySelectorAll('*')].flatMap((node) => {
        const s = getComputedStyle(node)
        return [s.color, s.backgroundColor, s.borderTopColor]
      })`,
      )
      for (const colour of azure) expect(used).not.toContain(colour)
    })
  }

  test('[onboarding 4] the welcome holds no button, link, input, select, text area or tap target, no Finnish and no question', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    const region = welcomeOf(page)
    await expect(
      region.locator(
        'button, a, input, select, textarea, [role="button"], [role="link"], [tabindex], [contenteditable], [onclick]',
      ),
    ).toHaveCount(0)
    for (const role of ['button', 'link', 'textbox', 'combobox', 'checkbox', 'radio', 'switch'] as const) {
      await expect(region.getByRole(role), role).toHaveCount(0)
    }
    await expect(region.locator('[lang]')).toHaveCount(0)
    expect(await region.innerText()).not.toMatch(/[äöåÄÖÅ]/)
    expect(await region.innerText()).not.toContain('?')
  })

  test('[onboarding 11] the block has no picture, icon, emoji, uppercase label, carousel, accent border, table style row or gradient', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    const region = welcomeOf(page)
    await expect(
      region.locator('img, picture, video, canvas, svg, object, embed, i, table, ul, ol'),
    ).toHaveCount(0)
    await expect(
      region.locator('[role="tablist"], [role="tab"], [aria-roledescription], [role="img"], hr'),
    ).toHaveCount(0)
    expect(await region.innerText()).not.toMatch(/[\p{Extended_Pictographic}•●○]/u)
    const problems = await onElement<string[]>(
      region,
      `(el) => [el, ...el.querySelectorAll('*')].flatMap((node) => {
      const s = getComputedStyle(node)
      const found = []
      const name = node.tagName.toLowerCase() + '.' + String(node.className)
      if (s.textTransform === 'uppercase') found.push(name + ' uppercase')
      if (s.backgroundImage !== 'none') found.push(name + ' background image ' + s.backgroundImage)
      if (s.boxShadow !== 'none') found.push(name + ' shadow')
      if (s.display.startsWith('table')) found.push(name + ' table display')
      if (s.transform !== 'none') found.push(name + ' transform')
      const widths = [s.borderTopWidth, s.borderRightWidth, s.borderBottomWidth, s.borderLeftWidth].map(parseFloat)
      if (Math.max(...widths) > 2) found.push(name + ' border wider than 2 px')
      // A border on one side only is an accent bar or a row line.
      if (Math.max(...widths) > 0 && Math.min(...widths) === 0) found.push(name + ' border on some sides only')
      return found
    })`,
    )
    expect(problems).toEqual([])
  })
})

// Who sees it ---------------------------------------------------------------------------

test.describe('who sees the welcome', () => {
  test('[onboarding 5] a new visitor sees it', async ({ page }) => {
    const today = page.waitForResponse((res) => new URL(res.url()).pathname === '/api/today')
    await page.goto('/')
    expect(await (await today).json()).toEqual({ signedIn: false, ended: false })
    await expect(welcomeOf(page)).toBeVisible()
    await expect(startOf(page)).toBeVisible()
  })

  for (const [key, message] of [
    ['signed-out', SIGNED_OUT],
    ['signed-out-email', SIGNED_OUT_EMAIL],
    ['deleted', DELETED],
  ] as const) {
    test(`[onboarding 5] the notice "${key}" shows its message and no welcome`, async ({ page }) => {
      await page.goto(`/?notice=${key}`)
      await expect(page.getByRole('status')).toHaveText(message)
      await expect(startOf(page)).toBeVisible()
      await expect(welcomeOf(page)).toHaveCount(0)
      await expect(page.getByRole('heading', { level: 2 })).toHaveCount(0)
      // A reload shows the same.
      await page.reload()
      await expect(page.getByRole('status')).toHaveText(message)
      await expect(welcomeOf(page)).toHaveCount(0)
    })
  }

  test("[onboarding 5] (standing in for the ended state) a guest whose account is gone sees job 8's message and no welcome", async ({
    page,
  }) => {
    await answerToday(page, { signedIn: false, ended: true })
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText(ENDED)
    await expect(startOf(page)).toBeVisible()
    await expect(welcomeOf(page)).toHaveCount(0)
  })

  test("[onboarding 5] (standing in for the email account's signed out state) the signed out message shows and no welcome", async ({
    page,
  }) => {
    await answerToday(page, { signedIn: false, ended: true, account: 'email' })
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText(SIGNED_OUT_EMAIL)
    await expect(welcomeOf(page)).toHaveCount(0)
  })

  for (const today of ['start', 'continue'] as const) {
    test(`[onboarding 5] (standing in for a signed in learner, "${today}") no welcome`, async ({ page }) => {
      await answerToday(page, { signedIn: true, today, canDo: 'You can say hello.' })
      await page.goto('/')
      await expect(
        page.getByRole('button', {
          name: today === 'start' ? START_NAME : "Continue today's session",
          exact: true,
        }),
      ).toBeVisible()
      await expect(welcomeOf(page)).toHaveCount(0)
      await expect(page.getByRole('heading', { level: 2 })).toHaveCount(0)
    })
  }

  test('[onboarding 6] (a guest, answer delayed 2 seconds) the welcome is never in the page while the answer is awaited, nor after it', async ({
    page,
  }) => {
    // Records every moment a welcome heading is in the page, even for a frame.
    await page.addInitScript(`
      window.__welcomeSeen = false
      new MutationObserver(() => {
        if ([...document.querySelectorAll('h2')].some((h) => h.textContent === ${JSON.stringify(REGION_NAME)})) {
          window.__welcomeSeen = true
        }
      }).observe(document, { childList: true, subtree: true, characterData: true })
    `)
    await answerToday(page, { signedIn: true, today: 'start', canDo: 'You can say hello.' }, 2_000)
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText("Loading today's session.")
    await expect(welcomeOf(page)).toHaveCount(0)
    await page.waitForTimeout(1_000)
    await expect(welcomeOf(page)).toHaveCount(0)
    await expect(startOf(page)).toBeVisible({ timeout: 5_000 })
    await expect(welcomeOf(page)).toHaveCount(0)
    expect(await page.evaluate<boolean>('window.__welcomeSeen')).toBe(false)
  })

  test("[onboarding 6] when /api/today fails the welcome shows, and Start fails in job 8's own words", async ({
    page,
  }) => {
    await page.route('**/api/today', (route) => route.abort('failed'))
    await page.route('**/api/guest', (route) => route.abort('failed'))
    await page.goto('/')
    await expect(welcomeOf(page)).toBeVisible()
    await startOf(page).click()
    const status = page.getByRole('status')
    await expect(status).toHaveText(
      'Could not start your session. Check your internet connection, then try again.',
    )
    await expect(status).toHaveAttribute('data-tone', 'problem')
    // The welcome stays, and Start can be pressed again.
    await expect(welcomeOf(page)).toBeVisible()
    await expect(startOf(page)).toBeEnabled()
  })
})

// Nothing new is stored or sent ---------------------------------------------------------

test.describe('nothing new is stored or sent', () => {
  test('[onboarding 7] before Start the page sends only its files and GET /api/today, to its own address, and stores nothing', async ({
    page,
    context,
  }) => {
    const requests = recordRequests(page)
    await openAsNewVisitor(page)
    await page.waitForLoadState('load')
    // A request the welcome made would start as soon as it appears, so a short wait is enough.
    await page.waitForTimeout(1_000)
    const origin = new URL(page.url()).origin
    expect(requests.length).toBeGreaterThan(0)
    const api: string[] = []
    for (const request of requests) {
      const url = new URL(request.url())
      expect(url.origin, request.url()).toBe(origin)
      expect(['document', 'script', 'stylesheet', 'font', 'fetch', 'other'], request.url()).toContain(
        request.resourceType(),
      )
      if (url.pathname.startsWith('/api/')) api.push(`${request.method()} ${url.pathname}`)
    }
    expect(api).toEqual(['GET /api/today'])
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    expect(await context.cookies()).toEqual([])
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<number>('sessionStorage.length')).toBe(0)
    // No database in IndexedDB either, where the browser says (older ones do not list them).
    const databases = await page.evaluate<number>(
      `(async () => (typeof indexedDB.databases === 'function' ? (await indexedDB.databases()).length : 0))()`,
    )
    expect(databases).toBe(0)
    expect(await page.evaluate<number>(`(async () => (await caches.keys()).length)()`)).toBe(0)
  })

  test('[onboarding 7] [onboarding 2] the welcome shows at the same address as before, and a reload changes nothing stored', async ({
    page,
    context,
  }) => {
    await openAsNewVisitor(page)
    await page.reload()
    await expect(welcomeOf(page)).toBeVisible()
    expect(await context.cookies()).toEqual([])
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<number>('sessionStorage.length')).toBe(0)
  })
})

// Speed ---------------------------------------------------------------------------------

test.describe('fit on the first screen', () => {
  for (const scheme of SCHEMES) {
    test(`[onboarding 9] at 375 x 812 the whole Start button and the whole guest line are on the first screen, ${scheme}`, async ({
      page,
    }) => {
      await page.setViewportSize({ width: 375, height: 812 })
      await openAsNewVisitor(page, scheme)
      const height = await page.evaluate<number>('window.innerHeight')
      expect(height).toBe(812)
      const start = await startOf(page).boundingBox()
      const line = await guestLineOf(page).boundingBox()
      expect(start, 'Start').not.toBeNull()
      expect(line, 'guest line').not.toBeNull()
      expect(start?.y ?? -1).toBeGreaterThanOrEqual(0)
      expect((start?.y ?? 0) + (start?.height ?? 0), 'bottom of Start').toBeLessThanOrEqual(height)
      expect(line?.y ?? -1).toBeGreaterThanOrEqual(0)
      expect((line?.y ?? 0) + (line?.height ?? 0), 'bottom of the guest line').toBeLessThanOrEqual(height)
      // Nothing is scrolled away: the page is at its top.
      expect(await page.evaluate<number>('window.scrollY')).toBe(0)
      console.log(
        `Fit | ${scheme} | Start bottom ${String(Math.round((start?.y ?? 0) + (start?.height ?? 0)))} px | guest line bottom ${String(Math.round((line?.y ?? 0) + (line?.height ?? 0)))} px of ${String(height)} px`,
      )
    })
  }

  test('[onboarding 9] on a smaller phone the page may scroll, and Start stays reachable by keyboard before the links', async ({
    page,
  }, testInfo) => {
    await page.setViewportSize({ width: 320, height: 568 })
    await openAsNewVisitor(page)
    await tabTo(page, startOf(page), testInfo)
    await expect(startOf(page)).toBeFocused()
    const start = await startOf(page).boundingBox()
    const link = await page.getByRole('link', { name: 'Privacy notice' }).boundingBox()
    expect(start?.y ?? 0).toBeLessThan(link?.y ?? 0)
  })
})

// Phone, keyboard and look --------------------------------------------------------------

test.describe('phone, keyboard and look', () => {
  test('[onboarding 10] nothing scrolls sideways at 320 px or with text at 200 percent, and Start stays at least 44 px tall', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    await page.setViewportSize({ width: 320, height: 640 })
    expect(await scrollsSideways(page)).toBe(false)
    await page.setViewportSize({ width: 375, height: 812 })
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    expect(await scrollsSideways(page)).toBe(false)
    const start = await startOf(page).boundingBox()
    expect(start?.height ?? 0).toBeGreaterThanOrEqual(44)
    // A very long word in the block (40 letters) wraps instead of pushing the page sideways.
    await page.setViewportSize({ width: 320, height: 640 })
    await page.evaluate(`(() => {
      const p = document.querySelector('section[aria-labelledby] p')
      p.textContent = 'a'.repeat(40) + 'b'.repeat(40)
    })()`)
    expect(await scrollsSideways(page)).toBe(false)
  })

  test('[onboarding 10] the page has one h1, then the welcome h2, and the first Tab stop is Start', async ({
    page,
  }, testInfo) => {
    await openAsNewVisitor(page)
    const headings = await page.evaluate<string[]>(
      `[...document.querySelectorAll('h1, h2, h3, h4, h5, h6, [role="heading"]')].map((el) => el.tagName.toLowerCase() + ' ' + el.textContent.trim())`,
    )
    expect(headings).toEqual(["h1 Today's session", `h2 ${REGION_NAME}`])
    // The first thing in the tab order, by structure, in both browsers.
    const firstControl = await page.evaluate<string>(`(() => {
      const first = document.querySelector('main button, main a[href], main input, main select, main textarea, main [tabindex]')
      return first ? first.textContent.trim() : ''
    })()`)
    expect(firstControl).toBe(START_NAME)
    if (testInfo.project.name === 'webkit') {
      // WebKit skips buttons on Tab unless a system setting allows it (tabTo handles that).
      await tabTo(page, startOf(page), testInfo)
    } else {
      await page.keyboard.press('Tab')
    }
    await expect(startOf(page)).toBeFocused()
  })

  for (const scheme of SCHEMES) {
    test(`[onboarding 10] axe finds no WCAG 2.0 to 2.2 A or AA problem on the new visitor's front door, ${scheme}`, async ({
      page,
    }) => {
      await openAsNewVisitor(page, scheme)
      await axe(page, `front door, ${scheme}`)
    })

    test(`[onboarding 10] every piece of text in the welcome keeps at least 4.5 to 1 against what is behind it, ${scheme}`, async ({
      page,
    }) => {
      // axe cannot judge text that sits straight on the page's fade (it reports
      // those as "needs review"), so the real colours are measured here: the
      // text colour against the nearest solid colour behind it, or against the
      // page's three ground colours (the worst of them counts).
      await openAsNewVisitor(page, scheme)
      await settleAnimations(page)
      const ground = ['--color-ground-top', '--color-ground-middle', '--color-ground-bottom'].map((name) =>
        hexOf(scheme, name),
      )
      const items = await onElement<{ text: string; color: string; behind: string | null }[]>(
        welcomeOf(page),
        `(region) => [...region.querySelectorAll('h2, p')].map((node) => {
          let behind = null
          for (let n = node; n && n !== region.parentElement; n = n.parentElement) {
            const background = getComputedStyle(n).backgroundColor
            if (background !== 'rgba(0, 0, 0, 0)') { behind = background; break }
          }
          return { text: node.textContent, color: getComputedStyle(node).color, behind }
        })`,
      )
      expect(items.length).toBe(WELCOME_LINES.length)
      for (const { text, color, behind } of items) {
        const behindColours = behind === null ? ground : [hexFromRgb(behind)]
        for (const back of behindColours) {
          expect(contrast(hexFromRgb(color), back), `${text} ${color} on ${back}`).toBeGreaterThanOrEqual(4.5)
        }
      }
    })

    test(`[onboarding 10] every button on the page has explicit token colours, ${scheme}`, async ({
      page,
    }) => {
      await openAsNewVisitor(page, scheme)
      await settleAnimations(page)
      const allowed = new Set(
        TOKENS[scheme].filter((t) => /^#[0-9a-f]{6}$/.test(t.value)).map((t) => rgb(t.value)),
      )
      const buttons = await page.evaluate<{ name: string; color: string; background: string }[]>(
        `[...document.querySelectorAll('button')].map((el) => {
          const s = getComputedStyle(el)
          return { name: el.textContent.trim(), color: s.color, background: s.backgroundColor }
        })`,
      )
      expect(buttons.length).toBeGreaterThanOrEqual(2)
      for (const { name, color, background } of buttons) {
        expect(allowed.has(color), `${name} text ${color}`).toBe(true)
        expect(
          allowed.has(background) || background === 'rgba(0, 0, 0, 0)',
          `${name} background ${background}`,
        ).toBe(true)
      }
    })
  }

  test('[onboarding 10] the welcome has no animation or transition, and with reduced motion the page is unchanged', async ({
    page,
  }) => {
    await openAsNewVisitor(page)
    const region = welcomeOf(page)
    const motion = await onElement<string[]>(
      region,
      `(el) => [el, ...el.querySelectorAll('*')].flatMap((node) => {
      const s = getComputedStyle(node)
      const found = []
      if (s.animationName !== 'none') found.push(node.tagName + ' animation ' + s.animationName)
      if (s.transitionProperty !== 'all' || s.transitionDuration !== '0s') {
        found.push(node.tagName + ' transition ' + s.transitionProperty + ' ' + s.transitionDuration)
      }
      return found
    })`,
    )
    expect(motion).toEqual([])
    expect(await onElement<number>(region, '(el) => el.getAnimations({ subtree: true }).length')).toBe(0)
    const snapshot = `(() => [...document.querySelectorAll('main, main *')].map((el) => {
      const box = el.getBoundingClientRect()
      const s = getComputedStyle(el)
      return [el.tagName, Math.round(box.x), Math.round(box.y), Math.round(box.width), Math.round(box.height), s.color, s.backgroundColor, s.opacity].join(' ')
    }).join('\\n'))()`
    await settleAnimations(page)
    const before = await page.evaluate<string>(snapshot)
    await page.emulateMedia({ reducedMotion: 'reduce' })
    await settleAnimations(page)
    const after = await page.evaluate<string>(snapshot)
    expect(after).toBe(before)
    expect(before.length).toBeGreaterThan(100)
  })
})

// The reference page (statement 13) -----------------------------------------------------

test.describe('the reference page', () => {
  for (const scheme of SCHEMES) {
    test(`[onboarding 13] /design-reference shows the welcome block with the same words and colours, ${scheme}`, async ({
      page,
    }) => {
      await page.emulateMedia({ colorScheme: scheme })
      await page.goto('/design-reference')
      await expect(page.getByRole('heading', { level: 1, name: 'Design reference' })).toBeVisible()
      const section = page.getByRole('region', { name: 'Welcome block', exact: true })
      await expect(section).toBeVisible()
      const block = section.getByRole('region', { name: REGION_NAME, exact: true })
      await expect(block).toBeVisible()
      const shown = (await block.innerText())
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
      expect(shown).toEqual(WELCOME_LINES)
      expect(await style(block.getByText(WELCOME_SPOKEN_LABEL, { exact: true }), 'color')).toBe(
        token(scheme, '--color-spoken-text'),
      )
      expect(await style(block.getByText(WELCOME_WRITTEN_LABEL, { exact: true }), 'color')).toBe(
        token(scheme, '--color-written'),
      )
    })
  }
})

// With an account: the real answers of the Worker -----------------------------------------

test.describe('a returning learner and the fixture', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }) => {
    await serveTone(page)
  })

  test('[onboarding 5] a guest who pressed Start and came back by Leave session sees no welcome', async ({
    page,
  }) => {
    await startGuest(page)
    await page.getByRole('link', { name: 'Leave session' }).click()
    await page.waitForURL((url) => url.pathname === '/')
    await expect(page.getByRole('button', { name: "Continue today's session" })).toBeVisible()
    await expect(welcomeOf(page)).toHaveCount(0)
    await expect(page.getByRole('heading', { level: 2 })).toHaveCount(0)
    // And on a fresh load of the front door.
    await page.goto('/')
    await expect(page.getByRole('button', { name: "Continue today's session" })).toBeVisible()
    await expect(welcomeOf(page)).toHaveCount(0)
  })

  test('[onboarding 5] a guest whose account was deleted in the database sees the "ended" message and no welcome', async ({
    page,
  }) => {
    const userId = await startGuest(page)
    one(`delete from auth.users where id = :'uid' returning 1`, { uid: userId })
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText(ENDED)
    await expect(startOf(page)).toBeVisible()
    await expect(welcomeOf(page)).toHaveCount(0)
  })

  test('[onboarding 6] a guest whose answer is delayed 2 seconds never sees the welcome', async ({
    page,
  }) => {
    await startGuest(page)
    await page.addInitScript(`
      window.__welcomeSeen = false
      new MutationObserver(() => {
        if ([...document.querySelectorAll('h2')].some((h) => h.textContent === ${JSON.stringify(REGION_NAME)})) {
          window.__welcomeSeen = true
        }
      }).observe(document, { childList: true, subtree: true, characterData: true })
    `)
    await page.route('**/api/today', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 2_000))
      await route.continue()
    })
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText("Loading today's session.")
    await expect(welcomeOf(page)).toHaveCount(0)
    await expect(page.getByRole('button', { name: "Continue today's session" })).toBeVisible({
      timeout: 6_000,
    })
    await expect(welcomeOf(page)).toHaveCount(0)
    expect(await page.evaluate<boolean>('window.__welcomeSeen')).toBe(false)
  })

  test.describe('with an email account', { tag: '@email' }, () => {
    test("[onboarding 5] an email account (the fixture's, as in job 11) sees no welcome, and after signing out sees the message and no welcome", async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-onboarding', testInfo)
      await startGuest(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      await page.goto('/')
      await expect(page.getByRole('button', { name: "Continue today's session" })).toBeVisible()
      await expect(welcomeOf(page)).toHaveCount(0)
      await page.goto('/account')
      await page.getByRole('button', { name: 'Sign out' }).click()
      await page.waitForURL((url) => url.pathname === '/')
      await expect(page.getByRole('status')).toHaveText(SIGNED_OUT)
      await expect(welcomeOf(page)).toHaveCount(0)
    })
  })

  test('[onboarding 7] [onboarding 8] a new visitor presses Start once and nothing else, the first line is on screen with its play controls within 10 seconds, and nothing is stored before or at /session', async ({
    page,
    context,
  }) => {
    const requests = recordRequests(page)
    await openAsNewVisitor(page)
    expect(requests.filter(isGuestPost)).toHaveLength(0)
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<number>('sessionStorage.length')).toBe(0)

    const pressed = Date.now()
    await startOf(page).click()
    await page.waitForURL('**/session')
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()

    // The first approved line of the dialogue the database picked, read from the database.
    const userId = await userIdOf(context)
    const dialogueId = sessionsOf(userId)[0]?.dialogueId ?? ''
    const first = linesOf(dialogueId)[0]
    if (!first) throw new Error('The dialogue has no approved line.')
    const spoken = page.locator('[lang="fi"]').first()
    await expect(spoken).toHaveText(first.puhe.replace(/\s+/g, ' '))
    await expect(page.getByRole('button', { name: 'Play the spoken line' }).first()).toBeVisible()
    await expect(page.getByRole('button', { name: 'Play the written line' }).first()).toBeVisible()
    const seconds = (Date.now() - pressed) / 1000
    console.log(`Speed | onboarding 8 | Start to first line | ${seconds.toFixed(2)} s`)
    expect(seconds).toBeLessThan(10)
    // One tap: exactly one guest was made and nothing else had to be pressed.
    expect(requests.filter(isGuestPost)).toHaveLength(1)

    // After Start, at /session: still nothing in the device's storage but the sign in cookies.
    expect(await page.evaluate<number>('localStorage.length')).toBe(0)
    expect(await page.evaluate<number>('sessionStorage.length')).toBe(0)
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    const origin = new URL(page.url()).origin
    for (const request of requests) {
      expect(new URL(request.url()).origin, request.url()).toBe(origin)
    }
    const names = (await context.cookies()).map((c) => c.name)
    expect(names.length).toBeGreaterThan(0)
    for (const name of names) expect(name, name).toMatch(/^puhuscribe-auth/)
  })

  test('[onboarding 8] loading the front door still creates no account', async ({ page }) => {
    const requests = recordRequests(page)
    await openAsNewVisitor(page)
    await page.waitForLoadState('networkidle')
    await page.reload()
    await expect(welcomeOf(page)).toBeVisible()
    expect(requests.filter(isGuestPost)).toHaveLength(0)
  })
})
