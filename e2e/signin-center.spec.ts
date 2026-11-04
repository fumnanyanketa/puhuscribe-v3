import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page } from '@playwright/test'
import { mockHome } from './road-mocks.ts'

// Sign in and code screens centred (fast route signin-center, owner, 4 November 2026). Labels name the
// item of the owner's brief, listed in factory/jobs/signin-center/build.md:
//   1. "Welcome back": the title, the subtitle and the line under the field are centred; the field stays full width.
//   2. "Enter the code" on sign in: title and subtitle centred, the subtitle is "You will receive a 6 digit code."
//      for every address, and the no code line stays.
//   3. "Enter the code" on the add email path: "Sent to <email>" kept and centred the same way.
//   4. At 320 px wide and with text at 200 percent, nothing runs sideways and a long address wraps.
// The pages answer from mocks, so no database is needed. With PUHUSCRIBE_EVIDENCE=1 the screenshots go to
// factory/jobs/signin-center/evidence/ (Chromium only).

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']
const OUT = resolve('factory/jobs/signin-center/evidence')
const evidence = process.env.PUHUSCRIBE_EVIDENCE === '1'
const SENT = 'You will receive a 6 digit code.'
const OLD_SENT = 'If this email has an Aleksi account, we sent it a 6 digit code.'
const NO_CODE = 'No code after a few minutes? Check the address, or go back and start as a guest.'
const SENDS_CODE = 'We send a 6 digit code to this address. We use your email only to send you sign in codes.'
const LONG = 'aleksandra.virtanen-korhonen.longaddress@example-helsinki-university.fi'

async function shot(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage: true })
}

/**
 * Large text runs past the screen, and a full page picture draws the sticky Send code bar over the middle.
 * So these are two screen sized pictures, one at the top and one scrolled to the bottom, as a learner sees them.
 */
async function scrolledShots(page: Page, name: string) {
  if (!evidence || test.info().project.name !== 'chromium') return
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
  await page.evaluate('window.scrollTo(0, 0)')
  await page.screenshot({ path: `${OUT}/${name}-top.png` })
  await page.evaluate('window.scrollTo(0, document.documentElement.scrollHeight)')
  await page.waitForTimeout(300)
  await page.screenshot({ path: `${OUT}/${name}-bottom.png` })
}

/** One computed style of the element. The e2e files have no DOM types, so the page's function is reached through a cast. */
const styleOf = (locator: Locator, property: string): Promise<string> =>
  locator.evaluate(
    (el, name) =>
      (
        globalThis as unknown as { getComputedStyle: (e: unknown) => Record<string, string | undefined> }
      ).getComputedStyle(el)[name] ?? '',
    property,
  )

const scrollsSideways = (page: Page) =>
  page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')

/** Opens a page with no database: /api/me answers `me`, and both "Send code" routes answer as the Worker does. */
async function open(page: Page, path: string, me: Record<string, unknown>) {
  const sent: unknown[] = []
  await mockHome(page, { me })
  for (const api of ['**/api/sign-in', '**/api/account/email'])
    await page.route(api, (route) => {
      sent.push(route.request().postDataJSON())
      return route.fulfill({ status: 200, contentType: 'application/json', body: '{"sent":true}' })
    })
  await page.goto(path)
  return sent
}

async function sendCode(page: Page, address: string) {
  await page.getByLabel('Email address').fill(address)
  await page.getByRole('button', { name: 'Send code' }).click()
  await expect(page.getByRole('heading', { level: 1, name: 'Enter the code' })).toBeVisible()
}

async function expectCentred(locator: Locator) {
  await expect(locator).toBeVisible()
  expect(await styleOf(locator, 'textAlign')).toBe('center')
}

test('[signin-center 1] Welcome back: the title, the subtitle and the line under the field are centred, and the field is full width', async ({
  page,
}) => {
  await open(page, '/learn/sign-in', { kind: 'none' })
  const title = page.getByRole('heading', { level: 1, name: 'Welcome back' })
  await expectCentred(title)
  await expectCentred(page.getByText('Enter your email for a code.', { exact: true }))
  await expectCentred(page.getByText(SENDS_CODE, { exact: true }))
  // The field spans the same width as the content column (the title's box).
  const field = await page.getByLabel('Email address').boundingBox()
  const column = await title.boundingBox()
  expect(Math.abs((field?.width ?? 0) - (column?.width ?? 0))).toBeLessThanOrEqual(1)
  expect(field?.width ?? 0).toBeGreaterThan(300)
  const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
  expect(axe.violations).toEqual([])
  await shot(page, 'after-sign-in-email-375x812')
})

test('[signin-center 2] Enter the code on sign in: the same centred sentence for every address, and the no code line stays', async ({
  page,
}) => {
  const sent = await open(page, '/learn/sign-in', { kind: 'none' })
  await sendCode(page, 'alex@example.com')
  await expectCentred(page.getByRole('heading', { level: 1, name: 'Enter the code' }))
  await expectCentred(page.getByText(SENT, { exact: true }))
  await expect(page.getByText(NO_CODE, { exact: true })).toBeVisible()
  // Neither the old sentence nor the address is on the screen, so nothing hints whether the address has an account.
  await expect(page.getByText(OLD_SENT)).toHaveCount(0)
  await expect(page.getByText('alex@example.com')).toHaveCount(0)
  const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze()
  expect(axe.violations).toEqual([])
  await shot(page, 'after-sign-in-code-375x812')
  // The countdown on "Send a new code" moves with the clock, so it is left out of the comparison.
  const screenText = async () => (await page.getByRole('main').innerText()).replace(/in \d+:\d\d/, '')
  const first = await screenText()
  // A second address: the screen reads word for word the same.
  await page.getByRole('button', { name: 'Use another email address' }).click()
  await sendCode(page, 'someone.else@example.org')
  expect(await screenText()).toBe(first)
  expect(sent).toEqual([{ email: 'alex@example.com' }, { email: 'someone.else@example.org' }])
})

test('[signin-center 3] Enter the code on the add email path keeps "Sent to" the address, centred the same way', async ({
  page,
}) => {
  await open(page, '/learn/account/email', { kind: 'guest' })
  await sendCode(page, 'alex@example.com')
  await expectCentred(page.getByRole('heading', { level: 1, name: 'Enter the code' }))
  await expectCentred(page.getByText('Sent to alex@example.com', { exact: true }))
  await expect(page.getByText(SENT, { exact: true })).toHaveCount(0)
  await shot(page, 'after-add-code-375x812')
})

test.describe('narrow and large text', () => {
  test.use({ viewport: { width: 320, height: 640 } })

  test('[signin-center 4] at 320 px wide with text at 200 percent, the sign in screens stay on the page', async ({
    page,
  }) => {
    await open(page, '/learn/sign-in', { kind: 'none' })
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    expect(await scrollsSideways(page)).toBe(false)
    await scrolledShots(page, 'after-sign-in-email-320-text-200')
    await sendCode(page, LONG)
    expect(await scrollsSideways(page)).toBe(false)
    await expect(page.getByText(SENT, { exact: true })).toBeVisible()
    await scrolledShots(page, 'after-sign-in-code-320-text-200')
  })

  test('[signin-center 4] a long address wraps on the add email code screen, at 320 px and with text at 200 percent', async ({
    page,
  }) => {
    await open(page, '/learn/account/email', { kind: 'guest' })
    await sendCode(page, LONG)
    const line = page.getByText(`Sent to ${LONG}`, { exact: true })
    await expectCentred(line)
    expect(await scrollsSideways(page)).toBe(false)
    const box = await line.boundingBox()
    expect((box?.x ?? 0) + (box?.width ?? 0)).toBeLessThanOrEqual(320)
    await shot(page, 'after-add-code-long-email-320')
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
    expect(await scrollsSideways(page)).toBe(false)
    await scrolledShots(page, 'after-add-code-long-email-320-text-200')
  })
})
