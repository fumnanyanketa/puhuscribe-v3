// The words of the home screen's messages. They moved here unchanged from the
// retired front door (job 19-redesign). GUEST_LINE, the sentence that says
// starting makes a guest account, is protected copy:
// src/screens/protected-copy.test.ts freezes it. Aleksi has no age limit
// (owner, 5 November 2026, fast route no-age-limit), so the line states none.

export const GUEST_LINE = 'Starting creates a guest account on this device so your progress is saved.'
export const ENDED = 'Your guest session ended on this device. Press Start to begin again.'
export const ALL_DONE = 'You have finished every dialogue that is ready.'
export const NOT_READY = "Today's session is not ready yet. Please come back later."
export const NOT_STARTED = 'Could not start your session. Check your internet connection, then try again.'
export const EMPTY_DAY = 'That is all for today.'
export const LOADING = 'Loading your road.'

// The bot check on the guest Start (Cloudflare Turnstile, job turnstile). Kind and plain: a failed check is
// never the learner's fault, and the way forward is always to press Start again.
export const CHECK_ASKING =
  'Cloudflare needs one quick check that you are a person before your guest account is made.'
export const CHECK_FAILED = 'The quick safety check did not go through. Press Start to try again.'
export const CHECK_UNAVAILABLE =
  'The quick safety check could not load. Check your internet connection, then press Start again.'
