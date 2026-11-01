// Words the day of the next review for the front door
// (factory/jobs/9-daily-review/spec.md, "Done when" 5). Both dates come from
// the database as Helsinki calendar dates (public.next_review_day), so this
// never reads the device clock. The difference between two calendar dates is
// worked out at midnight UTC, where every day has 24 hours, so a daylight
// saving change cannot shift it.

const WEEKDAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'] as const
const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
] as const

const DAY_MS = 24 * 60 * 60 * 1000
const DATE = /^(\d{4})-(\d{2})-(\d{2})$/

/** Midnight UTC of a YYYY-MM-DD date, or null when it is not a real date. */
function midnight(date: string): number | null {
  const match = DATE.exec(date)
  if (!match) return null
  const [y, m, d] = [Number(match[1]), Number(match[2]), Number(match[3])]
  const at = Date.UTC(y, m - 1, d)
  const back = new Date(at)
  if (back.getUTCFullYear() !== y || back.getUTCMonth() !== m - 1 || back.getUTCDate() !== d) return null
  return at
}

/**
 * "Your next review is later today.", "... is tomorrow." or "... is on
 * Saturday 24 October." Null when either date is not a real date.
 */
export function nextReviewSentence(today: string, day: string): string | null {
  const from = midnight(today)
  const to = midnight(day)
  if (from === null || to === null) return null
  const days = Math.round((to - from) / DAY_MS)
  if (days <= 0) return 'Your next review is later today.'
  if (days === 1) return 'Your next review is tomorrow.'
  const at = new Date(to)
  const weekday = WEEKDAYS[at.getUTCDay()] ?? ''
  const month = MONTHS[at.getUTCMonth()] ?? ''
  return `Your next review is on ${weekday} ${String(at.getUTCDate())} ${month}.`
}

/**
 * "About 4 minutes", worked out by a fixed rule and never measured: 18 seconds
 * a word, rounded to whole minutes, at least one (job 19-redesign, owner's
 * call 7, 1 November 2026). The review card on the road shows it.
 */
export function reviewMinutes(count: number): number {
  return Math.max(1, Math.round((count * 18) / 60))
}

/** "About 4 minutes" or "About 1 minute". */
export function reviewMinutesLine(count: number): string {
  const minutes = reviewMinutes(count)
  return `About ${String(minutes)} ${minutes === 1 ? 'minute' : 'minutes'}`
}
