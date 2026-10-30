// The owner page's numbers as public.owner_dashboard() returns them, and how
// each one is written on the page (factory/jobs/14-analytics/spec.md, "Done
// when" 8 and 17). Plain functions, so they are tested without a browser.

export interface OwnerNumbers {
  visits_by_day: { day: string; visits: number; fi: number }[]
  visits_by_country: { country: string; visits: number }[]
  active_learners: number
  day7_retention: { retained: number; cohort: number; percent: number | null }
  median_session_minutes: { minutes: number | null; used: number; left_out: number }
  speak_back: { count: number; base: number; percent: number | null }
  ai_cost_usd: { total: number; per_active_learner: number | null }
  feedback: { created_at: string; screen: string; account: string; message: string }[]
  crashes: {
    name: string
    message: string
    count: number
    first_seen: string
    last_seen: string
    source: string
    path: string
    browser: string
    app_version: string
    frames: { file: string; line: number; column: number; fn: string }[]
  }[]
  computed_at: string
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

/** True when the answer has every key the page shows (a shape check, not a full validation). */
export function isOwnerNumbers(value: unknown): value is OwnerNumbers {
  if (!isRecord(value)) return false
  return (
    Array.isArray(value.visits_by_day) &&
    Array.isArray(value.visits_by_country) &&
    typeof value.active_learners === 'number' &&
    isRecord(value.day7_retention) &&
    isRecord(value.median_session_minutes) &&
    isRecord(value.speak_back) &&
    isRecord(value.ai_cost_usd) &&
    Array.isArray(value.feedback) &&
    Array.isArray(value.crashes) &&
    typeof value.computed_at === 'string'
  )
}

const usd = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2,
  maximumFractionDigits: 4,
})

export function money(value: number | null): string {
  return value === null ? 'none' : usd.format(value)
}

export function retentionText(r: OwnerNumbers['day7_retention']): string {
  if (r.percent === null) return `No learner has reached day 7 yet (0 of 0 learners)`
  return `${String(r.percent)} percent (${String(r.retained)} of ${String(r.cohort)} learners)`
}

export function medianText(m: OwnerNumbers['median_session_minutes']): string {
  if (m.minutes === null) return 'No finished sessions yet'
  const sessions = m.used === 1 ? 'finished session' : 'finished sessions'
  return `${String(m.minutes)} minutes, from ${String(m.used)} ${sessions}`
}

export function speakBackText(s: OwnerNumbers['speak_back']): string {
  if (s.percent === null) return 'No active learners yet (0 of 0)'
  return `${String(s.percent)} percent (${String(s.count)} of ${String(s.base)})`
}

export function costText(c: OwnerNumbers['ai_cost_usd']): string {
  return `${money(c.total)} in total, ${money(c.per_active_learner)} per active learner`
}

/** "Fri 30 Oct" for a Helsinki day such as 2026-10-30. */
export function dayText(day: string): string {
  return new Date(`${day}T12:00:00Z`).toLocaleDateString('en-GB', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    timeZone: 'UTC',
  })
}

/** "30 Oct 2026, 14:05" in Helsinki time. */
export function timeText(iso: string): string {
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return iso
  return date.toLocaleString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Europe/Helsinki',
  })
}

/** A country's English name, with XX as "Unknown" and T1 as "Tor network"; the code when no name is known. */
export function countryName(code: string): string {
  if (code === 'XX') return 'Unknown'
  if (code === 'T1') return 'Tor network'
  try {
    const names =
      typeof Intl.DisplayNames === 'function' ? new Intl.DisplayNames(['en'], { type: 'region' }) : null
    return names?.of(code) ?? code
  } catch {
    return code
  }
}

export const SCREEN_NAMES: Record<string, string> = {
  front_door: 'From the front door',
  account: 'From the account page',
  finish: 'From the finish screen',
}

export const ACCOUNT_NAMES: Record<string, string> = {
  guest: 'Guest account',
  email: 'Email account',
}
