import { spawnSync } from 'node:child_process'
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'

// [8] The build fails when a built browser file holds a secret. `npm run build`
// runs this checker last, so a non-zero exit here fails the build.

const CHECKER = join(import.meta.dirname, 'check-built-secrets.ts')
const dirs: string[] = []

function builtDir(files: Record<string, string>): string {
  const dir = mkdtempSync(join(tmpdir(), 'puhuscribe-dist-'))
  dirs.push(dir)
  for (const [name, content] of Object.entries(files)) {
    mkdirSync(join(dir, name, '..'), { recursive: true })
    writeFileSync(join(dir, name), content)
  }
  return dir
}

function runChecker(dir: string, env: Record<string, string> = {}) {
  return spawnSync(process.execPath, [CHECKER, dir], { encoding: 'utf8', env: { ...process.env, ...env } })
}

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true })
})

describe('check-built-secrets', () => {
  it('[8] passes clean browser files', () => {
    const result = runChecker(
      builtDir({ 'index.html': '<h1>PuhuScribe</h1>', 'assets/app.js': 'fetch("/api/health")' }),
    )
    expect(result.status).toBe(0)
  })

  it('[8] fails when a built file contains a key shaped string', () => {
    const leaked = 'sb_' + 'secret_' + 'Abcdefghijklmnop1234'
    const result = runChecker(builtDir({ 'assets/app.js': `const k="${leaked}"` }))
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('Supabase secret key')
    expect(result.stderr).not.toContain(leaked)
  })

  it('[8] fails when a built file contains a secret name listed in .env.example', () => {
    const result = runChecker(builtDir({ 'assets/app.js': 'const n="SUPABASE_PUBLISHABLE_KEY"' }))
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('secret name SUPABASE_PUBLISHABLE_KEY')
  })

  it('[8] fails when a built file contains the value of a secret in the environment', () => {
    const value = 'plain-value-without-a-known-shape-42'
    const result = runChecker(builtDir({ 'assets/app.js': `const v="${value}"` }), { SOME_TEST_TOKEN: value })
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('contains the value of SOME_TEST_TOKEN')
    expect(result.stderr).not.toContain(value)
  })

  it('[8] fails when there is nothing to scan', () => {
    const result = runChecker(join(tmpdir(), 'puhuscribe-does-not-exist'))
    expect(result.status).toBe(1)
  })
})
