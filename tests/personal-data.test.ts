import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { USER_TABLE_NAMES } from '../src/privacy/data-inventory.ts'
import { PROCESSORS } from '../src/privacy/processors.ts'
import { FILE_STORE_MODULES, FILE_STORES } from '../worker/personal-data/file-stores.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
// Repository rules for accounts and personal data.

function filesUnder(dir: string, pattern: RegExp): string[] {
  if (!existsSync(dir)) return []
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name).replace(/\\/g, '/')
    if (statSync(path).isDirectory()) return filesUnder(path, pattern)
    return pattern.test(name) ? [path] : []
  })
}

/** Worker files (not tests) that write files: Supabase Storage uploads or an R2 binding's put(). */
export function fileWriters(files: { path: string; text: string }[], allowed: readonly string[]): string[] {
  return files
    .filter(({ path, text }) => !allowed.includes(path) && /\bstorage\s*\.\s*from\s*\(|\.put\s*\(/.test(text))
    .map(({ path }) => path)
}

/** Provider files not named by any processor in the privacy notice. */
export function unlistedProviders(
  files: string[],
  processors: readonly { modules: readonly string[] }[],
): string[] {
  const named = new Set(processors.flatMap((p) => p.modules))
  return files.filter((file) => !named.has(file))
}

const workerCode = () =>
  filesUnder('worker', /\.ts$/)
    .filter((path) => !path.endsWith('.test.ts'))
    .map((path) => ({ path, text: readFileSync(path, 'utf8') }))

describe('processors in the privacy notice', () => {
  it('[accounts 17] every file in worker/providers/ is named by a processor in src/privacy/processors.ts', () => {
    const providers = filesUnder('worker/providers', /\.ts$/)
      .filter((path) => !path.endsWith('.test.ts'))
      .map((path) => path.slice('worker/providers/'.length))
    expect(unlistedProviders(providers, PROCESSORS)).toEqual([])
  })

  it('[accounts 17] the check catches an unlisted provider file', () => {
    expect(unlistedProviders(['speech.ts'], PROCESSORS)).toEqual(['speech.ts'])
    expect(unlistedProviders(['speech.ts'], [...PROCESSORS, { modules: ['speech.ts'] }])).toEqual([])
  })
})

describe('files stored for a learner', () => {
  it('[accounts 23] the file store list is empty today and every listed module exists', () => {
    expect(FILE_STORES).toEqual([])
    for (const path of FILE_STORE_MODULES) expect(existsSync(path), path).toBe(true)
  })

  it('[accounts 23] no code in worker/ writes files outside a module listed in file-stores.ts', () => {
    const code = workerCode()
    expect(code.length).toBeGreaterThan(5)
    expect(fileWriters(code, FILE_STORE_MODULES)).toEqual([])
  })

  it('[accounts 23] the check catches a Supabase Storage upload and an R2 put outside the list', () => {
    const probe = [
      { path: 'worker/recordings.ts', text: "await client.storage.from('recordings').upload(name, body)" },
      { path: 'worker/r2.ts', text: 'await env.RECORDINGS.put(key, body)' },
      { path: 'worker/fine.ts', text: 'headers.set("a", "b")' },
    ]
    expect(fileWriters(probe, [])).toEqual(['worker/recordings.ts', 'worker/r2.ts'])
    expect(fileWriters(probe, ['worker/recordings.ts', 'worker/r2.ts'])).toEqual([])
  })
})

describe('no stronger key anywhere in worker/', () => {
  it('[accounts 26] no Worker file, in any folder, reads a Supabase secret key or service role key', () => {
    const code = workerCode()
    expect(code.some(({ path }) => path.startsWith('worker/personal-data/'))).toBe(true)
    for (const { path, text } of code)
      expect(text, path).not.toMatch(/service_role|SERVICE_ROLE|SECRET_KEY|sb_secret/i)
  })
})

describe('the export covers every user table', () => {
  it('[accounts 17] [accounts 19] the newest export_my_data() names exactly the inventory tables', () => {
    const migrations = readdirSync('supabase/migrations')
      .filter((name) => name.endsWith('.sql'))
      .sort()
      .map((name) => readFileSync(join('supabase/migrations', name), 'utf8'))
      .filter((text) => /create (or replace )?function public\.export_my_data\(\)/.test(text))
    const newest = migrations.at(-1) ?? ''
    const body = newest.slice(newest.search(/create (or replace )?function public\.export_my_data\(\)/))
    const keys = [...body.slice(0, body.indexOf('$$;')).matchAll(/^\s*'([a-z_.]+)', coalesce\(/gm)].map(
      (m) => m[1],
    )
    expect(keys.length).toBeGreaterThan(0)
    expect([...keys].sort()).toEqual([...USER_TABLE_NAMES].sort())
  })
})

const configToml = readFileSync('supabase/config.toml', 'utf8').replace(/\r\n/g, '\n')

function tomlSection(name: string): string {
  const header = `\n[${name}]\n`
  const start = configToml.indexOf(header)
  if (start < 0) throw new Error(`No [${name}] in supabase/config.toml`)
  const rest = configToml.slice(start + header.length)
  const end = rest.search(/^\[/m)
  return end < 0 ? rest : rest.slice(0, end)
}

describe('local Supabase settings', () => {
  it('[accounts 7] confirm email is on, so an email is attached only with its code', () => {
    expect(tomlSection('auth.email')).toMatch(/^enable_confirmations = true$/m)
    expect(tomlSection('auth.email')).toMatch(/^double_confirm_changes = true$/m)
  })

  it('[accounts 15] both code emails use the PuhuScribe templates and subject', () => {
    for (const [section, file] of [
      ['auth.email.template.magic_link', './supabase/templates/magic-link.html'],
      ['auth.email.template.email_change', './supabase/templates/email-change.html'],
    ] as const) {
      expect(tomlSection(section)).toContain('subject = "Your PuhuScribe code"')
      expect(tomlSection(section)).toContain(`content_path = "${file}"`)
    }
  })
})

describe('the code emails', () => {
  const templates = ['supabase/templates/magic-link.html', 'supabase/templates/email-change.html'].map(
    (path) => readFileSync(path, 'utf8'),
  )

  it('[accounts 15] show the code and the two lines, and the same body for both kinds', () => {
    for (const html of templates) {
      expect(html).toContain('{{ .Token }}')
      expect(html).toContain('Enter it in the app. It works for one hour.')
      expect(html).toContain('If you did not ask for this code, you can ignore this email.')
    }
    expect(templates[0]).toBe(templates[1])
  })

  it('[accounts 15] [accounts 9] hold no link and nothing that depends on the account', () => {
    for (const html of templates) {
      expect(html).not.toMatch(/https?:|href|ConfirmationURL|TokenHash|RedirectTo|SiteURL/i)
      // Only the code is filled in: no {{ if }} and no other value.
      expect([...html.matchAll(/\{\{[^}]*\}\}/g)].map((m) => m[0])).toEqual(['{{ .Token }}'])
    }
  })
})

describe('records', () => {
  it('[accounts 29] the conventions name the [accounts N] label and the rule for new user tables', () => {
    const conventions = readFileSync('docs/conventions.md', 'utf8')
    expect(conventions).toContain('| 11-accounts | `[accounts N]` |')
    expect(conventions).toMatch(
      /A new user table .* goes into `public\.export_my_data\(\)` and `src\/privacy\/data-inventory\.ts` in the same job/,
    )
  })

  it('[accounts 29] the data model describes the three functions, the clean up and the export check', () => {
    const model = readFileSync('docs/data-model.md', 'utf8')
    for (const name of [
      'public.my_account()',
      'public.export_my_data()',
      'public.delete_my_account()',
      'private.delete_inactive_guests()',
      'The export check',
    ]) {
      expect(model).toContain(name)
    }
    expect(model).not.toContain('Job 9 builds the clean up')
  })

  it('[accounts 29] the README keeps running costs at €0 and lists the owner setup steps', () => {
    const readme = readFileSync('README.md', 'utf8')
    const costs = readme.slice(readme.indexOf('## Running costs'))
    expect(costs).toMatch(/Supabase Cron .*€0/)
    expect(readme).toContain('## Owner setup for accounts (job 11-accounts)')
    for (const step of [
      '"Magic link"',
      '"Change email address"',
      '"Confirm email"',
      '"Secure email change"',
      'Write audit logs to the database',
    ]) {
      expect(readme).toContain(step)
    }
  })
})
