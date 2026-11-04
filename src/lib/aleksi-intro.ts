// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026).
// Who sees him is the owner's rule of 4 November 2026 (fast route intro-rule):
// everyone sees the intro each time the road opens, except a learner who is
// signed in with an email account and has finished at least one lesson. Both
// facts come from GET /api/today; the phone keeps no flag of its own.
//
// Two keys of earlier versions are cleared from the phone when they are still
// there: the answers of the first-open questions of fast route "intro"
// (OLD_INTRO_KEY) and the "met Aleksi" flag of fast route aleksi-intro
// (OLD_MET_KEY). Every call is wrapped, so blocked storage breaks nothing.

export const OLD_INTRO_KEY = 'puhuscribe-intro'
export const OLD_MET_KEY = 'puhuscribe-aleksi-met'

/** Harri reads "Moi! Mä oon Aleksi." (scripts/generate/aleksi_greeting.py, workflow task voice-aleksi). */
export const GREETING_AUDIO = '/audio/aleksi/greeting-d4688145c5ab.mp3'

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
  /** At least one lesson of this learner has finished. */
  finishedLesson?: boolean
}

/**
 * Whether the road opens with Aleksi's intro first. Only a learner who is signed in with an email
 * account and has finished at least one lesson goes straight to the road. Everyone else meets him:
 * a new visitor, a guest (with or without a finished lesson), a sign in that ended, and an email
 * account with no finished lesson.
 */
export function showsAleksiIntro(facts: IntroFacts): boolean {
  return !(facts.signedIn && facts.email && facts.finishedLesson === true)
}
