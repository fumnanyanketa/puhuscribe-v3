import { execFileSync } from 'node:child_process'
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterAll, beforeAll, describe, expect, it } from 'vitest'

// Statement 16 of factory/jobs/5-design-system/spec.md: a normal build (without
// VITE_DESIGN_REFERENCE=1) holds none of the reference page's or the Hear it
// sample's code, and none of their unreviewed Finnish.
//
// The app is built into a temporary folder that is deleted afterwards. Only
// the browser files (client/) are read: the Worker side of a local build can
// hold a copy of .env.local, which this test never opens or prints.

let out = ''
let client: string[] = []

// The Cloudflare plugin points `vite preview` at the last build through this
// file. The test puts it back afterwards, so a local `vite preview` (and the
// browser tests) keep using dist/ instead of the deleted temporary build.
const PREVIEW_POINTER = '.wrangler/deploy/config.json'
const pointerBefore = existsSync(PREVIEW_POINTER) ? readFileSync(PREVIEW_POINTER, 'utf8') : null

function allFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? allFiles(path) : [path]
  })
}

beforeAll(() => {
  out = mkdtempSync(join(tmpdir(), 'puhuscribe-build-'))
  execFileSync(
    process.execPath,
    ['node_modules/vite/bin/vite.js', 'build', '--outDir', out, '--emptyOutDir'],
    {
      // Vitest sets NODE_ENV=test, which would make Vite build in development
      // mode (where the design pages are on). A real build runs as production.
      env: { ...process.env, NODE_ENV: 'production', VITE_DESIGN_REFERENCE: '0' },
      stdio: 'ignore',
    },
  )
  client = allFiles(join(out, 'client')).filter((file) => /\.(js|css|html)$/.test(file))
}, 180_000)

afterAll(() => {
  if (out) rmSync(out, { recursive: true, force: true })
  if (pointerBefore === null) rmSync(PREVIEW_POINTER, { force: true })
  else writeFileSync(PREVIEW_POINTER, pointerBefore)
})

// Text that only the design pages hold.
const MARKERS = [
  'Design reference',
  'design-reference',
  'sample/hear-it',
  'Sample, not reviewed',
  'Alex meets Sanna.',
  'kotoisin',
  'maahanmuuttovirasto',
  // Round 3: text only the design pages hold. The shared controls' own words
  // ("Could not play", "Stop recording") will be in the learner app from job 6.
  'Try the states',
  'This button shows the busy state for two seconds',
  'No sound yet. Play lights up each word.',
]

describe('a normal build', () => {
  it('[design 16] builds the app', () => {
    expect(client.some((file) => file.endsWith('index.html'))).toBe(true)
    expect(client.some((file) => file.endsWith('.js'))).toBe(true)
  })

  it('[design 16] holds none of the design pages, their code or their samples', () => {
    const found: string[] = []
    for (const file of client) {
      const text = readFileSync(file, 'utf8')
      for (const marker of MARKERS) if (text.includes(marker)) found.push(`${marker} in ${file}`)
    }
    expect(found).toEqual([])
    expect(client.filter((file) => /HearItSample|DesignReference/.test(file))).toEqual([])
  })
})
