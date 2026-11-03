// The bot check on the guest "Start" (Cloudflare Turnstile, owner's choice of
// 3 November 2026). The Worker asks for it (POST /api/guest answers 403
// check_needed with the public site key) only when a new guest is about to be
// made, so Turnstile's script is loaded only then: never on page load and
// never for a signed in learner. The widget runs in managed mode with
// appearance "interaction-only", so most learners see nothing; when Cloudflare
// decides a check is needed, it appears inside the road card.
// Docs: https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/
//
// The script must come from this exact address, unproxied and uncached
// (Cloudflare's rule), so it is added as a script tag when needed. Old phones:
// the time limits use setTimeout, not AbortSignal.timeout (AGENTS.md).

const SCRIPT_URL = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'
const SCRIPT_TIMEOUT_MS = 15_000
/** How long to wait for a token while nothing is shown. Once the learner is asked to act, there is no limit. */
const QUIET_TIMEOUT_MS = 20_000
/** Named on the widget; the Worker checks it on real keys (worker/providers/human-check.ts). */
const GUEST_ACTION = 'guest'

interface TurnstileOptions {
  sitekey: string
  action: string
  appearance: 'always' | 'execute' | 'interaction-only'
  size: 'normal' | 'flexible' | 'compact'
  theme: 'auto' | 'light' | 'dark'
  language: string
  'response-field': boolean
  'feedback-enabled': boolean
  callback: (token: string) => void
  'error-callback': (code: string) => boolean
  'expired-callback': () => void
  'timeout-callback': () => void
  'before-interactive-callback': () => void
  'after-interactive-callback': () => void
  'unsupported-callback': () => void
}

interface TurnstileApi {
  render: (container: HTMLElement, options: TurnstileOptions) => string | undefined
  remove: (widgetId: string) => void
}

declare global {
  interface Window {
    turnstile?: TurnstileApi
  }
}

let loading: Promise<TurnstileApi | null> | null = null

/** Loads Turnstile's script once. Resolves null when it cannot load (no connection, a blocker); the next call tries again. */
export function loadHumanCheck(): Promise<TurnstileApi | null> {
  if (window.turnstile) return Promise.resolve(window.turnstile)
  if (loading) return loading
  loading = new Promise<TurnstileApi | null>((resolve) => {
    const script = document.createElement('script')
    const timer = setTimeout(() => {
      finish(null)
    }, SCRIPT_TIMEOUT_MS)
    function finish(api: TurnstileApi | null) {
      clearTimeout(timer)
      if (!api) {
        script.remove()
        loading = null
      }
      resolve(api)
    }
    script.src = SCRIPT_URL
    script.async = true
    script.onload = () => {
      finish(window.turnstile ?? null)
    }
    script.onerror = () => {
      finish(null)
    }
    document.head.appendChild(script)
  })
  return loading
}

export type HumanCheckResult = { token: string } | { problem: 'failed' | 'unavailable' }

/**
 * Runs the check in `slot` and resolves with a token, or with why there is
 * none. `onAsk(true)` says Cloudflare is showing the learner something to do,
 * `onAsk(false)` that it is gone. The widget is removed when this resolves.
 */
export async function runHumanCheck(
  slot: HTMLElement,
  siteKey: string,
  onAsk: (asking: boolean) => void,
): Promise<HumanCheckResult> {
  const api = await loadHumanCheck()
  if (!api) return { problem: 'unavailable' }
  return new Promise<HumanCheckResult>((resolve) => {
    let widgetId: string | undefined
    let done = false
    let quiet: ReturnType<typeof setTimeout> | undefined = setTimeout(() => {
      finish({ problem: 'unavailable' })
    }, QUIET_TIMEOUT_MS)
    function stopQuietTimer() {
      if (quiet !== undefined) clearTimeout(quiet)
      quiet = undefined
    }
    function finish(result: HumanCheckResult) {
      if (done) return
      done = true
      stopQuietTimer()
      onAsk(false)
      if (widgetId !== undefined) {
        try {
          api?.remove(widgetId)
        } catch {
          // Already gone.
        }
      }
      resolve(result)
    }
    try {
      widgetId = api.render(slot, {
        sitekey: siteKey,
        action: GUEST_ACTION,
        appearance: 'interaction-only',
        size: 'flexible',
        // The app is light only (design.md); the widget's own words follow the app's English.
        theme: 'light',
        language: 'en',
        'response-field': false,
        'feedback-enabled': false,
        callback: (token) => {
          finish({ token })
        },
        'error-callback': () => {
          finish({ problem: 'failed' })
          return true
        },
        'expired-callback': () => {
          finish({ problem: 'failed' })
        },
        // An interactive check left unsolved: Cloudflare resets it, and the learner can still act.
        'timeout-callback': () => undefined,
        'before-interactive-callback': () => {
          stopQuietTimer()
          onAsk(true)
        },
        'after-interactive-callback': () => {
          onAsk(false)
        },
        'unsupported-callback': () => {
          finish({ problem: 'unavailable' })
        },
      })
    } catch {
      finish({ problem: 'unavailable' })
    }
  })
}
