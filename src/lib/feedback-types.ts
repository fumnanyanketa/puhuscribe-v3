// What the feedback page and POST /api/feedback share
// (factory/jobs/14-analytics/spec.md, "Done when" 19 and 22).

/** The screens a learner can send feedback from: front door, account page, finish screen. */
export const FEEDBACK_SCREENS = ['front_door', 'account', 'finish'] as const
export type FeedbackScreen = (typeof FEEDBACK_SCREENS)[number]

export const MAX_FEEDBACK_CHARS = 1000

/** The gentle line when the day's 5 messages are used. */
export const FEEDBACK_LIMIT_TEXT = 'You have sent 5 messages today. Please try again tomorrow.'

export function isFeedbackScreen(value: unknown): value is FeedbackScreen {
  return FEEDBACK_SCREENS.some((screen) => screen === value)
}

/** How many characters a message has, as the database counts them (code points). */
export function feedbackLength(message: string): number {
  return Array.from(message).length
}
