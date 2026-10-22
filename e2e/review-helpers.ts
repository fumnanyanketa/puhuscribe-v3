import { resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { expect, type Page } from '@playwright/test'
import { linesOf, one, sessionsOf, sql, userIdOf } from './db.ts'
import {
  answerChoices,
  finishHearIt,
  finishUnderstandIt,
  questionLineId,
  startSession,
} from './session-helpers.ts'

// Shared steps for the daily review browser tests
// (factory/jobs/9-daily-review/spec.md). Expected content always comes from
// the throwaway local database (e2e/db.ts), never from text written here, so
// the tests also pass when job 7's real dialogues come first. Nothing here
// prints a row, a cookie or a token.

/**
 * "A day later": moves every card time of this learner back 24 hours, in the
 * throwaway local database only (spec, terms of "Done when").
 */
export function dayLater(userId: string): void {
  sql(
    `update public.cards
        set created_at = created_at - interval '24 hours',
            due = due - interval '24 hours',
            last_review = last_review - interval '24 hours'
      where user_id = :'uid'`,
    { uid: userId },
  )
}

/** Ends every other readable dialogue for this learner, so no new dialogue is ready. */
export function finishEveryOtherDialogue(userId: string): void {
  sql(
    `insert into public.sessions (user_id, dialogue_id, step_reached, started_at, ended_at)
     select :'uid', d.id, 'understand', now(), now()
       from public.dialogues d join public.units u on u.id = d.unit_id
      where d.status = 'approved' and u.status = 'approved'
        and not exists (select 1 from public.sessions s
                         where s.user_id = :'uid' and s.dialogue_id = d.id and s.ended_at is not null)`,
    { uid: userId },
  )
}

/** The form's spoken and written shapes. */
export function shapesOf(formId: string): { spoken: string; written: string } {
  const [row] = sql(`select surface_puhe, surface_kirja from public.forms where id = :fid`, { fid: formId })
  return { spoken: row?.[0] ?? '', written: row?.[1] ?? '' }
}

/** Runs the first session from the front door to its finish screen and back to the front door. */
export async function finishFirstSession(page: Page): Promise<{ userId: string; dialogueId: string }> {
  await startSession(page)
  const userId = await userIdOf(page.context())
  const dialogueId = sessionsOf(userId)[0]?.dialogueId ?? ''
  const lines = linesOf(dialogueId)
  await finishHearIt(page)
  await finishUnderstandIt(page, (lineId) => lines.find((line) => line.id === lineId)?.gloss ?? '')
  await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
  await page.getByRole('button', { name: 'Done' }).click()
  await page.waitForURL((url) => url.pathname === '/')
  return { userId, dialogueId }
}

/**
 * Answers Understand it right until the next screen is Keep it (or the
 * finish screen). Used for a session that ends with Keep it, where job 8's
 * helper would wait for the finish screen.
 */
export async function throughUnderstandIt(page: Page, userId: string): Promise<void> {
  await finishHearIt(page)
  const dialogueId = sessionsOf(userId).find((s) => !s.ended && s.dialogueId !== '')?.dialogueId ?? ''
  const lines = linesOf(dialogueId)
  const keepIt = page.getByRole('heading', { level: 1, name: 'Keep it' })
  const done = page.getByRole('heading', { level: 1, name: 'Now you can say this.' })
  for (;;) {
    const lineId = await questionLineId(page)
    const gloss = lines.find((line) => line.id === lineId)?.gloss ?? ''
    await answerChoices(page).getByRole('button', { name: gloss, exact: true }).click()
    await page.getByRole('button', { name: 'Next', exact: true }).click()
    const seen = { state: 'waiting' }
    await expect
      .poll(
        async () => {
          if ((await keepIt.isVisible()) || (await done.isVisible())) seen.state = 'left'
          else {
            const now = await questionLineId(page)
            if (now !== '' && now !== lineId) seen.state = 'question'
          }
          return seen.state
        },
        { timeout: 10_000 },
      )
      .not.toBe('waiting')
    if (seen.state === 'left') return
  }
}

export const FIELD = 'Type the missing word'

/** Types an answer, using the "Type ä" and "Type ö" buttons for those letters. */
export async function typeAnswer(page: Page, text: string): Promise<void> {
  const field = page.getByLabel(FIELD, { exact: true })
  await field.click()
  let typed = ''
  for (const letter of text) {
    if (letter === 'ä' || letter === 'ö') {
      await page.getByRole('button', { name: `Type ${letter}` }).click()
    } else {
      await page.keyboard.type(letter)
    }
    typed += letter
    await expect(field).toHaveValue(typed)
  }
  await expect(field).toBeFocused()
}

export type Move = 'right' | 'close' | 'wrong' | 'dont_know'

export interface Answered {
  formId: string
  retry: boolean
  move: Move
  /** The status line after Check. */
  status: string
}

/** A close answer: the spoken shape with its last letter changed. */
export function closeTo(shape: string): string {
  return `${shape.slice(0, -1)}${shape.endsWith('q') ? 'z' : 'q'}`
}

/** The form id of the review item on screen. */
export async function itemFormId(page: Page): Promise<string> {
  return (await page.locator('[data-review-item]').first().getAttribute('data-review-item')) ?? ''
}

/**
 * Answers one review item as `move` says and presses Check (or Enter, or "I
 * don't remember"), then waits for the feedback.
 */
export async function answerItem(
  page: Page,
  move: Move,
  submit: 'enter' | 'check' = 'enter',
): Promise<string> {
  const formId = await itemFormId(page)
  const { spoken } = shapesOf(formId)
  if (move === 'dont_know') {
    await page.getByRole('button', { name: "I don't remember" }).click()
  } else {
    const text = move === 'right' ? spoken : move === 'close' ? closeTo(spoken) : 'qqqqqqq'
    await typeAnswer(page, text)
    if (submit === 'enter') await page.keyboard.press('Enter')
    else await page.getByRole('button', { name: 'Check', exact: true }).click()
  }
  await expect(page.locator(`[data-review-feedback="${formId}"]`)).toBeVisible()
  return formId
}

/** After the feedback, presses Next and waits for the next item or the end of Keep it. */
export async function nextItem(page: Page): Promise<void> {
  await page.getByRole('button', { name: 'Next', exact: true }).click()
  await expect(page.locator('[data-review-feedback]')).toHaveCount(0, { timeout: 10_000 })
}

/** Whether Keep it is still running (an item is on screen). */
export async function onItem(page: Page): Promise<boolean> {
  const item = page.locator('[data-review-item]')
  const end = page
    .getByRole('heading', { level: 1, name: 'Now you can say this.' })
    .or(page.getByRole('heading', { level: 1, name: 'Review finished.' }))
  await expect(item.or(end).first()).toBeVisible()
  return (await item.count()) > 0
}

/** Runs Keep it to the end; `decide` picks the move for each item. */
export async function runKeepIt(
  page: Page,
  decide: (formId: string, retry: boolean, index: number) => Move = () => 'right',
): Promise<Answered[]> {
  const answered: Answered[] = []
  while (await onItem(page)) {
    const formId = await itemFormId(page)
    const retry = (await page.getByText('One more try at this word.', { exact: true }).count()) > 0
    const move = decide(formId, retry, answered.length)
    await answerItem(page, move)
    answered.push({ formId, retry, move, status: (await page.getByRole('status').innerText()).trim() })
    await nextItem(page)
  }
  return answered
}

export interface LogRow {
  formId: string
  rating: number
  mode: string
  state: string
  due: number
  stability: number
  difficulty: number
  elapsedDays: number
  lastElapsedDays: number
  scheduledDays: number
  reviewTime: number
}

const MS = (column: string) => `(extract(epoch from ${column}) * 1000)::bigint`

export function logsOf(userId: string): LogRow[] {
  return sql(
    `select form_id, rating, mode, state, ${MS('due')}, stability, difficulty, elapsed_days,
            last_elapsed_days, scheduled_days, ${MS('review_time')}
       from public.review_logs where user_id = :'uid' order by review_time, form_id`,
    { uid: userId },
  ).map((r) => ({
    formId: r[0] ?? '',
    rating: Number(r[1]),
    mode: r[2] ?? '',
    state: r[3] ?? '',
    due: Number(r[4]),
    stability: Number(r[5]),
    difficulty: Number(r[6]),
    elapsedDays: Number(r[7]),
    lastElapsedDays: Number(r[8]),
    scheduledDays: Number(r[9]),
    reviewTime: Number(r[10]),
  }))
}

export interface CardValues {
  due: number
  stability: number
  difficulty: number
  elapsedDays: number
  scheduledDays: number
  reps: number
  lapses: number
  state: string
  lastReview: number | null
}

export function cardOf(userId: string, formId: string): CardValues | null {
  const [r] = sql(
    `select ${MS('due')}, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state,
            coalesce(${MS('last_review')}::text, '')
       from public.cards where user_id = :'uid' and form_id = :fid`,
    { uid: userId, fid: formId },
  )
  if (!r) return null
  return {
    due: Number(r[0]),
    stability: Number(r[1]),
    difficulty: Number(r[2]),
    elapsedDays: Number(r[3]),
    scheduledDays: Number(r[4]),
    reps: Number(r[5]),
    lapses: Number(r[6]),
    state: r[7] ?? '',
    lastReview: r[8] ? Number(r[8]) : null,
  }
}

// v2's scheduler, loaded at run time. Playwright compiles it on the fly; the
// strict type check of e2e/ never reads v2's files (see docs/v2-imports.md).
interface EngineCard {
  due: Date
  stability: number
  difficulty: number
  elapsed_days: number
  scheduled_days: number
  reps: number
  lapses: number
  state: string
  last_review: Date | null
}
interface Engine {
  FSRS: new () => { schedule: (card: EngineCard, rating: number, now: Date) => { card: EngineCard } }
}

/**
 * The card values the same engine computes from a card's stored review logs:
 * a new card (createEmptyCard, due at the first log's due time), scheduled
 * once per log with its rating at its stored review time.
 */
export async function engineCard(logs: readonly LogRow[]): Promise<CardValues> {
  const url = pathToFileURL(resolve('src/lib/fsrs/scheduler.ts')).href
  const engine = (await import(url)) as Engine
  const first = logs[0]
  if (!first) throw new Error('No review log to compute from.')
  let card: EngineCard = {
    due: new Date(first.due),
    stability: 0,
    difficulty: 0,
    elapsed_days: 0,
    scheduled_days: 0,
    reps: 0,
    lapses: 0,
    state: 'new',
    last_review: null,
  }
  for (const log of logs) card = new engine.FSRS().schedule(card, log.rating, new Date(log.reviewTime)).card
  return {
    due: card.due.getTime(),
    stability: card.stability,
    difficulty: card.difficulty,
    elapsedDays: card.elapsed_days,
    scheduledDays: card.scheduled_days,
    reps: card.reps,
    lapses: card.lapses,
    state: card.state,
    lastReview: card.last_review ? card.last_review.getTime() : null,
  }
}

/** How many review logs this learner has. */
export function logCount(userId: string): number {
  return Number(one(`select count(*) from public.review_logs where user_id = :'uid'`, { uid: userId }))
}
