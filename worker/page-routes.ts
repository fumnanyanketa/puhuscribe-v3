// The app's page routes, the ones Cloudflare sends to the Worker before it
// looks for a file (factory/jobs/14-analytics/spec.md, "Done when" 3).
// wrangler.jsonc lists exactly RUN_WORKER_FIRST in assets.run_worker_first;
// tests/analytics-rules.test.ts fails when the two differ, when a page of
// src/App.tsx is missing here, or when a built file matches a pattern here,
// so files never run the Worker.
//
// A pattern is a path, or a path ending in /* for everything under it.

export const PAGE_ROUTES = [
  '/',
  '/session',
  '/voice',
  '/account',
  '/account/*',
  '/sign-in',
  '/privacy',
  '/feedback',
  '/owner',
] as const

export const RUN_WORKER_FIRST: readonly string[] = ['/api/*', ...PAGE_ROUTES]

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
