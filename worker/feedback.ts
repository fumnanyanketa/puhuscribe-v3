import {
  FEEDBACK_LIMIT_TEXT,
  MAX_FEEDBACK_CHARS,
  feedbackLength,
  isFeedbackScreen,
  type FeedbackScreen,
} from '../src/lib/feedback-types.ts'
import { json, refuseUnsafeWrite, withCookies } from './http.ts'
import type { LearnerClient, LearnerContext } from './learner-auth.ts'

// POST /api/feedback (factory/jobs/14-analytics/spec.md, "Done when" 19, 21
// and 22). JSON from this same address, the body read and capped at 8 KB
// before anything is answered, and a working sign in. The message is stored
// with the learner's own token, so the database's rules decide: only for
// themselves, at most 5 a Helsinki day. The message is never logged.
//
// 201 sent; 400 for an empty or too long message or an unknown screen; 429
// with the gentle line when the day's 5 are used.

export const MAX_FEEDBACK_BODY_BYTES = 8 * 1024

export interface FeedbackDb {
  /** Stores one message; "limit" when the day's 5 are used. */
  send(screen: FeedbackScreen, message: string): Promise<'sent' | 'limit'>
}

export class FeedbackUnavailable extends Error {}

export function supabaseFeedbackDb(client: LearnerClient): FeedbackDb {
  return {
    async send(screen, message) {
      const { error } = await client.from('feedback').insert({ screen, message })
      if (!error) return 'sent'
      if (error.message === 'feedback_daily_limit') return 'limit'
      throw new FeedbackUnavailable()
    },
  }
}

export function parseFeedback(
  body: string,
): { screen: FeedbackScreen; message: string } | 'bad_screen' | 'bad_message' {
  let parsed: unknown
  try {
    parsed = JSON.parse(body)
  } catch {
    return 'bad_message'
  }
  if (typeof parsed !== 'object' || parsed === null) return 'bad_message'
  const { screen, message } = parsed as { screen?: unknown; message?: unknown }
  if (!isFeedbackScreen(screen)) return 'bad_screen'
  if (typeof message !== 'string') return 'bad_message'
  const trimmed = message.trim()
  const length = feedbackLength(trimmed)
  if (length < 1 || length > MAX_FEEDBACK_CHARS) return 'bad_message'
  return { screen, message: trimmed }
}

export interface FeedbackKit {
  signedIn: (
    request: Request,
  ) => Promise<
    { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
  >
  feedbackDb: (context: LearnerContext) => FeedbackDb
}

export async function feedbackRoute(request: Request, kit: FeedbackKit): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_FEEDBACK_BODY_BYTES)
  if (write.refused) return write.refused
  const parsed = parseFeedback(write.body)
  if (parsed === 'bad_screen' || parsed === 'bad_message') return json({ error: parsed }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status: number) => withCookies(json(body, status), context.setCookies())
  try {
    const result = await kit.feedbackDb(context).send(parsed.screen, parsed.message)
    if (result === 'limit') return done({ error: 'feedback_limit', message: FEEDBACK_LIMIT_TEXT }, 429)
    return done({ sent: true }, 201)
  } catch {
    return done({ error: 'not_available' }, 503)
  }
}
