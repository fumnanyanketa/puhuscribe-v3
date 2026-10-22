import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// Rules about the Worker's files and its Cloudflare settings.

describe('no stronger key anywhere', () => {
  it('[session 7] no Worker file reads a Supabase secret key or service role key', () => {
    const files = readdirSync('worker').filter((name) => name.endsWith('.ts') && !name.endsWith('.test.ts'))
    expect(files.length).toBeGreaterThan(3)
    for (const name of files) {
      const text = readFileSync(join('worker', name), 'utf8')
      expect(text, name).not.toMatch(/service_role|SERVICE_ROLE|SECRET_KEY|sb_secret/i)
    }
  })
})

describe('Cloudflare invocation logs', () => {
  it('[session 19] are turned off in wrangler.jsonc', () => {
    const config = readFileSync('wrangler.jsonc', 'utf8')
    // The file is JSON with comments and trailing commas; strip both to read it.
    const plain = config
      .replace(/^\s*\/\/.*$/gm, '')
      .replace(/\/\*[\s\S]*?\*\//g, '')
      .replace(/,(\s*[}\]])/g, '$1')
    const parsed = JSON.parse(plain) as { observability?: { logs?: { invocation_logs?: unknown } } }
    expect(parsed.observability?.logs?.invocation_logs).toBe(false)
  })
})
