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
  'Until you delete your account. A guest account is deleted after 90 days with no learning activity, and an email account after 24 months with no learning activity. Deleting your account deletes everything at once.'

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
  },
  {
    name: 'Email account',
    what: 'Your email address, used only to send you sign in codes. No newsletters.',
    why: 'So you can sign in and keep your progress on other devices.',
    legal: SERVICE_REASON,
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
  },
  {
    table: 'cards',
    name: 'Review cards',
    what: 'One card for each word form you met in a dialogue, with when it is due for review.',
    why: 'To bring words back for review at the right time.',
    legal: SERVICE_REASON,
  },
  {
    table: 'review_logs',
    name: 'Review results',
    what: 'One line for each review: which word form, the result, whether you typed or spoke the answer, and when.',
    why: 'To plan your next reviews.',
    legal: SERVICE_REASON,
  },
  {
    table: 'consents',
    name: 'Voice consent choices',
    what: 'Each choice you make about your voice, the version of the text you were shown, and the time.',
    why: 'To respect the choice you made and show which text you saw.',
    legal: SERVICE_REASON,
  },
  {
    table: 'usage_events',
    name: 'Finished first session',
    what: 'One "finished first session" event: which session, and when.',
    why: 'To know how many learners finish their first session.',
    legal: SERVICE_REASON,
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
