// The one list of what PuhuScribe keeps about a learner
// (factory/jobs/11-accounts/spec.md, "Done when" 17). The privacy notice's
// "What we keep" section is rendered from it, and the downloaded file's
// "about" part is built from it, so the two cannot drift apart.
//
// Rule for every job: a new user table goes into public.export_my_data() and
// into USER_TABLES here, in the same job. A browser test fails when the
// downloaded file's table names and this list differ, and a database test
// fails when the export misses a table.
//
// Every sentence here comes from the "Privacy notice facts" table of the spec.

/** How long everything is kept, for every item below. */
export const HOW_LONG =
  'Until you delete your account, except where an item below says it goes sooner. A guest account is deleted after 90 days with no learning activity, and an email account after 24 months with no learning activity. Deleting your account deletes everything at once.'

/** The retention of items that last as long as the account does. */
export const WHILE_ACCOUNT =
  'Until you delete your account (or the account is deleted for inactivity, see below).'

export const CONSENT_REASON =
  'Your consent (GDPR Article 6(1)(a)). You can withdraw it at any time in Voice settings.'

export const SERVICE_REASON = 'Needed to provide the service you asked for (GDPR Article 6(1)(b)).'

export interface InventoryItem {
  /** A short name for the reader. */
  name: string
  /** What is kept, in plain words. */
  what: string
  /** Why it is kept. */
  why: string
  /** The legal reason. */
  legal: string
  /** How long it is kept. */
  keep: string
}

export interface TableItem extends InventoryItem {
  /** The table's name, as the downloaded file names it. */
  table: string
}

/** The account itself (Supabase Auth). In the download it is "account". */
export const ACCOUNT_ITEMS: readonly InventoryItem[] = [
  {
    name: 'Guest account',
    what: 'A random account id and its sign in times. No name.',
    why: 'To keep your progress on this device.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    name: 'Email account',
    what: 'Your email address, used only to send you sign in codes. No newsletters.',
    why: 'So you can sign in and keep your progress on other devices.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
]

/** Every user table, in the order the download lists them. */
export const USER_TABLES: readonly TableItem[] = [
  {
    table: 'sessions',
    name: 'Sessions',
    what: 'Which dialogue you worked on, how far you got, and when you started and finished.',
    why: 'To show you the next dialogue and bring you back where you left off.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    table: 'cards',
    name: 'Review cards',
    what: 'One card for each word form you met in a dialogue, with when it is due for review.',
    why: 'To bring words back for review at the right time.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    table: 'review_logs',
    name: 'Review results',
    what: 'One line for each review: which word form, the result, whether you typed or spoke the answer, and when.',
    why: 'To plan your next reviews.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    table: 'consents',
    name: 'Voice consent choices',
    what: 'Each choice you make about your voice, the version of the text you were shown, and the time.',
    why: 'To respect the choice you made and show which text you saw.',
    legal: CONSENT_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    table: 'usage_events',
    name: 'Finished first session',
    what: 'One "finished first session" event: which session, and when.',
    why: 'To know how many learners finish their first session.',
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
  {
    table: 'speaking_attempts',
    name: 'Speaking feedback results',
    what: 'One line for each time you said a line or word out loud and asked for feedback: which line or word, the text the speech service heard (the transcript), how close it was, and what the check cost. No audio.',
    why: 'To show you feedback, and to check that the feedback works.',
    legal: CONSENT_REASON,
    keep: 'The transcript is deleted after 90 days. The rest of the line stays until you delete your account.',
  },
  {
    table: 'speech_checks',
    name: 'Speaking feedback counter',
    what: 'One line with the time for each speaking feedback check you started. No content.',
    why: 'To limit how many checks one account can start, so the service stays fair and affordable.',
    legal: CONSENT_REASON,
    keep: 'Deleted after one day.',
  },
  {
    table: 'kept_recordings',
    name: 'Kept recordings',
    what: 'Only if you chose "keep my recordings": your first and latest try of each line, as a short audio file.',
    why: 'So you can play back your own voice and hear your progress.',
    legal: CONSENT_REASON,
    keep: 'Deleted after 90 days, immediately when you turn the choice off, or when you delete one yourself in Voice settings.',
  },
  {
    table: 'feedback',
    name: 'Feedback you send',
    what: 'The message you send, which screen you sent it from, and when.',
    why: 'So we can read what worked for you, what did not and what broke.',
    legal: SERVICE_REASON,
    keep: 'Stored with your account and deleted with it, including when an unused account is deleted automatically.',
  },
  {
    table: 'private.owners',
    name: 'Owner page access',
    what: "Only for the app's owner: that the account may open the private owner page, and since when. Empty for every learner.",
    why: "So that only the owner can open the page with the app's overall numbers.",
    legal: SERVICE_REASON,
    keep: WHILE_ACCOUNT,
  },
]

/**
 * What PuhuScribe keeps that is not linked to any account
 * (factory/jobs/14-analytics/spec.md, "Privacy notice facts").
 */
export const NOT_LINKED_ITEMS: readonly InventoryItem[] = [
  {
    name: 'Visit count',
    what: 'When you open PuhuScribe, we add one to a count for your country and the day. The country comes from your internet address, which we do not keep. We store no cookie, identifier or browser details for this.',
    why: 'To know how many people use the app and from where.',
    legal:
      'Our legitimate interest in knowing how many people use the app and from where (GDPR Article 6(1)(f)).',
    keep: 'Kept as daily totals.',
  },
  {
    name: 'Crash reports',
    what: 'When the app breaks, it records the error, the file and line, the screen, the app version and a short browser label such as "Safari 17, iOS". Not linked to your account, and nothing you typed or said is included.',
    why: 'To find and fix what broke.',
    legal: 'Our legitimate interest in keeping the app working (GDPR Article 6(1)(f)).',
    keep: 'Deleted after 30 days.',
  },
]

/** The table names, for checks. */
export const USER_TABLE_NAMES: readonly string[] = USER_TABLES.map((item) => item.table)

/** The "about" part of the downloaded file: what each part is, in plain English. */
export function aboutTheDownload(): Record<string, unknown> {
  return {
    file: 'Everything PuhuScribe keeps about your account, as it was when you downloaded this file.',
    exported_at: 'When this file was made.',
    account: ACCOUNT_ITEMS.map((item) => `${item.name}: ${item.what}`).join(' '),
    tables: Object.fromEntries(USER_TABLES.map((item) => [item.table, item.what])),
    files: 'Files kept outside the database. PuhuScribe keeps none today, so this part is empty.',
    how_long: HOW_LONG,
  }
}
