import { type Locator, type Page } from '@playwright/test'
import { PATHS } from '../src/lib/app-paths.ts'
import { expect, test } from './test-base.ts'
import {
  addEmail,
  authUser,
  confirmCode,
  nextMail,
  sendCodeTo,
  startGuest,
  testAddress,
} from './account-helpers.ts'
import { recordApiTimings } from './api-timing.ts'
import { linesOf, one, sessionsOf, userIdOf } from './db.ts'
import { dayLater, finishFirstSession, throughUnderstandIt } from './review-helpers.ts'
import {
  finishHearIt,
  finishUnderstandIt,
  passSayIt,
  recordRequests,
  serveTone,
  tabTo,
  isTurnstileScript,
} from './session-helpers.ts'
import {
  COMES_BACK,
  NOTE_SELECTOR,
  NOT_SAVED,
  SAVED,
  SAVED_PLAIN,
  SAVING,
  axe,
  axeIn,
  copy,
  emailScreenSentences,
  expectNoNote,
  expectNoteFits,
  expectNoteFullyVisible,
  focusedName,
  giveTwoEarlierFinishedSessions,
  noteOf,
  normalise,
  onAddEmailScreen,
  recordCompleteAnswers,
  storageOf,
  walkContinuedSession,
  walkFromHearIt,
  walkNextSession,
  walkToFinish,
} from './save-progress-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/18-save-progress/spec.md that each test protects.
//
// Phone size (375 x 812) in Chromium and WebKit, against the built app and the
// throwaway local Supabase of the pull request check, with the test fixture
// units and Mailpit, the local mail catcher. Every test here is tagged @seed
// (it reads or changes the throwaway database); tests that read a code from
// Mailpit, and the reminder test, are also tagged @email. Neither tag runs
// against the shared test project. Addresses are on example.com and unique to
// each test. The owner's calls of 31 October 2026: one reminder at the third
// finished session (call 1 B), the words of the note (call 2 B), and a white
// "Add your email" button with a quiet "Not now" (call 3 A).

interface LookOfTheNote {
  inside: number
  around: boolean
  inertPage: number
  openDialogs: number
  focusInside: boolean
  animations: number
  statuses: number
  position: string
  images: number
  uppercase: boolean
  gradients: boolean
  borders: string[]
  fill: string
  shadow: string
  tableLike: number
  badge: number
  overflowWrap: string
  langs: number
  headings: number
}

async function lookOfTheNote(page: Page): Promise<LookOfTheNote> {
  return page.evaluate<LookOfTheNote>(`(() => {
    const note = document.querySelector('${NOTE_SELECTOR}')
    const all = [note, ...note.querySelectorAll('*')]
    const css = getComputedStyle(note)
    const sentence = note.querySelector('p')
    return {
      inside: note.querySelectorAll('[role="dialog"],[aria-modal],[inert],[autofocus],[aria-live],[role="status"],[role="alert"],dialog').length,
      around: Boolean(note.closest('[role="dialog"],[aria-modal],[inert],dialog,[aria-live]')),
      inertPage: document.querySelectorAll('[inert]').length,
      openDialogs: document.querySelectorAll('dialog[open]').length,
      focusInside: note.contains(document.activeElement),
      animations: note.getAnimations({ subtree: true }).length,
      statuses: document.querySelectorAll('[role="status"]').length,
      position: css.position,
      images: note.querySelectorAll('img,svg,picture,canvas,video').length,
      uppercase: all.some((e) => getComputedStyle(e).textTransform === 'uppercase'),
      gradients: all.some((e) => getComputedStyle(e).backgroundImage !== 'none'),
      borders: [css.borderTopWidth, css.borderRightWidth, css.borderBottomWidth, css.borderLeftWidth],
      fill: css.backgroundColor,
      shadow: css.boxShadow,
      tableLike: note.querySelectorAll('table,tr,td,hr,[role="row"],[role="table"]').length,
      badge: all.filter((e) => e !== note && !e.closest('button') && (getComputedStyle(e).borderRadius !== '0px' || getComputedStyle(e).backgroundColor !== 'rgba(0, 0, 0, 0)')).length,
      overflowWrap: getComputedStyle(sentence).overflowWrap,
      langs: note.querySelectorAll('[lang]').length,
      headings: note.querySelectorAll('h1,h2,h3,h4,h5,h6,[role="heading"]').length,
    }
  })()`)
}

/** The colours of the finish screen's buttons against the design tokens, as the browser resolves them. */
async function buttonColours(page: Page) {
  return page.evaluate<{
    done: string
    add: string
    later: string
    addText: string
    tokens: { primary: string; secondary: string; text: string }
    primaryCount: number
  }>(`(() => {
    const resolve = (token, property) => {
      const probe = document.createElement('div')
      probe.style[property] = 'var(' + token + ')'
      document.body.append(probe)
      const value = getComputedStyle(probe)[property === 'background' ? 'backgroundColor' : property]
      probe.remove()
      return value
    }
    const button = (name) => [...document.querySelectorAll('button')].find((b) => b.textContent.trim() === name)
    const bg = (b) => getComputedStyle(b).backgroundColor
    const primary = resolve('--color-button', 'background')
    return {
      done: bg(button('Done')),
      add: bg(button('${copy.SAVE_NOTE_ADD}')),
      later: bg(button('${copy.SAVE_NOTE_LATER}')),
      addText: getComputedStyle(button('${copy.SAVE_NOTE_ADD}')).color,
      tokens: {
        primary,
        secondary: resolve('--color-button-secondary', 'background'),
        text: resolve('--color-mint-deep', 'color'),
      },
      // Buttons with words: the round play controls and the word buttons have none of their own.
      primaryCount: [...document.querySelectorAll('button')].filter((b) => b.textContent.trim() !== '' && bg(b) === primary).length,
    }
  })()`)
}

test.describe('the save progress note', { tag: '@seed' }, () => {
  test.setTimeout(150_000)

  test.beforeEach(async ({ page }, testInfo) => {
    recordApiTimings(page, testInfo)
    await serveTone(page)
  })

  // When the note shows ------------------------------------------------------------------

  test('[save-progress 1] [save-progress 3] [save-progress 9] [save-progress 12] [save-progress 16] a guest sees the note after the first finished session: in place, with exactly its words, as a plain block, and Done still works in one tap', async ({
    page,
  }) => {
    const answers = recordCompleteAnswers(page)
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    const note = noteOf(page)
    await expect(note).toBeVisible()
    await expect.poll(() => answers.length).toBe(1)
    // [3] The answer that already existed, plus one field.
    expect(answers[0]).toEqual({ status: 200, body: { saved: true, saveNote: 'first' } })

    // [9] [1] Exactly these words, and the two buttons.
    await expect(note.getByText(copy.SAVE_NOTE_SENTENCE, { exact: true })).toBeVisible()
    await expect(note.getByRole('button', { name: copy.SAVE_NOTE_ADD, exact: true })).toBeVisible()
    await expect(note.getByRole('button', { name: copy.SAVE_NOTE_LATER, exact: true })).toBeVisible()
    expect(normalise(await note.innerText())).toBe(
      `${copy.SAVE_NOTE_SENTENCE} ${copy.SAVE_NOTE_ADD} ${copy.SAVE_NOTE_LATER}`,
    )

    // [1] In the page after the line card (and the new words panel that follows it, job
    // 19-redesign, statement 33) and before "Send feedback". The old line "The words you met will
    // come back in your review." is gone on purpose.
    const top = async (target: Locator) => (await target.boundingBox())?.y ?? Number.NaN
    await expect(page.getByText(COMES_BACK, { exact: true })).toHaveCount(0)
    const card = await top(page.locator('[data-line-id]').first())
    const noteAt = await top(note)
    const feedback = await top(page.getByRole('link', { name: 'Send feedback' }))
    expect(card).toBeLessThan(noteAt)
    expect(noteAt).toBeLessThan(feedback)

    // [12] [16] [15] A plain block in the page, with nothing of a dialog, an alert or a decoration.
    const look = await lookOfTheNote(page)
    expect(look.inside).toBe(0)
    expect(look.around).toBe(false)
    expect(look.inertPage).toBe(0)
    expect(look.openDialogs).toBe(0)
    expect(look.focusInside).toBe(false)
    expect(look.animations).toBe(0)
    expect(look.statuses).toBe(1)
    expect(['static', 'relative']).toContain(look.position)
    expect(look.images).toBe(0)
    expect(look.uppercase).toBe(false)
    expect(look.gradients).toBe(false)
    // A milky panel since job 19-redesign (design.md, "Save progress note"): the same thin edge on
    // all four sides (never one thick side), a fill and the panel shadow.
    expect(look.borders).toEqual(['1px', '1px', '1px', '1px'])
    expect(look.fill).not.toBe('rgba(0, 0, 0, 0)')
    expect(look.shadow).not.toBe('none')
    expect(look.tableLike).toBe(0)
    expect(look.badge).toBe(0)
    expect(look.langs).toBe(0)
    expect(look.headings).toBe(0)
    expect(look.overflowWrap).toBe('anywhere')
    expect(await note.innerText()).not.toMatch(/\p{Extended_Pictographic}/u)
    await expect(page.locator('h1')).toHaveCount(1)
    expect(await note.innerText()).not.toMatch(/streak|badge|score|points|congratulations|lose|lost|losing/i)

    // [16] [call 3 A] Explicit token colours; "Done" is the only black button.
    // Away from the buttons, so none shows its hover colour.
    await page.mouse.move(0, 0)
    const colours = await buttonColours(page)
    expect(colours.done).toBe(colours.tokens.primary)
    expect(colours.add).toBe(colours.tokens.secondary)
    expect(colours.addText).toBe(colours.tokens.text)
    expect(colours.later).toBe('rgba(0, 0, 0, 0)')
    expect(colours.primaryCount).toBe(1)

    // [12] The bottom action area is unchanged: its status line and "Done" are fully visible and
    // the note is not part of it.
    const done = page.getByRole('button', { name: 'Done', exact: true })
    await expect(page.getByRole('status')).toBeInViewport({ ratio: 1 })
    await expect(done).toBeInViewport({ ratio: 1 })
    await expect(done.locator('xpath=..').locator(NOTE_SELECTOR)).toHaveCount(0)

    // [12] It never blocks: one tap on Done reaches the front door.
    await done.click()
    await page.waitForURL((url) => url.pathname === PATHS.home)
    await expect(page.getByRole('heading', { level: 1, name: 'Your road to A1' })).toBeAttached()
  })

  // Never mid session, never before the progress is saved -----------------------------------

  test('[save-progress 2] the note is on none of the front door, Hear it, Understand it and Say it', async ({
    page,
  }) => {
    await page.goto(PATHS.home)
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    await expectNoNote(page, 'front door')
    const userId = await startGuest(page)
    await expectNoNote(page, 'Hear it')
    await finishHearIt(page)
    await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeVisible()
    await expectNoNote(page, 'Understand it')
    const open = sessionsOf(userId).find((s) => !s.ended)
    const lines = linesOf(open?.dialogueId ?? '')
    await finishUnderstandIt(page, (lineId) => lines.find((l) => l.id === lineId)?.gloss ?? '')
    // The consent screen of Say it comes first for a new learner.
    await expectNoNote(page, 'Say it, consent')
    await passSayIt(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    await expect(noteOf(page)).toBeVisible()
  })

  test('[save-progress 2] the note is not on Keep it', async ({ page }) => {
    const { userId } = await finishFirstSession(page)
    dayLater(userId)
    await page.reload()
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await throughUnderstandIt(page, userId)
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    await expectNoNote(page, 'Keep it')
  })

  test('[save-progress 2] with the answer delayed by 2 seconds the finish screen says it is saving and shows no note, then shows the note', async ({
    page,
  }) => {
    await page.route('**/api/sessions/*/complete', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 2_000))
      await route.continue()
    })
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVING)
    await expectNoNote(page, 'while saving')
    await expect(page.getByRole('status')).toHaveText(SAVED)
    await expect(noteOf(page)).toBeVisible()
  })

  test('[save-progress 2] when the save cannot reach the Worker the screen says so, shows Try again and no note, and the note comes after Try again works', async ({
    page,
  }) => {
    let abort = true
    await page.route('**/api/sessions/*/complete', async (route) => {
      if (abort) await route.abort()
      else await route.continue()
    })
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(NOT_SAVED)
    await expect(page.getByRole('button', { name: 'Try again', exact: true })).toBeVisible()
    await expectNoNote(page, 'not saved')
    abort = false
    await page.getByRole('button', { name: 'Try again', exact: true }).click()
    await expect(page.getByRole('status')).toHaveText(SAVED)
    await expect(noteOf(page)).toBeVisible()
    await expect(page.getByRole('button', { name: 'Try again', exact: true })).toHaveCount(0)
  })

  // People with no account ----------------------------------------------------------------------

  test("[save-progress 6] a guest whose account was deleted during the session sees job 8's own message and no note", async ({
    page,
  }) => {
    const answers = recordCompleteAnswers(page)
    const userId = await startGuest(page)
    await page.route('**/api/sessions/*/complete', async (route) => {
      one(`delete from auth.users where id = :'uid' returning 1`, { uid: userId })
      await route.continue()
    })
    await walkFromHearIt(page, userId)
    await expect(page.getByRole('status')).toHaveText(NOT_SAVED)
    await expect.poll(() => answers.length).toBe(1)
    expect(answers[0]?.status).toBe(401)
    expect(JSON.stringify(answers[0]?.body)).not.toContain('saveNote')
    await expectNoNote(page, 'account deleted')
  })

  // It shows once ---------------------------------------------------------------------------------------

  test('[save-progress 7] [save-progress 11] [save-progress 13] [save-progress 15] "Not now" sends nothing and stores nothing, the line moves focus, and the note does not come back', async ({
    page,
  }) => {
    const requests = recordRequests(page)
    const answers = recordCompleteAnswers(page)
    const userId = await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    const note = noteOf(page)
    await expect(note).toBeVisible()

    // [13] Only the app's own address and only requests that exist today: no request for the note.
    const origin = new URL(page.url()).origin
    // Cloudflare Turnstile's script for the new guest's Start is the one outside request (job turnstile).
    for (const request of requests.filter((r) => !isTurnstileScript(r.url()))) {
      const url = new URL(request.url())
      expect(url.origin, request.url()).toBe(origin)
      if (url.pathname.startsWith('/api/')) {
        expect(url.pathname, request.url()).toMatch(
          /^\/api\/(guest|today|me|patterns|voice(\/consent)?|road|sessions\/today|sessions\/[0-9a-f-]+\/(step|complete|review|review\/done)|speech\/(say|recall)|review\/answer|feedback|crash)$/,
        )
      }
      if (url.pathname.startsWith('/api/')) {
        expect(url.pathname.toLowerCase()).not.toMatch(/note|save-?progress/)
      }
    }
    expect(answers).toHaveLength(1)
    const before = await storageOf(page)
    expect(before.documentCookie).toBe('')
    expect(before.localStorage).toBe(0)
    expect(before.sessionStorage).toBe(0)
    // At least one sign in cookie is held (the test must not pass with no cookie at all), and nothing else.
    expect(before.cookies.filter((cookie) => cookie.startsWith('puhuscribe-auth')).length).toBeGreaterThan(0)
    for (const cookie of before.cookies) expect(cookie).toMatch(/^puhuscribe-auth/)

    // [11] [15] "Not now" by keyboard (Space): no request, nothing stored, one plain line, focus on it.
    const marker = requests.length
    await note.getByRole('button', { name: copy.SAVE_NOTE_LATER, exact: true }).focus()
    await page.keyboard.press('Space')
    const closed = page.getByText(copy.SAVE_NOTE_CLOSED, { exact: true })
    await expect(closed).toBeVisible()
    await expect(note).toHaveCount(0)
    await expect(page.getByText(copy.SAVE_NOTE_SENTENCE)).toHaveCount(0)
    await expect(closed).toBeFocused()
    await expect(closed).toHaveAttribute('tabindex', '-1')
    const attributes = await page.evaluate<string[]>(`(() => {
      const line = [...document.querySelectorAll('p')].find((p) => p.textContent === ${JSON.stringify(copy.SAVE_NOTE_CLOSED)})
      return [line.getAttribute('role') ?? '', line.getAttribute('aria-live') ?? '', line.closest('[role="status"],[role="alert"],[aria-live]') ? 'inside' : '']
    })()`)
    expect(attributes).toEqual(['', '', ''])
    await expect(page.getByRole('status')).toHaveCount(1)
    await page.waitForLoadState('networkidle')
    expect(requests.length).toBe(marker)
    expect(await storageOf(page)).toEqual(before)

    // [7] Reload /session and the front door: no note. The next finished session: none either.
    await page.reload()
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
    await expectNoNote(page, 'after reload')
    await page.goto(PATHS.home)
    await expect(page.getByRole('heading', { level: 1, name: 'Your road to A1' })).toBeAttached()
    await expectNoNote(page, 'front door')
    await walkContinuedSession(page, userId)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    await expectNoNote(page, 'second session')
    await expect.poll(() => answers.length).toBe(2)
    expect(answers[1]).toEqual({ status: 200, body: { saved: true } })
  })

  test('[save-progress 7] [save-progress 10] [save-progress 12] [save-progress 15] "Add your email" opens the add email screen by keyboard, with its two sentences, and Back shows no note', async ({
    page,
  }) => {
    const userId = await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    const add = noteOf(page).getByRole('button', { name: copy.SAVE_NOTE_ADD, exact: true })
    await add.focus()
    await page.keyboard.press('Enter')
    await page.waitForURL((url) => url.pathname.endsWith(copy.ADD_EMAIL_PATH))
    expect(onAddEmailScreen(page)).toBe(true)
    await expect(page.getByRole('heading', { name: 'Create your account', exact: true })).toBeVisible()
    const { sendsCode, takenWarning } = emailScreenSentences()
    await expect(page.getByText(sendsCode, { exact: true })).toBeVisible()
    await expect(page.getByText(takenWarning, { exact: true })).toBeVisible()
    // The note adds no account code: nothing changed for this account.
    expect(authUser(userId).anonymous).toBe(true)
    await page.goBack()
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible()
    await expectNoNote(page, 'after Back')
    expect(onAddEmailScreen(page)).toBe(false)
  })

  // Never blocks --------------------------------------------------------------------------------------

  test('[save-progress 12] with the note showing, the play controls, Send feedback and Leave session still work', async ({
    page,
  }) => {
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    await expect(noteOf(page)).toBeVisible()
    for (const name of ['Play the spoken line', 'Play the written line']) {
      const play = page.getByRole('button', { name })
      await expect(play).toBeEnabled()
      await play.click()
      await expect(play).toBeEnabled()
    }
    await expect(page.getByRole('link', { name: 'Send feedback' })).toHaveAttribute(
      'href',
      `${PATHS.feedback}?from=finish`,
    )
    await expect(noteOf(page)).toBeVisible()
    await page.getByRole('link', { name: 'Leave session' }).click()
    await page.waitForURL((url) => url.pathname === PATHS.home)
    await expect(page.getByRole('heading', { level: 1, name: 'Your road to A1' })).toBeAttached()
  })

  // Phone, keyboard and look ------------------------------------------------------------------------------

  test('[save-progress 14] the whole note is visible without scrolling in light and dark, nothing scrolls sideways at 320 px and at 200 percent text, and both buttons are 44 x 44', async ({
    page,
  }) => {
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    for (const scheme of ['light', 'dark'] as const) {
      await page.emulateMedia({ colorScheme: scheme })
      await expect(noteOf(page)).toBeVisible()
      await expectNoteFullyVisible(page, `finish screen, ${scheme}`)
    }
    await page.emulateMedia({ colorScheme: 'light' })
    await expectNoteFits(page, 'finish screen')
  })

  test('[save-progress 15] [save-progress 16] the Tab order, the focus outline, axe in light and dark with the note and again after "Not now", and reduced motion', async ({
    page,
  }, testInfo) => {
    await walkToFinish(page)
    await expect(page.getByRole('status')).toHaveText(SAVED)
    const note = noteOf(page)
    await expect(note).toBeVisible()
    const add = note.getByRole('button', { name: copy.SAVE_NOTE_ADD, exact: true })
    const later = note.getByRole('button', { name: copy.SAVE_NOTE_LATER, exact: true })

    // WebKit skips buttons on Tab unless a system setting allows it, so the order is checked in Chromium.
    if (testInfo.project.name !== 'webkit') {
      await tabTo(page, add, testInfo)
      await page.keyboard.press('Shift+Tab')
      // Before the note come the new words (job 19-redesign), so the control before it is a word chip
      // or a play button; what matters is that it is not one of the note's own.
      expect(await focusedName(page)).not.toMatch(
        new RegExp(`^(${copy.SAVE_NOTE_ADD}|${copy.SAVE_NOTE_LATER})$`),
      )
      const order: string[] = []
      const outlines: string[] = []
      for (let i = 0; i < 4; i += 1) {
        await page.keyboard.press('Tab')
        order.push(await focusedName(page))
        outlines.push(
          await page.evaluate<string>(
            '(() => { const s = getComputedStyle(document.activeElement); return s.outlineStyle + " " + s.outlineWidth })()',
          ),
        )
      }
      expect(order).toEqual([copy.SAVE_NOTE_ADD, copy.SAVE_NOTE_LATER, 'Send feedback', 'Done'])
      expect(outlines).toEqual(['solid 3px', 'solid 3px', 'solid 3px', 'solid 3px'])
    }

    for (const scheme of ['light', 'dark'] as const) {
      await page.emulateMedia({ colorScheme: scheme })
      await axe(page, `finish screen with the note, ${scheme}`)
    }

    // Reduced motion: the page is identical.
    await page.emulateMedia({ colorScheme: 'light', reducedMotion: 'no-preference' })
    const normal = { text: normalise(await note.innerText()), box: await note.boundingBox() }
    await page.emulateMedia({ reducedMotion: 'reduce' })
    expect({ text: normalise(await note.innerText()), box: await note.boundingBox() }).toEqual(normal)
    expect((await lookOfTheNote(page)).animations).toBe(0)
    await page.emulateMedia({ reducedMotion: 'no-preference' })

    // After "Not now".
    await later.click()
    await expect(page.getByText(copy.SAVE_NOTE_CLOSED, { exact: true })).toBeFocused()
    for (const scheme of ['dark', 'light'] as const) {
      await page.emulateMedia({ colorScheme: scheme })
      await axe(page, `finish screen after Not now, ${scheme}`)
    }
  })

  test('[save-progress 15] [save-progress 16] the note shows on the design reference page in light and dark', async ({
    page,
  }) => {
    await page.goto('/design-reference')
    await expect(page.getByRole('heading', { level: 1, name: 'Design reference' })).toBeVisible()
    await page.evaluate('document.fonts.ready')
    const reference = page.getByRole('region', { name: 'Save progress note', exact: true })
    for (const scheme of ['light', 'dark'] as const) {
      await page.emulateMedia({ colorScheme: scheme })
      await expect(reference.getByRole('region', { name: copy.SAVE_NOTE_REGION, exact: true })).toBeVisible()
      await expect(reference.getByText(copy.SAVE_NOTE_SENTENCE, { exact: true })).toBeVisible()
      await expect(reference.getByRole('button', { name: copy.SAVE_NOTE_ADD, exact: true })).toBeVisible()
      await expect(reference.getByRole('button', { name: copy.SAVE_NOTE_LATER, exact: true })).toBeVisible()
      await reference.scrollIntoViewIfNeeded()
      await axeIn(page, `design reference, ${scheme}`, 'section[aria-labelledby="save-note"]')
    }
  })

  // Email accounts ---------------------------------------------------------------------------------------------

  test.describe('with email', { tag: '@email' }, () => {
    test('[save-progress 5] [save-progress 12] an account that added its email before its first finished session sees no note, and the answer has no saveNote', async ({
      page,
    }, testInfo) => {
      const answers = recordCompleteAnswers(page)
      const address = testAddress('learner-a', testInfo)
      const userId = await startGuest(page)
      await addEmail(page, address)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      expect(authUser(userId)).toEqual({ exists: true, anonymous: false, email: address })
      await walkContinuedSession(page, userId)
      await expect(page.getByRole('status')).toHaveText(SAVED_PLAIN)
      await expect.poll(() => answers.length).toBe(1)
      // The first finished session of a guest gets "first". The database sees a token that is not a guest's.
      expect(answers[0]).toEqual({ status: 200, body: { saved: true } })
      await expectNoNote(page, 'email account, first session')
    })

    test('[save-progress 5] a guest sees the note on the first session, adds an email, and sees no note on the second', async ({
      page,
    }, testInfo) => {
      const answers = recordCompleteAnswers(page)
      const address = testAddress('learner-a', testInfo)
      const userId = await walkToFinish(page)
      await expect(page.getByRole('status')).toHaveText(SAVED)
      await expect(noteOf(page)).toBeVisible()
      await addEmail(page, address)
      expect(authUser(userId)).toEqual({ exists: true, anonymous: false, email: address })
      await walkNextSession(page, userId)
      await expect(page.getByRole('status')).toHaveText(SAVED_PLAIN)
      await expectNoNote(page, 'email account, second session')
      await expect.poll(() => answers.length).toBe(2)
      expect(answers[0]?.body).toEqual({ saved: true, saveNote: 'first' })
      expect(answers[1]).toEqual({ status: 200, body: { saved: true } })
    })

    test('[save-progress 19] a guest is told the progress is saved on this device, and an account with an email keeps the plain line', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await walkToFinish(page)
      // The owner's choice of 1 November 2026: the guest's line says where the progress is.
      await expect(page.getByRole('status')).toHaveText(copy.SAVED_ON_THIS_DEVICE)
      await expect(page.getByRole('status')).toHaveText('Your progress is saved on this device.')
      await expect(noteOf(page)).toBeVisible()
      await addEmail(page, address)
      expect(authUser(userId)).toEqual({ exists: true, anonymous: false, email: address })
      await walkNextSession(page, userId)
      // The same screen for a learner with an email: exactly the plain line.
      await expect(page.getByRole('status')).toHaveText(SAVED_PLAIN)
      await expect(page.getByRole('status')).not.toContainText('on this device')
      await expectNoNote(page, 'email account, second session')
    })

    test('[save-progress 10] from the note a guest adds their email with a code from Mailpit and keeps the same account', async ({
      page,
    }, testInfo) => {
      const address = testAddress('learner-a', testInfo)
      const userId = await walkToFinish(page)
      await expect(page.getByRole('status')).toHaveText(SAVED)
      await noteOf(page).getByRole('button', { name: copy.SAVE_NOTE_ADD, exact: true }).click()
      await page.waitForURL((url) => url.pathname.endsWith(copy.ADD_EMAIL_PATH))
      await expect(page.getByRole('heading', { name: 'Create your account', exact: true })).toBeVisible()
      const { sendsCode, takenWarning } = emailScreenSentences()
      await expect(page.getByText(sendsCode, { exact: true })).toBeVisible()
      await expect(page.getByText(takenWarning, { exact: true })).toBeVisible()
      await sendCodeTo(page, address)
      const mail = await nextMail(address)
      await confirmCode(page, mail.code)
      await expect(page.getByRole('status')).toHaveText(
        'Your email is added. Your progress is saved to your account.',
      )
      expect(authUser(userId)).toEqual({ exists: true, anonymous: false, email: address })
      expect(await userIdOf(page.context())).toBe(userId)
    })

    test('[save-progress 8] one reminder at the third finished session, with the same words, and none after it', async ({
      page,
    }) => {
      const answers = recordCompleteAnswers(page)
      const userId = await startGuest(page)
      giveTwoEarlierFinishedSessions(userId)
      await walkFromHearIt(page, userId)
      await expect(page.getByRole('status')).toHaveText(SAVED)
      const note = noteOf(page)
      await expect(note).toBeVisible()
      expect(normalise(await note.innerText())).toBe(
        `${copy.SAVE_NOTE_SENTENCE} ${copy.SAVE_NOTE_ADD} ${copy.SAVE_NOTE_LATER}`,
      )
      await expect.poll(() => answers.length).toBe(1)
      expect(answers[0]).toEqual({ status: 200, body: { saved: true, saveNote: 'reminder' } })
      await page.getByRole('button', { name: 'Done', exact: true }).click()
      await page.waitForURL((url) => url.pathname === PATHS.home)
      await walkNextSession(page, userId)
      await expect(page.getByRole('status')).toHaveText(SAVED)
      await expectNoNote(page, 'fourth session')
      await expect.poll(() => answers.length).toBe(2)
      expect(answers[1]).toEqual({ status: 200, body: { saved: true } })
    })
  })
})
