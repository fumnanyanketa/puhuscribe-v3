import { expect, test, type Page, type Route } from '@playwright/test'

// Labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md that each test protects.
// The private review pages under /review/ and the owner page's "Send review
// link" and "Review answers", drawn by the app shell. Every /api route they
// call is answered by the test, so no row is written anywhere and no email is
// sent; the Worker's own rules are worker/review-links.test.ts and
// worker/owner.test.ts, and the database's supabase/tests/database/review_links.test.sql.
//
// REVIEW_LINKS_EVIDENCE_DIR set: the phone and desktop pictures are saved there
// (factory/jobs/review-links/evidence/).

const evidence = process.env.REVIEW_LINKS_EVIDENCE_DIR
// A made up secret of the right shape (43 base64url characters), plainly not random.
const TOKEN = 'fake-review-link-for-browser-tests'.padEnd(43, '0')
const WRONG = 'Z'.repeat(43)
const FORTY = 'Lentokonesuihkuturbiinimoottoriapumekaanikko'.slice(0, 40)

const TITLES = [
  'A new colleague',
  'At the language café',
  'A new neighbour',
  'Ordering coffee at the counter',
  'Paying for the coffee',
  'Coffee and a bun for two',
]

const OVERVIEW = {
  batch: 1,
  dialogues: Array.from({ length: 27 }, (_, i) => ({
    id: 100 + i,
    position: i + 1,
    title: TITLES[i] ?? `Dialogue ${String(i + 1)}`,
    stop: i < 3 ? 'Meeting people' : i < 6 ? 'Ordering coffee' : 'Later stops',
    lines: 8,
    answered: i === 0 ? 8 : i === 1 ? 3 : 0,
  })),
}

const LINES = [
  ['Pekka', 'Moi! Mä oon Pekka.', 'Hei! Minä olen Pekka.', "Hi! I'm Pekka."],
  ['Maria', 'Moi Pekka, mä oon Maria.', 'Hei Pekka, minä olen Maria.', "Hi Pekka, I'm Maria."],
  ['Pekka', 'Ootsä uus täällä?', 'Oletko sinä uusi täällä?', 'Are you new here?'],
  [
    'Maria',
    `Joo, mä aloitin eilen. ${FORTY}.`,
    `Kyllä, minä aloitin eilen. ${FORTY}.`,
    'Yes, I started yesterday.',
  ],
] as const

function dialogue(answers: Record<number, { answer: string; note: string | null }> = {}) {
  return {
    id: 100,
    position: 1,
    of: 27,
    title: 'A new colleague',
    stop: 'Meeting people',
    previous: null,
    next: 101,
    lines: LINES.map(([speaker, spoken, written, english], i) => ({
      id: 1000 + i,
      position: i + 1,
      speaker,
      spoken,
      written,
      english,
      spokenAudio: `/audio/meeting-people-new-colleague/${String(i + 1)}-puhe-0123456789ab.mp3`,
      writtenAudio: `/audio/meeting-people-new-colleague/${String(i + 1)}-kirja-0123456789ab.mp3`,
      answer: answers[1000 + i]?.answer ?? null,
      note: answers[1000 + i]?.note ?? null,
    })),
  }
}

const json = (route: Route, status: number, body: unknown) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

/**
 * Answers /api/review/* as the Worker does for TOKEN, and 404 link_not_found for anything else.
 * `saveAnswer` decides each save; the bodies sent are kept.
 */
async function fakeReviewApi(
  page: Page,
  saveAnswer: (body: Record<string, unknown>) =>
    | Promise<{ status: number; body: unknown }>
    | {
        status: number
        body: unknown
      } = () => ({ status: 200, body: { saved: true } }),
  answers: Record<number, { answer: string; note: string | null }> = {},
) {
  const saves: Record<string, unknown>[] = []
  const calls: string[] = []
  await page.route('**/api/review/**', async (route) => {
    const url = new URL(route.request().url())
    calls.push(url.pathname)
    if (url.pathname === `/api/review/${TOKEN}`) return json(route, 200, OVERVIEW)
    if (url.pathname === `/api/review/${TOKEN}/dialogues/100`) return json(route, 200, dialogue(answers))
    if (url.pathname === `/api/review/${TOKEN}/answers`) {
      const body = JSON.parse(route.request().postData() ?? '{}') as Record<string, unknown>
      saves.push(body)
      const result = await saveAnswer(body)
      return json(route, result.status, result.body)
    }
    return json(route, 404, { error: 'link_not_found' })
  })
  return { saves, calls }
}

async function scrollsSideways(page: Page): Promise<boolean> {
  return page.evaluate<boolean>('document.documentElement.scrollWidth > window.innerWidth')
}

async function picture(page: Page, name: string) {
  if (evidence) await page.screenshot({ path: `${evidence}/${name}.png`, fullPage: true })
}

test.describe('the review list', () => {
  test("[review-links 3] [review-links 7] shows the batch, its 27 dialogues and each one's progress, at 375 x 812, with no cookie", async ({
    page,
    context,
  }, testInfo) => {
    await page.setViewportSize({ width: 375, height: 812 })
    await fakeReviewApi(page)
    await page.goto(`/review/${TOKEN}`)
    await expect(page.getByRole('heading', { level: 1, name: 'Check the Finnish in Aleksi' })).toBeVisible()
    await expect(
      page.getByText('This is batch 1 of 4, with 27 dialogues in the order a learner meets them.'),
    ).toBeVisible()
    const items = page.locator('[data-review="dialogues"] li')
    await expect(items).toHaveCount(27)
    await expect(items.nth(0)).toHaveText('A new colleagueMeeting people. Done.')
    await expect(items.nth(1)).toHaveText('At the language caféMeeting people. In progress, 3 of 8 lines.')
    await expect(items.nth(2)).toHaveText('A new neighbourMeeting people. Not started.')
    await expect(items.nth(0).getByRole('link')).toHaveAttribute('href', `/review/${TOKEN}/100`)
    expect(new URL(page.url()).pathname).toBe(`/review/${TOKEN}`)
    expect(await scrollsSideways(page)).toBe(false)
    expect(await context.cookies()).toEqual([])
    if (testInfo.project.name === 'chromium') await picture(page, '3-review-list-375x812')
  })

  test('[review-links 3] the list on a desktop', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'chromium', 'One desktop picture is enough.')
    await page.setViewportSize({ width: 1440, height: 900 })
    await fakeReviewApi(page)
    await page.goto(`/review/${TOKEN}`)
    await expect(page.locator('[data-review="dialogues"] li')).toHaveCount(27)
    await picture(page, '3-review-list-desktop-1440x900')
  })
})

test.describe('a dialogue page', () => {
  test('[review-links 3] each line has spoken, written, English and Play, from the Worker', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    await fakeReviewApi(page)
    await page.goto(`/review/${TOKEN}/100`)
    await expect(page.getByRole('heading', { level: 1, name: 'A new colleague' })).toBeVisible()
    await expect(page.getByText('Dialogue 1 of 27. Meeting people.')).toBeVisible()
    const lines = page.locator('[data-review="lines"] > li')
    await expect(lines).toHaveCount(4)
    const first = lines.nth(0)
    await expect(first.getByRole('group', { name: 'How people say it' })).toContainText('Moi! Mä oon Pekka.')
    await expect(first.getByRole('group', { name: 'How it is written' })).toContainText(
      'Hei! Minä olen Pekka.',
    )
    await expect(first.getByText("Hi! I'm Pekka.")).toBeVisible()
    await expect(first.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
    await expect(first.getByRole('button', { name: 'Play the written line' })).toBeVisible()
    for (const name of ['Correct', 'Needs a fix', 'Not sure'])
      await expect(first.getByRole('button', { name, exact: true })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Next dialogue' })).toHaveAttribute(
      'href',
      `/review/${TOKEN}/101`,
    )
  })

  test('[review-links 4] each answer saves on tap and says "Saved."; "Needs a fix" opens a note box of up to 500 characters', async ({
    page,
  }, testInfo) => {
    await page.setViewportSize({ width: 375, height: 812 })
    const { saves } = await fakeReviewApi(page)
    await page.goto(`/review/${TOKEN}/100`)
    const lines = page.locator('[data-review="lines"] > li')
    const first = lines.nth(0)
    await first.getByRole('button', { name: 'Correct', exact: true }).click()
    await expect(first.getByRole('status')).toHaveText('Saved.')
    await expect(first.getByRole('button', { name: 'Correct', exact: true })).toHaveAttribute(
      'aria-pressed',
      'true',
    )
    expect(saves).toEqual([{ lineId: 1000, answer: 'correct', note: null }])

    const second = lines.nth(1)
    await expect(second.getByLabel('What should change?')).toHaveCount(0)
    await second.getByRole('button', { name: 'Needs a fix', exact: true }).click()
    await expect(second.getByRole('status')).toHaveText('Saved.')
    const box = second.getByLabel('What should change?')
    await expect(box).toBeVisible()
    await box.fill('In spoken Finnish "mä oon" is right, but people often say "mä oon" with the name first.')
    await expect(second.getByText('of 500 characters')).toBeVisible()
    await second.getByRole('button', { name: 'Save the note' }).click()
    await expect(second.getByRole('status')).toHaveText('Saved.')
    expect(saves[2]).toEqual({
      lineId: 1001,
      answer: 'needs_fix',
      note: 'In spoken Finnish "mä oon" is right, but people often say "mä oon" with the name first.',
    })

    // Changing the answer sends the new one; the Worker and database replace the old.
    await lines.nth(2).getByRole('button', { name: 'Not sure', exact: true }).click()
    await expect(lines.nth(2).getByRole('status')).toHaveText('Saved.')
    expect(saves.at(-1)).toEqual({ lineId: 1002, answer: 'not_sure', note: null })

    // A note of 501 characters is refused on the page, with nothing sent.
    const before = saves.length
    await box.fill('a'.repeat(501))
    await expect(second.getByText('501 of 500 characters')).toBeVisible()
    await second.getByRole('button', { name: 'Save the note' }).click()
    await expect(second.getByRole('status')).toHaveText('Please keep the note to 500 characters.')
    expect(saves.length).toBe(before)
    await box.fill('In spoken Finnish the name usually comes first: "Maria, mä oon uus täällä."')
    await second.getByRole('button', { name: 'Save the note' }).click()
    await expect(second.getByRole('status')).toHaveText('Saved.')
    // All three answers fit one row at 375 px.
    const tops: number[] = []
    for (const button of await second
      .getByRole('group', { name: 'Your answer for line 2' })
      .getByRole('button')
      .all())
      tops.push(Math.round((await button.boundingBox())?.y ?? -1))
    expect(new Set(tops).size).toBe(1)

    expect(await scrollsSideways(page)).toBe(false)
    if (testInfo.project.name === 'chromium') {
      await second.scrollIntoViewIfNeeded()
      await picture(page, '3-4-dialogue-needs-a-fix-375x812')
      await page.setViewportSize({ width: 1440, height: 900 })
      await picture(page, '3-4-dialogue-needs-a-fix-desktop-1440x900')
    }
  })

  test('[review-links 4] a failed save says so and keeps what was typed; a tap while saving is ignored', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    let release: () => void = () => undefined
    const held = new Promise<void>((resolve) => {
      release = resolve
    })
    let n = 0
    const { saves } = await fakeReviewApi(page, async () => {
      n += 1
      if (n === 1) {
        await held
        return { status: 200, body: { saved: true } }
      }
      if (n === 2) return { status: 503, body: { error: 'not_available' } }
      return { status: 429, body: { error: 'limit' } }
    })
    await page.goto(`/review/${TOKEN}/100`)
    const first = page.locator('[data-review="lines"] > li').nth(0)
    await first.getByRole('button', { name: 'Correct', exact: true }).click()
    await first.getByRole('button', { name: 'Not sure', exact: true }).click({ force: true })
    await first.getByRole('button', { name: 'Needs a fix', exact: true }).click({ force: true })
    release()
    await expect(first.getByRole('status')).toHaveText('Saved.')
    expect(saves).toEqual([{ lineId: 1000, answer: 'correct', note: null }])

    const second = page.locator('[data-review="lines"] > li').nth(1)
    await second.getByRole('button', { name: 'Needs a fix', exact: true }).click()
    await expect(second.getByRole('status')).toHaveText('Not saved. Please try again in a moment.')
    const box = second.getByLabel('What should change?')
    await box.fill('Kept after a failed save.')
    await second.getByRole('button', { name: 'Save the note' }).click()
    await expect(second.getByRole('status')).toHaveText(
      'Not saved, because many answers came in at once. Wait a minute, then try again.',
    )
    await expect(box).toHaveValue('Kept after a failed save.')

    await page.route(`**/api/review/${TOKEN}/answers`, (route) => route.abort())
    await second.getByRole('button', { name: 'Save the note' }).click()
    await expect(second.getByRole('status')).toHaveText(
      'Not saved. Check your internet connection, then try again.',
    )
    await expect(box).toHaveValue('Kept after a failed save.')
  })

  test('[review-links 4] a saved answer and note come back when the reviewer returns', async ({ page }) => {
    await fakeReviewApi(page, undefined, { 1001: { answer: 'needs_fix', note: 'Saved last time.' } })
    await page.goto(`/review/${TOKEN}/100`)
    const second = page.locator('[data-review="lines"] > li').nth(1)
    await expect(second.getByRole('button', { name: 'Needs a fix', exact: true })).toHaveAttribute(
      'aria-pressed',
      'true',
    )
    await expect(second.getByLabel('What should change?')).toHaveValue('Saved last time.')
  })

  test('[review-links 7] the pages fit 320 px with 200 percent text, with 44 px controls and no sideways scroll', async ({
    page,
  }) => {
    await fakeReviewApi(page)
    for (const path of [`/review/${TOKEN}`, `/review/${TOKEN}/100`]) {
      await page.setViewportSize({ width: 320, height: 812 })
      await page.goto(path)
      await expect(page.getByRole('heading', { level: 1 })).toBeVisible()
      if (path.endsWith('/100')) {
        await page
          .locator('[data-review="lines"] > li')
          .nth(1)
          .getByRole('button', { name: 'Needs a fix' })
          .click()
      }
      await page.addStyleTag({ content: 'html { font-size: 200% !important; }' })
      expect(await scrollsSideways(page), `${path} at 320 px, 200 percent text`).toBe(false)
      for (const control of await page.locator('main button, main a[href], main textarea').all()) {
        const size = await control.boundingBox()
        if (!size) continue
        expect(size.height, await control.innerText()).toBeGreaterThanOrEqual(44)
        expect(size.width, await control.innerText()).toBeGreaterThanOrEqual(44)
      }
    }
  })
})

test.describe('a link that does not work', () => {
  test('[review-links 2] a wrong or deleted link and a malformed one show the same plain page', async ({
    page,
  }, testInfo) => {
    await page.setViewportSize({ width: 375, height: 812 })
    const { calls } = await fakeReviewApi(page)
    await page.goto(`/review/${WRONG}`)
    await expect(page.getByRole('heading', { level: 1, name: 'This link does not work' })).toBeVisible()
    const wrong = await page.locator('main').innerText()
    if (testInfo.project.name === 'chromium') await picture(page, '2-link-does-not-work-375x812')
    await page.goto(`/review/${WRONG}/100`)
    await expect(page.getByRole('heading', { level: 1, name: 'This link does not work' })).toBeVisible()
    const before = calls.length
    await page.goto('/review/not-a-real-link')
    await expect(page.getByRole('heading', { level: 1, name: 'This link does not work' })).toBeVisible()
    expect(await page.locator('main').innerText()).toBe(wrong)
    expect(calls.length).toBe(before)
    if (testInfo.project.name === 'chromium') {
      await page.setViewportSize({ width: 1440, height: 900 })
      await picture(page, '2-link-does-not-work-desktop-1440x900')
    }
  })
})

const NUMBERS = {
  visits_by_day: [],
  visits_by_country: [],
  active_learners: 12,
  day7_retention: { retained: 2, cohort: 5, percent: 40 },
  median_session_minutes: { minutes: 9, used: 20, left_out: 0 },
  speak_back: { count: 8, base: 12, percent: 67 },
  ai_cost_usd: { total: 0.42, per_active_learner: 0.035 },
  feedback: [],
  crashes: [],
  computed_at: '2026-11-24T12:00:00Z',
}
const SIGNUPS = [
  {
    id: '0b7e2c1a-8f3d-4c2b-9a1e-5d6f7a8b9c0d',
    name: 'Aino Virtanen',
    email: 'aino@example.fi',
    thanks_name: 'Aino V.',
    created_at: '2026-11-24T09:00:00+00:00',
  },
  {
    id: '1c8f3d2b-9a4e-4d3c-8b2f-6e7a8b9c0d1e',
    name: 'Eero Laine',
    email: 'eero@example.fi',
    thanks_name: null,
    created_at: '2026-11-23T15:30:00+00:00',
  },
]
const LINKS = [
  {
    id: '5a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d',
    signup_id: SIGNUPS[0]?.id,
    batch: 1,
    sent_at: '2026-11-24T10:00:00+00:00',
    lines: 212,
    answered: 37,
  },
]
const ANSWERS = [
  {
    link_id: LINKS[0]?.id,
    line_id: 1001,
    answer: 'needs_fix',
    note: 'In spoken Finnish the name usually comes first: "Maria, mä oon uus täällä."',
    answered_at: '2026-11-24T11:20:00+00:00',
    name: 'Aino Virtanen',
    dialogue: 'A new colleague',
    position: 2,
    speaker: 'Maria',
    spoken: 'Moi Pekka, mä oon Maria.',
    written: 'Hei Pekka, minä olen Maria.',
    english: "Hi Pekka, I'm Maria.",
  },
  {
    link_id: LINKS[0]?.id,
    line_id: 1002,
    answer: 'not_sure',
    note: null,
    answered_at: '2026-11-24T11:05:00+00:00',
    name: 'Aino Virtanen',
    dialogue: 'A new colleague',
    position: 3,
    speaker: 'Pekka',
    spoken: 'Ootsä uus täällä?',
    written: 'Oletko sinä uusi täällä?',
    english: 'Are you new here?',
  },
]

/** Given `hold`, every send waits for it, so a test can press again while the first send is open. */
async function fakeOwnerApi(page: Page, emailReady = true, hold?: Promise<void>) {
  const sends: Record<string, unknown>[] = []
  let links = [...LINKS]
  await page.route('**/api/owner/dashboard', (route) => json(route, 200, NUMBERS))
  await page.route('**/api/owner/reviewers', (route) => json(route, 200, { signups: SIGNUPS }))
  await page.route('**/api/owner/review-links', (route) =>
    json(route, 200, { links, answers: ANSWERS, emailReady }),
  )
  await page.route('**/api/owner/review-links/send', async (route) => {
    const body = JSON.parse(route.request().postData() ?? '{}') as { signupId: string; batch: number }
    sends.push(body)
    if (hold) await hold
    if (!emailReady) return json(route, 503, { error: 'email_not_set' })
    links = [
      {
        id: `new-${String(sends.length)}`,
        signup_id: body.signupId,
        batch: body.batch,
        sent_at: '2026-11-24T12:30:00+00:00',
        lines: 212,
        answered: 0,
      },
      ...links,
    ]
    return json(route, 201, { sent: true })
  })
  return sends
}

test.describe('the owner page review links', () => {
  test('[review-links 1] [review-links 6] each sign up has "Send review link" with batches 1 to 4; one press sends one', async ({
    page,
  }, testInfo) => {
    await page.setViewportSize({ width: 375, height: 812 })
    let release: () => void = () => undefined
    const held = new Promise<void>((resolve) => {
      release = resolve
    })
    const sends = await fakeOwnerApi(page, true, held)
    await page.goto('/learn/owner')
    const signups = page.locator('[data-owner="reviewers"] > li')
    await expect(signups).toHaveCount(2)
    const aino = signups.nth(0)
    await expect(
      aino.getByText('Batch 1 sent on 24 Nov 2026, 12:00. 37 of 212 lines answered.'),
    ).toBeVisible()
    await expect(signups.nth(1).getByText('No review link sent yet.')).toBeVisible()
    const batch = aino.getByLabel('Batch')
    await expect(batch).toHaveValue('2')
    expect(await batch.locator('option').allInnerTexts()).toEqual(['1', '2', '3', '4'])
    const send = aino.getByRole('button', { name: 'Send review link to Aino Virtanen' })
    // The second press lands while the first send is still open, and is ignored.
    await send.click()
    await send.click({ force: true })
    release()
    await expect(aino.getByRole('status').last()).toHaveText('Batch 2 sent.')
    expect(sends).toEqual([{ signupId: SIGNUPS[0]?.id, batch: 2 }])
    await expect(aino.getByText('Batch 2 sent on 24 Nov 2026, 14:30. 0 of 212 lines answered.')).toBeVisible()

    const answers = page.locator('[data-owner="review-answers"] > li')
    await expect(page.getByRole('heading', { level: 2, name: 'Review answers' })).toBeVisible()
    await expect(answers).toHaveCount(2)
    await expect(answers.nth(0)).toContainText('Needs a fix, from Aino Virtanen')
    await expect(answers.nth(0)).toContainText('In spoken Finnish the name usually comes first')
    await expect(answers.nth(1)).toContainText('Not sure, from Aino Virtanen')
    expect(await scrollsSideways(page)).toBe(false)

    if (testInfo.project.name === 'chromium') {
      await page.getByRole('heading', { level: 2, name: 'Reviewer sign-ups' }).scrollIntoViewIfNeeded()
      await picture(page, '1-6-owner-send-and-answers-375x812')
      await page.setViewportSize({ width: 1440, height: 900 })
      await picture(page, '1-6-owner-send-and-answers-desktop-1440x900')
    }
  })

  test('[review-links 1] without the Brevo settings the owner page says so, and a press sends nothing', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    const sends = await fakeOwnerApi(page, false)
    await page.goto('/learn/owner')
    await expect(
      page.getByText(
        'Email sending is not set up on this Worker (BREVO_API_KEY is missing), so no review link can be sent.',
      ),
    ).toBeVisible()
    const aino = page.locator('[data-owner="reviewers"] > li').nth(0)
    await aino.getByRole('button', { name: 'Send review link to Aino Virtanen' }).click()
    await expect(aino.getByRole('status').last()).toHaveText(
      'Email sending is not set up on this Worker (BREVO_API_KEY is missing), so no review link can be sent.',
    )
    expect(sends).toHaveLength(1)
  })
})
