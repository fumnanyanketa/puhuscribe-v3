import { createServerClient, parseCookieHeader, serializeCookieHeader } from '@supabase/ssr'
import { isAuthApiError, isAuthSessionMissingError } from '@supabase/supabase-js'
import type { Database } from '../src/lib/database.types.ts'

// The learner's sign in (factory/jobs/8-first-session/spec.md, Decision 1).
//
// The Worker talks to Supabase for the browser. It uses @supabase/ssr's
// server client with the publishable key, and keeps the learner's tokens in
// cookies that the page's own scripts cannot read: HttpOnly, Secure,
// SameSite=Lax, Path=/, no Domain, for 90 days (the owner's rule for unused
// guests). Every database call then runs with the learner's own token, so the
// database's access rules decide what comes back. No secret or service role
// key exists here.
//
// This file writes nothing to the log. When renewal fails (a deleted or
// revoked guest), auth-js may write one short error line with no personal data
// (worker/logs.test.ts checks no cookie, token, user id or address is logged).

/** The name of the sign in cookie (long sessions are split into .0, .1 ...). */
export const AUTH_COOKIE = 'puhuscribe-auth'
/** 90 days, the owner's rule for unused guest accounts. */
export const GUEST_MAX_AGE_SECONDS = 90 * 24 * 60 * 60

export interface SupabaseEnv {
  SUPABASE_URL?: string
  SUPABASE_PUBLISHABLE_KEY?: string
}

export type Fetch = (input: string | URL | Request, init?: RequestInit) => Promise<Response>

export interface LearnerContext {
  client: LearnerClient
  /** True when the request carried a sign in cookie. */
  hadAuthCookie: boolean
  /** Clears every sign in cookie the request carried. */
  clearCookies: () => void
  /** The Set-Cookie values for the answer, one per cookie name. */
  setCookies: () => string[]
}

function isAuthCookie(name: string): boolean {
  return name === AUTH_COOKIE || name.startsWith(`${AUTH_COOKIE}.`) || name.startsWith(`${AUTH_COOKIE}-`)
}

function cookieValue(name: string, value: string, remove: boolean): string {
  return serializeCookieHeader(name, remove ? '' : value, {
    path: '/',
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    maxAge: remove ? 0 : GUEST_MAX_AGE_SECONDS,
  })
}

/** True when the request carries a sign in cookie (its value is not looked at). */
export function hasAuthCookie(request: Request): boolean {
  return parseCookieHeader(request.headers.get('cookie') ?? '').some(({ name }) => isAuthCookie(name))
}

/** The project address and publishable key, or null when either is missing. */
export function supabaseSettings(env: SupabaseEnv): { url: string; key: string } | null {
  const url = env.SUPABASE_URL?.trim().replace(/\/+$/, '')
  const key = env.SUPABASE_PUBLISHABLE_KEY?.trim()
  if (!url || !key) return null
  return { url, key }
}

type CookieList = { name: string; value: string }[]
type CookieWriter = (cookies: { name: string; value: string; options: { maxAge?: number } }[]) => void

function serverClient(
  settings: { url: string; key: string },
  getAll: () => CookieList,
  setAll: CookieWriter,
  fetchImpl: Fetch,
) {
  return createServerClient<Database>(settings.url, settings.key, {
    cookieOptions: { name: AUTH_COOKIE },
    cookies: { getAll, setAll },
    global: { fetch: fetchImpl },
  })
}

export type LearnerClient = ReturnType<typeof serverClient>

export function learnerContext(
  request: Request,
  settings: { url: string; key: string },
  fetchImpl: Fetch,
): LearnerContext {
  const requestCookies = parseCookieHeader(request.headers.get('cookie') ?? '')
  const authCookies = requestCookies.filter(({ name }) => isAuthCookie(name))
  // Keyed by name, so a cookie set twice in one request is sent once, last value wins.
  const outgoing = new Map<string, string>()

  const client = serverClient(
    settings,
    () => authCookies,
    (cookies) => {
      for (const { name, value, options } of cookies) {
        const remove = options.maxAge === 0 || value === ''
        outgoing.set(name, cookieValue(name, value, remove))
      }
    },
    fetchImpl,
  )

  return {
    client,
    hadAuthCookie: authCookies.length > 0,
    clearCookies: () => {
      for (const { name } of authCookies) outgoing.set(name, cookieValue(name, '', true))
    },
    setCookies: () => [...outgoing.values()],
  }
}

export type SignInState = 'active' | 'none' | 'ended' | 'unavailable'

/**
 * Whether the learner is signed in, asked of Supabase Auth itself (getUser,
 * not getSession, which the Supabase docs say not to trust on a server).
 * An expired access token is renewed with the refresh token on the way, and
 * the new cookies are set. When renewal fails because the user was deleted or
 * the token revoked, the sign in cookies are cleared and the answer is
 * "ended". A network fault answers "unavailable" and keeps the cookies.
 */
export async function signInState(context: LearnerContext): Promise<SignInState> {
  if (!context.hadAuthCookie) return 'none'
  let error: unknown
  try {
    const result = await context.client.auth.getUser()
    if (result.data.user) return 'active'
    error = result.error
  } catch (thrown) {
    error = thrown
  }
  // A 4xx answer from Supabase Auth means the token is no good any more
  // (deleted user, revoked or used refresh token). 429 is a rate limit, not
  // a verdict on the token, so it keeps the cookies.
  const refused = isAuthApiError(error) && error.status >= 400 && error.status < 500 && error.status !== 429
  if (isAuthSessionMissingError(error) || refused) {
    context.clearCookies()
    return 'ended'
  }
  return 'unavailable'
}
