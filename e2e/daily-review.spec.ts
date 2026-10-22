import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { recordApiTimings } from './api-timing.ts'
import { one, sessionsOf, sql } from './db.ts'
import {
  FIELD,
  answerItem,
  cardOf,
  dayLater,
  engineCard,
  finishEveryOtherDialogue,
  finishFirstSession,
  itemFormId,
  logCount,
  logsOf,
  nextItem,
  onItem,
  runKeepIt,
  shapesOf,
  throughUnderstandIt,
  typeAnswer,
} from './review-helpers.ts'
import { scrollsSideways, serveTone, tabTo } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
//
// Phone size (375 x 812) in Chromium and WebKit, against the built app and the
// throwaway local Supabase of the pull request check, with job 8's test
// fixture unit loaded from supabase/seeds/browser/ (unchanged). Every test is
// tagged @seed, so it never runs against the shared test project. Expected
// content is read from the database. "A day later" moves this learner's card
// times back 24 hours in the local database (e2e/review-helpers.ts).

const ENDS_WITH_REVIEW = 'It ends with a short review of words you met before.'
const REVIEW_ONLY = 'A short review of words you met before. Type each missing word from memory.'
const ALL_DONE = 'You have finished every dialogue that is ready.'

/** Front door text that would be a count of due words, a score or a celebration. */
const NO_COUNTS = /\d+\s*(words?|cards?|reviews?|due)|streak|score|points|badge|congratulations|well done/i

async function frontDoorText(page: Page): Promise<string> {
  return page.locator('main').innerText()
}

/** A learner who met their first dialogue yesterday, now back at the front door. */
async function metYesterday(page: Page): Promise<{ userId: string; dialogueId: string }> {
  const first = await finishFirstSession(page)
  dayLater(first.userId)
  return first
}

test.describe('the daily review', { tag: '@seed' }, () => {
  test.setTimeout(150_000)

  test.beforeEach(async ({ page }, testInfo) => {
    recordApiTimings(page, testInfo)
    await serveTone(page)
  })

  test('[review 4] [review 6] [review 12] [review 13] a day later the session ends with Keep it, step 3 of 3, then the finish screen saves as in job 8', async ({
    page,
  }) => {
    const { userId } = await finishFirstSession(page)

    // First day, after dialogue 1: job 8's front door for the next dialogue, no word of review.
    await expect(page.getByRole('heading', { level: 1, name: "Today's session" })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    const firstDay = await frontDoorText(page)
    expect(firstDay).not.toMatch(/review/i)
    expect(firstDay).not.toMatch(NO_COUNTS)

    // A day later, a dialogue ready and words reviewable: one sentence added, one Start.
    dayLater(userId)
    await page.reload()
    await expect(page.getByText(ENDS_WITH_REVIEW, { exact: false })).toBeVisible()
    await expect(page.getByRole('button')).toHaveCount(1)
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    expect(await frontDoorText(page)).not.toMatch(NO_COUNTS)

    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.getByText('Hear it, step 1 of 3', { exact: true })).toBeVisible()
    await throughUnderstandIt(page, userId)
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    await expect(page.getByText('Keep it, step 3 of 3', { exact: true })).toBeVisible()
    await expect(page.getByText(/^Word 1 of \d+\.$/)).toBeVisible()
    const session = sessionsOf(userId).find((s) => !s.ended)
    expect(session?.step).toBe('understand')

    // One item close, one missed, the rest right. Both come back once more at the end.
    const answered = await runKeepIt(page, (_formId, retry, index) => {
      if (retry) return 'right'
      if (index === 0) return 'close'
      if (index === 1) return 'wrong'
      return 'right'
    })
    const firstPass = answered.filter((a) => !a.retry)
    const retries = answered.filter((a) => a.retry)
    expect(firstPass[0]?.status).toBe('Close. Check the spelling below.')
    expect(firstPass[1]?.status).toBe('Here is the word. It will come back soon.')
    for (const a of firstPass.slice(2)) expect(a.status).toBe('Yes, that is right.')
    // [review 13] The two missed items came back once each, after the others, and no third time.
    expect(retries.map((a) => a.formId)).toEqual([firstPass[0]?.formId, firstPass[1]?.formId])
    expect(answered.slice(firstPass.length).every((a) => a.retry)).toBe(true)

    // The finish screen as in job 8.
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    await expect(page.getByText('Session finished', { exact: true })).toBeVisible()
    await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
    const row = sessionsOf(userId).find((s) => s.id === session?.id)
    expect(row?.step).toBe('keep')
    expect(row?.ended).toBe(true)
    expect(one(`select count(*) from public.usage_events where user_id = :'uid'`, { uid: userId })).toBe('1')

    // [review 13] One log per answer: a second log row for each retried word.
    expect(logCount(userId)).toBe(answered.length)
    for (const formId of [firstPass[0]?.formId, firstPass[1]?.formId]) {
      expect(logsOf(userId).filter((l) => l.formId === formId)).toHaveLength(2)
    }
  })

  test("[review 11] [review 14] one item right and one wrong are saved at once with the same engine's values; leaving keeps them, and Continue restarts Keep it with what is still due", async ({
    page,
  }) => {
    const { userId } = await metYesterday(page)
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await throughUnderstandIt(page, userId)
    const total = Number(/of (\d+)/.exec(await page.getByText(/^Word 1 of \d+\.$/).innerText())?.[1])
    expect(total).toBeGreaterThan(2)

    const right = await answerItem(page, 'right')
    await nextItem(page)
    const wrong = await answerItem(page, 'wrong', 'check')
    await expect(page.getByText(/^You wrote/)).toBeVisible()

    // Saved at once: two log rows, ratings 3 and 1, mode typed.
    const logs = logsOf(userId)
    expect(logs.map((l) => [l.formId, l.rating, l.mode])).toEqual([
      [right, 3, 'typed'],
      [wrong, 1, 'typed'],
    ])
    for (const formId of [right, wrong]) {
      const stored = cardOf(userId, formId)
      const expected = await engineCard(logs.filter((l) => l.formId === formId))
      expect(stored).not.toBeNull()
      expect(stored?.due).toBe(expected.due)
      expect(stored?.lastReview).toBe(expected.lastReview)
      expect(stored?.reps).toBe(expected.reps)
      expect(stored?.lapses).toBe(expected.lapses)
      expect(stored?.state).toBe(expected.state)
      expect(stored?.elapsedDays).toBe(expected.elapsedDays)
      expect(stored?.scheduledDays).toBe(expected.scheduledDays)
      expect(stored?.stability).toBeCloseTo(expected.stability, 9)
      expect(stored?.difficulty).toBeCloseTo(expected.difficulty, 9)
    }

    // [review 14] Leave, then continue: Keep it again, without the two answered words.
    await page.getByRole('link', { name: 'Leave session' }).click()
    await page.waitForURL((url) => url.pathname === '/')
    await page.getByRole('button', { name: "Continue today's session" }).click()
    await page.waitForURL('**/session')
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    await expect(page.getByText(`Word 1 of ${String(total - 2)}.`, { exact: true })).toBeVisible()
    const rest = await runKeepIt(page)
    expect(rest.map((a) => a.formId)).not.toContain(right)
    expect(rest.map((a) => a.formId)).not.toContain(wrong)
    expect(rest).toHaveLength(total - 2)
    expect(logCount(userId)).toBe(total)
    expect(sessionsOf(userId).filter((s) => s.dialogueId !== '' && s.ended)).toHaveLength(2)
  })

  test("[review 4] [review 5] [review 7] with no new dialogue, today's session is the review alone; then the day is empty and names the next review", async ({
    page,
  }) => {
    const { userId } = await finishFirstSession(page)
    finishEveryOtherDialogue(userId)
    dayLater(userId)
    await page.reload()
    await expect(page.getByRole('heading', { level: 1, name: "Today's session" })).toBeVisible()
    await expect(page.getByText(REVIEW_ONLY, { exact: true })).toBeVisible()
    await expect(page.getByRole('button')).toHaveCount(1)
    expect(await frontDoorText(page)).not.toMatch(NO_COUNTS)
    const events = one(`select count(*) from public.usage_events where user_id = :'uid'`, { uid: userId })
    const cards = one(`select count(*) from public.cards where user_id = :'uid'`, { uid: userId })

    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.getByText('Keep it, step 1 of 1', { exact: true })).toBeVisible()
    const reviewRow = sessionsOf(userId).find((s) => s.dialogueId === '')
    expect(reviewRow?.ended).toBe(false)

    // [review 4] Leaving shows "Continue today's session", which reuses the same row.
    await page.getByRole('link', { name: 'Leave session' }).click()
    await page.waitForURL((url) => url.pathname === '/')
    await page.getByRole('button', { name: "Continue today's session" }).click()
    await page.waitForURL('**/session')
    expect(sessionsOf(userId).filter((s) => s.dialogueId === '')).toHaveLength(1)

    await runKeepIt(page)
    await expect(page.getByRole('heading', { level: 1, name: 'Review finished.' })).toBeVisible()
    await expect(
      page.getByText('These words will come back when they are due.', { exact: true }),
    ).toBeVisible()
    await expect(page.getByText('Session finished', { exact: true })).toBeVisible()
    await expect(page.getByRole('button')).toHaveCount(1)
    await expect(page.getByText(NO_COUNTS)).toHaveCount(0)
    const [row] = sessionsOf(userId).filter((s) => s.dialogueId === '')
    expect(row?.step).toBe('keep')
    expect(row?.ended).toBe(true)
    // No complete_session: no new event and no new card.
    expect(one(`select count(*) from public.usage_events where user_id = :'uid'`, { uid: userId })).toBe(
      events,
    )
    expect(one(`select count(*) from public.cards where user_id = :'uid'`, { uid: userId })).toBe(cards)

    // [review 5] Nothing ready and nothing due: plain words and the day of the next review.
    await page.getByRole('button', { name: 'Done' }).click()
    await page.waitForURL((url) => url.pathname === '/')
    await expect(page.getByRole('heading', { level: 1, name: 'That is all for today.' })).toBeVisible()
    await expect(page.getByRole('status')).toHaveText(ALL_DONE)
    await expect(page.getByText('Your next review is tomorrow.', { exact: true })).toBeVisible()
    await expect(page.getByRole('button')).toHaveCount(0)
    await expect(page.locator('main img')).toHaveCount(0)
    expect(await frontDoorText(page)).not.toMatch(NO_COUNTS)

    // A later day, worded from the database's dates (Helsinki), not the device clock.
    sql(
      `update public.cards set due = (((now() at time zone 'Europe/Helsinki')::date + 5) + time '12:00') at time zone 'Europe/Helsinki'
        where user_id = :'uid'`,
      { uid: userId },
    )
    const day = one(`select to_char((now() at time zone 'Europe/Helsinki')::date + 5, 'FMDay FMDD FMMonth')`)
    await page.reload()
    await expect(page.getByText(`Your next review is on ${day}.`, { exact: true })).toBeVisible()
  })

  test('[review 9] the ä button types where the cursor is and keeps focus; Check waits for text; Enter submits', async ({
    page,
  }) => {
    const { userId } = await metYesterday(page)
    finishEveryOtherDialogue(userId)
    await page.reload()
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()

    const field = page.getByLabel(FIELD, { exact: true })
    await expect(field).toHaveAttribute('lang', 'fi')
    for (const [name, value] of [
      ['autocapitalize', 'off'],
      ['autocorrect', 'off'],
      ['spellcheck', 'false'],
      ['autocomplete', 'off'],
      ['enterkeyhint', 'done'],
      ['maxlength', '100'],
    ] as const) {
      await expect(field, name).toHaveAttribute(name, value)
    }
    const check = page.getByRole('button', { name: 'Check', exact: true })
    await expect(check).toBeDisabled()
    // Enter on an empty field checks nothing.
    await field.click()
    await page.keyboard.press('Enter')
    await expect(page.locator('[data-review-feedback]')).toHaveCount(0)

    await page.keyboard.type('ab')
    await page.keyboard.press('ArrowLeft')
    await page.getByRole('button', { name: 'Type ä' }).click()
    await expect(field).toHaveValue('aäb')
    await expect(field).toBeFocused()
    await page.keyboard.type('x')
    await expect(field).toHaveValue('aäxb')
    await page.getByRole('button', { name: 'Type ö' }).click()
    await expect(field).toHaveValue('aäxöb')
    await expect(check).toBeEnabled()

    await field.fill('')
    await expect(check).toBeDisabled()
    const formId = await itemFormId(page)
    await typeAnswer(page, shapesOf(formId).spoken)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
    expect(logsOf(userId).map((l) => l.formId)).toEqual([formId])
  })

  test('[review 8] [review 12] [review 17] the items hold no answer and no draft; after answering, the whole line, the word and what was typed, gently', async ({
    page,
  }) => {
    const { userId } = await metYesterday(page)
    finishEveryOtherDialogue(userId)
    await page.reload()
    const itemsAnswer = page.waitForResponse(
      (res) =>
        /\/api\/sessions\/[0-9a-f-]+\/review$/.test(new URL(res.url()).pathname) &&
        res.request().method() === 'GET',
    )
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    const body = await (await itemsAnswer).text()
    const { items } = JSON.parse(body) as {
      items: { formId: number; register: string; words: { text?: string; gap?: true }[]; gloss: string }[]
    }
    expect(items.length).toBeGreaterThan(0)
    for (const item of items) {
      const own = JSON.stringify(item)
      const { spoken, written } = shapesOf(String(item.formId))
      for (const word of item.words) {
        if (word.text === undefined) continue
        expect(word.text.toLowerCase(), `form ${String(item.formId)}`).not.toBe(spoken.toLowerCase())
        expect(word.text.toLowerCase(), `form ${String(item.formId)}`).not.toBe(written.toLowerCase())
      }
      expect(item.words.some((w) => w.gap)).toBe(true)
      // The other register's line text is not in the item.
      const [line] = sql(
        `select l.text_puhe, l.text_kirja from public.dialogue_lines l
          where l.gloss_en = :'gloss' and l.status = 'approved' limit 1`,
        { gloss: item.gloss },
      )
      const other = item.register === 'spoken' ? line?.[1] : line?.[0]
      if (other) expect(own).not.toContain(other)
      expect(own).not.toMatch(/lemma|formName|"why"|surface/)
    }
    // [review 17] No draft content: the fixture's draft line and draft form never appear.
    const drafts = sql(
      `select gloss_en from public.dialogue_lines where status <> 'approved' and gloss_en is not null
       union all select form_name_en from public.forms where status <> 'approved' and form_name_en is not null
       union all select why_en from public.forms where status <> 'approved' and why_en is not null`,
    ).map((r) => r[0] ?? '')
    for (const draft of drafts.filter(Boolean)) expect(body).not.toContain(draft)

    // [review 8] Before answering: the gap is read as "missing word", one play control, no word cards.
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    await expect(page.locator('[data-review-item] [lang="fi"]').first()).toBeVisible()
    await expect(page.locator('[data-gap]').first()).toContainText('missing word')
    await expect(
      page.locator('[data-review-item]').getByRole('button', { name: /^Play the (spoken|written) line$/ }),
    ).toHaveCount(1)
    await expect(page.locator('[data-review-item] [aria-haspopup="dialog"]')).toHaveCount(0)

    // [review 12] Close: gentle, both registers, both play controls, the word marked in both lines, what was typed.
    const formId = await answerItem(page, 'close')
    const { spoken, written } = shapesOf(formId)
    await expect(page.getByRole('status')).toHaveText('Close. Check the spelling below.')
    await expect(page.getByRole('status')).toHaveAttribute('data-tone', 'gentle')
    const feedback = page.locator(`[data-review-feedback="${formId}"]`)
    await expect(feedback.getByRole('button', { name: 'Play the spoken line', exact: true })).toHaveCount(1)
    await expect(feedback.getByRole('button', { name: 'Play the written line', exact: true })).toHaveCount(1)
    await expect(feedback.getByText('Spoken', { exact: true }).first()).toBeVisible()
    await expect(feedback.getByText('Written', { exact: true }).first()).toBeVisible()
    expect(await feedback.getByText(', the missing word').count()).toBeGreaterThanOrEqual(2)
    await expect(feedback.locator('[lang="fi"]', { hasText: spoken }).first()).toBeVisible()
    await expect(feedback.locator('[lang="fi"]', { hasText: written }).first()).toBeVisible()
    await expect(feedback.getByText(/^You wrote/)).toBeVisible()
    // Words are tappable for their cards, as in job 8.
    await feedback.locator('[lang="fi"] button').first().click()
    await expect(page.getByRole('dialog')).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(page.getByText(/wrong|incorrect|mistake|score/i)).toHaveCount(0)
    await nextItem(page)

    // Not remembered: gentle, the word shown, no "You wrote".
    await answerItem(page, 'dont_know')
    await expect(page.getByRole('status')).toHaveText('Here is the word. It will come back soon.')
    await expect(page.getByRole('status')).toHaveAttribute('data-tone', 'gentle')
    await expect(page.getByText(/^You wrote/)).toHaveCount(0)
    await expect(page.getByText(/wrong|incorrect|mistake|score/i)).toHaveCount(0)
    await nextItem(page)

    // Right: neutral.
    if (await onItem(page)) {
      await answerItem(page, 'right')
      await expect(page.getByRole('status')).toHaveText('Yes, that is right.')
      await expect(page.getByRole('status')).toHaveAttribute('data-tone', 'neutral')
    }
    // [review 17] Nothing on screen came from draft content either.
    for (const draft of drafts.filter(Boolean)) await expect(page.getByText(draft)).toHaveCount(0)
    // [review 17] The typed answer is not stored: no table holds it.
    const typed = `${spoken.slice(0, -1)}q`
    expect(
      one(
        `select count(*) from public.review_logs l where l.user_id = :'uid' and to_jsonb(l)::text like '%' || :'typed' || '%'`,
        { uid: userId, typed },
      ),
    ).toBe('0')
  })

  test('[review 16] the review routes refuse another site and a stranger, and save nothing', async ({
    page,
    playwright,
  }) => {
    const { userId } = await metYesterday(page)
    finishEveryOtherDialogue(userId)
    await page.reload()
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await page.waitForURL('**/session')
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    const sessionId = sessionsOf(userId).find((s) => s.dialogueId === '')?.id ?? ''
    const formId = Number(await itemFormId(page))
    const answer = { sessionId, formId, text: 'abc', kind: 'typed' }
    const evil = { 'content-type': 'application/json', origin: 'https://evil.example' }
    for (const [path, data] of [
      ['/api/review/answer', answer],
      [`/api/sessions/${sessionId}/review/done`, {}],
    ] as const) {
      const res = await page.request.post(path, { headers: evil, data })
      expect(res.status(), path).toBe(403)
      expect(res.headers()['access-control-allow-origin']).toBeUndefined()
    }
    const rating = await page.request.post('/api/review/answer', { data: { ...answer, rating: 4 } })
    expect(rating.status()).toBe(400)

    // A stranger: no sign in cookie, and none of the test config's headers.
    const stranger = await playwright.request.newContext({
      baseURL: new URL(page.url()).origin,
      ignoreHTTPSErrors: true,
      extraHTTPHeaders: {},
    })
    const items = await stranger.get(`/api/sessions/${sessionId}/review`)
    expect(items.status()).toBe(401)
    const post = await stranger.post('/api/review/answer', { data: answer })
    expect(post.status()).toBe(401)
    expect(post.headers()['set-cookie']).toBeUndefined()
    await stranger.dispose()

    expect(logCount(userId)).toBe(0)
    expect(sessionsOf(userId).find((s) => s.id === sessionId)?.step).toBe('')
  })

  test('[review 20] Keep it fits 320 px and 200 percent text, with tap areas of at least 44 x 44', async ({
    page,
  }) => {
    const { userId } = await metYesterday(page)
    finishEveryOtherDialogue(userId)
    await page.reload()
    await page.getByRole('button', { name: 'Start', exact: true }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
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
        const name = (await button.getAttribute('aria-label')) ?? (await button.innerText())
        expect(box?.height ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
        expect(box?.width ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(inLine ? 24 : 44)
      }
    }
    await typeAnswer(page, 'ab')
    await check('Keep it, answering')
    await page.getByLabel(FIELD, { exact: true }).fill('')
    await answerItem(page, 'close')
    await check('Keep it, after answering')
    await nextItem(page)
    await runKeepIt(page)
    await expect(page.getByRole('heading', { level: 1, name: 'Review finished.' })).toBeVisible()
    await check('Review finished')
    await page.getByRole('button', { name: 'Done' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'That is all for today.' })).toBeVisible()
    await check('Empty day')
  })

  test('[review 20] the whole review works with the keyboard alone, in reading order', async ({
    page,
  }, testInfo) => {
    const { userId } = await metYesterday(page)
    finishEveryOtherDialogue(userId)
    await page.reload()
    const start = page.getByRole('button', { name: 'Start', exact: true })
    await tabTo(page, start, testInfo)
    await page.keyboard.press('Enter')
    await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
    const field = page.getByLabel(FIELD, { exact: true })
    const play = page
      .locator('[data-review-item]')
      .getByRole('button', { name: /^Play the (spoken|written) line$/ })

    // Reading order: Leave session, the play control, the field, ä, ö, then "I don't remember".
    if (testInfo.project.name !== 'webkit') {
      const order: string[] = []
      for (let i = 0; i < 12; i += 1) {
        await page.keyboard.press('Tab')
        order.push(
          await page.evaluate<string>(
            '(document.activeElement?.getAttribute("aria-label") || (document.activeElement?.tagName === "INPUT" ? "field" : document.activeElement?.textContent) || "").trim()',
          ),
        )
      }
      const at = (name: string) => order.indexOf(name)
      const playName = (await play.getAttribute('aria-label')) ?? ''
      expect(at('Leave session')).toBeGreaterThanOrEqual(0)
      expect(at(playName)).toBeGreaterThan(at('Leave session'))
      expect(at('field')).toBeGreaterThan(at(playName))
      expect(at('Type ä')).toBeGreaterThan(at('field'))
      expect(at('Type ö')).toBeGreaterThan(at('Type ä'))
      expect(at("I don't remember")).toBeGreaterThan(at('Type ö'))
    }

    let answered = 0
    while (await onItem(page)) {
      const formId = await itemFormId(page)
      if (answered === 0) await tabTo(page, field, testInfo)
      await expect(field).toBeFocused()
      await page.keyboard.type(shapesOf(formId).spoken)
      await page.keyboard.press('Enter')
      await expect(page.locator(`[data-review-feedback="${formId}"]`)).toBeVisible()
      const next = page.getByRole('button', { name: 'Next', exact: true })
      await expect(next).toBeFocused()
      await page.keyboard.press('Enter')
      await expect(page.locator('[data-review-feedback]')).toHaveCount(0, { timeout: 10_000 })
      answered += 1
    }
    await expect(page.getByRole('heading', { level: 1, name: 'Review finished.' })).toBeVisible()
    await tabTo(page, page.getByRole('button', { name: 'Done' }), testInfo)
    await page.keyboard.press('Enter')
    await page.waitForURL((url) => url.pathname === '/')
    expect(logCount(userId)).toBe(answered)
  })

  for (const scheme of ['light', 'dark'] as const) {
    test(`[review 20] axe finds no WCAG A or AA problem on any review screen, ${scheme}`, async ({
      page,
    }) => {
      await page.emulateMedia({ colorScheme: scheme })
      const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']
      const scan = async (label: string) => {
        await page.evaluate('document.fonts.ready')
        const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
        expect(
          result.violations.map(
            (v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`,
          ),
        ).toEqual([])
      }
      const { userId } = await metYesterday(page)
      await page.reload()
      await expect(page.getByText(ENDS_WITH_REVIEW, { exact: false })).toBeVisible()
      await scan('front door, session ends with a review')
      finishEveryOtherDialogue(userId)
      await page.reload()
      await expect(page.getByText(REVIEW_ONLY, { exact: true })).toBeVisible()
      await scan('front door, review only')
      await page.getByRole('button', { name: 'Start', exact: true }).click()
      await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
      await scan('Keep it, answering')
      await answerItem(page, 'close')
      await scan('Keep it, close')
      await page.locator('[data-review-feedback] [lang="fi"] button').first().click()
      await expect(page.getByRole('dialog')).toBeVisible()
      await page.waitForTimeout(400)
      await scan('word card')
      await page.keyboard.press('Escape')
      await nextItem(page)
      if (await onItem(page)) {
        await answerItem(page, 'dont_know')
        await scan('Keep it, not remembered')
        await nextItem(page)
      }
      if (await onItem(page)) {
        await answerItem(page, 'right')
        await scan('Keep it, right')
        await nextItem(page)
      }
      await runKeepIt(page)
      await expect(page.getByRole('heading', { level: 1, name: 'Review finished.' })).toBeVisible()
      await scan('Review finished')
      await page.getByRole('button', { name: 'Done' }).click()
      await expect(page.getByRole('heading', { level: 1, name: 'That is all for today.' })).toBeVisible()
      await scan('front door, empty day')
    })
  }
})
