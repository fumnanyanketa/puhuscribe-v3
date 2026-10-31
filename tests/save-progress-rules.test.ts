import { readdirSync, readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels [save-progress N] are the "Done when" statement numbers from
// factory/jobs/18-save-progress/spec.md that each test protects.
// Repository rules for the note that asks a guest to add an email.

/** The one migration this job adds. */
function thisJobsMigrations(): string[] {
  return readdirSync('supabase/migrations').filter((name) => name.endsWith('_save_progress_note.sql'))
}

/** SQL without its comments, so a word in a comment never counts. */
function code(sql: string): string {
  return sql.replace(/--.*$/gm, '').replace(/\/\*[\s\S]*?\*\//g, '')
}

describe('the migration stores nothing new', () => {
  it('[save-progress 13] the job adds exactly one migration', () => {
    expect(thisJobsMigrations()).toHaveLength(1)
  })

  it('[save-progress 13] it does not create or change a table or a type', () => {
    const [name] = thisJobsMigrations()
    const sql = code(readFileSync(`supabase/migrations/${name ?? ''}`, 'utf8'))
    expect(sql).not.toMatch(/\bcreate\s+table\b/i)
    expect(sql).not.toMatch(/\balter\s+table\b/i)
    expect(sql).not.toMatch(/\bcreate\s+type\b/i)
    expect(sql).not.toMatch(/\balter\s+type\b/i)
  })

  it('[save-progress 13] it creates exactly one function and writes no row', () => {
    const [name] = thisJobsMigrations()
    const sql = code(readFileSync(`supabase/migrations/${name ?? ''}`, 'utf8'))
    expect(sql.match(/\bcreate\s+(or\s+replace\s+)?function\b/gi)).toHaveLength(1)
    expect(sql).not.toMatch(/\b(insert\s+into|update\s+public|delete\s+from)\b/i)
  })

  it('[save-progress 4] the function is stable, invoker, with an empty search path and written out grants', () => {
    const [name] = thisJobsMigrations()
    const sql = code(readFileSync(`supabase/migrations/${name ?? ''}`, 'utf8'))
    expect(sql).toMatch(/\bstable\b/i)
    expect(sql).toMatch(/security\s+invoker/i)
    expect(sql).not.toMatch(/security\s+definer/i)
    expect(sql).toMatch(/set\s+search_path\s*=\s*''/i)
    expect(sql).toMatch(
      /revoke\s+all\s+on\s+function\s+public\.save_progress_note\(uuid\)\s+from\s+public,\s*anon,\s*authenticated,\s*service_role/i,
    )
    expect(sql).toMatch(
      /grant\s+execute\s+on\s+function\s+public\.save_progress_note\(uuid\)\s+to\s+authenticated\s*;/i,
    )
  })
})
