import { readFileSync } from 'node:fs'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { USER_TABLE_NAMES } from '../src/privacy/data-inventory.ts'
import {
  addEmail,
  authUser,
  confirmCode,
  finishTodaysSession,
  frontDoorState,
  mailCount,
  mailIds,
  nextMail,
  rowsOf,
  secondDevice,
  sendCodeTo,
  signIn,
  snapshotOf,
  startGuest,
  testAddress,
  userCount,
} from './account-helpers.ts'
import { recordApiTimings } from './api-timing.ts'
import { one, sessionsOf, userIdOf } from './db.ts'
import { recordRequests, scrollsSideways, serveTone, settleAnimations, tabTo } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
//
// Phone size (375 x 812) in Chromium and WebKit, against the built app and the
// throwaway local Supabase of the pull request check, with the test fixture
// unit and Mailpit, the local mail catcher. Every test here is tagged @seed
// (it reads or changes the throwaway database); tests that send email are
// also tagged @email. Neither tag runs against the shared test project, whose
// built in sender only reaches the Supabase team. "Two devices" are two
// browser contexts that share no cookies. Addresses are on example.com and
// unique to each test.

function allZero(counts: Record<string, number>): string[] {
  return Object.entries(counts)
    .filter(([, n]) => n > 0)
    .map(([table, n]) => `${table}: ${String(n)}`)
}

async function axe(page: Page, label: string) {
  await page.evaluate('document.fonts.ready')
  // A colour scheme switched on an open page starts the buttons' colour
  // transitions; axe must measure the finished colours, not a frame halfway.
  await settleAnimations(page)
  const result = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
    .analyze()
  expect(
    result.violations.map((v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
  ).toEqual([])
}

async function fits(page: Page, label: string) {
  for (const [width, text] of [
    [320, '100%'],
    [375, '200%'],
  ] as const) {
    await page.setViewportSize({ width, height: 812 })
    await page.addStyleTag({ content: `html { font-size: ${text} !important; }` })
    expect(await scrollsSideways(page), `${label} at ${String(width)} px, text ${text}`).toBe(false)
    await page.addStyleTag({ content: 'html { font-size: 100% !important; }' })
  }
  await page.setViewportSize({ width: 375, height: 812 })
  for (const control of await page.locator('button, a[href], input').all()) {
    if (!(await control.isVisible())) continue
    const box = await control.boundingBox()
    const name = (await control.innerText().catch(() => '')) || ((await control.getAttribute('id')) ?? '')
    expect(box?.height ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
    expect(box?.width ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
  }
}

async function downloadFile(page: Page): Promise<{ name: string; file: Record<string, unknown> }> {
  await page.goto('/account')
  const button = page.getByRole('button', { name: 'Download my data' })
  await expect(button).toBeVisible()
  const waiting = page.waitForEvent('download')
  await button.click()
  const download = await waiting
  const path = await download.path()
  await expect(page.getByRole('status')).toHaveText('Your file is ready.')
  return {
    name: download.suggestedFilename(),
    file: JSON.parse(readFileSync(path, 'utf8')) as Record<string, unknown>,
  }
}

test.describe('accounts and personal data', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }, testInfo) => {
    recordApiTimings(page, testInfo)
    await serveTone(page)
  })

  test("[accounts 2] a guest's account page offers adding an email, the download and deletion, and no sign out", async ({
    page,
  }) => {
    await startGuest(page)
    await page.goto('/account')
    await expect(
      page.getByText(
        'You are using a guest account on this device. Add your email to keep your progress and use it on other devices.',
        { exact: true },
      ),
    ).toBeVisible()
    await expect(page.getByRole('button', { name: 'Add your email' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Download my data' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Privacy notice' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign out' })).toHaveCount(0)
    await expect(
      page.getByText('A guest account cannot sign back in, so add your email before you leave.', {
        exact: true,
      }),
    ).toBeVisible()
    await expect(page.locator('main')).not.toContainText(/streak|score|\d+ (words|sessions|cards)/i)
  })

  test('[accounts 18] [accounts 17] a guest downloads one file holding the account and every user table, matching the database', async ({
    page,
  }) => {
    const userId = await finishTodaysSession(page)
    let preparing = false
    await page.route('**/api/account/export', async (route) => {
      preparing = (await page.getByRole('status').innerText()) === 'Preparing your file.'
      await route.continue()
    })
    const { name, file } = await downloadFile(page)
    expect(preparing).toBe(true)
    expect(name).toMatch(/^puhuscribe-data-\d{4}-\d{2}-\d{2}\.json$/)
    expect(Object.keys(file)).toEqual(['about', 'exported_at', 'account', 'tables', 'files'])
    expect(file.account).toMatchObject({ id: userId, is_anonymous: true, email: null })
    const tables = file.tables as Record<string, Record<string, unknown>[]>
    // The file's table names and the inventory's must be the same list (statement 17).
    expect(Object.keys(tables).sort()).toEqual([...USER_TABLE_NAMES].sort())
    const counts = rowsOf(userId)
    for (const table of USER_TABLE_NAMES) {
      expect(tables[table]?.length ?? -1, table).toBe(counts[table] ?? 0)
      for (const row of tables[table] ?? []) expect(row.user_id, table).toBe(userId)
    }
    expect((tables.sessions ?? []).map((s) => s.id).sort()).toEqual(
      sessionsOf(userId)
        .map((s) => s.id)
        .sort(),
    )
    expect(file.files).toEqual({})
    const text = JSON.stringify(file)
    for (const cookie of await page.context().cookies()) expect(text).not.toContain(cookie.value.slice(0, 40))
  })

  test('[accounts 20] a guest deletes their account: the confirmation, then every row is gone and the front door says so', async ({
    page,
    context,
  }) => {
    const userId = await finishTodaysSession(page)
    await page.goto('/account')
    await page.getByRole('link', { name: 'Delete my account' }).click()
    await page.waitForURL('**/account/delete')
    await expect(
      page.getByText(
        'This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy.',
      ),
    ).toBeVisible()
    await expect(page.getByRole('button', { name: 'Keep my account' })).toBeVisible()
    await page.getByRole('button', { name: 'Delete my account' }).click()
    await page.waitForURL((url) => url.pathname === '/')
    await expect(page.getByRole('status')).toHaveText('Your account and all its data are deleted.')
    expect(authUser(userId).exists).toBe(false)
    expect(allZero(rowsOf(userId))).toEqual([])
    expect((await context.cookies()).filter((c) => c.name.startsWith('puhuscribe-auth'))).toEqual([])
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
  })

  test('[accounts 20] "Keep my account" goes back and deletes nothing', async ({ page }) => {
    const userId = await startGuest(page)
    await page.goto('/account/delete')
    await page.getByRole('button', { name: 'Keep my account' }).click()
    await page.waitForURL('**/account')
    expect(authUser(userId).exists).toBe(true)
  })

  test('[accounts 23] when the deletion fails the screen says so in the problem style and nothing is deleted', async ({
    page,
  }) => {
    const userId = await startGuest(page)
    await page.goto('/account/delete')
    await page.route('**/api/account/delete', (route) =>
      route.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"not_deleted"}' }),
    )
    await page.getByRole('button', { name: 'Delete my account' }).click()
    const status = page.getByRole('status')
    await expect(status).toHaveText(
      'Your account was not deleted. Check your internet connection, then try again.',
    )
    await expect(status).toHaveAttribute('data-tone', 'problem')
    expect(authUser(userId).exists).toBe(true)
  })

  test.describe('with email', { tag: '@email' }, () => {
    test('[accounts 4] [accounts 5] [accounts 7] [accounts 15] adding an email: the screens, a wrong code, and no email until the right code', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await startGuest(page)
      await page.clock.install()
      await page.goto('/account')
      await page.getByRole('button', { name: 'Add your email' }).click()
      await page.waitForURL('**/account/email')
      await expect(page.getByRole('heading', { level: 1, name: 'Add your email' })).toBeVisible()
      await expect(
        page.getByText(
          'We send a 6 digit code to this address. We use your email only to send you sign in codes.',
        ),
      ).toBeVisible()
      await expect(
        page.getByText(
          'If this email already has a PuhuScribe account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts.',
        ),
      ).toBeVisible()
      await sendCodeTo(page, address)

      // Statement 7: after "Send code" the account is still a guest with no email.
      expect(authUser(userId)).toEqual({ exists: true, anonymous: true, email: '' })

      await expect(
        page.getByText(`Enter the 6 digit code we sent to ${address}. The code works for one hour.`),
      ).toBeVisible()
      const code = page.getByLabel('6 digit code')
      await expect(code).toHaveAttribute('inputmode', 'numeric')
      await expect(code).toHaveAttribute('autocomplete', 'one-time-code')
      const resend = page.getByRole('button', { name: 'Send a new code' })
      await expect(resend).toBeDisabled()
      await expect(page.getByText('You can ask for a new code after one minute.')).toBeVisible()

      // Statement 15: the email change email shows a 6 digit code and no link.
      const mail = await nextMail(address)
      expect(mail.subject).toBe('Your PuhuScribe code')
      expect(mail.code).toMatch(/^\d{6}$/)
      expect(`${mail.text} ${mail.html}`).not.toMatch(/http/i)
      expect(mail.text).toContain('Enter it in the app. It works for one hour.')

      const wrong = mail.code === '000000' ? '111111' : '000000'
      await confirmCode(page, wrong)
      const status = page.getByRole('status')
      await expect(status).toHaveText('That code did not work. Check the numbers and try again.')
      await expect(status).toHaveAttribute('data-tone', 'gentle')
      expect(authUser(userId)).toEqual({ exists: true, anonymous: true, email: '' })

      await page.clock.runFor(61_000)
      await expect(resend).toBeEnabled()
    })

    test('[accounts 6] [accounts 2] a guest who finished a session adds an email and keeps the same account and every row', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await finishTodaysSession(page)
      const before = snapshotOf(userId)
      expect(before.sessions.length).toBeGreaterThan(0)
      expect(before.cards.length).toBeGreaterThan(0)
      const users = userCount()
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      expect(authUser(userId)).toEqual({ exists: true, anonymous: false, email: address })
      expect(snapshotOf(userId)).toEqual(before)
      expect(userCount()).toBe(users)
      expect(await userIdOf(page.context())).toBe(userId)
      await page.goto('/account')
      await expect(page.getByText(`You are signed in as ${address}.`, { exact: true })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Sign out' })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Download my data' })).toBeVisible()
      await expect(page.getByRole('link', { name: 'Delete my account' })).toBeVisible()
    })

    test('[accounts 8] [accounts 9] a guest adds an email that already has an account: same screens, then signed in to it and the guest deleted', async ({
      page,
      browser,
      baseURL,
    }, testInfo) => {
      const address = testAddress('learner-b', testInfo)
      // Account B exists with progress (a guest who finished a session added the email).
      const ownerId = await finishTodaysSession(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      const ownerRows = snapshotOf(ownerId)

      const other = await secondDevice(browser, testInfo, baseURL)
      const guestPage = await other.newPage()
      await serveTone(guestPage)
      const guestId = await startGuest(guestPage)
      await guestPage.goto('/account/email')
      const seen = await mailIds(address)
      await sendCodeTo(guestPage, address)
      // The same screen as for a new address (statement 9).
      await expect(
        guestPage.getByText(`Enter the 6 digit code we sent to ${address}. The code works for one hour.`),
      ).toBeVisible()
      const mail = await nextMail(address, seen)
      expect(mail.subject).toBe('Your PuhuScribe code')
      expect(`${mail.text} ${mail.html}`).not.toMatch(/http/i)
      await confirmCode(guestPage, mail.code)
      await expect(guestPage.getByRole('status')).toHaveText(
        'You are signed in to your account. The guest progress from this device was deleted.',
      )
      expect(await userIdOf(other)).toBe(ownerId)
      expect(snapshotOf(ownerId)).toEqual(ownerRows)
      expect(authUser(guestId).exists).toBe(false)
      expect(allZero(rowsOf(guestId))).toEqual([])
      await other.close()
    })

    test('[accounts 10] [accounts 11] [accounts 9] signing in with an unknown address shows the same text, sends nothing and makes no account', async ({
      page,
    }, testInfo) => {
      const address = testAddress('nobody', testInfo)
      const users = userCount()
      await page.goto('/sign-in')
      await sendCodeTo(page, address)
      await expect(
        page.getByText('If this email has a PuhuScribe account, we sent it a 6 digit code.'),
      ).toBeVisible()
      await expect(
        page.getByText('No code after a few minutes? Check the address, or go back and start as a guest.'),
      ).toBeVisible()
      await page.waitForTimeout(3_000)
      expect(await mailCount(address)).toBe(0)
      expect(one(`select count(*) from auth.users where email = :'email'`, { email: address })).toBe('0')
      expect(userCount()).toBe(users)
    })

    test('[accounts 12] [accounts 10] [accounts 15] two devices: the second signs in and sees the same progress, and progress made there shows on the first', async ({
      page,
      browser,
      baseURL,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await finishTodaysSession(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )

      const deviceB = await secondDevice(browser, testInfo, baseURL)
      const pageB = await deviceB.newPage()
      await serveTone(pageB)
      const seen = await mailIds(address)
      await pageB.goto('/sign-in')
      await sendCodeTo(pageB, address)
      const mail = await nextMail(address, seen)
      // Statement 15: the sign in email shows a 6 digit code and no link.
      expect(mail.subject).toBe('Your PuhuScribe code')
      expect(mail.code).toMatch(/^\d{6}$/)
      expect(`${mail.text} ${mail.html}`).not.toMatch(/http/i)
      await confirmCode(pageB, mail.code)
      await expect(pageB.getByRole('status')).toHaveText('You are signed in to your account.')
      const cookies = await deviceB.cookies()
      for (const cookie of cookies.filter((c) => c.name.startsWith('puhuscribe-auth'))) {
        expect(cookie.httpOnly).toBe(true)
        expect(cookie.secure).toBe(true)
        expect(cookie.sameSite).toBe('Lax')
      }
      expect(await userIdOf(deviceB)).toBe(userId)

      expect(await frontDoorState(pageB)).toBe(await frontDoorState(page))
      const fileA = (await downloadFile(page)).file.tables as Record<
        string,
        { id?: string; form_id?: number }[]
      >
      const fileB = (await downloadFile(pageB)).file.tables as Record<
        string,
        { id?: string; form_id?: number }[]
      >
      expect(fileB.sessions?.map((s) => s.id)).toEqual(fileA.sessions?.map((s) => s.id))
      expect(fileB.cards?.map((c) => c.form_id)).toEqual(fileA.cards?.map((c) => c.form_id))

      const endedBefore = sessionsOf(userId).filter((s) => s.ended).length
      await finishTodaysSession(pageB)
      expect(sessionsOf(userId).filter((s) => s.ended).length).toBe(endedBefore + 1)
      expect(await frontDoorState(page)).toBe(await frontDoorState(pageB))
      await deviceB.close()
    })

    test('[accounts 13] a guest on the second device is warned, then signing in deletes the guest', async ({
      page,
      browser,
      baseURL,
    }, testInfo) => {
      const address = testAddress('learner-b', testInfo)
      const ownerId = await startGuest(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )

      const other = await secondDevice(browser, testInfo, baseURL)
      const guestPage = await other.newPage()
      await serveTone(guestPage)
      const guestId = await startGuest(guestPage)
      await guestPage.goto('/sign-in')
      await expect(
        guestPage.getByText(
          'This device has a guest account. Signing in deletes its progress, because progress cannot be moved between accounts. To keep it, add your email to the guest account instead.',
        ),
      ).toBeVisible()
      await expect(guestPage.getByRole('button', { name: 'Go back' })).toBeVisible()
      await signIn(guestPage, address, { anyway: true })
      await expect(guestPage.getByRole('status')).toHaveText(
        'You are signed in to your account. The guest progress from this device was deleted.',
      )
      expect(authUser(guestId).exists).toBe(false)
      expect(allZero(rowsOf(guestId))).toEqual([])
      expect(await userIdOf(other)).toBe(ownerId)
      await guestPage.goto('/account')
      await expect(guestPage.getByText(`You are signed in as ${address}.`, { exact: true })).toBeVisible()
      await other.close()
    })

    test('[accounts 14] signing out ends this device only; the other device stays signed in', async ({
      page,
      browser,
      baseURL,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      await startGuest(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      const deviceB = await secondDevice(browser, testInfo, baseURL)
      const pageB = await deviceB.newPage()
      await signIn(pageB, address)

      await page.goto('/account')
      await page.getByRole('button', { name: 'Sign out' }).click()
      await page.waitForURL((url) => url.pathname === '/')
      await expect(page.getByRole('status')).toHaveText('You are signed out on this device.')
      await expect(page.getByRole('button', { name: 'I already have an account' })).toBeVisible()
      expect((await page.context().cookies()).filter((c) => c.name.startsWith('puhuscribe-auth'))).toEqual([])

      await pageB.goto('/account')
      await expect(pageB.getByText(`You are signed in as ${address}.`, { exact: true })).toBeVisible()
      await deviceB.close()
    })

    test('[accounts 18] [accounts 20] an email account downloads its file, then deletes the account and everything in it', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await finishTodaysSession(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      const { file } = await downloadFile(page)
      expect(file.account).toMatchObject({ id: userId, email: address, is_anonymous: false })
      expect(Object.keys(file.tables as object).sort()).toEqual([...USER_TABLE_NAMES].sort())

      await page.goto('/account/delete')
      await page.getByRole('button', { name: 'Delete my account' }).click()
      await page.waitForURL((url) => url.pathname === '/')
      await expect(page.getByRole('status')).toHaveText('Your account and all its data are deleted.')
      expect(authUser(userId).exists).toBe(false)
      expect(allZero(rowsOf(userId))).toEqual([])
      expect(one(`select count(*) from auth.users where email = :'email'`, { email: address })).toBe('0')
    })

    test('[accounts 22] deleting the account on one device signs the other out at its next press, and nothing is written', async ({
      page,
      browser,
      baseURL,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await startGuest(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )

      const deviceB = await secondDevice(browser, testInfo, baseURL)
      const pageB = await deviceB.newPage()
      await serveTone(pageB)
      await signIn(pageB, address)
      await pageB.goto('/session')
      await expect(pageB.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()

      await page.goto('/account/delete')
      await page.getByRole('button', { name: 'Delete my account' }).click()
      await page.waitForURL((url) => url.pathname === '/')
      expect(authUser(userId).exists).toBe(false)

      for (;;) {
        const next = pageB.getByRole('button', { name: 'Next line' })
        if ((await next.count()) === 0) break
        await next.click()
      }
      await pageB.getByRole('button', { name: 'Continue' }).click()
      await pageB.waitForURL((url) => url.pathname === '/')
      const message = 'You are signed out on this device. Sign in with your email to continue.'
      await expect(pageB.getByRole('status')).toHaveText(message)
      await pageB.reload()
      await expect(pageB.getByRole('status')).toHaveText(message)
      expect(allZero(rowsOf(userId))).toEqual([])
      expect((await deviceB.cookies()).filter((c) => c.name.startsWith('puhuscribe-auth'))).toEqual([])
      await deviceB.close()
    })

    test('[accounts 27] the email and code screens fit, work by keyboard alone, and pass axe in light and dark', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      await startGuest(page)
      for (const scheme of ['light', 'dark'] as const) {
        await page.emulateMedia({ colorScheme: scheme })
        await page.goto('/account')
        await expect(page.getByRole('button', { name: 'Add your email' })).toBeVisible()
        await axe(page, `account, guest, ${scheme}`)
        await page.goto('/account/delete')
        await expect(page.getByRole('button', { name: 'Keep my account' })).toBeVisible()
        await axe(page, `delete, ${scheme}`)
        await page.goto('/sign-in')
        await expect(page.getByRole('button', { name: 'Sign in anyway' })).toBeVisible()
        await axe(page, `sign in warning, ${scheme}`)
      }
      await page.emulateMedia({ colorScheme: 'light' })
      for (const path of ['/account', '/account/delete', '/sign-in']) {
        await page.goto(path)
        await page.waitForLoadState('networkidle')
        await fits(page, path)
      }

      // The whole add email flow by keyboard alone.
      await page.goto('/account')
      await tabTo(page, page.getByRole('button', { name: 'Add your email' }), testInfo)
      await page.keyboard.press('Enter')
      await page.waitForURL('**/account/email')
      await expect(page.getByLabel('Email address')).toBeFocused()
      await fits(page, 'email screen')
      for (const scheme of ['light', 'dark'] as const) {
        await page.emulateMedia({ colorScheme: scheme })
        await axe(page, `email screen, ${scheme}`)
      }
      await page.emulateMedia({ colorScheme: 'light' })
      await page.getByLabel('Email address').focus()
      await page.keyboard.type(address)
      await page.keyboard.press('Enter')
      await expect(page.getByLabel('6 digit code')).toBeFocused()
      await fits(page, 'code screen')
      for (const scheme of ['light', 'dark'] as const) {
        await page.emulateMedia({ colorScheme: scheme })
        await axe(page, `code screen, ${scheme}`)
      }
      await page.emulateMedia({ colorScheme: 'light' })
      const mail = await nextMail(address)
      await page.keyboard.type('000000' === mail.code ? '111111' : '000000')
      await page.keyboard.press('Enter')
      await expect(page.getByRole('status')).toHaveText(
        'That code did not work. Check the numbers and try again.',
      )
      await axe(page, 'code screen, wrong code')
      await page.getByLabel('6 digit code').focus()
      await page.keyboard.press('ControlOrMeta+a')
      await page.keyboard.type(mail.code)
      await page.keyboard.press('Enter')
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      await axe(page, 'email added')
      await page.goto('/account')
      await expect(page.getByRole('button', { name: 'Sign out' })).toBeVisible()
      await axe(page, 'account, email')
      await fits(page, 'account, email')
    })
  })

  test('[accounts 26] the account screens send every request to their own address, and the browser holds no token', async ({
    page,
  }) => {
    const requests = recordRequests(page)
    await startGuest(page)
    for (const path of ['/account', '/account/email', '/account/delete', '/sign-in', '/privacy']) {
      await page.goto(path)
      await page.waitForLoadState('networkidle')
    }
    const origin = new URL(page.url()).origin
    for (const request of requests) {
      expect(new URL(request.url()).origin, request.url()).toBe(origin)
      expect(new URL(request.url()).hostname).not.toMatch(/supabase\.co$/)
    }
    expect(await page.evaluate<string>('document.cookie')).toBe('')
    const storage = await page.evaluate<string>('JSON.stringify([localStorage, sessionStorage])')
    expect(storage).not.toMatch(/access_token|refresh_token|eyJ/)
  })

  test('[accounts 26] a post from another site cannot delete an account', async ({ page }) => {
    const userId = await startGuest(page)
    const res = await page.request.post('/api/account/delete', {
      headers: { 'content-type': 'application/json', origin: 'https://evil.example' },
      data: {},
    })
    expect(res.status()).toBe(403)
    expect(authUser(userId).exists).toBe(true)
  })

  test("[accounts 22] a guest whose account was deleted keeps job 8's message", async ({ page }) => {
    const userId = await startGuest(page)
    one(`delete from auth.users where id = :'uid' returning 1`, { uid: userId })
    await page.goto('/')
    await expect(page.getByRole('status')).toHaveText(
      'Your guest session ended on this device. Press Start to begin again.',
    )
  })
})
