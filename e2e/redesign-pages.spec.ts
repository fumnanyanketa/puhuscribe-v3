import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page, type Route } from '@playwright/test'
import { mockHome } from './road-mocks.ts'
import { recordRequests } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. These answer the pages' reads and writes
// themselves, so they need no database.

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

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

type Me = { kind: 'guest' } | { kind: 'email'; email: string } | { kind: 'none' }

interface PageMocks {
  me?: Me
  processing?: 'granted' | 'not_asked' | 'withdrawn'
  retention?: boolean
  region?: string | null
  /** Kept recordings in GET /api/voice (round 6: "My recordings" and the delete button show only with some). */
  recordings?: { id: string; line: string | null; slot: 'first' | 'latest'; createdAt: string }[]
}

async function mockAccount(page: Page, mocks: PageMocks = {}) {
  const calls = {
    consent: [] as unknown[],
    deleted: 0,
    feedback: [] as unknown[],
    exported: 0,
    sent: [] as unknown[],
  }
  await mockHome(page, { done: { 1: 4, 2: 4, 3: 2 }, me: mocks.me ?? { kind: 'guest' } })
  await page.route('**/api/voice', (route) =>
    json(route, {
      available: true,
      region: mocks.region ?? null,
      processing: mocks.processing ?? 'granted',
      retention: mocks.retention ?? false,
      recordings: mocks.recordings ?? [],
    }),
  )
  await page.route('**/api/voice/consent', (route) => {
    const body = route.request().postDataJSON() as { choice: string }
    calls.consent.push(body)
    const on =
      body.choice === 'turn_on' || (body.choice.startsWith('keep') && mocks.processing !== 'not_asked')
    return json(route, {
      available: true,
      region: null,
      processing: body.choice === 'turn_off' ? 'withdrawn' : on ? 'granted' : 'not_asked',
      retention: body.choice === 'keep_on',
      recordings: [],
    })
  })
  await page.route('**/api/account/delete', (route) => {
    calls.deleted += 1
    return json(route, { deleted: true })
  })
  await page.route('**/api/account/export', (route) => {
    calls.exported += 1
    return route.fulfill({
      status: 200,
      contentType: 'application/json',
      headers: { 'content-disposition': 'attachment; filename="puhuscribe-data.json"' },
      body: '{"about":"test"}',
    })
  })
  await page.route('**/api/account/email', (route) => {
    calls.sent.push(route.request().postDataJSON())
    return json(route, { sent: true })
  })
  await page.route('**/api/sign-in', (route) => {
    calls.sent.push(route.request().postDataJSON())
    return json(route, { sent: true })
  })
  await page.route('**/api/feedback', (route) => {
    calls.feedback.push(route.request().postDataJSON())
    return json(route, { sent: true }, 201)
  })
  return calls
}

test.describe('the account page', () => {
  test('[redesign 34] a guest sees the avatar, the journey, the add note and four settings rows, and no Sign out', async ({
    page,
  }) => {
    await mockAccount(page)
    await page.goto('/account')
    await expect(page.getByRole('heading', { level: 1, name: 'Your account' })).toBeAttached()
    await expect(page.getByText('Guest', { exact: true })).toBeVisible()
    await expect(page.getByText('Saved on this device')).toBeVisible()
    await expect(page.getByText('Stop 3 of 36')).toBeVisible()
    await expect(page.getByText('Now: At the grocery store')).toBeVisible()
    await expect(page.getByText('A1', { exact: true })).toBeVisible()
    // Round 6 (owner, item 29): the owner's words of 1 November and a plain "Create", named in full.
    await expect(page.getByText('Create an account to save your progress.')).toBeVisible()
    const create = page.getByRole('button', { name: 'Create an account' })
    await expect(create).toHaveText('Create')
    for (const row of ['Speaking feedback', 'Download my data', 'Privacy notice', 'Send feedback']) {
      await expect(page.getByRole('list').getByText(row)).toBeVisible()
    }
    await expect(page.getByText('On', { exact: true })).toBeVisible()
    // "Speaking feedback" shows its value and no chevron, as drawn; the other rows keep theirs.
    await expect(page.getByRole('link', { name: /Speaking feedback/ }).locator('svg')).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Privacy notice' }).locator('svg')).toHaveCount(1)
    await expect(page.getByRole('button', { name: 'Sign out' })).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
    await create.click()
    await page.waitForURL('**/account/email')
  })

  test('[redesign 34] an email account sees its address, "Saved to your email", Sign out and Delete, and no add note', async ({
    page,
  }) => {
    await mockAccount(page, { me: { kind: 'email', email: 'alex@example.com' } })
    await page.goto('/account')
    await expect(page.getByText('alex@example.com')).toBeVisible()
    await expect(page.getByText('Saved to your email')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign out' })).toBeVisible()
    await expect(page.getByText('Create an account to save your progress.')).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
    // Round 6 (item 29): "Sign out · Delete my account", with the dot between them and Sign out not underlined.
    const signOut = page.getByRole('button', { name: 'Sign out' })
    expect(await styleOf(signOut, 'textDecorationLine')).toBe('none')
  })

  test('[redesign 34] with no account it says so and offers "Sign in with your email"', async ({ page }) => {
    await mockAccount(page, { me: { kind: 'none' } })
    await page.goto('/account')
    await expect(page.getByText('There is no account on this device.')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign in with your email' })).toBeVisible()
    await expect(page.getByText('Your journey')).toHaveCount(0)
  })

  test('[redesign 37] "Download my data" gives the file, then shows "Your file is ready" in place with a Download button', async ({
    page,
  }) => {
    const calls = await mockAccount(page)
    await page.goto('/account')
    const downloading = page.waitForEvent('download')
    await page.getByRole('button', { name: 'Download my data' }).click()
    expect((await downloading).suggestedFilename()).toBe('puhuscribe-data.json')
    // Round 6 (item 34): the page's title "Download my data" sits beside the back arrow, and "Your file is
    // ready" with no full stop is the title under the orb, as drawn. The only way back is the arrow.
    await expect(page.getByRole('heading', { level: 1, name: 'Download my data' })).toBeVisible()
    await expect(page.getByRole('heading', { level: 2, name: 'Your file is ready' })).toHaveText(
      'Your file is ready',
    )
    // The status line still says it for screen readers, and is not drawn a second time.
    await expect(page.getByRole('status')).toHaveText('Your file is ready.')
    expect(
      await page
        .getByRole('status')
        .boundingBox()
        .then((box) => box?.width ?? 0),
    ).toBeLessThan(3)
    await expect(page.getByText('Everything we keep about you, in one file.')).toBeVisible()
    await expect(page.getByRole('link', { name: 'Back to your account' })).toHaveCount(1)
    await expect(page.getByRole('button', { name: 'Back to your account' })).toHaveCount(0)
    const title = await page.getByRole('heading', { level: 2 }).boundingBox()
    expect(Math.abs((title?.x ?? 0) + (title?.width ?? 0) / 2 - 187.5)).toBeLessThan(3)
    await expect(page.getByRole('button', { name: 'Download', exact: true })).toBeVisible()
    expect(new URL(page.url()).pathname).toBe('/account')
    const again = page.waitForEvent('download')
    await page.getByRole('button', { name: 'Download', exact: true }).click()
    await again
    expect(calls.exported).toBe(2)
  })
})

test.describe('the email screens', () => {
  test('[redesign 35] Create your account: one field, one button, and the protected sentences in full', async ({
    page,
  }) => {
    const calls = await mockAccount(page)
    await page.goto('/account/email')
    await expect(page.getByRole('heading', { level: 1, name: 'Create your account' })).toBeVisible()
    await expect(
      page.getByText(
        'We send a 6 digit code to this address. We use your email only to send you sign in codes.',
        { exact: true },
      ),
    ).toBeVisible()
    await expect(
      page.getByText(
        'If this email already has a PuhuScribe account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts.',
        { exact: true },
      ),
    ).toBeVisible()
    await page.getByLabel('Email address').fill('alex@example.com')
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Enter the code' })).toBeVisible()
    expect(calls.sent).toEqual([{ email: 'alex@example.com' }])
  })

  test('[redesign 35] the code is one field for a screen reader, with a box for each digit, and a pasted code fills them', async ({
    page,
  }) => {
    await mockAccount(page)
    await page.goto('/account/email')
    await page.getByLabel('Email address').fill('alex@example.com')
    await page.getByRole('button', { name: 'Send code' }).click()
    const field = page.getByLabel('6 digit code')
    await expect(field).toHaveAttribute('autocomplete', 'one-time-code')
    await expect(page.getByLabel('6 digit code')).toHaveCount(1)
    await field.fill('471923')
    const boxes = await page.evaluate<string[]>(
      `[...document.querySelectorAll('[class*="boxes"] > span')].map((el) => el.textContent)`,
    )
    expect(boxes).toEqual(['4', '7', '1', '9', '2', '3'])
    await expect(page.getByRole('button', { name: 'Send a new code' })).toBeVisible()
    await expect(page.getByText('The code works for one hour.')).toBeVisible()
  })

  test('[redesign 35] Sign in: the guest warning in full when this device has a guest, and "Start as a guest instead"', async ({
    page,
  }) => {
    await mockAccount(page, { me: { kind: 'guest' } })
    await page.goto('/sign-in')
    await expect(
      page.getByText(
        'This device has a guest account. Signing in deletes its progress, because progress cannot be moved between accounts. To keep it, add your email to the guest account instead.',
        { exact: true },
      ),
    ).toBeVisible()
    await page.getByRole('button', { name: 'Sign in anyway' }).click()
    await expect(page.getByRole('link', { name: 'Start as a guest instead' })).toHaveAttribute('href', '/')
    const none = await page.context().newPage()
    await mockAccount(none, { me: { kind: 'none' } })
    await none.goto('/sign-in')
    // Round 6 (item 32): the drawing's title and subtitle.
    await expect(none.getByRole('heading', { level: 1, name: 'Welcome back' })).toBeVisible()
    await expect(none.getByText('Enter your email for a code.', { exact: true })).toBeVisible()
    await expect(none.getByRole('link', { name: 'Start as a guest instead' })).toBeVisible()
    // "Start as a guest instead" sits small under Send code, at the bottom of the screen.
    const send = await none.getByRole('button', { name: 'Send code' }).boundingBox()
    const guest = await none.getByRole('link', { name: 'Start as a guest instead' }).boundingBox()
    expect((guest?.y ?? 0) > (send?.y ?? 0)).toBe(true)
    expect(await styleOf(none.getByRole('link', { name: 'Start as a guest instead' }), 'fontSize')).toBe(
      '12.5px',
    )
  })

  // Round 6 (owner, items 3 and 30): the drawn field. Its words are the placeholder, its label is for screen
  // readers, the protected sentences sit small (12 px) and quiet under it, and Send code is at the bottom.
  test('[redesign 35] [redesign 43] Create your account: the drawn field with "Your email", the protected sentences small under it, Send code at the bottom', async ({
    page,
  }) => {
    await mockAccount(page)
    await page.goto('/account/email')
    const field = page.getByLabel('Email address')
    await expect(field).toHaveAttribute('placeholder', 'Your email')
    const label = await page.locator('label[for="email"]').boundingBox()
    expect(label?.width ?? 0).toBeLessThan(3)
    for (const sentence of [
      'We send a 6 digit code to this address. We use your email only to send you sign in codes.',
      'If this email already has a PuhuScribe account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts.',
    ]) {
      const text = page.getByText(sentence, { exact: true })
      await expect(text).toBeVisible()
      expect(await styleOf(text, 'fontSize')).toBe('12px')
      expect(((await text.boundingBox())?.y ?? 0) > ((await field.boundingBox())?.y ?? 0)).toBe(true)
    }
    const send = await page.getByRole('button', { name: 'Send code' }).boundingBox()
    expect((send?.y ?? 0) + (send?.height ?? 0)).toBeGreaterThan(812 - 120)
    await expect(page.getByRole('link', { name: 'Privacy notice' })).toBeVisible()
  })

  // Round 6 (item 31): "Sent to" the address as the subtitle; the back arrow goes back to the email (the old
  // "Use another email address" pill is gone); "Send a new code" is the small link under the boxes and reads
  // the wait while it waits; Confirm is the pale pill until six digits are in.
  test('[redesign 35] Enter the code: "Sent to", the waiting link counts down, Confirm waits for six digits, and the arrow goes back to the email', async ({
    page,
  }) => {
    await page.clock.install()
    const calls = await mockAccount(page)
    await page.goto('/account/email')
    await page.getByLabel('Email address').fill('alex@example.com')
    await page.getByRole('button', { name: 'Send code' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Enter the code' })).toBeVisible()
    await expect(page.getByText('Sent to alex@example.com', { exact: true })).toBeVisible()
    await expect(page.getByText('The code works for one hour.')).toBeVisible()
    await expect(page.getByText('You can ask for a new code after one minute.')).toHaveCount(0)
    const resend = page.getByRole('button', { name: /^Send a new code/ })
    await expect(resend).toBeDisabled()
    await expect(resend).toHaveText('Send a new code in 1:00')
    await page.clock.runFor(15_000)
    await expect(resend).toHaveText('Send a new code in 0:45')
    const confirm = page.getByRole('button', { name: 'Confirm' })
    await expect(confirm).toBeDisabled()
    await page.getByLabel('6 digit code').fill('4719')
    await expect(confirm).toBeDisabled()
    await page.getByLabel('6 digit code').fill('471923')
    await expect(confirm).toBeEnabled()
    await page.clock.runFor(46_000)
    await expect(resend).toBeEnabled()
    await expect(resend).toHaveText('Send a new code')
    await resend.click()
    await expect.poll(() => calls.sent.length).toBe(2)
    await expect(page.getByRole('button', { name: 'Use another email address' })).toHaveCount(1)
    await page.getByRole('button', { name: 'Use another email address' }).click()
    await expect(page.getByLabel('Email address')).toBeVisible()
    await expect(page.getByRole('heading', { level: 1, name: 'Create your account' })).toBeVisible()
  })
})

test.describe('Voice settings', () => {
  // Round 6 (owner, item 33): two separate milky cards, the drawing's short line under "Keep my recordings",
  // no "shown below" line, and "My recordings" with "Delete my recordings" only when something is kept.
  test('[redesign 36] two drawn cards, the short keep line, and "My recordings" and its delete button only when there are kept recordings', async ({
    page,
  }) => {
    await mockAccount(page, { processing: 'granted', retention: true })
    await page.goto('/voice')
    const speaking = page.getByRole('switch', { name: 'Speaking feedback' })
    await expect(speaking).toBeVisible()
    await expect(page.getByText('So I can hear my progress. 90 days.', { exact: true })).toBeVisible()
    const shownBelow = page.getByText('Your voice settings are shown below.')
    await expect(shownBelow).toBeAttached()
    expect((await shownBelow.boundingBox())?.width ?? 0).toBeLessThan(3)
    await expect(speaking).toHaveAccessibleDescription(/^On\. Your recordings are checked/)
    const cards = await page.evaluate<number>(
      `[...document.querySelectorAll('[role="switch"]')].map((s) => s.closest('[class*="switchCard"]')).filter(Boolean).length`,
    )
    expect(cards).toBe(2)
    await expect(page.getByRole('heading', { name: 'My recordings' })).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Delete my recordings' })).toHaveCount(0)
    const kept = await page.context().newPage()
    await mockAccount(kept, {
      processing: 'granted',
      retention: true,
      recordings: [{ id: 'r1', line: 'Moi.', slot: 'first', createdAt: '2026-11-01T10:00:00Z' }],
    })
    await kept.goto('/voice')
    await expect(kept.getByRole('heading', { name: 'My recordings' })).toBeVisible()
    const remove = kept.getByRole('button', { name: 'Delete my recordings' })
    await expect(remove).toBeVisible()
    expect(((await remove.boundingBox())?.y ?? 0) > 600).toBe(true)
  })

  test('[redesign 36] two real switches, one press changes each, and "Keep my recordings" waits for the first', async ({
    page,
  }) => {
    const calls = await mockAccount(page, { processing: 'granted', retention: false })
    await page.goto('/voice')
    const speaking = page.getByRole('switch', { name: 'Speaking feedback' })
    const keep = page.getByRole('switch', { name: 'Keep my recordings' })
    await expect(speaking).toHaveAttribute('aria-checked', 'true')
    await expect(keep).toHaveAttribute('aria-checked', 'false')
    await keep.click()
    await expect.poll(() => calls.consent).toEqual([{ choice: 'keep_on' }])
    await speaking.click()
    await expect.poll(() => calls.consent).toEqual([{ choice: 'keep_on' }, { choice: 'turn_off' }])
  })

  test('[redesign 36] [redesign 29] the Keep switch says what keeping means before the press, in the sentence the consent version covers', async ({
    page,
  }) => {
    await mockAccount(page, { processing: 'granted', retention: false })
    await page.goto('/voice')
    const keep = page.getByRole('switch', { name: 'Keep my recordings' })
    await expect(keep).toHaveAccessibleDescription(
      /Off\. Keep my recordings so I can hear my progress\. We keep your first and latest try of each line for 90 days\. You can delete them at any time\./,
    )
    await expect(
      page.getByText(
        'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
        { exact: false },
      ),
    ).toBeVisible()
    await keep.click()
    await expect(keep).toHaveAccessibleDescription(
      /On\. Keep my recordings so I can hear my progress\. We keep your first and latest try of each line for 90 days\. You can delete them at any time\./,
    )
  })

  // Round 5 (evaluator, statement 47): Safari does not focus a tapped button, so the switch must be given focus
  // back by the sheet. The tap here is a mousedown that cannot move focus, as on an iPhone.
  test('[redesign 47] a tap on the Speaking feedback switch opens the consent sheet, and Not now, Escape and the dimmed page give focus back to the switch', async ({
    page,
  }) => {
    await mockAccount(page, { processing: 'not_asked' })
    await page.goto('/voice')
    const speaking = page.getByRole('switch', { name: 'Speaking feedback' })
    await expect(speaking).toHaveAttribute('aria-checked', 'false')
    await page.evaluate("document.addEventListener('mousedown', (event) => event.preventDefault(), true)")
    for (const how of ['Not now', 'Escape', 'the dimmed page'] as const) {
      await speaking.click()
      const sheet = page.getByRole('dialog', { name: 'Say it out loud' })
      await expect(sheet).toBeVisible()
      if (how === 'Not now') await sheet.getByRole('button', { name: 'Not now' }).click()
      else if (how === 'Escape') await page.keyboard.press('Escape')
      else await page.mouse.click(187, 8)
      await expect(sheet).toBeHidden()
      await expect(speaking, `after ${how}`).toBeFocused()
    }
  })

  test('[redesign 36] turning speaking feedback on shows the consent sheet; nothing is sent until "Turn on"', async ({
    page,
  }) => {
    const calls = await mockAccount(page, { processing: 'not_asked' })
    await page.goto('/voice')
    const speaking = page.getByRole('switch', { name: 'Speaking feedback' })
    await expect(speaking).toHaveAttribute('aria-checked', 'false')
    await expect(page.getByRole('switch', { name: 'Keep my recordings' })).toBeDisabled()
    await speaking.click()
    const sheet = page.getByRole('dialog', { name: 'Say it out loud' })
    await expect(sheet).toBeVisible()
    expect(calls.consent).toEqual([])
    await sheet.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect.poll(() => calls.consent).toEqual([{ choice: 'turn_on', keepRecordings: false }])
  })
})

test.describe('delete, feedback and the privacy notice', () => {
  test('[redesign 38] the delete page: the title, the warning in full, and nothing deleted before the second press', async ({
    page,
  }) => {
    const calls = await mockAccount(page)
    await page.goto('/account/delete')
    await expect(page.getByRole('heading', { level: 1, name: 'Delete your account?' })).toBeVisible()
    await expect(
      page.getByText(
        'This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy.',
        { exact: true },
      ),
    ).toBeVisible()
    await expect(page.getByRole('button', { name: 'Keep my account' })).toBeVisible()
    await page.waitForTimeout(500)
    expect(calls.deleted).toBe(0)
    await page.getByRole('button', { name: 'Delete for good' }).click()
    await page.waitForURL((url) => url.searchParams.get('notice') === 'deleted')
    expect(calls.deleted).toBe(1)
  })

  test('[redesign 38] "Keep my account" goes back without deleting', async ({ page }) => {
    const calls = await mockAccount(page)
    await page.goto('/account/delete')
    await page.getByRole('button', { name: 'Keep my account' }).click()
    await page.waitForURL('**/account')
    expect(calls.deleted).toBe(0)
  })

  test('[redesign 39] the privacy notice has the readable first layer, the owner’s sentence, and the whole notice behind one control, and it calls no /api route', async ({
    page,
  }) => {
    const requests = recordRequests(page)
    await page.goto('/privacy')
    await expect(page.getByRole('heading', { level: 1, name: 'Privacy notice' })).toBeVisible()
    for (const heading of ['What we keep', 'Your voice', 'How long', 'Your rights', 'Who runs PuhuScribe']) {
      await expect(page.getByRole('heading', { level: 2, name: heading, exact: true })).toBeVisible()
    }
    await expect(
      page.getByText('PuhuScribe is part of the product family of Exentrik, a product studio in Finland.'),
    ).toBeVisible()
    await expect(page.getByText('Exentrik looks after your data')).toHaveCount(0)
    // Round 6 (item 36): "Updated 1 November 2026" small at the bottom, as drawn (no full stop).
    await expect(page.getByText('Updated 1 November 2026', { exact: true })).toBeVisible()
    await expect(
      page.locator('#full-notice').getByRole('heading', { level: 2, name: 'Who is responsible' }),
    ).toBeHidden()
    await page.getByRole('button', { name: 'Read the full notice' }).click()
    await expect(
      page.locator('#full-notice').getByRole('heading', { level: 2, name: 'Who is responsible' }),
    ).toBeVisible()
    await expect(page.getByText('Fumnanya Nketa is responsible for your data in PuhuScribe.')).toBeVisible()
    await expect(
      page
        .locator('#full-notice')
        .getByRole('heading', { level: 2, name: 'Where it is kept and who processes it' }),
    ).toBeVisible()
    // The only /api call is the one read that names the speech service's country (round 2).
    expect(
      requests
        .filter((request) => new URL(request.url()).pathname.startsWith('/api/'))
        .map((request) => `${request.method()} ${new URL(request.url()).pathname}`),
    ).toEqual(['GET /api/voice'])
  })

  test('[redesign 29] [redesign 39] "How it works" opens the privacy page at its voice section, with the Keep sentence and the country', async ({
    page,
  }) => {
    await mockAccount(page, { region: 'Italy' })
    await page.goto('/privacy#privacy-voice')
    const section = page.getByRole('heading', { level: 2, name: 'Your voice' })
    await expect(section).toBeInViewport()
    await expect(page.getByText('Microsoft does not keep your recording', { exact: false })).toBeVisible()
    await expect(
      page.getByText("Microsoft's speech service in the EU, in Italy.", { exact: false }),
    ).toBeVisible()
    await expect(
      page.getByText(
        'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
        { exact: true },
      ),
    ).toBeVisible()
    await expect(page.getByText('You can change both choices at any time in Voice settings.')).toBeVisible()
  })

  // Round 6 (owner, item 36): the drawing's look. The title is in the page, large and quiet; the section
  // headings are mint (round 2 had made them ink); the voice details sit behind "More about your voice".
  test('[redesign 39] the title is in the page, the section headings are mint as drawn, and the voice details sit behind one tap', async ({
    page,
  }) => {
    await page.goto('/privacy')
    await expect(page.getByRole('heading', { level: 2, name: 'Who runs PuhuScribe' })).toBeVisible()
    const look = await page.evaluate<{ colours: string[]; titleInHeader: boolean }>(`({
      colours: [...document.querySelectorAll('[class*="firstLayer"] section h2')].map((h) => getComputedStyle(h).color),
      titleInHeader: Boolean(document.querySelector('header h1')),
    })`)
    expect(look.colours).toHaveLength(5)
    for (const colour of look.colours) expect(colour).toBe('rgb(26, 111, 93)')
    expect(look.titleInHeader).toBe(false)
    const more = page.getByRole('button', { name: 'More about your voice' })
    await expect(more).toHaveAttribute('aria-expanded', 'false')
    await expect(page.getByText('Microsoft does not keep your recording', { exact: false })).toBeHidden()
    await more.click()
    await expect(more).toHaveAttribute('aria-expanded', 'true')
    await expect(page.getByText('Microsoft does not keep your recording', { exact: false })).toBeVisible()
  })

  test('[redesign 39] with no account the voice section says "in the EU" and names no country', async ({
    page,
  }) => {
    await mockHome(page, { me: { kind: 'none' } })
    await page.route('**/api/voice', (route) => json(route, { error: 'not_signed_in' }, 401))
    await page.goto('/privacy#privacy-voice')
    await expect(page.getByText('speech service in the EU. The service', { exact: false })).toBeVisible()
    await expect(page.getByText(/in the EU, in /)).toHaveCount(0)
  })

  test('[redesign 40] Send feedback: the title, "What should we know?", the protected line, and one message per press', async ({
    page,
  }) => {
    const calls = await mockAccount(page)
    await page.goto('/feedback?from=account')
    await expect(page.getByRole('heading', { level: 1, name: 'Send feedback' })).toBeVisible()
    await expect(
      page.getByText(
        'Tell us what worked, what did not, or what broke. Please do not include personal details.',
        { exact: true },
      ),
    ).toBeVisible()
    const box = page.getByLabel('What should we know?')
    // Round 6 (item 37): the drawn box with its placeholder, the protected line small under it, and the
    // count drawn only when 100 or fewer characters are left (it is read with the box all the time).
    await expect(box).toHaveAttribute('placeholder', "What worked, what didn't, what broke.")
    const line = page.getByText(
      'Tell us what worked, what did not, or what broke. Please do not include personal details.',
      { exact: true },
    )
    expect(await styleOf(line, 'fontSize')).toBe('12px')
    expect(((await line.boundingBox())?.y ?? 0) > ((await box.boundingBox())?.y ?? 0)).toBe(true)
    await box.fill('The road is lovely.')
    const count = page.getByText('19 of 1,000 characters')
    await expect(count).toBeAttached()
    expect((await count.boundingBox())?.width ?? 0).toBeLessThan(3)
    await expect(box).toHaveAccessibleDescription(/19 of 1,000 characters/)
    await box.fill('a'.repeat(905))
    const near = page.getByText('905 of 1,000 characters')
    expect((await near.boundingBox())?.width ?? 0).toBeGreaterThan(50)
    await box.fill('The road is lovely.')
    await page.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(page.getByText('Thank you. Your message is sent.')).toBeVisible()
    expect(calls.feedback).toEqual([{ screen: 'account', message: 'The road is lovely.' }])
  })
})

test.describe('errors and offline', () => {
  test('[redesign 41] "No connection" on the road says the progress is safe; Try again reloads', async ({
    page,
  }) => {
    await mockHome(page, { roadFails: 0 })
    await page.goto('/')
    await expect(page.getByRole('heading', { level: 1, name: 'No connection' })).toBeVisible()
    await expect(page.getByText("Your progress is safe. Try again when you're online.")).toBeVisible()
    await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible()
  })

  test('[redesign 41] inside a lesson the failure keeps its words and does not say the progress is safe', async ({
    page,
  }) => {
    await page.route('**/api/sessions/today', (route) => route.abort('failed'))
    await page.goto('/session')
    await expect(page.getByRole('status')).toContainText('Check your internet connection, then try again.')
    await expect(page.getByText('Your progress is safe.')).toHaveCount(0)
  })
})

test.describe('every page at phone size', () => {
  const PAGES: [string, string, PageMocks][] = [
    ['account, guest', 'account', {}],
    ['account, email', 'account', { me: { kind: 'email', email: 'alex@example.com' } }],
    ['create your account', 'account/email', {}],
    ['sign in', 'sign-in', { me: { kind: 'none' } }],
    ['voice settings', 'voice', {}],
    ['delete my account', 'account/delete', {}],
    ['privacy notice', 'privacy', {}],
    ['send feedback', 'feedback?from=account', {}],
  ]
  for (const [name, path, mocks] of PAGES) {
    test(`[redesign 46] [redesign 47] ${name}: one h1, no sideways scroll at 375 and at 320 with 200 percent text, controls at least 44 px, and axe finds nothing`, async ({
      page,
    }) => {
      await mockAccount(page, mocks)
      await page.goto(`/${path}`)
      await expect(page.getByRole('heading', { level: 1 })).toHaveCount(1)
      await page.evaluate('document.fonts.ready')
      await page.waitForTimeout(400)
      const small = await page.evaluate<string[]>(
        `[...document.querySelectorAll('main button, main a[href], main input, main textarea')].filter((el) => {
          const box = el.getBoundingClientRect()
          const hidden = box.width === 0 || box.height === 0 || getComputedStyle(el).visibility === 'hidden' || el.closest('[hidden]')
          return !hidden && !el.closest('[class*="boxes"]') && (box.height < 43.5 || box.width < 23.5) && el.type !== 'hidden'
        }).map((el) => (el.getAttribute('aria-label') || el.textContent || el.id).trim())`,
      )
      expect(small).toEqual([])
      const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
      await page.setViewportSize({ width: 320, height: 640 })
      await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
      await page.waitForTimeout(300)
      expect(
        await page.evaluate<boolean>(
          'document.documentElement.scrollWidth <= document.documentElement.clientWidth',
        ),
      ).toBe(true)
    })
  }

  // Round 2 (design review, must fix 1): the content of a page starts below the hills, trees and sun of
  // the band, so no text sits on them. The band is the first drawing in the page.
  const CONTENT_START = `(() => {
    const main = document.querySelector('main')
    const header = main.querySelector('header')
    let top = Infinity
    const walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT)
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      if (!node.textContent.trim()) continue
      const element = node.parentElement
      if ((header && header.contains(element)) || element.closest('[hidden]')) continue
      // Round 6: a visually hidden heading (the account page's "Your account") is not drawn, so it is not counted.
      if (element.getBoundingClientRect().width <= 2) continue
      const range = document.createRange()
      range.selectNodeContents(node)
      for (const box of range.getClientRects()) if (box.width > 2 && box.height > 2) top = Math.min(top, box.top + window.scrollY)
    }
    // The lowest painted point of anything the band draws as a shape of its own (the pines, the flags,
    // the sun); the hills are the ground they stand on and fade out under them.
    const band = main.querySelector('div[aria-hidden="true"] > svg')
    let lowest = 0
    for (const shape of band.querySelectorAll('circle, path')) {
      const box = shape.getBoundingClientRect()
      if (box.height > 0 && box.height < 50) lowest = Math.max(lowest, box.bottom + window.scrollY)
    }
    return { top, lowest }
  })()`
  for (const [name, path, mocks] of PAGES) {
    for (const [width, height, size] of [
      [375, 812, '100%'],
      [375, 667, '100%'],
      [320, 640, '200%'],
    ] as const) {
      test(`[redesign 4] [redesign 46] ${name}: the first text of the content starts below the landscape at ${String(width)} x ${String(height)}, text ${size}`, async ({
        page,
      }) => {
        await page.setViewportSize({ width, height })
        await mockAccount(page, mocks)
        await page.goto(`/${path}`)
        await page.addStyleTag({ content: `html { font-size: ${size} !important; }` })
        await page.waitForLoadState('networkidle')
        await page.evaluate('document.fonts.ready')
        await page.waitForTimeout(300)
        const { top, lowest } = await page.evaluate<{ top: number; lowest: number }>(CONTENT_START)
        // Round 6 (owner, items 8, 29, 33, 36 and 37): content starts where the drawings put it, which is
        // higher than round 2's 160 px on the account page, Voice settings, the privacy notice and Send
        // feedback. It still never sits on the band's pines, flags or sun.
        expect(top).toBeGreaterThanOrEqual(110)
        expect(lowest).toBeGreaterThan(40)
        expect(top).toBeGreaterThan(lowest)
      })
    }
  }
})
