import { spawnSync } from 'node:child_process'
import { existsSync, readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { isSecretName, namesFromEnvFile } from '../scripts/security/secrets.ts'

// [9] Secrets have one home: git ignores every local secret file and every
// build or test output, and .env.example lists names without values.

function ignored(path: string): boolean {
  return spawnSync('git', ['check-ignore', '--quiet', '--no-index', path]).status === 0
}

describe('.gitignore', () => {
  it.each([
    '.env.local',
    '.env',
    '.dev.vars',
    '.dev.vars.preview',
    '.wrangler/state/file',
    'dist/client/index.html',
    'playwright-report/index.html',
    'test-results/run/trace.zip',
    '.venv/bin/python',
  ])('[9] ignores %s', (path) => {
    expect(ignored(path)).toBe(true)
  })

  it("[smoke 7] ignores the Supabase CLI's local state in supabase/.temp/", () => {
    expect(ignored('supabase/.temp/cli-latest')).toBe(true)
    expect(ignored('supabase/migrations/20261019183410_create_visits.sql')).toBe(false)
  })

  it('[9] keeps .env.example in git', () => {
    expect(ignored('.env.example')).toBe(false)
  })
})

// Labels [public N] are the findings of the pre-publication review
// (factory/jobs/14-public-repo/review-prepublish.md).

describe('recording/ is a separate private repository', () => {
  it('[public 7] git ignores everything in recording/, so session logs are never committed here', () => {
    expect(ignored('recording/log-turn.mjs')).toBe(true)
    expect(ignored('recording/scenes/0001.md')).toBe(true)
  })
})

describe('third party notices', () => {
  const notices = readFileSync('THIRD-PARTY-NOTICES.md', 'utf8')

  it('[public 3] the first line says the repository has no licence yet', () => {
    expect(notices.split(/\r?\n/)[0]).toMatch(/no licen[cs]e/i)
  })

  it('[public 3] names the MIT skills and the three CC BY-SA files', () => {
    for (const text of [
      'jsmastery-pro/skills',
      'MIT License',
      'data/finnish_frequency_lemmas.json',
      'content/v2-starter/from-v2/20260607000003_word_ipa_from_kaikki.sql',
      'supabase/migrations/20261020090300_load_v2_lemma_ipa.sql',
      'CC BY-SA 4.0',
      'https://creativecommons.org/licenses/by-sa/4.0/',
    ]) {
      expect(notices, text).toContain(text)
    }
  })

  it('[public 3] lists every skill that skills-lock.json says came from jsmastery-pro/skills', () => {
    const lock = JSON.parse(readFileSync('skills-lock.json', 'utf8')) as {
      skills: Record<string, { source: string }>
    }
    const names = Object.entries(lock.skills)
      .filter(([, skill]) => skill.source === 'jsmastery-pro/skills')
      .map(([name]) => name)
    expect(names.length).toBeGreaterThan(0)
    for (const name of names) expect(notices, name).toContain(`\`${name}\``)
  })

  it('[public 3] adds no root LICENSE file, because the owner has not chosen a licence', () => {
    for (const name of ['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'COPYING']) {
      expect(existsSync(name), name).toBe(false)
    }
  })

  it('[public 3] the README links the notices file', () => {
    expect(readFileSync('README.md', 'utf8')).toContain('(THIRD-PARTY-NOTICES.md)')
  })
})

describe('.env.example', () => {
  const text = readFileSync('.env.example', 'utf8')
  const assignments = text.split(/\r?\n/).filter((line) => /^[A-Z_][A-Z0-9_]*=/.test(line))

  it('[9] gives no variable a value', () => {
    for (const line of assignments) {
      const value = (line.split('=')[1] ?? '').split('#')[0]?.trim()
      expect(value, line).toBe('')
    }
  })

  it('[9] gives every variable a one line purpose', () => {
    for (const line of assignments) expect(line, line).toMatch(/#\s*\S/)
  })

  it('[9] lists every GitHub secret the checks use', () => {
    const names = namesFromEnvFile(text)
    for (const name of [
      'CLOUDFLARE_API_TOKEN',
      'CLOUDFLARE_ACCOUNT_ID',
      'SUPABASE_TEST_URL',
      'SUPABASE_TEST_PUBLISHABLE_KEY',
      'SUPABASE_TEST_DB_URL',
      'CF_ACCESS_CLIENT_ID',
      'CF_ACCESS_CLIENT_SECRET',
    ]) {
      expect(names).toContain(name)
    }
  })

  it('[8] has no secret looking name with the VITE_ prefix', () => {
    expect(namesFromEnvFile(text).filter((n) => n.startsWith('VITE_') && isSecretName(n))).toEqual([])
  })
})
