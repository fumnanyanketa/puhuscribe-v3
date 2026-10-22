import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Locator, type Page } from '@playwright/test'
import { recordApiTimings } from './api-timing.ts'
import { linesOf, one, sessionsOf, sql, userIdOf } from './db.ts'
import {
  finishHearIt,
  finishUnderstandIt,
  scrollsSideways,
  serveTone,
  startSession,
  tabTo,
} from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/12-units-1-3/spec.md that each test protects.
//
// The "Patterns you've seen" panel, at phone size (375 x 812) in Chromium and
// WebKit, against the built app and the throwaway local Supabase of the pull
// request check, with the test fixture units of supabase/seeds/browser/
// loaded (job 8's unit 1 at 900, job 12's units 2 and 3 at 901 and 902).
// Every test is tagged @seed, so it never runs against the shared test
// project. Expected content is read from the database. Audio requests are
// answered with a generated tone.

interface ShownForm {
  spoken: string
  written: string
  lemma: string
  why: string
  lineSpoken: string
  lineWritten: string
}
interface ShownGroup {
  name: string
  forms: ShownForm[]
}

const PANEL = "Patterns you've seen"
const INTRO = 'Word forms from the dialogues you have met, grouped by pattern.'

function panelOf(page: Page): Locator {
  return page.getByRole('dialog', { name: PANEL })
}

/** What the panel shows, read from the page in reading order. */
async function shownGroups(page: Page): Promise<ShownGroup[]> {
  // e2e/ has no DOM types, so the page code is a string (as in session-helpers.ts).
  return page.evaluate<ShownGroup[]>(`
    [...document.querySelectorAll('dialog[data-testid="patterns-panel"] section')].map((section) => ({
      name: section.querySelector('h3')?.textContent ?? '',
      forms: [...section.querySelectorAll('li')].map((li) => {
        const fi = [...li.querySelectorAll('[lang="fi"]')].map((el) => el.textContent ?? '')
        return {
          spoken: fi[0] ?? '',
          written: fi[1] ?? '',
          lemma: fi[2] ?? '',
          why: li.querySelector('dd:not([lang])')?.textContent ?? '',
          lineSpoken: fi[3] ?? '',
          lineWritten: fi[4] ?? '',
        }
      }),
    }))
  `)
}

/**
 * What the panel must show, from the database: the approved forms the learner
 * has a card for plus those of the current session, each with its earliest
 * line (by unit, dialogue and line position) in a dialogue whose session
 * finished Understand it or is the current one. Groups and forms in the order
 * of first meeting, ties by base form.
 */
function expectedGroups(userId: string, sessionId: string): ShownGroup[] {
  const rows = sql(
    `with cur as (
       select id, dialogue_id from public.sessions where id = :'sid' and user_id = :'uid'),
     met as (
       select s.dialogue_id, min(s.started_at) as first_start from public.sessions s
        where s.user_id = :'uid' and s.dialogue_id is not null
          and (s.step_reached >= 'understand' or s.id in (select id from cur))
        group by s.dialogue_id),
     met_lines as (
       select l.id, l.text_puhe, l.text_kirja, u.position as upos, d.position as dpos, l.position as lpos,
              m.first_start
         from public.dialogue_lines l
         join public.dialogues d on d.id = l.dialogue_id
         join public.units u on u.id = d.unit_id
         join met m on m.dialogue_id = d.id
        where l.status = 'approved' and d.status = 'approved' and u.status = 'approved'),
     shown as (
       select form_id from public.cards where user_id = :'uid'
       union
       select t.form_id from public.tokens t join public.dialogue_lines l on l.id = t.line_id
        where l.dialogue_id in (select dialogue_id from cur) and t.form_id is not null),
     hits as (
       select f.id, f.form_name_en, f.lemma, f.surface_puhe, f.surface_kirja, f.why_en,
              ml.text_puhe, ml.text_kirja, ml.upos, ml.dpos, ml.lpos, ml.first_start
         from public.forms f
         join shown s on s.form_id = f.id
         join public.tokens t on t.form_id = f.id
         join met_lines ml on ml.id = t.line_id
        where f.status = 'approved')
     select distinct on (h.id) h.form_name_en, h.lemma, h.surface_puhe, h.surface_kirja, h.why_en,
            h.text_puhe, h.text_kirja,
            to_char((select min(x.first_start) from hits x where x.id = h.id) at time zone 'UTC',
                    'YYYY-MM-DD"T"HH24:MI:SS.US')
       from hits h order by h.id, h.upos, h.dpos, h.lpos`,
    { uid: userId, sid: sessionId },
  ).map(
    ([
      name = '',
      lemma = '',
      puhe = '',
      kirja = '',
      why = '',
      linePuhe = '',
      lineKirja = '',
      first = '',
    ]) => ({
      name,
      first,
      form: { spoken: puhe, written: kirja, lemma, why, lineSpoken: linePuhe, lineWritten: lineKirja },
    }),
  )
  const cmp = (a: string, b: string) => (a < b ? -1 : a > b ? 1 : 0)
  rows.sort(
    (a, b) =>
      cmp(a.first, b.first) ||
      cmp(a.form.lemma, b.form.lemma) ||
      cmp(a.form.written, b.form.written) ||
      cmp(a.form.spoken, b.form.spoken),
  )
  const groups: ShownGroup[] = []
  for (const row of rows) {
    let group = groups.find((g) => g.name === row.name)
    if (!group) {
      group = { name: row.name, forms: [] }
      groups.push(group)
    }
    group.forms.push(row.form)
  }
  return groups
}

/** The learner's open session (the current one). */
function currentSession(userId: string): { id: string; dialogueId: string } {
  const open = sessionsOf(userId).filter((s) => !s.ended)
  const row = open[open.length - 1]
  if (!row) throw new Error('The learner has no open session.')
  return row
}

/** Opens the word card of the first word with a card on screen and returns its button. */
async function openFirstCard(page: Page): Promise<{ word: Locator; card: Locator }> {
  const word = page.locator('ol [lang="fi"] button').first()
  const name = (await word.innerText()).trim()
  await word.click()
  const card = page.getByRole('dialog', { name })
  await expect(card).toBeVisible()
  return { word, card }
}

async function openPanel(page: Page): Promise<{ card: Locator; button: Locator }> {
  const { card } = await openFirstCard(page)
  const button = card.getByRole('button', { name: PANEL })
  await button.click()
  await expect(panelOf(page)).toBeVisible()
  await expect(panelOf(page).getByRole('heading', { level: 3 }).first()).toBeVisible()
  return { card, button }
}

/** Finishes today's session through the screens, then goes back to the front door. */
async function finishTodaysSession(page: Page): Promise<void> {
  const userId = await userIdOf(page.context())
  const lines = linesOf(currentSession(userId).dialogueId)
  await finishHearIt(page)
  await finishUnderstandIt(page, (id) => lines.find((l) => l.id === id)?.gloss ?? '')
  await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
  await page.getByRole('button', { name: 'Done' }).click()
  await page.waitForURL((url) => url.pathname === '/')
}

async function startNext(page: Page): Promise<void> {
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
}

test.describe('Patterns you have seen', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }, testInfo) => {
    recordApiTimings(page, testInfo)
    await serveTone(page)
  })

  test('[units 9] [units 10] [units 12] a word card opens the panel at its group, with every field from the database', async ({
    page,
  }) => {
    await startSession(page)
    const userId = await userIdOf(page.context())
    const { card } = await openFirstCard(page)
    const formName = (
      await card
        .locator('dt')
        .filter({ hasText: /^Form$/ })
        .locator('xpath=following-sibling::dd')
        .innerText()
    ).trim()
    const asked = page.waitForRequest((r) => new URL(r.url()).pathname === '/api/patterns')
    await card.getByRole('button', { name: PANEL }).click()
    const request = await asked
    expect(request.method()).toBe('GET')
    expect(new URL(request.url()).searchParams.get('session')).toBe(currentSession(userId).id)

    const panel = panelOf(page)
    await expect(panel).toBeVisible()
    await expect(panel.getByRole('heading', { level: 2, name: PANEL })).toBeVisible()
    await expect(panel.getByText(INTRO, { exact: true })).toBeVisible()
    // Focus moves to the word card's own group, scrolled into view.
    const heading = panel.getByRole('heading', { level: 3, name: formName, exact: true })
    await expect(heading).toBeFocused()
    await expect(heading).toBeInViewport()

    const expected = expectedGroups(userId, currentSession(userId).id)
    expect(expected.length).toBeGreaterThan(0)
    expect(await shownGroups(page)).toEqual(expected)
    // Labels, Finnish marked as Finnish, and both play controls on every form.
    const forms = panel.locator('li')
    const count = await forms.count()
    for (let i = 0; i < count; i += 1) {
      const form = forms.nth(i)
      await expect(form.getByText('Spoken', { exact: true })).toHaveCount(2)
      await expect(form.getByText('Written', { exact: true })).toHaveCount(2)
      await expect(form.getByText('Base form', { exact: true })).toBeVisible()
      await expect(form.getByText('Why', { exact: true })).toBeVisible()
      await expect(form.getByRole('button', { name: 'Play the spoken line' })).toHaveCount(1)
      await expect(form.getByRole('button', { name: 'Play the written line' })).toHaveCount(1)
    }
    // The panel has no address of its own.
    expect(new URL(page.url()).pathname).toBe('/session')
  })

  test('[units 10] Close, Escape and a tap outside each return to the word card with focus on the button', async ({
    page,
  }) => {
    await startSession(page)
    const { card, button } = await openPanel(page)
    await panelOf(page).getByRole('button', { name: 'Close' }).click()
    await expect(panelOf(page)).toBeHidden()
    await expect(card).toBeVisible()
    await expect(button).toBeFocused()

    await button.click()
    await expect(panelOf(page)).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(panelOf(page)).toBeHidden()
    await expect(card).toBeVisible()
    await expect(button).toBeFocused()

    await button.click()
    await expect(panelOf(page)).toBeVisible()
    // The panel is a sheet at the bottom; the top of the screen is outside it.
    await page.mouse.click(187, 8)
    await expect(panelOf(page)).toBeHidden()
    await expect(card).toBeVisible()
    await expect(button).toBeFocused()
  })

  test('[units 11] two learners: each sees only the forms they met, with the earliest met line, and never draft, retired or unmet forms', async ({
    page,
    browser,
  }) => {
    // Learner A finishes the first dialogue, then starts the second.
    await startSession(page)
    const userA = await userIdOf(page.context())
    const firstDialogue = currentSession(userA).dialogueId
    await finishTodaysSession(page)
    await startNext(page)
    const secondDialogue = currentSession(userA).dialogueId
    expect(secondDialogue).not.toBe(firstDialogue)
    await openPanel(page)
    const shownA = await shownGroups(page)
    expect(shownA).toEqual(expectedGroups(userA, currentSession(userA).id))
    const keysA = shownA.flatMap((g) => g.forms.map((f) => `${f.lemma}|${f.written}|${f.spoken}`))

    // Every approved form of both met dialogues is there.
    const formsOf = (dialogueId: string) =>
      sql(
        `select distinct f.lemma, f.surface_kirja, f.surface_puhe
           from public.dialogue_lines l join public.tokens t on t.line_id = l.id
           join public.forms f on f.id = t.form_id
          where l.dialogue_id = :did and l.status = 'approved' and f.status = 'approved'`,
        { did: dialogueId },
      ).map((r) => r.join('|'))
    const metForms = [...formsOf(firstDialogue), ...formsOf(secondDialogue)]
    for (const key of metForms) expect(keysA).toContain(key)

    // Never a draft or retired form, or a form only in dialogues not met.
    const never = sql(
      `select f.lemma, f.surface_kirja, f.surface_puhe from public.forms f
        where f.status <> 'approved'
           or not exists (select 1 from public.tokens t join public.dialogue_lines l on l.id = t.line_id
                           where t.form_id = f.id and l.dialogue_id in (:d1, :d2))`,
      { d1: firstDialogue, d2: secondDialogue },
    ).map((r) => r.join('|'))
    expect(never.map((key) => key.split('|')[0])).toEqual(
      expect.arrayContaining(['kotoisin', 'todella', 'kahvi', 'kauramaito']),
    )
    for (const key of never) expect(keysA).not.toContain(key)

    // A form in both dialogues shows its line from the first one.
    const both = formsOf(firstDialogue).filter((key) => formsOf(secondDialogue).includes(key))
    const firstLines = linesOf(firstDialogue).map((l) => l.puhe)
    for (const key of both) {
      const shown = shownA.flatMap((g) => g.forms).find((f) => `${f.lemma}|${f.written}|${f.spoken}` === key)
      expect(firstLines, key).toContain(shown?.lineSpoken)
    }

    // Learner B, in a new browser, is in the first dialogue: none of learner A's second dialogue only forms.
    const other = await browser.newContext()
    const pageB = await other.newPage()
    await serveTone(pageB)
    await startSession(pageB)
    const userB = await userIdOf(other)
    expect(userB).not.toBe(userA)
    await openPanel(pageB)
    const shownB = await shownGroups(pageB)
    expect(shownB).toEqual(expectedGroups(userB, currentSession(userB).id))
    const keysB = shownB.flatMap((g) => g.forms.map((f) => `${f.lemma}|${f.written}|${f.spoken}`))
    for (const key of formsOf(secondDialogue)) {
      if (!formsOf(firstDialogue).includes(key)) expect(keysB).not.toContain(key)
    }
    await other.close()
  })

  test('[units 13] the panel shows no counts, scores, dates or practice: no digit outside the Finnish, why lines and form names', async ({
    page,
  }) => {
    await startSession(page)
    await openPanel(page)
    // The Finnish, the stored "why" lines and the form names (h3) are left out.
    const text = await page.evaluate<string>(`(() => {
      const copy = document.querySelector('dialog[data-testid="patterns-panel"]').cloneNode(true)
      for (const el of copy.querySelectorAll('[lang="fi"], dd:not([lang]), h3')) el.remove()
      return copy.textContent ?? ''
    })()`)
    expect(text).toContain('Base form')
    expect(text).not.toMatch(/\d/)
    await expect(panelOf(page).locator('input, textarea, progress, meter')).toHaveCount(0)
    await expect(panelOf(page).getByRole('button', { name: /record|practice|quiz|start/i })).toHaveCount(0)
  })

  test('[units 14] if loading fails the panel says so, and Try again loads it; the answer holds no user id', async ({
    page,
  }) => {
    await startSession(page)
    const userId = await userIdOf(page.context())
    await page.route('**/api/patterns**', (route) => route.abort())
    const { card } = await openFirstCard(page)
    await card.getByRole('button', { name: PANEL }).click()
    await expect(panelOf(page).getByText('Could not load your patterns.', { exact: true })).toBeVisible()
    await page.unroute('**/api/patterns**')
    const answer = page.waitForResponse((r) => new URL(r.url()).pathname === '/api/patterns')
    await panelOf(page).getByRole('button', { name: 'Try again' }).click()
    const body = await (await answer).text()
    await expect(panelOf(page).getByRole('heading', { level: 3 }).first()).toBeVisible()
    expect(body).not.toContain(userId)
    expect(body).not.toMatch(/user|stability|difficulty|"due"|"reps"|lapses/)
    // Nothing was written by opening the panel.
    expect(one(`select count(*) from public.cards where user_id = :'uid'`, { uid: userId })).toBe('0')
    expect(sessionsOf(userId)).toHaveLength(1)
  })

  test('[units 14] without an account the route answers 401', async ({ page }) => {
    const res = await page.request.get('/api/patterns')
    expect(res.status()).toBe(401)
  })

  test('[units 17] the panel fits 320 px and 200 percent text without sideways scrolling, with large enough tap areas', async ({
    page,
  }) => {
    await startSession(page)
    await openPanel(page)
    for (const [width, size] of [
      [320, '100%'],
      [375, '200%'],
    ] as const) {
      await page.setViewportSize({ width, height: 812 })
      await page.addStyleTag({ content: `html { font-size: ${size} !important; }` })
      expect(await scrollsSideways(page), `at ${String(width)} px, text ${size}`).toBe(false)
      const sideways = await page.evaluate<boolean>(
        `(() => { const el = document.querySelector('dialog[data-testid="patterns-panel"]'); return el.scrollWidth > el.clientWidth + 1 })()`,
      )
      expect(sideways, `panel at ${String(width)} px, text ${size}`).toBe(false)
      await page.addStyleTag({ content: 'html { font-size: 100% !important; }' })
    }
    await page.setViewportSize({ width: 375, height: 812 })
    for (const button of await panelOf(page).getByRole('button').all()) {
      await button.scrollIntoViewIfNeeded()
      const box = await button.boundingBox()
      const name = (await button.getAttribute('aria-label')) ?? (await button.innerText())
      expect(box?.height ?? 0, name).toBeGreaterThanOrEqual(44)
      expect(box?.width ?? 0, name).toBeGreaterThanOrEqual(44)
    }
    const patterns = page.getByRole('button', { name: PANEL })
    const box = await patterns.boundingBox()
    expect(box?.height ?? 0).toBeGreaterThanOrEqual(44)
    expect(box?.width ?? 0).toBeGreaterThanOrEqual(44)
  })

  test('[units 17] works with the keyboard alone', async ({ page }, testInfo) => {
    await startSession(page)
    const word = page.locator('ol [lang="fi"] button').first()
    await tabTo(page, word, testInfo)
    await page.keyboard.press('Enter')
    const button = page.getByRole('button', { name: PANEL })
    await tabTo(page, button, testInfo)
    await page.keyboard.press('Enter')
    await expect(panelOf(page)).toBeVisible()
    await expect(panelOf(page).getByRole('heading', { level: 3 }).first()).toBeVisible()
    await tabTo(page, panelOf(page).getByRole('button', { name: 'Close' }), testInfo)
    await page.keyboard.press('Enter')
    await expect(panelOf(page)).toBeHidden()
    await expect(button).toBeFocused()
    await page.keyboard.press('Escape')
    await expect(word).toBeFocused()
  })

  for (const scheme of ['light', 'dark'] as const) {
    test(`[units 17] axe finds no WCAG A or AA problem with the panel open, ${scheme}`, async ({ page }) => {
      await page.emulateMedia({ colorScheme: scheme })
      await startSession(page)
      await openPanel(page)
      await page.waitForTimeout(400)
      await page.evaluate('document.fonts.ready')
      const result = await new AxeBuilder({ page })
        .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
        .analyze()
      expect(
        result.violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
      ).toEqual([])
    })
  }
})
