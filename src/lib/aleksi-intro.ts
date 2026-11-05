// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026).
// Who sees him is the owner's rule of 4 November 2026 (fast routes intro-rule
// and intro-stop): everyone, except a learner who is signed in with an email
// account and has finished at least one whole stop of the road (every lesson of
// it). Both facts come from GET /api/today. When he shows is the owner's rule of
// 5 November 2026 (fast route intro-visit): only at the start of a visit, kept
// as one time stamp in this tab's sessionStorage (see "A visit" below). The
// phone keeps no "met" flag. What he shows is the owner's new intro of
// 5 November 2026 (fast route intro-logo, src/screens/AleksiIntro.tsx): the
// logo and "Play with sound", his greeting spoken and written on a lesson card,
// then the road and his journey line. The visit is marked when that ends, on
// Skip, or on Start.
//
// Two keys of earlier versions are cleared from the phone when they are still
// there: the answers of the first-open questions of fast route "intro"
// (OLD_INTRO_KEY) and the "met Aleksi" flag of fast route aleksi-intro
// (OLD_MET_KEY). Every call is wrapped, so blocked storage breaks nothing.

export const OLD_INTRO_KEY = 'puhuscribe-intro'
export const OLD_MET_KEY = 'puhuscribe-aleksi-met'

/** Harri reads "Moi! Mä oon Aleksi." (scripts/generate/aleksi_greeting.py, workflow task voice-aleksi). */
export const GREETING_AUDIO = '/audio/aleksi/greeting-d4688145c5ab.mp3'

/** Harri reads "Moi! Minä olen Aleksi.", the greeting in written Finnish (a draft for the native reviewer). */
export const GREETING_WRITTEN_AUDIO = '/audio/aleksi/greeting-written-8a9e4f43bbd0.mp3'

/** Harri reads "Ja mä vien sut tälle matkalle." when the road opens (a draft for the native reviewer). */
export const JOURNEY_AUDIO = '/audio/aleksi/journey-998cf808bc4f.mp3'

/**
 * How long each clip lasts, in milliseconds, measured with ffprobe on 5 November 2026 (4.008 s, 3.960 s
 * and 2.832 s). The intro waits for each clip's end; these lengths only pace the scenes when a clip cannot
 * play, and set how long a clip may take before the intro moves on without it.
 */
export const CLIP_MS: Readonly<Record<string, number>> = {
  [GREETING_AUDIO]: 4008,
  [GREETING_WRITTEN_AUDIO]: 3960,
  [JOURNEY_AUDIO]: 2832,
}

/** The portrait at three widths (public/aleksi/), for the photo card's srcset. */
export const PORTRAIT_WIDTHS = [360, 720, 1080] as const
export const PORTRAIT_RATIO = { width: 7, height: 10 } as const

export function portraitSrc(width: number): string {
  return `/aleksi/portrait-${String(width)}.webp`
}

/** The one call of the browser's storage that is used. */
export interface KeyValueStore {
  removeItem: (key: string) => void
}

/** Where the old keys are, the browser's localStorage, or null when even reaching it throws. */
export type StorageSource = () => KeyValueStore | null

export const browserStorage: StorageSource = () => {
  try {
    return (globalThis as { localStorage?: KeyValueStore }).localStorage ?? null
  } catch {
    return null
  }
}

/** Removes the keys of earlier versions (the old first-open answers and the old "met" flag), if this phone still holds them. */
export function clearOldIntroKeys(source: StorageSource = browserStorage): void {
  for (const key of [OLD_INTRO_KEY, OLD_MET_KEY]) {
    try {
      source()?.removeItem(key)
    } catch {
      // Storage that cannot be reached holds nothing to clear.
    }
  }
}

/** What the road knows about who is on this device, from GET /api/today (src/road/home-view.ts). */
export interface IntroFacts {
  signedIn: boolean
  /** The account is an email account (not a guest). */
  email: boolean
  /** The learner has finished every lesson of at least one stop. */
  finishedStop?: boolean
}

/**
 * Whether the road opens with Aleksi's intro first. Only a learner who is signed in with an email
 * account and has finished at least one whole stop goes straight to the road. Everyone else meets him:
 * a new visitor, a guest (whatever they finished), a sign in that ended, and an email account that has
 * not finished a stop yet, even with some lessons done.
 */
export function showsAleksiIntro(facts: IntroFacts): boolean {
  return !(facts.signedIn && facts.email && facts.finishedStop === true)
}

// A visit (fast route intro-visit, owner, 5 November 2026): Aleksi introduces himself only at the start of a
// visit, never again while the learner is still using the app. A visit starts when the app opens fresh (a
// new tab or app launch: this tab's sessionStorage holds no marker) or after the app has gone unused for
// 60 minutes or more. The marker is one sessionStorage key holding only the time of the last use, in
// milliseconds. Nothing about the learner is in it, and the browser drops it when the tab closes.

export const VISIT_KEY = 'puhuscribe-visit'

/** The app unused this long ends a visit. */
export const VISIT_GAP_MS = 60 * 60 * 1000

/** The two calls of the browser's sessionStorage that the visit uses. */
export interface VisitStore {
  getItem: (key: string) => string | null
  setItem: (key: string, value: string) => void
}

/** Where the visit marker is kept, or null when even reaching it throws. */
export type VisitSource = () => VisitStore | null

/** The time now, in milliseconds. */
export type Clock = () => number

export const browserSessionStorage: VisitSource = () => {
  try {
    return (globalThis as { sessionStorage?: VisitStore }).sessionStorage ?? null
  } catch {
    return null
  }
}

const systemClock: Clock = () => Date.now()

/** The time of the last use in this tab, or null when there is no marker or it cannot be read. */
function lastUse(source: VisitSource): number | null {
  try {
    const value = source()?.getItem(VISIT_KEY)
    if (typeof value !== 'string' || !/^\d+$/.test(value)) return null
    const time = Number(value)
    return Number.isSafeInteger(time) ? time : null
  } catch {
    return null
  }
}

/**
 * Whether a visit is under way: the app was used in this tab less than 60 minutes ago. No marker, one that
 * cannot be read, blocked storage, and a time in the future (a clock set back) all mean a new visit.
 */
export function visitIsLive(source: VisitSource = browserSessionStorage, now: Clock = systemClock): boolean {
  const last = lastUse(source)
  if (last === null) return false
  const gap = now() - last
  return gap >= 0 && gap < VISIT_GAP_MS
}

/** Starts the visit, or carries it on: the road opened, or the intro ended, was skipped, or Start was pressed. */
export function markVisit(source: VisitSource = browserSessionStorage, now: Clock = systemClock): void {
  try {
    source()?.setItem(VISIT_KEY, String(now()))
  } catch {
    // Storage that cannot be written keeps no visit; the intro then shows at the next road opening.
  }
}

/** Carries a visit under way on. It never starts one, so a learner back after an hour still meets Aleksi. */
export function keepVisit(source: VisitSource = browserSessionStorage, now: Clock = systemClock): void {
  if (visitIsLive(source, now)) markVisit(source, now)
}

/**
 * Whether the road opens with Aleksi's intro now: the learner is one who meets him (showsAleksiIntro) and
 * this is the start of a visit.
 */
export function introDue(
  facts: IntroFacts,
  source: VisitSource = browserSessionStorage,
  now: Clock = systemClock,
): boolean {
  return showsAleksiIntro(facts) && !visitIsLive(source, now)
}

/** The page's window and document, as far as the visit needs them. */
interface VisitPage {
  addEventListener: (
    type: string,
    listener: () => void,
    options?: { capture?: boolean; passive?: boolean },
  ) => void
  removeEventListener: (type: string, listener: () => void, options?: { capture?: boolean }) => void
}

/** Events on the window that mean the learner is using the app, or leaving the page. */
const USE_EVENTS = ['pointerdown', 'keydown', 'pagehide'] as const

/**
 * Carries the visit on while the app is in use: on every tap or key, when the page is hidden (the phone
 * locks, the learner switches app) and when it is left (pagehide). Returns the call that stops listening.
 */
export function watchVisit(
  win: VisitPage,
  doc: VisitPage & { visibilityState: string },
  source: VisitSource = browserSessionStorage,
  now: Clock = systemClock,
): () => void {
  const keep = () => {
    keepVisit(source, now)
  }
  const onVisibility = () => {
    if (doc.visibilityState === 'hidden') keep()
  }
  for (const type of USE_EVENTS) win.addEventListener(type, keep, { capture: true, passive: true })
  doc.addEventListener('visibilitychange', onVisibility)
  return () => {
    for (const type of USE_EVENTS) win.removeEventListener(type, keep, { capture: true })
    doc.removeEventListener('visibilitychange', onVisibility)
  }
}
