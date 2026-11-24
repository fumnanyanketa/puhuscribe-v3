import { cleanEmail } from './email-address.ts'

// The reviewer sign up form at /reviewers (fast route reviewers,
// factory/jobs/reviewers/spec.md, "Done when" 3). One set of rules, used by
// the page before sending and by the Worker before it asks the database,
// which checks the same limits again (supabase/migrations/*_reviewer_signups.sql).

/** The longest name and thank-you name, in characters. */
export const MAX_REVIEWER_NAME = 100

export interface ReviewerSignup {
  name: string
  /** Trimmed and in lower case (src/lib/email-address.ts). */
  email: string
  /** The name for the thank-you in the owner's next video, or null for none. */
  thanksName: string | null
}

export type ReviewerField = 'name' | 'email' | 'thanks_name'

/** A pair of UTF-16 surrogates: one character outside the basic plane, such as an emoji. */
const SURROGATE_PAIR = /[\uD800-\uDBFF][\uDC00-\uDFFF]/g

/**
 * Characters as the database counts them (Postgres char_length, one per Unicode
 * code point), so the page, the Worker and the database agree on 100.
 */
export function characterCount(text: string): number {
  return text.replace(SURROGATE_PAIR, '_').length
}

// No control characters (new lines, tabs, invisible codes) in a name.
const CONTROL = /\p{Cc}/u

/** The cleaned name (null for an empty optional one), or null itself when the name is refused. */
function cleanName(raw: unknown, required: boolean): { value: string | null } | null {
  if (raw === undefined || raw === null) return required ? null : { value: null }
  if (typeof raw !== 'string') return null
  const name = raw.trim()
  if (name === '') return required ? null : { value: null }
  if (characterCount(name) > MAX_REVIEWER_NAME || CONTROL.test(name)) return null
  return { value: name }
}

/** The sign up as it is stored, or the first field that is refused. */
export function parseReviewerSignup(raw: unknown): ReviewerSignup | { bad: ReviewerField } {
  if (typeof raw !== 'object' || raw === null) return { bad: 'name' }
  const fields = raw as Record<string, unknown>
  const name = cleanName(fields.name, true)?.value
  if (!name) return { bad: 'name' }
  const email = cleanEmail(fields.email)
  if (email === null) return { bad: 'email' }
  const thanksName = cleanName(fields.thanksName, false)
  if (thanksName === null) return { bad: 'thanks_name' }
  return { name, email, thanksName: thanksName.value }
}
