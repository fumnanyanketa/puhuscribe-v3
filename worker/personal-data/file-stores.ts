import type { LearnerClient } from '../learner-auth.ts'

// Every place outside the database where the Worker keeps a learner's files
// (factory/jobs/11-accounts/spec.md, "Done when" 23 and contract note 2).
//
// Deleting an account calls deleteAllFor on every store BEFORE the database
// row is deleted; if one store fails, nothing in the database is deleted. The
// download of a learner's data includes every store's exportFor result.
//
// Empty today: no job stores a learner's files outside the database. A job that
// does (for example recordings in Supabase Storage or an R2 bucket) adds its
// store to FILE_STORES and the module that writes the files to
// FILE_STORE_MODULES, and replaces private.user_has_stored_files() in the
// database so the daily clean up skips those learners. A repository test
// (tests/personal-data.test.ts) fails when code in worker/ writes files outside
// a module listed here.

/** Whose files: the learner's own id (from my_account) and their own client. */
export interface FileOwner {
  userId: string
  /** Supabase, as the learner (their own token). */
  client: LearnerClient
}

export interface FileStore {
  /** The key of this store's part in the downloaded file's "files". */
  name: string
  /** Everything this store holds for the learner, as JSON, for the download. */
  exportFor: (owner: FileOwner) => Promise<unknown>
  /** Deletes everything this store holds for the learner. Throws when it could not. */
  deleteAllFor: (owner: FileOwner) => Promise<void>
}

export const FILE_STORES: readonly FileStore[] = []

/** The worker/ files (paths from the repository root) allowed to write files. */
export const FILE_STORE_MODULES: readonly string[] = []
