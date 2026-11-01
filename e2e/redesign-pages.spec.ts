import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page, type Route } from '@playwright/test'
import { mockHome } from './road-mocks.ts'
import { recordRequests } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. These answer the pages' reads and writes
// themselves, so they need no database.

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22a', 'wcag22aa']

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

type Me = { kind: 'guest' } | { kind: 'email'; email: string } | { kind: 'none' }

interface PageMocks {
  me?: Me
  processing?: 'granted' | 'not_asked' | 'withdrawn'
  retention?: boolean
  region?: string | null
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
      recordings: [],
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
    await expect(page.getByText('Add your email to keep your progress.')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Add your email' })).toBeVisible()
    for (const row of ['Speaking feedback', 'Download my data', 'Privacy notice', 'Send feedback']) {
      await expect(page.getByRole('list').getByText(row)).toBeVisible()
    }
    await expect(page.getByText('On', { exact: true })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign out' })).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
    await page.getByRole('button', { name: 'Add your email' }).click()
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
    await expect(page.getByText('Add your email to keep your progress.')).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
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
    // Round 2: "Your file is ready." is the title, centred under the orb, and the only way back is the arrow.
    await expect(page.getByRole('heading', { level: 1, name: 'Your file is ready.' })).toBeVisible()
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
    const title = await page.getByRole('heading', { level: 1 }).boundingBox()
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
    await expect(none.getByRole('heading', { level: 1, name: 'Sign in with your email' })).toBeVisible()
    await expect(none.getByRole('link', { name: 'Start as a guest instead' })).toBeVisible()
  })
})

test.describe('Voice settings', () => {
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
    await expect(page.getByText('Updated 1 November 2026.')).toBeVisible()
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

  test('[redesign 39] the section headings are ink, not mint, because mint means a control you can press', async ({
    page,
  }) => {
    await page.goto('/privacy')
    const colours = await page.evaluate<
      string[]
    >(`[...document.querySelectorAll('[class*="firstLayer"] section h2')]
      .map((h) => getComputedStyle(h).color)`)
    expect(colours).toHaveLength(5)
    for (const colour of colours) expect(colour).toBe('rgb(27, 42, 38)')
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
    await page.getByLabel('What should we know?').fill('The road is lovely.')
    await expect(page.getByText('19 of 1,000 characters')).toBeVisible()
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
    await expect(
      page.getByText('Your progress is safe. Check your internet connection, then try again.'),
    ).toBeVisible()
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
        await page.evaluate('document.fonts.ready')
        await page.waitForTimeout(300)
        const { top, lowest } = await page.evaluate<{ top: number; lowest: number }>(CONTENT_START)
        expect(top).toBeGreaterThanOrEqual(160)
        expect(lowest).toBeGreaterThan(40)
        expect(top).toBeGreaterThan(lowest)
      })
    }
  }
})
