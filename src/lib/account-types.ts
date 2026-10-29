// The shapes the Worker sends the app for accounts and personal data
// (factory/jobs/11-accounts/spec.md). Shared by worker/ and src/, so both sides
// agree. No answer holds a token or a user id; only GET /api/me holds the
// learner's own email, and only for an email account.

/** GET /api/me (statement 3). */
export type MeAnswer = { kind: 'none' } | { kind: 'guest' } | { kind: 'email'; email: string }

/**
 * The one answer of POST /api/account/email and POST /api/sign-in, whatever
 * happened to the address: new, already used by an account, or unknown
 * (statement 9). Never change it per case.
 */
export const CODE_SENT_ANSWER = { sent: true } as const

/** POST /api/account/email/verify and POST /api/sign-in/verify, after a right code. */
export interface CodeAcceptedAnswer {
  /**
   * added: the guest account now has the email.
   * switched: this device is signed in to the account that already had the
   * email, and the guest account of this device was deleted.
   * signed_in: this device is signed in; it had no guest account.
   */
  result: 'added' | 'switched' | 'signed_in'
}

/** The error codes the account routes answer with. */
export type AccountError =
  | 'bad_email'
  | 'wrong_code'
  | 'too_many_tries'
  | 'has_email'
  | 'guest_cannot_sign_out'
  | 'signed_out'
  | 'session_ended'
  | 'not_deleted'
  | 'not_available'

/**
 * Added to a 401 "session_ended" answer when the account that ended was an
 * email account (read from the old sign in, only to pick the message).
 * Guests get job 8's answer unchanged.
 */
export interface EndedHint {
  account?: 'email'
}
