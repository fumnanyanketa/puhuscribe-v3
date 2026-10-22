import { execFileSync } from 'node:child_process'
import type { BrowserContext } from '@playwright/test'

// Reads (and, for a few tests, changes) the throwaway local database the
// browser tests run against, through psql. LOCAL_DB_URL is the throwaway
// database's own fixed local address, set by the pull request check
// "Browser tests (Playwright, local Supabase)" (job 6-pr-local-db). It is
// never a hosted database: tests that need it are tagged @seed, and the
// after-merge run against the test project leaves them out.
//
// Values are passed to psql as variables (:'name'), never pasted into SQL.
// Nothing here prints a row, a cookie or a token.

export const LOCAL_DB_URL = process.env.LOCAL_DB_URL ?? ''

const SEPARATOR = '\u001f'

/** Runs SQL on the throwaway database and returns its rows as arrays of text. */
export function sql(query: string, vars: Record<string, string | number> = {}): string[][] {
  if (!LOCAL_DB_URL)
    throw new Error('LOCAL_DB_URL is not set: these tests need the throwaway local database.')
  if (!/^postgres(ql)?:\/\/[^@]+@(127\.0\.0\.1|localhost):\d+\//.test(LOCAL_DB_URL)) {
    throw new Error('LOCAL_DB_URL must point at a database on this machine.')
  }
  const args = [
    LOCAL_DB_URL,
    '--no-psqlrc',
    '--tuples-only',
    '--no-align',
    '--quiet',
    '-v',
    'ON_ERROR_STOP=1',
  ]
  args.push(`--field-separator=${SEPARATOR}`)
  for (const [name, value] of Object.entries(vars)) args.push('-v', `${name}=${String(value)}`)
  const out = execFileSync('psql', args, { input: query, encoding: 'utf8' })
  return out
    .split('\n')
    .filter((line) => line.length > 0)
    .map((line) => line.split(SEPARATOR))
}

/** One value: the first column of the first row. */
export function one(query: string, vars: Record<string, string | number> = {}): string {
  return sql(query, vars)[0]?.[0] ?? ''
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

/**
 * The guest's user id, read from the sign in cookie the browser holds. The
 * page itself cannot read that cookie (HttpOnly); the test reads it from the
 * browser context, decodes the session the Worker stored, and returns only
 * the user id.
 */
export async function userIdOf(context: BrowserContext): Promise<string> {
  const cookies = (await context.cookies()).filter(
    (c) => c.name === 'puhuscribe-auth' || c.name.startsWith('puhuscribe-auth.'),
  )
  if (cookies.length === 0) return ''
  const value = cookies
    .sort((a, b) => a.name.localeCompare(b.name, 'en', { numeric: true }))
    .map((c) => c.value)
    .join('')
  const encoded = decodeURIComponent(value).replace(/^base64-/, '')
  const session = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8')) as { user?: { id?: string } }
  const id = session.user?.id ?? ''
  if (!UUID.test(id)) throw new Error('The sign in cookie did not hold a user id.')
  return id
}

/** Today's dialogue for this learner, as the spec's rule picks it (statement 6). */
export function todaysDialogue(userId: string): string {
  return one(
    `select d.id from public.dialogues d join public.units u on u.id = d.unit_id
      where d.status = 'approved' and u.status = 'approved'
        and not exists (select 1 from public.sessions s
                         where s.dialogue_id = d.id and s.user_id = :'uid' and s.ended_at is not null)
      order by u.position, d.position limit 1`,
    { uid: userId },
  )
}

export interface DbLine {
  id: string
  speaker: string
  puhe: string
  kirja: string
  gloss: string
}

export function linesOf(dialogueId: string): DbLine[] {
  return sql(
    `select id, speaker, text_puhe, text_kirja, gloss_en from public.dialogue_lines
      where dialogue_id = :did and status = 'approved' order by position`,
    { did: dialogueId },
  ).map(([id = '', speaker = '', puhe = '', kirja = '', gloss = '']) => ({ id, speaker, puhe, kirja, gloss }))
}

export interface DbWord {
  surface: string
  lemma: string
  formName: string
  why: string
  puhe: string
  kirja: string
}

/** The first word of a line in one register whose form is approved. */
export function firstWordWithForm(lineId: string, register: 'puhe' | 'kirja'): DbWord | null {
  const row = sql(
    `select t.surface, f.lemma, f.form_name_en, f.why_en, f.surface_puhe, f.surface_kirja
       from public.tokens t join public.forms f on f.id = t.form_id
      where t.line_id = :lid and t.register = :'reg' and f.status = 'approved'
      order by t.position limit 1`,
    { lid: lineId, reg: register },
  )[0]
  if (!row) return null
  const [surface = '', lemma = '', formName = '', why = '', puhe = '', kirja = ''] = row
  return { surface, lemma, formName, why, puhe, kirja }
}

/** How many distinct approved forms the dialogue's lines link to (statement 15). */
export function approvedFormsOf(dialogueId: string): number {
  return Number(
    one(
      `select count(distinct f.id) from public.dialogue_lines l
         join public.tokens t on t.line_id = l.id
         join public.forms f on f.id = t.form_id
        where l.dialogue_id = :did and l.status = 'approved' and f.status = 'approved'`,
      { did: dialogueId },
    ),
  )
}

export function sessionsOf(
  userId: string,
): { id: string; dialogueId: string; step: string; ended: boolean }[] {
  return sql(
    `select id, dialogue_id, coalesce(step_reached::text, ''), ended_at is not null
       from public.sessions where user_id = :'uid' order by started_at`,
    { uid: userId },
  ).map(([id = '', dialogueId = '', step = '', ended = '']) => ({
    id,
    dialogueId,
    step,
    ended: ended === 't',
  }))
}
