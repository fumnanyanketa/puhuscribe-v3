// The app's page paths in one place (job 19-redesign, statement 45; job
// 17-landing-page). The public landing page has the main address "/", and the
// learner app lives under /learn. Every link, redirect and window.location call
// in the app takes its address from here.

export const LEARN = '/learn'

export const PATHS = {
  /** The public landing page (job 17-landing-page). */
  landing: '/',
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

/** True for /learn and every address under it. */
export function isLearnPath(path: string): boolean {
  return path === LEARN || path.startsWith(`${LEARN}/`)
}

/**
 * Where the app shell sends an address that is not an app page (job
 * 17-landing-page): an old address goes to its new one, keeping the query and
 * the fragment, and an old deep link under /account goes to the account page.
 * Any other address outside /learn goes to the landing page. Null means
 * "stay": the address is under /learn. `path` has no trailing slash.
 */
export function forwardFor(path: string, search: string, hash: string): string | null {
  if (isLearnPath(path)) return null
  const target = OLD_PATHS[path] ?? (path.startsWith('/account/') ? PATHS.account : null)
  if (target) return `${target}${search}${hash}`
  return PATHS.landing
}
