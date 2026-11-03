// What the preview job does on a pull request that changes the database
// (factory/jobs/6-pr-local-db, "Done when" 10). The preview Worker uses the
// shared test project, which gets a pull request's migrations only after the
// owner approves the job. So when a pull request adds, changes or deletes a
// migration, only the Cloudflare Access lock tests (tag @preview) run on the
// preview, and the comment says where the full test videos are.
//
// In the workflow:
//   git diff --name-only --no-renames "$BASE_SHA...HEAD" | node scripts/ci/preview-plan.ts database-changed
//     -> prints true or false
//   HEAD_SHA=... URL=... DB_CHANGED=true|false TESTS_RAN=true|false RUN_URL=... node scripts/ci/preview-plan.ts comment
//     -> prints the pull request comment
//
// TESTS_RAN is false until the MVP launch: by the owner's decision of 3
// November 2026 no test runs on a pull request. The preview is still uploaded
// and its link posted, and the comment says no test ran on it.
import { readFileSync } from 'node:fs'

const MIGRATIONS = 'supabase/migrations/'

export function changesDatabase(paths: string[]): boolean {
  return paths.some((path) => path.trim().startsWith(MIGRATIONS))
}

export interface CommentInput {
  sha: string
  url: string
  databaseChanged: boolean
  testsRan: boolean
  runUrl: string
}

const TESTS_RAN =
  "Private: opening it shows a Cloudflare Access sign in first. The browser tests in this job already ran against it with the evaluator's service token."
const NO_TESTS =
  "Private: opening it shows a Cloudflare Access sign in first. No browser test ran against this link or on this pull request. Until the MVP launch, by the owner's decision of 3 November 2026, only the secret scan runs on each change; the full run happens once before launch."

const DATABASE_NOTE =
  'This pull request changes the database. The preview uses the shared test project, which gets these changes only after you approve the job, so screens that need them do not work on this link yet.'

export function previewComment({ sha, url, databaseChanged, testsRan, runUrl }: CommentInput): string {
  const parts = [`Preview for ${sha.slice(0, 7)}: ${url}`, testsRan ? TESTS_RAN : NO_TESTS]
  if (databaseChanged) {
    // The sentence about the throwaway database is true only when its browser tests ran.
    parts.push(
      testsRan
        ? `${DATABASE_NOTE} The browser tests ran on a throwaway database with the changes; their videos and screenshots are in the playwright-report download of this run: ${runUrl}`
        : DATABASE_NOTE,
    )
  }
  return parts.join('\n\n')
}

function trueOrFalse(name: string): boolean {
  const value = required(name)
  if (value !== 'true' && value !== 'false') {
    console.error(`${name} must be true or false.`)
    process.exit(1)
  }
  return value === 'true'
}

function required(name: string): string {
  const value = process.env[name]?.trim()
  if (!value) {
    console.error(`${name} is not set.`)
    process.exit(1)
  }
  return value
}

if (import.meta.main) {
  const mode = process.argv[2]
  if (mode === 'database-changed') {
    console.log(String(changesDatabase(readFileSync(0, 'utf8').split(/\r?\n/))))
  } else if (mode === 'comment') {
    console.log(
      previewComment({
        sha: required('HEAD_SHA'),
        url: required('URL'),
        databaseChanged: trueOrFalse('DB_CHANGED'),
        testsRan: trueOrFalse('TESTS_RAN'),
        runUrl: required('RUN_URL'),
      }),
    )
  } else {
    console.error('Usage: preview-plan.ts database-changed|comment')
    process.exit(1)
  }
}
