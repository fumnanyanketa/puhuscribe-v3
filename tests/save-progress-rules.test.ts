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

// "Done when" 17: the note works at / today and under /learn after job
// 17-landing-page. The one app address it uses, the add email screen, is held
// in one constant, so job 17's move changes one line.

const THIS_JOBS_FILES = [
  'src/screens/SaveNote.tsx',
  'src/screens/save-note.ts',
  'src/screens/save-note-copy.ts',
  'src/screens/save-note-copy.test.ts',
  'src/screens/FinishScreen.tsx',
  'worker/api.ts',
  'worker/learner-db.ts',
  'worker/test-fakes.ts',
  'worker/save-progress.test.ts',
  ...readdirSync('e2e')
    .filter((name) => name.startsWith('save-progress'))
    .map((name) => `e2e/${name}`),
]

const THE_CONSTANT = /^export const ADD_EMAIL_PATH = '\/account\/email'$/m

/** A quoted app path: '/account, "/session, `/learn and so on. */
function quotedAppPaths(text: string): string[] {
  return [...text.matchAll(/(['"`])\/(account|session|learn)\b[^'"`]*/g)].map((m) => m[0])
}

describe('the note names no app path outside its one constant', () => {
  it('[save-progress 17] no file this job adds or changes holds a quoted app path, except the constant', () => {
    for (const path of THIS_JOBS_FILES) {
      const text = readFileSync(path, 'utf8').replace(THE_CONSTANT, '')
      expect(quotedAppPaths(text), path).toEqual([])
    }
  })

  it('[save-progress 17] the constant is in save-note-copy.ts, and the screen uses it', () => {
    expect(readFileSync('src/screens/save-note-copy.ts', 'utf8')).toMatch(THE_CONSTANT)
    const screen = readFileSync('src/screens/SaveNote.tsx', 'utf8')
    expect(screen).toContain('window.location.assign(ADD_EMAIL_PATH)')
  })

  it('[save-progress 17] the check catches a quoted path in each kind of quote, and lets other addresses through', () => {
    expect(quotedAppPaths("window.location.assign('/account/email')")).toHaveLength(1)
    expect(quotedAppPaths('page.goto("/session")')).toHaveLength(1)
    expect(quotedAppPaths('const url = `/learn/account`')).toHaveLength(1)
    expect(quotedAppPaths("href('/feedback?from=finish')")).toEqual([])
    expect(quotedAppPaths("callApi('/api/sessions/1/complete')")).toEqual([])
    expect(quotedAppPaths("window.location.assign('/')")).toEqual([])
  })

  it('[save-progress 17] this job adds no page route and no API route', () => {
    const app = readFileSync('src/App.tsx', 'utf8')
    expect(app).not.toMatch(/save-?note|save-?progress/i)
    const routes = readFileSync('worker/page-routes.ts', 'utf8')
    expect(routes).not.toMatch(/save-?note|save-?progress/i)
    expect(readFileSync('worker/api.ts', 'utf8')).not.toMatch(/\/api\/[a-z/-]*(save-?note|note)\b/)
  })
})
