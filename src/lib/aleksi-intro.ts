// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026). A
// new visitor meets Aleksi once on this phone before the road opens. The phone
// keeps only "met" under one key in the browser's own storage; nothing is sent
// to the Worker or the database. Every read and write is wrapped, so a phone
// whose storage is blocked or full still gets past the intro; it simply meets
// Aleksi again next time.
//
// The two first-open questions of fast route "intro" are gone. Their key,
// OLD_INTRO_KEY, is cleared from the phone when it is still there.

export const MET_KEY = 'puhuscribe-aleksi-met'
export const OLD_INTRO_KEY = 'puhuscribe-intro'

/** Harri reads "Moi! Mä oon Aleksi." (scripts/generate/aleksi_greeting.py, workflow task voice-aleksi). */
export const GREETING_AUDIO = '/audio/aleksi/greeting-d4688145c5ab.mp3'

/** The portrait at three widths (public/aleksi/), for the photo card's srcset. */
export const PORTRAIT_WIDTHS = [360, 720, 1080] as const
export const PORTRAIT_RATIO = { width: 7, height: 10 } as const

export function portraitSrc(width: number): string {
  return `/aleksi/portrait-${String(width)}.webp`
}

/** The calls of the browser's storage that are used. */
export interface KeyValueStore {
  getItem: (key: string) => string | null
  setItem: (key: string, value: string) => void
  removeItem: (key: string) => void
}

/** Where the flag is kept: the browser's localStorage, or null when even reaching it throws. */
export type StorageSource = () => KeyValueStore | null

export const browserStorage: StorageSource = () => {
  try {
    return (globalThis as { localStorage?: KeyValueStore }).localStorage ?? null
  } catch {
    return null
  }
}

/** This phone has met Aleksi. Anything missing or unreadable counts as "not met". */
export function hasMetAleksi(source: StorageSource = browserStorage): boolean {
  try {
    return source()?.getItem(MET_KEY) === 'yes'
  } catch {
    return false
  }
}

/** Keeps "met" on this phone. Returns false when storage refused; the road opens either way. */
export function markMetAleksi(source: StorageSource = browserStorage): boolean {
  try {
    const storage = source()
    if (!storage) return false
    storage.setItem(MET_KEY, 'yes')
    return true
  } catch {
    return false
  }
}

/** Removes the answers of the old first-open questions, if this phone still holds them. */
export function clearOldIntro(source: StorageSource = browserStorage): void {
  try {
    source()?.removeItem(OLD_INTRO_KEY)
  } catch {
    // Storage that cannot be reached holds nothing to clear.
  }
}

/**
 * Whether the road opens with Aleksi's intro first. Only a new visitor meets him: nobody is signed in
 * on this device (no guest session, no account), no sign in ended here, and this phone has not met him.
 */
export function showsAleksiIntro(signedIn: boolean, ended: boolean, met: boolean): boolean {
  return !signedIn && !ended && !met
}
