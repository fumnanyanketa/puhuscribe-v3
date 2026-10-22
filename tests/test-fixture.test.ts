import { execFileSync } from 'node:child_process'
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterAll, beforeAll, describe, expect, it } from 'vitest'

// Statement 20 of factory/jobs/8-first-session/spec.md: the test dialogue
// lives only in throwaway databases. It is a browser seed file
// (supabase/seeds/browser/), never a migration, never applied to the test
// project, and none of its Finnish is in the built app.

const SEED = 'supabase/seeds/browser/010_test_fixture_unit_1.sql'
const seed = readFileSync(SEED, 'utf8')

function allFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? allFiles(path) : [path]
  })
}

// Both texts of every line in the seed, read from its dialogue_lines rows.
function fixtureFinnish(): string[] {
  const block = seed.slice(
    seed.indexOf('insert into public.dialogue_lines'),
    seed.indexOf('insert into public.tokens'),
  )
  const texts: string[] = []
  const row = /\('test-fixture-dialogue[a-z0-9-]*', \d+, '[^']*',\s*'((?:[^']|'')*)',\s*'((?:[^']|'')*)'/g
  for (const match of block.matchAll(row)) texts.push(match[1] ?? '', match[2] ?? '')
  return texts.map((text) => text.replace(/''/g, "'"))
}

describe('the test fixture seed', () => {
  it('[session 20] holds one unit at position 900, two approved dialogues, a draft dialogue, a draft line and a draft form', () => {
    expect(seed).toMatch(/'test-fixture-unit-1', 900,/)
    expect(seed).toContain("where slug in ('test-fixture-dialogue-1', 'test-fixture-dialogue-2');")
    expect(seed).toContain("('test-fixture-dialogue-draft', 3,")
    expect(seed).toContain("'Test fixture draft line, never shown.'")
    expect(seed).toContain("update public.forms set status = 'draft' where lemma = 'kotoisin'")
  })

  it('[session 20] every approval reference starts with test-fixture:not-reviewed and every audio key with test-fixture/', () => {
    const refs = [...seed.matchAll(/approval_ref\s*=\s*'([^']*)'|'(test-fixture:[^']*)'/g)].map(
      (m) => m[1] ?? m[2] ?? '',
    )
    expect(refs.length).toBeGreaterThan(2)
    for (const ref of refs) expect(ref.startsWith('test-fixture:not-reviewed')).toBe(true)
    expect(seed).not.toMatch(/approval_ref\s*=\s*'(?!test-fixture:not-reviewed)/)
    expect(seed).toContain("'test-fixture/' || d.slug || '/' || l.position || '-puhe.mp3'")
    expect(seed).toContain("'test-fixture/' || d.slug || '/' || l.position || '-kirja.mp3'")
  })

  it('[session 20] its Finnish is lines 1 to 5 of the voice test sheet', () => {
    const sheet = readFileSync('docs/risk-tests/test-2-voice-lines.md', 'utf8')
    const lines = fixtureFinnish()
    expect(lines.length).toBe(12)
    for (const text of lines) expect(sheet, text).toContain(text)
  })
})

describe('where the fixture can go', () => {
  it('[session 20] no migration contains test-fixture', () => {
    for (const name of readdirSync('supabase/migrations')) {
      expect(readFileSync(join('supabase/migrations', name), 'utf8'), name).not.toMatch(/test-fixture/i)
    }
  })

  it('[session 20] no workflow applies seeds to a hosted database (no --include-seed)', () => {
    for (const name of readdirSync('.github/workflows')) {
      expect(readFileSync(join('.github/workflows', name), 'utf8'), name).not.toContain('--include-seed')
    }
  })

  it('[session 20] supabase/config.toml does not load the browser seeds', () => {
    const config = readFileSync('supabase/config.toml', 'utf8')
    const paths = /^sql_paths\s*=\s*\[([^\]]*)\]/m.exec(config)?.[1] ?? ''
    expect(paths).not.toMatch(/browser|test-fixture/)
  })
})

describe('the built app', () => {
  let out = ''
  let client: string[] = []
  // The Cloudflare plugin points `vite preview` at the last build through this
  // file; it is put back afterwards (as in tests/design-build.test.ts).
  const PREVIEW_POINTER = '.wrangler/deploy/config.json'
  const pointerBefore = existsSync(PREVIEW_POINTER) ? readFileSync(PREVIEW_POINTER, 'utf8') : null

  beforeAll(() => {
    out = mkdtempSync(join(tmpdir(), 'puhuscribe-fixture-build-'))
    execFileSync(
      process.execPath,
      ['node_modules/vite/bin/vite.js', 'build', '--outDir', out, '--emptyOutDir'],
      {
        env: { ...process.env, NODE_ENV: 'production', VITE_DESIGN_REFERENCE: '0' },
        stdio: 'ignore',
      },
    )
    // Only the browser files are read: the Worker side of a local build can
    // hold a copy of .env.local, which this test never opens.
    client = allFiles(join(out, 'client')).filter((file) => /\.(js|css|html)$/.test(file))
  }, 180_000)

  afterAll(() => {
    if (out) rmSync(out, { recursive: true, force: true })
    if (pointerBefore === null) rmSync(PREVIEW_POINTER, { force: true })
    else writeFileSync(PREVIEW_POINTER, pointerBefore)
  })

  it("[session 20] contains none of the fixture's Finnish", () => {
    expect(client.length).toBeGreaterThan(0)
    const built = client.map((file) => readFileSync(file, 'utf8')).join('\n')
    expect(built).toContain("Today's session")
    for (const text of fixtureFinnish()) expect(built, text).not.toContain(text)
    expect(built).not.toContain('test-fixture')
  })
})
