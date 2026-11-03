// The consent text for talking with Otso, the AI tutor, and its version label
// (factory/jobs/16-tutor-step/spec.md, "Done when" 5 and 25, with the owner's answers of 3 November
// 2026: Anthropic's API, processed in the United States). The one place this text lives. The Worker
// writes TUTOR_NOTICE_VERSION into every ai_tutor consents row it adds; the browser never chooses
// it. A new text needs a new label.
//
// Draft wording for the owner to approve at the end of the job.

export const TUTOR_NOTICE_VERSION = 'tutor-2026-11.2'

/** The sentence the consent screen and the privacy notice share about what is kept. */
export const TUTOR_KEEPS =
  'PuhuScribe does not keep your messages or Otso’s answers. It keeps only a line for each AI call: which session, when, which model, how many tokens and what it cost.'

export const TUTOR_NOTICE = {
  heading: 'Talk with Otso',
  paragraphs: [
    'Otso is an AI tutor. At the end of a lesson he has a short chat with you, using only Finnish words you have met.',
    'What you type or say in the chat, Otso’s earlier lines and the list of Finnish words you have met go to Anthropic, the AI company, in the United States. We never send your email or account. What you type or say to Otso is sent as text, so leave out personal details.',
    TUTOR_KEEPS,
    'You can turn Otso off at any time on your account page.',
  ],
  turnOn: 'Talk with Otso',
  notNow: 'Not now',
} as const
