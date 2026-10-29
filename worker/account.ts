import { isAuthApiError } from '@supabase/supabase-js'
import {
  CODE_SENT_ANSWER,
  type AccountError,
  type CodeAcceptedAnswer,
  type MeAnswer,
} from '../src/lib/account-types.ts'
import { cleanCode, cleanEmail } from '../src/lib/email-address.ts'
import { aboutTheDownload } from '../src/privacy/data-inventory.ts'
import { supabaseAccountDb, type Account, type AccountDb } from './account-db.ts'
import { API_HEADERS, json, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
import {
  blankContext,
  endedHint,
  hasAuthCookie,
  learnerContext,
  supabaseSettings,
  type Fetch,
  type LearnerContext,
  type SupabaseEnv,
} from './learner-auth.ts'
import { FILE_STORES, type FileOwner, type FileStore } from './personal-data/file-stores.ts'

// The account routes (factory/jobs/11-accounts/spec.md):
//   GET  /api/me                      what kind of account this device has
//   POST /api/account/email           a guest asks for a code to add an email
//   POST /api/account/email/verify    ... and types it
//   POST /api/sign-in                 a device asks for a sign in code
//   POST /api/sign-in/verify          ... and types it
//   POST /api/sign-out                an email account signs out this device
//   GET  /api/account/export          the learner's data as one file
//   POST /api/account/delete          deletes the account and everything in it
//
// The rules every route keeps:
// - The account is learned from the database (public.my_account()), which
//   also checks the sign in is still live, never from Supabase Auth's /user
//   (Decision 6).
// - No answer tells whether an email address has an account (statement 9).
//   Both "send a code" routes answer exactly CODE_SENT_ANSWER, with the same
//   cookies, for a new, a taken and an unknown address.
// - No user id goes in or out: the database functions act on the token's own
//   id. Only the downloaded file holds the learner's own id.
// - The publishable key only. No Supabase secret key is used anywhere.
// - Nothing is written to the log: no email, code, token or user id.

export interface AccountDeps {
  fetch: Fetch
  /** Tests pass a fake; normally it is Supabase, as the learner. */
  accountDb?: (context: LearnerContext) => AccountDb
  /** Tests pass fakes; normally the list in worker/personal-data/file-stores.ts. */
  fileStores?: readonly FileStore[]
}

type Answer = Response

function dbFor(context: LearnerContext, deps: AccountDeps): AccountDb {
  return deps.accountDb ? deps.accountDb(context) : supabaseAccountDb(context.client)
}

function storesOf(deps: AccountDeps): readonly FileStore[] {
  return deps.fileStores ?? FILE_STORES
}

function fail(error: AccountError, status: number): Response {
  return json({ error }, status)
}

const NOT_CONFIGURED = (): Response => fail('not_available', 503)

/** A 4xx answer from Supabase Auth: a verdict on the request, not a fault. */
function refusedByAuth(error: unknown): boolean {
  return isAuthApiError(error) && error.status >= 400 && error.status < 500
}

function authErrorCode(error: unknown): string | undefined {
  return isAuthApiError(error) ? error.code : undefined
}

type AccountState =
  | { kind: 'none' }
  | { kind: 'ended' }
  | { kind: 'unavailable' }
  | { kind: 'active'; account: Account; accessToken: string }

/**
 * Who this device is signed in as, asked of the database. An expired access
 * token is renewed on the way (the new cookies are set). When the sign in is
 * gone (renewal refused, signed out, or the account deleted), the sign in
 * cookies are cleared and the state is "ended".
 */
async function accountState(context: LearnerContext, deps: AccountDeps): Promise<AccountState> {
  if (!context.hadAuthCookie) return { kind: 'none' }
  let accessToken: string
  try {
    const { data, error } = await context.client.auth.getSession()
    if (error) {
      if (refusedByAuth(error) && error.status !== 429) {
        context.clearCookies()
        return { kind: 'ended' }
      }
      return { kind: 'unavailable' }
    }
    if (!data.session) {
      context.clearCookies()
      return { kind: 'ended' }
    }
    accessToken = data.session.access_token
  } catch {
    return { kind: 'unavailable' }
  }
  try {
    const account = await dbFor(context, deps).myAccount()
    if (!account) {
      context.clearCookies()
      return { kind: 'ended' }
    }
    return { kind: 'active', account, accessToken }
  } catch {
    return { kind: 'unavailable' }
  }
}

/** The answer for a state that is not "active". */
async function notActive(
  state: Exclude<AccountState, { kind: 'active' }>,
  request: Request,
  context: LearnerContext,
): Promise<Answer> {
  if (state.kind === 'unavailable') return withCookies(fail('not_available', 503), context.setCookies())
  if (state.kind === 'ended') {
    return withCookies(
      json({ error: 'session_ended', ...(await endedHint(request)) }, 401),
      context.setCookies(),
    )
  }
  return withCookies(fail('signed_out', 401), context.setCookies())
}

function parseBody(body: string): Record<string, unknown> {
  try {
    const parsed: unknown = JSON.parse(body)
    return typeof parsed === 'object' && parsed !== null ? (parsed as Record<string, unknown>) : {}
  } catch {
    return {}
  }
}

function owner(context: LearnerContext, account: Account): FileOwner {
  return { userId: account.id, client: context.client }
}

/**
 * Deletes the signed in account of this context: every file store first, then
 * the database row (statement 23). Nothing in the database is deleted when a
 * store fails.
 */
async function deleteAccount(
  context: LearnerContext,
  account: Account,
  deps: AccountDeps,
): Promise<'deleted' | 'not_live' | 'failed'> {
  try {
    for (const store of storesOf(deps)) await store.deleteAllFor(owner(context, account))
  } catch {
    return 'failed'
  }
  try {
    return await dbFor(context, deps).deleteMyAccount()
  } catch {
    return 'failed'
  }
}

// GET /api/me ---------------------------------------------------------------------

async function me(request: Request, deps: AccountDeps, context: LearnerContext | null) {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  if (!context) return json({ kind: 'none' } satisfies MeAnswer)
  const state = await accountState(context, deps)
  if (state.kind === 'none')
    return withCookies(json({ kind: 'none' } satisfies MeAnswer), context.setCookies())
  if (state.kind !== 'active') return notActive(state, request, context)
  const { account } = state
  const answer: MeAnswer =
    account.isAnonymous || !account.email ? { kind: 'guest' } : { kind: 'email', email: account.email }
  return withCookies(json(answer), context.setCookies())
}

// Sending a code --------------------------------------------------------------------

/**
 * Asks Supabase to send a sign in code to an existing account, from a context
 * with no sign in. Never makes an account (shouldCreateUser: false). Returns
 * false only for a fault (Supabase down); every refusal, including "no such
 * account" and rate limits, counts as sent, so the answer is the same.
 */
async function sendSignInCode(request: Request, settings: Settings, fetchImpl: Fetch, email: string) {
  const blank = blankContext(request, settings, fetchImpl)
  try {
    const { error } = await blank.client.auth.signInWithOtp({ email, options: { shouldCreateUser: false } })
    return !error || refusedByAuth(error)
  } catch {
    return false
  }
}

interface Settings {
  url: string
  key: string
}

// POST /api/account/email: a guest asks for a code to add an email (statements 4, 8, 9).
async function addEmail(request: Request, settings: Settings, deps: AccountDeps, context: LearnerContext) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const email = cleanEmail(parseBody(write.body).email)
  if (!email) return fail('bad_email', 400)
  const state = await accountState(context, deps)
  if (state.kind !== 'active') return notActive(state, request, context)
  if (!state.account.isAnonymous) return withCookies(fail('has_email', 409), context.setCookies())
  // Only cookies set so far (a renewed sign in) go back. The guest's stored
  // session changes when Supabase accepts the address and not when it is
  // taken, so a cookie written below would tell the two apart (statement 9).
  const cookies = context.setCookies()
  try {
    const { error } = await context.client.auth.updateUser({ email })
    if (error) {
      if (authErrorCode(error) === 'email_exists') {
        if (!(await sendSignInCode(request, settings, deps.fetch, email))) {
          return withCookies(fail('not_available', 503), cookies)
        }
      } else if (!refusedByAuth(error)) {
        return withCookies(fail('not_available', 503), cookies)
      }
    }
  } catch {
    return withCookies(fail('not_available', 503), cookies)
  }
  return withCookies(json(CODE_SENT_ANSWER), cookies)
}

// POST /api/sign-in: a sign in code, for an existing account only (statements 10, 11).
async function signIn(
  request: Request,
  settings: Settings,
  deps: AccountDeps,
  context: LearnerContext | null,
) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const email = cleanEmail(parseBody(write.body).email)
  if (!email) return fail('bad_email', 400)
  let cookies: string[] = []
  if (context) {
    const state = await accountState(context, deps)
    if (state.kind === 'unavailable') return notActive(state, request, context)
    if (state.kind === 'active' && !state.account.isAnonymous) {
      return withCookies(fail('has_email', 409), context.setCookies())
    }
    cookies = context.setCookies()
  }
  if (!(await sendSignInCode(request, settings, deps.fetch, email))) {
    return withCookies(fail('not_available', 503), cookies)
  }
  return withCookies(json(CODE_SENT_ANSWER), cookies)
}

// Checking a code ---------------------------------------------------------------------

type Checked =
  | { kind: 'accepted'; context: LearnerContext; userId: string; accessToken: string }
  | { kind: 'wrong' | 'too_many' | 'fault' }

/** Checks a code in a context with no sign in. On success that context holds the new sign in. */
async function checkCode(
  request: Request,
  settings: Settings,
  fetchImpl: Fetch,
  email: string,
  code: string,
  type: 'email' | 'email_change',
): Promise<Checked> {
  const blank = blankContext(request, settings, fetchImpl)
  try {
    const { data, error } = await blank.client.auth.verifyOtp({ email, token: code, type })
    if (error) {
      if (isAuthApiError(error) && error.status === 429) return { kind: 'too_many' }
      return refusedByAuth(error) ? { kind: 'wrong' } : { kind: 'fault' }
    }
    if (!data.session || !data.user) return { kind: 'fault' }
    return { kind: 'accepted', context: blank, userId: data.user.id, accessToken: data.session.access_token }
  } catch {
    return { kind: 'fault' }
  }
}

function claims(accessToken: string): Record<string, unknown> {
  try {
    const part = accessToken.split('.')[1] ?? ''
    const text = atob(part.replace(/-/g, '+').replace(/_/g, '/'))
    const parsed: unknown = JSON.parse(text)
    return typeof parsed === 'object' && parsed !== null ? (parsed as Record<string, unknown>) : {}
  } catch {
    return {}
  }
}

/** Ends a sign in that was made but will not be used (best effort, never logged). */
async function discard(context: LearnerContext): Promise<void> {
  try {
    await context.client.auth.signOut({ scope: 'local' })
  } catch {
    // Nothing to do: the sign in then simply runs out.
  }
}

function checkFailed(result: { kind: 'wrong' | 'too_many' | 'fault' }, cookies: string[]): Response {
  if (result.kind === 'wrong') return withCookies(fail('wrong_code', 400), cookies)
  if (result.kind === 'too_many') return withCookies(fail('too_many_tries', 429), cookies)
  return withCookies(fail('not_available', 503), cookies)
}

/**
 * The device signs in to another account: this device's guest account is
 * deleted first (with the guest's own token), then the new sign in replaces
 * the cookies (statements 8 and 13). If the guest cannot be deleted, the new
 * sign in is ended and the guest stays.
 */
async function switchAccount(
  context: LearnerContext,
  guest: Account | null,
  accepted: Extract<Checked, { kind: 'accepted' }>,
  deps: AccountDeps,
  cookies: string[],
  result: CodeAcceptedAnswer['result'],
): Promise<Response> {
  if (guest) {
    const deleted = await deleteAccount(context, guest, deps)
    if (deleted !== 'deleted') {
      await discard(accepted.context)
      return withCookies(fail('not_available', 503), cookies)
    }
  }
  context.adopt(accepted.context)
  return withCookies(json({ result } satisfies CodeAcceptedAnswer), context.setCookies())
}

// POST /api/account/email/verify: the guest types the code (statements 5 to 8).
async function addEmailVerify(
  request: Request,
  settings: Settings,
  deps: AccountDeps,
  context: LearnerContext,
) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const body = parseBody(write.body)
  const email = cleanEmail(body.email)
  if (!email) return fail('bad_email', 400)
  const code = cleanCode(body.code)
  if (!code) return fail('wrong_code', 400)
  const state = await accountState(context, deps)
  if (state.kind !== 'active') return notActive(state, request, context)
  const guest = state.account
  if (!guest.isAnonymous) return withCookies(fail('has_email', 409), context.setCookies())
  const cookies = context.setCookies()

  // The Worker cannot know which code the learner holds without saying
  // whether the address had an account, so it tries the email change code
  // first (the address was new), then the sign in code (it was taken).
  const added = await checkCode(request, settings, deps.fetch, email, code, 'email_change')
  if (added.kind === 'accepted') {
    if (added.userId !== guest.id) {
      // Not this guest's change: never sign in to someone else's guest account.
      await discard(added.context)
      return withCookies(fail('wrong_code', 400), cookies)
    }
    let fresh = added
    if (claims(added.accessToken).is_anonymous !== false) {
      // Renew once, so the new token says the account is no longer a guest.
      try {
        const { data, error } = await added.context.client.auth.refreshSession()
        if (!error && data.session) fresh = { ...added, accessToken: data.session.access_token }
      } catch {
        // The sign in made by the check still works; the next renewal updates it.
      }
    }
    // The guest's old sign in on this device is ended: the new one replaces it.
    try {
      await context.client.auth.admin.signOut(state.accessToken, 'local')
    } catch {
      // It then simply runs out.
    }
    context.adopt(fresh.context)
    return withCookies(json({ result: 'added' } satisfies CodeAcceptedAnswer), context.setCookies())
  }
  if (added.kind === 'fault' || added.kind === 'too_many') return checkFailed(added, cookies)

  const existing = await checkCode(request, settings, deps.fetch, email, code, 'email')
  if (existing.kind !== 'accepted') return checkFailed(existing, cookies)
  if (existing.userId === guest.id) {
    await discard(existing.context)
    return withCookies(fail('wrong_code', 400), cookies)
  }
  return switchAccount(context, guest, existing, deps, cookies, 'switched')
}

// POST /api/sign-in/verify: the code from a sign in email (statements 10 and 13).
async function signInVerify(
  request: Request,
  settings: Settings,
  deps: AccountDeps,
  context: LearnerContext | null,
) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const body = parseBody(write.body)
  const email = cleanEmail(body.email)
  if (!email) return fail('bad_email', 400)
  const code = cleanCode(body.code)
  if (!code) return fail('wrong_code', 400)
  const device = context ?? blankContext(request, settings, deps.fetch)
  let guest: Account | null = null
  if (context) {
    const state = await accountState(context, deps)
    if (state.kind === 'unavailable') return notActive(state, request, context)
    if (state.kind === 'active') {
      if (!state.account.isAnonymous) return withCookies(fail('has_email', 409), context.setCookies())
      guest = state.account
    }
  }
  const cookies = device.setCookies()
  const accepted = await checkCode(request, settings, deps.fetch, email, code, 'email')
  if (accepted.kind !== 'accepted') return checkFailed(accepted, cookies)
  if (accepted.userId === guest?.id) {
    await discard(accepted.context)
    return withCookies(fail('wrong_code', 400), cookies)
  }
  return switchAccount(device, guest, accepted, deps, cookies, guest ? 'switched' : 'signed_in')
}

// POST /api/sign-out: this device only, email accounts only (statement 14).
async function signOut(request: Request, deps: AccountDeps, context: LearnerContext | null) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  if (!context) return fail('signed_out', 401)
  const state = await accountState(context, deps)
  if (state.kind !== 'active') return notActive(state, request, context)
  if (state.account.isAnonymous) {
    return withCookies(fail('guest_cannot_sign_out', 409), context.setCookies())
  }
  const cookies = context.setCookies()
  try {
    const { error } = await context.client.auth.signOut({ scope: 'local' })
    if (error && !refusedByAuth(error)) return withCookies(fail('not_available', 503), cookies)
  } catch {
    return withCookies(fail('not_available', 503), cookies)
  }
  context.clearCookies()
  return withCookies(json({ signedOut: true }), context.setCookies())
}

// GET /api/account/export: everything, as one file (statements 18 and 19).
async function exportData(request: Request, deps: AccountDeps, context: LearnerContext | null) {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  if (!context) return fail('signed_out', 401)
  const state = await accountState(context, deps)
  if (state.kind !== 'active') return notActive(state, request, context)
  const { account } = state
  let tables: Record<string, unknown[]>
  const files: Record<string, unknown> = {}
  try {
    tables = await dbFor(context, deps).exportMyData()
    for (const store of storesOf(deps)) files[store.name] = await store.exportFor(owner(context, account))
  } catch {
    return withCookies(fail('not_available', 503), context.setCookies())
  }
  const now = new Date()
  const file = {
    about: aboutTheDownload(),
    exported_at: now.toISOString(),
    account: {
      id: account.id,
      email: account.email,
      is_anonymous: account.isAnonymous,
      created_at: account.createdAt,
      last_sign_in_at: account.lastSignInAt,
      email_confirmed_at: account.emailConfirmedAt,
    },
    tables,
    files,
  }
  const headers = new Headers(API_HEADERS)
  headers.set('content-type', 'application/json; charset=utf-8')
  headers.set(
    'content-disposition',
    `attachment; filename="puhuscribe-data-${now.toISOString().slice(0, 10)}.json"`,
  )
  return withCookies(
    new Response(JSON.stringify(file, null, 2), { status: 200, headers }),
    context.setCookies(),
  )
}

// POST /api/account/delete: the account and everything in it (statements 20 to 23).
async function deleteRoute(request: Request, deps: AccountDeps, context: LearnerContext | null) {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  if (!context) return fail('signed_out', 401)
  const state = await accountState(context, deps)
  if (state.kind !== 'active') return notActive(state, request, context)
  const result = await deleteAccount(context, state.account, deps)
  if (result === 'failed') return withCookies(fail('not_deleted', 503), context.setCookies())
  context.clearCookies()
  if (result === 'not_live') {
    return withCookies(
      json({ error: 'session_ended', ...(await endedHint(request)) }, 401),
      context.setCookies(),
    )
  }
  return withCookies(json({ deleted: true }), context.setCookies())
}

/** The routes that only read. */
const READ_ROUTES = new Set(['/api/me', '/api/account/export'])
/** The routes that work without a sign in. */
const OPEN_ROUTES = new Set(['/api/me', '/api/sign-in', '/api/sign-in/verify'])

const ROUTES = new Set([
  '/api/me',
  '/api/account/email',
  '/api/account/email/verify',
  '/api/sign-in',
  '/api/sign-in/verify',
  '/api/sign-out',
  '/api/account/export',
  '/api/account/delete',
])

/**
 * Answers an account route, or returns null when the path is not one (the
 * request is then untouched).
 */
export async function handleAccountApi(
  request: Request,
  env: SupabaseEnv,
  deps: AccountDeps,
): Promise<Response | null> {
  const { pathname } = new URL(request.url)
  if (!ROUTES.has(pathname)) return null
  const settings = supabaseSettings(env)
  // Without a sign in cookie, /api/me needs no database at all.
  if (pathname === '/api/me' && !hasAuthCookie(request)) return me(request, deps, null)
  if (!settings) {
    // The request's own checks still come first, so a refusal does not
    // depend on whether this Worker has its Supabase settings.
    const refused = READ_ROUTES.has(pathname)
      ? await refuseNonGet(request)
      : (await refuseUnsafeWrite(request)).refused
    if (refused) return refused
    if (!hasAuthCookie(request) && !OPEN_ROUTES.has(pathname)) return fail('signed_out', 401)
    return NOT_CONFIGURED()
  }
  const context = hasAuthCookie(request) ? learnerContext(request, settings, deps.fetch) : null
  switch (pathname) {
    case '/api/me':
      return me(request, deps, context)
    case '/api/account/email':
      return context ? addEmail(request, settings, deps, context) : signedOutWrite(request)
    case '/api/account/email/verify':
      return context ? addEmailVerify(request, settings, deps, context) : signedOutWrite(request)
    case '/api/sign-in':
      return signIn(request, settings, deps, context)
    case '/api/sign-in/verify':
      return signInVerify(request, settings, deps, context)
    case '/api/sign-out':
      return signOut(request, deps, context)
    case '/api/account/export':
      return exportData(request, deps, context)
    default:
      return deleteRoute(request, deps, context)
  }
}

/** A write route that needs a sign in, without one: the usual checks first, then 401. */
async function signedOutWrite(request: Request): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  return fail('signed_out', 401)
}
