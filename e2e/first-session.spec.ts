import { AxeBuilder } from '@axe-core/playwright'
import { type Page } from '@playwright/test'
import { expect, test } from './test-base.ts'
import { recordApiTimings } from './api-timing.ts'
import {
  approvedFormsOf,
  firstWordWithForm,
  linesOf,
  one,
  sessionsOf,
  sql,
  todaysDialogue,
  userIdOf,
  type DbLine,
} from './db.ts'
import {
  afterNext,
  answerChoices,
  dismissTip,
  finishHearIt,
  finishUnderstandIt,
  passSayIt,
  isGuestPost,
  isTurnstileScript,
  leaveLesson,
  questionLineId,
  finishLineId,
  recordRequests,
  scrollsSideways,
  serveTone,
  settleAnimations,
  startSession,
  tabTo,
  declineConsent,
} from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
//
// Phone size (375 x 812) in Chromium and WebKit, against the built app and the
// throwaway local Supabase of the pull request check (job 6-pr-local-db), with
// the test fixture unit from supabase/seeds/browser/ loaded. Every test here is
// tagged @seed, so it never runs against the shared test project. Expected
// content is read from the database, so these also pass when job 7's real
// dialogue comes first. Audio requests are answered with a generated tone.
//
// Job 10-speaking-feedback ("Done when" 5) put Say it between Understand it
// and the finish screen. The tests that name the step count or the resume
// point, or walk to the finish screen, were updated for the new list with
// their labels kept; each changed line is listed in that job's build.md.

function firstOf(lines: DbLine[]): DbLine {
  const line = lines[0]
  if (!line) throw new Error('The dialogue has no approved line.')
  return line
}

test.describe('the first session', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }, testInfo) => {
    recordApiTimings(page, testInfo)
    await serveTone(page)
  })

  async function startAndLoad(page: Page, options: { consent?: 'not now' | 'open' } = {}) {
    await startSession(page, options)
    const userId = await userIdOf(page.context())
    const dialogueId = sessionsOf(userId)[0]?.dialogueId ?? ''
    const lines = linesOf(dialogueId)
    const glossOf = (lineId: string) => lines.find((line) => line.id === lineId)?.gloss ?? ''
    return { userId, dialogueId, lines, glossOf }
  }

  test(
    '[session 1] [session 2] Start makes exactly one guest, and Start again, a reload or a new tab makes no second one',
    { tag: '@smoke' },
    async ({ page, context }) => {
      const requests = recordRequests(page)
      // Since the turnstile job (owner's choice of 3 November 2026) Start first asks without a token and
      // is answered 403 check_needed; after Cloudflare's check (e2e/road-route.ts) it asks again and the
      // guest is made.
      const guestAnswers: number[] = []
      page.on('response', (res) => {
        if (isGuestPost(res.request())) guestAnswers.push(res.status())
      })
      await page.goto('/learn')
      await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
      expect(requests.filter(isGuestPost)).toHaveLength(0)

      const answer = page.waitForResponse((res) => isGuestPost(res.request()) && res.status() !== 403)
      await page.getByRole('button', { name: 'Start', exact: true }).click()
      // The page leaves for /session at once, so only the status is read here;
      // the answer body (no token, no user id) is checked by the unit tests and
      // by the second Start below.
      expect((await answer).status()).toBe(201)
      await page.waitForURL('**/session')

      const userId = await userIdOf(context)
      expect(one(`select count(*) from auth.users where id = :'uid' and is_anonymous`, { uid: userId })).toBe(
        '1',
      )

      const cookies = (await context.cookies()).filter((c) => c.name.startsWith('puhuscribe-auth'))
      expect(cookies.length).toBeGreaterThan(0)
      const host = new URL(page.url()).hostname
      for (const cookie of cookies) {
        expect(cookie.httpOnly).toBe(true)
        expect(cookie.secure).toBe(true)
        expect(cookie.sameSite).toBe('Lax')
        expect(cookie.path).toBe('/')
        // A host-only cookie: no Domain attribute was sent.
        expect(cookie.domain).toBe(host)
        const days = (cookie.expires - Date.now() / 1000) / (24 * 60 * 60)
        expect(days).toBeGreaterThan(89)
        expect(days).toBeLessThanOrEqual(90)
      }

      await page.reload()
      await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
      const second = await context.newPage()
      await second.goto('/learn')
      await expect(second.getByRole('button', { name: 'Continue', exact: true })).toBeVisible()
      const again = await page.request.post('/api/guest', {
        headers: { 'content-type': 'application/json' },
        data: {},
      })
      expect(again.status()).toBe(200)
      expect(await again.json()).toEqual({ guest: 'existing' })
      expect(await userIdOf(context)).toBe(userId)
      expect(requests.filter(isGuestPost)).toHaveLength(2)
      expect(guestAnswers).toEqual([403, 201])
    },
  )

  test('[session 3] [session 7] every request stays on the page address, the browser holds no token, and no draft content appears', async ({
    page,
  }) => {
    const requests = recordRequests(page)
    const answers: string[] = []
    page.on('response', (res) => {
      // A body can be gone when the page has already moved on; those are skipped.
      if (new URL(res.url()).pathname.startsWith('/api/'))
        void res.text().then(
          (text) => answers.push(text),
          () => undefined,
        )
    })
    const storage = async () =>
      page.evaluate<string>(
        'document.cookie + "|" + JSON.stringify(Object.assign({}, localStorage)) + "|" + JSON.stringify(Object.assign({}, sessionStorage))',
      )
    const seen: string[] = [await page.goto('/learn').then(storage)]

    const { glossOf } = await startAndLoad(page)
    seen.push(await storage())
    await page.getByRole('button', { name: 'Play the spoken line' }).first().click()
    await finishHearIt(page)
    seen.push(await storage())
    await finishUnderstandIt(page, glossOf)
    await passSayIt(page)
    await expect(page.getByRole('status')).toHaveText('Your progress is saved on this device.')
    seen.push(await storage())
    await page.waitForLoadState('networkidle')

    const origin = new URL(page.url()).origin
    expect(requests.length).toBeGreaterThan(5)
    // Cloudflare Turnstile's script for the new guest's Start is the one outside request (job turnstile).
    for (const request of requests.filter((r) => !isTurnstileScript(r.url()))) {
      expect(new URL(request.url()).origin, request.url()).toBe(origin)
      expect(new URL(request.url()).hostname, request.url()).not.toMatch(/supabase\.co$/)
    }
    for (const text of seen) {
      expect(text).not.toMatch(/puhuscribe-auth|sb-|access_token|refresh_token|eyJ/)
    }

    const drafts = [
      ...sql(`select title_en from public.dialogues where status <> 'approved'`),
      ...sql(
        `select coalesce(gloss_en, ''), coalesce(text_puhe, '') from public.dialogue_lines where status <> 'approved'`,
      ),
      ...sql(
        `select coalesce(form_name_en, ''), coalesce(why_en, '') from public.forms where status <> 'approved'`,
      ),
    ]
      .flat()
      .filter((text) => text.length > 0)
    expect(drafts.length).toBeGreaterThan(0)
    const everything = answers.join('\n') + (await page.content())
    for (const text of drafts) {
      // A draft line may share its Finnish with an approved line, so only
      // text unique to drafts is checked.
      const alsoApproved = one(
        `select count(*) from public.dialogue_lines where status = 'approved' and (text_puhe = :'t' or text_kirja = :'t' or gloss_en = :'t')`,
        { t: text },
      )
      if (alsoApproved === '0') expect(everything, text).not.toContain(text)
    }
  })

  // Redrawn in job 19-redesign (statements 21 to 24): one line card at a time, no labels, the bar named
  // by its step, no unit goal on this screen.
  test(
    '[session 9] [redesign 24] Hear it shows the lines one at a time, spoken first and written, and Continue stores hear',
    { tag: '@smoke' },
    async ({ page }) => {
      const { userId, lines } = await startAndLoad(page)
      const shown = page.locator('[data-line-id]')
      await expect(page.getByRole('progressbar', { name: 'Hear it, say it, step 1 of 3' })).toBeVisible()
      await expect(page.getByText(/^Unit goal\./)).toHaveCount(0)
      for (let i = 0; i < lines.length; i += 1) {
        const line = firstOf(lines.slice(i))
        await expect(shown).toHaveCount(1)
        // The status line says which line of how many, so each new line is announced.
        await expect(page.getByRole('status')).toHaveText(`Line ${String(i + 1)} of ${String(lines.length)}.`)
        const card = shown.first()
        await expect(card.getByText(line.speaker, { exact: true }).first()).toBeVisible()
        await expect(
          card.getByText(`Line ${String(i + 1)} of ${String(lines.length)}`, { exact: true }),
        ).toBeVisible()
        const finnish = card.locator('[lang="fi"]')
        await expect(finnish.nth(0)).toHaveText(line.puhe.replace(/\s+/g, ' '))
        await expect(finnish.nth(1)).toHaveText(line.kirja.replace(/\s+/g, ' '))
        await expect(card.getByText('Written', { exact: true })).toHaveCount(0)
        await expect(card.getByText(line.gloss, { exact: true })).toBeVisible()
        const button = page.getByRole('button', { name: i === lines.length - 1 ? 'Continue' : 'Next line' })
        await expect(button).toBeVisible()
        if (i < lines.length - 1) await button.click()
      }
      expect(sessionsOf(userId)[0]?.step).toBe('')
      await page.getByRole('button', { name: 'Continue' }).click()
      await expect(page.getByRole('progressbar', { name: 'Understand it, step 2 of 3' })).toBeVisible()
      expect(sessionsOf(userId)[0]?.step).toBe('hear')
    },
  )

  test('[session 9] [redesign 2] changed words are peach on a peach wash, and the old hint line is gone', async ({
    page,
  }) => {
    const { dialogueId } = await startAndLoad(page)
    const changed = one(
      `select count(*) from public.dialogue_lines l join public.tokens t on t.line_id = l.id
         join public.forms f on f.id = t.form_id
        where l.dialogue_id = :did and f.status = 'approved' and f.surface_puhe <> f.surface_kirja`,
      { did: dialogueId },
    )
    test.skip(changed === '0', 'This dialogue has no changed words')
    let peach = 0
    for (;;) {
      peach += await page.locator('[lang="fi"] button span[class*="changed"]').count()
      const next = page.getByRole('button', { name: 'Next line' })
      if ((await next.count()) === 0) break
      await next.click()
    }
    await expect(page.getByText('Blue words change', { exact: false })).toHaveCount(0)
    expect(peach).toBeGreaterThan(0)
  })

  async function finishHearItLines(page: Page) {
    await dismissTip(page)
    for (;;) {
      const next = page.getByRole('button', { name: 'Next line' })
      if ((await next.count()) === 0) return
      await next.click()
    }
  }

  test('[session 10] audio plays only when pressed, from /audio/<key>, and the playing line is marked in words', async ({
    page,
  }) => {
    await page.unrouteAll()
    const asked = await serveTone(page, 1.5)
    const { lines } = await startAndLoad(page)
    await page.waitForLoadState('networkidle')
    expect(asked).toEqual([])

    const first = firstOf(lines)
    const keys = sql(`select audio_puhe_key, audio_kirja_key from public.dialogue_lines where id = :lid`, {
      lid: first.id,
    })[0] ?? ['', '']
    const card = page.locator('[data-line-id]').first()
    const spoken = card.getByRole('button', { name: 'Play the spoken line' })
    await expect(spoken).toHaveAttribute('data-state', 'ready')
    await spoken.click()
    await expect(card.getByRole('button', { name: 'Pause the spoken line' })).toBeVisible()
    await expect(card.getByText('Playing', { exact: true })).toBeVisible()
    expect(asked).toEqual([`/audio/${keys[0] ?? ''}`])
    await card.getByRole('button', { name: 'Pause the spoken line' }).click()
    await expect(card.getByText('Playing', { exact: true })).toHaveCount(0)

    await card.getByRole('button', { name: 'Play the written line' }).click()
    await expect(card.getByRole('button', { name: 'Pause the written line' })).toBeVisible()
    expect(asked).toContain(`/audio/${keys[1] ?? ''}`)
  })

  test('[session 10] a file that is not found shows "Could not play." with "Try again"', async ({ page }) => {
    await page.unrouteAll()
    await page.route('**/audio/**', (route) => route.fulfill({ status: 404, body: '' }))
    await startAndLoad(page)
    const card = page.locator('[data-line-id]').first()
    await card.getByRole('button', { name: 'Play the spoken line' }).click()
    await expect(card.getByText('Could not play.', { exact: true })).toBeVisible()
    await expect(card.getByRole('button', { name: 'Try again: play the spoken line' })).toBeVisible()
  })

  test('[session 10] the loading state shows while the file is on its way', async ({ page }) => {
    await page.unrouteAll()
    let release: () => void = () => undefined
    const held = new Promise<void>((resolve) => {
      release = resolve
    })
    const body = (await import('./session-helpers.ts')).tone(1)
    await page.route('**/audio/**', async (route) => {
      await held
      await route.fulfill({ status: 200, contentType: 'audio/wav', body })
    })
    await startAndLoad(page)
    const card = page.locator('[data-line-id]').first()
    await card.getByRole('button', { name: 'Play the spoken line' }).click()
    await expect(card.getByRole('button', { name: 'Loading the spoken line' })).toBeVisible()
    release()
    await expect(card.getByRole('button', { name: 'Pause the spoken line' })).toBeVisible()
  })

  test(
    '[session 12] tapping a spoken and a written word opens its card with every field from the database',
    { tag: '@smoke' },
    async ({ page }) => {
      const { lines } = await startAndLoad(page)
      const first = firstOf(lines)
      const card = page.locator('[data-line-id]').first()
      for (const register of ['puhe', 'kirja'] as const) {
        const word = firstWordWithForm(first.id, register)
        expect(word).not.toBeNull()
        if (!word) return
        const band = card.locator('[lang="fi"]').nth(register === 'puhe' ? 0 : 1)
        const button = band.getByRole('button', { name: word.surface, exact: true }).first()
        await button.click()
        const dialog = page.getByRole('dialog', { name: word.surface })
        await expect(dialog).toBeVisible()
        await expect(dialog.getByRole('heading', { name: word.surface })).toBeFocused()
        // The facts of the redesigned card (job 19-redesign, statement 26): both registers and the
        // dictionary form first, the form name and the reason behind "Why does it change?".
        for (const text of [word.lemma, word.puhe, word.kirja]) {
          await expect(dialog.getByText(text, { exact: true }).first()).toBeVisible()
        }
        await dialog.getByRole('button', { name: 'Why does it change?' }).click()
        for (const text of [word.formName, word.why]) {
          await expect(dialog.getByText(text).first()).toBeVisible()
        }
        // Job word-audio: when a word has its own clip, the tiles play the word and one more control plays the
        // whole line. These tests answer every /audio/ request with the tone (serveTone), so every word has a
        // clip here; the card without a clip, with its hidden caption, is tested in e2e/redesign-lesson.spec.ts.
        await expect(dialog.getByRole('button', { name: 'Play the spoken word' })).toBeVisible()
        await expect(dialog.getByRole('button', { name: 'Play the written word' })).toBeVisible()
        await expect(dialog.getByRole('button', { name: 'Play the whole line' })).toBeVisible()
        await page.keyboard.press('Escape')
        await expect(dialog).toBeHidden()
        await expect(button).toBeFocused()
      }
    },
  )

  test('[session 12] a word with no readable form is plain text, not a button', async ({ page }) => {
    const { dialogueId } = await startAndLoad(page)
    let checked = 0
    for (;;) {
      const lineId = await finishLineId(page)
      const plain = sql(
        `select t.surface from public.dialogue_lines l join public.tokens t on t.line_id = l.id
           left join public.forms f on f.id = t.form_id and f.status = 'approved'
          where l.dialogue_id = :did and l.id = :lid and l.status = 'approved' and f.id is null
            and not exists (select 1 from public.tokens o join public.forms g on g.id = o.form_id
                             where o.line_id = t.line_id and o.surface = t.surface and g.status = 'approved')`,
        { did: dialogueId, lid: lineId },
      ).map((row) => row[0] ?? '')
      const card = page.locator('[data-line-id]').first()
      for (const surface of plain) {
        await expect(card.getByText(surface, { exact: true }).first()).toBeVisible()
        await expect(card.getByRole('button', { name: surface, exact: true })).toHaveCount(0)
        checked += 1
      }
      const next = page.getByRole('button', { name: 'Next line' })
      if ((await next.count()) === 0) break
      await next.click()
    }
    test.skip(checked === 0, 'Every word of this dialogue has a readable form')
  })

  test(
    '[session 13] Understand it: a wrong answer is gently refused and unavailable, a right one says so, the order survives a reload, and nothing is stored',
    { tag: '@smoke' },
    async ({ page }) => {
      const { userId, glossOf } = await startAndLoad(page)
      await finishHearIt(page)
      const choices = async () => answerChoices(page).getByRole('button').allTextContents()
      const before = { line: await questionLineId(page), choices: await choices() }
      await page.reload()
      await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeVisible()
      expect({ line: await questionLineId(page), choices: await choices() }).toEqual(before)

      const right = glossOf(before.line)
      const wrong = before.choices.find((choice) => choice !== right)
      expect(before.choices).toContain(right)
      expect(before.choices.length).toBeLessThanOrEqual(3)
      if (wrong) {
        const wrongButton = answerChoices(page).getByRole('button', { name: wrong })
        await wrongButton.click()
        const status = page.getByRole('status')
        await expect(status).toHaveText('Not this one. Listen again and try another.')
        await expect(status).toHaveAttribute('data-tone', 'gentle')
        await expect(wrongButton).toHaveAttribute('aria-disabled', 'true')
        await wrongButton.click({ force: true })
        await expect(status).toHaveText('Not this one. Listen again and try another.')
        // The bottom pill is unavailable until the answer is right (job 19-redesign, statement 28).
        await expect(page.getByRole('button', { name: 'Next', exact: true })).toBeDisabled()
        // Never red, never a score.
        const colour = await status.evaluate('(element) => getComputedStyle(element).backgroundColor')
        expect(String(colour)).not.toMatch(/rgb\(2[0-5]\d, [0-6]?\d, [0-6]?\d\)/)
        await expect(page.getByText(/score|mistake|\d+ (of|\/) \d+ (right|correct)/i)).toHaveCount(0)
      }
      await answerChoices(page).getByRole('button', { name: right, exact: true }).click()
      await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
      await expect(page.getByRole('button', { name: 'Next', exact: true })).toBeEnabled()
      expect(sessionsOf(userId)[0]?.step).toBe('hear')

      // The rest of the questions, then the step is stored.
      await page.getByRole('button', { name: 'Next', exact: true }).click()
      // The Recap (once Say it, fast route hear-and-say) may open under its consent sheet after the reload.
      const done = page.getByRole('heading', { level: 1, name: 'Recap' })
      if ((await afterNext(page, before.line)) === 'question') await finishUnderstandIt(page, glossOf)
      await expect(done).toBeAttached()
      expect(sessionsOf(userId)[0]?.step).toBe('understand')
      // Nothing about the answers is stored anywhere: no learner table has a column for them.
      expect(
        one(
          `select count(*) from information_schema.columns where table_schema = 'public'
           and table_name in ('sessions', 'cards', 'review_logs', 'consents', 'usage_events')
           and column_name ~ '(answer|choice|correct|score|mistake)'`,
        ),
      ).toBe('0')
    },
  )

  test(
    '[session 14] [session 15] [session 16] the finish screen gives one sentence, and the end is saved once with cards and one event',
    { tag: '@smoke' },
    async ({ page }) => {
      const { userId, dialogueId, lines, glossOf } = await startAndLoad(page)
      await finishHearIt(page)
      await finishUnderstandIt(page, glossOf)
      await passSayIt(page)
      // Round 6 (job 19-redesign): no top bar on the finish screen; the full bar is for screen readers.
      await expect(page.getByRole('progressbar', { name: 'Session finished' })).toBeAttached()
      await expect(page.getByRole('status')).toHaveText('Your progress is saved on this device.')
      // The old line "The words you met will come back in your review." is not on the redrawn screen.
      await expect(page.getByText('The words you met will come back in your review.')).toHaveCount(0)
      const shownId = await finishLineId(page)
      const shown = lines.find((line) => line.id === shownId)
      expect(shown).toBeDefined()
      await expect(page.getByText(shown?.gloss ?? '', { exact: true })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Play the written line' })).toBeVisible()
      await expect(page.getByText(/streak|badge|score|points|congratulations/i)).toHaveCount(0)

      const [row] = sessionsOf(userId)
      expect(row?.step).toBe('say')
      expect(row?.ended).toBe(true)
      expect(sessionsOf(userId)).toHaveLength(1)
      const forms = approvedFormsOf(dialogueId)
      expect(forms).toBeGreaterThan(0)
      expect(one(`select count(*) from public.cards where user_id = :'uid'`, { uid: userId })).toBe(
        String(forms),
      )
      expect(
        one(
          `select count(*) from public.cards c where c.user_id = :'uid' and not exists (
           select 1 from public.dialogue_lines l join public.tokens t on t.line_id = l.id
            where l.dialogue_id = :did and t.form_id = c.form_id)`,
          { uid: userId, did: dialogueId },
        ),
      ).toBe('0')
      expect(
        one(
          `select count(*) from public.usage_events where user_id = :'uid' and name = 'first_session_completed'`,
          {
            uid: userId,
          },
        ),
      ).toBe('1')

      await page.getByRole('button', { name: 'Done' }).click()
      await page.waitForURL((url) => url.pathname === '/learn')
      await expect(page.getByRole('heading', { level: 1, name: 'Your road to A1' })).toBeAttached()
    },
  )

  test('[session 9] [session 22] a word and its punctuation never wrap apart, at 375 and 320 px', async ({
    page,
  }) => {
    await startAndLoad(page)
    await finishHearItLines(page)
    for (const width of [375, 320]) {
      await page.setViewportSize({ width, height: 812 })
      // Every word with its punctuation is one span that must sit on one line.
      const split = await page.evaluate<string[]>(
        'Array.from(document.querySelectorAll("[lang=fi] [data-word]")).filter((el) => el.getClientRects().length > 1).map((el) => el.textContent)',
      )
      expect(split, `at ${String(width)} px`).toEqual([])
      const questions = await page.evaluate<number>(
        'Array.from(document.querySelectorAll("[lang=fi] [data-word]")).filter((el) => /[?,]$/.test(el.textContent || "")).length',
      )
      expect(questions).toBeGreaterThan(0)
    }
  })

  test('[session 13] [session 22] the answer rows stay in view on a short phone, also after a wrong answer', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 667 })
    const { glossOf } = await startAndLoad(page)
    await finishHearIt(page)
    const inView = async (label: string) => {
      const status = await page.getByRole('status').boundingBox()
      for (const row of await answerChoices(page).getByRole('button').all()) {
        const box = await row.boundingBox()
        expect(box, label).not.toBeNull()
        if (!box || !status) continue
        expect(box.y, `${label}: ${await row.innerText()}`).toBeGreaterThanOrEqual(0)
        expect(box.y + box.height, `${label}: ${await row.innerText()}`).toBeLessThanOrEqual(status.y)
      }
    }
    await inView('when the question opens')
    const right = glossOf(await questionLineId(page))
    const wrong = (await answerChoices(page).getByRole('button').allTextContents()).find((c) => c !== right)
    if (wrong) {
      await answerChoices(page).getByRole('button', { name: wrong }).click()
      await expect(page.getByRole('status')).toHaveText('Not this one. Listen again and try another.')
      await inView('after a wrong answer')
    }
  })

  test('[smoke 3] [session 15] keyboard: Try again on the finish screen moves focus to the status line, which then says it is saved', async ({
    page,
  }, testInfo) => {
    const { glossOf } = await startAndLoad(page)
    let fail = true
    await page.route('**/api/sessions/*/complete', async (route) => {
      if (fail) await route.abort('failed')
      else await route.continue()
    })
    await finishHearIt(page)
    await finishUnderstandIt(page, glossOf)
    await passSayIt(page)
    const status = page.getByRole('status')
    await expect(status).toHaveText(
      'Your progress was not saved. Check your internet connection, then try again.',
    )
    fail = false
    const tryAgain = page.getByRole('button', { name: 'Try again' })
    await tabTo(page, tryAgain, testInfo)
    await page.keyboard.press('Enter')
    await expect(tryAgain).toHaveCount(0)
    await expect(status).toBeFocused()
    await expect(status).toHaveText('Your progress is saved on this device.')
    await expect(status).toBeFocused()
  })

  test('[session 15] when saving fails the screen says so in the problem style, and Try again saves', async ({
    page,
  }) => {
    const { userId, glossOf } = await startAndLoad(page)
    await page.route('**/api/sessions/*/complete', (route) => route.abort('failed'))
    await finishHearIt(page)
    await finishUnderstandIt(page, glossOf)
    await passSayIt(page)
    const status = page.getByRole('status')
    await expect(status).toHaveText(
      'Your progress was not saved. Check your internet connection, then try again.',
    )
    await expect(status).toHaveAttribute('data-tone', 'problem')
    expect(sessionsOf(userId)[0]?.ended).toBe(false)
    await page.unroute('**/api/sessions/*/complete')
    await page.getByRole('button', { name: 'Try again' }).click()
    await expect(status).toHaveText('Your progress is saved on this device.')
    expect(sessionsOf(userId)[0]?.ended).toBe(true)
    expect(one(`select count(*) from public.usage_events where user_id = :'uid'`, { uid: userId })).toBe('1')
  })

  test('[session 18] Leave session and Continue resume the same session at each step', async ({ page }) => {
    const { userId, glossOf } = await startAndLoad(page)
    const leave = async () => {
      await leaveLesson(page)
      await page.waitForURL((url) => url.pathname === '/learn')
      await page.getByRole('button', { name: 'Continue', exact: true }).click()
      await page.waitForURL('**/session')
    }
    await leave()
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
    await finishHearIt(page)
    await leave()
    await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeVisible()
    await page.route('**/api/sessions/*/complete', (route) => route.abort('failed'))
    await finishUnderstandIt(page, glossOf)
    await leave()
    // The Recap (once Say it); after a fresh load its consent sheet may cover it.
    await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeAttached()
    expect(sessionsOf(userId)[0]?.step).toBe('understand')
    await passSayIt(page)
    await leave()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    const rows = sessionsOf(userId)
    expect(rows).toHaveLength(1)
    expect(rows[0]?.step).toBe('say')
    expect(rows[0]?.ended).toBe(false)
  })

  test('[session 4] when the guest is deleted, the front door says the session ended and Start begins again', async ({
    page,
    context,
  }) => {
    const { userId } = await startAndLoad(page)
    sql(`delete from auth.users where id = :'uid'`, { uid: userId })
    await page.goto('/learn')
    await expect(page.getByRole('status')).toHaveText(
      'Your guest session ended on this device. Press Start to begin again.',
    )
    expect((await context.cookies()).filter((c) => c.name.startsWith('puhuscribe-auth'))).toEqual([])
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
    expect(await userIdOf(context)).not.toBe(userId)
  })

  test('[session 5] a post from another site is refused and saves nothing', async ({ page }) => {
    const { userId } = await startAndLoad(page)
    const sessionId = sessionsOf(userId)[0]?.id ?? ''
    const evil = { 'content-type': 'application/json', origin: 'https://evil.example' }
    for (const [path, data] of [
      ['/api/guest', {}],
      ['/api/sessions/today', {}],
      [`/api/sessions/${sessionId}/step`, { step: 'hear' }],
      [`/api/sessions/${sessionId}/complete`, {}],
    ] as const) {
      const res = await page.request.post(path, { headers: evil, data })
      expect(res.status(), path).toBe(403)
      expect(res.headers()['access-control-allow-origin']).toBeUndefined()
    }
    const form = await page.request.post(`/api/sessions/${sessionId}/step`, { form: { step: 'hear' } })
    expect(form.status()).toBe(415)
    const rows = sessionsOf(userId)
    expect(rows).toHaveLength(1)
    expect(rows[0]?.step).toBe('')
    expect(one(`select count(*) from public.usage_events where user_id = :'uid'`, { uid: userId })).toBe('0')
  })

  test('[session 6] after every readable dialogue is finished, the front door says so', async ({ page }) => {
    const { userId } = await startAndLoad(page)
    sql(
      `insert into public.sessions (user_id, dialogue_id, step_reached, started_at, ended_at)
       select :'uid', d.id, 'understand', now(), now() from public.dialogues d join public.units u on u.id = d.unit_id
        where d.status = 'approved' and u.status = 'approved'`,
      { uid: userId },
    )
    expect(todaysDialogue(userId)).toBe('')
    await page.goto('/learn')
    await expect(page.getByRole('status')).toHaveText('You have finished every dialogue that is ready.')
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toHaveCount(0)
  })

  test('[session 22] every screen fits 320 px and 200 percent text without sideways scrolling, with large enough tap areas', async ({
    page,
  }) => {
    // Fast route hear-and-say: the consent sheet now opens in the first step, before the first line is said.
    const { glossOf } = await startAndLoad(page, { consent: 'open' })
    const check = async (label: string) => {
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
      for (const button of await page.getByRole('button').all()) {
        if (!(await button.isVisible())) continue
        const box = await button.boundingBox()
        const inLine = (await button.locator('xpath=ancestor::*[@lang="fi"]').count()) > 0
        expect(box?.height ?? 0, `${label}: ${await button.innerText()}`).toBeGreaterThanOrEqual(44)
        expect(box?.width ?? 0, `${label}: ${await button.innerText()}`).toBeGreaterThanOrEqual(
          inLine ? 24 : 44,
        )
      }
    }
    await expect(page.getByRole('button', { name: 'Not now', exact: true })).toBeVisible()
    await check('Hear it, say it, consent')
    await declineConsent(page)
    await check('Hear it, say it')
    await finishHearIt(page)
    await check('Understand it')
    await finishUnderstandIt(page, glossOf)
    await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeVisible()
    await check('Recap')
    await passSayIt(page)
    await check('Finish')
  })

  test('[session 22] the whole flow works with the keyboard alone', async ({ page }, testInfo) => {
    // Fast route hear-and-say: the consent sheet opens in the first step; "Not now" by keyboard first.
    const { glossOf } = await startAndLoad(page, { consent: 'open' })
    await expect(page.getByRole('button', { name: 'Not now', exact: true })).toBeVisible()
    await tabTo(page, page.getByRole('button', { name: 'Not now', exact: true }), testInfo)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('dialog', { name: 'Say it out loud' })).toBeHidden()
    for (;;) {
      const next = page.getByRole('button', { name: 'Next line' })
      if ((await next.count()) === 0) break
      await tabTo(page, next, testInfo)
      await page.keyboard.press('Enter')
    }
    // A word card opens and closes from the keyboard.
    const word = page.locator('[data-line-id] [lang="fi"] button').first()
    await tabTo(page, word, testInfo)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('dialog')).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(word).toBeFocused()
    await tabTo(page, page.getByRole('button', { name: 'Continue' }), testInfo)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('heading', { level: 1, name: 'Understand it' })).toBeVisible()
    for (;;) {
      const lineId = await questionLineId(page)
      const right = answerChoices(page).getByRole('button', { name: glossOf(lineId), exact: true })
      await tabTo(page, right, testInfo)
      await page.keyboard.press('Enter')
      const next = page.getByRole('button', { name: 'Next', exact: true })
      await expect(next).toBeFocused()
      await page.keyboard.press('Enter')
      if ((await afterNext(page, lineId)) === 'done') break
      await expect(page.getByRole('heading', { level: 2, name: 'What does this mean?' })).toBeFocused()
    }
    // The Recap (once Say it) does not ask again after "Not now" in the same lesson.
    await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeVisible()
    for (;;) {
      const cont = page.getByRole('button', { name: 'Continue', exact: true })
      const last = await cont.isVisible()
      await tabTo(page, last ? cont : page.getByRole('button', { name: 'Next line', exact: true }), testInfo)
      await page.keyboard.press('Enter')
      if (last) break
    }
    await tabTo(page, page.getByRole('button', { name: 'Done' }), testInfo)
    await page.keyboard.press('Enter')
    await page.waitForURL((url) => url.pathname === '/learn')
  })

  test('[session 22] keyboard focus follows reading order on Hear it', async ({ page }, testInfo) => {
    test.skip(
      testInfo.project.name === 'webkit',
      'WebKit skips buttons on Tab unless a system setting allows it',
    )
    await startAndLoad(page)
    const order: string[] = []
    for (let i = 0; i < 30; i += 1) {
      await page.keyboard.press('Tab')
      order.push(
        await page.evaluate<string>(
          '(document.activeElement?.getAttribute("aria-label") || document.activeElement?.textContent || "").trim()',
        ),
      )
    }
    // Focus may start inside the screen ("Not now" gives it back to the line's action), so the order is read
    // from the first time Tab reaches the cross: then the line's play button, then its action.
    const leave = order.indexOf('Leave session')
    const play = order.indexOf('Play the spoken line', leave)
    const next = order.findIndex((name, i) => i > play && (name === 'Next line' || name === 'Continue'))
    expect(leave).toBeGreaterThanOrEqual(0)
    expect(play).toBeGreaterThan(leave)
    expect(next).toBeGreaterThan(play)
  })

  for (const scheme of ['light', 'dark'] as const) {
    test(`[session 22] axe finds no WCAG A or AA problem on any screen, ${scheme}`, async ({ page }) => {
      await page.emulateMedia({ colorScheme: scheme })
      const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']
      const scan = async (label: string) => {
        await page.evaluate('document.fonts.ready')
        // The road's opening is a crossfade at reduced motion: measure the finished colours.
        await settleAnimations(page)
        const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
        expect(
          result.violations.map(
            (v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`,
          ),
        ).toEqual([])
      }
      await page.goto('/learn')
      await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
      await scan('front door')
      // Fast route hear-and-say: the consent sheet opens in the first step.
      const { glossOf } = await startAndLoad(page, { consent: 'open' })
      await expect(page.getByRole('button', { name: 'Not now', exact: true })).toBeVisible()
      await scan('Hear it, say it, consent')
      await declineConsent(page)
      await scan('Hear it, say it')
      await page.locator('[data-line-id] [lang="fi"] button').first().click()
      await expect(page.getByRole('dialog')).toBeVisible()
      await page.waitForTimeout(400)
      await scan('word card')
      await page.keyboard.press('Escape')
      await finishHearIt(page)
      await scan('Understand it')
      const firstLine = await questionLineId(page)
      const right = glossOf(firstLine)
      const wrong = (await answerChoices(page).getByRole('button').allTextContents()).find((c) => c !== right)
      if (wrong) {
        await answerChoices(page).getByRole('button', { name: wrong }).click()
        await scan('Understand it, after a wrong answer')
      }
      await answerChoices(page).getByRole('button', { name: right, exact: true }).click()
      await scan('Understand it, after the right answer')
      await page.getByRole('button', { name: 'Next', exact: true }).click()
      if ((await afterNext(page, firstLine)) === 'question') await finishUnderstandIt(page, glossOf)
      await expect(page.getByRole('heading', { level: 1, name: 'Recap' })).toBeVisible()
      await scan('Recap')
      await passSayIt(page)
      await expect(page.getByRole('status')).toHaveText('Your progress is saved on this device.')
      await scan('finish')
      await page.goto('/learn')
      await expect(
        page
          .getByRole('button', { name: 'Continue', exact: true })
          .or(page.getByRole('button', { name: 'Start', exact: true })),
      ).toBeVisible()
      await scan('front door, signed in')
    })
  }
})

// Statement 6 with an empty content database. The pull request check runs
// this file a second time with PUHUSCRIBE_EMPTY_CONTENT=1 after setting every
// unit back to draft in its throwaway database; the test first proves that
// nothing is readable, so it cannot pass for the wrong reason.
test.describe('with no readable dialogue', { tag: ['@seed', '@empty-content'] }, () => {
  test.skip(process.env.PUHUSCRIBE_EMPTY_CONTENT !== '1', 'Runs only in the empty content pass')

  test('[session 6] the session screen says it is not ready yet and shows no Finnish', async ({ page }) => {
    expect(
      one(`select count(*) from public.dialogues d join public.units u on u.id = d.unit_id
            where d.status = 'approved' and u.status = 'approved'`),
    ).toBe('0')
    await page.goto('/learn')
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.getByRole('status')).toHaveText(
      "Today's session is not ready yet. Please come back later.",
    )
    await expect(page.locator('[lang="fi"]')).toHaveCount(0)
    const userId = await userIdOf(page.context())
    expect(sessionsOf(userId)).toEqual([])
    await page.goto('/learn')
    await expect(page.getByRole('status')).toHaveText(
      "Today's session is not ready yet. Please come back later.",
    )
  })
})
