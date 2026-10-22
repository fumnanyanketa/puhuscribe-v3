import { isRecord, type ApiAnswer } from './api.ts'

// Messages the front door shows after the learner left another page
// (factory/jobs/11-accounts/spec.md, "Done when" 14, 20 and 22). The page that
// sends the learner to / names the message in the address (/?notice=...), so
// a reload shows it again. Only a message key goes in the address, never
// anything about the learner, and the front door shows it only when this
// device has no sign in.

export const SIGNED_OUT = 'You are signed out on this device.'
export const SIGNED_OUT_EMAIL = 'You are signed out on this device. Sign in with your email to continue.'
export const DELETED = 'Your account and all its data are deleted.'

const NOTICES = new Map<string, string>([
  ['signed-out', SIGNED_OUT],
  ['signed-out-email', SIGNED_OUT_EMAIL],
  ['deleted', DELETED],
])

export type NoticeKey = 'signed-out' | 'signed-out-email' | 'deleted'

/** The message named in the address, or null. */
export function noticeFrom(search: string): string | null {
  const key = new URLSearchParams(search).get('notice')
  return key === null ? null : (NOTICES.get(key) ?? null)
}

/** Goes to the front door with a message. */
export function leaveWith(key: NoticeKey): void {
  window.location.assign(`/?notice=${key}`)
}

/**
 * True when an answer says the email account of this device is gone or signed
 * out elsewhere (401 with account "email"). Guests keep job 8's own handling.
 */
export function emailSignInEnded(answer: ApiAnswer | null): boolean {
  return answer?.status === 401 && isRecord(answer.body) && answer.body.account === 'email'
}
