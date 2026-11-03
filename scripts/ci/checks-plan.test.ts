import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { needsDatabaseTests, writesSql } from './checks-plan.ts'

// Labels [fast N] are the numbered parts of the owner's decision of 3 November
// 2026 on the checks (fast checks on every change, one full run before the MVP
// launch), as the factory manager wrote them down for job fast-checks.
// [fast 1]: the database tests run only when a change touches supabase/ or a
// scripts/generate/ file that writes SQL tests or migrations.

const GENERATED_SQL_WRITERS = [
  'scripts/generate/fixture_outputs.py',
  'scripts/generate/pipeline.py',
  'scripts/generate/publish.py',
  'scripts/generate/road_fix.py',
  'scripts/generate/road_fix_pgtap.py',
  'scripts/generate/road_forms_pgtap.py',
  'scripts/generate/road_pgtap.py',
  'scripts/generate/road_publish.py',
  'scripts/generate/road_sql.py',
]

describe('which changes run the database tests', () => {
  it('[fast 1] any file under supabase/ runs them', () => {
    for (const path of [
      'supabase/migrations/20261103000000_new_table.sql',
      'supabase/tests/database/accounts.test.sql',
      'supabase/config.toml',
      'supabase/seeds/browser/010_rows.sql',
    ]) {
      expect(needsDatabaseTests(['src/App.tsx', path]), path).toBe(true)
    }
  })

  it('[fast 1] the files the database job reads or checks run them', () => {
    for (const path of [
      'src/lib/database.types.ts',
      'scripts/v2-import/fixtures/check-load-twice.sql',
      'package-lock.json',
      'package.json',
      '.github/workflows/checks.yml',
    ]) {
      expect(needsDatabaseTests([path]), path).toBe(true)
    }
  })

  it('[fast 1] every real scripts/generate/ file that writes SQL runs them, read from disk', () => {
    for (const path of GENERATED_SQL_WRITERS) {
      expect(writesSql(path), path).toBe(true)
      expect(needsDatabaseTests([path]), path).toBe(true)
    }
  })

  it('[fast 1] the list above is every such file today, so a new SQL writer is not missed by a stale list', () => {
    const found = readdirSync('scripts/generate')
      .filter((name) => name.endsWith('.py'))
      .map((name) => join('scripts/generate', name).replace(/\\/g, '/'))
      .filter((path) => writesSql(path))
    expect(found.sort()).toEqual(GENERATED_SQL_WRITERS)
  })

  it('[fast 1] a scripts/generate/ file that writes no SQL, and a Python test file, do not', () => {
    for (const path of [
      'scripts/generate/analysis.py',
      'scripts/generate/voikko_gate.py',
      'scripts/generate/test_road_publish.py',
      'scripts/generate/README.md',
    ]) {
      expect(needsDatabaseTests([path]), path).toBe(false)
    }
    expect(readFileSync('scripts/generate/analysis.py', 'utf8')).not.toMatch(/supabase/)
  })

  it('[fast 1] a generator is judged by its text: naming supabase/tests, supabase/migrations or a .sql file', () => {
    const read = (text: string) => () => text
    expect(writesSql('scripts/generate/new.py', read('OUT = REPO / "supabase" / "tests" / "x"'))).toBe(true)
    expect(writesSql('scripts/generate/new.py', read('path = "supabase/migrations/1_x.sql"'))).toBe(true)
    expect(writesSql('scripts/generate/new.py', read('write("a1_road.test.sql")'))).toBe(true)
    expect(writesSql('scripts/generate/new.py', read('import voikko'))).toBe(false)
  })

  it('[fast 1] a deleted generator runs them, since it may have written SQL', () => {
    expect(needsDatabaseTests(['scripts/generate/gone.py'], () => undefined)).toBe(true)
  })

  it('[fast 1] app, test, docs and notes changes do not run them', () => {
    expect(
      needsDatabaseTests([
        '',
        'src/App.tsx',
        'worker/index.ts',
        'e2e/front-door.spec.ts',
        'tests/checks-workflow.test.ts',
        'docs/supabase/migrations/note.md',
        'README.md',
        '.github/workflows/content-pipeline.yml',
      ]),
    ).toBe(false)
  })

  it('[fast 1] ignores empty lines and surrounding spaces from git output', () => {
    expect(needsDatabaseTests(['', '  supabase/migrations/x.sql  '])).toBe(true)
    expect(needsDatabaseTests([])).toBe(false)
  })
})
