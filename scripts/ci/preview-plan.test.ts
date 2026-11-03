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
    testsRan: true,
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

  // Changed when the owner paused every test until the MVP launch (3 November 2026).
  it('[fast 4] with no tests on pull requests the comment says no browser test ran, and still gives the link', () => {
    const body = previewComment({ ...base, databaseChanged: false, testsRan: false })
    expect(body).toBe(
      "Preview for abcdef1: https://x-puhuscribe-preview.a.workers.dev\n\nPrivate: opening it shows a Cloudflare Access sign in first. No browser test ran against this link or on this pull request. Until the MVP launch, by the owner's decision of 3 November 2026, only the secret scan runs on each change; the full run happens once before launch.",
    )
    expect(body).not.toContain('already ran')
  })

  it('[fast 4] with no tests and a database change, the database note is added without claiming tests ran', () => {
    const body = previewComment({ ...base, databaseChanged: true, testsRan: false })
    expect(body).toContain('No browser test ran against this link')
    expect(body).toContain('This pull request changes the database.')
    expect(body).not.toContain('The browser tests ran on a throwaway database')
    expect(body).not.toContain('playwright-report')
  })
})
