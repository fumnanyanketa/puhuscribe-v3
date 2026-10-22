import { execFileSync } from 'node:child_process'
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterAll, beforeAll, describe, expect, it } from 'vitest'

// Statement 15 of factory/jobs/12-units-1-3/spec.md: the test content for
// units 2 and 3 lives only in throwaway databases. It is a browser seed file
// (supabase/seeds/browser/, loaded after job 8's unit 1 fixture), never a
// migration, never applied to the test project, and none of its Finnish is in
// the built app. Job 8's checks in tests/test-fixture.test.ts, extended to
// this file.

const SEED = 'supabase/seeds/browser/020_test_fixture_units_2_3.sql'
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
  const row = /\('test-fixture-dialogue[a-z0-9-]*', \d+, '[^']*', '((?:[^']|'')*)', '((?:[^']|'')*)'/g
  for (const match of block.matchAll(row)) texts.push(match[1] ?? '', match[2] ?? '')
  return texts.map((text) => text.replace(/''/g, "'"))
}

describe('the units 2 and 3 test fixture seed', () => {
  it('[units 15] holds two test units at positions 901 and 902 with one approved dialogue each', () => {
    expect(seed).toMatch(/\('test-fixture-unit-2', 901,/)
    expect(seed).toMatch(/\('test-fixture-unit-3', 902,/)
    expect(seed).toContain("('test-fixture-unit-2', 'test-fixture-dialogue-unit-2', 1,")
    expect(seed).toContain("('test-fixture-unit-3', 'test-fixture-dialogue-unit-3', 1,")
    expect(seed).toContain("where slug in ('test-fixture-dialogue-unit-2', 'test-fixture-dialogue-unit-3');")
  })

  it('[units 15] every approval reference starts with test-fixture:not-reviewed and every audio key with test-fixture/', () => {
    const refs = [...seed.matchAll(/approval_ref\s*=\s*'([^']*)'|'(test-fixture:[^']*)'/g)].map(
      (m) => m[1] ?? m[2] ?? '',
    )
    expect(refs.length).toBeGreaterThan(2)
    for (const ref of refs) expect(ref.startsWith('test-fixture:not-reviewed')).toBe(true)
    expect(seed).not.toMatch(/approval_ref\s*=\s*'(?!test-fixture:not-reviewed)/)
    expect(seed).toContain("'test-fixture/' || d.slug || '/' || l.position || '-puhe.mp3'")
    expect(seed).toContain("'test-fixture/' || d.slug || '/' || l.position || '-kirja.mp3'")
  })

  it('[units 15] its Finnish is lines 6 to 10 of the voice test sheet', () => {
    const sheet = readFileSync('docs/risk-tests/test-2-voice-lines.md', 'utf8')
    const rows = sheet.split('\n').filter((line) => /^\| (6|7|8|9|10) \|/.test(line))
    expect(rows).toHaveLength(5)
    const lines = fixtureFinnish()
    expect(lines).toHaveLength(10)
    const expected = rows.flatMap((row) =>
      row
        .split('|')
        .slice(2, 4)
        .map((cell) => cell.trim()),
    )
    expect(lines).toEqual(expected)
  })

  it('[units 15] every form name and "why" line it writes is marked as fixture', () => {
    const block = seed.slice(
      seed.indexOf('insert into public.forms'),
      seed.indexOf('insert into public.dialogue_lines'),
    )
    const pairs = [...block.matchAll(/'(Test fixture[^']*)',\s*'([^']*)'\)/g)]
    expect(pairs.length).toBe(16)
    for (const [, name, why] of pairs) {
      expect(name?.startsWith('Test fixture')).toBe(true)
      expect(why?.startsWith('Test fixture, not reviewed.')).toBe(true)
    }
  })
})

describe('where the units 2 and 3 fixture can go', () => {
  it('[units 15] no migration contains test-fixture', () => {
    for (const name of readdirSync('supabase/migrations')) {
      expect(readFileSync(join('supabase/migrations', name), 'utf8'), name).not.toMatch(/test-fixture/i)
    }
  })

  it('[units 15] the checks workflow loads browser seeds only into the throwaway database, and no workflow applies seeds to a hosted one', () => {
    for (const name of readdirSync('.github/workflows')) {
      expect(readFileSync(join('.github/workflows', name), 'utf8'), name).not.toContain('--include-seed')
    }
    const config = readFileSync('supabase/config.toml', 'utf8')
    const paths = /^sql_paths\s*=\s*\[([^\]]*)\]/m.exec(config)?.[1] ?? ''
    expect(paths).not.toMatch(/browser|test-fixture/)
  })
})

describe('the built app and the units 2 and 3 fixture', () => {
  let out = ''
  let client: string[] = []
  // The Cloudflare plugin points `vite preview` at the last build through this
  // file; it is put back afterwards (as in tests/test-fixture.test.ts).
  const PREVIEW_POINTER = '.wrangler/deploy/config.json'
  const pointerBefore = existsSync(PREVIEW_POINTER) ? readFileSync(PREVIEW_POINTER, 'utf8') : null

  beforeAll(() => {
    out = mkdtempSync(join(tmpdir(), 'puhuscribe-fixture-units-build-'))
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

  it("[units 15] contains none of the fixture's Finnish", () => {
    expect(client.length).toBeGreaterThan(0)
    const built = client.map((file) => readFileSync(file, 'utf8')).join('\n')
    expect(built).toContain("Patterns you've seen")
    for (const text of fixtureFinnish()) expect(built, text).not.toContain(text)
    expect(built).not.toContain('test-fixture')
  })
})
