import { readFileSync } from 'node:fs'
import { AxeBuilder } from '@axe-core/playwright'
import { expect, type Locator, type Page } from '@playwright/test'
import * as copy from '../src/screens/save-note-copy.ts'
import { startGuest } from './account-helpers.ts'
import { linesOf, sessionsOf, sql } from './db.ts'
import {
  finishHearIt,
  finishUnderstandIt,
  passSayIt,
  scrollsSideways,
  settleAnimations,
} from './session-helpers.ts'

// Shared steps for the save progress note browser tests
// (factory/jobs/18-save-progress/spec.md). Expected content comes from the
// database (e2e/db.ts) and the note's words from the one file that holds them
// (src/screens/save-note-copy.ts), never from text written here. Nothing here
// prints a code, a cookie or a token. No app path is written in this file:
// pages open through the helpers of the other e2e files and the address of the
// add email screen comes from the note's own constant (statement 17).

export { copy }

export const SAVED = 'Your progress is saved.'
export const SAVING = 'Saving your progress.'
export const NOT_SAVED = 'Your progress was not saved. Check your internet connection, then try again.'
export const COMES_BACK = 'The words you met will come back in your review.'
export const NOTE_SELECTOR = `section[aria-label="${copy.SAVE_NOTE_REGION}"]`

/** The note: a region named "Keep your progress". */
export function noteOf(page: Page): Locator {
  return page.getByRole('region', { name: copy.SAVE_NOTE_REGION, exact: true })
}

/** Zero of the note's region, sentence and follow up line. */
export async function expectNoNote(page: Page, label = ''): Promise<void> {
  await expect(noteOf(page), label).toHaveCount(0)
  await expect(page.getByText(copy.SAVE_NOTE_SENTENCE), label).toHaveCount(0)
  await expect(page.getByText(copy.SAVE_NOTE_CLOSED), label).toHaveCount(0)
}

export function normalise(text: string): string {
  return text.replace(/\s+/g, ' ').trim()
}

// The complete request ------------------------------------------------------------------

export interface CompleteAnswer {
  status: number
  body: unknown
}

/** Every answer to POST /api/sessions/<id>/complete the page gets, in order. */
export function recordCompleteAnswers(page: Page): CompleteAnswer[] {
  const answers: CompleteAnswer[] = []
  page.on('response', (response) => {
    const { pathname } = new URL(response.url())
    if (response.request().method() !== 'POST' || !/^\/api\/sessions\/[0-9a-f-]+\/complete$/.test(pathname)) {
      return
    }
    const status = response.status()
    void response.json().then(
      (body: unknown) => answers.push({ status, body }),
      () => answers.push({ status, body: null }),
    )
  })
  return answers
}

// Sessions -----------------------------------------------------------------------------------

/** From the Hear it screen of an open session to the finish screen's heading. */
export async function walkFromHearIt(page: Page, userId: string): Promise<void> {
  const open = sessionsOf(userId).find((s) => !s.ended)
  const lines = linesOf(open?.dialogueId ?? '')
  await finishHearIt(page)
  await finishUnderstandIt(page, (lineId) => lines.find((l) => l.id === lineId)?.gloss ?? '')
  await passSayIt(page)
}

/** A new guest walks the whole first session to the finish screen. The save may still be running. */
export async function walkToFinish(page: Page): Promise<string> {
  const userId = await startGuest(page)
  await walkFromHearIt(page, userId)
  return userId
}

/** The next session of a learner who has no open session: front door, Start, the whole loop. */
export async function walkNextSession(page: Page, userId: string): Promise<void> {
  await page.goto('/')
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
  await walkFromHearIt(page, userId)
}

/** The learner's open session, from the front door's "Continue" button. */
export async function walkContinuedSession(page: Page, userId: string): Promise<void> {
  await page.goto('/')
  await page.getByRole('button', { name: "Continue today's session" }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
  await walkFromHearIt(page, userId)
}

/**
 * Gives a guest two earlier finished dialogue sessions and the first_session_completed
 * event for the earliest, in the throwaway database only, so that the session the test
 * finishes next is the learner's third (statement 8). The first note is the event's
 * session, so without the event the third session would be the first.
 */
export function giveTwoEarlierFinishedSessions(userId: string): void {
  sql(
    `with picked as (
       select d.id, row_number() over (order by u.position, d.position) as n
         from public.dialogues d join public.units u on u.id = d.unit_id
        where d.status = 'approved' and u.status = 'approved'
        order by u.position, d.position limit 2)
     insert into public.sessions (user_id, dialogue_id, step_reached, started_at, ended_at)
     select :'uid', p.id, 'say', now() - interval '3 days', now() - interval '2 days' + p.n * interval '1 hour'
       from picked p`,
    { uid: userId },
  )
  sql(
    `insert into public.usage_events (user_id, name, session_id)
     select s.user_id, 'first_session_completed', s.id
       from public.sessions s
      where s.user_id = :'uid' and s.ended_at is not null
      order by s.ended_at limit 1`,
    { uid: userId },
  )
}

// What the add email screen says (job 11-accounts) ---------------------------------------------

/** SENDS_CODE and TAKEN_WARNING of src/screens/EmailFlow.tsx, read from the source so they are never copied here. */
export function emailScreenSentences(): { sendsCode: string; takenWarning: string } {
  const source = readFileSync('src/screens/EmailFlow.tsx', 'utf8')
  const read = (name: string) => {
    const found = new RegExp(`export const ${name} =\\s*'([^']+)'`).exec(source)?.[1]
    if (!found) throw new Error(`${name} not found in EmailFlow.tsx`)
    return found
  }
  return { sendsCode: read('SENDS_CODE'), takenWarning: read('TAKEN_WARNING') }
}

/** True when the page is the add email screen, with or without a base path. */
export function onAddEmailScreen(page: Page): boolean {
  return new URL(page.url()).pathname.endsWith(copy.ADD_EMAIL_PATH)
}

// The look ---------------------------------------------------------------------------------------

export async function axe(page: Page, label: string): Promise<void> {
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

/**
 * Axe on one part of a page that has endless animations (the reference page's loading rings), so
 * the colours cannot be waited for with settleAnimations. A short wait lets the colour change of a
 * switched scheme finish instead.
 */
export async function axeIn(page: Page, label: string, include: string): Promise<void> {
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(600)
  const result = await new AxeBuilder({ page })
    .include(include)
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
    .analyze()
  expect(
    result.violations.map((v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
  ).toEqual([])
}

/** The whole note is on screen and clear of the bottom action area (statement 14). */
export async function expectNoteFullyVisible(page: Page, label: string): Promise<void> {
  const note = noteOf(page)
  await expect(note, label).toBeInViewport({ ratio: 1 })
  const actions = page.getByRole('button', { name: 'Done', exact: true }).locator('xpath=..')
  const noteBox = await note.boundingBox()
  const actionBox = await actions.boundingBox()
  expect(noteBox, label).not.toBeNull()
  expect(actionBox, label).not.toBeNull()
  expect(
    (noteBox?.y ?? 0) + (noteBox?.height ?? 0),
    `${label}: the note ends above the action area`,
  ).toBeLessThanOrEqual((actionBox?.y ?? 0) + 0.5)
}

/** No sideways scroll at 320 px and at 375 px with text at 200 percent, and both buttons at least 44 x 44. */
export async function expectNoteFits(page: Page, label: string): Promise<void> {
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
  for (const name of [copy.SAVE_NOTE_ADD, copy.SAVE_NOTE_LATER]) {
    const box = await noteOf(page).getByRole('button', { name, exact: true }).boundingBox()
    expect(box?.height ?? 0, `${label}: ${name} height`).toBeGreaterThanOrEqual(44)
    expect(box?.width ?? 0, `${label}: ${name} width`).toBeGreaterThanOrEqual(44)
  }
}

export interface Storage {
  cookies: string[]
  localStorage: number
  sessionStorage: number
  documentCookie: string
}

/** What this page holds on the phone: cookie names and values, and the length of both storages. */
export async function storageOf(page: Page): Promise<Storage> {
  const cookies = (await page.context().cookies()).map((c) => `${c.name}=${c.value}`).sort()
  return {
    cookies,
    localStorage: await page.evaluate<number>('localStorage.length'),
    sessionStorage: await page.evaluate<number>('sessionStorage.length'),
    documentCookie: await page.evaluate<string>('document.cookie'),
  }
}

/** The name of the focused control: its aria-label, else its text. */
export async function focusedName(page: Page): Promise<string> {
  return page.evaluate<string>(
    '(document.activeElement?.getAttribute("aria-label") || document.activeElement?.textContent || "").trim()',
  )
}
