// The consent text for talking with Otso, the AI tutor, and its version label
// (factory/jobs/16-tutor-step/spec.md, "Done when" 5 and 25, with the owner's answers of 3 November
// 2026: Anthropic's API, processed in the United States). The one place this text lives. The Worker
// writes TUTOR_NOTICE_VERSION into every ai_tutor consents row it adds; the browser never chooses
// it. A new text needs a new label.
//
// Draft wording for the owner to approve at the end of the job.

// tutor-2026-11.3: the tutor and the app renamed Aleksi (owner, 4 November 2026, job rename-aleksi).
export const TUTOR_NOTICE_VERSION = 'tutor-2026-11.3'

/** The sentence the consent screen and the privacy notice share about what is kept. */
export const TUTOR_KEEPS =
  'We do not keep your messages or Aleksi’s answers. We keep only a line for each AI call: which session, when, which model, how many tokens and what it cost.'

export const TUTOR_NOTICE = {
  heading: 'Talk with Aleksi',
  paragraphs: [
    'Aleksi is an AI tutor. At the end of a lesson he has a short chat with you, using only Finnish words you have met.',
    'What you type or say in the chat, Aleksi’s earlier lines and the list of Finnish words you have met go to Anthropic, the AI company, in the United States. We never send your email or account. What you type or say to Aleksi is sent as text, so leave out personal details.',
    TUTOR_KEEPS,
    'You can turn Aleksi off at any time on your account page.',
  ],
  turnOn: 'Talk with Aleksi',
  notNow: 'Not now',
} as const
