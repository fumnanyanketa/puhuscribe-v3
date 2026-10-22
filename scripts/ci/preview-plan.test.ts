import { describe, expect, it } from 'vitest'
import { changesDatabase, previewComment } from './preview-plan.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/6-pr-local-db/spec.md that each test protects.

const NOTE =
  'This pull request changes the database. The preview uses the shared test project, which gets these changes only after you approve the job, so screens that need them do not work on this link yet. The browser tests ran on a throwaway database with the changes; their videos and screenshots are in the playwright-report download of this run: https://github.com/o/r/actions/runs/42'

describe('changesDatabase', () => {
  it('[prdb 10] a pull request that adds, changes or deletes a migration changes the database', () => {
    expect(changesDatabase(['src/App.tsx', 'supabase/migrations/20261101000000_new_table.sql'])).toBe(true)
    expect(changesDatabase(['supabase/migrations/20261019183410_create_visits.sql'])).toBe(true)
  })

  it('[prdb 10] a pull request with no migration file does not', () => {
    expect(changesDatabase([])).toBe(false)
    expect(
      changesDatabase([
        'src/App.tsx',
        'supabase/tests/database/visits_access.test.sql',
        'supabase/config.toml',
        'supabase/seeds/browser/010_rows.sql',
        'docs/supabase/migrations/note.md',
      ]),
    ).toBe(false)
  })

  it('[prdb 10] ignores empty lines and surrounding spaces from git output', () => {
    expect(changesDatabase(['', '  supabase/migrations/x.sql  '])).toBe(true)
  })
})

describe('previewComment', () => {
  const base = {
    sha: 'abcdef1234567',
    url: 'https://x-puhuscribe-preview.a.workers.dev',
    runUrl: 'https://github.com/o/r/actions/runs/42',
  }

  it('[prdb 10] without a database change the comment is the same as before this job', () => {
    expect(previewComment({ ...base, databaseChanged: false })).toBe(
      "Preview for abcdef1: https://x-puhuscribe-preview.a.workers.dev\n\nPrivate: opening it shows a Cloudflare Access sign in first. The browser tests in this job already ran against it with the evaluator's service token.",
    )
  })

  it('[prdb 10] with a database change the comment adds the note with the run link', () => {
    const body = previewComment({ ...base, databaseChanged: true })
    expect(body.startsWith('Preview for abcdef1: https://x-puhuscribe-preview.a.workers.dev\n\n')).toBe(true)
    expect(body.endsWith(`\n\n${NOTE}`)).toBe(true)
  })
})
