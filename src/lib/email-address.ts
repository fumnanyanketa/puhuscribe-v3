// One rule for an email address the learner types, used by the browser before
// sending and by the Worker before it asks Supabase anything
// (factory/jobs/11-accounts/spec.md, "Done when" 4). It only checks the shape:
// whether an inbox exists is proven by the code sent to it.

/** The longest address the email standards allow (RFC 5321 path limit). */
export const MAX_EMAIL_LENGTH = 254

// Something before one @, something after it with at least one dot, and no
// spaces or control characters anywhere.
const SHAPE = /^[^\s@\p{Cc}]+@[^\s@\p{Cc}]+\.[^\s@\p{Cc}.]+$/u

/**
 * The address as the app sends it (trimmed and in lower case), or null when it
 * is empty, longer than 254 characters, or not shaped like an email address.
 */
export function cleanEmail(raw: unknown): string | null {
  if (typeof raw !== 'string') return null
  const email = raw.trim().toLowerCase()
  if (email.length === 0 || email.length > MAX_EMAIL_LENGTH) return null
  if (!SHAPE.test(email)) return null
  return email
}

/** A 6 digit code, as typed (spaces removed), or null. */
export function cleanCode(raw: unknown): string | null {
  if (typeof raw !== 'string') return null
  const code = raw.replace(/\s+/g, '')
  return /^\d{6}$/.test(code) ? code : null
}
