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
//   HEAD_SHA=... URL=... DB_CHANGED=true|false RUN_URL=... node scripts/ci/preview-plan.ts comment
//     -> prints the pull request comment
import { readFileSync } from 'node:fs'

const MIGRATIONS = 'supabase/migrations/'

export function changesDatabase(paths: string[]): boolean {
  return paths.some((path) => path.trim().startsWith(MIGRATIONS))
}

export interface CommentInput {
  sha: string
  url: string
  databaseChanged: boolean
  runUrl: string
}

export function previewComment({ sha, url, databaseChanged, runUrl }: CommentInput): string {
  const parts = [
    `Preview for ${sha.slice(0, 7)}: ${url}`,
    "Private: opening it shows a Cloudflare Access sign in first. The browser tests in this job already ran against it with the evaluator's service token.",
  ]
  if (databaseChanged) {
    parts.push(
      `This pull request changes the database. The preview uses the shared test project, which gets these changes only after you approve the job, so screens that need them do not work on this link yet. The browser tests ran on a throwaway database with the changes; their videos and screenshots are in the playwright-report download of this run: ${runUrl}`,
    )
  }
  return parts.join('\n\n')
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
    const changed = required('DB_CHANGED')
    if (changed !== 'true' && changed !== 'false') {
      console.error('DB_CHANGED must be true or false.')
      process.exit(1)
    }
    console.log(
      previewComment({
        sha: required('HEAD_SHA'),
        url: required('URL'),
        databaseChanged: changed === 'true',
        runUrl: required('RUN_URL'),
      }),
    )
  } else {
    console.error('Usage: preview-plan.ts database-changed|comment')
    process.exit(1)
  }
}
