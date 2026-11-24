// The app's page paths in one place (job 19-redesign, statement 45; job
// 17-landing-page). The public landing page has the main address "/", and the
// learner app lives under /learn. Every link, redirect and window.location call
// in the app takes its address from here.

export const LEARN = '/learn'

export const PATHS = {
  /** The public landing page (job 17-landing-page). */
  landing: '/',
  /** The public reviewer sign up page, outside /learn (fast route reviewers). The app shell draws it. */
  reviewers: '/reviewers',
  /**
   * The private review pages live under it, /review/<secret> (fast route review-links). The app
   * shell draws them; the bare /review is not a page.
   */
  review: '/review',
  /** The road, the app's home screen and front door. */
  home: LEARN,
  session: `${LEARN}/session`,
  account: `${LEARN}/account`,
  accountEmail: `${LEARN}/account/email`,
  accountDelete: `${LEARN}/account/delete`,
  signIn: `${LEARN}/sign-in`,
  privacy: `${LEARN}/privacy`,
  voice: `${LEARN}/voice`,
  feedback: `${LEARN}/feedback`,
  owner: `${LEARN}/owner`,
} as const

/**
 * The "Create your account" screen opened from Aleksi's stop screen before a first lesson (fast route
 * signup-choice, owner, 22 November 2026). Only this exact query switches the email screen to its first
 * lesson mode; the lesson it then opens is the fixed PATHS.session, never an address from the page.
 */
export const FIRST_LESSON_QUERY = 'then=lesson'
export const ACCOUNT_BEFORE_LESSON = `${PATHS.accountEmail}?${FIRST_LESSON_QUERY}`

/** True when the page address asks for the email screen's first lesson mode (exactly ?then=lesson). */
export function isBeforeFirstLesson(search: string): boolean {
  return new URLSearchParams(search).get('then') === 'lesson'
}

/**
 * The app's addresses before the move to /learn, and where each one lives now
 * (job 17-landing-page). The map is fixed: no part of a target ever comes from
 * the visitor, so an odd path can never forward outside this site.
 */
export const OLD_PATHS: Readonly<Record<string, string>> = {
  '/session': PATHS.session,
  '/voice': PATHS.voice,
  '/account': PATHS.account,
  '/account/email': PATHS.accountEmail,
  '/account/delete': PATHS.accountDelete,
  '/sign-in': PATHS.signIn,
  '/privacy': PATHS.privacy,
  '/feedback': PATHS.feedback,
  '/owner': PATHS.owner,
}

/** True for every address under the base, such as /review/<secret> under /review, but not the base itself. */
export function isUnder(path: string, base: string): boolean {
  return path.startsWith(`${base}/`) && path.length > base.length + 1
}

/** True for /learn and every address under it. */
export function isLearnPath(path: string): boolean {
  return path === LEARN || path.startsWith(`${LEARN}/`)
}

/**
 * Where the app shell sends an address that is not an app page (job
 * 17-landing-page): an old address goes to its new one, keeping the query and
 * the fragment, and an old deep link under /account goes to the account page.
 * Any other address outside /learn goes to the landing page. Null means
 * "stay": the address is under /learn, or it is the public reviewer page
 * /reviewers (fast route reviewers), or a private review page under /review/
 * (fast route review-links). `path` has no trailing slash.
 */
export function forwardFor(path: string, search: string, hash: string): string | null {
  if (isLearnPath(path) || path === PATHS.reviewers || isUnder(path, PATHS.review)) return null
  const target = OLD_PATHS[path] ?? (path.startsWith('/account/') ? PATHS.account : null)
  if (target) return `${target}${search}${hash}`
  return PATHS.landing
}
