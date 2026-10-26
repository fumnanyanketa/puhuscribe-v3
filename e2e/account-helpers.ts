import { expect, type Browser, type BrowserContext, type Page, type TestInfo } from '@playwright/test'
import { linesOf, one, sessionsOf, sql, userIdOf } from './db.ts'
import { finishHearIt, finishUnderstandIt, serveTone } from './session-helpers.ts'

// Shared steps for the account browser tests (factory/jobs/11-accounts/spec.md).
//
// Mailpit is the local Supabase's mail catcher: every code email of the
// throwaway database lands there, and its API on this machine is read here.
// It never holds a real address: tests use the reserved domain example.com.
// Nothing here prints a code, a cookie or a token.

const MAILPIT_URL = process.env.MAILPIT_URL ?? 'http://127.0.0.1:54324'

function mailpit(path: string, init?: RequestInit): Promise<Response> {
  if (!/^http:\/\/(127\.0\.0\.1|localhost):\d+$/.test(MAILPIT_URL)) {
    throw new Error('MAILPIT_URL must point at Mailpit on this machine.')
  }
  return fetch(`${MAILPIT_URL}${path}`, init)
}

export interface Mail {
  id: string
  subject: string
  text: string
  html: string
  code: string
}

interface Summary {
  ID: string
}

async function messagesTo(address: string): Promise<Summary[]> {
  const res = await mailpit(`/api/v1/search?query=${encodeURIComponent(`to:"${address}"`)}`)
  if (!res.ok) throw new Error(`Mailpit search answered ${String(res.status)}.`)
  const body = (await res.json()) as { messages?: Summary[] }
  return body.messages ?? []
}

async function readMail(id: string): Promise<Mail> {
  const res = await mailpit(`/api/v1/message/${encodeURIComponent(id)}`)
  if (!res.ok) throw new Error(`Mailpit message answered ${String(res.status)}.`)
  const body = (await res.json()) as { Subject?: string; Text?: string; HTML?: string }
  const text = body.Text ?? ''
  const code = /\b(\d{6})\b/.exec(text)?.[1] ?? /\b(\d{6})\b/.exec(body.HTML ?? '')?.[1] ?? ''
  return { id, subject: body.Subject ?? '', text, html: body.HTML ?? '', code }
}

/** How many emails Mailpit holds for an address. */
export async function mailCount(address: string): Promise<number> {
  return (await messagesTo(address)).length
}

/** Waits for a new email to the address (one not in `seen`) and returns it. */
export async function nextMail(address: string, seen: string[] = []): Promise<Mail> {
  let found: Summary | undefined
  await expect
    .poll(
      async () => {
        found = (await messagesTo(address)).find((m) => !seen.includes(m.ID))
        return Boolean(found)
      },
      { timeout: 20_000, message: 'no code email arrived in Mailpit' },
    )
    .toBe(true)
  if (!found) throw new Error('No email.')
  return readMail(found.ID)
}

/** The ids of every email to the address so far. */
export async function mailIds(address: string): Promise<string[]> {
  return (await messagesTo(address)).map((m) => m.ID)
}

/** A fresh address on the reserved example.com domain, unique to this test. */
export function testAddress(name: string, testInfo: TestInfo): string {
  const id = `${testInfo.project.name}-${String(Date.now())}-${String(Math.floor(Math.random() * 1e6))}`
  return `${name}-${id}@example.com`
}

// The database, read for checks ------------------------------------------------------

/**
 * Every user table and its user columns, from the database catalogue: tables
 * in a schema this project creates with a user_id column or a link to
 * auth.users (the same rule as supabase/tests/database/accounts.test.sql).
 */
export function userTables(): { schema: string; table: string; column: string }[] {
  return sql(`
    select n.nspname, c.relname, a.attname
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      join pg_attribute a on a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
     where c.relkind in ('r', 'p') and not c.relispartition
       and n.nspname not in ('pg_catalog', 'information_schema', 'auth', 'storage', 'realtime', '_realtime',
         'extensions', 'graphql', 'graphql_public', 'pgsodium', 'pgsodium_masks', 'vault', 'supabase_functions',
         'supabase_migrations', 'net', 'cron', 'pgbouncer', '_analytics', 'pgtle', 'pgmq', '_supavisor',
         'topology', 'tiger', 'tiger_data')
       and n.nspname not like 'pg\\_toast%' and n.nspname not like 'pg\\_temp%'
       and (a.attname = 'user_id'
            or exists (select 1 from pg_constraint k where k.conrelid = c.oid and k.contype = 'f'
                         and k.confrelid = 'auth.users'::regclass and a.attnum = any (k.conkey)))
     order by 1, 2, 3`).map(([schema = '', table = '', column = '']) => ({ schema, table, column }))
}

/** The rows a user has in every user table, by table, read from the catalogue. */
export function rowsOf(userId: string): Record<string, number> {
  const counts: Record<string, number> = {}
  for (const { schema, table, column } of userTables()) {
    const key = schema === 'public' ? table : `${schema}.${table}`
    const n = Number(
      one(`select count(*) from "${schema}"."${table}" where "${column}" = :'uid'`, { uid: userId }),
    )
    counts[key] = (counts[key] ?? 0) + n
  }
  return counts
}

/** Every row of the user's sessions, cards and usage events, as JSON text, in a fixed order. */
export function snapshotOf(userId: string): { sessions: string[]; cards: string[]; usage_events: string[] } {
  const rows = (table: string, order: string) =>
    sql(`select to_jsonb(t)::text from public.${table} t where t.user_id = :'uid' order by ${order}`, {
      uid: userId,
    }).map(([row = '']) => row)
  return {
    sessions: rows('sessions', 'id'),
    cards: rows('cards', 'form_id'),
    usage_events: rows('usage_events', 'id'),
  }
}

export function authUser(userId: string): { exists: boolean; anonymous: boolean; email: string } {
  const row = sql(`select is_anonymous, coalesce(email, '') from auth.users where id = :'uid'`, {
    uid: userId,
  })[0]
  return { exists: Boolean(row), anonymous: row?.[0] === 't', email: row?.[1] ?? '' }
}

export function userCount(): number {
  return Number(one('select count(*) from auth.users'))
}

// The app ------------------------------------------------------------------------------

/** Starts and finishes today's session (job 8's flow), and returns the user id. */
export async function finishTodaysSession(page: Page): Promise<string> {
  await serveTone(page)
  await page.goto('/')
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
  const userId = await userIdOf(page.context())
  const open = sessionsOf(userId).find((s) => !s.ended)
  const lines = linesOf(open?.dialogueId ?? '')
  await finishHearIt(page)
  await finishUnderstandIt(page, (lineId) => lines.find((l) => l.id === lineId)?.gloss ?? '')
  await expect(page.getByRole('status')).toHaveText('Your progress is saved.')
  return userId
}

/** A new guest: Start on the front door, then back to the front door. */
export async function startGuest(page: Page): Promise<string> {
  await serveTone(page)
  await page.goto('/')
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  // Wait for the session screen to finish loading. A test that deletes the
  // account while POST /api/sessions/today is still in flight lets that
  // request find the account gone and clear the cookies first (statement 22),
  // so the front door can no longer tell a guest was here (CI run 39837754783).
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
  return userIdOf(page.context())
}

/** Fills the email screen and presses Send code. */
export async function sendCodeTo(page: Page, address: string): Promise<void> {
  await page.getByLabel('Email address').fill(address)
  await page.getByRole('button', { name: 'Send code' }).click()
  await expect(page.getByLabel('6 digit code')).toBeVisible()
}

/** Types a code and presses Confirm. */
export async function confirmCode(page: Page, code: string): Promise<void> {
  await page.getByLabel('6 digit code').fill(code)
  await page.getByRole('button', { name: 'Confirm' }).click()
}

/** Adds an email to this device's guest account, through the screens and Mailpit. */
export async function addEmail(page: Page, address: string): Promise<Mail> {
  const seen = await mailIds(address)
  await page.goto('/account/email')
  await sendCodeTo(page, address)
  const mail = await nextMail(address, seen)
  await confirmCode(page, mail.code)
  return mail
}

/** Signs this device in with an email, through the screens and Mailpit. */
export async function signIn(page: Page, address: string, { anyway = false } = {}): Promise<Mail> {
  const seen = await mailIds(address)
  await page.goto('/sign-in')
  if (anyway) await page.getByRole('button', { name: 'Sign in anyway' }).click()
  await sendCodeTo(page, address)
  const mail = await nextMail(address, seen)
  await confirmCode(page, mail.code)
  await expect(page.getByRole('status')).toHaveText(/You are signed in to your account\./)
  return mail
}

/** A second device: a new browser context at phone size, sharing no cookies with the first. */
export async function secondDevice(
  browser: Browser,
  testInfo: TestInfo,
  baseURL: string | undefined,
): Promise<BrowserContext> {
  const use = testInfo.project.use
  return browser.newContext({
    baseURL,
    ignoreHTTPSErrors: true,
    viewport: use.viewport ?? { width: 375, height: 812 },
    hasTouch: use.hasTouch,
    isMobile: use.isMobile,
    userAgent: use.userAgent,
    deviceScaleFactor: use.deviceScaleFactor,
  })
}

/** What the front door offers: its status line and its main buttons. */
export async function frontDoorState(page: Page): Promise<string> {
  await page.goto('/')
  // Job 9 headed an empty day with "That is all for today." instead.
  await expect(
    page.getByRole('heading', { level: 1, name: /^(Today's session|That is all for today\.)$/ }),
  ).toBeVisible()
  await expect(page.getByRole('status').filter({ hasText: "Loading today's session." })).toHaveCount(0)
  const buttons = await page.getByRole('button').allInnerTexts()
  const message = (await page.locator('[role=status]').allInnerTexts()).join(' ')
  return `${buttons.join(' | ')} || ${message}`.replace(/\s+/g, ' ').trim()
}
