import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { OWNER_HOST_ATTRIBUTE, OWNER_HOST_MARK } from './owner-host.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// The browser's crash reporter, with the page's globals stood in for.

const ORIGIN = 'https://puhuscribe.example'
interface Sent {
  url: string
  init: { keepalive?: boolean; credentials?: string; body: string }
}
let sent: Sent[] = []
let listeners: Record<string, (event: unknown) => void> = {}

/**
 * A reporter with fresh state. `hostMark` is what the page's <html> element
 * holds in its owner host attribute: worker/owner.ts sets "owner" on every page
 * the owner host serves, and the app host never sets it (null).
 */
async function freshReporter(keepalive: boolean, hostMark: string | null = null) {
  vi.resetModules()
  sent = []
  listeners = {}
  vi.stubGlobal('window', {
    location: { origin: ORIGIN, pathname: '/api/sessions/0f8e2b44-6a71-4c3e-9d55-1b2c3d4e5f60/step' },
    addEventListener: (name: string, listener: (event: unknown) => void) => {
      listeners[name] = listener
    },
  })
  vi.stubGlobal('document', {
    querySelectorAll: () => [{ value: 'kahvilassa', type: 'text' }],
    documentElement: {
      getAttribute: (name: string) => (name === OWNER_HOST_ATTRIBUTE ? hostMark : null),
    },
  })
  vi.stubGlobal('HTMLInputElement', vi.fn())
  vi.stubGlobal(
    'Request',
    vi.fn(function (this: Record<string, unknown>, _url: string, init: RequestInit) {
      if (keepalive) this.keepalive = init.keepalive
    }),
  )
  vi.stubGlobal(
    'fetch',
    vi.fn((url: string, init: Sent['init']) => {
      sent.push({ url, init })
      return Promise.resolve(new Response(null, { status: 204 }))
    }),
  )
  return import('./crash-reporter.ts')
}

function errorWith(message: string, line: number): Error {
  const error = new TypeError(message)
  error.stack = `TypeError: ${message}\n    at onClick (${ORIGIN}/assets/index-AbC.js:1:${String(line)})\n    at https://evil.example/x.js:1:1`
  return error
}

beforeEach(() => {
  vi.useRealTimers()
})

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('the browser crash reporter', () => {
  it('[analytics 24] [analytics 25] sends one report by fetch with keepalive and no cookies, holding only the allow list', async () => {
    const { reportError } = await freshReporter(true)
    reportError(errorWith('Could not grade kahvilassa for learner@example.com', 10))
    expect(sent).toHaveLength(1)
    const [report] = sent
    expect(report.url).toBe('/api/crash')
    expect(report.init.keepalive).toBe(true)
    expect(report.init.credentials).toBe('omit')
    expect(JSON.parse(report.init.body)).toEqual({
      source: 'browser',
      name: 'TypeError',
      message: 'Could not grade [typed] for [email]',
      frames: [{ file: '/assets/index-AbC.js', line: 1, column: 10, fn: 'onClick' }],
      path: '/api/sessions/:id/step',
    })
  })

  // Round 2 (security note 1). On the live owner host Cloudflare Access lets a
  // request through only with its own cookie, so a report sent without cookies
  // would be stopped there. The owner host sends same origin cookies; the app
  // host never sends any.
  it('[analytics 27] [analytics 24] on the owner host, sends the report with same origin cookies so Cloudflare Access lets it through', async () => {
    const { reportError } = await freshReporter(true, OWNER_HOST_MARK)
    reportError(errorWith('A test error from the owner page.', 4))
    expect(sent).toHaveLength(1)
    expect(sent[0]?.url).toBe('/api/crash')
    expect(sent[0]?.init.credentials).toBe('same-origin')
  })

  it('[analytics 25] [analytics 30] on the app host, or with any other mark, sends no cookies', async () => {
    for (const mark of [null, '', 'app', 'OWNER', 'owner ']) {
      const { reportError } = await freshReporter(true, mark)
      reportError(errorWith('x', 2))
      expect(sent, String(mark)).toHaveLength(1)
      expect(sent[0]?.init.credentials, String(mark)).toBe('omit')
    }
  })

  it('[analytics 24] falls back to a plain fetch where keepalive is missing', async () => {
    const { reportError } = await freshReporter(false)
    reportError(errorWith('x', 1))
    expect(sent).toHaveLength(1)
    expect(sent[0]?.init.keepalive).toBeUndefined()
  })

  it('[analytics 24] sends each distinct error once and at most 5 per page load', async () => {
    const { reportError } = await freshReporter(true)
    reportError(errorWith('same', 1))
    reportError(errorWith('same', 1))
    expect(sent).toHaveLength(1)
    for (let i = 2; i <= 9; i += 1) reportError(errorWith(`other ${String(i)}`, i))
    expect(sent).toHaveLength(5)
  })

  it('[analytics 24] catches errors and unhandled rejections through its listeners', async () => {
    const { installCrashReporter } = await freshReporter(true)
    installCrashReporter()
    listeners.error({ error: errorWith('from a listener', 3), message: 'from a listener' })
    listeners.unhandledrejection({ reason: 'not an error' })
    expect(sent.map((s) => (JSON.parse(s.init.body) as { message: string }).message)).toEqual([
      'from a listener',
      'A value that is not an Error was thrown.',
    ])
  })
})
