import { expect, test, type Page } from '@playwright/test'
import {
  ACCOUNT_NAMES,
  SCREEN_NAMES,
  costText,
  countryName,
  dayText,
  medianText,
  retentionText,
  speakBackText,
} from '../src/lib/owner-numbers.ts'
import { linesOf, one, sessionsOf, sql, userIdOf } from './db.ts'
import { stubMicrophone } from './microphone.ts'
import {
  addToOwnerList,
  appBrowser,
  dashboard,
  openOwnerPage,
  ownerAccount,
  ownerHostMissing,
  type Dashboard,
} from './owner-helpers.ts'
import { finishHearIt, finishUnderstandIt, serveTone, startSession } from './session-helpers.ts'

// Label [analytics 12] is "Done when" 12 of factory/jobs/14-analytics/spec.md.
//
// One test learner's journey moves each number of the owner page. It runs in
// its own Playwright project ("journey", playwright.config.ts) after every
// other browser test has finished, because other tests move the same totals.
// The learner's arrival carries the country the test sets in request.cf: the
// local Workers runtime takes it from the MF-CF-Blob header (a feature of the
// local runtime only; the live Worker gets request.cf from Cloudflare).
// Sessions are moved back in time in the throwaway database only (@seed).

/** Helsinki noon, some days ago, plus some minutes, as SQL. */
function noon(daysAgo: number, minutes = 0): string {
  return `((((now() at time zone 'Europe/Helsinki')::date - ${String(daysAgo)})::timestamp + interval '12 hours' + interval '${String(minutes)} minutes') at time zone 'Europe/Helsinki')`
}

/** The median used session length in minutes, worked out here from the rows, to one decimal. */
function expectedMedian(): number | null {
  const minutes = sql(
    `select extract(epoch from (s.ended_at - s.started_at)) / 60
       from public.sessions s
      where s.started_at >= ${noon(29, -720)}
        and s.ended_at is not null
        and s.ended_at - s.started_at <= interval '2 hours'
        and not exists (select 1 from private.owners o where o.user_id = s.user_id)`,
  )
    .map(([value = '0']) => Number(value))
    .sort((a, b) => a - b)
  if (minutes.length === 0) return null
  const middle = Math.floor(minutes.length / 2)
  const median =
    minutes.length % 2 === 1
      ? (minutes[middle] ?? 0)
      : ((minutes[middle - 1] ?? 0) + (minutes[middle] ?? 0)) / 2
  return Math.round(median * 10) / 10
}

async function sayOneLineAloud(page: Page): Promise<void> {
  await expect(page.getByRole('heading', { level: 1, name: 'Speaking feedback' })).toBeVisible()
  await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
  await expect(page.getByRole('heading', { level: 1, name: 'Say it' })).toBeVisible()
  const record = page.getByRole('button', { name: 'Record yourself saying the line' })
  await record.click()
  await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
  await page.waitForTimeout(1_200)
  await page.getByRole('button', { name: /^Stop recording/ }).click()
  await expect(record).toBeVisible({ timeout: 20_000 })
  // One check is enough; the quiet exit skips the other lines (job 10, "Done when" 6).
  await page.getByRole('button', { name: "I can't speak right now", exact: true }).click()
  await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
  await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
}

function today(d: Dashboard) {
  return d.visits_by_day[0] ?? { day: '', visits: 0, fi: 0 }
}

function finland(d: Dashboard): number {
  return d.visits_by_country.find((c) => c.country === 'FI')?.visits ?? 0
}

test(
  '[analytics 12] a test learner journey moves each owner page number, each checked on its own',
  {
    tag: ['@seed', '@email'],
  },
  async ({ browser, baseURL }, testInfo) => {
    test.skip(ownerHostMissing() !== null, ownerHostMissing() ?? '')
    test.setTimeout(180_000)

    // The owner, signed in on the owner host and on the owner list.
    const { page: owner, userId: ownerId } = await ownerAccount(browser, testInfo, baseURL)
    addToOwnerList(ownerId)

    // The starting numbers, as the page shows them.
    await openOwnerPage(owner)
    const before = await dashboard(owner)
    await expect(owner.getByText(retentionText(before.day7_retention), { exact: true })).toBeVisible()
    await expect(owner.getByText(medianText(before.median_session_minutes), { exact: true })).toBeVisible()
    await expect(owner.getByText(speakBackText(before.speak_back), { exact: true })).toBeVisible()
    await expect(owner.getByText(costText(before.ai_cost_usd), { exact: true })).toBeVisible()

    // A test learner arrives from Finland, with a normal browser.
    const learnerContext = await appBrowser(browser, testInfo, baseURL, {
      'MF-CF-Blob': JSON.stringify({ country: 'FI' }),
    })
    const learner = await learnerContext.newPage()
    await stubMicrophone(learner, 'tone')
    await serveTone(learner)
    await startSession(learner)
    const learnerId = await userIdOf(learnerContext)
    const session = sessionsOf(learnerId)[0]
    const lines = linesOf(session?.dialogueId ?? '')
    await finishHearIt(learner)
    await finishUnderstandIt(learner, (lineId) => lines.find((line) => line.id === lineId)?.gloss ?? '')
    // One speech check with the fake provider: its cost is recorded.
    await sayOneLineAloud(learner)
    const cost = Number(
      one(`select coalesce(sum(cost_usd), 0) from public.speaking_attempts where user_id = :'uid'`, {
        uid: learnerId,
      }),
    )
    expect(
      Number(one(`select count(*) from public.speaking_attempts where user_id = :'uid'`, { uid: learnerId })),
    ).toBe(1)

    // Feedback from the finish screen.
    const message = `Journey feedback ${String(Date.now())}`
    await learner.getByRole('link', { name: 'Send feedback' }).click()
    await learner.getByLabel('Your message').fill(message)
    await learner.getByRole('button', { name: 'Send', exact: true }).click()
    await expect(learner.getByRole('status')).toHaveText('Thank you. Your message is sent.')

    // A browser error.
    const sent = learner.waitForResponse((res) => res.url().endsWith('/api/crash'))
    await learner.evaluate(() => {
      const error = new Error('A test error from the journey.')
      error.name = 'JourneyTestError'
      setTimeout(() => {
        throw error
      }, 0)
    })
    expect((await sent).status()).toBe(204)
    await learnerContext.close()

    // The learner's first session moves to day D (8 days ago, 6 minutes long)
    // and the session just finished to D + 7 (yesterday, 10 minutes long).
    sql(`update public.sessions set started_at = ${noon(1)}, ended_at = ${noon(1, 10)} where id = :'sid'`, {
      sid: session?.id ?? '',
    })
    sql(
      `insert into public.sessions (user_id, started_at, ended_at) values (:'uid', ${noon(8)}, ${noon(8, 6)})`,
      { uid: learnerId },
    )
    const median = expectedMedian()

    await openOwnerPage(owner)
    const after = await dashboard(owner)

    // 1. Visits by day: one more today, and one more from Finland.
    expect(today(after).day).toBe(today(before).day)
    expect(today(after).visits).toBe(today(before).visits + 1)
    expect(today(after).fi).toBe(today(before).fi + 1)
    const row = owner.getByRole('table', { name: 'Visits by day, last 30 days' }).getByRole('row', {
      name: new RegExp(`^${dayText(today(after).day)} `),
    })
    await expect(row.getByRole('cell').nth(0)).toHaveText(String(today(after).visits))
    await expect(row.getByRole('cell').nth(1)).toHaveText(String(today(after).fi))

    // 2. Visits by country: one more from Finland.
    expect(finland(after)).toBe(finland(before) + 1)
    await expect(
      owner
        .getByRole('table', { name: 'Visits by country, last 30 days' })
        .getByRole('row', { name: new RegExp(`^${countryName('FI')} `) })
        .getByRole('cell'),
    ).toHaveText(String(finland(after)))

    // 3. Active learners: one more.
    expect(after.active_learners).toBe(before.active_learners + 1)
    await expect(
      owner
        .locator('div', { has: owner.getByRole('heading', { level: 3, name: 'Active learners' }) })
        .last()
        .locator('p')
        .first(),
    ).toHaveText(String(after.active_learners))

    // 4. Day 7 retention: one more learner in the cohort, and retained.
    expect(after.day7_retention.cohort).toBe(before.day7_retention.cohort + 1)
    expect(after.day7_retention.retained).toBe(before.day7_retention.retained + 1)
    await expect(owner.getByText(retentionText(after.day7_retention), { exact: true })).toBeVisible()

    // 5. Median session: two more finished sessions, and the median of all of them.
    expect(after.median_session_minutes.used).toBe(before.median_session_minutes.used + 2)
    expect(after.median_session_minutes.left_out).toBe(before.median_session_minutes.left_out)
    expect(after.median_session_minutes.minutes).toBe(median)
    await expect(owner.getByText(medianText(after.median_session_minutes), { exact: true })).toBeVisible()

    // 6. Speak back: one more learner who spoke, of one more active learner.
    expect(after.speak_back.count).toBe(before.speak_back.count + 1)
    expect(after.speak_back.base).toBe(before.speak_back.base + 1)
    await expect(owner.getByText(speakBackText(after.speak_back), { exact: true })).toBeVisible()

    // 7. Cost: the speech check's recorded cost is added.
    expect(after.ai_cost_usd.total).toBeCloseTo(before.ai_cost_usd.total + cost, 8)
    await expect(owner.getByText(costText(after.ai_cost_usd), { exact: true })).toBeVisible()

    // The feedback list: the message first, from the finish screen, a guest.
    expect(after.feedback[0]).toMatchObject({ message, screen: 'finish', account: 'guest' })
    const newest = owner.locator('[data-owner="feedback"] > li').first()
    await expect(newest).toContainText(message)
    await expect(newest).toContainText(`${SCREEN_NAMES.finish ?? ''}. ${ACCOUNT_NAMES.guest ?? ''}.`)

    // The crash list: the learner's error.
    expect(after.crashes.some((c) => c.name === 'JourneyTestError' && c.path === '/feedback')).toBe(true)
    await expect(
      owner.locator('[data-owner="crashes"] > li').filter({ hasText: 'JourneyTestError' }),
    ).toBeVisible()
  },
)
