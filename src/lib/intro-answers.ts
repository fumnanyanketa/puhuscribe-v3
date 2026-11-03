// The two first-open questions and where their answers live (the owner's
// fast route plan of 3 November 2026, "intro"). The answers stay on this phone
// only, in the browser's own storage under one key. Nothing here is sent to the
// Worker or the database. Every read and write is wrapped, so a phone whose
// storage is blocked or full still gets through the questions to Start; it
// simply sees them again next time.

export const INTRO_KEY = 'puhuscribe-intro'

export const REASONS = [
  { value: 'work', label: 'Work' },
  { value: 'daily-life', label: 'Daily life' },
  { value: 'family-and-friends', label: 'Family and friends' },
  { value: 'studies', label: 'Studies' },
] as const

export const TIMES = [
  { value: 'morning', label: 'Morning' },
  { value: 'lunch-break', label: 'Lunch break' },
  { value: 'evening', label: 'Evening' },
  { value: 'no-fixed-time', label: 'No fixed time' },
] as const

export type Reason = (typeof REASONS)[number]['value']
export type PractiseTime = (typeof TIMES)[number]['value']

export interface IntroAnswers {
  /** The phone has been through the questions once. */
  seen: boolean
  reason?: Reason
  time?: PractiseTime
}

/** The two calls of the browser's storage that are used. */
export interface KeyValueStore {
  getItem: (key: string) => string | null
  setItem: (key: string, value: string) => void
}

/** Where the answers are kept: the browser's localStorage, or null when even reaching it throws. */
export type StorageSource = () => KeyValueStore | null

export const browserStorage: StorageSource = () => {
  try {
    return (globalThis as { localStorage?: KeyValueStore }).localStorage ?? null
  } catch {
    return null
  }
}

function isReason(value: unknown): value is Reason {
  return REASONS.some((option) => option.value === value)
}

function isTime(value: unknown): value is PractiseTime {
  return TIMES.some((option) => option.value === value)
}

/** What this phone has stored. Anything missing, unreadable or unexpected counts as "not seen". */
export function readIntro(source: StorageSource = browserStorage): IntroAnswers {
  try {
    const raw = source()?.getItem(INTRO_KEY)
    if (typeof raw !== 'string') return { seen: false }
    const parsed: unknown = JSON.parse(raw)
    if (typeof parsed !== 'object' || parsed === null) return { seen: false }
    const record = parsed as Record<string, unknown>
    if (record.seen !== true) return { seen: false }
    return {
      seen: true,
      ...(isReason(record.reason) ? { reason: record.reason } : {}),
      ...(isTime(record.time) ? { time: record.time } : {}),
    }
  } catch {
    return { seen: false }
  }
}

/** Keeps the answers on this phone. Returns false when storage refused; the flow goes on either way. */
export function saveIntro(answers: IntroAnswers, source: StorageSource = browserStorage): boolean {
  try {
    const storage = source()
    if (!storage) return false
    const kept: IntroAnswers = {
      seen: answers.seen,
      ...(answers.reason && isReason(answers.reason) ? { reason: answers.reason } : {}),
      ...(answers.time && isTime(answers.time) ? { time: answers.time } : {}),
    }
    storage.setItem(INTRO_KEY, JSON.stringify(kept))
    return true
  } catch {
    return false
  }
}

/**
 * Whether pressing Start on the day one card opens the questions first. Only a
 * new visitor sees them: the day one card (no account on this device), no
 * guest session that ended here, and this phone has not been through them.
 */
export function offersIntro(cardKind: string, ended: boolean, stored: IntroAnswers): boolean {
  return cardKind === 'day-one' && !ended && !stored.seen
}
