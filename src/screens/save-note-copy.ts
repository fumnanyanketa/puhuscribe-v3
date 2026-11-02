// The words of the finish screen's note that asks a guest to add an email
// (factory/jobs/18-save-progress/spec.md, "Done when" 9 and 17). They are all
// here so the owner can edit them at one place and one test can check them
// against the writing rules (src/screens/save-note-copy.test.ts).
//
// The sentence was the owner's call 2, option B, of 31 October 2026. On
// 1 November 2026 the owner changed it to the words below and the button to
// "Create account", centred (job 19-redesign, owner's answers). Plain English,
// no Finnish, no number, no word about losing anything.

/** The region's name for screen readers. It is not shown on screen. */
export const SAVE_NOTE_REGION = 'Keep your progress'

export const SAVE_NOTE_SENTENCE = 'Create an account to save your progress.'

/** The secondary button. It leads to the add email screen of job 11-accounts. */
export const SAVE_NOTE_ADD = 'Create account'

/** The quiet button that closes the note. */
export const SAVE_NOTE_LATER = 'Not now'

/**
 * The finish screen's status line for a guest (the owner's choice of 1 November
 * 2026, round 2): the progress is saved, and only on this phone until an email
 * is added. A learner with an email keeps the plain "Your progress is saved.",
 * which stays in FinishScreen.tsx.
 */
export const SAVED_ON_THIS_DEVICE = 'Your progress is saved on this device.'

/** What replaces the note after "Not now", and where to find the choice again. */
export const SAVE_NOTE_CLOSED = 'No problem. You can add your email later from Your account.'

/**
 * The one place this job names an app address: the add email screen (job
 * 11-accounts). Job 17-landing-page moves the app under /learn; if it adds a
 * helper for the app's base path, this line uses it, and nothing else here
 * changes. tests/save-progress-rules.test.ts fails if another file of this job
 * holds such an address.
 */
export const ADD_EMAIL_PATH = '/account/email'
