// The bot check on the guest "Start" (Cloudflare Turnstile, owner's choice of
// 3 November 2026). Supabase counts every anonymous sign in under the Worker's
// address, so a script calling POST /api/guest could use up the shared limit
// and block real learners. Before a new guest is made, the token the browser
// got from Turnstile is checked here with Cloudflare's siteverify endpoint.
// This is the only file that talks to Turnstile, so the check can be swapped by
// changing this module (AGENTS.md, "Providers"). Docs:
// https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
//
// Keys. TURNSTILE_SITE_KEY (public) and TURNSTILE_SECRET (secret) are
// Worker settings, written from GitHub secrets (docs/turnstile.md). They are
// used only as a pair. Without the pair, local and workers.dev preview
// addresses use Cloudflare's published test keys, which always pass, so
// nothing breaks before the owner creates the widget. Any other address (the
// future live domain) without the pair refuses to make guests: a live app must
// never fall back to a check that always passes.
//
// What is sent: the secret and the token only. The learner's internet address
// is not added (it is optional), and this file writes nothing to the log.

import type { Fetch } from '../learner-auth.ts'

export interface HumanCheckEnv {
  TURNSTILE_SITE_KEY?: string
  TURNSTILE_SECRET?: string
}

export const SITEVERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'

/** Cloudflare's published test keys: a visible widget that always passes, and a secret that always passes. */
export const TEST_SITE_KEY = '1x00000000000000000000AA'
export const TEST_SECRET = '1x0000000000000000000000000000000AA'
/** Both test keys as Worker settings, for unit tests and for describing the local setup. */
export const TEST_KEYS: Required<HumanCheckEnv> = {
  TURNSTILE_SITE_KEY: TEST_SITE_KEY,
  TURNSTILE_SECRET: TEST_SECRET,
}
/** Every published test secret (always passes, always fails, "already spent"). Their answers carry sample hostnames. */
const TEST_SECRETS = new Set([
  TEST_SECRET,
  '2x0000000000000000000000000000000AA',
  '3x0000000000000000000000000000000AA',
])

/** The action the browser names when it renders the widget; checked on real keys. */
export const GUEST_ACTION = 'guest'

/** Turnstile tokens are at most 2048 characters. */
const MAX_TOKEN_LENGTH = 2048
const SITEVERIFY_TIMEOUT_MS = 8000

/** Secret errors mean the app is set up wrongly, not that the learner failed. */
const SETUP_ERRORS = new Set([
  'missing-input-secret',
  'invalid-input-secret',
  'internal-error',
  'bad-request',
])

export interface HumanCheckKeys {
  siteKey: string
  secret: string
  /** Cloudflare's test keys: the answer's hostname and action are sample values, so they are not compared. */
  test: boolean
}

/** Local addresses and the workers.dev previews may use the test keys. */
export function mayUseTestKeys(hostname: string): boolean {
  return (
    hostname === 'localhost' ||
    hostname === '127.0.0.1' ||
    hostname === '[::1]' ||
    hostname.endsWith('.localhost') ||
    hostname.endsWith('.workers.dev')
  )
}

/** The key pair for this address, or null when this address has none (the check is then unavailable). */
export function humanCheckKeys(env: HumanCheckEnv, hostname: string): HumanCheckKeys | null {
  const siteKey = env.TURNSTILE_SITE_KEY?.trim()
  const secret = env.TURNSTILE_SECRET?.trim()
  if (siteKey && secret) return { siteKey, secret, test: TEST_SECRETS.has(secret) }
  if (mayUseTestKeys(hostname)) return { siteKey: TEST_SITE_KEY, secret: TEST_SECRET, test: true }
  return null
}

export type HumanCheck = 'passed' | 'failed' | 'unavailable'

function isTokenShaped(token: unknown): token is string {
  return typeof token === 'string' && token.length > 0 && token.length <= MAX_TOKEN_LENGTH
}

/**
 * Asks Cloudflare whether the token is good for this address. "failed" means
 * the token was refused (or missing); "unavailable" means the check itself
 * could not run, and no guest is made either way.
 */
export async function checkHuman(
  token: unknown,
  keys: HumanCheckKeys,
  hostname: string,
  fetch: Fetch,
): Promise<HumanCheck> {
  if (!isTokenShaped(token)) return 'failed'
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, SITEVERIFY_TIMEOUT_MS)
  let answer: unknown
  try {
    const res = await fetch(SITEVERIFY_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ secret: keys.secret, response: token }),
      signal: controller.signal,
    })
    answer = await res.json()
  } catch {
    return 'unavailable'
  } finally {
    clearTimeout(timer)
  }
  if (typeof answer !== 'object' || answer === null) return 'unavailable'
  const result = answer as Record<string, unknown>
  if (result.success !== true) {
    const codes = Array.isArray(result['error-codes']) ? result['error-codes'] : []
    return codes.some((code) => typeof code === 'string' && SETUP_ERRORS.has(code)) ? 'unavailable' : 'failed'
  }
  if (keys.test) return 'passed'
  // A real token must come from this address and from the guest Start.
  if (result.hostname !== hostname || result.action !== GUEST_ACTION) return 'failed'
  return 'passed'
}
