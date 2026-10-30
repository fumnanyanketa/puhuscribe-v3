import {
  MAX_FRAMES,
  cleanName,
  cleanPath,
  cleanText,
  ownBrowserFile,
  parseStack,
  withoutValues,
} from './crash-clean.ts'
import { OWNER_HOST_ATTRIBUTE, OWNER_HOST_MARK } from './owner-host.ts'

// The browser's crash reports (factory/jobs/14-analytics/spec.md, "Done when"
// 24 and 25). Errors are caught by listeners for "error" and
// "unhandledrejection" and by the error boundary around the app
// (src/components/CrashBoundary.tsx). Each report holds only the error name,
// a cleaned message, the app's own stack frames and the page path with ids
// replaced. Anything the learner typed into a field on the page is removed
// from the message. At most 5 reports per page load, each distinct error once,
// sent to /api/crash without cookies, except on the owner host, where
// Cloudflare Access needs its own cookie (src/lib/owner-host.ts). The Worker
// cleans everything again.

export const MAX_REPORTS_PER_LOAD = 5

const sent = new Set<string>()
let count = 0

/** What a field on the page holds right now: never sent, only removed from the message. */
function typedValues(): string[] {
  if (typeof document === 'undefined') return []
  return [...document.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input, textarea')]
    .filter(
      (field) =>
        !(field instanceof HTMLInputElement) || !['hidden', 'checkbox', 'radio'].includes(field.type),
    )
    .map((field) => field.value)
}

function supportsKeepalive(): boolean {
  try {
    return 'keepalive' in new Request('/', { method: 'POST', keepalive: true })
  } catch {
    return false
  }
}

/** True only on a page the owner host served (worker/owner.ts marks it). */
function onOwnerHost(): boolean {
  if (typeof document === 'undefined') return false
  return document.documentElement.getAttribute(OWNER_HOST_ATTRIBUTE) === OWNER_HOST_MARK
}

function send(body: string): void {
  const init: RequestInit = {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body,
    // The app host sends no cookies at all. The owner host must send Cloudflare
    // Access's cookie, or Access stops the report before it reaches the Worker;
    // the Worker still never reads a cookie on /api/crash.
    credentials: onOwnerHost() ? 'same-origin' : 'omit',
  }
  // keepalive lets a report finish when the page is closing. Older browsers
  // without it send a plain request.
  if (supportsKeepalive()) init.keepalive = true
  fetch('/api/crash', init).catch(() => undefined)
}

/** Reports one error, unless this page load already sent 5 or already sent this one. */
export function reportError(error: unknown): void {
  try {
    const known = error instanceof Error ? error : null
    const origin = window.location.origin
    const frames = parseStack(known?.stack)
      .map((frame) => ({ ...frame, file: ownBrowserFile(frame.url, origin) }))
      .filter((frame): frame is typeof frame & { file: string } => frame.file !== null)
      .slice(0, MAX_FRAMES)
      .map(({ file, line, column, fn }) => ({ file, line, column, fn }))
    const name = cleanName(known?.name ?? 'UnhandledRejection')
    const message = known
      ? cleanText(withoutValues(known.message, typedValues()))
      : 'A value that is not an Error was thrown.'
    const key = `${name}|${message}|${frames[0] ? `${frames[0].file}:${String(frames[0].line)}:${String(frames[0].column)}` : ''}`
    if (count >= MAX_REPORTS_PER_LOAD || sent.has(key)) return
    sent.add(key)
    count += 1
    send(
      JSON.stringify({ source: 'browser', name, message, frames, path: cleanPath(window.location.pathname) }),
    )
  } catch {
    // A report must never break the page.
  }
}

let installed = false

/** Listens for errors nobody caught, once per page load. */
export function installCrashReporter(): void {
  if (installed) return
  installed = true
  window.addEventListener('error', (event) => {
    reportError(event.error ?? new Error(event.message))
  })
  window.addEventListener('unhandledrejection', (event) => {
    reportError(event.reason)
  })
}
