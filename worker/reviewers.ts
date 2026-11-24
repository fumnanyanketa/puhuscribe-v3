import { parseReviewerSignup, type ReviewerSignup } from '../src/lib/reviewer-signup.ts'
import { json, refuseUnsafeWrite } from './http.ts'
import { supabaseSettings, type Fetch, type SupabaseEnv } from './learner-auth.ts'
import { checkHuman, humanCheckKeys, REVIEWERS_ACTION, type HumanCheckEnv } from './providers/human-check.ts'

// POST /api/reviewers: the native speaker reviewer sign up at /reviewers
// (fast route reviewers, factory/jobs/reviewers/spec.md, "Done when" 2, 3 and
// 6). Anyone may send it: no account, no sign in and no cookie, in or out.
//
// 1. JSON from this same address, the body read and capped at 4 KB.
// 2. The fields are checked (src/lib/reviewer-signup.ts): a name of 1 to 100
//    characters, an email address of at most 254, an optional thank-you name
//    of at most 100. Anything else is refused with 400 and the field's name.
// 3. A Cloudflare Turnstile token is checked with the guest Start's check
//    (worker/providers/human-check.ts), for the action "reviewers". Without a
//    token the answer is 403 check_needed with the public site key, and the
//    page runs the check and sends again. With no passed check nothing is saved.
// 4. One row is saved through public.sign_up_reviewer, as anon with the
//    publishable key: the only door to private.reviewer_signups, which the
//    browser roles cannot touch. The database refuses a fourth sign up from the
//    same email address on one Helsinki day, and more than 200 sign ups a day
//    in all. The Worker also refuses a sixth sign up from one internet
//    address on one Helsinki day, counted in memory only, for each running
//    copy of the Worker; the address is never stored or logged.
// 5. After a 201 the owner gets a short email alert with no name or email
//    (worker/providers/feedback-alert.ts), sent after the answer.
//
// This file writes nothing to the log.

export const MAX_REVIEWERS_BODY_BYTES = 4 * 1024
/** Sign ups from one internet address on one Helsinki day, per running copy of the Worker. */
export const SIGNUPS_PER_ADDRESS_PER_DAY = 5
const DATABASE_TIMEOUT_MS = 5000

export interface ReviewersDb {
  /** Saves one sign up; "limit" when a daily limit is reached. Throws when the database cannot be reached. */
  signUp(signup: ReviewerSignup): Promise<'saved' | 'limit'>
}

export class ReviewersUnavailable extends Error {}

/** The database, as anon with the publishable key and no sign in. */
export function supabaseReviewersDb(env: SupabaseEnv, fetchImpl: Fetch): ReviewersDb {
  return {
    async signUp(signup) {
      const settings = supabaseSettings(env)
      if (!settings) throw new ReviewersUnavailable()
      const controller = new AbortController()
      const timer = setTimeout(() => {
        controller.abort()
      }, DATABASE_TIMEOUT_MS)
      try {
        const res = await fetchImpl(`${settings.url}/rest/v1/rpc/sign_up_reviewer`, {
          method: 'POST',
          headers: { apikey: settings.key, 'content-type': 'application/json' },
          body: JSON.stringify({
            p_name: signup.name,
            p_email: signup.email,
            p_thanks_name: signup.thanksName,
          }),
          signal: controller.signal,
        })
        const answer: unknown = await res.json().catch(() => null)
        if (!res.ok) throw new ReviewersUnavailable()
        if (answer === true) return 'saved'
        if (answer === false) return 'limit'
        throw new ReviewersUnavailable()
      } catch {
        throw new ReviewersUnavailable()
      } finally {
        clearTimeout(timer)
      }
    },
  }
}

function helsinkiDay(at: Date): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Helsinki' }).format(at)
}

/** Counts sign ups per internet address for the current Helsinki day, in memory only. */
export interface AddressLimiter {
  /** True when this address may still sign up today. */
  allows(address: string, at: Date): boolean
  /** Counts one saved sign up for this address. */
  count(address: string, at: Date): void
}

/** At most this many addresses are remembered; past it the count starts again, so memory stays small. */
const MAX_ADDRESSES = 10_000

export function memoryLimiter(limit = SIGNUPS_PER_ADDRESS_PER_DAY): AddressLimiter {
  let day = ''
  const counts = new Map<string, number>()
  function today(at: Date) {
    const now = helsinkiDay(at)
    if (now !== day || counts.size >= MAX_ADDRESSES) {
      day = now
      counts.clear()
    }
  }
  return {
    allows(address, at) {
      today(at)
      return (counts.get(address) ?? 0) < limit
    },
    count(address, at) {
      today(at)
      counts.set(address, (counts.get(address) ?? 0) + 1)
    },
  }
}

const sharedLimiter = memoryLimiter()

export interface ReviewersKit {
  env: SupabaseEnv & HumanCheckEnv
  fetch: Fetch
  db: ReviewersDb
  /** Tests pass their own; normally one per running copy of the Worker. */
  limiter?: AddressLimiter
  /** Tests pass their own clock. */
  now?: () => Date
  /** Runs after a sign up is saved, once the answer is ready (the owner's alert). It must not throw. */
  afterSent?: () => void
}

/** The Turnstile token in the body, or undefined when none was sent. */
function tokenOf(body: unknown): unknown {
  if (typeof body !== 'object' || body === null) return undefined
  return (body as Record<string, unknown>).turnstileToken
}

export async function reviewersRoute(request: Request, kit: ReviewersKit): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_REVIEWERS_BODY_BYTES)
  if (write.refused) return write.refused
  let body: unknown
  try {
    body = JSON.parse(write.body)
  } catch {
    return json({ error: 'bad_input', field: 'name' }, 400)
  }
  const signup = parseReviewerSignup(body)
  if ('bad' in signup) return json({ error: 'bad_input', field: signup.bad }, 400)

  const at = (kit.now ?? (() => new Date()))()
  const limiter = kit.limiter ?? sharedLimiter
  const address = request.headers.get('cf-connecting-ip')?.trim() ?? ''
  if (address && !limiter.allows(address, at)) return json({ error: 'limit' }, 429)

  const hostname = new URL(request.url).hostname
  const keys = humanCheckKeys(kit.env, hostname)
  if (!keys) return json({ error: 'check_unavailable' }, 503)
  const token = tokenOf(body)
  if (token === undefined) return json({ error: 'check_needed', siteKey: keys.siteKey }, 403)
  const check = await checkHuman(token, keys, hostname, kit.fetch, REVIEWERS_ACTION)
  if (check === 'failed') return json({ error: 'check_failed', siteKey: keys.siteKey }, 403)
  if (check === 'unavailable') return json({ error: 'check_unavailable' }, 503)

  let result: 'saved' | 'limit'
  try {
    result = await kit.db.signUp(signup)
  } catch {
    return json({ error: 'not_available' }, 503)
  }
  if (result === 'limit') return json({ error: 'limit' }, 429)
  if (address) limiter.count(address, at)
  kit.afterSent?.()
  return json({ sent: true }, 201)
}
