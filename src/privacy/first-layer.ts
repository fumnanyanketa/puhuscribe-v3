// The first layer of the privacy notice (job 19-redesign, statement 39): a
// short summary and five short sections, drawn on 1 November 2026. The full
// notice of job 11 stays behind "Read the full notice", unchanged in content.
//
// Every claim the first layer makes is listed here with the line of
// src/privacy/data-inventory.ts, src/privacy/processors.ts or the rights that
// supports it, and src/privacy/first-layer.test.ts checks each one. A claim the
// inventory does not support is reworded, not kept. Two claims of the drawing
// were reworded this way: "Never your name" became "We never ask for your
// name" (the inventory says no name is asked for, and a feedback message could
// hold one by accident), and "Checked, then deleted" became "Your recording is
// checked, then deleted" (the transcript is kept for 90 days, the recording is
// not).

export const FIRST_LAYER = {
  title: 'Privacy notice',
  summary: 'We keep only what we need to teach you, in the EU. You can download it or delete it at any time.',
  sections: [
    {
      id: 'privacy-keep',
      heading: 'What we keep',
      text: 'Your progress, your settings, and a random guest id or your email. We never ask for your name.',
    },
    {
      id: 'privacy-voice',
      heading: 'Your voice',
      text: 'Only if you turn on speaking feedback. Your recording is checked, then deleted, unless you choose to keep it.',
    },
    {
      // Job 16-tutor-step; reworded on 3 November 2026 (fast route otso-privacy) after the manager's
      // check of Anthropic's terms. The detail sits behind "More about Otso" (processors.ts, Anthropic).
      id: 'privacy-tutor',
      heading: 'Talking with Aleksi',
      text: 'Only if you turn Aleksi on. Your chats with Aleksi, typed or spoken, go as text to Anthropic in the United States. We do not save them.',
    },
    {
      id: 'privacy-time',
      heading: 'How long',
      text: 'While you use Aleksi. A guest account is deleted after 90 days without use, and an email account after 24 months.',
    },
    {
      id: 'privacy-rights-short',
      heading: 'Your rights',
      text: 'See, download or delete everything from Your account.',
    },
    {
      id: 'privacy-who-short',
      heading: 'Who runs Aleksi',
      // The owner's sentence, word for word (1 November 2026).
      text: 'Aleksi is part of the product family of Exentrik, a product studio in Finland.',
    },
  ],
  fullNotice: 'Read the full notice',
  hideFullNotice: 'Hide the full notice',
} as const

/** A claim of the first layer, and where in the inventory its support is. */
export interface Claim {
  claim: string
  /** The file and line of the data it rests on, in words. */
  source: string
}

export const CLAIMS: readonly Claim[] = [
  {
    claim: 'We keep it in the EU',
    source: 'processors.ts, Supabase: "In the EU (Germany)."',
  },
  {
    claim: 'You can download it or delete it at any time',
    source: 'PrivacyPage.tsx RIGHTS: "Download my data" and "Delete my account"',
  },
  {
    claim: 'We keep your progress and your settings',
    source: 'data-inventory.ts LEARNER_TABLES: Sessions, Review cards, Voice consent choices',
  },
  {
    claim: 'We keep a random guest id, or your email',
    source: 'data-inventory.ts ACCOUNT_ITEMS: Guest account ("A random account id"), Email account',
  },
  {
    claim: 'We never ask for your name',
    source: 'data-inventory.ts ACCOUNT_ITEMS: Guest account "No name"; no item asks for a name',
  },
  {
    claim: 'Speaking feedback is only if you turn it on',
    source: 'processors.ts, Microsoft: "only if you turned speaking feedback on"',
  },
  {
    claim: 'Your recording is deleted unless you choose to keep it',
    source:
      'data-inventory.ts LEARNER_TABLES: Kept recordings, "Only if you chose"; Speaking feedback results, "No audio"',
  },
  {
    claim: 'Chats with Aleksi, typed or spoken, go as text to Anthropic in the United States',
    source: 'processors.ts, Anthropic: role and where; worker/tutor-prompt.ts builds the request',
  },
  {
    claim: 'We do not save the chats',
    source: 'data-inventory.ts LEARNER_TABLES: Calls to Aleksi, "No text"',
  },
  {
    claim: 'A guest account is deleted after 90 days without use, an email account after 24 months',
    source: 'data-inventory.ts HOW_LONG',
  },
  {
    claim: 'You can see, download or delete everything from Your account',
    source:
      'PrivacyPage.tsx RIGHTS: download, and delete ("deletes everything linked to your account at once")',
  },
]
