import type { FeedbackScreen } from '../../src/lib/feedback-types.ts'
import { PATHS } from '../../src/lib/app-paths.ts'
import type { Fetch } from '../learner-auth.ts'

// The owner's email alerts (fast route feedback-alert, owner's call of 21
// November 2026: a short alert, never the message itself; fast route
// reviewers, owner's call of 24 November 2026: the same kind of alert when
// someone signs up at /reviewers, never their name or email). This is the
// only file that knows the alerts go through Brevo's email API. Moving to
// another email service changes this file only.
//
// The alert holds the screen the message came from, the Helsinki time and a
// link to the owner page. It never holds the message, the learner's account
// id or anything else about the learner, so the learner's words never leave
// Aleksi's database and the privacy notice needs no change.
//
// At most one alert per ALERT_GAP_SECONDS per running copy of the Worker,
// kept in memory only (nothing is stored). Brevo's free plan allows 300 emails
// a day, shared with the sign in code emails, so a burst of feedback must not
// use them up. The owner page shows every message, so one alert per gap is
// enough. Cloudflare may run a few copies at once in different places, so in
// a burst a few alerts can arrive inside one gap; each copy still sends at
// most 48 a day.
//
// Without BREVO_API_KEY and FEEDBACK_ALERT_TO (local runs, previews, tests),
// nothing is sent. It never throws and writes nothing to the log.
//
// The reviewer sign up alert works the same way, with its own gap of the same
// length, so a burst of feedback never hides a sign up and the other way round.
// It holds only the Helsinki time and the owner page link.

export interface FeedbackAlertEnv {
  /** Brevo API key, a secret on the live Worker only. */
  BREVO_API_KEY?: string
  /** The owner's inbox for alerts, a secret on the live Worker only (never in a file). */
  FEEDBACK_ALERT_TO?: string
  /** The owner page's hostname, for the link (worker/owner.ts). */
  OWNER_HOSTNAME?: string
}

export const BREVO_SEND_URL = 'https://api.brevo.com/v3/smtp/email'
/** The address the sign in code emails already come from (src/privacy/processors.ts). */
export const ALERT_SENDER = { name: 'Aleksi', email: 'hello@meetaleksi.com' }
export const ALERT_SUBJECT = 'New feedback on Aleksi'
export const REVIEWER_ALERT_SUBJECT = 'New reviewer sign-up on Aleksi'
export const ALERT_GAP_SECONDS = 30 * 60
const TIMEOUT_MS = 3000

const SCREEN_NAMES: Record<FeedbackScreen, string> = {
  front_door: 'the road',
  account: 'the account page',
  finish: 'the end of a lesson',
}

/** The gap between alerts. Tests pass their own. */
export interface AlertGate {
  /** True, and the gap starts, when no alert went out in the last ALERT_GAP_SECONDS. */
  open(at: Date): boolean
}

/** A gate kept in memory, for one running copy of the Worker. */
export function memoryGate(): AlertGate {
  let last: number | null = null
  return {
    open(at) {
      const now = at.getTime()
      if (last !== null && now - last < ALERT_GAP_SECONDS * 1000) return false
      last = now
      return true
    },
  }
}

const sharedGate = memoryGate()
/** The reviewer sign up alert's own gap (fast route reviewers). */
const reviewerGate = memoryGate()

function setting(value: string | undefined): string {
  return value?.trim() ?? ''
}

function helsinkiTime(at: Date): string {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Europe/Helsinki',
    day: 'numeric',
    month: 'long',
    hour: '2-digit',
    minute: '2-digit',
  }).format(at)
}

/** The alert's plain text. Holds no learner data. */
export function alertText(screen: FeedbackScreen, at: Date, ownerHost: string): string {
  const lines = [
    `Someone sent feedback from ${SCREEN_NAMES[screen]} on ${helsinkiTime(at)} (Helsinki time).`,
    '',
    `You get at most one of these emails every ${String(ALERT_GAP_SECONDS / 60)} minutes, so there may be more messages.`,
  ]
  if (ownerHost) lines.push('', `Read them on your owner page: https://${ownerHost}${PATHS.owner}`)
  return lines.join('\n')
}

/** The reviewer sign up alert's plain text (fast route reviewers). Holds no name and no email. */
export function reviewerAlertText(at: Date, ownerHost: string): string {
  const lines = [
    `Someone signed up to help check the Finnish on ${helsinkiTime(at)} (Helsinki time).`,
    '',
    `You get at most one of these emails every ${String(ALERT_GAP_SECONDS / 60)} minutes, so there may be more sign-ups.`,
  ]
  if (ownerHost) lines.push('', `See them on your owner page: https://${ownerHost}${PATHS.owner}`)
  return lines.join('\n')
}

/**
 * Emails the owner one alert through Brevo, when it is configured and the
 * gate is open. True when Brevo accepted it; false when it is not configured,
 * inside the gap, refused or not reachable. Never throws.
 */
async function sendOwnerAlert(
  env: FeedbackAlertEnv,
  fetchImpl: Fetch,
  subject: string,
  text: (ownerHost: string) => string,
  at: Date,
  gate: AlertGate,
): Promise<boolean> {
  const key = setting(env.BREVO_API_KEY)
  const to = setting(env.FEEDBACK_ALERT_TO)
  if (!key || !to) return false
  // The gap starts before sending, so two messages at the same moment send one alert.
  if (!gate.open(at)) return false
  return brevoSend(key, to, subject, text(setting(env.OWNER_HOSTNAME)), fetchImpl)
}

/**
 * Sends one plain text email from Aleksi <hello@meetaleksi.com> through
 * Brevo's API. True when Brevo accepted it; false when it refused it or could
 * not be reached in time. Never throws. The owner's alerts and the review
 * link email (fast route review-links) share it.
 */
async function brevoSend(
  key: string,
  to: string,
  subject: string,
  text: string,
  fetchImpl: Fetch,
): Promise<boolean> {
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, TIMEOUT_MS)
  try {
    const res = await fetchImpl(BREVO_SEND_URL, {
      method: 'POST',
      headers: { 'api-key': key, 'content-type': 'application/json', accept: 'application/json' },
      body: JSON.stringify({
        sender: ALERT_SENDER,
        to: [{ email: to }],
        subject,
        textContent: text,
      }),
      signal: controller.signal,
    })
    await res.body?.cancel()
    return res.ok
  } catch {
    return false
  } finally {
    clearTimeout(timer)
  }
}

/**
 * Emails the owner a short alert. True when Brevo accepted it; false when it
 * is not configured, inside the gap, refused or not reachable.
 */
export function sendFeedbackAlert(
  env: FeedbackAlertEnv,
  fetchImpl: Fetch,
  screen: FeedbackScreen,
  at: Date = new Date(),
  gate: AlertGate = sharedGate,
): Promise<boolean> {
  return sendOwnerAlert(env, fetchImpl, ALERT_SUBJECT, (host) => alertText(screen, at, host), at, gate)
}

/**
 * Emails the owner that someone signed up as a reviewer (fast route
 * reviewers). The same rules as the feedback alert, with its own gap.
 */
export function sendReviewerAlert(
  env: FeedbackAlertEnv,
  fetchImpl: Fetch,
  at: Date = new Date(),
  gate: AlertGate = reviewerGate,
): Promise<boolean> {
  return sendOwnerAlert(
    env,
    fetchImpl,
    REVIEWER_ALERT_SUBJECT,
    (host) => reviewerAlertText(at, host),
    at,
    gate,
  )
}

// The review link email (fast route review-links, factory/jobs/review-links/spec.md,
// "Done when" 1). The owner presses "Send review link" on the owner page and the
// person who signed up at /reviewers gets their own private link, in the
// owner's words, word for word. It needs only BREVO_API_KEY: it goes to the
// sign up's own email address, never to the owner's inbox. Unlike the alerts
// it has no gap, because the owner sends each one by hand. The email holds the
// person's name and the link; Brevo is listed as its processor in the privacy
// notice (src/privacy/processors.ts).

export const REVIEW_LINK_SUBJECT = 'Your Aleksi review link'

/** The review link email's plain text, word for word from the spec. */
export function reviewLinkText(name: string, link: string): string {
  return [
    `Hi ${name},`,
    '',
    'Thank you for offering to help check the Finnish in Aleksi.',
    '',
    `Here is your private review link: ${link}`,
    '',
    'It has 27 short dialogues. For each line you can listen to the audio, read it in spoken and written Finnish, and mark it Correct, Needs a fix or Not sure. Your answers save as you go, so you can stop and come back with the same link.',
    '',
    'Please keep the link to yourself, since anyone who has it can add answers.',
    '',
    'Kiitos!',
    'Fumnanya',
  ].join('\n')
}

/** True when the Worker can send the review link email (BREVO_API_KEY is set). */
export function reviewLinkEmailReady(env: FeedbackAlertEnv): boolean {
  return setting(env.BREVO_API_KEY) !== ''
}

/**
 * Emails one person their private review link. True when Brevo accepted it;
 * false when BREVO_API_KEY is not set (nothing is sent), or Brevo refused it
 * or could not be reached. Never throws and writes nothing to the log.
 */
export function sendReviewLinkEmail(
  env: FeedbackAlertEnv,
  fetchImpl: Fetch,
  to: { name: string; email: string },
  link: string,
): Promise<boolean> {
  const key = setting(env.BREVO_API_KEY)
  const email = to.email.trim()
  if (!key || !email) return Promise.resolve(false)
  return brevoSend(key, email, REVIEW_LINK_SUBJECT, reviewLinkText(to.name, link), fetchImpl)
}
