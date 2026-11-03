// The app's page routes, the ones Cloudflare sends to the Worker before it
// looks for a file (factory/jobs/14-analytics/spec.md, "Done when" 3).
// wrangler.jsonc lists exactly RUN_WORKER_FIRST in assets.run_worker_first;
// tests/analytics-rules.test.ts fails when the two differ, when a page of
// src/App.tsx is missing here, or when a built file matches a pattern here,
// so files never run the Worker.
//
// A pattern is a path, or a path ending in /* for everything under it.

// Since job 17-landing-page, "/" is the public landing page (the built file
// landing.html, answered by worker/index.ts) and the app lives under /learn.
// The old addresses (/session, /account ...) are no longer routes: Cloudflare
// answers them with the app shell, which forwards each to its new address
// (src/lib/app-paths.ts). /landing runs the Worker only so it can send it to
// "/", and the landing page has one address: Cloudflare sends /landing.html to
// /landing itself (html_handling), and no built file may match a pattern here
// (scripts/security/check-built-files.ts), so the file's own name is not listed.

export const PAGE_ROUTES = [
  '/',
  '/learn',
  '/learn/session',
  '/learn/voice',
  '/learn/account',
  '/learn/account/*',
  '/learn/sign-in',
  '/learn/privacy',
  '/learn/feedback',
  '/learn/owner',
] as const

/** The built landing file's own address, which only ever redirects to "/". */
export const LANDING_FILE_ROUTES = ['/landing'] as const

export const RUN_WORKER_FIRST: readonly string[] = ['/api/*', ...PAGE_ROUTES, ...LANDING_FILE_ROUTES]

/** True when the path matches one of the patterns. */
export function matchesPattern(pathname: string, patterns: readonly string[]): boolean {
  return patterns.some((pattern) =>
    pattern.endsWith('/*') ? pathname.startsWith(pattern.slice(0, -1)) : pathname === pattern,
  )
}

/** True when the path is one of the app's pages. */
export function isPageRoute(pathname: string): boolean {
  return matchesPattern(pathname, PAGE_ROUTES)
}
